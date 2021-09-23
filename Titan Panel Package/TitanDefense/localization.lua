-- Titan Defense Localization File

-- Global Definitions
TITAN_DEFENSE_STRINGS_VERSION = "3.0.7.30200";
TITAN_DEFENSE_STRINGS_VERSION_INFO = "|cffffd700Titan Panel [Defense] "..TITAN_DEFENSE_STRINGS_VERSION.." [|cffBB33BBHonorGoG|cffffd700]";

local locale = GetLocale();

-- English (Default)
TITAN_DEFENSE_STRINGS_MODNAME = "Titan Panel [Defense]";
TITAN_DEFENSE_STRINGS_MODDESC = "Summarize WorldDefense spam for Titan Panel";
TITAN_DEFENSE_STRINGS_BARFRAMENAME = "TitanPanelDefenseButton";
TITAN_DEFENSE_STRINGS_MENUTEXT = "Titan Defense"
TITAN_DEFENSE_STRINGS_TOOLTIP = "Titan Defense"
TITAN_DEFENSE_STRINGS_ZONEATTACKSEARCH = string.gsub(ZONE_UNDER_ATTACK, "%%[^%s]+", "(.+)") -- "|cffffff00%s is under attack!|r"
TITAN_DEFENSE_STRINGS_NEWZONE1 = "TitanDefense: New subzone found ";
TITAN_DEFENSE_STRINGS_NEWZONE2 = ", please send your WTF\Account\<username>\TitanDefense.lua file and upload the TitanDefense_newSubzones variable block to honorgog@titanpanel.org!";
TITAN_DEFENSE_STRINGS_WDCHANNAME = "WorldDefense";
TITAN_DEFENSE_STRINGS_LDCHANNAME = "LocalDefense";
TITAN_DEFENSE_STRINGS_ATTACKTEXT = "1 Attack";
TITAN_DEFENSE_STRINGS_ATTACKSTEXT = " Attacks";
TITAN_DEFENSE_STRINGS_NOATTACKS = "No Attacks";
TITAN_DEFENSE_STRINGS_SECONDS = " sec";
TITAN_DEFENSE_STRINGS_MINUTES = " min";
TITAN_DEFENSE_STRINGS_HOUR = " hour";
TITAN_DEFENSE_STRINGS_SZTIMETITLE = "Most Recently Attacked Subzones"
TITAN_DEFENSE_STRINGS_ZTIMETITLE = "Most Recently Attacked Zones";
TITAN_DEFENSE_STRINGS_SZFRQTITLE = "Most Frequently Attacked Subzones";
TITAN_DEFENSE_STRINGS_ZFRQTITLE = "Most Frequently Attacked Zones";
TITAN_DEFENSE_STRINGS_LOCALHEADER = "|cffff0000Local|r: ";
TITAN_DEFENSE_STRINGS_AGOENDER = " ago";
TITAN_DEFENSE_STRINGS_UNKNOWNZONE = "Unknown Zone";

-- German by El Rico on Curse Gaming --
if (locale == "deDE") then
     TITAN_DEFENSE_STRINGS_MODNAME = "Titan Panel [Verteidigung]";
     TITAN_DEFENSE_STRINGS_MODDESC = "Verteidigungs Tracker plugin f\195\188r Titan Panel";
     TITAN_DEFENSE_STRINGS_BARFRAMENAME = "TitanPanelVerteidigungSchaltfl\195\164che";
     TITAN_DEFENSE_STRINGS_MENUTEXT = "Verteidigungs Tracker"
     TITAN_DEFENSE_STRINGS_TOOLTIP = "Verteidigungs Tracker"
     TITAN_DEFENSE_STRINGS_NEWZONE1 = "Verteidigungs-Tracker: Neue Subzone gefunden ";
     TITAN_DEFENSE_STRINGS_NEWZONE2 = ", überprüfe die SavedVariables.lua und uploade den TitanDefense_newSubzones Variablen Block ins addons@goldshire.com!";
     TITAN_DEFENSE_STRINGS_WDCHANNAME = "WeltVerteidigung";
     TITAN_DEFENSE_STRINGS_LDCHANNAME = "LokaleVerteidigung";
     TITAN_DEFENSE_STRINGS_ATTACKTEXT = "1 Angriff";
     TITAN_DEFENSE_STRINGS_ATTACKSTEXT = " Angriffe";
     TITAN_DEFENSE_STRINGS_NOATTACKS = "Kein Angriff";
     TITAN_DEFENSE_STRINGS_SECONDS = " sek";
     TITAN_DEFENSE_STRINGS_MINUTES = " min";
     TITAN_DEFENSE_STRINGS_HOUR = " Stunde";
     TITAN_DEFENSE_STRINGS_SZTIMETITLE = "Zuletzt angegriffene Subzonen"
     TITAN_DEFENSE_STRINGS_ZTIMETITLE = "Zuletzt angegriffene Zonen";
     TITAN_DEFENSE_STRINGS_SZFRQTITLE = "Am häufigsten angegriffene Subzonen";
     TITAN_DEFENSE_STRINGS_ZFRQTITLE = "Am häufigsten angegriffene Zonen";
     TITAN_DEFENSE_STRINGS_LOCALHEADER = "|cffff0000Lokal|r: ";
     TITAN_DEFENSE_STRINGS_AGOENDER = " vorüber";
     TITAN_DEFENSE_STRINGS_UNKNOWNZONE = "Unbekannte Zone";     
end