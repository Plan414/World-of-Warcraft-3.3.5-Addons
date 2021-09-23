local L = LibStub("AceLocale-3.0"):NewLocale("Critline", "enUS", true)
if not L then return end

-- common
L["damage"] = true
L["Damage"] = true
L["healing"] = true
L["Healing"] = true
L["pet"] = true
L["Pet"] = true

L["Normal"] = true
L["Crit"] = true

L["critical "] = true
L["Critical!"] = true
L["n/a"] = true
L["None"] = true
L["Invalid spell ID."] = true
L["No records"] = true
L["Drag to move"] = true
L["Left-click to toggle summary frame"] = true
L["Right-click to open options"] = true
L["tick"] = true
L["Tick"] = true
L["Enabled"] = true
L["Show"] = true
L["Locked"] = true
L["Opacity"] = true
L["Scale"] = true

L["Here you can review and manage all your registered spells. Click the button on the right hand side of a spell for options."] = true

-- core
L["New %s%s record - %s"] = true
L["Record damage"] = true
L["Check to enable damage events to be recorded."] = true
L["Record healing"] = true
L["Check to enable healing events to be recorded."] = true
L["Record pet damage"] = true
L["Check to enable pet damage events to be recorded."] = true
L["Record PvE"] = true
L["Disable to ignore records where the target is an NPC."] = true
L["Record PvP"] = true
L["Disable to ignore records where the target is a player."] = true
L["Detailed tooltip"] = true
L["Use detailed format in the summary tooltip."] = true
L["Ignore vulnerability"] = true
L["Enable to ignore additional damage due to vulnerability."] = true
L["Include old record"] = true
L["Includes previous record along with \"New record\" messages."] = true
L["Records in spell tooltips"] = true
L["Include (unfiltered) records in spell tooltips."] = true
L["Chat output"] = true
L["Prints new record notifications to the chat frame."] = true
L["Screenshot"] = true
L["Saves a screenshot on a new record."] = true
L["Shorten records"] = true
L["Use shorter format for record numbers."] = true
L["Sound effect"] = true
L["Sort tooltips by:"] = true
L["Spell name"] = true
L["Crit record"] = true
L["Normal record"] = true

-- filters
L["Include"] = true
L["included spells"] = true
L["Exclude"] = true
L["excluded spells"] = true
L["Auras"] = true
L["aura filter"] = true
L["Mobs"] = true
L["mob filter"] = true

L["Spells in this list will be considered known spells for the purposes of the 'Only known spells' option."] = true
L["Spells in this list will not be registered."] = true
L["Spells cast on targets in this list will not be registered."] = true
L["When an aura in this list is gained, records will be disabled for the remainder of the combat duration."] = true
L["%s added to %s."] = true
L["%s removed from %s."] = true
L["%s is already in %s."] = true
L["Enter spell ID"] = true
L["Enter spell name or ID"] = true
L["Invalid input. Please enter a spell ID."] = true
L["Enter mob name"] = true
L["Add target"] = true
L["No target selected."] = true
L["Cannot add players to mob filter."] = true

L["Filter new spells"] = true
L["Enable to filter out new spell entries by default."] = true
L["Ignore aura filter"] = true
L["Enable to ignore integrated aura filter."] = true
L["Ignore mob filter"] = true
L["Enable to ignore integrated mob filter."] = true
L["Only known spells"] = true
L["Enable to ignore spells that are not in your (or your pet's) spell book."] = true
L["Suppress mind control"] = true
L["Suppress all records while mind controlled."] = true
L["Level filter"] = true
L["If level difference between you and the target is greater than this setting, records will not be registered."] = true
L["Ignore outdoor bosses"] = true
L["Ignore damage dealt to boss level creatures outside of raid instances."] = true

-- splash
L["Splash frame"] = true
L["Shows the new record on the middle of the screen."] = true
L["New %s record!"] = true
L["Critline splash frame unlocked"] = true
L["Right-click to lock"] = true
L["Font"] = true
L["Font outline"] = true
L["Thick"] = true
L["Sets the scale of the splash frame."] = true
L["Amount color"] = true
L["Sets the color for the amount text in the splash frame."] = true
L["Spell color"] = true
L["Sets the color for the spell text in the splash frame."] = true
L["Font size"] = true
L["Sets the font size of the splash frame."] = true
L["Fade duration"] = true
L["Sets the time between the splash frame starting to fade and being fully faded out."] = true
L["Duration"] = true
L["Sets the time (in seconds) the splash frame is visible before fading out."] = true
L["Use combat text splash"] = true
L["Enable to use scrolling combat text for \"New record\" messages instead of the default splash frame."] = true

-- display
L["Show summary frame."] = true
L["Lock summary frame."] = true
L["Sets the scale of the display."] = true
L["Sets the opacity of the display."] = true
L["Backdrop opacity"] = true
L["Sets the opacity of the display backdrop."] = true
L["Border opacity"] = true
L["Sets the opacity of the display border."] = true
L["Show icons"] = true
L["Enable to show icon indicators instead of text."] = true

-- minimap
L["Minimap"] = true
L["Show minimap button."] = true
L["Lock minimap button."] = true

-- announce
L["Announce"] = true
L["Enter whisper target"] = true
L["Invalid channel. Please enter a valid channel name or ID."] = true

-- reset
L["Are you sure you want to reset all %s records?"] = true
L["Are you sure you want to revert all recent %s records?"] = true
L["Previous record:"] = true
L["Reset"] = true
L["Reset all"] = true
L["Reset all %s records."] = true
L["Reset %s (%s) records."] = true
L["Revert"] = true
L["Revert all"] = true
L["Reverted all recent %s records."] = true

-- advanced
L["Spell mappings"] = true
L["Tooltip mappings"] = true
L["Spell name overrides"] = true
L["Spell icon overrides"] = true
L["Conflicting mapping."] = true
L["This spell ID is already mapped."] = true
L["Spell mappings causes the source spell to be registered as if it were the target spell. It will be stored with the ID, name and icon of"..
" the target spell. Useful for merging different spell IDs of the same spell into a single record. Spells will immediately be converted"..
" into their target ID after a mapping has been created."] = true
L["Tooltip mappings causes the tooltip of the source spell to display the records of the target spell. Useful for when several tooltips refer to "..
"the same spell, or you want to display some side effect of a spell. Any tooltip can only display the records of one database entry at a time."] = true
L["Name overrides will cause the source spell to be listed as the target name in tree tooltips, new record messages and the spell list."] = true
L["Icon overrides will cause the source spell to use the target texture in the spell list."] = true
