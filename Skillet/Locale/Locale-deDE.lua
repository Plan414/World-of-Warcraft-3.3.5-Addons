--[[

Skillet: A tradeskill window replacement.
Copyright (c) 2007 Robert Clark <nogudnik@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

]]--

-- German localizations provided by Farook (from wowinterface.com) and Stan (from wowace)

-- If you are doing localization and would like your name added here, please feel free
-- to do so, or let me know and I will be happy to add you to the credits

local L = AceLibrary("AceLocale-2.2"):new("Skillet")
L:RegisterTranslations("deDE", function() return {
    ["Skillet Trade Skills"]                = "Skillet Trade Skills",
    ["Create"]                              = "Erstellen",
    ["Queue All"]                           = "Alle in Warteschlange",
    ["Create All"]                          = "Alle erstellen",
    ["Create"]                              = "Erstellen",
    ["Queue"]                               = "Warteschlange",
    ["Enchant"]                             = "Verzaubern",
    ["Rescan"]                              = "Erneut scannen",
    ["Number of items to queue/create"]     = "Anzahl der Gegenst\195\164nde in Warteschlange/zum Erstellen",
    ["buyable"]                             = "k\195\164uflich",
    ["reagents in inventory"]               = "Reagenzien im Inventar",
    ["bank"]                                = "Reagenzien in der Bank", -- "reagents in bank"
    ["alts"]                                = "Reagenzien auf Twinks", -- "reagents on alts"
    ["can be created from reagents in your inventory"]  = "kann mit den Reagenzien in deinem Inventar erstellt werden",
    ["can be created from reagents in your inventory and bank"] = "kann mit den Reagenzien in deinem Inventar und der Bank erstellt werden",
    ["can be created from reagents on all characters"] = "kann mit den Reagenzien auf allen Charakteren erstellt werden",
    ["Scanning tradeskill"]                 = "Scanne Berufe",
    ["Scan completed"]                      = "Scan abgeschlossen",
    ["Filter"]                              = "Filter",
    ["Hide uncraftable"]                    = "Nicht herstellbare verstecken",
    ["Hide trivial"]                        = "Graue Gegenst\195\164nde verstecken",
    ["Options"]                             = "Optionen",
    ["Notes"]                               = "Notizen",
    ["Purchased"]                           = "Eingekauft",
    ["Total spent"]                         = "Ausgegeben total",
    ["This merchant sells reagents you need!"]      = "Dieser H\195\164ndler verkauft Reagenzien die du brauchst!",
    ["Buy Reagents"]                        = "Reagenzien kaufen",
    ["click here to add a note"]            = "Hier klicken um eine Notiz hinzuzuf\195\188gen",
    ["not yet cached"]                      = "noch nicht gecached",

    -- Options
    ["About"]						= "??ber",
    ["ABOUTDESC"]					= "Gibt infos ??ber Skillet aus",
    ["Config"]						= "Konfiguraton",
    ["CONFIGDESC"]					= "??ffnet ein Konfigurationsfenster f??r Skillet",
    ["Shopping List"]					= "Einkaufsliste",
    ["SHOPPINGLISTDESC"]				= "Zeigt die Einkaufsliste",

    ["Features"]					= "Funktionen",
    ["FEATURESDESC"]					= "Optionale Funktionen die ein- oder ausgeschaltet werden k??nnen.",
    ["VENDORBUYBUTTONNAME"]				= "Zeige Reagenzien Kaufen Knopf bei H??ndlern",
    ["VENDORBUYBUTTONDESC"]				= "Zeige einen Button bei H??ndlern die, die ben??tigten Reagenzien f??r Rezepte in der Warteschlange haben.",
    ["VENDORAUTOBUYNAME"]				= "Reagenzien automatisch kaufen",
    ["VENDORAUTOBUYDESC"]				= "Wenn du Rezepte in der Warteschlange hast und mit einem H??ndler sprichst der etwas verkauft was f??r die Rezepte ben??tigt, wird es automatisch gekauft.",
    ["SHOWITEMNOTESTOOLTIPNAME"]			= "F??ge Benutzerdefinierte Notizen zum Tooltip hinzu",
    ["SHOWITEMNOTESTOOLTIPDESC"]			= "F??gt Benutzerdefinierte Notizen f??r ein Item zum dazugeh??rigen Tooltip",
    ["SHOWDETAILEDRECIPETOOLTIPNAME"]			= "Zeigt einen detaillierten Tooltip f??r Rezepte an",
    ["SHOWDETAILEDRECIPETOOLTIPDESC"]			= "Zeigt einen detaillierten Tooltip wenn man ??ber die Rezepte auf der linken Seite des Panels f??hrt",
    ["LINKCRAFTABLEREAGENTSNAME"]			= "Mache Reagenzien Klickbar",
    ["LINKCRAFTABLEREAGENTSDESC"]			= "Wenn du ein Reagenz f??r das aktuelle Rezept herstellen kannst wird ein Klick auf das Reagenz zum entsprechenden Rezept bringen.",
    ["QUEUECRAFTABLEREAGENTSNAME"]			= "F??ge herstellbare Reagenzien zur Warteschlange hinzu",
    ["QUEUECRAFTABLEREAGENTSDESC"]			= "Wenn du ein Reagenz f??r das aktuelle Rezept herstellen kannst und nicht genug Reagenzien hast, wird das Reagenz zur Warteschlange hinzugef??gt",
    ["DISPLAYSHOPPINGLISTATBANKNAME"]			= "Zeige Einkaufsliste in der Bank",
    ["DISPLAYSHOPPINGLISTATBANKDESC"]			= "Zeigt eine Einkaufsliste, die die Items zeigt die ben??tigt werden um die Rezepte in der Warteschlange herzustellen, aber nicht in deinen Taschen sind",
    ["DISPLAYSGOPPINGLISTATAUCTIONNAME"]		= "Zeige Einkaufsliste im Auktionshaus",
    ["DISPLAYSGOPPINGLISTATAUCTIONDESC"]		= "Zeigt eine Einkaufsliste, die die Items zeigt die ben??tigt werden um die Rezepte in der Warteschlange herzustellen, aber nicht in deinen Taschen sind",

    ["Appearance"]					= "Aussehen",
    ["APPEARANCEDESC"]					= "Einstelungen die das Aussehen von Skillet ??ndern",
    ["DISPLAYREQUIREDLEVELNAME"]			= "Zeige ben??tigten Level",
    ["DISPLAYREQUIREDLEVELDESC"]			= "Wenn das hergestellte Item ein Level-Minimum erfordert um es zu benutzen, wird das Level im Rezept angezeigt",
    ["Transparency"]					= "Transparenz",
    ["TRANSPARAENCYDESC"]				= "Transparenz des Haupt Berufsfensters",

    -- New in version 1.6
    ["Shopping List"]               = "Einkaufsliste",
    ["Retrieve"]                    = "Abfragen",
    ["Include alts"]                = "Twinks miteinbeziehen",

    -- New in vesrsion 1.9
    ["Start"]                       = "Start",
    ["Pause"]                       = "Pause",
    ["Clear"]                       = "Leeren",
    ["None"]                        = "Nichts",
    ["By Name"]                     = "Nach Name",
    ["By Difficulty"]               = "Nach Schwierigkeit",
    ["By Level"]                    = "Nach Level",
    ["Scale"]                       = "Skalierung",
    ["SCALEDESC"]                   = "Skalierung des Berufsfensters (Standard 1.0)",
    ["Could not find bag space for"] = "Kann keinen Taschenplatz finden f??r",
    ["SORTASC"]                     = "Sortiere die Rezptliste vom h??chsten (oben) zum nidrigsten (unten)",
    ["SORTDESC"]                    = "Sortiere die Rezptliste vom nidrigsten (oben) tum h??chsten (unten)",
    ["By Quality"]                  = "Nach Qualit??t",

    -- New in version 1.10
    ["Inventory"]                   = "Inventar",
    ["INVENTORYDESC"]               = "Inventar-Information",
    ["Supported Addons"]            = "Unterst??tzte Addons",
    ["Selected Addon"]              = "Gew??hltes Addon",
    ["Library"]                     = "Bibliothek",
    ["SUPPORTEDADDONSDESC"]         = "Unterst??tzte Addons die Dazu benutzt werden k??nnten oder benutzt werden um das Inventar aufzuzeichnen.",
    -- ["SHOWBANKALTCOUNTSNAME"]       = "Include bank and alt character contents",
    -- ["SHOWBANKALTCOUNTSDESC"]       = "When calculating and displaying craftable itemn counts, include items from your bank and from your other characters",
    -- ["ENHANCHEDRECIPEDISPLAYNAME"]  = "Show recipe difficulty as text",
    -- ["ENHANCHEDRECIPEDISPLAYDESC"]  = "When enabled, recipe names will have one or more '+' characters appeneded to their name to inidcate the difficulty of the recipe.",
    -- ["SHOWCRAFTCOUNTSNAME"]         = "Show craftable counts",
    -- ["SHOWCRAFTCOUNTSDESC"]         = "Show the number of times you can craft a recipe, not the total number of items producable",

    -- New in version 1.11
    ["Crafted By"]                  = "Crafted by",

    -- New in 1.13
    ["SHOWCRAFTERSTOOLTIPNAME"]     = "Show crafters in tooltips",
    ["SHOWCRAFTERSTOOLTIPDESC"]     = "Display the alternate characters that can craft an item in the item's tooltip",
} end)
