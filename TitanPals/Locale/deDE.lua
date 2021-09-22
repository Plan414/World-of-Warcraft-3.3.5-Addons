local L = LibStub("AceLocale-3.0"):NewLocale("TitanPals", "deDE");
if not L then return end
L["TITAN_PALS_BUTTON_LABEL"] = "Freunde: "
L["TITAN_PALS_BUTTON_TEXT"] = "%s/%s/%s"
L["TITAN_PALS_BUTTON_TEXT_NOREALID"] = "%s/%s"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_F"] = "Todesritter"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_M"] = "Todesritter"
L["TITAN_PALS_CLASSES_DRUID_F"] = "Druidin"
L["TITAN_PALS_CLASSES_DRUID_M"] = "Druide"
L["TITAN_PALS_CLASSES_HUNTER_F"] = "Jägerin"
L["TITAN_PALS_CLASSES_HUNTER_M"] = "Jäger"
L["TITAN_PALS_CLASSES_MAGE_F"] = "Magierin"
L["TITAN_PALS_CLASSES_MAGE_M"] = "Magier"
L["TITAN_PALS_CLASSES_PALADIN_F"] = "Paladin"
L["TITAN_PALS_CLASSES_PALADIN_M"] = "Paladin"
L["TITAN_PALS_CLASSES_PRIEST_F"] = "Priesterin"
L["TITAN_PALS_CLASSES_PRIEST_M"] = "Priester"
L["TITAN_PALS_CLASSES_ROGUE_F"] = "Schurkin"
L["TITAN_PALS_CLASSES_ROGUE_M"] = "Schurke"
L["TITAN_PALS_CLASSES_SHAMAN_F"] = "Schamanin"
L["TITAN_PALS_CLASSES_SHAMAN_M"] = "Schamane"
L["TITAN_PALS_CLASSES_WARLOCK_F"] = "Hexenmeisterin"
L["TITAN_PALS_CLASSES_WARLOCK_M"] = "Hexenmeister"
L["TITAN_PALS_CLASSES_WARRIOR_F"] = "Kriegerin"
L["TITAN_PALS_CLASSES_WARRIOR_M"] = "Krieger"
L["TITAN_PALS_COLORS_BLUE"] = "|cff00ffff"
L["TITAN_PALS_COLORS_CTAG"] = "|r"
L["TITAN_PALS_COLORS_GRAY"] = "|cff808080"
L["TITAN_PALS_COLORS_GREEN"] = "|cff20ff20"
L["TITAN_PALS_COLORS_HLIGHT"] = "|cffffffff"
L["TITAN_PALS_COLORS_NORMAL"] = "|cffffd200"
L["TITAN_PALS_COLORS_ORANGE"] = "|cffff9900"
L["TITAN_PALS_COLORS_RED"] = "|cffff2020"
L["TITAN_PALS_CONFIG"] = "Titan [|cffeda55fPals|r]"
L["TITAN_PALS_CONFIG_ABOUT"] = "Über"
L["TITAN_PALS_CONFIG_BANNOR"] = "Zeige Ladebildschirm"
L["TITAN_PALS_CONFIG_BANNOR_DESC"] = "Zeigt Addon Informationen und Speicherverbrauch zum Ladezeitpunkt im Chatfenster."
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP"] = "Add a |cff00ffffRealID|r Tooltip Format :" -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_DESC"] = "Here you can add custom formats for the tooltip display" -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_INST"] = [=[
|cff20ff20Benutze :|r
     |cff20ff20!cn|r for Character Name
     |cff20ff20!fn|r for Full Name
     |cff20ff20!sn|r for Sir Name
     |cff20ff20!ln|r for Last Name
     |cff20ff20!rn|r for Realm Name
     |cff20ff20!gn|r for Game Client|r]=] -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP"] = "Füge ein Tooltip Format hinzu"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_DESC"] = "Hier kannst du eigene Formate für das Tooltip-Display hinzufügen"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_INST"] = [=[
|cff20ff20Benutze :|r
     |cff20ff20!s|r für Status
     |cff20ff20!l|r für Level
     |cff20ff20!p|r für Spieler
     |cff20ff20!z|r für Zone
     |cff20ff20!n|r für Bemerkung
     |cff20ff20!c|r für Klasse
     |cff20ff20!uc|r für farbige Spielernamen

|cffff9900Die RECHTE Seite muss von der LINKEN Seite mit ~ (Tilde) getrennt werden.|r]=]
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID"] = "|cff00ffffRealID|r Tooltip Format :"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID_DESC"] = "Ein paar |cff00ffffRealID|r Voreinstellungen um den Namen von |cff00ffffRealID|r Freunden anzupassen"
L["TITAN_PALS_CONFIG_HEADER_ADD"] = "Neue Formate"
L["TITAN_PALS_CONFIG_HEADER_REALID"] = "|cff00ffffRealID Format|r"
L["TITAN_PALS_CONFIG_HEADER_REALID_ADD"] = "New |cff00ffffRealID|r Formats" -- Requires localization
L["TITAN_PALS_CONFIG_HEADER_REALID_REMOVE"] = "Remove |cff00ffffRealID|r Formats" -- Requires localization
L["TITAN_PALS_CONFIG_HEADER_REMOVE"] = "Formate entfernen"
L["TITAN_PALS_CONFIG_LABEL"] = "Addon für Titan Panel, Dieses Addon zeigt Ihre Freundesliste sortiert nach Login-Status im Titan Panel an"
L["TITAN_PALS_CONFIG_NOALTS"] = "Entferne alternative Chars vom ToolTip"
L["TITAN_PALS_CONFIG_NOALTS_DESC"] = "Verhindert das alternative Chars im ToolTip angezeigt werden."
L["TITAN_PALS_CONFIG_PRESETS"] = "Tooltip Voreinstellungen :"
L["TITAN_PALS_CONFIG_PRESETS_DESC"] = "Eine Auswahl an Listenformatierungen für die Tooltip-Anzeige"
L["TITAN_PALS_CONFIG_PRESETS_PREVIEW"] = "Für Vorschau bitte die Maus über die Titan [|cffeda55fPals|r] Schaltfläche bewegen."
L["TITAN_PALS_CONFIG_REALID_NOTE1_OFF"] = " |cffff2020Deaktivieren|r dieser Option wird verhindern, das irgendeine |cff00ffffRealID Freunde|r Info im Tooltip angezeigt."
L["TITAN_PALS_CONFIG_REALID_NOTE1_ON"] = "|cff20ff20Aktivieren|r dieser Option wird die |cff00ffffRealID Freunde|r Info im Tooltip anzeigen."
L["TITAN_PALS_CONFIG_REALID_ONOFF"] = "Zeige die |cff00ffffRealID|r im Tooltip"
L["TITAN_PALS_CONFIG_REALID_ONOFF_DESC"] = "Diese Option wird die |cff00ffffRealID Freunde|r Info im Tooltip anzeigen."
L["TITAN_PALS_CONFIG_REALID_PRESETS"] = "|cff00ffffRealID|r Tooltip Presets :" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_PRESETS_DESC"] = "A few diffrent preset format for the |cff00ffffRealID|r part of the tooltip" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE"] = "Remove |cff00ffffRealID|r" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE_DESC"] = "This will remove the selected |cff00ffffRealID|r format from the presets tooltip table" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE_PRESETS_DESC"] = "Please select a |cff00ffffRealID|r format to remove!" -- Requires localization
L["TITAN_PALS_CONFIG_REMOVE"] = "Entferne"
L["TITAN_PALS_CONFIG_REMOVE_DESC"] = "Dies wird das ausgewählte Format aus den Voreinstellungen entfernen"
L["TITAN_PALS_CONFIG_REMOVE_PRESETS_DESC"] = "Bitte wähle das zu entfernende Format!"
L["TITAN_PALS_CONFIG_SET_HEADER"] = "Addon Einstellungen :"
L["TITAN_PALS_CONFIG_SET_HEADER_2"] = "Freundesliste anpassen :"
L["TITAN_PALS_CONFIG_SET_HEADER_STATUS"] = "Status Types" -- Requires localization
L["TITAN_PALS_CONFIG_SHOWIGNORED"] = "Zeige zurzeit Ignoriert"
L["TITAN_PALS_CONFIG_SHOWIGNORED_DESC"] = "Zeigt alle Spieler die von euch derzeit ignoriert werden im Tooltip an."
L["TITAN_PALS_CONFIG_SHOWMEM"] = "Zeige Speicherverbrauch"
L["TITAN_PALS_CONFIG_SHOWMEM_DESC"] = "Zeigt den Speicherverbrauch von TitanPals an."
L["TITAN_PALS_CONFIG_SHOWOFFLINE"] = "Zeige Offline Freunde"
L["TITAN_PALS_CONFIG_SHOWOFFLINE_DESC"] = "Zeigt detaillierte Infos eurer Freunde im ToolTip an."
L["TITAN_PALS_CONFIG_STATUS_TYPES"] = "Status Display Style" -- Requires localization
L["TITAN_PALS_CONFIG_STATUS_TYPES_DESC"] = "The style that you would like Pals that are away to show up as." -- Requires localization
L["TITAN_PALS_CONFIG_STATUS_TYPES_INST"] = [=[

|cff20ff20This allow you to change the default text of <Away> in the tooltip, you choices are :|r
     |cffff8c00<Away>|r
     |cffff8c00<AFK>|r
     |cffff8c00<A>|r
     |cffff8c00(Away)|r
     |cffff8c00(AFK)|r
     |cffff8c00(A)|r
     |cffff8c00[Away]|r
     |cffff8c00[AFK]|r
     |cffff8c00[A]|r]=] -- Requires localization
L["TITAN_PALS_DEBUG_DEBUG1"] = "Debug Setting"
L["TITAN_PALS_DEBUG_DEV"] = "Debug Mode"
L["TITAN_PALS_DEBUG_DEVEVENT"] = "Event Debug Mode"
L["TITAN_PALS_DEBUG_DEVLOGEVENT"] = "Log Event Debug Mode"
L["TITAN_PALS_DEBUG_MDEBUG"] = "Debug Menu"
L["TITAN_PALS_DEBUG_PLAY"] = "Play Data Array To Chat Frame"
L["TITAN_PALS_DEBUG_PLAYALTS"] = "Print Alts To Chat Frame"
L["TITAN_PALS_DEBUG_PLAYFRIENDS"] = "Print Friends To Chat Frame"
L["TITAN_PALS_MENU_CUSTOM_NOTE"] = "Eigene Bemerkung"
L["TITAN_PALS_MENU_INVITE"] = "Einladen"
L["TITAN_PALS_MENU_NORMAL"] = "Normale Freunde"
L["TITAN_PALS_MENU_NOTE"] = "Hinweis"
L["TITAN_PALS_MENU_REALID"] = "|cff00ffffRealID Freunde|r"
L["TITAN_PALS_MENU_REMOVE"] = "Entfernen"
L["TITAN_PALS_MENU_REMOVEDATA"] = "Werkzeuge Datenbank"
L["TITAN_PALS_MENU_REMOVE_ALT"] = "Alternativen Char entfernen"
L["TITAN_PALS_MENU_REMOVE_ALTDATA"] = "Alternativen Char aus Datenbank entfernen"
L["TITAN_PALS_MENU_REMOVE_FRIEND"] = "Freund entfernen"
L["TITAN_PALS_MENU_REMOVE_FRIENDDATA"] = "Freund aus Datenbank entfernen"
L["TITAN_PALS_MENU_SETTINGS"] = "Einstellungen"
L["TITAN_PALS_MENU_SUB_REMOVE"] = "Entferne "
L["TITAN_PALS_MENU_SYNC"] = "Synchronisieren"
L["TITAN_PALS_MENU_SYNCALTS"] = "Synchronisiere alternative Chars mit Freundesliste"
L["TITAN_PALS_MENU_SYNCALTSFRIENDS"] = "Synchronisiere Freunde der alternativen Chars mit Freundesliste"
L["TITAN_PALS_MENU_TEXT"] = "Titan Pals"
L["TITAN_PALS_MENU_WHISPER"] = "Flüstern"
L["TITAN_PALS_NOTES_DEATH KNIGHT_1"] = "Blut"
L["TITAN_PALS_NOTES_DEATH KNIGHT_2"] = "Frost"
L["TITAN_PALS_NOTES_DEATH KNIGHT_3"] = "Unheilig"
L["TITAN_PALS_NOTES_DRUID_1"] = "Gleichgewicht"
L["TITAN_PALS_NOTES_DRUID_2"] = "Wilder Kampf"
L["TITAN_PALS_NOTES_DRUID_3"] = "Wiederherstellung"
L["TITAN_PALS_NOTES_HUNTER_1"] = "Treffsicherheit"
L["TITAN_PALS_NOTES_HUNTER_2"] = "Tierherrschaft"
L["TITAN_PALS_NOTES_HUNTER_3"] = "Überleben"
L["TITAN_PALS_NOTES_MAGE_1"] = "Feuer"
L["TITAN_PALS_NOTES_MAGE_2"] = "Frost"
L["TITAN_PALS_NOTES_MAGE_3"] = "Arkan"
L["TITAN_PALS_NOTES_PALADIN_1"] = "Schutz"
L["TITAN_PALS_NOTES_PALADIN_2"] = "Heilig"
L["TITAN_PALS_NOTES_PALADIN_3"] = "Vergeltung"
L["TITAN_PALS_NOTES_PRIEST_1"] = "Schatten"
L["TITAN_PALS_NOTES_PRIEST_2"] = "Heilig"
L["TITAN_PALS_NOTES_PRIEST_3"] = "Disziplin"
L["TITAN_PALS_NOTES_ROGUE_1"] = "Meucheln"
L["TITAN_PALS_NOTES_ROGUE_2"] = "Kampf"
L["TITAN_PALS_NOTES_ROGUE_3"] = "Täuschung"
L["TITAN_PALS_NOTES_SHAMAN_1"] = "Elementar"
L["TITAN_PALS_NOTES_SHAMAN_2"] = "Verstärkung"
L["TITAN_PALS_NOTES_SHAMAN_3"] = "Wiederherstellung"
L["TITAN_PALS_NOTES_WARLOCK_1"] = "Gebrechen"
L["TITAN_PALS_NOTES_WARLOCK_2"] = "Dämonologie"
L["TITAN_PALS_NOTES_WARLOCK_3"] = "Zerstörung"
L["TITAN_PALS_NOTES_WARRIOR_1"] = "Schutz"
L["TITAN_PALS_NOTES_WARRIOR_2"] = "Waffen"
L["TITAN_PALS_NOTES_WARRIOR_3"] = "Furor"
L["TITAN_PALS_REALM_ERROR"] = " Sorry %s ist nicht in deinem Realm. Du kannst nur Freunde einladen, die sich im gleichen Realm befinden."
L["TITAN_PALS_REAL_TOOLTIP"] = "|cff00ffffRealID|r Pals Info"
L["TITAN_PALS_TOOLTIP"] = "Info Freunde Online"
L["TITAN_PALS_TOOLTIP_EMPTY"] = "Deine Freundesliste ist Zur zeit leer!!!"
L["TITAN_PALS_TOOLTIP_IGNORE"] = "Info zurzeit Ignoriert"
L["TITAN_PALS_TOOLTIP_IGNORED"] = "Zurzeit Ignoriert"
L["TITAN_PALS_TOOLTIP_IGNORE_EMPTY"] = "Deine Ignorieren-Liste ist zur Zeit leer."
L["TITAN_PALS_TOOLTIP_MEM"] = "Speicherverbrauch"
L["TITAN_PALS_TOOLTIP_NOPALS"] = "Im Moment keine Freunde Online"
L["TITAN_PALS_TOOLTIP_NOREALID_FRIENDS"] = "Du hast keine |cff00ffffRealID Freunde|r!!!"
L["TITAN_PALS_TOOLTIP_NOREALPALS"] = "  Kein RealID Freund zur Zeit online"
L["TITAN_PALS_TOOLTIP_NO_OFF"] = "  No Offline Pals" -- Requires localization
L["TITAN_PALS_TOOLTIP_OFF"] = "Info Freunde Offline"
L["TITAN_PALS_TOOLTIP_OFFLINE"] = "Offline"
L["TITAN_PALS_TOOLTIP_OFFLINE_IGNORED"] = "Ignoriert"
L["TITAN_PALS_TOOLTIP_ONLINE"] = "Online"