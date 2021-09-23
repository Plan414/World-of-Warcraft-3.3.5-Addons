--[[///////////////////////////////////////////////////////////////////////////////////////
    GENIE 3.0.5.1_beta2

    Author: adjo
    Website: http://wow.curseforge.com/projects/genie
    Feedback: http://wow.curseforge.com/projects/genie/tickets/
    Localization: http://wow.curseforge.com/addons/genie/localization/
    
	adjo 2010-05-03T11:49:12Z   
--///////////////////////////////////////////////////////////////////////////////////////]]

local L = LibStub("AceLocale-3.0"):NewLocale("Genie", "ruRU")
if not L then return end
--[[///////////////////////////////////////////////////////////////////////////////////////
    Automatic translation injection

	NOTE: Do NOT translate strings here!
	If you want to translate, do so at
	http://wow.curseforge.com/addons/genie/localization/
--///////////////////////////////////////////////////////////////////////////////////////]]
L["Add"] = "Add" -- Requires localization
L["Add a class/family to the ranking"] = "Add a class/family to the ranking" -- Requires localization
L["Add an element to this X"] = "Add an element to this X" -- Requires localization
L["AIC:short"] = "Aic" -- Requires localization
L["All items are beeing ignored"] = "All items are beeing ignored" -- Requires localization
L["Alt"] = "Alt" -- Requires localization
L["As you wish master"] = "As you wish master" -- Requires localization
L["Automatic"] = "Automatic" -- Requires localization
L["Automatic mode"] = "Automatic mode" -- Requires localization
L["Automatic X events"] = "Automatic X events" -- Requires localization
L["Bag"] = "Bag" -- Requires localization
L["bag/ bank or guildbank"] = "bag/ bank or guildbank" -- Requires localization
L["Bags"] = "Bags" -- Requires localization
L["Bank"] = "Bank" -- Requires localization
L["BANKFRAME_CLOSED"] = "Checked your Bank" -- Requires localization
L["BANKFRAME_OPENED"] = "Open your Bank" -- Requires localization
L["Classranking"] = "Classranking" -- Requires localization
L["Combine one or more ranks"] = "Combine one or more ranks" -- Requires localization
L["Contains"] = "Contains" -- Requires localization
L["Count"] = "Count" -- Requires localization
L["Create"] = "Create" -- Requires localization
L["Created"] = "Created" -- Requires localization
L["Current content of X"] = "Current content of X" -- Requires localization
L["Custom family"] = "Custom family" -- Requires localization
L["Custom family:short"] = "CF" -- Requires localization
L["Delete"] = "Delete" -- Requires localization
L["Delete a combined rank"] = "Delete a combined rank" -- Requires localization
L["Deleted"] = "Deleted" -- Requires localization
L["Disable"] = "Disable" -- Requires localization
L["Disable a class"] = "Disable a class" -- Requires localization
L["Disabled"] = "Disabled" -- Requires localization
L["Disabled:short"] = "D" -- Requires localization
L["Display detailed infos about a rank"] = "Display detailed infos about a rank" -- Requires localization
L["Enable"] = "Enable" -- Requires localization
L["Enable a class"] = "Enable a class" -- Requires localization
L["Enabled"] = "Enabled" -- Requires localization
L["EquipLoc"] = "Equip Location" -- Requires localization
L["EQUIPMENT_SWAP_FINISHED"] = "Changed Equipment Set" -- Requires localization
L["Events"] = "Events" -- Requires localization
L["Family"] = "Family" -- Requires localization
L["Fast"] = "Fast" -- Requires localization
L["Finished"] = "Finished" -- Requires localization
L["Genie"] = "Genie" -- Requires localization
L["Guildbank"] = "Guildbank" -- Requires localization
L["GUILDBANKFRAME_CLOSED"] = "Checked your Guildbank" -- Requires localization
L["Guildbank-Tab 'X' unlocked. You're welcome."] = "Guildbank-Tab 'X' unlocked. You're welcome." -- Requires localization
L["Ignore"] = "Ignore" -- Requires localization
L["Ignore all elements of this X"] = "Ignore all elements of this X" -- Requires localization
L["Ignore all elements of X"] = "Ignore all elements of X" -- Requires localization
L["iLvl"] = "ItemLevel" -- Requires localization
L["I'm locking Guildbank-Tab 'X'. Step back!"] = "I'm locking Guildbank-Tab 'X'. Step back!" -- Requires localization
L["I need to know on which tabs i'm allowed to work"] = "I need to know on which tabs i'm allowed to work" -- Requires localization
L["Inspect"] = "Inspect" -- Requires localization
L["Inventory"] = "Inventory" -- Requires localization
L["Invert a class"] = "Invert a class" -- Requires localization
L["Inverted:short"] = "I" -- Requires localization
L["Invert the sorting order"] = "Invert the sorting order" -- Requires localization
L["Itemid"] = "Itemid" -- Requires localization
L["I've done what you requested in X seconds"] = "I've done what you requested in X seconds" -- Requires localization
L["I will try to read your mind master"] = "I will try to read your mind master" -- Requires localization
L["Keyring"] = "Keyring" -- Requires localization
L["LeftClick"] = "LeftClick" -- Requires localization
L["Lock the Guildbank"] = "Lock the Guildbank" -- Requires localization
L["Lock the Guildbank:desc"] = "Lock the Guilbank-Tab Genie is currently working on" -- Requires localization
L["LOOT_CLOSED"] = "Looted" -- Requires localization
L["MAIL_CLOSED"] = "Checked your Mailbox" -- Requires localization
L["Master i apologize, there where some errors. I had to stop"] = "Master i apologize, there where some errors. I had to stop" -- Requires localization
L["Master, i can't work with an empty container"] = "Master, i can't work with an empty container" -- Requires localization
L["Master, that's one thing i'm not allowed to do"] = "Master, that's one thing i'm not allowed to do" -- Requires localization
L["Master, there's nothing (more) to do"] = "Master, there's nothing (more) to do" -- Requires localization
L["MERCHANT_CLOSED"] = "Visited a Merchant" -- Requires localization
L["MinLevel"] = "Minimum level" -- Requires localization
L["Mode"] = "Mode" -- Requires localization
L["Move all items"] = "Move all items" -- Requires localization
L["Moving"] = "Moving" -- Requires localization
L["Name"] = "Name" -- Requires localization
L["New"] = "New" -- Requires localization
L["No X defined"] = "No X defined" -- Requires localization
L["Open the optionsmenu"] = "Open the optionsmenu" -- Requires localization
L["Price"] = "Sell price" -- Requires localization
L["Questitem"] = "Quest Item" -- Requires localization
L["Rarity"] = "Quality" -- Requires localization
L["Remove"] = "Remove" -- Requires localization
L["Remove an element from this X"] = "Remove an element from this X" -- Requires localization
L["Rename"] = "Rename" -- Requires localization
L["Reset the classranking"] = "Reset the classranking" -- Requires localization
L["Reverse"] = "Reverse" -- Requires localization
L["Reverse the order in which your bags and/or bagslots will be accsessed"] = "Reverse the order in which your bags and/or bagslots will be accsessed" -- Requires localization
L["RightClick"] = "RightClick" -- Requires localization
L["Shift"] = "Shift" -- Requires localization
L["Show"] = "Show" -- Requires localization
L["Show current X"] = "Show current X" -- Requires localization
L["Silent"] = "Silent" -- Requires localization
L["SlotCooldown"] = "Slot Cooldown" -- Requires localization
L["SlotCooldown:desc"] = "Time in seconds Genie should wait before reusing a specific slot. Set this to 0(Zero) if you want no delay." -- Requires localization
L["Slots"] = "Slots" -- Requires localization
L["Sort all items"] = "Sort all items" -- Requires localization
L["sort_heap"] = "Heapsort" -- Requires localization
L["Sorting"] = "Sorting" -- Requires localization
L["Sorting algorithm"] = "Sorting algorithm" -- Requires localization
L["sort_insert"] = "Insertionsort" -- Requires localization
L["sort_quick3"] = "Quicksort3" -- Requires localization
L["sort_select"] = "Selectionsort" -- Requires localization
L["Soulbound"] = "Soulbound" -- Requires localization
L["Sound"] = "Sound" -- Requires localization
L["Stack all items"] = "Stack all items" -- Requires localization
L["StackCount"] = "Stackcount" -- Requires localization
L["Stacking"] = "Stacking" -- Requires localization
L["Stack, move and sort your X"] = "Stack, move and sort your X" -- Requires localization
L["Stop"] = "Stop" -- Requires localization
L["Strg"] = "Control" -- Requires localization
L["SubType"] = "Subtype" -- Requires localization
L["SwapsPerCycle"] = "Swaps per cycle" -- Requires localization
L["SwapsPerCycle:desc"] = "Each cycle Genie swaps a specifc amount of items. Set this to 0(Zero) if you want Genie to swap them all at once" -- Requires localization
L["Text"] = "Text" -- Requires localization
L["Texture"] = "Texture" -- Requires localization
L["TRADE_CLOSED"] = "Traded with someone" -- Requires localization
L["Type"] = "Type" -- Requires localization
L["Unique"] = "Unique" -- Requires localization
L["Unknown"] = "Unknown" -- Requires localization
L["Update"] = "Update" -- Requires localization
L["Update a class"] = "Update a class" -- Requires localization
L["Updated"] = "Updated" -- Requires localization
L["Version"] = "Version" -- Requires localization
L["waitAfter"] = "Wait after combat" -- Requires localization
L["Work"] = "Work" -- Requires localization
L["X added to Y"] = "X added to Y" -- Requires localization
L["X has been updated"] = "X has been updated" -- Requires localization
L["X is empty"] = "X is empty" -- Requires localization
L["X removed from Y"] = "X removed from Y" -- Requires localization
L["X renamed to Y"] = "X renamed to Y" -- Requires localization


--[[///////////////////////////////////////////////////////////////////////////////////////
	translated auctionitemclasses
--///////////////////////////////////////////////////////////////////////////////////////]]
local itemClasses = { GetAuctionItemClasses() }
if #itemClasses > 0 then
	for i, itemClass in pairs(itemClasses) do
		L["AIC".. string.format('%.2d',i)] = itemClass
		local itemSubClasses = { GetAuctionItemSubClasses(i) }
		if #itemSubClasses > 0 then
			for j, itemSubClass in pairs(itemSubClasses) do
				L["aic"..string.format('%.2d',i)..string.format('%.2d',j)] = itemSubClass
			end
		else
			L["aic"..string.format('%.2d',i).. "00"] = itemClass
		end
	end
end
