local L = LibStub("AceLocale-3.0"):NewLocale("TitanPals", "frFR");
if not L then return end
L["TITAN_PALS_BUTTON_LABEL"] = "Pals: " -- Needs review
L["TITAN_PALS_BUTTON_TEXT"] = "%s/%s/%s"
L["TITAN_PALS_BUTTON_TEXT_NOREALID"] = "%s/%s"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_F"] = "Chevalier de la mort"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_M"] = "Chevalier de la mort"
L["TITAN_PALS_CLASSES_DRUID_F"] = "Druidesse"
L["TITAN_PALS_CLASSES_DRUID_M"] = "Druide"
L["TITAN_PALS_CLASSES_HUNTER_F"] = "Chasseresse"
L["TITAN_PALS_CLASSES_HUNTER_M"] = "Chasseur"
L["TITAN_PALS_CLASSES_MAGE_F"] = "Mage"
L["TITAN_PALS_CLASSES_MAGE_M"] = "Mage"
L["TITAN_PALS_CLASSES_PALADIN_F"] = "Paladin"
L["TITAN_PALS_CLASSES_PALADIN_M"] = "Paladin"
L["TITAN_PALS_CLASSES_PRIEST_F"] = "Prêtresse"
L["TITAN_PALS_CLASSES_PRIEST_M"] = "Prêtre"
L["TITAN_PALS_CLASSES_ROGUE_F"] = "Voleuse"
L["TITAN_PALS_CLASSES_ROGUE_M"] = "Voleur"
L["TITAN_PALS_CLASSES_SHAMAN_F"] = "Chamane"
L["TITAN_PALS_CLASSES_SHAMAN_M"] = "Chaman"
L["TITAN_PALS_CLASSES_WARLOCK_F"] = "Démoniste"
L["TITAN_PALS_CLASSES_WARLOCK_M"] = "Démoniste"
L["TITAN_PALS_CLASSES_WARRIOR_F"] = "Guerrière"
L["TITAN_PALS_CLASSES_WARRIOR_M"] = "Guerrier"
L["TITAN_PALS_COLORS_BLUE"] = "|cff00ffff"
L["TITAN_PALS_COLORS_CTAG"] = "|r"
L["TITAN_PALS_COLORS_GRAY"] = "|cff808080"
L["TITAN_PALS_COLORS_GREEN"] = "|cff20ff20"
L["TITAN_PALS_COLORS_HLIGHT"] = "|cffffffff"
L["TITAN_PALS_COLORS_NORMAL"] = "|cffffd200"
L["TITAN_PALS_COLORS_ORANGE"] = "|cffff9900"
L["TITAN_PALS_COLORS_RED"] = "|cffff2020"
L["TITAN_PALS_CONFIG"] = "Titan [|cffeda55fPals|r]"
L["TITAN_PALS_CONFIG_ABOUT"] = "About"
L["TITAN_PALS_CONFIG_BANNOR"] = "Display Load Bannor" -- Needs review
L["TITAN_PALS_CONFIG_BANNOR_DESC"] = "This will display addon information and memory usage when the addon is loaded in the chat frame." -- Needs review
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP"] = "Add a |cff00ffffRealID|r Tooltip Format :"
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_DESC"] = "Here you can add custom formats for the tooltip display"
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_INST"] = [=[
|cff20ff20You can use :|r
     |cff20ff20!cn|r for Character Name
     |cff20ff20!fn|r for Full Name
     |cff20ff20!sn|r for Sir Name
     |cff20ff20!ln|r for Last Name
     |cff20ff20!rn|r for Realm Name
     |cff20ff20!gn|r for Game Client|r]=]
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP"] = "Add a Tooltip Format :"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_DESC"] = "Here you can add custom formats for the tooltip display"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_INST"] = [=[
|cff20ff20You can use :|r
     |cff20ff20!s|r for Status
     |cff20ff20!l|r for Level
     |cff20ff20!p|r for Player
     |cff20ff20!z|r for Zone
     |cff20ff20!n|r for Note
     |cff20ff20!c|r for Class
     |cff20ff20!uc|r for Colored Players Name

 |cffff9900The RIGHT side must be seperated from the LEFT with a ~ (tilda).|r]=]
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID"] = "|cff00ffffRealID|r Tooltip Format :"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID_DESC"] = "A few |cff00ffffRealID|r presets for changeing the name format of |cff00ffffRealID Pals|r that show up in the tooltip."
L["TITAN_PALS_CONFIG_HEADER_ADD"] = "Add a New Format"
L["TITAN_PALS_CONFIG_HEADER_REALID"] = "|cff00ffffRealID|r"
L["TITAN_PALS_CONFIG_HEADER_REALID_ADD"] = "New |cff00ffffRealID|r Formats"
L["TITAN_PALS_CONFIG_HEADER_REALID_REMOVE"] = "Remove |cff00ffffRealID|r Formats"
L["TITAN_PALS_CONFIG_HEADER_REMOVE"] = "Remove a Format"
L["TITAN_PALS_CONFIG_LABEL"] = "Addon for Titan Panel, This addon displays your friends list sorted by connection status on Titan Panel"
L["TITAN_PALS_CONFIG_NOALTS"] = "Remove Alts from ToolTip"
L["TITAN_PALS_CONFIG_NOALTS_DESC"] = "This will keep alts from showing up on the tooltip."
L["TITAN_PALS_CONFIG_PRESETS"] = "Tooltip Presets :"
L["TITAN_PALS_CONFIG_PRESETS_DESC"] = "A few diffrent preset format for the tooltip display"
L["TITAN_PALS_CONFIG_PRESETS_PREVIEW"] = "To preview, mouse over Titan [|cffeda55fPals|r] button."
L["TITAN_PALS_CONFIG_REALID_NOTE1_OFF"] = "|cffff2020Disabling|r This will prevent any |cff00ffffRealID Pals|r info from showing on the tooltip."
L["TITAN_PALS_CONFIG_REALID_NOTE1_ON"] = "|cff20ff20Enabling|r this will show |cff00ffffRealID Pals|r info in tooltip."
L["TITAN_PALS_CONFIG_REALID_ONOFF"] = "Show |cff00ffffRealID Pals|r in Tooltip"
L["TITAN_PALS_CONFIG_REALID_ONOFF_DESC"] = "This will show |cff00ffffRealID Pals|r info in tooltip."
L["TITAN_PALS_CONFIG_REALID_PRESETS"] = "|cff00ffffRealID|r Tooltip Presets :"
L["TITAN_PALS_CONFIG_REALID_PRESETS_DESC"] = "A few diffrent preset format for the |cff00ffffRealID|r part of the tooltip"
L["TITAN_PALS_CONFIG_REALID_REMOVE"] = "Remove |cff00ffffRealID|r"
L["TITAN_PALS_CONFIG_REALID_REMOVE_DESC"] = "This will remove the selected |cff00ffffRealID|r format from the presets tooltip table"
L["TITAN_PALS_CONFIG_REALID_REMOVE_PRESETS_DESC"] = "Please select a |cff00ffffRealID|r format to remove!"
L["TITAN_PALS_CONFIG_REMOVE"] = "Remove"
L["TITAN_PALS_CONFIG_REMOVE_DESC"] = "This will remove the selected format from the presets tooltip table"
L["TITAN_PALS_CONFIG_REMOVE_PRESETS_DESC"] = "Please select the format to remove!"
L["TITAN_PALS_CONFIG_SET_HEADER"] = "Tooltip Format :"
L["TITAN_PALS_CONFIG_SET_HEADER_2"] = "Toooltip Settings :"
L["TITAN_PALS_CONFIG_SET_HEADER_STATUS"] = "Status Types"
L["TITAN_PALS_CONFIG_SHOWIGNORED"] = "Show Currently Ignored"
L["TITAN_PALS_CONFIG_SHOWIGNORED_DESC"] = "This will show anyone you might have Ignored on the tooltip."
L["TITAN_PALS_CONFIG_SHOWMEM"] = "Show Memory Usage"
L["TITAN_PALS_CONFIG_SHOWMEM_DESC"] = "This will show you the amount of memory that TitamPals is using on the Tooltip."
L["TITAN_PALS_CONFIG_SHOWOFFLINE"] = "Show Offline Friends"
L["TITAN_PALS_CONFIG_SHOWOFFLINE_DESC"] = "This will show some detailed info on the tooltip about your friends."
L["TITAN_PALS_CONFIG_STATUS_TYPES"] = "Status Display Style"
L["TITAN_PALS_CONFIG_STATUS_TYPES_DESC"] = "The style that you would like Pals that are away to show up as."
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
     |cffff8c00[A]|r]=]
L["TITAN_PALS_DEBUG_DEBUG1"] = "Debug Setting"
L["TITAN_PALS_DEBUG_DEV"] = "Debug Mode"
L["TITAN_PALS_DEBUG_DEVEVENT"] = "Event Debug Mode"
L["TITAN_PALS_DEBUG_DEVLOGEVENT"] = "Log Event Debug Mode"
L["TITAN_PALS_DEBUG_MDEBUG"] = "Debug Menu"
L["TITAN_PALS_DEBUG_PLAY"] = "Play Data Array To Chat Frame"
L["TITAN_PALS_DEBUG_PLAYALTS"] = "Print Alts To Chat Frame"
L["TITAN_PALS_DEBUG_PLAYFRIENDS"] = "Print Friends To Chat Frame"
L["TITAN_PALS_MENU_CUSTOM_NOTE"] = "Custom Note"
L["TITAN_PALS_MENU_INVITE"] = "Invite"
L["TITAN_PALS_MENU_NORMAL"] = "Normal Friends"
L["TITAN_PALS_MENU_NOTE"] = "Note"
L["TITAN_PALS_MENU_REALID"] = "|cff00ffffRealID Pals|r"
L["TITAN_PALS_MENU_REMOVE"] = "Remove"
L["TITAN_PALS_MENU_REMOVEDATA"] = "Database Utilitys"
L["TITAN_PALS_MENU_REMOVE_ALT"] = "Remove Alt"
L["TITAN_PALS_MENU_REMOVE_ALTDATA"] = "Remove Alt From Database"
L["TITAN_PALS_MENU_REMOVE_FRIEND"] = "Remove Friend"
L["TITAN_PALS_MENU_REMOVE_FRIENDDATA"] = "Remove Friend From Database"
L["TITAN_PALS_MENU_SETTINGS"] = "Settings" -- Needs review
L["TITAN_PALS_MENU_SUB_REMOVE"] = "Remove "
L["TITAN_PALS_MENU_SYNC"] = "Syncing" -- Needs review
L["TITAN_PALS_MENU_SYNCALTS"] = "Sync Alts to Friends List" -- Needs review
L["TITAN_PALS_MENU_SYNCALTSFRIENDS"] = "Sync Alts Friends to Friends List" -- Needs review
L["TITAN_PALS_MENU_TEXT"] = "Titan Pals" -- Needs review
L["TITAN_PALS_MENU_WHISPER"] = "Whisper" -- Needs review
L["TITAN_PALS_NOTES_DEATH KNIGHT_1"] = "Blood"
L["TITAN_PALS_NOTES_DEATH KNIGHT_2"] = "Frost"
L["TITAN_PALS_NOTES_DEATH KNIGHT_3"] = "Unholy"
L["TITAN_PALS_NOTES_DRUID_1"] = "Balance"
L["TITAN_PALS_NOTES_DRUID_2"] = "Feral Combat"
L["TITAN_PALS_NOTES_DRUID_3"] = "Restoration"
L["TITAN_PALS_NOTES_HUNTER_1"] = "Marksmanship"
L["TITAN_PALS_NOTES_HUNTER_2"] = "Beast Mastery"
L["TITAN_PALS_NOTES_HUNTER_3"] = "Survival"
L["TITAN_PALS_NOTES_MAGE_1"] = "Fire"
L["TITAN_PALS_NOTES_MAGE_2"] = "Frost"
L["TITAN_PALS_NOTES_MAGE_3"] = "Arcane"
L["TITAN_PALS_NOTES_PALADIN_1"] = "Protection"
L["TITAN_PALS_NOTES_PALADIN_2"] = "Holy"
L["TITAN_PALS_NOTES_PALADIN_3"] = "Retribution"
L["TITAN_PALS_NOTES_PRIEST_1"] = "Shadow"
L["TITAN_PALS_NOTES_PRIEST_2"] = "Holy"
L["TITAN_PALS_NOTES_PRIEST_3"] = "Discipline"
L["TITAN_PALS_NOTES_ROGUE_1"] = "Assassination"
L["TITAN_PALS_NOTES_ROGUE_2"] = "Combat"
L["TITAN_PALS_NOTES_ROGUE_3"] = "Subtlety"
L["TITAN_PALS_NOTES_SHAMAN_1"] = "Elemental"
L["TITAN_PALS_NOTES_SHAMAN_2"] = "Enhancement"
L["TITAN_PALS_NOTES_SHAMAN_3"] = "Restoration"
L["TITAN_PALS_NOTES_WARLOCK_1"] = "Affliction"
L["TITAN_PALS_NOTES_WARLOCK_2"] = "Demonology"
L["TITAN_PALS_NOTES_WARLOCK_3"] = "Destruction"
L["TITAN_PALS_NOTES_WARRIOR_1"] = "Protection"
L["TITAN_PALS_NOTES_WARRIOR_2"] = "Arms"
L["TITAN_PALS_NOTES_WARRIOR_3"] = "Fury"
L["TITAN_PALS_REALM_ERROR"] = "Sorry %s is not on your realm, you can only invite ppl from your realm"
L["TITAN_PALS_REAL_TOOLTIP"] = "|cff00ffffRealID|r Pals Info"
L["TITAN_PALS_TOOLTIP"] = "Online Pals Info" -- Needs review
L["TITAN_PALS_TOOLTIP_EMPTY"] = "Your Pals List Is Currently Empty!!!"
L["TITAN_PALS_TOOLTIP_IGNORE"] = "Currently Ignored Info" -- Needs review
L["TITAN_PALS_TOOLTIP_IGNORED"] = "Currently Ignored"
L["TITAN_PALS_TOOLTIP_IGNORE_EMPTY"] = "Your ignore list is currently empty." -- Needs review
L["TITAN_PALS_TOOLTIP_MEM"] = "Memory Usage"
L["TITAN_PALS_TOOLTIP_NOPALS"] = "No Pals Currently Online"
L["TITAN_PALS_TOOLTIP_NOREALID_FRIENDS"] = "You have no |cff00ffffRealID Pals|r!!!"
L["TITAN_PALS_TOOLTIP_NOREALPALS"] = "  No |cff00ffffRealID|r Pals Currently Online"
L["TITAN_PALS_TOOLTIP_NO_OFF"] = "  No Offline Pals"
L["TITAN_PALS_TOOLTIP_OFF"] = "Offline Pals Info" -- Needs review
L["TITAN_PALS_TOOLTIP_OFFLINE"] = "Offline" -- Needs review
L["TITAN_PALS_TOOLTIP_OFFLINE_IGNORED"] = "<Ignored>"
L["TITAN_PALS_TOOLTIP_ONLINE"] = "Online" -- Needs review