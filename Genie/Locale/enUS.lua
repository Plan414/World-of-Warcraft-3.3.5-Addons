--[[///////////////////////////////////////////////////////////////////////////////////////
    GENIE 3.0.5.1_beta2

    Author: adjo
    Website: http://wow.curseforge.com/projects/genie
    Feedback: http://wow.curseforge.com/projects/genie/tickets/
    Localization: http://wow.curseforge.com/addons/genie/localization/
    
	adjo 2010-05-03T11:49:12Z   
--///////////////////////////////////////////////////////////////////////////////////////]]

local L = LibStub("AceLocale-3.0"):NewLocale("Genie", "enUS", true, true)
--[[///////////////////////////////////////////////////////////////////////////////////////
    Automatic translation injection
--///////////////////////////////////////////////////////////////////////////////////////]]
L["Add"] = true
L["Add a class/family to the ranking"] = true
L["Add an element to this X"] = true
L["AIC:short"] = "Aic"
L["All items are beeing ignored"] = true
L["Alt"] = true
L["As you wish master"] = true
L["Automatic"] = true
L["Automatic mode"] = true
L["Automatic X events"] = true
L["Bag"] = true
L["bag/ bank or guildbank"] = true
L["Bags"] = true
L["Bank"] = true
L["BANKFRAME_CLOSED"] = "Checked your Bank"
L["BANKFRAME_OPENED"] = "Open your Bank"
L["Classranking"] = true
L["Combine one or more ranks"] = true
L["Contains"] = true
L["Count"] = true
L["Create"] = true
L["Created"] = true
L["Current content of X"] = true
L["Custom family"] = true
L["Custom family:short"] = "CF"
L["Delete"] = true
L["Delete a combined rank"] = true
L["Deleted"] = true
L["Disable"] = true
L["Disable a class"] = true
L["Disabled"] = true
L["Disabled:short"] = "D"
L["Display detailed infos about a rank"] = true
L["Enable"] = true
L["Enable a class"] = true
L["Enabled"] = true
L["EquipLoc"] = "Equip Location"
L["EQUIPMENT_SWAP_FINISHED"] = "Changed Equipment Set"
L["Events"] = true
L["Family"] = true
L["Fast"] = true
L["Finished"] = true
L["Genie"] = true
L["Guildbank"] = true
L["GUILDBANKFRAME_CLOSED"] = "Checked your Guildbank"
L["Guildbank-Tab 'X' unlocked. You're welcome."] = true
L["Ignore"] = true
L["Ignore all elements of this X"] = true
L["Ignore all elements of X"] = true
L["iLvl"] = "ItemLevel"
L["I'm locking Guildbank-Tab 'X'. Step back!"] = true
L["I need to know on which tabs i'm allowed to work"] = true
L["Inspect"] = true
L["Inventory"] = true
L["Invert a class"] = true
L["Inverted:short"] = "I"
L["Invert the sorting order"] = true
L["Itemid"] = true
L["I've done what you requested in X seconds"] = true
L["I will try to read your mind master"] = true
L["Keyring"] = true
L["LeftClick"] = true
L["Lock the Guildbank"] = true
L["Lock the Guildbank:desc"] = "Lock the Guilbank-Tab Genie is currently working on"
L["LOOT_CLOSED"] = "Looted"
L["MAIL_CLOSED"] = "Checked your Mailbox"
L["Master i apologize, there where some errors. I had to stop"] = true
L["Master, i can't work with an empty container"] = true
L["Master, that's one thing i'm not allowed to do"] = true
L["Master, there's nothing (more) to do"] = true
L["MERCHANT_CLOSED"] = "Visited a Merchant"
L["MinLevel"] = "Minimum level"
L["Mode"] = true
L["Move all items"] = true
L["Moving"] = true
L["Name"] = true
L["New"] = true
L["No X defined"] = true
L["Open the optionsmenu"] = true
L["Price"] = "Sell price"
L["Questitem"] = "Quest Item"
L["Rarity"] = "Quality"
L["Remove"] = true
L["Remove an element from this X"] = true
L["Rename"] = true
L["Reset the classranking"] = true
L["Reverse"] = true
L["Reverse the order in which your bags and/or bagslots will be accsessed"] = true
L["RightClick"] = true
L["Shift"] = true
L["Show"] = true
L["Show current X"] = true
L["Silent"] = true
L["SlotCooldown"] = "Slot Cooldown"
L["SlotCooldown:desc"] = "Time in seconds Genie should wait before reusing a specific slot. Set this to 0(Zero) if you want no delay."
L["Slots"] = true
L["Sort all items"] = true
L["sort_heap"] = "Heapsort"
L["Sorting"] = true
L["Sorting algorithm"] = true
L["sort_insert"] = "Insertionsort"
L["sort_quick3"] = "Quicksort3"
L["sort_select"] = "Selectionsort"
L["Soulbound"] = true
L["Sound"] = true
L["Stack all items"] = true
L["StackCount"] = "Stackcount"
L["Stacking"] = true
L["Stack, move and sort your X"] = true
L["Stop"] = true
L["Strg"] = "Control"
L["SubType"] = "Subtype"
L["SwapsPerCycle"] = "Swaps per cycle"
L["SwapsPerCycle:desc"] = "Each cycle Genie swaps a specifc amount of items. Set this to 0(Zero) if you want Genie to swap them all at once"
L["Text"] = true
L["Texture"] = true
L["TRADE_CLOSED"] = "Traded with someone"
L["Type"] = true
L["Unique"] = true
L["Unknown"] = true
L["Update"] = true
L["Update a class"] = true
L["Updated"] = true
L["Version"] = true
L["waitAfter"] = "Wait after combat"
L["Work"] = true
L["X added to Y"] = true
L["X has been updated"] = true
L["X is empty"] = true
L["X removed from Y"] = true
L["X renamed to Y"] = true


--[[///////////////////////////////////////////////////////////////////////////////////////
	translated auctionitemclasses

    Usage: L[L['Weapon']()] to get the translated type
    Note: Update if auctionitemclasses are added/removed
--///////////////////////////////////////////////////////////////////////////////////////]]
L["Weapon"] = function() return "aic01" end
L["Armor"] = function() return "aic02" end
L["Container"] = function() return "aic03" end
L["Consumable"] = function() return "aic04" end
L["Glyph"] = function() return "aic05" end
L["Trade Goods"] = function() return "aic06" end
L["Projectile"] = function() return "aic07" end
L["Quiver"] = function() return "aic08" end
L["Recipe"] = function() return "aic09" end
L["Gem"] = function() return "aic10" end
L["Miscellaneous"] = function() return "aic11" end
L["Quest"] = function() return "aic12" end

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
