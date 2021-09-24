local L = LibStub("AceLocale-3.0"):NewLocale("BestInSlotRedux", "enUS", true)

-- Unused strings commented out

--Common strings
--L["Patch %s"] = true
L["Raid Tier"] = true
L["Difficulty"] = true
L["Specialization"] = true
L["Raid Instance"] = true
--L["Selection"] = true
L["Overview"] = true
--L["Shared Boss Loot"] = true
L["commands"] = true
L["Select all"] = true
L["VANQUISHER"] = "Vanquisher"
L["PROTECTOR"] = "Protector"
L["CONQUEROR"] = "Conqueror"
L["Trash Loot"] = true
--L["Warlords Season %d"] = true
--L["PvP Vendor"] = true
L["Custom Items"] = true
L["Tooltip"] = true
L["Credits"] = true

--Core
L["%s or %s"] = true
--L["Developed by %s"] = true
L["Created by %s. Currently developed by %s."] = true
L["This addon requires atleast 1 expansion module! Please enable one!"] = true
L["Show the GUI"] = true
L["%1$s from raid tier: %2$s"] = true
L["Deselect item"] = true
L["Select an item"] = true
L["has been initialized, use %s to show the GUI"] = true
L["Command not recognized, try '%s' for help"] = true
L["%s - this dialog"] = true
L["%s - enable/disable debug messages"] = true
L["Disabling debug messages"] = true
L["Enabling debug messages"] = true
L["The following people in your guild also need this item:"] = true
L["The following people in your guild already obtained this item"] = true
L["Resets the window to it's original position"] = true

--Tips
--L["In the BiS manager you can compare items with your selected item!"] = true
--L["Don't like the animating screens? Disable the animations in the options!"] = true
--L["Miss a feature that you would like to see? Suggest it on %s"] = true
--L["Do you want this add-on to be available in your language? Help translate at %s"] = true
--L["Put your mouse over this text!"] = true
--L["This way you can often get more info about this tip!"] = true
--L["%1$s translation by %2$s"] = true

--L["Wanna know how to use the manager?"] = true
--L["You can use this window to edit your BestInSlot list."] = true
--L["The data in the following dropdown menus are defined by the modules you have activated."] = true
--L["You can either select an icon or a 'Select an Item' button to select an item for that slot."] = true
--L["You can shift-click icons or items to link them in the chat."] = true
--L["After selecting an item, hovering over a different item will popup a compare window."] = true

-- Manager Frame
L["%s manager"] = true
L["Use left-click to (de)select the left one, and right-click to select the right one"] = true
L["Are you sure you want to import the %s difficulty? This will override your old BiS list!"] = true
L["Are you sure you want to import the list from %s? This will override your old BiS list!"] = true
L["Import from other difficulty/character"] = true
L["Add lower raid tiers"] = true
L["Only show this raid tier"] = true
L["Only show items for specialization"] = true
L["Show all items"] = true
L["No other characters to import"] = true

--Options Frame
L["Debug messages"] = true
L["Debug messages will be shown in the chat window if enabled."] = true
L["These can be used to identify problems."] = true
L["Generally encouraged to keep this disabled"] = true
L["This setting is not saved between sessions, and off by default."] = true

L["Instant animations"] = true
L["Changes the behavior of the BestInSlot frame."] = true
L["Checking this disables the animation, and makes the frame instantly change size."] = true
L["This setting is account wide and saved between sessions."] = true

L["Show BestInSlot in Item tooltip"] = true
L["This will put a note underneath Item tooltips when the item is part of your BestInSlot"] = true

L["Show guild members in Item Tooltip"] = true
L["This will show the guild members who also have BestInSlot in your item tooltips."] = true

L["Show the item source in the tooltip, for example a boss that drops it, or a quest chain."] = true
L["Show item source in tooltip."] = true

L["Disable resizing"] = true
L["This will disable resizing and set the window on a fixed size"] = true

L["Options"] = true

L["Automatization"] = true
L["Send automatic updates"] = true
L["When you update your BiS list, it'll automatically send the updates to the guild"] = true

L["Receive automatic updates"] = true
L["When others in your guild update their BiS list, automatically save it."] = true

L["Show minimap button"] = true

L["Shows interactive tutorials on how to efficiently use %s"] = true
L["Tutorials have been reset."] = true

--RaidTier Frame
L["It looks like this instance does not drop any of your BestInSlot items."] = true
L["It could also be that you haven't set the BestInSlot for this raid tier yet"] = true
L["You can use the BiS Manager on the left to set your BestInSlot"] = true

L["Report your BestInSlot to:"] = true
L["Select an option"] = true
L["%1$s needs the following bosses from %2$s %3$s"] = true
L["%1$s needs nothing from %2$s %3$s"] = true

--Request BestInSlots
L["Request"] = true
L["Request BiS"] = true
--L["Request type"] = true
L["Request from"] = true
--L["BestInSlot per Player"] = true
--L["Instance Overview"] = true
--L["Select a request type"] = true
--L["Select a type first!"] = true
L["Select a channel"] = true
L["Whisper target"] = true
L["Select all"] = true
L["Deselect all"] = true
L["Class filter"] = true
L["Token filter"] = true
L["Armor filter"] = true
L["Show obtained items"] = true
--L["Show Guild BiS lists"] = true
L["Not enough data to filter"] = true

--Overview window
--L["Show all"] = true
L["You have this item"] = true
L["Only show missing items"] = true
L["You have this item on '%s'"] = true
L["Report BestInSlot"] = true

--Mists of Pandaria locale
--L["Legendary Cloak Quest"] = true

--Warlords of Draenor locale
--L["Legenday Ring Quest"] = true

--Communication
--L["This function requires a channel."] = true
L["This function requires a target."] = true
L["Usage: %s"] = true
L["Queries the specified channels for versions."] = true
L["Your version of BestInSlot is outdated! You can download the newest version at %s%s"] = true

--Guild BiS Lists
L["Guild BiS lists"] = true
L["%s's BestInSlot lists"] = true
L["Return to character selection"] = true
L["Delete this specialization from this raid tier"] = true
L["Delete options"] = true
L["Delete %s from this difficulty"] = true
L["Delete %s from this raidtier"] = true
L["Delete %s completely."] = true
L["You've picked: %s"] = true
L["Deleting this is irreversible. Are you sure?"] = true
L["There are no Best in Slot lists from any of your guild members available. Have you requested their Best In Slot info?"] = true

--Minimap Tooltip
L["Click"] = true

--Debugging console
L["%s - Shows a debugging console"] = true

--Tutorials
L["In this menu you can select different parts of the AddOn. The selected menu is displayed in white."] = true
--L["In the bottom of the window you can view tips and credits. These will update based on the page you're viewing"] = true
L["On most pages you can set your instance, difficulty and specialization in the top of the page. These settings are saved across all pages."] = true
L["On this page you can set your BestInSlot list. You can use the '%s' buttons to select your item for that slot"] = true
L["You can right-click icons to quickly remove them from your list."] = true
L["When you've set a difficulty before, you can easily import a previously set list."] = true
L["When selecting rings or trinkets, you can see both items at once."] = true

L["On this page you can overview your BestInSlot list per instance."] = true
L["The filter is set to only show the items you have not obtained yet. You can also make multiple specializations appear here."] = true
L["If you want to share your BestInSlot list, you can report it here."] = true
L["Note: This could send a long list of items depending on the amount of items you still need, and might be considered spam."] = true

L["On this page you can view the BestInSlot lists of your guild."] = true
L["The dropdowns will only show BestInSlot lists that you have available."] = true
L["You can request BestInSlot lists in the '%s' page."] = true
L["Click on the class icons to view that characters BestInSlot list."] = true
L["Right clicking the icons gives you options to delete them from your Saved Variables."] = true
L["Click on any specialization icon to view that specializations list."] = true
L["Only the specializations that you received are enabled."] = true

L["On this page you can request BestInSlot lists from your friends, guildmembers or raidmembers."] = true
L["Use the '%s' dropdown to pick where you would like to request lists from."] = true
L["When picking the whisper target, make sure you also fill in a recipient!"] = true
L["When you have successfully received BestInSlot lists you can use the filter to filter lists."] = true

--Zonedetection module
L["These items from %s are %sBestInSlot%s:"] = true
L["You already have these %sBestInSlot%s items from %s"] = true
L["Show BestInSlot in boss tooltips"] = true
L["This will show items on the boss tooltip that you consider BestInSlot"] = true
L["Show tooltips in combat"] = true
L["You can preserve speed by preventing BestInSlot from adding information to tooltips while you are in combat"] = true

--CustomItems
L["Insert item ID, item link or item name"] = true
L["Please verify that this is the item you would like to add:"] = true
L["You can only add items of %ssuperior%s quality or higher!"] = true
L["You must be able to equip the item!"] = true
L["Looking up item"] = true
L["This item already exists in the database! It is registered to %s"] = true
L["Failed to add item because of the following reasons:"] = true
L["The minimum item level of custom items is %d!"] = true
L["You cannot add items of type: %s!"] = true
L["Warlords crafted options:"] = true
L["Select the instance that you would like to add this item to."] = true
L["Successfully added %s to the custom items of %s!"] = true
L["Add a custom item"] = true
L["Pick a previously created custom item"] = true
L["Warning! Editing this item will overwrite the previous item set on this itemid!"] = true
L["Are you sure you want to delete %s? This item is on your Best In Slot list!"] = true
L["Couldn't find item!"] = true
L["Successfully deleted %s%s from the custom items!"] = true
L["There are no custom items present"] = true
L["In this menu you can add custom items. Use this edit box to submit your item."] = true
L["You can only use the item name if you have the item in your inventory!"] = true
L["You can edit previously made custom items by selecting them with this dropdown box."] = true
--L["When adding crafted items, you can select the random stats and the stage of the item with these dropdown boxes."] = true

--Export/Import
L["Export"] = true
--L["%1$s's %2$s list for %3$s %4$s"] = true
--L["Failed to get info from %s"] = true

--History
L["Show history for %s"] = true
L["History for %s"] = true
L["There is no history available for %s"] = true
L["Created BestInSlot list"] = true
L["Modified the %s slot. Previous item: %s, new item: %s"] = true
L["Tracks changes made by Guild Members to their BestInSlot lists"] = true
L["History tracking"] = true
L["Automatically delete history"] = true
L["Automatically deletes history based on the time set below"] = true
L["Wipe history"] = true
L["Are you sure you want to delete ALL history?"] = true

--Preview window
--L["Mastery tooltips are not supported due to technical limitations"] = true

--Bugs and Reporting
--L["Bugs and recommendations"] = true
--L["Submit Missing item"] = true
--L["Please choose what you would like to submit"] = true
--L["Describe what you were doing when the bug occured"] = true
--L["What is the item ID for the item you miss in BestInSlot?"] = true
--L["Should this item be added to an instance? If so which one, and which boss."] = true
--L["Is the item missing for a particular class or slot? If so, which one."] = true
--L["Describe what you would like to see implemented"] = true
--L["Additional Information"] = true
--L["Please navigate to the issue tracker."] = true
--L["Please select the type: %s"] = true
--L["Copy paste underlying information in the description field."] = true
--L["Paste any LUA errors in this field"] = true
--L["%s - Shows the report bug window"] = true
--L["This window is intended for when the normal BestInSlot window won't open!"] = true

--Custom Lists
L["Custom Lists"] = true
L["Your custom lists"] = true
L["New custom list"] = true
L["Each custom list must be tied to a talent specialization."] = true
L["This name is invalid"] = true
L["A list with this name already exists"] = true
L["You must select a specialization."] = true
L["You can't delete this custom list.\r\nIt is in use at:\r\n%s"] = true
L["You can't delete this custom list."] = true
L["It's in use at:"] = true
