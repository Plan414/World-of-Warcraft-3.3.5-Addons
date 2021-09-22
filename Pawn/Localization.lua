-- Pawn by Vger-Azjol-Nerub
-- 
-- English resources

------------------------------------------------------------


------------------------------------------------------------
-- "Constants"
------------------------------------------------------------

PawnDefaultScaleName = "Pawn value" -- The name of the default Pawn scale
PawnUINoScale = "(none)" -- The name that shows up in lists of scales if you have no scales

------------------------------------------------------------
-- Master table of stats
------------------------------------------------------------

-- The master list of all stats that Pawn supports.
-- First column is the friendly translated name of the stat.
-- Second column is the Pawn name of the stat; this can't be translated.
-- Third column is the description of the stat.
-- Fourth column is an optional chunk of text instead of the "1 ___ is worth:" prompt.
-- If only a name is present, the row becomes an uneditable header in the UI and is otherwise ignored.
PawnStats =
{
	{"Base stats"},
	{"Strength", "Strength", "The primary stat, Strength."},
	{"Agility", "Agility", "The primary stat, Agility."},
	{"Stamina", "Stamina", "The primary stat, Stamina."},
	{"Intellect", "Intellect", "The primary stat, Intellect."},
	{"Spirit", "Spirit", "The primary stat, Spirit."},
	{"Health", "Health", "Raw health.  Does not include health from Stamina.  This generally appears only on enchantments."},
	{"Mana", "Mana", "Raw mana.  Does not include mana from Intellect.  This generally appears only on enchantments."},
	
	{"Sockets"},
	{"Red socket", "RedSocket", "An empty red socket.  Once you socket an item, the socket \"stat\" is removed and the value of the gem is added."},
	{"Yellow socket", "YellowSocket", "An empty yellow socket.  Once you socket an item, the socket \"stat\" is removed and the value of the gem is added."},
	{"Blue socket", "BlueSocket", "An empty blue socket.  Once you socket an item, the socket \"stat\" is removed and the value of the gem is added."},
	{"Colorless socket", "ColorlessSocket", VgerCore.Color.Blue .. "Only used in Wrath of the Lich King.  " .. VgerCore.Color.Reset .. "An empty colorless socket (created by blacksmithing)."},
	{"Meta socket", "MetaSocket", "An empty meta socket.  Once you socket an item, the socket \"stat\" is removed and the value of the gem is added.  The item's value will be the same whether or not the meta gem requirements are met."},
	
	{"Weapon stats"},
	{"DPS", "Dps", "Weapon damage per second.  (If you want to value DPS differently for different types of weapons, see the \"Special weapon stats\" section.)"},
	{"Minimum damage", "MinDamage", "Weapon minimum damage."},
	{"Maximum damage", "MaxDamage", "Weapon maximum damage."},
	{"Speed", "Speed", "Weapon speed, in seconds per swing.  (If you prefer fast weapons, this number should be negative.  See also: \"speed baseline\" in the \"Special weapon stats\" section.)"},
	
	{"Hybrid ratings"},
	{"Hit rating", "HitRating", "Melee and ranged hit rating.  In Wrath of the Lich King, also applies to spells."},
	{"Crit rating", "CritRating", "Melee and ranged critical strike rating.  In Wrath of the Lich King, also applies to spells."},
	{"Haste rating", "HasteRating", "Haste rating.  In Wrath of the Lich King, also applies to spells."},
	
	{"Offensive physical stats"},
	{"Attack power", "Ap", "Attack power.  Does not include attack power that you will receive from Strength or Agility."},
	{"Ranged AP", "Rap", "Ranged attack power."},
	{"Feral AP", "FeralAp", "Attack power in druid feral forms."},
	{"Expertise rating", "ExpertiseRating", "Expertise rating."},
	{"Armor penetration", "ArmorPenetration", "Armor penetration causes your attacks to ignore some of your opponent's armor."},
	
	{"Spell stats"},
	{"Spell power", "SpellPower", VgerCore.Color.Blue .. "Only used in Wrath of the Lich King.  " .. VgerCore.Color.Reset .. "The new Wrath stat that affects both spell damage and healing.  (Items will only have spell power OR damage and/or healing.)"},
	{"Spell damage", "SpellDamage", "Spell damage affects all schools of offensive magic, but not healing."},
	{"Healing", "Healing", "Bonus healing.  An item that says that it gives 300 healing and 100 spell damage would have 300 of the Healing stat and 100 of the Spell damage stat."},
	{"Mana per 5", "Mp5", "Mana regeneration per 5 seconds."},
	{"Spell hit rating", "SpellHitRating", "Spell hit rating.  " .. VgerCore.Color.Blue .. "Not used in Wrath of the Lich King."},
	{"Spell crit rating", "SpellCritRating", "Spell critical strike rating.  " .. VgerCore.Color.Blue .. "Not used in Wrath of the Lich King."},
	{"Fire spell power", "FireSpellDamage", "Fire-only spell power.  This stat does not appear on items that give spell power to all schools."},
	{"Shadow spell power", "ShadowSpellDamage", "Shadow-only spell power.  This stat does not appear on items that give spell power to all schools."},
	{"Nature spell power", "NatureSpellDamage", "Nature-only spell power.  This stat does not appear on items that give spell power to all schools."},
	{"Arcane spell power", "ArcaneSpellDamage", "Arcane-only spell power.  This stat does not appear on items that give spell power to all schools."},
	{"Frost spell power", "FrostSpellDamage", "Frost-only spell power.  This stat does not appear on items that give spell power to all schools."},
	{"Holy damage", "HolySpellDamage", "Holy-only spell damage.  This stat is quite rare, and does not appear on items that give spell power to all schools."},
	{"Spell penetration", "SpellPenetration", "Spell penetration causes your spells to ignore some of your opponent's resistances."},
	{"Spell haste rating", "SpellHasteRating", "Spell haste rating.  " .. VgerCore.Color.Blue .. "Not used in Wrath of the Lich King."},
	
	{"Defense stats"},
	{"Armor", "Armor", "Armor."},
	{"Block value", "BlockValue", "Block value increases the amount of damage absorbed with each successful shield block."},
	{"Block rating", "BlockRating", "Block rating increases your chances of blocking with a shield."},
	{"Defense rating", "DefenseRating", "Defense rating."},
	{"Resilience rating", "ResilienceRating", "Resilience rating."},
	{"Dodge rating", "DodgeRating", "Dodge rating."},
	{"Parry rating", "ParryRating", "Parry rating."},
	{"All resistances", "AllResist", "All elemental resistances."},
	{"Fire resistance", "FireResist", "Fire resistance.  This stat does not appear on items that give all elemental resistances."},
	{"Shadow resistance", "ShadowResist", "Shadow resistance.  This stat does not appear on items that give all elemental resistances."},
	{"Nature resistance", "NatureResist", "Nature resistance.  This stat does not appear on items that give all elemental resistances."},
	{"Arcane resistance", "ArcaneResist", "Arcane resistance.  This stat does not appear on items that give all elemental resistances."},
	{"Frost resistance", "FrostResist", "Frost resistance.  This stat does not appear on items that give all elemental resistances."},
	{"Health per 5", "Hp5", "Health regeneration per 5 seconds.  Generally only appears on enchantments."},
	
	{"Weapon types"},
	{"Axe", "IsAxe", "Points to be assigned if the item is an axe (of any kind)."},
	{"Bow", "IsBow", "Points to be assigned if the item is a bow, or a stack of arrows."},
	{"Crossbow", "IsCrossbow", "Points to be assigned if the item is a crossbow."},
	{"Dagger", "IsDagger", "Points to be assigned if the item is a dagger."},
	{"Fist weapon", "IsFist", "Points to be assigned if the item is a fist weapon (of any kind)."},
	{"Gun", "IsGun", "Points to be assigned if the item is a gun, or a stack of bullets."},
	{"Mace", "IsMace", "Points to be assigned if the item is a mace (of any kind)."},
	{"Polearm", "IsPolearm", "Points to be assigned if the item is a polearm."},
	{"Staff", "IsStaff", "Points to be assigned if the item is a staff."},
	{"Sword", "IsSword", "Points to be assigned if the item is a sword."},
	{"Thrown", "IsThrown", "Points to be assigned if the item is a thrown weapon."},
	{"Wand", "IsWand", "Points to be assigned if the item is a wand."},

	{"Special weapon stats"},
	{"Melee: DPS", "MeleeDps", "Weapon damage per second, only for melee weapons."},
	{"Melee: min damage", "MeleeMinDamage", "Weapon minimum damage, only for melee weapons."},
	{"Melee: max damage", "MeleeMaxDamage", "Weapon maximum damage, only for melee weapons."},
	{"Melee: speed", "MeleeSpeed", "Weapon speed, only for melee weapons."},
	{"Ranged: DPS", "RangedDps", "Weapon damage per second, only for ranged weapons."},
	{"Ranged: min damage", "RangedMinDamage", "Weapon minimum damage, only for ranged weapons."},
	{"Ranged: max damage", "RangedMaxDamage", "Weapon maximum damage, only for ranged weapons."},
	{"Ranged: speed", "RangedSpeed", "Weapon speed, only for ranged weapons."},
	{"MH: DPS", "MainHandDps", "Weapon damage per second, only for main hand weapons."},
	{"MH: min damage", "MainHandMinDamage", "Weapon minimum damage, only for main hand weapons."},
	{"MH: max damage", "MainHandMaxDamage", "Weapon maximum damage, only for main hand weapons."},
	{"MH: speed", "MainHandSpeed", "Weapon speed, only for main hand weapons."},
	{"OH: DPS", "OffHandDps", "Weapon damage per second, only for off-hand weapons."},
	{"OH: min damage", "OffHandMinDamage", "Weapon minimum damage, only for off-hand weapons."},
	{"OH: max damage", "OffHandMaxDamage", "Weapon maximum damage, only for off-hand weapons."},
	{"OH: speed", "OffHandSpeed", "Weapon speed, only for off-hand weapons."},
	{"1H: DPS", "OneHandDps", "Weapon damage per second, only for weapons marked One Hand, not including Main Hand or Off Hand weapons."},
	{"1H: min damage", "OneHandMinDamage", "Weapon minimum damage, only for weapons marked One Hand, not including Main Hand or Off Hand weapons."},
	{"1H: max damage", "OneHandMaxDamage", "Weapon maximum damage, only for weapons marked One Hand, not including Main Hand or Off Hand weapons."},
	{"1H: speed", "OneHandSpeed", "Weapon speed, only for weapons marked One Hand, not including Main Hand or Off Hand weapons."},
	{"2H: DPS", "TwoHandDps", "Weapon damage per second, only for two-handed weapons."},
	{"2H: min damage", "TwoHandMinDamage", "Weapon minimum damage, only for two-handed weapons."},
	{"2H: max damage", "TwoHandMaxDamage", "Weapon maximum damage, only for two-handed weapons."},
	{"2H: speed", "TwoHandSpeed", "Weapon speed, only for two-handed weapons."},
	{"Speed baseline", "SpeedBaseline", "Not an actual stat, per se.  This number is subtracted from the Speed stat before multiplying it by the scale value.", "|cffffffffSpeed baseline|r is:"},
	
}

-- The 1-based indes of the stat header before which socket bonus information should be added.
PawnUIStats_SocketBonusBefore = 14


------------------------------------------------------------
-- UI strings
------------------------------------------------------------

-- Translation note: All of the strings ending in _Text should be translated; those will show up in the UI.  The strings ending
-- in _Tooltip are only used in tooltips, and can be safely left out.  If you don't want to translate them right now, delete those
-- lines, and Pawn won't show tooltips for those UI elements.


-- Configuration UI
PawnUIFrame_CloseButton_Text = "Close"

-- Configuration UI, Scales tab
PawnUIFrame_ScalesTab_Text = "Scales"

PawnUIFrame_WelcomeLabel_Text = "Choose which scale you want to modify.  You can also import a scale tag that someone else created, or create your own scale, starting from scratch or from a set of defaults."
PawnUIFrame_AddScaleLabel_Text = "Add a scale:"
PawnUIFrame_CurrentScaleDropDown_Label_Text = "Current scale:"
PawnUIFrame_CurrentScaleDropDown_Tooltip = "Select a new scale to work with."

PawnUIFrame_NewScaleButton_Text = "New empty"
PawnUIFrame_NewScaleButton_Tooltip = "Create a new scale from scratch, with no starting values for any stats."
PawnUIFrame_NewScaleFromDefaultsButton_Text = "New default"
PawnUIFrame_NewScaleFromDefaultsButton_Tooltip = "Create a new scale by starting with a copy of the default scale, which has starting values for most stats."
PawnUIFrame_CopyScaleButton_Text = "Copy"
PawnUIFrame_CopyScaleButton_Tooltip = "Create a new scale by starting with a copy of the currently selected scale."
PawnUIFrame_ImportScaleButton_Text = "Import"
PawnUIFrame_ImportScaleButton_Tooltip = "Import a scale by pasting a Pawn scale tag."
PawnUIFrame_RenameScaleButton_Text = "Rename"
PawnUIFrame_RenameScaleButton_Tooltip = "Rename this scale."
PawnUIFrame_DeleteScaleButton_Text = "Delete"
PawnUIFrame_DeleteScaleButton_Tooltip = "Delete this scale.\n\nThis command cannot be undone!"
PawnUIFrame_ExportScaleButton_Text = "Export"
PawnUIFrame_ExportScaleButton_Tooltip = "Export this scale to a Pawn scale tag that you can copy and share with others."

PawnUIFrame_ClearValueButton_Text = "Remove"
PawnUIFrame_ClearValueButton_Tooltip = "Remove this stat from the scale."

PawnUIFrame_ScaleSocketOptionsHeaderLabel_Text = "When calculating a value for this scale:"
PawnUIFrame_ScaleSocketBestRadio_Text = "Use the best gems for each socket"
PawnUIFrame_ScaleSocketBestRadio_Tooltip = "When calculating a value for this scale, Pawn will use the colors of gems that will maximize the total value of the item, even if that means putting the \"wrong\" color gem in a socket and ignoring the socket bonus."
PawnUIFrame_ScaleSocketCorrectRadio_Text = "Use the correct gem color for each socket"
PawnUIFrame_ScaleSocketCorrectRadio_Tooltip = "When calculating a value for this scale, Pawn will use the correct colors of gems for each socket, so the item will qualify for the socket bonus."

PawnUIFrame_ScaleColorSwatch_Label_Text = "Change color"
PawnUIFrame_ScaleColorSwatch_Tooltip = "Change the color that this scale's name and value appear in on item tooltips."
PawnUIFrame_ShowScaleCheck_Label_Text = "Show this scale in tooltips"
PawnUIFrame_ShowScaleCheck_Tooltip = "Uncheck this option to keep it from showing up in your tooltips, without having to actually delete it."

-- Configuration UI, Compare tab
PawnUIFrame_CompareTab_Text = "Compare"

PawnUIFrame_VersusHeader_Text = "—vs.—" -- Short for "versus."  Appears between the names of the two items.
PawnUIFrame_VersusHeader_NoItem = "(no item)" -- Text displayed next to empty item slots.

PawnUIFrame_CompareMissingItemInfo_Text = "Drop items in the boxes in the upper-left and upper-right corners to compare their stats according to the scale listed below.\n\nGenerally, you'll use the left slot for your current item, and the right slot for a new item.  Once an item is in the right slot, shortcuts to your equivalent currently equipped items will appear in the lower-left."

PawnUIFrame_CompareSocketBonusHeader_Text = "Socket bonus" -- Heading that appears above the item socket bonuses.

PawnUIFrame_CompareOtherInfoHeader_Text = "Other" -- Heading that appears above the item's level and the following stats:
PawnUIFrame_CompareAsterisk = "Other stats " .. VgerCore.Color.Blue .. "(*)"
PawnUIFrame_CompareAsterisk_Yes = "Yes" -- Appears on the Compare tab when an item has unrecognized stats (*).

PawnUIFrame_CurrentCompareScaleDropDown_Label_Text = "Comparison scale"
PawnUIFrame_CurrentCompareScaleDropDown_Tooltip = "Select a new scale to use when comparing the two items."

PawnUIFrame_ClearItemsButton_Label = "Clear"
PawnUIFrame_ClearItemsButton_Tooltip = "Remove both comparison items."

PawnUIFrame_CompareSwapButton_Text = "< Swap >"
PawnUIFrame_CompareSwapButton_Tooltip = "Swap the item on the left side with the one on the right."

-- Configuration UI, Options tab
PawnUIFrame_OptionsTab_Text = "Options"
PawnUIFrame_OptionsHeaderLabel_Text = "Configure Pawn the way you like it.  Changes will take effect immediately."

PawnUIFrame_TooltipOptionsHeaderLabel_Text = "Tooltip options"
PawnUIFrame_ShowItemLevelsCheck_Text = "Show item levels"
PawnUIFrame_ShowItemLevelsCheck_Tooltip = "Enable this option to have Pawn display the item level of every item you come across.\n\nEvery item in World of Warcraft has a hidden level that is used to determine how many stats it can have.  In general, an item of the same type (helmet, cloak) and quality (green, blue) and a higher level will have more, or at least better, stats."
PawnUIFrame_ShowItemIDsCheck_Text = "Show item IDs"
PawnUIFrame_ShowItemIDsCheck_Tooltip = "Enable this option to have Pawn display the item ID of every item you come across, as well as the IDs of all enchantments and gems.\n\nEvery item in World of Warcraft has an ID number associated with it.  This information is generally only useful to mod authors."
PawnUIFrame_ShowIconsCheck_Text = "Show inventory icons"
PawnUIFrame_ShowIconsCheck_Tooltip = "Enable this option to show inventory icons next to item link windows."
PawnUIFrame_ShowExtraSpaceCheck_Text = "Add a blank line before values"
PawnUIFrame_ShowExtraSpaceCheck_Tooltip = "Keep your item tooltips extra tidy by enabling this option, which adds a blank line before the Pawn values."
PawnUIFrame_AlignRightCheck_Text = "Align values to right edge of tooltip"
PawnUIFrame_AlignRightCheck_Tooltip = "Enable this option to align your Pawn values (as well as item levels and item IDs) to the right edge of the tooltip instead of the left."
PawnUIFrame_AsterisksHeaderLabel_Text = "Show (*) on unrecognized stats:"
PawnUIFrame_AsterisksAutoRadio_Text = "Auto (not on items with no stats)"
PawnUIFrame_AsterisksAutoRadio_Tooltip = "Don't add the (*) on items that don't have any stats, such as the Hearthstone.  This is the default."
PawnUIFrame_AsterisksAutoNoTextRadio_Text = "Auto, but don't add the warning text"
PawnUIFrame_AsterisksAutoNoTextRadio_Tooltip = "Same as auto, but also don't print the 'Pawn gave no value to some stats' warning message."
PawnUIFrame_AsterisksOnRadio_Text = "On for all items"
PawnUIFrame_AsterisksOnRadio_Tooltip = "Always display the (*) and warning message, even for things like Hearthstone."
PawnUIFrame_AsterisksOffRadio_Text = "Never"
PawnUIFrame_AsterisksOffRadio_Tooltip = "Never display the (*) or warning message."

PawnUIFrame_CalculationOptionsHeaderLabel_Text = "Calculation options"
PawnUIFrame_DigitsBox_Label_Text = "Digits of precision:"
PawnUIFrame_DigitsBox_Tooltip = "Specify how many digits of precision you want in your Pawn values, 0-9.  0 rounds all Pawn values to whole numbers ('25').  1 is the default ('24.5')."
PawnUIFrame_UnenchantedValuesCheck_Text = "Calculate unenchanted values"
PawnUIFrame_UnenchantedValuesCheck_Tooltip = "Enable this option to have Pawn calculate values for unenchanted versions of items.  An unenchanted item has no enchantments or gems, as if it just dropped or was bought from the vendor.\n\nIf enchanted values are also enabled, the unenchanted value will be shown second, in parentheses.  If both values are the same (such as if the item is not enchanted), only one number is shown."
PawnUIFrame_EnchantedValuesCheck_Text = "Calculate enchanted values"
PawnUIFrame_EnchantedValuesCheck_Tooltip = "Enable this option to have Pawn calculate values for items exactly as they are, including all enchantments and gems if present.\n\nIf unenchanted values are also enabled, the enchanted value will be shown first."
PawnUIFrame_NormalizeValuesCheck_Text = "Normalize values (like Lootzor)"
PawnUIFrame_NormalizeValuesCheck_Tooltip = "Enable this option to divide all Pawn values by the sum of all numbers in your scale, like Lootzor does.\n\nFor more information on this setting, see the readme file."
PawnUIFrame_DebugCheck_Text = "Show debug info"
PawnUIFrame_DebugCheck_Tooltip = "If you're not sure how Pawn is calculating the values for a particular item, enable this option to make Pawn spam all sorts of 'useful' data to the chat console whenever you hover over an item.  This information includes which stats Pawn thinks the item has, which parts of the item Pawn doesn't understand, and how it took each one into account for each of your scales.\n\nThis option will fill up your chat log quickly, so you'll want to turn it off once you're finished investigating.\n\nShortcuts:\n/pawn debug on\n/pawn debug off"

PawnUIFrame_OtherOptionsHeaderLabel_Text = "Other options"
PawnUIFrame_ButtonPositionHeaderLabel_Text = "Show the Pawn button:"
PawnUIFrame_ButtonRightRadio_Text = "On the right"
PawnUIFrame_ButtonRightRadio_Tooltip = "Show the Pawn button in the lower-right corner of the Character Info panel."
PawnUIFrame_ButtonLeftRadio_Text = "On the left"
PawnUIFrame_ButtonLeftRadio_Tooltip = "Show the Pawn button in the lower-left corner of the Character Info panel."
PawnUIFrame_ButtonOffRadio_Text = "Hide it"
PawnUIFrame_ButtonOffRadio_Tooltip = "Don't show the Pawn button on the Character Info panel."

-- Configuration UI, About tab
PawnUIFrame_AboutTab_Text = "About"
PawnUIFrame_AboutHeaderLabel_Text = "by Vger-Azjol-Nerub"
PawnUIFrame_AboutVersionLabel_Text = "Version %s"
PawnUIFrame_AboutTranslationLabel_Text = "Official English translation" -- Translators: credit yourself here... "Klingon translation by Stovokor"
PawnUIFrame_WebsiteLabel_Text = "For other mods by Vger, visit vgermods.com."
PawnUIFrame_ReadmeLabel_Text = "Don't be a n00b!  See the readme file that comes with Pawn for step-by-step instructions on how to get the most out of Pawn."

-- Configuration UI, Help tab
PawnUIFrame_HelpTab_Text = "Getting started"
PawnUIFrame_GettingStartedLabel_Text =
	VgerCore.Color.White ..
	"Welcome to Pawn!  " ..
	VgerCore.Color.Salmon .. 
	"To get the most out of Pawn, you should take a look at the Readme file.  (Seriously.)  " ..
	VgerCore.Color.White ..
	"But, here are some tips to get you started.\n\n" ..
	VgerCore.Color.Blue ..
	"Pawn values\n" ..
	VgerCore.Color.White ..
	"Pawn calculates Pawn values for items that you can use to quickly determine which of a pair of items is \"better\" according to rules you set up.  These values show up almost everywhere you see an item, at the bottom of the tooltip.\n\n" ..
	VgerCore.Color.Blue ..
	"Scales\n" ..
	VgerCore.Color.White ..
	"A scale is a list of item stats, with a point value for each stat.  For example, you might think that Stamina is worth 1 point and Agility is worth 2 points.  You can have any number of scales, each one tailored for different situations -- you could have one scale for PVP and one for PVE, and your PVP scale could value stamina and resilience more than your PVE scale.  It's up to you to decide what stats are worth.  For each scale you have, Pawn will add one more number to your item tooltips.\n\n" ..
	VgerCore.Color.Blue ..
	"Changing and adding scales\n" ..
	VgerCore.Color.White ..
	"You'll want to customize your Pawn scales on the Scales tab of this window.  You start out with one scale that you can work with right away, but you can also add more -- just find the stat you want to change, and type a new value.  In addition, you can import \"scale tags\" that you copy and paste from forums and other websites.\n\n" ..
	VgerCore.Color.Blue ..
	"Learning more\n" ..
	VgerCore.Color.White ..
	"There's a lot more to learn about Pawn after you've learned the basics, so you'll want to skim through the readme file for more information on Pawn options, sharing Pawn scales with other people, and how Pawn takes things like enchantments and gems into account when determining item values.\n\n" ..
	"Have fun!"

-- Inventory button
PawnUI_InventoryPawnButton_Tooltip = "Click to show the Pawn UI."
PawnUI_InventoryPawnButton_Subheader = "Totals for all equipped items:"

-- Interface Options page
PawnInterfaceOptionsFrame_OptionsHeaderLabel_Text = "Pawn options are found in the Pawn UI."
PawnInterfaceOptionsFrame_OptionsSubHeaderLabel_Text = "Click the Pawn button to go there.  You can also open Pawn from your inventory page, or by binding a key to it."

-- Bindings UI
BINDING_HEADER_PAWN = "Pawn"
BINDING_NAME_PAWN_TOGGLE_UI = "Toggle Pawn UI" -- Show or hide the Pawn UI
PAWN_TOGGLE_UI_DEFAULT_KEY = "P" -- Default key to assign to this command
BINDING_NAME_PAWN_COMPARE_LEFT = "Compare item (left)" -- Set the currently hovered item to be the left-side Compare item
PAWN_COMPARE_LEFT_DEFAULT_KEY = "[" -- Default key to assign to this command
BINDING_NAME_PAWN_COMPARE_RIGHT = "Compare item (right)" -- Set the currently hovered item to be the right-side Compare item
PAWN_COMPARE_RIGHT_DEFAULT_KEY = "]" -- Default key to assign to this command


PawnLocal =
{

	-- General messages
	["NeedNewerVgerCoreMessage"] = "Pawn needs a newer version of VgerCore.  Please use the version of VgerCore that came with Pawn.",
	
	-- Scale management dialog messages
	["NewScaleEnterName"] = "Enter a name for your scale:",
	["NewScaleNoQuotes"] = "A scale can't have \" in its name.  Enter a name for your scale:",
	["NewScaleDuplicateName"] = "A scale with that name already exists.  Enter a name for your scale:",
	
	["CopyScaleEnterName"] = "Enter a name for your new scale, a copy of %s:", -- %s is the name of the existing scale
	["RenameScaleEnterName"] = "Enter a new name for %s:", -- %s is the old name of the scale
	["DeleteScaleConfirmation"] = "Are you sure you want to delete %s? This can't be undone. Type \"%s\" to confirm:", -- First %s is the name of the scale, second %s is DELETE
	
	["ImportScaleMessage"] = "Press Ctrl+V to paste a scale tag that you've copied from another source here:",
	["ImportScaleTagErrorMessage"] = "Pawn doesn't understand that scale tag.  Did you copy the whole tag?  Try copying and pasting again:",
	
	["ExportScaleMessage"] = "Press Ctrl+C to copy the following scale tag for |cffffffff%s|r, and then press Ctrl+V to paste it later.", -- %s is name of scale
	
	-- Configuration UI, Scales tab
	["NoStatDescription"] = "Choose a stat from the list on the left to give it a value.",
	["NoScalesDescription"] = "To begin, import a scale or start a new one.",
	["StatNameText"] = "1 |cffffffff%s|r is worth:", -- |cffffffff%s|r is the name of the stat, in white
	
	-- Generic string dialogs
	["OKButton"] = "OK",
	["CancelButton"] = "Cancel",
	["CloseButton"] = "Close",
	
	-- Debug messages
	["UnenchantedStatsHeader"] = "(Unenchanted)",
	["FailedToGetItemLinkMessage"] = "   Failed to get item link from tooltip.  This may be due to a mod conflict.",
	["FailedToGetUnenchantedItemMessage"] = "   Failed to get unenchanted values.  This may be due to a mod conflict.",
	["DidntUnderstandMessage"] = "   (*) Didn't understand \"%s\".",
	["FoundStatMessage"] = "   %d %s", -- 25 Stamina
	
	["ValueCalculationMessage"] = "   %g %s x %g each = %g", -- 25 Stamina x 1 each = 25
	["NoValueMessage"] = "   %s has no value.", -- Stamina has no value.
	["SocketBonusValueCalculationMessage"] = "   -- Socket bonus would be worth:",
	["MissocketWorthwhileMessage"] = "   -- But it's better to use only %s gems:", -- Better to use only Red/Blue gems:
	["NormalizationMessage"] = "   ---- Normalized by dividing by %g", -- Normalized by dividing by 3.5
	["TotalValueMessage"] = "   ---- Total: %g", -- Total: 25
	
	-- Tooltip annotations
	["ItemIDTooltipLine"] = "Item ID",
	["ItemLevelTooltipLine"] = "Item level",
	["AsteriskTooltipLine"] = "* Pawn gave no value to some stats.",
	
	-- Slash commands
	["DebugOnCommand"] = "debug on",
	["DebugOffCommand"] = "debug off",
	
	["Usage"] = [[
Pawn by Vger-Azjol-Nerub
www.vgermods.com
 
/pawn -- show or hide the Pawn UI
/pawn debug [ on | off ] -- spam debug messages to the console
 
For more information on customizing Pawn, please see the help file (Readme.htm) that comes with the mod.
]],

}


------------------------------------------------------------
-- Tooltip parsing expressions
------------------------------------------------------------

-- Turns a game constant into a regular expression.
function PawnGameConstant(Text)
	return "^" .. PawnGameConstantUnwrapped(Text) .. "$"
end
function PawnGameConstantUnwrapped(Text)
	return string.gsub(string.gsub(Text, "%%", "%%%%"), "%-", "%%-")
end

-- These strings indicate that a given line might contain multiple stats, such as complex enchantments
-- (ZG, AQ) and gems.  These are sorted in priority order.  If a string earlier in the table is present, any
-- string later in the table can be ignored.
PawnSeparators =
{
	", ",
	"/",
	" & ",
	" and ",
}

-- This string indicates that whatever stats follow it on the same line is the item's socket bonus.
PawnSocketBonusPrefix = "Socket Bonus: "

-- Lines that match any of the following patterns will cause all further tooltip parsing to stop.
PawnKillLines =
{
	"^ \n$", -- The blank line before set items before WoW 2.3
	" %(%d+/%d+%)$", -- The (1/8) on set items for all versions of WoW
	"^|cff00e0ffDropped By", -- Mod compatibility: MobInfo-2 (should match mifontLightBlue .. MI_TXT_DROPPED_BY)
}

-- Lines that begin with any of the following strings will not be searched for separator strings.
PawnSeparatorIgnorePrefixes =
{
	'"', -- double quote
	"Equip:",
	"Use:",
	"Chance on hit:",
}

-- Items that begin with any of the following strings will never be parsed.
PawnIgnoreNames =
{
	"Design:",
	"Formula:",
	"Manual:",
	"Pattern:",
	"Plans:",
	"Recipe:",
	"Schematic:",
}

-- This is a list of regular expression substitutions that Pawn performs to normalize stat names before running
-- them through the normal gauntlet of expressions.
PawnNormalizationRegexes =
{
	{"^([%w%s%.]+) %+(%d+)$", "+%2 %1"}, -- "Stamina +5" --> "+5 Stamina"
	{"^(.-)|r.*", "%1"}, -- For removing meta gem requirements
}

-- These regular expressions are used to parse item tooltips.
-- The first string is the regular expression to match.  Stat values should be denoted with "(%d+)".
-- Subsequent strings follow this pattern: Stat, Number, Source
-- Stat is the name of a statistic.
-- Number is either the amount of that stat to include, or the 1-based index into the matches array produced by the regex.
-- If it's an index, it can also be negative to mean that the stat should be subtracted instead of added.  If nil, defaults to 1.
-- Source is either PawnMultipleStatsFixed if Number is the amount of the stat, or PawnMultipleStatsExtract or nil if Number is the matches array index.
-- Note that certain strings don't need to be translated: for example, the game defines
-- ITEM_BIND_ON_PICKUP to be "Binds when picked up" in English, and the correct string
-- in other languages automatically.
PawnMultipleStatsFixed = "_MultipleFixed"
PawnMultipleStatsExtract = "_MultipleExtract"
PawnRegexes =
{
	-- ========================================
	-- Strings that are ignored for compatibility with other mods
	-- ========================================
	{"^Used by outfits:"}, -- Mod compatibility: Outfitter
	
	-- ========================================
	-- Common strings that are ignored (rare ones are at the bottom of the file)
	-- ========================================
	{PawnGameConstant(ITEM_UNSELLABLE)}, -- No sell price
	{PawnGameConstant(ITEM_SOULBOUND)}, -- Soulbound
	{PawnGameConstant(ITEM_BIND_ON_EQUIP)}, -- Binds when equipped
	{PawnGameConstant(ITEM_BIND_ON_PICKUP)}, -- Binds when picked up
	{PawnGameConstant(ITEM_BIND_ON_USE)}, -- Binds when used
	{"^Binds to account$"}, -- Binds to account (Polished Spaulders of Valor) *** Should be {PawnGameConstant(ITEM_BIND_TO_ACCOUNT)}, in WoW 3.0
	{"^" .. PawnGameConstantUnwrapped(ITEM_UNIQUE)}, -- Unique; leave off the $ for Unique(20)
	{"^" .. PawnGameConstantUnwrapped(ITEM_BIND_QUEST)}, -- Leave off the $ for MonkeyQuest mod compatibility
	{PawnGameConstant(ITEM_STARTS_QUEST)}, -- This Item Begins a Quest
	{PawnGameConstant(ITEM_CONJURED)}, -- Conjured Item
	{PawnGameConstant(ITEM_PROSPECTABLE)}, -- Prospectable
	{"^Will receive.*$"}, -- Appears in the trade window when an item is about to be enchanted ("Will receive +8 Stamina")
	{PawnGameConstant(ITEM_ENCHANT_DISCLAIMER)}, -- Item will not be traded!
	{"^.+ Charges?$"}, -- Brilliant Mana Oil
	{PawnGameConstant(LOCKED)}, -- Locked
	{"^Encrypted$"}, -- Encrypted (Floral Foundations) -- *** Should be {PawnGameConstant(ENCRYPTED)}, in WoW 3.0
	{PawnGameConstant(ITEM_SPELL_KNOWN)}, -- Already Known
	{PawnGameConstant(INVTYPE_HEAD)}, -- Head
	{PawnGameConstant(INVTYPE_NECK)}, -- Neck
	{PawnGameConstant(INVTYPE_SHOULDER)}, -- Shoulder
	{PawnGameConstant(INVTYPE_CLOAK)}, -- Back
	{PawnGameConstant(INVTYPE_ROBE)}, -- Chest
	{PawnGameConstant(INVTYPE_BODY)}, -- Shirt
	{PawnGameConstant(INVTYPE_TABARD)}, -- Tabard
	{PawnGameConstant(INVTYPE_WRIST)}, -- Wrist
	{PawnGameConstant(INVTYPE_HAND)}, -- Hands
	{PawnGameConstant(INVTYPE_WAIST)}, -- Waist
	{PawnGameConstant(INVTYPE_FEET)}, -- Feet
	{PawnGameConstant(INVTYPE_LEGS)}, -- Legs
	{PawnGameConstant(INVTYPE_FINGER)}, -- Finger
	{PawnGameConstant(INVTYPE_TRINKET)}, -- Trinket
	{"^Major Glyph$"}, -- Major Glyph *** Should be {PawnGameConstant(MAJOR_GLYPH)}, in WoW 3.0
	{"^Minor Glyph$"}, -- Minor Glyph *** Should be {PawnGameConstant(MINOR_GLYPH)}, in WoW 3.0
	{"^Totem$"},
	{"^Relic$"},
	{"^Idol$"},
	{"^Libram$"},
	{"^Mount$"}, -- Cenarion War Hippogryph
	{"^Classes:"},
	{"^Races:"},
	{"^Requires"},
	{"^Durability"},
	{"^Duration:"},
	{"^Cooldown remaining:"},
	{"<.+>"}, -- Made by, Right-click to read, etc. (No ^$; can be prefixed by a color)
	{"^Written by "},
	{'^"'}, -- Flavor text
	{"|cff%x%x%x%x%x%xRequires"}, -- Meta gem requirements
	{"^%d+ Slot .+$"}, -- Bags of all kinds
	{"^.+%(%d+ sec%)$"}, -- Temporary item buff
	{"^.+%(%d+ min%)$"}, -- Temporary item buff
	
	-- ========================================
	-- Strings that represent statistics that Pawn cares about
	-- ========================================
	{PawnGameConstant(INVTYPE_RANGED), "IsRanged", 1, PawnMultipleStatsFixed}, -- Ranged
	{"^Projectile$", "IsRanged", 1, PawnMultipleStatsFixed}, -- Projectile
	{PawnGameConstant(INVTYPE_THROWN), "IsRanged", 1, PawnMultipleStatsFixed}, -- Thrown
	{PawnGameConstant(INVTYPE_WEAPON), "IsOneHand", 1, PawnMultipleStatsFixed}, -- One-Hand
	{PawnGameConstant(INVTYPE_2HWEAPON), "IsTwoHand", 1, PawnMultipleStatsFixed}, -- Two-Hand
	{PawnGameConstant(INVTYPE_WEAPONMAINHAND), "IsMainHand", 1, PawnMultipleStatsFixed}, -- Main Hand
	{PawnGameConstant(INVTYPE_WEAPONOFFHAND), "IsOffHand", 1, PawnMultipleStatsFixed}, -- Off Hand
	{PawnGameConstant(INVTYPE_HOLDABLE)}, -- Held In Off-Hand; no Pawn stat for this
	{"^(%d-) %- (%d-) Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Standard weapon
	{"^%+?(%d-) %- (%d-) Fire Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) Shadow Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) Nature Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand, Thunderfury
	{"^%+?(%d-) %- (%d-) Arcane Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) Frost Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) Holy Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand, Ashbringer
	{"^%+?(%d-) Weapon Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Weapon enchantments
	{"^Equip: %+?(%d-) Weapon Damage%.$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Braided Eternium Chain
	{"^%+?(%d-) Damage$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Weapons with no damage range: Crossbow of the Albatross
	{"^Scope %(%+(%d-) Damage%)$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Ranged weapon scopes
	{"^%+?(%d+) All Stats$", "Strength", 1, PawnMultipleStatsExtract, "Agility", 1, PawnMultipleStatsExtract, "Stamina", 1, PawnMultipleStatsExtract, "Intellect", 1, PawnMultipleStatsExtract, "Spirit", 1, PawnMultipleStatsExtract},
	{"^%+?(%d+) to All Stats$", "Strength", 1, PawnMultipleStatsExtract, "Agility", 1, PawnMultipleStatsExtract, "Stamina", 1, PawnMultipleStatsExtract, "Intellect", 1, PawnMultipleStatsExtract, "Spirit", 1, PawnMultipleStatsExtract}, -- Enchanted Pearl, Enchanted Tear
	{"^%+?(%-?%d+) Strength$", "Strength"},
	{"^Potency$", "Strength", 20, PawnMultipleStatsFixed}, -- weapon enchantment (untested)
	{"^%+?(%-?%d+) Agility$", "Agility"},
	{"^%+?(%-?%d+) Stamina$", "Stamina"},
	{"^%+?(%-?%d+) Intellect$", "Intellect"}, -- negative Intellect: Kreeg's Mug
	{"^%+?(%-?%d+) Spirit$", "Spirit"},
	{"^Boar's Speed$", "Stamina", 9, PawnMultipleStatsFixed}, -- Enchantment; has additional effects
	{"^Cat's Swiftness$", "Agility", 6, PawnMultipleStatsFixed}, -- Enchantment; has additional effects
	{"^Tuskar's Vitality$", "Stamina", 15, PawnMultipleStatsFixed}, -- Enchantment; has additional effects --- *** Typo as of the beta build where premades first appeared
	{"^%+?(%d+) Block$", "BlockValue"},
	{"^%+(%d+) Block Value$", "BlockValue"}, -- part of complex warrior helm enchantment
	{"^Equip: Increases the block value of your shield by (%d+)%.$", "BlockValue"},
	{"^Equip: Increases your block rating by (%d+)%.$", "BlockRating"}, -- Waistband of Wrath
	{"^Equip: Increases your shield block rating by (%d+)%.$", "BlockRating"}, -- Warbringer Chestguard
	{"^%+?(%d+) Block Rating$", "BlockRating"}, -- Northman's Shield of Blocking
	{"^%+?(%d+) Shield Block Rating$", "BlockRating"}, -- enchantment
	{"^Equip: Increases defense rating by (%d+)%.$", "DefenseRating"}, -- Bulwark of Kings
	{"^Defense Rating %+(%d)%$", "DefenseRating"},
	{"^%+?(%d+) Defense$", "DefenseRating"}, -- compound paladin enchantment
	{"^%+?(%d+) Defense Rating$", "DefenseRating"}, -- Thick Amber; Bloodscale Legguards of Defense
	{"^%+?(%d+) Dodge Rating$", "DodgeRating"}, -- Arctic Ring of Eluding
	{"^Equip: Increases your dodge rating by (%d+)%.$", "DodgeRating"}, -- Frostwolf Insignia Rank 6
	{"^Equip: Increases your parry rating by (%d+)%.$", "ParryRating"}, -- Draconic Avenger
	{"^%+?(%d+) Parry Rating$", "ParryRating"},
	{"^%(([%d%.,]+) damage per second%)$"}, -- Ignore this; DPS is calculated manually
	{"^Adds ([%d%.,]+) damage per second$", "Dps"},
	{"^Fiery Weapon$", "Dps", 4, PawnMultipleStatsFixed}, -- weapon enchantment, 
	{"^Equip: Increases your expertise rating by (%d+)%.$", "ExpertiseRating"}, -- Earthwarden
	{"^%+?(%d+) Expertise Rating$", "ExpertiseRating"}, -- Guardian's Shadow Crystal
	{"^Equip: Improves critical strike rating by (%d+)%.$", "CritRating"},
	{"^Equip: Increases your critical strike rating by (%d+)%.$", "CritRating"},
	{"^%+?(%d+) Crit Rating$", "CritRating"}, -- Mantle of Malorne
	{"^%+?(%d+) Critical Rating$", "CritRating"}, -- Enscribed Fire Opal (after normalization)
	{"^%+?(%d+) Critical Strike Rating$", "CritRating"},
	{"^Scope %(%+(%d+) Critical Strike Rating%)$", "CritRating"},
	{"^Equip: Increases your hit rating by (%d+)%.$", "HitRating"}, -- Don Julio's Band
	{"^Equip: Improves hit rating by (%d+)%.$", "HitRating"},
	{"^%+?(%d+) Hit Rating$", "HitRating"}, -- 3% hit scope
	{"^Surefooted$", "HitRating", 10, PawnMultipleStatsFixed}, -- Enchantment (untested); has additional effects
	{"^Equip: Increases your spell critical strike rating by (%d+)%.$", "SpellCritRating"}, -- (*** obsolete in WoW 3.0)
	{"^Equip: Improves spell critical strike rating by (%d+)%.$", "SpellCritRating"}, -- Explorer's Boots (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Crit Rating$", "SpellCritRating"}, -- Potent Ornate Topaz (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Critical$", "SpellCritRating"}, -- Chaotic Skyfire Diamond (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Critical Rating$", "SpellCritRating"}, -- Gleaming Amber (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Critical Strike Rating$", "SpellCritRating"}, -- Gleaming Ornate Dawnstone (*** obsolete in WoW 3.0)
	{"^Equip: Increases your spell hit rating by (%d+)%.$", "SpellHitRating"}, -- Zanzil's Band (*** obsolete in WoW 3.0)
	{"^Equip: Improves spell hit rating by (%d+)%.$", "SpellHitRating"}, -- High Warlord's Spellblade (Level 70) (*** obsolete in WoW 3.0)
	{"^Equip: Improves your spell hit rating by (%d+)%.$", "SpellHitRating"}, -- unused?  both increases and improves? (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Hit$", "SpellHitRating"}, -- Sha'tar and ZG head and leg enchantments? (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Hit Rating$", "SpellHitRating"}, -- (*** obsolete in WoW 3.0)
	{"^Equip: Improves your resilience rating by (%d+)%.$", "ResilienceRating"},
	{"^%+?(%d+) Resilience Rating$", "ResilienceRating"},
	{"^%+?(%d+) Resilience$", "ResilienceRating"}, -- Sublime Mystic Dawnstone
	{"^Counterweight %(%+(%d+) Haste Rating%)", "HasteRating"},
	{"^Equip: Improves haste rating by (%d+)%.$", "HasteRating"}, -- Swiftsteel Shoulders
	{"^%+?(%d+) Haste Rating$", "HasteRating"}, -- Leggings of the Betrayed
	{"^%+?(%d+) Spell Haste Rating$", "SpellHasteRating"}, -- Reckless Noble Topaz (*** obsolete in WoW 3.0)
	{"^Equip: Improves spell haste rating by (%d+)%.$", "SpellHasteRating"}, -- Zhar'doom, Greatstaff of the Devourer (*** obsolete in WoW 3.0)
	{"^Equip: Increases attack power by (%d+)%.$", "Ap"},
	{"^%+?(%d+) Attack Power$", "Ap"},
	{"^Equip: Increases attack power by (%d+) in Cat, Bear, Dire Bear, and Moonkin forms only%.$", "FeralAp"}, -- Mace of Unending Life
	{"^%+?(%d+) Ranged Attack Power$", "Rap"},
	{"^Equip: Increases ranged attack power by (%d+)%.$", "Rap"},
	{"^Savagery$", "Ap", 70, PawnMultipleStatsFixed}, -- weapon enchantment
	{"^Equip: Restores (%d+) mana per 5 sec%.$", "Mp5"},
	{"^%+?(%d+) Mana Regen$", "Mp5"}, -- Shoulder enchantment, Scryers?
	{"^Mana Regen (%d+) per 5 sec%.$", "Mp5"},
	{"^%+?(%d+) [mM]ana [pP]er 5 [sS]ec%.?$", "Mp5"}, 
	{"^%+?(%d+) [mM]ana [eE]very 5 [sS]ec%.?$", "Mp5"}, 
	{"^%+?(%d+) [mM]ana [pP]er 5 [sS]econds$", "Mp5"}, -- Royal Shadow Draenite
	{"^%+?(%d+) [mM]ana every 5 [sS]ec%.$", "Mp5"},
	{"^%+?(%d+) [mM]ana every 5 seconds$", "Mp5"},
	{"^%+(%d+) Mana restored per 5 seconds$", "Mp5"}, -- Magister's armor kit
	{"^Equip: Restores (%d+) health every 5 sec%.$", "Hp5"},
	{"^Equip: Restores (%d+) health per 5 sec%.$", "Hp5"}, -- Yes, both "every" and "per" are used on items...
	{"^%+?(%d+) [hH]ealth [eE]very 5 [sS]ec%.?$", "Hp5"}, -- Aquamarine Signet of Regeneration
	{"^%+?(%d+) [hH]ealth [pP]er 5 [sS]ec%.?$", "Hp5"}, -- Anglesite Choker of Regeneration
	{"^Vitality$", "Mp5", 4, PawnMultipleStatsFixed, "Hp5", 4, PawnMultipleStatsFixed}, -- boots enchantment
	{"^%+(%d+) Mana$", "Mana"}, -- +150 mana enchantment
	{"^%+(%d+) HP$", "Health"}, -- +100 health head/leg enchantment
	{"^%+(%d+) Health$", "Health"}, -- +150 health enchantment
	{"^%+?(%d+) Armor$", "Armor"}, -- normal armor has no +, but the cloak armor enchantments do
	{"^Reinforced %(%+(%d+) Armor%)$", "Armor"}, -- armor kits
	{"^Equip: %+(%d+) Armor%.$", "Armor"}, -- paladin Royal Seal of Eldre'Thalas
	{"^Equip: Increases spell power by (%d+)%.$", "SpellPower"}, -- Overlaid Chain Spaulders
	{"^%+?(%d+) Spell Power$", "SpellPower"}, -- Reckless Monarch Topaz (*** one Shattrath shoulder enchantment in WoW 2.4 also uses this phrase to mean spell damage)
	{"^Equip: Increases damage and healing done by magical spells and effects by up to (%d+)%.$", "SpellDamage", 1, PawnMultipleStatsExtract, "Healing", 1, PawnMultipleStatsExtract}, -- (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Damage ?$", "SpellDamage", 1, PawnMultipleStatsExtract, "Healing", 1, PawnMultipleStatsExtract}, -- include (WorldOfWar) says one gem adds a space after "Spell Damage" (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Healing and Spell Damage$", "SpellDamage", 1, PawnMultipleStatsExtract, "Healing", 1, PawnMultipleStatsExtract}, -- ZG or AQ enchantment (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Spell Damage and Healing$", "SpellDamage", 1, PawnMultipleStatsExtract, "Healing", 1, PawnMultipleStatsExtract}, -- Starfire Trousers of the Sorcerer (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Damage and Healing Spells$", "SpellDamage", 1, PawnMultipleStatsExtract, "Healing", 1, PawnMultipleStatsExtract}, -- Circlet of the Victor socket bonus (*** obsolete in WoW 3.0)
	{"^Equip: Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects%.$", "Healing", 1, PawnMultipleStatsExtract, "SpellDamage", 2, PawnMultipleStatsExtract}, -- (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Healing$", "Healing"}, -- enchantments; gems (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Healing %+?(%d+) Spell Damage$", "Healing", 1, PawnMultipleStatsExtract, "SpellDamage", 2, PawnMultipleStatsExtract}, -- gems (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Healing and %+?(%d+) Spell Damage$", "Healing", 1, PawnMultipleStatsExtract, "SpellDamage", 2, PawnMultipleStatsExtract}, -- Teardrop Tourmaline (*** obsolete in WoW 3.0)
	{"^%+?(%d+) Healing Spells and %+?(%d+) Damage Spells$", "Healing", 1, PawnMultipleStatsExtract, "SpellDamage", 2, PawnMultipleStatsExtract}, -- Enchant Weapon: Major Healing (*** obsolete in WoW 3.0)
	{"^Equip: Increases armor penetration rating by (%d+)%.$", "ArmorPenetration"}, -- Onslaught Breastplate, Vereesa's Silver Chain Belt
	{"^Equip: Your attacks ignore (%d+) of your opponent's armor%.$", "ArmorPenetration"}, -- Onslaught Breastplate *** obsolete in WoW 3.0
	{"^%+?(%d+) Armor Penetration$", "ArmorPenetration"}, -- Puissant Shadow Crystal
	{"^Equip: Increases your spell penetration by (%d+)%.$", "SpellPenetration"}, -- Frostfire Robe
	{"^%+?(%d+) Spell Penetration$", "SpellPenetration"}, -- Radiant Talasite
	{"^%+(%d+) Fire Damage$", "FireSpellDamage"},
	{"^%+(%d+) Fire Spell Damage$", "FireSpellDamage"},
	{"^Equip: Increases damage done by Fire spells and effects by up to (%d+)%.$", "FireSpellDamage"},
	{"^Equip: Increases fire spell power by (%d+)%.$", "FireSpellDamage"},
	{"^%+(%d+) Shadow Damage$", "ShadowSpellDamage"},
	{"^%+(%d+) Shadow Spell Damage$", "ShadowSpellDamage"},
	{"^Equip: Increases damage done by Shadow spells and effects by up to (%d+)%.$", "ShadowSpellDamage"},
	{"^Equip: Increases shadow spell power by (%d+)%.$", "FrostSpellDamage"}, -- Frozen Shadoweave Shoulders
	{"^%+(%d+) Nature Damage$", "NatureSpellDamage"}, -- Netherstalker Legguards of Nature's Wrath
	{"^%+(%d+) Nature Spell Damage$", "NatureSpellDamage"},
	{"^Equip: Increases damage done by Nature spells and effects by up to (%d+)%.$", "NatureSpellDamage"},
	{"^Equip: Increases nature spell power by (%d+)%.$", "NatureSpellDamage"},
	{"^%+(%d+) Arcane Damage$", "ArcaneSpellDamage"},
	{"^%+(%d+) Arcane Spell Damage$", "ArcaneSpellDamage"}, -- Dragon Finger of Arcane Wrath
	{"^Equip: Increases damage done by Arcane spells and effects by up to (%d+)%.$", "ArcaneSpellDamage"},
	{"^Equip: Increases arcane spell power by (%d+)%.$", "ArcaneSpellDamage"},
	{"^Sunfire$", "FireSpellDamage", 50, PawnMultipleStatsFixed, "ArcaneSpellDamage", 50, PawnMultipleStatsFixed}, -- weapon enchantment (untested)
	{"^%+(%d+) Frost Damage$", "FrostSpellDamage"},
	{"^%+(%d+) Frost Spell Damage$", "FrostSpellDamage"}, -- enchantment
	{"^Equip: Increases damage done by Frost spells and effects by up to (%d+)%.$", "FrostSpellDamage"},
	{"^Equip: Increases frost spell power by (%d+)%.$", "FrostSpellDamage"}, -- Frozen Shadoweave Shoulders
	{"^Soulfrost$", "FrostSpellDamage", 54, PawnMultipleStatsFixed, "ShadowSpellDamage", 54, PawnMultipleStatsFixed}, -- weapon enchantment (untested)
	{"^%+(%d+) Holy Damage$", "HolySpellDamage"},
	{"^%+(%d+) Holy Spell Damage$", "HolySpellDamage"},
	{"^Equip: Increases damage done by Holy spells and effects by up to (%d+)%.$", "HolySpellDamage"}, -- Lightforged Blade
	{"^Equip: Increases the damage done by Holy spells and effects by up to (%d+)%.$", "HolySpellDamage"}, -- Drape of the Righteous
	{"^Equip: Increases holy spell power by (%d+)%.$", "HolySpellDamage"},
	{"^%+?(%d+) All Resistances$", "AllResist"},
	{"^%+?(%d+) Resist All$", "AllResist"}, -- Prismatic Sphere
	{"^%+?(%d+) Fire Resistance$", "FireResist"},
	{"^%+?(%d+) Shadow Resistance$", "ShadowResist"},
	{"^%+?(%d+) Nature Resistance$", "NatureResist"},
	{"^%+?(%d+) Arcane Resistance$", "ArcaneResist"},
	{"^%+?(%d+) Frost Resistance$", "FrostResist"},
	{"^Red Socket$", "RedSocket", 1, PawnMultipleStatsFixed},
	{"^Yellow Socket$", "YellowSocket", 1, PawnMultipleStatsFixed},
	{"^Blue Socket$", "BlueSocket", 1, PawnMultipleStatsFixed},
	{"^Colorless Socket$", "ColorlessSocket", 1, PawnMultipleStatsFixed}, -- *** WoW 3.0 blacksmithing pattern, such as Socket Bracer
	{"^Meta Socket$", "MetaSocket", 1, PawnMultipleStatsFixed},

	-- ========================================
	-- Rare strings that are ignored (common ones are at the top of the file)
	-- ========================================
	{"^Alterac Valley$"}, -- Stormpike Soldier's Blood
	{"^Blackrock Depths$"}, -- Dark Brewmaiden's Brew
	{"^Blade's Edge Mountains$"}, -- Felsworn Gas Mask
	{"^Black Temple$"}, -- Naj'entus Spine
	{"^Dire Maul$"}, -- Gordok Courtyard Key
	{"^Ebon Hold$"}, -- Scourgestone
	{"^Hyjal Summit$"}, -- Tears of the Goddess
	{"^Karazhan$"}, -- Torment of the Worgen
	{"^Old Hillsbrad Foothills$"}, -- Pack of Incendiary Bombs
	{"^Serpentshrine Cavern$"}, -- Tainted Core
	{"^Shadowmoon Valley$"}, -- Enchanted Illidari Tabard
	{"^Stratholme$"}, -- Andonisus, Reaper of Souls
	{"^Tempest Keep$"}, -- Cosmic Infuser
	{"^The Escape From Durnholde$"}, -- Pack of Incendiary Bombs
	{"^The Black Morass$"}, -- Chrono-beacon
	{"^Wintergrasp$"}, -- Inflatable Land Mines
	{"^Zul'Aman$"}, -- Amani Hex Stick
}

-- These regexes work exactly the same as PawnRegexes, but they're used to parse the right side of tooltips.
-- Unrecognized stats on the right side are always ignored.
PawnRightHandRegexes =
{
	{"^Speed ([%d%.,]+)$", "Speed"},
	{"^Arrow$", "IsBow", 1, PawnMultipleStatsFixed},
	{"^Axe$", "IsAxe", 1, PawnMultipleStatsFixed},
	{"^Bow$", "IsBow", 1, PawnMultipleStatsFixed},
	{"^Bullet$", "IsGun", 1, PawnMultipleStatsFixed},
	{"^Crossbow$", "IsCrossbow", 1, PawnMultipleStatsFixed},
	{"^Dagger$", "IsDagger", 1, PawnMultipleStatsFixed},
	{"^Fist Weapon$", "IsFist", 1, PawnMultipleStatsFixed},
	{"^Gun$", "IsGun", 1, PawnMultipleStatsFixed},
	{"^Mace$", "IsMace", 1, PawnMultipleStatsFixed},
	{"^Polearm$", "IsPolearm", 1, PawnMultipleStatsFixed},
	{"^Staff$", "IsStaff", 1, PawnMultipleStatsFixed},
	{"^Sword$", "IsSword", 1, PawnMultipleStatsFixed},
	{"^Thrown$", "IsThrown", 1, PawnMultipleStatsFixed},
	{"^Wand$", "IsWand", 1, PawnMultipleStatsFixed},
}