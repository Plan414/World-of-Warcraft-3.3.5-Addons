---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------

--[[
Name: AltNames
Revision: $Revision $
Author(s): Fin (fin@instinct.org)
Website: http://files.wowace.com/Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#AltNames
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Description: Allows people's alt characters to be linked to their mains, which will then be displayed next to their names when found in chat messages (default=off).
Dependencies: Prat
]]

Prat:AddModuleToLoad(function() 

local PRAT_MODULE = Prat:RequestModuleName("AltNames")

if PRAT_MODULE == nil then 
    return 
end

local L = Prat:GetLocalizer({})

--[===[@debug@
L:AddLocale("enUS", {
	["Start"] = true,
	["AltNames"] = true,
	["module_desc"] = "Allows people's alt characters to be linked to their mains, which can then be displayed next to their names when found in chat messages (default=off).",
	["quiet"] = "Be quiet",
	["quiet_name"] = true,
	["quiet_desc"] = "Whether to report to the chat frame or not.",
	["mainpos_name"] = "Main name position",
	["mainpos_desc"] = "Where to display a character's main name when on their alt.",
	["Main name position"] = true,
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = true,
	["Where to display a character's main name when on their alt."] = true,
	["Left"] = true,
	["Right"] = true,
	["Disabled"] = true,
	["Find characters"] = true,
	["Search the list of linked characters for matching main or alt names."] = true,
	["<search term> (eg, /altnames find fin)"] = true,
	["Link alt"] = true,
	["Link someone's alt character with the name of their main."] = true,
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = true,
	["Delete alt"] = true,
	["Delete a character's link to another character as their main."] = true,
	["Be quiet"] = true,
	["Whether to report to the chat frame or not."] = true,
	["You have not yet linked any alts with their mains."] = true,
	["no matches found"] = true,
	["List all"] = true,
	["List all links between alts and their main names."] = true,
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariables\LOKWhoIsWho.lua in the Prat directory to be able to use this)."] = true,
	["LOKWhoIsWho import"] = true,
	["Clear all"] = true,
	["Clear all links between alts and main names."] = true,
	["Colour"] = true,
	["The colour of an alt's main name that will be displayed"] = true,
	["Import from guild roster"] = true,
	['Imports alt names from the guild roster by checking for members with the rank "alt" or "alts", or guild / officer notes like "<name>\'s alt"'] = true,
	['Import from Guild Greet database'] = true,
	['Imports alt names from a Guild Greet database, if present'] = true,
	['Use class colour (from the PlayerNames module)'] = true,
	["use class colour of main"] = true,
	["use class colour of alt"] = true,
	["don't use"] = true,
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = true,
	["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = true,
	["Don't use data from the PlayerNames module at all"] = true,
	["Import options"] = true,
	["Various ways to import a main's alts from other addons"] = true,
	["Don't overwrite existing links"] = true,
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = true,
	[".*[Aa]lts?$"] = true,
	["(.-)'s? [Aa]lt"] = "%f[%a\192-\255]([%a\192-\255]+)%f[^%a\128-\255]'s [Aa]lt",
	["([^%s%p%d%c%z]+)'s alt"] = "%f[%a\192-\255]([%a\192-\255]+)%f[^%a\128-\255]'s [Aa]lt",
	['ERROR: some function sent a blank message!'] = true,
	["Alts:"] = true,
	['Main:'] = true,
	["No main name supplied to link %s to"] = true,
	['alt name exists: %s -> %s; not overwriting as set in preferences'] = true,
	['warning: alt %s already linked to %s'] = true,
	["linked alt %s => %s"] = true,
	["character removed: %s"] = true,
	['no characters called "%s" found; nothing deleted'] = true,
	['%s total alts linked to mains'] = true,
	['no alts or mains found matching "%s"'] = true,
	["searched for: %s - total matches: %s"] = true,
	['LOKWhoIsWho lua file not found, sorry.'] = true,
	["LOKWhoIsWho data not found"] = true,
	["%s alts imported from LOKWhoIsWho"] = true,
	['No Guild Greet database found'] = true,
	['You are not in a guild'] = true,
	["guild member alts found and imported: %s"] = true,
	["Fix alts"] = true,
	["Fix corrupted entries in your list of alt names."] = true,
	["Class colour"] = true,
	["Use class colour (from the PlayerNames module)"] = true,
	['Show main in tooltip'] = true,
	["Display a player's main name in the tooltip"] = true,
	['Show alts in tooltip'] = true,
	["Display a player's alts in the tooltip"] = true,
	["Found alt: %s => main: %s"] = true,
	["alt"] = true,
	["main"] = true,
	["Alt"] = true,
	["Main"] = true,
	['no alts found for character '] = true,
	['List alts'] = true,
	['List alts for a given character'] = true,
	['<main> (eg /altnames listalts Fin)'] = true,
	['%d alts found for %s: %s'] = true,
	['No arg string given to :addAlt()'] = true, 
	["Use LibAlts Data"] = true,
	["Use the data available via the shared alt information library."] = true,
	["autoguildalts_name"] = "Auto Import Guild Alts",
	["autoguildalts_desc"] = "Automatically run the import from guild roster command silently",
})
--@end-debug@]===]

-- These Localizations are auto-generated. To help with localization
-- please go to http://www.wowace.com/projects/prat-3-0/localization/


--@non-debug@
L:AddLocale("enUS", 
{
	["%d alts found for %s: %s"] = true,
	["%s alts imported from LOKWhoIsWho"] = true,
	["%s total alts linked to mains"] = true,
	["(.-)'s? [Aa]lt"] = "%f[%a\\192-\\255]([%a\\192-\\255]+)%f[^%a\\128-\\255]'s [Aa]lt",
	["([^%s%p%d%c%z]+)'s alt"] = "%f[%a\\192-\\255]([%a\\192-\\255]+)%f[^%a\\128-\\255]'s [Aa]lt",
	[".*[Aa]lts?$"] = true,
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = true,
	["<main> (eg /altnames listalts Fin)"] = true,
	["<search term> (eg, /altnames find fin)"] = true,
	Alt = true,
	AltNames = true,
	["Alts:"] = true,
	["Be quiet"] = true,
	["Class colour"] = true,
	["Clear all"] = true,
	["Clear all links between alts and main names."] = true,
	Colour = true,
	["Delete a character's link to another character as their main."] = true,
	["Delete alt"] = true,
	Disabled = true,
	["Display a player's alts in the tooltip"] = true,
	["Display a player's main name in the tooltip"] = true,
	["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = true,
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = true,
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = true,
	["Don't overwrite existing links"] = true,
	["Don't use data from the PlayerNames module at all"] = true,
	["ERROR: some function sent a blank message!"] = true,
	["Find characters"] = true,
	["Fix alts"] = true,
	["Fix corrupted entries in your list of alt names."] = true,
	["Found alt: %s => main: %s"] = true,
	["Import from Guild Greet database"] = true,
	["Import from guild roster"] = true,
	["Import options"] = true,
	["Imports alt names from a Guild Greet database, if present"] = true,
	["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = true,
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = true,
	["LOKWhoIsWho data not found"] = true,
	["LOKWhoIsWho import"] = true,
	["LOKWhoIsWho lua file not found, sorry."] = true,
	Left = true,
	["Link alt"] = true,
	["Link someone's alt character with the name of their main."] = true,
	["List all"] = true,
	["List all links between alts and their main names."] = true,
	["List alts"] = true,
	["List alts for a given character"] = true,
	Main = true,
	["Main name position"] = true,
	["Main:"] = true,
	["No Guild Greet database found"] = true,
	["No arg string given to :addAlt()"] = true,
	["No main name supplied to link %s to"] = true,
	Right = true,
	["Search the list of linked characters for matching main or alt names."] = true,
	["Show alts in tooltip"] = true,
	["Show main in tooltip"] = true,
	Start = true,
	["The colour of an alt's main name that will be displayed"] = true,
	["Use LibAlts Data"] = true,
	["Use class colour (from the PlayerNames module)"] = true,
	["Use the data available via the shared alt information library."] = true,
	["Various ways to import a main's alts from other addons"] = true,
	["Where to display a character's main name when on their alt."] = true,
	["Whether to report to the chat frame or not."] = true,
	["You are not in a guild"] = true,
	["You have not yet linked any alts with their mains."] = true,
	alt = true,
	["alt name exists: %s -> %s; not overwriting as set in preferences"] = true,
	autoguildalts_desc = "Automatically run the import from guild roster command silently",
	autoguildalts_name = "Auto Import Guild Alts",
	["character removed: %s"] = true,
	["don't use"] = true,
	["guild member alts found and imported: %s"] = true,
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = true,
	["linked alt %s => %s"] = true,
	main = true,
	mainpos_desc = "Where to display a character's main name when on their alt.",
	mainpos_name = "Main name position",
	module_desc = "Allows people's alt characters to be linked to their mains, which can then be displayed next to their names when found in chat messages (default=off).",
	["no alts found for character "] = true,
	["no alts or mains found matching \"%s\""] = true,
	["no characters called \"%s\" found; nothing deleted"] = true,
	["no matches found"] = true,
	quiet = "Be quiet",
	quiet_desc = "Whether to report to the chat frame or not.",
	quiet_name = true,
	["searched for: %s - total matches: %s"] = true,
	["use class colour of alt"] = true,
	["use class colour of main"] = true,
	["warning: alt %s already linked to %s"] = true,
}

)
L:AddLocale("frFR",  
{
	-- ["%d alts found for %s: %s"] = "",
	-- ["%s alts imported from LOKWhoIsWho"] = "",
	-- ["%s total alts linked to mains"] = "",
	-- ["(.-)'s? [Aa]lt"] = "",
	-- ["([^%s%p%d%c%z]+)'s alt"] = "",
	-- [".*[Aa]lts?$"] = "",
	-- ["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "",
	-- ["<main> (eg /altnames listalts Fin)"] = "",
	-- ["<search term> (eg, /altnames find fin)"] = "",
	-- Alt = "",
	-- AltNames = "",
	-- ["Alts:"] = "",
	-- ["Be quiet"] = "",
	-- ["Class colour"] = "",
	-- ["Clear all"] = "",
	-- ["Clear all links between alts and main names."] = "",
	-- Colour = "",
	-- ["Delete a character's link to another character as their main."] = "",
	-- ["Delete alt"] = "",
	-- Disabled = "",
	-- ["Display a player's alts in the tooltip"] = "",
	["Display a player's main name in the tooltip"] = "Affiche le nom principale d'un joueur dans la tooltip",
	-- ["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "Ne pas ??craser les liens principal <-> Alternatif lors d'un import ou d'un ajout de nouveaux personnages Alternatifs",
	["Don't overwrite existing links"] = "Ne pas ??craser les liens existant",
	["Don't use data from the PlayerNames module at all"] = "Ne pas utiliser les donn??e du module \"PlayerNames\" du tout",
	["ERROR: some function sent a blank message!"] = "ERREUR: une fonction a envoy?? un message blanc !",
	["Find characters"] = "Trouver des personnages",
	["Fix alts"] = "R??parer les alternatifs", -- Needs review
	["Fix corrupted entries in your list of alt names."] = "R??parer les entr??es corrompues dans votre liste de noms alternatifs.",
	-- ["Found alt: %s => main: %s"] = "",
	-- ["Import from Guild Greet database"] = "",
	-- ["Import from guild roster"] = "",
	-- ["Import options"] = "",
	-- ["Imports alt names from a Guild Greet database, if present"] = "",
	-- ["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "",
	-- ["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "",
	-- ["LOKWhoIsWho data not found"] = "",
	-- ["LOKWhoIsWho import"] = "",
	-- ["LOKWhoIsWho lua file not found, sorry."] = "",
	-- Left = "",
	-- ["Link alt"] = "",
	-- ["Link someone's alt character with the name of their main."] = "",
	-- ["List all"] = "",
	-- ["List all links between alts and their main names."] = "",
	-- ["List alts"] = "",
	-- ["List alts for a given character"] = "",
	-- Main = "",
	-- ["Main name position"] = "",
	-- ["Main:"] = "",
	-- ["No Guild Greet database found"] = "",
	-- ["No arg string given to :addAlt()"] = "",
	-- ["No main name supplied to link %s to"] = "",
	Right = "Droite",
	-- ["Search the list of linked characters for matching main or alt names."] = "",
	-- ["Show alts in tooltip"] = "",
	-- ["Show main in tooltip"] = "",
	-- Start = "",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	-- ["Use LibAlts Data"] = "",
	-- ["Use class colour (from the PlayerNames module)"] = "",
	-- ["Use the data available via the shared alt information library."] = "",
	-- ["Various ways to import a main's alts from other addons"] = "",
	-- ["Where to display a character's main name when on their alt."] = "",
	-- ["Whether to report to the chat frame or not."] = "",
	-- ["You are not in a guild"] = "",
	-- ["You have not yet linked any alts with their mains."] = "",
	-- alt = "",
	-- ["alt name exists: %s -> %s; not overwriting as set in preferences"] = "",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	-- ["character removed: %s"] = "",
	-- ["don't use"] = "",
	-- ["guild member alts found and imported: %s"] = "",
	-- ["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "",
	-- ["linked alt %s => %s"] = "",
	-- main = "",
	-- mainpos_desc = "",
	-- mainpos_name = "",
	-- module_desc = "",
	-- ["no alts found for character "] = "",
	-- ["no alts or mains found matching \"%s\""] = "",
	-- ["no characters called \"%s\" found; nothing deleted"] = "",
	-- ["no matches found"] = "",
	-- quiet = "",
	-- quiet_desc = "",
	-- quiet_name = "",
	-- ["searched for: %s - total matches: %s"] = "",
	-- ["use class colour of alt"] = "",
	-- ["use class colour of main"] = "",
	-- ["warning: alt %s already linked to %s"] = "",
}

)
L:AddLocale("deDE", 
{
	["%d alts found for %s: %s"] = "%d Alts gefunden f??r %s: %s",
	["%s alts imported from LOKWhoIsWho"] = "%s Alts importiert von LOKWhoIsWho",
	["%s total alts linked to mains"] = "Insgesamt %s Alts mit Haupt-Charakteren verkn??pft",
	["(.-)'s? [Aa]lt"] = " %f[%a\\192-\\255]([%a\\192-\\255]+)%f[^%a\\128-\\255]s [Aa]lt",
	["([^%s%p%d%c%z]+)'s alt"] = "%f[%a\\192-\\255]([%a\\192-\\255]+)%f[^%a\\128-\\255]s [Aa]lt",
	[".*[Aa]lts?$"] = true,
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "<Altname> (z.B. /altnames del FalscherAltname)",
	["<main> (eg /altnames listalts Fin)"] = "<main> (z.b. /altnames listalts Shylera)",
	["<search term> (eg, /altnames find fin)"] = "<Suchbegriff> (z.b. /altnames find Shy)",
	Alt = true,
	AltNames = "AltName",
	["Alts:"] = true,
	["Be quiet"] = "Stumm schalten",
	["Class colour"] = "Klassenfarbe",
	["Clear all"] = "Alle l??schen",
	["Clear all links between alts and main names."] = "Alle Verkn??pfungen zwischen Alt- und Haupt-Charakternamen l??schen",
	Colour = "Farbe",
	["Delete a character's link to another character as their main."] = "Die Verkn??pfung eines Charakters zu einem anderen (Haupt-)Charakter l??schen.",
	["Delete alt"] = "Alts l??schen",
	Disabled = "Inaktiv",
	["Display a player's alts in the tooltip"] = "Die Altnamen eines Spielers im Tooltip anzeigen.",
	["Display a player's main name in the tooltip"] = "Den Namen des Hauptcharakters eines Spielers im Tooltip anzeigen.",
	["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "Namen der Hauptcharaktere in Klassenfarbe des Alts anzeigen (Daten werden vom Modul PlayerNames geliefert, falls aktiviert).",
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "Namen der Hauptcharaktere in Klassenfarbe des Hauptcharakters anzeigen (Daten werden vom Modul PlayerNames geliefert, falls aktiviert).",
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "Vorhandenen Alt nicht ??berschreiben <-> Verkn??pfungen zu Hauptcharakteren w??hrend des Imports oder des Hinzuf??gens von neuen Alts.",
	["Don't overwrite existing links"] = "Bestehende Verkn??pfungen nicht ??berschreiben",
	["Don't use data from the PlayerNames module at all"] = "Daten vom Modul SpielerNamen nicht verwenden.",
	["ERROR: some function sent a blank message!"] = "ERROR: eine Funktion hat eine leere Nachricht hinterlassen.",
	["Find characters"] = "Charaktersuche",
	["Fix alts"] = "Alts reparieren",
	["Fix corrupted entries in your list of alt names."] = "Korrupte Eintr??ge in deiner Liste der Alt-Namen reparieren.",
	["Found alt: %s => main: %s"] = "Alt gefunden: %s => Haupt: %s",
	["Import from Guild Greet database"] = "Importiere von der Gilden-Begr????ungs-Datenbank",
	["Import from guild roster"] = "Importiere von Gildenliste",
	["Import options"] = "Import-Optionen",
	["Imports alt names from a Guild Greet database, if present"] = "Importiert Alt-Namen von einer Gilden-Begr????ungs-Datenbank, wenn vorhanden.",
	["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "Importiert Alt-Namen von der Gildenliste, indem Mitglieder mit dem Rang \"alt\" oder \"alts\", oder Gilden- und Gildenoffiziersnotizen wie \"<name>s alt\" gepr??ft werden.",
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "Importiert Daten von LOKWhoIsWho, wenn vorhanden (um diese Funktion verwenden zu k??nnen, kopiere deine Datei SavedVariablesLOKWhoIsWho.lua in den Prat-Ordner!).",
	["LOKWhoIsWho data not found"] = "LOKWhoIsWho-Daten nicht gefunden",
	["LOKWhoIsWho import"] = "LOKWhoIsWho-Import",
	["LOKWhoIsWho lua file not found, sorry."] = "LOKWhoIsWho.lua-Datei nicht gefunden, entschuldige.",
	Left = "Links",
	["Link alt"] = "Alt verkn??pfen",
	["Link someone's alt character with the name of their main."] = "Jemandes Alt-Charakter mit dem Namen seines Hauptcharakters verkn??pfen.",
	["List all"] = "Alle auflisten",
	["List all links between alts and their main names."] = "Alle Verkn??pfungen zwischen Alts und deren Hauptchar-Namen auflisten.",
	["List alts"] = "Alts auflisten",
	["List alts for a given character"] = "Alts eines bestimmten Charakters auflisten.",
	Main = "Hauptchar",
	["Main name position"] = "Position des Namens eines Hauptcharakters",
	["Main:"] = "Hauptchar:",
	["No Guild Greet database found"] = "Keine Gilden-Begr????ungs-Datenbank gefunden.",
	["No arg string given to :addAlt()"] = "Kein Parameter angegeben f??r: :addAlt()",
	["No main name supplied to link %s to"] = "Kein Hauptcharname geliefert, mit dem %s verkn??pft werden kann.",
	Right = "Rechts",
	["Search the list of linked characters for matching main or alt names."] = "Durchsuche die Liste der verkn??pften Charaktere nach passenden Hauptchar- oder Altchar-Namen.",
	["Show alts in tooltip"] = "Alts im Tooltip anzeigen",
	["Show main in tooltip"] = "Hauptchar im Tooltip anzeigen",
	Start = "Starte",
	["The colour of an alt's main name that will be displayed"] = "Die Farbe des Hauptcharnamens eines Alts, der dargestellt wird.",
	["Use LibAlts Data"] = "Daten von LibAlts benutzen",
	["Use class colour (from the PlayerNames module)"] = "Klassenfarbe verwenden (vom Modul \"PlayerNames\") ",
	["Use the data available via the shared alt information library."] = "Verwende die vorhandenen Daten ??ber die gemeinsam genutzte Alt-Informations-Sammlung.",
	["Various ways to import a main's alts from other addons"] = "Verschiedene M??glichkeiten, wie man die Alts eines Hauptchars von anderen AddOns importieren kann.",
	["Where to display a character's main name when on their alt."] = "Wo der Name eines Hauptcharakters angezeigt werden soll, wenn diese mit ihrem Alt-Char zocken.",
	["Whether to report to the chat frame or not."] = "Ob Meldungen im Chat-Rahmen erscheinen oder nicht.",
	["You are not in a guild"] = "Du bist in keiner Gilde",
	["You have not yet linked any alts with their mains."] = "Bisher hast du keine Alt-Chars mit ihren Hauptchars verkn??pft.",
	alt = "Alt",
	["alt name exists: %s -> %s; not overwriting as set in preferences"] = "Alt-Name vorhanden: %s -> %s; wir nicht ??berschrieben, wie in der Auswahl eingestellt.",
	autoguildalts_desc = "Automatisch den Import von der Gildenliste im Hintergrund ausf??hren.",
	autoguildalts_name = "Auto-Import der Gilden-Alts",
	["character removed: %s"] = "Charakter entfernt: %s",
	["don't use"] = "Nicht verwenden",
	["guild member alts found and imported: %s"] = "Alt-Chars eines Gildenmitglieds gefunden und importiert: %s",
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "Verkn??pfe <alt-name> <hauptcharname> (z.B. /altnames link Fin Finjaderaltvonfin)",
	["linked alt %s => %s"] = "Altchar verkn??pft %s => %s",
	main = "Hauptchar",
	mainpos_desc = "Wo der Name eines Hauptchars dargestellt werden soll, wenn diese mit ihrem Alt-Char zocken.",
	mainpos_name = "Hauptchar-Name Position",
	module_desc = "Erlaubt das Verkn??pfen von Alt-Chars mit deren Hauptchars, was dann neben deren Namen angezeigt werden kann, wenn sie in Chat-Mitteilungen erscheinen (standard = aus).",
	["no alts found for character "] = "Keine Alt-Chars f??r diesen Charakter gefunden.",
	["no alts or mains found matching \"%s\""] = "Keine Alt-Chars oder Hauptchars gefunden, die mit \"%s\" ??bereinstimmen.",
	["no characters called \"%s\" found; nothing deleted"] = "Keine Charaktere mit dem Namen \"%s\" gefunden; es wurde nichts gel??scht.",
	["no matches found"] = "Keine ??bereinstimmungen gefunden.",
	quiet = "Sei ruhig",
	quiet_desc = "Ob Meldungen an den Chat-Rahmen gesendet werden oder nicht.",
	quiet_name = true,
	["searched for: %s - total matches: %s"] = "Gesucht nach: %s - gesamte ??bereinstimmungen: %s",
	["use class colour of alt"] = "Klassenfarbe f??r Alt-Char verwenden.",
	["use class colour of main"] = "Klassenfarbe des Hauptchars verwenden",
	["warning: alt %s already linked to %s"] = "Warnung: Alt %s ist bereits mit %s verkn??pft!",
}

)
L:AddLocale("koKR",  
{
	-- ["%d alts found for %s: %s"] = "",
	-- ["%s alts imported from LOKWhoIsWho"] = "",
	-- ["%s total alts linked to mains"] = "",
	-- ["(.-)'s? [Aa]lt"] = "",
	-- ["([^%s%p%d%c%z]+)'s alt"] = "",
	-- [".*[Aa]lts?$"] = "",
	-- ["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "",
	-- ["<main> (eg /altnames listalts Fin)"] = "",
	-- ["<search term> (eg, /altnames find fin)"] = "",
	-- Alt = "",
	-- AltNames = "",
	-- ["Alts:"] = "",
	-- ["Be quiet"] = "",
	["Class colour"] = "?????? ??????",
	-- ["Clear all"] = "",
	-- ["Clear all links between alts and main names."] = "",
	Colour = "??????",
	-- ["Delete a character's link to another character as their main."] = "",
	-- ["Delete alt"] = "",
	Disabled = "?????????",
	-- ["Display a player's alts in the tooltip"] = "",
	-- ["Display a player's main name in the tooltip"] = "",
	-- ["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "",
	-- ["Don't overwrite existing links"] = "",
	-- ["Don't use data from the PlayerNames module at all"] = "",
	-- ["ERROR: some function sent a blank message!"] = "",
	-- ["Find characters"] = "",
	-- ["Fix alts"] = "",
	-- ["Fix corrupted entries in your list of alt names."] = "",
	-- ["Found alt: %s => main: %s"] = "",
	-- ["Import from Guild Greet database"] = "",
	-- ["Import from guild roster"] = "",
	-- ["Import options"] = "",
	-- ["Imports alt names from a Guild Greet database, if present"] = "",
	-- ["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "",
	-- ["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "",
	-- ["LOKWhoIsWho data not found"] = "",
	-- ["LOKWhoIsWho import"] = "",
	-- ["LOKWhoIsWho lua file not found, sorry."] = "",
	-- Left = "",
	-- ["Link alt"] = "",
	-- ["Link someone's alt character with the name of their main."] = "",
	-- ["List all"] = "",
	-- ["List all links between alts and their main names."] = "",
	-- ["List alts"] = "",
	-- ["List alts for a given character"] = "",
	-- Main = "",
	-- ["Main name position"] = "",
	-- ["Main:"] = "",
	-- ["No Guild Greet database found"] = "",
	-- ["No arg string given to :addAlt()"] = "",
	-- ["No main name supplied to link %s to"] = "",
	-- Right = "",
	-- ["Search the list of linked characters for matching main or alt names."] = "",
	-- ["Show alts in tooltip"] = "",
	-- ["Show main in tooltip"] = "",
	-- Start = "",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	-- ["Use LibAlts Data"] = "",
	["Use class colour (from the PlayerNames module)"] = "?????? ?????? ?????? (???????????? ?????? ??????)",
	-- ["Use the data available via the shared alt information library."] = "",
	-- ["Various ways to import a main's alts from other addons"] = "",
	-- ["Where to display a character's main name when on their alt."] = "",
	-- ["Whether to report to the chat frame or not."] = "",
	["You are not in a guild"] = "????????? ????????? ?????? ?????? ????????????",
	-- ["You have not yet linked any alts with their mains."] = "",
	-- alt = "",
	-- ["alt name exists: %s -> %s; not overwriting as set in preferences"] = "",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	-- ["character removed: %s"] = "",
	-- ["don't use"] = "",
	-- ["guild member alts found and imported: %s"] = "",
	-- ["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "",
	-- ["linked alt %s => %s"] = "",
	-- main = "",
	-- mainpos_desc = "",
	-- mainpos_name = "",
	-- module_desc = "",
	-- ["no alts found for character "] = "",
	-- ["no alts or mains found matching \"%s\""] = "",
	-- ["no characters called \"%s\" found; nothing deleted"] = "",
	-- ["no matches found"] = "",
	-- quiet = "",
	-- quiet_desc = "",
	-- quiet_name = "",
	-- ["searched for: %s - total matches: %s"] = "",
	-- ["use class colour of alt"] = "",
	-- ["use class colour of main"] = "",
	-- ["warning: alt %s already linked to %s"] = "",
}

)
L:AddLocale("esMX",  
{
	-- ["%d alts found for %s: %s"] = "",
	-- ["%s alts imported from LOKWhoIsWho"] = "",
	-- ["%s total alts linked to mains"] = "",
	-- ["(.-)'s? [Aa]lt"] = "",
	-- ["([^%s%p%d%c%z]+)'s alt"] = "",
	-- [".*[Aa]lts?$"] = "",
	-- ["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "",
	-- ["<main> (eg /altnames listalts Fin)"] = "",
	-- ["<search term> (eg, /altnames find fin)"] = "",
	-- Alt = "",
	-- AltNames = "",
	-- ["Alts:"] = "",
	-- ["Be quiet"] = "",
	-- ["Class colour"] = "",
	-- ["Clear all"] = "",
	-- ["Clear all links between alts and main names."] = "",
	-- Colour = "",
	-- ["Delete a character's link to another character as their main."] = "",
	-- ["Delete alt"] = "",
	-- Disabled = "",
	-- ["Display a player's alts in the tooltip"] = "",
	-- ["Display a player's main name in the tooltip"] = "",
	-- ["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "",
	-- ["Don't overwrite existing links"] = "",
	-- ["Don't use data from the PlayerNames module at all"] = "",
	-- ["ERROR: some function sent a blank message!"] = "",
	-- ["Find characters"] = "",
	-- ["Fix alts"] = "",
	-- ["Fix corrupted entries in your list of alt names."] = "",
	-- ["Found alt: %s => main: %s"] = "",
	-- ["Import from Guild Greet database"] = "",
	-- ["Import from guild roster"] = "",
	-- ["Import options"] = "",
	-- ["Imports alt names from a Guild Greet database, if present"] = "",
	-- ["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "",
	-- ["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "",
	-- ["LOKWhoIsWho data not found"] = "",
	-- ["LOKWhoIsWho import"] = "",
	-- ["LOKWhoIsWho lua file not found, sorry."] = "",
	-- Left = "",
	-- ["Link alt"] = "",
	-- ["Link someone's alt character with the name of their main."] = "",
	-- ["List all"] = "",
	-- ["List all links between alts and their main names."] = "",
	-- ["List alts"] = "",
	-- ["List alts for a given character"] = "",
	-- Main = "",
	-- ["Main name position"] = "",
	-- ["Main:"] = "",
	-- ["No Guild Greet database found"] = "",
	-- ["No arg string given to :addAlt()"] = "",
	-- ["No main name supplied to link %s to"] = "",
	-- Right = "",
	-- ["Search the list of linked characters for matching main or alt names."] = "",
	-- ["Show alts in tooltip"] = "",
	-- ["Show main in tooltip"] = "",
	-- Start = "",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	-- ["Use LibAlts Data"] = "",
	-- ["Use class colour (from the PlayerNames module)"] = "",
	-- ["Use the data available via the shared alt information library."] = "",
	-- ["Various ways to import a main's alts from other addons"] = "",
	-- ["Where to display a character's main name when on their alt."] = "",
	-- ["Whether to report to the chat frame or not."] = "",
	-- ["You are not in a guild"] = "",
	-- ["You have not yet linked any alts with their mains."] = "",
	-- alt = "",
	-- ["alt name exists: %s -> %s; not overwriting as set in preferences"] = "",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	-- ["character removed: %s"] = "",
	-- ["don't use"] = "",
	-- ["guild member alts found and imported: %s"] = "",
	-- ["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "",
	-- ["linked alt %s => %s"] = "",
	-- main = "",
	-- mainpos_desc = "",
	-- mainpos_name = "",
	-- module_desc = "",
	-- ["no alts found for character "] = "",
	-- ["no alts or mains found matching \"%s\""] = "",
	-- ["no characters called \"%s\" found; nothing deleted"] = "",
	-- ["no matches found"] = "",
	-- quiet = "",
	-- quiet_desc = "",
	-- quiet_name = "",
	-- ["searched for: %s - total matches: %s"] = "",
	-- ["use class colour of alt"] = "",
	-- ["use class colour of main"] = "",
	-- ["warning: alt %s already linked to %s"] = "",
}

)
L:AddLocale("ruRU",  
{
	["%d alts found for %s: %s"] = "%d ???????????? ?????????????? ?????? %s: %s",
	["%s alts imported from LOKWhoIsWho"] = "?????????????????????????? ???????????? ???? LOKWhoIsWho: %s",
	["%s total alts linked to mains"] = "?????????? ???????????? ?????????????? ?? ???????????????? %s",
	["(.-)'s? [Aa]lt"] = "(.-)'s? [????]??????", -- Needs review
	["([^%s%p%d%c%z]+)'s alt"] = "([^%s%p%d%c%z]+) ????????", -- Needs review
	[".*[Aa]lts?$"] = ".*[????]?????????$",
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "<?????? ??????????> (?? ??????????????, /altnames del ????????????)",
	["<main> (eg /altnames listalts Fin)"] = "<????????????????> (?? ??????????????: /altnames listalts ????????????)",
	["<search term> (eg, /altnames find fin)"] = "<?????????????? ????????????> (?? ??????????????, /altnames find ????????????)",
	Alt = "????????",
	AltNames = "?????? ????????????",
	["Alts:"] = "??????????:",
	-- ["Be quiet"] = "",
	["Class colour"] = "?????????????? ???? ????????????",
	["Clear all"] = "???????????????? ??????",
	["Clear all links between alts and main names."] = "???????????????? ?????? ???????????? ?????????? ?????????????? ?? ?????????????????? ??????????????.",
	Colour = "????????",
	["Delete a character's link to another character as their main."] = "?????????????? ???????????? ?????????????????? ???? ?????????????? ?????????????????? ???????? ???? ????????????????.",
	["Delete alt"] = "?????????????? ??????????",
	Disabled = "??????????????????",
	["Display a player's alts in the tooltip"] = "???????????????????? ???????????? ???????????? ?? ??????????????????",
	["Display a player's main name in the tooltip"] = "???????????????????? ???????????????? ???????????????????? ???????????? ?? ??????????????????",
	["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "???????????????????? ?????????? ?????????????????? ?????????????????? ???? ???????????? ?????????? (???????????? ?????????????? ???? ???????????? PlayerNames, ???????? ???? ??????????????)",
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "???????????????????? ?????????? ?????????????????? ?????????????????? ???? ?????? ?????????????????? ???????????? (???????????? ?????????????? ???? ???????????? PlayerNames, ???????? ???? ??????????????)",
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "???? ???????????????????????????? ???????????????????????? ???????????? ???????????? <-> ???????????????? ?????? ???????????????????????????? ?????? ???????????????????? ????????????.",
	["Don't overwrite existing links"] = "???? ???????????????????????????? ???????????????????????? ????????????",
	["Don't use data from the PlayerNames module at all"] = "???? ???????????????????????? ?????? ???????? ???????????? ???? ???????????? PlayerNames",
	-- ["ERROR: some function sent a blank message!"] = "",
	["Find characters"] = "?????????? ??????????????????",
	["Fix alts"] = "?????????????????? ????????????",
	["Fix corrupted entries in your list of alt names."] = "?????????????????? ???????????????????????? ???????????? ?? ?????????? ???????????? ???????? ????????????.",
	["Found alt: %s => main: %s"] = "???????? ????????????: %s => ????????????????: %s",
	["Import from Guild Greet database"] = "???????????? ???????? ???????????? Guild Greet",
	["Import from guild roster"] = "???????????? ???? ???????????? ??????????????",
	["Import options"] = "?????????????????? ??????????????",
	["Imports alt names from a Guild Greet database, if present"] = "???????????? ???????????? ???? ???????? ???????????? Guild Greet, ???????? ????????",
	["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "???????????? ???????? ???????????? ???? ???????????? ?????????????? ?????????????????? ?????????????????? ???? ???????????? \"alt\" ?????? \"alts\", ?????? ?????????? / ???????????????????? ?????????????? ???????? \"<name> alt\"",
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "?????????????????????????? ???????????? ???? LOKWhoIsWho, ???????? ???????? (???????????????????? ?????? SavedVariables/LOKWhoIsWho.lua ?? ?????????? Prat?? ?????? ??????????????????????????).",
	["LOKWhoIsWho data not found"] = "???????????? LOKWhoIsWho ???? ??????????????",
	["LOKWhoIsWho import"] = "???????????? ???? LOKWhoIsWho",
	["LOKWhoIsWho lua file not found, sorry."] = "Lua ???????? LOKWhoIsWho ???? ????????????, ????????????????.",
	Left = "??????????",
	["Link alt"] = "?????????????? ??????????",
	["Link someone's alt character with the name of their main."] = "?????????????? ?????????????????????????? ?????????? ?? ???????????? ?????? ?????????????????? ??????????????????.",
	["List all"] = "???????? ????????????",
	["List all links between alts and their main names."] = "???????? ???????????? ???????????? ?????????? ?????????????? ?? ?????????????????? ??????????????.",
	["List alts"] = "???????????? ????????????",
	["List alts for a given character"] = "???????????? ???????????? ?????? ???????????????? ????????????????????",
	Main = "????????????????",
	["Main name position"] = "?????????????? ?????????????????? ??????????",
	["Main:"] = "????????????????:",
	["No Guild Greet database found"] = "???????? ???????????? Guild Greet ???? ??????????????",
	-- ["No arg string given to :addAlt()"] = "",
	["No main name supplied to link %s to"] = "???? ?????????????????????????? ???????????????? ?????? ?????? ???????????? %s ??",
	Right = "????????????",
	["Search the list of linked characters for matching main or alt names."] = "?????????? ?? ???????????? ?????????????????? ????????????????????.",
	["Show alts in tooltip"] = "?????????? ?? ??????????????????",
	["Show main in tooltip"] = "???????????????? ?? ??????????????????",
	Start = "????????????",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	["Use LibAlts Data"] = "???????????????????????? LibAlts",
	["Use class colour (from the PlayerNames module)"] = "???????????????????????? ?????????????? ???? ?????????? ???????????? (???? ???????????? PlayerNames)",
	-- ["Use the data available via the shared alt information library."] = "",
	["Various ways to import a main's alts from other addons"] = "?????????????????? ???????????????? ?????????????? ???????????? ???????????????? ???????????????????? ???? ???????????? ??????????????",
	["Where to display a character's main name when on their alt."] = "?????? ???????????????????? ?????? ???????????????? ?????????????????? ???????? ???? ???? ??????????.",
	["Whether to report to the chat frame or not."] = "???????????????? ?? ?????? ?????? ??????.",
	["You are not in a guild"] = "???? ???? ?????????????????? ??????????????",
	["You have not yet linked any alts with their mains."] = "???? ?????? ???? ?????????????? ???? ???????????? ?????????? ?? ???? ??????????????????.",
	alt = "????????",
	["alt name exists: %s -> %s; not overwriting as set in preferences"] = "?????? ?????????? ?????? ????????????????????: %s -> %s; ???????????????????? ?????????????????? ??????????????????????",
	-- autoguildalts_desc = "",
	autoguildalts_name = "????????-???????????? ???????????? ??????????????",
	["character removed: %s"] = "???????????????? ????????????: %s",
	["don't use"] = "???? ????????????????????",
	["guild member alts found and imported: %s"] = "%s: ?????????????? ???????????? ???????????????????? ?????????????? ?? ????????????????????????????",
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "link <?????? ??????????> <?????? ??????????????????> (????????????, /altnames link ???????????? ????????????????????????)",
	["linked alt %s => %s"] = "???????? %s ???????????? ?? => %s",
	main = "????????????????",
	mainpos_desc = "?????? ???????????????????? ?????? ???????????????? ?????????????????? ???????? ???? ???? ??????????.",
	mainpos_name = "?????????????? ?????????????????? ??????????",
	-- module_desc = "",
	["no alts found for character "] = "???? ?????????????? ???????????? ?????? ??????????????????",
	["no alts or mains found matching \"%s\""] = "?????????????????? ???????????? ?????? ???????????????? \"%s\"",
	["no characters called \"%s\" found; nothing deleted"] = "???? ???????????? ???????????????? ???? ?????????? \"%s\"; ???????????? ??????????????",
	["no matches found"] = "???????????????????? ???? ??????????????",
	-- quiet = "",
	-- quiet_desc = "",
	-- quiet_name = "",
	["searched for: %s - total matches: %s"] = "?????????? ??????: %s - ?????????? ????????????????????: %s",
	["use class colour of alt"] = "?????????? ???????????? ?????? ????????????",
	["use class colour of main"] = "?????????? ???????????? ?????? ????????????????",
	["warning: alt %s already linked to %s"] = "????????????????: ???????? %s ?????? ???????????? ?? %s",
}

)
L:AddLocale("zhCN",  
{
	["%d alts found for %s: %s"] = "%d ???????????? %s: %s",
	["%s alts imported from LOKWhoIsWho"] = "%s?????????LOKWhoIsWho??????",
	["%s total alts linked to mains"] = "%s???????????????????????????",
	["(.-)'s? [Aa]lt"] = true, -- Needs review
	["([^%s%p%d%c%z]+)'s alt"] = true, -- Needs review
	[".*[Aa]lts?$"] = true,
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "<????????????> (???, /altnames del ??????????????????????????????????????????)",
	["<main> (eg /altnames listalts Fin)"] = "<??????> (??? /altnames listalts ????????????)",
	["<search term> (eg, /altnames find fin)"] = "<????????????>(???, /altnames find ????????????)",
	Alt = "??????",
	AltNames = "????????????",
	["Alts:"] = "??????:",
	["Be quiet"] = "??????",
	["Class colour"] = "????????????",
	["Clear all"] = "????????????",
	["Clear all links between alts and main names."] = "?????????????????????????????????????????????",
	Colour = "??????",
	["Delete a character's link to another character as their main."] = "??????????????????????????????????????????????????????",
	["Delete alt"] = "????????????",
	Disabled = "??????",
	["Display a player's alts in the tooltip"] = "???????????????????????????????????????",
	["Display a player's main name in the tooltip"] = "???????????????????????????????????????",
	["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "???????????????????????????????????????????????????(??????????????????????????????,??????????????????)",
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "???????????????????????????????????????????????????(??????????????????????????????,??????????????????)",
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "????????????????????????????????????????????????????????? <-> ??????",
	["Don't overwrite existing links"] = "????????????????????????",
	["Don't use data from the PlayerNames module at all"] = "???????????????????????????????????????",
	["ERROR: some function sent a blank message!"] = "??????:???????????????????????????????????????!",
	["Find characters"] = "????????????",
	["Fix alts"] = "????????????",
	["Fix corrupted entries in your list of alt names."] = "???????????????????????????????????????????????????",
	["Found alt: %s => main: %s"] = "????????????: %s => ??????: %s",
	["Import from Guild Greet database"] = "??????????????????????????????",
	["Import from guild roster"] = "?????????????????????",
	["Import options"] = "????????????",
	["Imports alt names from a Guild Greet database, if present"] = "??????????????????????????????????????????,????????????",
	["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "????????????????????????????????????????????????????????????????????????????????????????????????,???????????????????????????\"<??????>?????????\"",
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "???LOKWhoIsWho????????????,????????????(??????Prat????????????SavedVariablesLOKWhoIsWho.lua??????????????????).",
	["LOKWhoIsWho data not found"] = "?????????LOKWhoIsWho??????",
	["LOKWhoIsWho import"] = "LOKWhoIsWho??????",
	["LOKWhoIsWho lua file not found, sorry."] = "?????????LOKWhoIsWho????????????,??????",
	Left = "??????",
	["Link alt"] = "????????????",
	["Link someone's alt character with the name of their main."] = "???????????????????????????????????????????????????",
	["List all"] = "????????????",
	["List all links between alts and their main names."] = "??????????????????????????????????????????????????????",
	["List alts"] = "????????????",
	["List alts for a given character"] = "???????????????????????????",
	Main = "??????",
	["Main name position"] = "??????????????????",
	["Main:"] = "??????:",
	["No Guild Greet database found"] = "??????????????????????????????",
	["No arg string given to :addAlt()"] = "?????????????????????:addAlt()",
	["No main name supplied to link %s to"] = "??????????????????????????????%s",
	Right = "??????",
	["Search the list of linked characters for matching main or alt names."] = "?????????????????????????????????????????????????????????",
	["Show alts in tooltip"] = "????????????????????????",
	["Show main in tooltip"] = "????????????????????????",
	Start = "??????",
	["The colour of an alt's main name that will be displayed"] = "???????????????????????????????????????",
	["Use LibAlts Data"] = "??????LibAlts??????",
	["Use class colour (from the PlayerNames module)"] = "??????????????????(?????????????????????)",
	["Use the data available via the shared alt information library."] = "??????????????????????????????????????????",
	["Various ways to import a main's alts from other addons"] = "???????????????????????????????????????????????????",
	["Where to display a character's main name when on their alt."] = "????????????????????????????????????????????????",
	["Whether to report to the chat frame or not."] = "????????????????????????",
	["You are not in a guild"] = "????????????????????????",
	["You have not yet linked any alts with their mains."] = "?????????????????????????????????????????????",
	alt = "??????",
	["alt name exists: %s -> %s; not overwriting as set in preferences"] = "??????????????????: %s -> %s;????????????????????????",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	["character removed: %s"] = "????????????: %s",
	["don't use"] = "?????????",
	["guild member alts found and imported: %s"] = "?????????????????????????????????: %s",
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "?????? <????????????> <????????????>(???,/altnames link ???????????? ?????????)",
	["linked alt %s => %s"] = "??????????????? %s => %s",
	main = "??????",
	mainpos_desc = "???????????????????????????????????????????????????",
	mainpos_name = "??????????????????",
	module_desc = "????????????????????????????????????????????????,???????????????????????????????????????(??????=??????).",
	["no alts found for character "] = "?????????????????????",
	["no alts or mains found matching \"%s\""] = "???????????????\"%s\"???????????????",
	["no characters called \"%s\" found; nothing deleted"] = "???????????????\"%s\"??????;?????????",
	["no matches found"] = "???????????????",
	quiet = "??????",
	quiet_desc = "????????????????????????",
	quiet_name = "??????_??????",
	["searched for: %s - total matches: %s"] = "??????: %s - ????????????: %s",
	["use class colour of alt"] = "?????????????????????",
	["use class colour of main"] = "?????????????????????",
	["warning: alt %s already linked to %s"] = "??????:??????%s????????????%s",
}

)
L:AddLocale("esES",  
{
	["%d alts found for %s: %s"] = "%d alternativos encontrados para %s: %s",
	["%s alts imported from LOKWhoIsWho"] = "%s alternativos importados desde LOKWhoIsWho",
	["%s total alts linked to mains"] = "alternativos total %s vinculados a principales",
	["(.-)'s? [Aa]lt"] = true, -- Needs review
	["([^%s%p%d%c%z]+)'s alt"] = true, -- Needs review
	[".*[Aa]lts?$"] = true,
	["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "<nombre alt> (ej, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)",
	["<main> (eg /altnames listalts Fin)"] = "<principal> (ej /altnames listalts Fin)",
	["<search term> (eg, /altnames find fin)"] = "<t??rmino b??squeda> (ej, /altnames find fin)",
	Alt = true,
	AltNames = "AltNombres",
	["Alts:"] = true,
	["Be quiet"] = "Silencio",
	["Class colour"] = "Color Clase",
	["Clear all"] = "Limpiar todo",
	["Clear all links between alts and main names."] = "Borrar todos los enlaces entre nombres alternativos y principales.",
	Colour = "Color",
	-- ["Delete a character's link to another character as their main."] = "",
	["Delete alt"] = "Eliminar alternativo",
	Disabled = "Desactivado",
	-- ["Display a player's alts in the tooltip"] = "",
	-- ["Display a player's main name in the tooltip"] = "",
	-- ["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "Mostrar nombres principales en el mismo color que el de su clase principal (tomando los datos del m??dulo PlayerNames si est?? habilitado)",
	["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "No sobreescribir enlaces alternativo <-> principal existentes al importar o a??adir nuevos alternativos.",
	["Don't overwrite existing links"] = "No sobreescribir enlaces existentes",
	["Don't use data from the PlayerNames module at all"] = "No utilizar datos del m??dulo PlayerNames en absoluto",
	["ERROR: some function sent a blank message!"] = "ERROR: alguna funci??n envi?? un mensaje en blanco!",
	["Find characters"] = "Encontrar caracteres",
	["Fix alts"] = "Arreglar alternativos",
	["Fix corrupted entries in your list of alt names."] = "Arreglar entradas corruptas en su lista de nombres alternativos.",
	["Found alt: %s => main: %s"] = "Alternativo encontrado: %s => principal: %s",
	-- ["Import from Guild Greet database"] = "",
	["Import from guild roster"] = "Importar desde la lista de la hermandad",
	["Import options"] = "Opciones de Importaci??n",
	-- ["Imports alt names from a Guild Greet database, if present"] = "",
	-- ["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "",
	["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "Importa datos de LOKWhoIsWho, si est?? presente (colocar su SavedVariablesLOKWhoIsWho.lua en el directorio Prat para poder usar este).",
	["LOKWhoIsWho data not found"] = "LOKWhoIsWho datos no encontrados",
	["LOKWhoIsWho import"] = "importar LOKWhoIsWho",
	["LOKWhoIsWho lua file not found, sorry."] = "LOKWhoIsWho archivo lua no encontrado, lo siento.",
	Left = "Izquierda",
	-- ["Link alt"] = "",
	-- ["Link someone's alt character with the name of their main."] = "",
	["List all"] = "Listar todo",
	["List all links between alts and their main names."] = "Lista todos los enlaces entre alternativos y sus nombres principales.",
	["List alts"] = "Lista alternativos",
	["List alts for a given character"] = "Lista alternativos para un personaje dado",
	Main = "Principal",
	["Main name position"] = "Posici??n del nombre principal",
	["Main:"] = "Principal:",
	-- ["No Guild Greet database found"] = "",
	["No arg string given to :addAlt()"] = "Sin cadena de argumento dado a: addAlt()",
	["No main name supplied to link %s to"] = "Sin nombre principal proporcionado para el enlace %s",
	Right = "Derecha",
	-- ["Search the list of linked characters for matching main or alt names."] = "",
	["Show alts in tooltip"] = "Muestra alternativos en ayuda contextual",
	["Show main in tooltip"] = "Mostrar principal en ayuda contextual",
	Start = "Inicio",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	["Use LibAlts Data"] = "Utiilizar Datos de LibAlts",
	["Use class colour (from the PlayerNames module)"] = "Utilizar el color de clase (desde el m??dulo de NombresJugador)",
	["Use the data available via the shared alt information library."] = "Utilice los datos disponibles a trav??s de la biblioteca compartida de informaci??n alternativa.",
	-- ["Various ways to import a main's alts from other addons"] = "",
	-- ["Where to display a character's main name when on their alt."] = "",
	["Whether to report to the chat frame or not."] = "Si se debe reportar al marco de chat o no.",
	["You are not in a guild"] = "No est?? en una hermandad",
	["You have not yet linked any alts with their mains."] = "A??n no ha vinculado alg??n alternativo con su principal.",
	alt = true,
	["alt name exists: %s -> %s; not overwriting as set in preferences"] = "existe el nombre alternativo: %s -> %s; sin sobrescribir como est?? establecido en las preferencias",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	["character removed: %s"] = "Personaje eliminado: %s",
	["don't use"] = "No utilizar",
	["guild member alts found and imported: %s"] = "Miembros de hermandad alternativos encontrados e importados: %s",
	["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "enlace <nombre alt> <nombre principal> (ej, /nombrealt enlace Fin Finjathealtoffin)",
	["linked alt %s => %s"] = "alternativo enlazado %s => %s",
	main = "principal",
	mainpos_desc = "Donde mostrar nombre principal de un personaje cuando es su alternativa.",
	mainpos_name = "Posici??n del nombre principal",
	-- module_desc = "",
	["no alts found for character "] = "sin alternativos encontrados para el personaje",
	["no alts or mains found matching \"%s\""] = "sin alternativos o principales coincidentes con \"%s\" encontrados",
	["no characters called \"%s\" found; nothing deleted"] = "no se han encontrado personajes llamados \"%s\"; nada eliminado",
	["no matches found"] = "Ninguna coincidencia encontrada",
	quiet = "Silencioso",
	quiet_desc = "Si desea informar al marco de chat o no.",
	-- quiet_name = "",
	["searched for: %s - total matches: %s"] = "buscado: %s - total de coincidencias: %s",
	["use class colour of alt"] = "utilizar color de clase de alt",
	["use class colour of main"] = "utilizar el color de la clase principal",
	["warning: alt %s already linked to %s"] = "advertencia: alt %s ya vinculado a %s",
}

)
L:AddLocale("zhTW",  
{
	-- ["%d alts found for %s: %s"] = "",
	-- ["%s alts imported from LOKWhoIsWho"] = "",
	-- ["%s total alts linked to mains"] = "",
	-- ["(.-)'s? [Aa]lt"] = "",
	-- ["([^%s%p%d%c%z]+)'s alt"] = "",
	-- [".*[Aa]lts?$"] = "",
	-- ["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"] = "",
	-- ["<main> (eg /altnames listalts Fin)"] = "",
	-- ["<search term> (eg, /altnames find fin)"] = "",
	-- Alt = "",
	-- AltNames = "",
	-- ["Alts:"] = "",
	["Be quiet"] = "??????",
	["Class colour"] = "????????????",
	["Clear all"] = "????????????",
	-- ["Clear all links between alts and main names."] = "",
	-- Colour = "",
	-- ["Delete a character's link to another character as their main."] = "",
	["Delete alt"] = "????????????",
	Disabled = "??????",
	-- ["Display a player's alts in the tooltip"] = "",
	-- ["Display a player's main name in the tooltip"] = "",
	-- ["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"] = "",
	-- ["Don't overwrite existing alt <-> main links when importing or adding new alts."] = "",
	-- ["Don't overwrite existing links"] = "",
	-- ["Don't use data from the PlayerNames module at all"] = "",
	["ERROR: some function sent a blank message!"] = "??????????????????????????????????????????",
	["Find characters"] = "????????????",
	["Fix alts"] = "????????????",
	["Fix corrupted entries in your list of alt names."] = "????????????????????????????????????",
	["Found alt: %s => main: %s"] = "???????????????%s => ???????????????%s",
	-- ["Import from Guild Greet database"] = "",
	["Import from guild roster"] = "??????????????????",
	["Import options"] = "??????????????????",
	-- ["Imports alt names from a Guild Greet database, if present"] = "",
	-- ["Imports alt names from the guild roster by checking for members with the rank \"alt\" or \"alts\", or guild / officer notes like \"<name>'s alt\""] = "",
	-- ["Imports data from LOKWhoIsWho, if present (drop your SavedVariablesLOKWhoIsWho.lua in the Prat directory to be able to use this)."] = "",
	-- ["LOKWhoIsWho data not found"] = "",
	-- ["LOKWhoIsWho import"] = "",
	-- ["LOKWhoIsWho lua file not found, sorry."] = "",
	Left = "??????",
	-- ["Link alt"] = "",
	-- ["Link someone's alt character with the name of their main."] = "",
	["List all"] = "????????????",
	-- ["List all links between alts and their main names."] = "",
	["List alts"] = "????????????",
	-- ["List alts for a given character"] = "",
	Main = "??????",
	["Main name position"] = "??????????????????",
	["Main:"] = "?????????",
	-- ["No Guild Greet database found"] = "",
	-- ["No arg string given to :addAlt()"] = "",
	-- ["No main name supplied to link %s to"] = "",
	-- Right = "",
	-- ["Search the list of linked characters for matching main or alt names."] = "",
	-- ["Show alts in tooltip"] = "",
	-- ["Show main in tooltip"] = "",
	-- Start = "",
	-- ["The colour of an alt's main name that will be displayed"] = "",
	["Use LibAlts Data"] = "?????? LibAlts ??????",
	["Use class colour (from the PlayerNames module)"] = "????????????????????????????????????????????????",
	-- ["Use the data available via the shared alt information library."] = "",
	["Various ways to import a main's alts from other addons"] = "??????????????????????????????????????????????????????",
	["Where to display a character's main name when on their alt."] = "?????????????????????????????????????????????????????????",
	["Whether to report to the chat frame or not."] = "?????????????????????????????????",
	["You are not in a guild"] = "??????????????????????????????",
	-- ["You have not yet linked any alts with their mains."] = "",
	-- alt = "",
	-- ["alt name exists: %s -> %s; not overwriting as set in preferences"] = "",
	-- autoguildalts_desc = "",
	-- autoguildalts_name = "",
	["character removed: %s"] = "??????????????????%s",
	-- ["don't use"] = "",
	["guild member alts found and imported: %s"] = "???????????????????????????????????????%s",
	-- ["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"] = "",
	-- ["linked alt %s => %s"] = "",
	main = "??????",
	-- mainpos_desc = "",
	mainpos_name = "??????????????????",
	-- module_desc = "",
	["no alts found for character "] = "????????????????????????",
	-- ["no alts or mains found matching \"%s\""] = "",
	-- ["no characters called \"%s\" found; nothing deleted"] = "",
	-- ["no matches found"] = "",
	quiet = "??????",
	quiet_desc = "??????????????????????????????",
	-- quiet_name = "",
	-- ["searched for: %s - total matches: %s"] = "",
	["use class colour of alt"] = "???????????????????????????????????????",
	["use class colour of main"] = "???????????????????????????????????????",
	["warning: alt %s already linked to %s"] = "????????????????????? %s ??????????????? %s",
}

)
--@end-non-debug@

local module = Prat:NewModule(PRAT_MODULE, "AceHook-3.0", "AceEvent-3.0")

local altregistry = LibStub("LibAlts-1.0")

module.Alts = {}

Prat:SetModuleDefaults(module.name, {
	profile = {
		on	= false,
		quiet	= false,
		pncol	= 'no',
		altidx	= {},
		mainpos	= 'RIGHT',
		colour	= {},
	
		maincolour	= '97ff4c',	-- fairly light bright green
		altcolour	= 'ff6df2',	-- fairly bright light purpley pinkish
		noclobber	= false,
	
		tooltip_showmain	= false,
		tooltip_showalts	= false,

		usealtlib = true,
		autoguildalts = false,
	},
	realm = {
		alts	= {},
	}
} )


Prat:SetModuleInit(module, 
	function(self) 
		if self.db.profile.alts then
		   local alts = self.db.profile.alts
		   self.db.profile.alts = nil
		   for k,v in pairs(alts) do 
		     self.db.realm.alts[k] = self.db.realm.alts[k] or v
		   end
		end
		
		-- Load shared Alts data
		for alt,main in pairs(self.db.realm.alts) do
			altregistry:SetAlt(main,alt)
		end

		-- define a popup to get the main name
		StaticPopupDialogs['MENUITEM_LINKALT'] = {
			-- text		= "Who would you like to set as the main character of %s?",
			text	= 'Mainname',
			button1		= TEXT(ACCEPT),
			button2		= TEXT(CANCEL),
			hasEditBox	= 1,
			maxLetters	= 24,
			exclusive	= 0,
	
			OnAccept = function(this, altname)
				local mainname	= this.editBox:GetText()
	
				altname	= altname or 'xxx'
	
				module:addAlt(string.format('%s %s', altname, mainname))
			end,
	
			OnShow = function(this)
				this.editBox:SetFocus();
			end,
	
			OnHide = function(this)
				if ( this.editBox:IsShown() ) then
					this.editBox:SetFocus();
				end
				_G[this:GetName().."EditBox"]:SetText("");
			end,
	
			EditBoxOnEnterPressed = function(this, altname)
        		local parent = this:GetParent()
        		local editBox = parent.editBox
				local mainname	= editBox:GetText()
	
				altname	= altname or 'xxx'
	
				module:addAlt(string.format('%s %s', altname, mainname))
	
				parent:Hide()
			end,
	
			EditBoxOnEscapePressed = function(this)
				this:GetParent():Hide();
			end,
			timeout		= 0,
			whileDead	= 1,
			hideOnEscape	= 1
			}
	return end)


Prat:SetModuleOptions(module, {
		name	= L["AltNames"],
		desc	= L["module_desc"],
		type	= "group",
		args = {
			find = {
				name	= L["Find characters"],
				desc	= L["Search the list of linked characters for matching main or alt names."],
				type	= "input",
				usage	= L["<search term> (eg, /altnames find fin)"],
				order	= 110,
				set	= function(info, q) info.handler:findChars(q) end,
				get	= false,
				},

			listalts = {
				name	= L['List alts'],
				desc	= L['List alts for a given character'],
				type	= 'input',
				usage	= L['<main> (eg /altnames listalts Fin)'],
				order	= 115,
				set	= function(info, m) info.handler:listAlts(m) end,
				get	= false,
				},

			link = {
				name	= L["Link alt"],
				desc	= L["Link someone's alt character with the name of their main."],
				type	= "input",
				order	= 120,
				usage	= L["link <alt name> <main name> (eg, /altnames link Fin Finjathealtoffin)"],
				-- pass	= true,
				-- set	= function(argname, argstr) self:addAlt(argstr) end,
				set	= function(info, argstr) info.handler:addAlt(argstr) end,
				get	= false,
--				alias	= { 'new', 'add' },
				},

			del = {
				name	= L["Delete alt"],
				desc	= L["Delete a character's link to another character as their main."],
				type	= "input",
				usage	= L["<alt name> (eg, /altnames del Personyouthoughtwassomeonesaltbutreallyisnt)"],
				order	= 130,
				set	= function(info, altname) info.handler:delAlt(altname) end,
				get	= false,
				confirm	= true,
--				alias	= { 'remove', 'unlink' },
				},

			quiet = {
				name	= L["Be quiet"],
				desc	= L["Whether to report to the chat frame or not."],
				type	= "toggle",
				order	= 191, -- 19x = options

				},

			listall = {
				name	= L["List all"],
				desc	= L["List all links between alts and their main names."],
				type	= "execute",
				func	= "listAll",
--				alias	= { 'list', 'all' },
				},

			clearall = {
				name	= L["Clear all"],
				desc	= L["Clear all links between alts and main names."],
				type	= "execute",
				func	= "clearAllAlts",
				confirm	= true,
				},

			fixalts = {
				name	= L["Fix alts"],
				desc	= L["Fix corrupted entries in your list of alt names."],
				type	= "execute",
				func	= "fixAlts",
				},

			colour = {
				name	= L["Colour"],
				get	= function(info) return info.handler:getColour() end,
				set	= function(info, nr, ng, nb, na) info.handler.db.profile.colour = { r = nr, g = ng, b = nb, a = na } end,
				desc	= L["The colour of an alt's main name that will be displayed"],
				type	= "color",
				order   = 60,
				disabled = function(info) return info.handler.db.profile.pncol ~= 'no' end
				},

			pncol = {
					name	= L["Class colour"],
					desc	= L["Use class colour (from the PlayerNames module)"],
					type	= "select",
					get     =  function(info) return info.handler.db.profile.pncol end,
					set	= function(info, v) info.handler.db.profile.pncol = v end,
					order	= 55,
					values = {
						['main']	= L["use class colour of main"],
						['alt']		= L["use class colour of alt"],
						['no']		= L["don't use"],
					},
				},

			mainpos = {
				name	= L["Main name position"],
				desc	= L["Where to display a character's main name when on their alt."],
				type	= "select",
				order	= 50,
				get	= function(info) return info.handler.db.profile.mainpos end,
				set	= function(info, v) info.handler:setMainPos(v) end,
				values = {
					["LEFT"]	= L["Left"],
					["RIGHT"]	= L["Right"],
	 				["START"]	= L["Start"],
					},
				},

			tooltip_showmain = {
				name	= L['Show main in tooltip'],
				desc	= L["Display a player's main name in the tooltip"],
				type	= 'toggle',
				order	= 150,
				get	= function(info) return info.handler.db.profile.tooltip_showmain end,
				set	= function(info)
						info.handler.db.profile.tooltip_showmain = not info.handler.db.profile.tooltip_showmain
						info.handler.altertooltip = info.handler.db.profile.tooltip_showalts or info.handler.db.profile.tooltip_showmain

						info.handler:HookTooltip()
					end,

				},

			tooltip_showalts = {
				name	= L['Show alts in tooltip'],
				desc	= L["Display a player's alts in the tooltip"],
				type	= 'toggle',
				order	= 150,
				get	= function(info) return info.handler.db.profile.tooltip_showalts end,
				set	= function(info)
						info.handler.db.profile.tooltip_showalts = not info.handler.db.profile.tooltip_showalts
						info.handler.altertooltip = info.handler.db.profile.tooltip_showalts or info.handler.db.profile.tooltip_showmain
						
						info.handler:HookTooltip()
					end,
				},


			noclobber = {
				name	= L["Don't overwrite existing links"],
				desc	= L["Don't overwrite existing alt <-> main links when importing or adding new alts."],
				type	= "toggle",
				order	= 192,	-- 19x = options

				},

--			blankheader = {
--				order	= 499,
--				type	= 'header',
--				},

			--[[ IMPORT OPTIONS ]]--
			importheader = {
				name	= L["Import options"],
				desc	= L["Various ways to import a main's alts from other addons"],
				type	= 'header',
				order	= 500,
				},

			-- imports: LOKWhoIsWho - SavedVariables
			importfromlok = {
				name	= L["LOKWhoIsWho import"],
				desc	= L["Imports data from LOKWhoIsWho, if present (drop your SavedVariables\LOKWhoIsWho.lua in the Prat directory to be able to use this)."],
				type	= "execute",
				func	= "importFromLOK",
				confirm	= true,
				order	= 560,
				},

			-- imports: guild roster - officer notes, public notes, ranks
			guildimport = {
				name	= L["Import from guild roster"],
				desc	= L['Imports alt names from the guild roster by checking for members with the rank "alt" or "alts", or guild / officer notes like "<name>\'s alt"'],
				type	= "execute",
				func	= "importGuildAlts",
				confirm	= true,
				order	= 520,
				},

			-- imports: guild greet - SavedVariables
			ggimport = {
				name	= L['Import from Guild Greet database'],
				desc	= L['Imports alt names from a Guild Greet database, if present'],
				type	= 'execute',
				func	= "importGGAlts",
				confirm	= true,
				order	= 550,
				},

			usealtlib = {
				name	= L["Use LibAlts Data"],
				desc	= L["Use the data available via the shared alt information library."],
				type	= "toggle",
				order	= 540,	
				},
				
			autoguildalts = {
				name	= L["autoguildalts_name"],
				desc	= L["autoguildalts_desc"],
				type	= "toggle",
				order	= 540,	
				},				

			}
		}
)

--	if Prat:IsModuleActive("PlayerNames") then
--		self.moduleOptions['args']['pncol'] = {
--			name	= L["Class colour"],
--			desc	= L["Use class colour (from the PlayerNames module)"],
--			type	= "text",
--			get     =  function() return self.db.profile.pncol end,
--			set	= function(v) self.db.profile.pncol = v end,
--			order	= 150,
--			validate = {
--				['main']	= L["use class colour of main"],
--				['alt']		= L["use class colour of alt"],
--				['no']		= L["don't use"],
--				},
--			validateDesc = {
--				['main']	= L["Display main names in the same colour as that of the main's class (taking the data from the PlayerNames module if it is enabled)"],
--				['alt']		= L["Display main names in the same colour as that of the alt's class (taking the data from the PlayerNames module if it is enabled)"],
--				['no']		= L["Don't use data from the PlayerNames module at all"],
--				},
--			}
--	end
--)


--[[------------------------------------------------
    Module Event Functions
------------------------------------------------]]--

function module:OnModuleEnable()
	-- much code ripped off from the PlayerMenu code - thanks, and sorry!

	-- things to do when the module is enabled
	for altname, mainname in pairs(self.db.realm.alts) do
		self.Alts[altname] = mainname
	end

	-- PlayerNames colour
	local pncol = self.db.profile.pncol

	if pncol == 'no' then
		pncol			= false
		self.db.profile.pncol	= false
	end

	self.db.profile.pncol = self.db.profile.pncol or false

	-- for caching a main's list of alts
	self.Altlists = {}

	-- just register one area which can be used for anything
	-- (and only actually has one use at the moment)
	self.ALTNAMES = ""

	-- set position that main names are displayed in chat messages
	self:setMainPos(self.db.profile.mainpos)

	-- register events
	Prat.RegisterChatEvent(self, "Prat_PreAddMessage")

	-- hook functions
	self.altertooltip = self.db.profile.tooltip_showmain or self.db.profile.tooltip_showalts

	self:HookTooltip()

	-- hack 'n' slash
	local slashcmds = {
		'/altnames',
		'/alts',
		'/alt',
		}

	--Prat:RegisterChatCommand(slashcmds, self.moduleOptions, string.upper("AltNames"))

	--self:SecureHook("UnitPopup_OnClick")
	--self:SecureHook("UnitPopup_ShowMenu")

    Prat:RegisterDropdownButton("LINK_ALT")

	-- add the bits to the context menus
	UnitPopupButtons['LINK_ALT'] = { text = "Set Main", dist = 0, func = function() module:UnitPopup_LinkAltOnClick() end , arg1 = "", arg2 = ""}

    if not self.menusAdded then
    	tinsert(UnitPopupMenus['PARTY'], #UnitPopupMenus['PARTY']-1, 'LINK_ALT')
    	tinsert(UnitPopupMenus['FRIEND'], #UnitPopupMenus['FRIEND']-1, 'LINK_ALT')
    	tinsert(UnitPopupMenus['SELF'], #UnitPopupMenus['SELF']-1, 'LINK_ALT')
    	tinsert(UnitPopupMenus['PLAYER'], #UnitPopupMenus['PLAYER']-1, 'LINK_ALT')
    	-- tinsert(UnitPopupMenus['TARGET'], getn(UnitPopupMenus['TARGET'])-1, 'LINK_ALT')
        
        self.menusAdded = true
    end
    	
	if self.db.profile.autoguildalts then
    	self:AutoImportGuildAlts(true)
    end
end

function module:AutoImportGuildAlts(b)
	if b then
	    self:RegisterEvent("GUILD_ROSTER_UPDATE", function() module:importGuildAlts(nil, true) end)
	    GuildRoster() 
	else
	    self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

function module:OnValueChanged(info, b)
	local field = info[#info]
	if field == "autoguildalts" then
		AutoImportGuildAlts(b)
	end
end

local function NOP() return end

function module:HookTooltip()
	if self.altertooltip then
		self:SecureHookScript(GameTooltip, 'OnTooltipSetUnit')
		self:SecureHookScript(GameTooltip, 'OnTooltipCleared')
	
		module.HookTooltip = NOP
	end
end

--function module:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
--	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
--		button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
--
--		-- Patch our handler function back in
--		if  button.value == "LINK_ALT" then
--		    button.func = UnitPopupButtons["LINK_ALT"].func
--		end
--	end
--end

function module:UnitPopup_LinkAltOnClick()
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU

	--if (button == 'LINK_ALT') then
		local altname	= dropdownFrame.name
		local dialog	= StaticPopup_Show('MENUITEM_LINKALT', altname)

		if dialog then
			local altname	= dropdownFrame.name
			dialog.data	= altname
		end
	--end
end



-- things to do when the module is disabled
function module:OnModuleDisable()
	-- unregister events
	Prat.UnregisterAllChatEvents(self)
end


--[[------------------------------------------------
    Core Functions
------------------------------------------------]]--


function module:print(msg, printanyway)
	-- make sure we've got a message
	if msg == nil then
		printanyway = true
		msg = L['ERROR: some function sent a blank message!']
	end

	local verbose = (not self.db.profile.quiet) 

	if (not self.silent) and (verbose or printanyway) then
		msg = string.format('|cffffd100' .. L['AltNames'] .. ':|r %s', msg)
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end

--[[ colo*u*ring and formatting ]]--

local clrname = function(name, colour)
	return '|cff' .. (colour or 'ffffff') .. (name or "") .. '|r'
end

local clrmain = function(mainname, maincolour)
	mainname	= mainname or ""
	maincolour	= maincolour or module.db.profile.maincolour or '8080ff'

	-- 1, 0.9, 0, 0.5, 0.5, 1

	return clrname(mainname, maincolour)
end

local clralt = function(altname, altcolour)
	altname		= altname or ""
	altcolour	= altcolour or module.db.profile.altcolour or 'ff8080'

	-- 1, 0.7, 0, 1, 0.5, 0.5

	return clrname(altname, altcolour)
end

local clralts = function(alts, altcolour)
	if not alts or (type(alts) ~= 'table') or (#alts == 0) then return false end

	for mainname, altname in pairs(alts) do
		alts[mainname] = clralt(module:formatCharName(altname))
	end

	return alts
end

function module:formatCharName(name)
	-- format character names as having uppercase first letter followed by all lowercase

	if name == nil then
		return ""
	end

	name	= name:gsub('[%%%[%]":|%s]', '')
	name	= name:gsub("'", '')

	name	= string.lower(name)
	name	= string.gsub(name, Prat.MULTIBYTE_FIRST_CHAR, string.upper, 1)

	return name
end

--[[ alt <-> main link management ]]--

function module:addAlt(argstr)
	local mainname

	local altname	= ""
	local args	= {}

	-- check we've been passed somethin
	if (argstr == nil) or (argstr == "") then
		self:print(L['No arg string given to :addAlt()'])
		return false
	end

	-- extract the alt's name and the main name to link to
	for k, v in argstr:gmatch('(%S+)%s+(%S+)') do
		altname, mainname = k, v
	end

	-- check we've got a main name to link to
	if altname and not mainname then
		altname = argstr
		self:print(string.format(L["No main name supplied to link %s to"], clralt(altname)), true)
		return false
	end

	-- clean up character names
	mainname	= self:formatCharName(mainname)
	altname		= self:formatCharName(altname)

	-- check if alt has already been linked to a main
	local oldmain	= ""
	local noclobber	= self.db.profile.noclobber

	if self.Alts[altname] then
		oldmain = self.Alts[altname]

		if oldmain == mainname then
			self:print(string.format(L['warning: alt %s already linked to %s'], clralt(altname), clrmain(mainname)))
			return false
		end

		if noclobber then
			self:print(string.format(L['alt name exists: %s -> %s; not overwriting as set in preferences'], clralt(altname), clrmain(oldmain)))
			return false
		end

		self:print(string.format(L['warning: alt %s already linked to %s'], clralt(altname), clrmain(oldmain)))
	end

	-- add alt to list of alts -> mains
	self.Alts[altname]		= mainname
	self.db.realm.alts[altname]	= mainname

	-- make sure this character's list of alts is rebuilt next time it's needed
	if self.Altlists[mainname] then self.Altlists[mainname] = nil end

    -- publish this info globablly
	altregistry:SetAlt(mainname, altname)

	self:print(string.format(L["linked alt %s => %s"], clralt(altname), clrmain(mainname)))
end

function module:delAlt(altname)
	local suppliedaltname = altname

	altname = self:formatCharName(altname)

	if self.Alts[altname] then
		self.Alts[altname]		= nil
		self.db.realm.alts[altname]	= nil

		self:print(string.format(L["character removed: %s"], clralt(suppliedaltname)))

		-- make sure this character's list of alts is rebuilt next time it's needed
		if self.Altlists[mainname] then self.Altlists[mainname] = nil end

		return true
	end

	self:print(string.format(L['no characters called "%s" found; nothing deleted'], clralt(suppliedaltname)))
end

function module:listAll()
	if not self.db.realm.alts and self.Alts then
		self:print(L["You have not yet linked any alts with their mains."], true)
		return false
	end

	local altcount = 0

	for altname, mainname in pairs(self.Alts) do
		altcount = altcount + 1
		self:print(string.format("alt: %s => main: %s", clralt(altname), clrmain(mainname)))
	end

	self:print(string.format(L['%s total alts linked to mains'], altcount))
end

function module:findChars(q)
	local numfound

	local matchhighlight

	if not self.Alts then
		self:print(L["You have not yet linked any alts with their mains."], true)
		return false
	else
		local matches = {}
		local numfound = 0

		for altname, mainname in pairs(self.Alts) do
			local a = string.lower(altname)
			local m = string.lower(mainname)
			local pat = string.lower(q)

			-- self:print(string.format("matching against: altname:'%s', mainname:'%s', pat:'%s'", a, m, pat))

			if (a == pat) or (m == pat) or (a:find(pat)) or (m:find(pat)) then
				matches[altname] = mainname
				numfound = numfound + 1
			end
		end

		if numfound == 0 then
			self:print(string.format(L['no alts or mains found matching "%s"'], '|cffffb200' .. q .. '|r'), true)
		else
			for altname, mainname in pairs(matches) do
				self:print(string.format(L["Found alt: %s => main: %s"], clralt(altname), clrmain(mainname)))
			end

			self:print(string.format(L["searched for: %s - total matches: %s"], q, numfound))
		end

		return numfound
	end
end


function module:fixAlts()
	local fixedalts = {}

	for altname, mainname in pairs(self.db.realm.alts) do
		altname		= self:formatCharName(altname)
		mainname	= self:formatCharName(mainname)

		fixedalts[altname] = mainname
	end

	self.Alts = fixedalts
	self.db.realm.alts = fixedalts
end


function module:clearAllAlts()
	self.Alts		= {}
	self.db.realm.alts	= {}
	self.Altlists		= {}
end


local CLR = Prat.CLR

function module:setMainPos(pos)
	-- which item to go after, depending on our position
	local msgitems = {
		RIGHT	= 'Pp',
		LEFT	= 'Ff',
		START	= nil,
		}

	pos	= pos or 'RIGHT'

	Prat.RegisterMessageItem('ALTNAMES', msgitems[pos])

	if pos == 'RIGHT' then
		self.padfmt	= ' '..CLR:Colorize("ffffff", "(").."%s"..CLR:Colorize("ffffff", ")")
	else
		self.padfmt	= CLR:Colorize("ffffff", "(").."%s"..CLR:Colorize("ffffff", ")")..' '
	end

	self.db.profile.mainpos	= pos
end

local function isAlt(name)
    local alt = module.Alts[name]
    if alt then return alt end
    
    if altregistry and altregistry:IsAlt(name) then
        return altregistry:GetMain(name)
    end  
    
    return
end

local playernames
function module:Prat_PreAddMessage(e, message, frame, event)
	local hexcolour = CLR.NONE

	local mainname = message.PLAYERLINK

	if self.db.profile.on and isAlt(mainname) then
        local pres = message.PRESENCE_ID or 0

		local altname	= isAlt(mainname)
		local padfmt	= self.padfmt or ' (%s)'


		if self.db.profile.colour then
			if self.db.profile.pncol ~= 'no' then
				local charname
				local coltype = self.db.profile.pncol

				if coltype == "alt" then
					charname = mainname
				elseif coltype == "main" then
					charname = altname
				else
					charname = nil
					self.db.profile.pncol = 'no'
				end

				playernames = playernames or Prat.Addon:GetModule("PlayerNames")
				if charname then
					local class, level, subgroup = playernames:GetData(charname)
					if class then
						hexcolour = playernames:GetClassColor(class)
					end
				end
			else
				hexcolour = CLR:GetHexColor(self.db.profile.colour)
			end

			hexcolour = hexcolour or CLR:GetHexColor(self.db.profile.colour)
		end

		self.ALTNAMES	= string.format(padfmt, CLR:Colorize(hexcolour, altname:gsub(Prat.MULTIBYTE_FIRST_CHAR, string.upper, 1)))

		message.ALTNAMES = self.ALTNAMES
	end
end

function module:getColour(r, g, b, a)
	local col = self.db.profile.colour
	if not col then return false end
	return col.r, col.g, col.b, nil
end

function module:importFromLOK()
	if not LOKWhoIsWho_Config then
		self:print(L['LOKWhoIsWho lua file not found, sorry.'])
		return false
	end

	local server	= GetRealmName()
	local lokalts	= LOKWhoIsWho_Config[server]['players']

	if lokalts == nil then
		self:print(L["LOKWhoIsWho data not found"])
		return false
	end

	local numimported = 0

	for altname, mainname in pairs(lokalts) do
		self:addAlt(string.format("%s %s", altname, mainname))
		numimported = numimported + 1
	end

	self:print(string.format(L["%s alts imported from LOKWhoIsWho"], numimported))
end

function module:importGGAlts()
	--[[
		imports guilds from a Guild Greet database, if present
	]]
	if not GLDG_Data then
		self:print(L['No Guild Greet database found'])
		return
	end

	local servername = GetRealmName()
	local k, v

	for k, v in pairs(GLDG_Data) do
		if string.match(k, servername .. ' - %S+') then
			local name, player

			for name, player in pairs(v) do
				-- not sure whether this would be useful:
				-- if player['alt'] and player['alt'] ~= "" and not player['own'] then
				if player['alt'] and player['alt'] ~= "" then
					mainname	= player['alt']
					altname		= name

					self:addAlt(string.format('%s %s', altname, mainname))
				end
			end
		end
	end
end

function module:importGuildAlts(altrank, silently)
	if altrank == "" then altrank = nil end

	local totalmembers
	self.silent = silently

	totalmembers = GetNumGuildMembers(true)

	if totalmembers == 0 then
		self:print(L['You are not in a guild'])
		return
	end


	-- build a list of guild members to check guild notes against later
	local guildMembers = {}

	for x = 1, totalmembers do
		local name, rank, rankIndex, level, class, zone, publicnote, officernote, online, status = GetGuildRosterInfo(x)
		guildMembers[string.lower(name)] = name
	end


	-- loop through members and check stuff for later
	local mainname
	local altname
	local numfound = 0

	for x = 1, totalmembers do
		altname		= nil
		mainname	= nil

		local name, rank, rankIndex, level, class, zone, publicnote, officernote, online, status = GetGuildRosterInfo(x)

		-- yeah I know the vars should be pre-lc'ed and it's not as efficient as it could be below
		-- ... feel free to clean it up

		-- untested (is there a more convenient trim function available?):
		--[[
		officernote = gsub("^%s*", "", officernote)
		publicnote = gsub("^%s*", "", publicnote)
		]]

        officernote = (officernote):match(L["(.-)'s? [Aa]lt"]) or officernote
        publicnote = (publicnote):match(L["(.-)'s? [Aa]lt"]) or publicnote

		local cleanpubnote = publicnote:match(Prat.AnyNamePattern) 
		local cleanoffnote = officernote:match(Prat.AnyNamePattern) 

		-- check for guild members with rank "alt" or "alts" or "officer alt"
		if (rank:match(L[".*[Aa]lts?$"]) or (altrank and rank == altrank) ) and (cleanpubnote and guildMembers[cleanpubnote:lower()] ) then
			-- self:print(string.format('found mainname name for member %s', name))
			mainname = cleanpubnote
		-- check whether guild note is an exact match of a member's name
		elseif cleanpubnote and guildMembers[cleanpubnote:lower()] then
			mainname = cleanpubnote
		elseif cleanoffnote and guildMembers[cleanoffnote:lower()] then
			mainname = cleanoffnote
		elseif officernote:find(L["([^%s%p%d%c%z]+)'s alt"]) or publicnote:find(L["([^%s%p%d%c%z]+)'s alt"]) then
			local TempName = officernote:match(L["([^%s%p%d%c%z]+)'s alt"]) or publicnote:match(L["([^%s%p%d%c%z]+)'s alt"])
			if TempName and guildMembers[string.lower(TempName)] then
				mainname = TempName
			end
		end

		-- set alt name if we've found their main name
		if mainname and mainname ~= "" then

			if mainname:lower() ~= name:lower() then 
				numfound	= numfound + 1
				altname		= name
				self:addAlt(string.format('%s %s', altname, mainname))
			end
		end
	end

	self:print(string.format(L["guild member alts found and imported: %s"], numfound))
	self.silent = nil
end


-- function for showing a list of alt names in the tooltip
function module:getAlts(mainname)
	if self.db.profile.usealtlib then
		local alts = { altregistry:GetAlts(mainname) }
		if #alts > 0 then
			return alts
		end		

		return false
	end

	-- self.Alts = self.db.profile.altnames

	-- check valid mainname is being passed and that we actually have a list of alts
	if not (mainname and self.Alts) then return false end

	-- format the character name
	mainname = self:formatCharName(mainname)

	-- check mainname wasn't just made of invalid characters
	if mainname == "" then return false end

	-- check we've not already built the list of alts for this character
	if self.Altlists[mainname] then return self.Altlists[mainname] end

	local alts	= {}
	local allalts	= self.Alts

	-- loop through list of alts and build alts table for given mainname
	for alt, tmpmainname in pairs(allalts) do
		if mainname == tmpmainname then
			table.insert(alts, alt)
		end
	end

	-- check there we've actually found some alts
	if #alts == 0 then return false end

	-- cache this list of alts
	self.Altlists[mainname] = alts

	return alts
end


-- function for showing main names in the tooltip
function module:getMain(altname)
	if self.db.profile.usealtlib then
		local main = altregistry:GetMain(altname)
		if main then
			return self:formatCharName(main)
		end		

		return false
	end

	-- self.Alts = self.db.profile.altnames

	-- check for valid alt name being passed and that we actually have a list of alts
	if not altname and self.Alts then return false end

	-- format the character name
	altname = self:formatCharName(altname)

	-- check the alt name wasn't just made of invalid character
	if altname == "" then return false end

	-- check a main exists for the given alt name
	if not self.Alts[altname] then return false end

	return self.Alts[altname]
end



function module:nicejoin(t, glue, gluebeforelast)
	-- check we've got a table
	if type(t) ~= 'table' then return false end

	local list	= {}
	local index	= 1

	-- create a copy of the table with a numerical and no nested tables
	for i, v in pairs(t) do
		local vtype	= type(v)
		local item	= self:formatCharName(v)

		if vtype ~= 'string' then
			item = vtype
		end

		list[index]	= item or vtype
		index		= index + 1
	end

	-- make sure we have some items to join
	if #list == 0 then
		return ""
	end

	-- trying to join one item = that item
	if #list == 1 then
		return list[1]
	end

	-- defaults with which we will want wo woin no that's not going to work
	-- defaults
	glue		= glue or ', '
	gluebeforelast	= gluebeforelast or ', and '

	-- pop the last value off
	local last	= table.remove(list) or "" -- shouldn't need the ' or ""'?

	-- standard way of joining a list of items together
	local str	= table.concat(list, glue)

	-- return the previous list, but add the last value nicely
	return str .. gluebeforelast .. last
end


-- displays all alts for a given character as a list rather than seperate matches
function module:listAlts(mainname)
	if not mainname then return false end

	mainname = self:formatCharName(mainname)

	if mainname == "" then return false end

	local alts

	alts = self:getAlts(mainname)

	if not alts or (#alts == 0) then
		self:print(L['no alts found for character '] .. mainname)
		return
	else
		self:print(string.format(L['%d alts found for %s: %s'], #alts, clrmain(mainname), clralt(self:nicejoin(alts))))
		return #alts
	end
end


-- hooked function to show mains and alts if set in preferences
function module:OnTooltipSetUnit()
	--[[
	check:

	 . the user wants information about alts or mains on the tooltip
	 . there's a tooltip to alter
	 .  we haven't already added anything to the tooltip

	]]
	if self.altertooltip and GameTooltip and not self.showingtooltip then
		-- create lines table for extra information that might be added
		local lines	= {}

		-- check who / what the tooltip's being displayed for
		local charname, unitid	= GameTooltip:GetUnit()

		-- check to see if it's a character
		if UnitIsPlayer(unitid) then
			local mainname, alts, tooltipaltered

			-- check if the user wants the mainame name shown on alts' tooltips
			if self.db.profile.tooltip_showmain then
				local mainname = self:getMain(charname)

				if mainname then
					-- add the character's main name to the tooltip
					GameTooltip:AddDoubleLine(L['Main:'] .. ' ', clrmain(mainname), 1, 0.9, 0, 0.5, 0.5, 1)
					tooltipaltered = true
				end
			end

			local width = GameTooltip:GetWidth()
			-- check if the user wants a list of alts shown on mains' tooltips
			if self.db.profile.tooltip_showalts then
				local alts	= self:getAlts(charname) or self:getAlts(mainame)

				if alts then
					-- build the string listing alts
--					local altstr = self:nicejoin(alts)

					-- add the list of alts to the tooltip
					GameTooltip:AddLine("|cffffc080"..L['Alts:'] .. "|r " .. clralt(self:nicejoin(alts)), 1, 0.5, 0.5, 1)
					tooltipaltered = true
				end
			end

			if tooltipaltered then
				GameTooltip:SetWidth(width)
				GameTooltip:Show()
			end

			-- make sure we don't add another tooltip
			self.showingtooltip = true
		end
	end
end

-- got to reset the flag so we know when to readd the lines
function module:OnTooltipCleared()
	self.showingtooltip	= false
end


  return
end ) -- Prat:AddModuleToLoad