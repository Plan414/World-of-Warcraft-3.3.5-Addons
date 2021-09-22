-- Pawn by Vger-Azjol-Nerub
-- www.vgermods.com
-- © 2006-2008 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
-- 
-- Version 1.1.2: support for account-bound heirloom (gold) items
------------------------------------------------------------


-- Pawn requires this version of VgerCore:
local PawnVgerCoreVersionRequired = 1.02

-- Caching
-- 	An item in the cache has the following properties: Name, NumLines, UnknownLines, Stats, SocketBonusStats, UnenchantedStats, UnenchantedSocketBonusStats, Values, Link, PrettyLink, Level, ItemID
--	(See PawnGetEmptyCachedItem.)
local PawnItemCache = nil
local PawnItemCacheMaxSize = 20

local PawnScaleTotals = { }

-- Formatting
local PawnEnchantedAnnotationFormat = nil
local PawnUnenchantedAnnotationFormat = nil

-- "Constants"
local PawnCurrentScaleVersion = 1

local PawnTooltipAnnotation
if VgerCore then PawnTooltipAnnotation = VgerCore.Color.Blue .. " (*)" end

PawnShowAsterisksNever = 0
PawnShowAsterisksNonzero = 1
PawnShowAsterisksAlways = 2
PawnShowAsterisksNonzeroNoText = 3

PawnButtonPositionHidden = 0
PawnButtonPositionLeft = 1
PawnButtonPositionRight = 2

PawnImportScaleResultSuccess = 1
PawnImportScaleResultAlreadyExists = 2
PawnImportScaleResultTagError = 3

-- Data used by PawnGetSlotsForItemType.
local PawnItemEquipLocToSlot1 = 
{
	INVTYPE_AMMO = 0,
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 13,
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = 16,
	INVTYPE_SHIELD = 17,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17,
	INVTYPE_RANGED = 18,
	INVTYPE_THROWN = 18,
	INVTYPE_RANGEDRIGHT = 18,
	INVTYPE_RELIC = 18,
	INVTYPE_TABARD = 19,
}
local PawnItemEquipLocToSlot2 = 
{
	INVTYPE_FINGER = 12,
	INVTYPE_TRINKET = 14,
	INVTYPE_WEAPON = 17,
}


------------------------------------------------------------
-- Pawn events
------------------------------------------------------------

-- Called when an event that Pawn cares about is fired.
function PawnOnEvent(Event, arg1, ...)
	if Event == "VARIABLES_LOADED" then 
		PawnInitialize()
	elseif Event == "ADDON_LOADED" then
		PawnOnAddonLoaded(arg1, ...)
	elseif Event == "UPDATE_BINDINGS" then
		PawnSetDefaultKeybindings()
	end 
end

-- Initializes Pawn after all saved variables have been loaded.
function PawnInitialize()

	-- Check the current version of VgerCore.
	if (not VgerCore) or (not VgerCore.Version) or (VgerCore.Version < PawnVgerCoreVersionRequired) then
		if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cfffe8460" .. PawnLocal.NeedNewerVgerCoreMessage) end
		message(PawnLocal.NeedNewerVgerCoreMessage)
		return
	end

	SLASH_PAWN1 = "/pawn"
	SlashCmdList["PAWN"] = PawnCommand

	-- Set any unset options to their default values.  If the user is a new Pawn user, all options
	-- will be set to default values.  If upgrading, only missing options will be set to default values.
	PawnSetEmptyOptions()
	
	-- Go through the user's scales and check them for errors.
	for ScaleName, _ in pairs(PawnOptions.Scales) do
		PawnCorrectScaleErrors(ScaleName)
		PawnRecalculateScaleTotal(ScaleName)
	end
	
	-- Adjust UI elements.
	PawnUI_InventoryPawnButton_Move()
	
	-- Hook into events.
	-- Main game tooltip
	hooksecurefunc(GameTooltip, "SetAuctionItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetAuctionItem", ...) end)
	hooksecurefunc(GameTooltip, "SetAuctionSellItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetAuctionSellItem", ...) end)
	hooksecurefunc(GameTooltip, "SetBagItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetBagItem", ...) end)
	hooksecurefunc(GameTooltip, "SetBuybackItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetBuybackItem", ...) end)
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetCraftItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetCraftItem", ...) end) end -- *** gone in WoW 3.0?
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetCraftSpell", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetCraftSpell", ...) end) end -- *** gone in WoW 3.0?
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetExistingSocketGem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetExistingSocketGem", ...) end) end -- *** gone in WoW 3.0?
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetGuildBankItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetGuildBankItem", ...) end) end -- *** gone in WoW 3.0?
	hooksecurefunc(GameTooltip, "SetHyperlink", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetHyperlink", ...) end)
	hooksecurefunc(GameTooltip, "SetInboxItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetInboxItem", ...) end)
	hooksecurefunc(GameTooltip, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetInventoryItem", ...) end)
	hooksecurefunc(GameTooltip, "SetLootItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetLootItem", ...) end)
	hooksecurefunc(GameTooltip, "SetLootRollItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetLootRollItem", ...) end)
	hooksecurefunc(GameTooltip, "SetMerchantItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetMerchantItem", ...) end)
	hooksecurefunc(GameTooltip, "SetQuestItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetQuestItem", ...) end)
	hooksecurefunc(GameTooltip, "SetQuestLogItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetQuestLogItem", ...) end)
	hooksecurefunc(GameTooltip, "SetSendMailItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetSendMailItem", ...) end)
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetSocketGem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetSocketGem", ...) end) end -- *** gone in WoW 3.0?
	hooksecurefunc(GameTooltip, "SetTradePlayerItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradePlayerItem", ...) end)
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradeSkillItem", ...) end) end -- *** gone in WoW 3.0?
	hooksecurefunc(GameTooltip, "SetTradeTargetItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradeTargetItem", ...) end)
	if GameTooltip.SetCraftItem then hooksecurefunc(GameTooltip, "SetTrainerService", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTrainerService", ...) end) end -- *** gone in WoW 3.0?
	hooksecurefunc(GameTooltip, "Hide", function(self, ...) PawnLastHoveredItem = nil end)
	
	-- The item link tooltip (only hook it if it's an actual item)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink",
		function(self, ItemLink, ...)
			-- Attach an icon to the tooltip first so that an existing icon can be hidden if the new hyperlink doesn't have one.
			PawnAttachIconToTooltip(ItemRefTooltip, false, ItemLink)
			if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
			PawnUpdateTooltip("ItemRefTooltip", "SetHyperlink", ItemLink, ...)
		end)
	ItemRefTooltip:SetScript("OnEnter", function() _, PawnLastHoveredItem = ItemRefTooltip:GetItem() end)
	ItemRefTooltip:SetScript("OnLeave", function() PawnLastHoveredItem = nil end)
	ItemRefTooltip:SetScript("OnMouseUp",
		function(object, button)
			if button == "RightButton" then
				local _, ItemLink = ItemRefTooltip:GetItem()
				PawnUI_SetCompareItemAndShow(2, ItemLink)
			end
		end)
	
	-- The loot roll window
	local LootRollClickHandler =
		function(object, button)
			if button == "RightButton" then
				local ItemLink = GetLootRollItemLink(object:GetParent().rollID)
				PawnUI_SetCompareItemAndShow(2, ItemLink)
			end
		end
	GroupLootFrame1IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame2IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame3IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame4IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	
	-- The "currently equipped" tooltips (two, in case of rings, trinkets, and dual wielding)
	hooksecurefunc(ShoppingTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip1, true) end)
	hooksecurefunc(ShoppingTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip2, true) end)
	if ShoppingTooltip3 then -- *** WoW 3.0
		-- PROBLEM: *** In current Wrath builds, this returns the same ItemLink as the original item (the view-as-level parameter hasn't changed).
		--hooksecurefunc(ShoppingTooltip3, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip3", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip3, true) end)
	end
	hooksecurefunc(ShoppingTooltip1, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip1", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip1, true) end) -- EQCompare compatibility
	hooksecurefunc(ShoppingTooltip2, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip2", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip2, true) end) -- EQCompare compatibility
	if ShoppingTooltip3 then -- *** WoW 3.0
		--hooksecurefunc(ShoppingTooltip3, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip3", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip3, true) end) -- EQCompare compatibility, assuming EQCompare adds support for the third shopping tooltip
	end
		
	-- MultiTips compatibility
	if MultiTips then
		VgerCore.HookInsecureFunction(ItemRefTooltip2, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip2", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip2, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip3, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip3", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip3, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip4, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip4", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip4, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip5, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip5", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip5, false, ItemLink) end)
	end
	
	-- EquipCompare compatibility
	if ComparisonTooltip1 then
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end)
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end)
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetInventoryItem", ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end) -- EquipCompare with CharactersViewer
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetInventoryItem", ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end) -- EquipCompare with CharactersViewer
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end) -- EquipCompare with Armory
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end) -- EquipCompare with Armory
	end
	
	-- AtlasLoot Enhanced compatibility
	if AtlasLootTooltip then
		VgerCore.HookInsecureFunction(AtlasLootTooltip, "SetHyperlink", function(self, ...) PawnUpdateTooltip("AtlasLootTooltip", "SetHyperlink", ...) end)
	end
	
	-- LinkWrangler compatibility
	if LinkWrangler then
		LinkWrangler.RegisterCallback("Pawn", PawnLinkWranglerOnTooltip, "refresh")
		LinkWrangler.RegisterCallback("Pawn", PawnLinkWranglerOnTooltip, "refreshcomp")
	end

end

function PawnOnAddonLoaded(AddonName)
	if AddonName == "Blizzard_InspectUI" then
		-- After the inspect UI is loaded, we want to hook it to add the Pawn button.
		PawnUI_InspectPawnButton_Attach()
	end
end

-- Resets all Pawn options and scales.  Used to set the saved variable to a default state.
function PawnResetOptions()
	PawnOptions = nil
	PawnSetEmptyOptions()
end

-- Sets values for any options that don't have a value set yet.  Useful when upgrading.
function PawnSetEmptyOptions()
	if not PawnOptions then PawnOptions = {} end
	
	if PawnOptions.Debug == nil then PawnOptions.Debug = false end
	if PawnOptions.Digits == nil  then PawnOptions.Digits = 1 end
	if PawnOptions.ShowAsterisks == nil  then PawnOptions.ShowAsterisks = PawnShowAsterisksNonzero end
	if PawnOptions.ShowUnenchanted == nil  then PawnOptions.ShowUnenchanted = true end
	if PawnOptions.ShowEnchanted == nil  then PawnOptions.ShowEnchanted = true end
	if PawnOptions.ShowItemID == nil  then PawnOptions.ShowItemID = false end
	if PawnOptions.ShowItemLevel == nil  then PawnOptions.ShowItemLevel = false end
	if PawnOptions.AlignNumbersRight == nil  then PawnOptions.AlignNumbersRight = false end
	if PawnOptions.ShowSpace == nil  then PawnOptions.ShowSpace = false end
	if PawnOptions.ButtonPosition == nil  then PawnOptions.ButtonPosition = PawnButtonPositionRight end
	if PawnOptions.ShowTooltipIcons == nil  then PawnOptions.ShowTooltipIcons = true end
	
	if not PawnOptions.Scales then
		PawnOptions.Scales = {}
		PawnResetScales()
	end
	
	PawnRecreateAnnotationFormats()
end

-- Once per new version of Pawn that adds keybindings, bind the new actions to default keys.
function PawnSetDefaultKeybindings()
	if PawnOptions.LastKeybindingsSet == nil  then PawnOptions.LastKeybindingsSet = 0 end
	local BindingSet = false
	
	-- Keybindings for opening the Pawn UI and setting comparison items.
	if PawnOptions.LastKeybindingsSet < 1 then
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_TOGGLE_UI_DEFAULT_KEY, "PAWN_TOGGLE_UI") or BindingSet
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_COMPARE_LEFT_DEFAULT_KEY, "PAWN_COMPARE_LEFT") or BindingSet
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_COMPARE_RIGHT_DEFAULT_KEY, "PAWN_COMPARE_RIGHT") or BindingSet
	end
	
	-- If any keybindings were changed, save the user's bindings.
	if BindingSet then SaveBindings(GetCurrentBindingSet()) end
	
	-- Record that we've set those keybindings, so we don't try to set them again in the future, even if
	-- the user clears them.
	PawnOptions.LastKeybindingsSet = 1
end

-- Sets a keybinding to its default value if it's not already assigned to something else.  Returns true if anything was changed.
function PawnSetKeybindingIfAvailable(Key, Binding)
	-- Is this key already bound?
	local ExistingBinding = GetBindingAction(Key)
	if not ExistingBinding or ExistingBinding == "" then
		-- Bind this key to its default Pawn action.
		SetBinding(Key, Binding)
		return true
	else
		-- This key is already bound, so do nothing.
		return false
	end
end

-- Returns an empty Pawn scale table.
function PawnGetEmptyScale()
	return { Values = {} }
end

-- Returns the default Pawn scale table.
function PawnGetDefaultScale()
	return 
	{
		["SmartGemSocketing"] = true,
		["Values"] =
		{
			["Strength"] = 1,
			["Agility"] = 1,
			["Stamina"] = 2/3,
			["Intellect"] = 1,
			["Spirit"] = 1,
			["Armor"] = 0.1,
			["Dps"] = 3.4,
			["ExpertiseRating"] = 1,
			["HitRating"] = 1,
			["CritRating"] = 1,
			["ArmorPenetration"] = 1/7,
			["SpellHitRating"] = 1,
			["SpellCritRating"] = 1,
			["ResilienceRating"] = 1,
			["HasteRating"] = 1,
			["SpellHasteRating"] = 1,
			["Ap"] = 0.5,
			["FeralAp"] = 0.4,
			["Rap"] = 0.4,
			["Mp5"] = 2.5,
			["Hp5"] = 2.5,
			["Mana"] = 1/15,
			["Health"] = 1/15,
			["BlockValue"] = 0.65,
			["BlockRating"] = 1,
			["DefenseRating"] = 1,
			["DodgeRating"] = 1,
			["ParryRating"] = 1,
			["SpellPower"] = 6/7,
			["SpellDamage"] = 0.4,
			["Healing"] = 0.455,
			["SpellPenetration"] = 0.8,
			["FireSpellDamage"] = 0.7,
			["ShadowSpellDamage"] = 0.7,
			["NatureSpellDamage"] = 0.7,
			["ArcaneSpellDamage"] = 0.7,
			["FrostSpellDamage"] = 0.7,
			["HolySpellDamage"] = 0.7,
			["AllResist"] = 2.5,
			["FireResist"] = 1,
			["ShadowResist"] = 1,
			["NatureResist"] = 1,
			["ArcaneResist"] = 1,
			["FrostResist"] = 1,
			["RedSocket"] = 4,
			["YellowSocket"] = 4,
			["BlueSocket"] = 4,
			["MetaSocket"] = 4,
		},
	}
end

-- LinkWrangler compatibility
function PawnLinkWranglerOnTooltip(Tooltip, ItemLink)
	if not Tooltip then return end
	PawnUpdateTooltip(Tooltip:GetName(), "SetHyperlink", ItemLink)
	PawnAttachIconToTooltip(Tooltip, false, ItemLink)
end

------------------------------------------------------------
-- Pawn core methods
------------------------------------------------------------

-- If debugging is enabled, show a message; otherwise, do nothing.
function PawnDebugMessage(Message)
	if PawnOptions.Debug then
		VgerCore.Message(Message)
	end
end

-- Processes an Pawn slash command.
function PawnCommand(Command)
	if Command == "" then
		PawnUIShow()
	elseif Command == PawnLocal.DebugOnCommand then
		PawnOptions.Debug = true
		PawnResetTooltips()
		if PawnUIFrame_DebugCheck then PawnUIFrame_DebugCheck:SetChecked(PawnOptions.Debug) end
	elseif Command == PawnLocal.DebugOffCommand then
		PawnOptions.Debug = false
		PawnResetTooltips()
		if PawnUIFrame_DebugCheck then PawnUIFrame_DebugCheck:SetChecked(PawnOptions.Debug) end
	else
		PawnUsage()
	end
end

-- Displays Pawn usage information.
function PawnUsage()
	VgerCore.Message(" ")
	VgerCore.MultilineMessage(PawnLocal.Usage)
	VgerCore.Message(" ")
end

-- Returns an empty item for use in the item cache.
function PawnGetEmptyCachedItem(NewItemLink, NewItemName, NewNumLines)
	-- Also includes properties set to nil by default: Stats, SocketBonusStats, UnenchantedState, UnenchantedSocketBonusStats, Values, Level, ItemID
	return { Name = NewItemName, NumLines = NewNumLines, UnknownLines = {}, Link = NewItemLink }
end

-- Searches the item cache for an item, and either returns the correct cached item, or nil.
function PawnGetCachedItem(ItemLink, ItemName, NumLines)
	-- If the item cache is empty, skip all this...
	if (not PawnItemCache) or (#PawnItemCache == 0) then return end
	-- If debug mode is on, the cache is disabled.
	if PawnOptions.Debug then return end

	-- Otherwise, search the item cache for this item.
	for _, CachedItem in pairs(PawnItemCache) do
		if NumLines and (NumLines == CachedItem.NumLines) then
			if ItemLink and CachedItem.Link then
				if ItemLink == CachedItem.Link then return CachedItem end
			else
				if ItemName == CachedItem.Name then return CachedItem end
			end
		end
	end
end

-- Adds an item to the item cache, removing existing items if necessary.
function PawnCacheItem(CachedItem)
	-- If debug mode is on, the cache is disabled.
	if PawnOptions.Debug then return end
	
	-- Cache it.
	if PawnItemCacheMaxSize <= 0 then return end
	if not PawnItemCache then PawnItemCache = {} end
	table.insert(PawnItemCache, CachedItem)
	while #PawnItemCache > PawnItemCacheMaxSize do
		table.remove(PawnItemCache, 0)
	end
end

-- Clears the item cache.
function PawnClearCache()
	PawnItemCache = nil
end

-- Clears only the calculated values for items in the cache, retaining things like stats.
function PawnClearCacheValuesOnly()
	if not PawnItemCache then return end
	for _, CachedItem in pairs(PawnItemCache) do
		CachedItem.Values = nil
	end
end

-- Performance notes useful to the cache and general item processing:
-- * It's faster to store the size of a table in a separate variable than to use #tablename.
-- * It's faster to use tinsert than table.insert.

-- Clears all calculated values and causes them to be recalculated the next time tooltips are displayed.  The stats
-- will not be re-read next time, however.
function PawnResetTooltips()
	-- Clear out the calculated values in the cache, leaving item data.
	PawnClearCacheValuesOnly()
	-- Then, attempt to reset tooltips where possible.  On-hover tooltips don't need to be reset manually, but the
	-- item link tooltip does.
	PawnResetTooltip("ItemRefTooltip")
	PawnResetTooltip("ItemRefTooltip2") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip3") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip4") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip5") -- MultiTips compatibility
	PawnResetTooltip("ComparisonTooltip1") -- EquipCompare compatibility
	PawnResetTooltip("ComparisonTooltip2") -- EquipCompare compatibility
	PawnResetTooltip("AtlasLootTooltip") -- AtlasLoot compatibility
end

-- Attempts to reset a single tooltip, causing Pawn values to be recalculated.  Returns true if successful.
function PawnResetTooltip(TooltipName)
	local Tooltip = getglobal(TooltipName)
	if not Tooltip or not Tooltip.IsShown or not Tooltip:IsShown() or not Tooltip.GetItem then return end
	
	local _, ItemLink = Tooltip:GetItem()
	if not ItemLink then return end
	
	Tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	Tooltip:SetHyperlink(ItemLink)
	Tooltip:Show()
	return true
end

-- Recalculates the total value of all stats in a scale.
function PawnRecalculateScaleTotal(ScaleName)
	-- Find the appropriate scale.
	local ThisScale = PawnOptions.Scales[ScaleName]
	if ThisScale then ThisScale = ThisScale.Values end
	if not ThisScale then
		-- If the passed-in scale doesn't exist, remove it from our cache and exit.
		PawnScaleTotals[ScaleName] = nil
		return
	end
	
	-- Calculate the total.
	local Total = 0
	for _, Value in pairs(ThisScale) do
		if Value then Total = Total + Value end
	end
	PawnScaleTotals[ScaleName] = Total
end

-- Recreates the tooltip annotation format strings.
function PawnRecreateAnnotationFormats()
	PawnUnenchantedAnnotationFormat = "%s%s:  %." .. PawnOptions.Digits .. "f"
	PawnEnchantedAnnotationFormat = PawnUnenchantedAnnotationFormat .. "  %s(%." .. PawnOptions.Digits .. "f)"
end

-- Gets the item data for a specific item link.  Retrieves the information from the cache when possible; otherwise, it gets fresh information.
-- Return value type is the same as PawnGetCachedItem.
function PawnGetItemData(ItemLink)
	VgerCore.Assert(ItemLink, "ItemLink must be non-null!")
	if not ItemLink then return end
	
	-- Only item links are supported; other links are not.
	if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
	
	-- If we have an item link, we can extract basic data from it from the user's WoW cache (not the Pawn item cache).
	-- We get a new, normalized version of ItemLink so that items don't end up in the cache multiple times if they're requested
	-- using different styles of links that all point to the same item.
	ItemID = PawnGetItemIDFromLink(ItemLink)
	local ItemName, NewItemLink, _, ItemLevel = GetItemInfo(ItemLink)
	if NewItemLink then
		ItemLink = NewItemLink
	else
		-- We didn't get a new item link.  This is almost certainly because the item is not in the user's local WoW cache.
		-- REVIEW: In the future, would it be possible to detect this case, and then poll the tooltip until item information
		-- comes back, and THEN parse and annotate it?  There's also an OnTooltipSetItem event.
	end
	
	-- Now, with that information, we can look up the item in the Pawn item cache.
	local Item = PawnGetCachedItem(nil, ItemName, ItemNumLines)
	if Item and Item.Values then
		return Item
	end
	-- If Item is non-null but Item.Values is null, we're not done yet!

	-- If we don't have a cached item at all, that means we have to load a tooltip and parse it.
	if not Item then
		Item = PawnGetEmptyCachedItem(ItemLink, ItemName, ItemNumLines)
		Item.Level = ItemLevel
		Item.ID = ItemID
		if PawnOptions.Debug then
			PawnDebugMessage(" ")
			PawnDebugMessage("====================")
			PawnDebugMessage(ItemLink .. VgerCore.Color.Green .. " (" .. tostring(PawnGetItemIDsForDisplay(ItemLink)) .. VgerCore.Color.Green .. ")")
		end
		
		-- First the enchanted stats.
		Item.Stats, Item.SocketBonusStats, Item.UnknownLines, Item.PrettyLink = PawnGetStatsFromTooltipWithMethod("PawnPrivateTooltip", true, "SetHyperlink", Item.Link)

		-- Then, the unenchanted stats.  But, we only need to do this if the item is enchanted or socketed.  PawnUnenchantItemLink
		-- will return nil if the item isn't enchanted, so we can skip that process.
		local UnenchantedItemLink = PawnUnenchantItemLink(ItemLink)
		if UnenchantedItemLink then
			PawnDebugMessage(" ")
			PawnDebugMessage(PawnLocal.UnenchantedStatsHeader)
			Item.UnenchantedStats, Item.UnenchantedSocketBonusStats = PawnGetStatsForItemLink(UnenchantedItemLink, true)
			if not Item.UnenchantedStats then
				PawnDebugMessage(PawnLocal.FailedToGetUnenchantedItemMessage)
			end
		else
			-- If there was no unenchanted item link, then it's because the original item was not
			-- enchanted.  So, the unenchanted item is the enchanted item; copy the stats over.
			Item.UnenchantedStats = Item.Stats
			Item.UnenchantedSocketBonusStats = Item.SocketBonusStats
		end
		
		-- Cache this item so we don't have to re-parse next time.
		PawnCacheItem(Item)
	end
	
	-- Recalculate the scale values for the item only if necessary.
	PawnRecalculateItemValuesIfNecessary(Item)
	
	return Item
end

-- Gets the item data for a specific item.  Retrieves the information from the cache when possible; otherwise, gets it from the tooltip specified.
-- Return value type is the same as PawnGetCachedItem.
function PawnGetItemDataFromTooltip(TooltipName, MethodName, Param1, ...)
	VgerCore.Assert(TooltipName, "TooltipName must be non-null!")
	VgerCore.Assert(MethodName, "MethodName must be non-null!")
	if (not TooltipName) or (not MethodName) then return end
	
	-- First, find the tooltip.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	
	-- If we have a tooltip, try to get an item link from it.
	local ItemLink, ItemID, ItemLevel
	if (MethodName == "SetHyperlink") and Param1 then
		-- Special case: if the method is SetHyperlink, then we already have an item link.
		-- (Normally, GetItem will work, but SetHyperlink is used by some mod compatibility code.)
		ItemLink = Param1
	elseif Tooltip.GetItem then
		_, ItemLink = Tooltip:GetItem()
	end
	
	-- If we got an item link from the tooltip (or it was passed in), we can go through the simpler and more effective code that specifically
	-- uses item links, and skip the rest of this function.
	if ItemLink then
		return PawnGetItemData(ItemLink)
	end
	
	-- If we made it this far, then we're in the degenerate case where the tooltip doesn't have item information.  Let's look for the item's name,
	-- and maybe we'll get lucky and find that in our item cache.
	local ItemName, ItemNameLineNumber = PawnGetItemNameFromTooltip(TooltipName)
	if (not ItemName) or (not ItemNameLineNumber) then return end
	local ItemNumLines = Tooltip:NumLines()
	local Item = PawnGetCachedItem(nil, ItemName, ItemNumLines)
	if Item and Item.Values then
		return Item
	end
	-- If Item is non-null but Item.Values is null, we're not done yet!
	
	-- Ugh, the tooltip doesn't have item information and this item isn't in the Pawn item cache, so we'll have to try to parse this tooltip.	
	if not Item then
		Item = PawnGetEmptyCachedItem(nil, ItemName, ItemNumLines)
		PawnDebugMessage(" ")
		PawnDebugMessage("====================")
		PawnDebugMessage(VgerCore.Color.Green .. ItemName)
		
		-- Since we don't have an item link, we have to just read stats from the original tooltip, so we only get enchanted values.
		PawnFixStupidTooltipFormatting(TooltipName)
		Item.Stats, Item.SocketBonusStats, Item.UnknownLines = PawnGetStatsFromTooltip(TooltipName, true)
		PawnDebugMessage(PawnLocal.FailedToGetItemLinkMessage)
		
		-- Cache this item so we don't have to re-parse next time.
		PawnCacheItem(Item)
	end
	
	-- Recalculate the scale values for the item only if necessary.
	PawnRecalculateItemValuesIfNecessary(Item)
	
	return Item
end

-- Returns the same information as PawnGetItemData, but based on an inventory slot index instead of an item link.
-- If requested, data for the base unenchanted item can be returned instead; otherwise, the actual item is returned.
function PawnGetItemDataForInventorySlot(Slot, Unenchanted)
	local ItemLink = GetInventoryItemLink("player", Slot)
	if not ItemLink then return end
	if Unenchanted then
		local UnenchantedItem = PawnUnenchantItemLink(ItemLink)
		if UnenchantedItem then ItemLink = UnenchantedItem end
	end
	return PawnGetItemData(ItemLink)
end

-- Recalculates the scale values for a cached item if necessary, and returns them.
function PawnRecalculateItemValuesIfNecessary(Item)
	-- We now have stats for the item.  If values aren't already calculated for the item, calculate those.  This happens when we have
	-- just retrieved the stats for the item, and also when the item values were cleared from the cache but not the stats.
	if not Item.Values then
		-- Calculate each of the values for which there are scales.
		Item.Values = PawnGetAllItemValues(Item.Stats, Item.SocketBonusStats, Item.UnenchantedStats, Item.UnenchantedSocketBonusStats, true)

		PawnDebugMessage(" ")
	end
	
	return Item.Values
end

-- Returns a single scale value (in both its enchanted and unenchanted forms) for a cached item.  Returns nil for any values that are not present.
function PawnGetSingleValueFromItem(Item, ScaleName)
	local ValuesTable = PawnRecalculateItemValuesIfNecessary(Item)
	if not ValuesTable then return end
	
	-- The scale values are sorted alphabetically, so we need to go through the list.
	local Count = #ValuesTable
	for i = 1, Count do
		local Value = ValuesTable[i]
		if Value[1] == ScaleName then
			return Value[2], Value[3]
		end
	end
	
	-- It's not here; return nil.
end

-- Updates a specific tooltip.
function PawnUpdateTooltip(TooltipName, MethodName, Param1, ...)
	if not PawnOptions.Scales then return end
	
	-- Get information for the item in this tooltip.  This function will use item links and cached data whenever possible.
	local Item = PawnGetItemDataFromTooltip(TooltipName, MethodName, Param1, ...)
	-- If there's no item data, then something failed, so we can't update this tooltip.
	if not Item then return end
	
	-- If this is the main GameTooltip, remember the item that was hovered over.
	-- AtlasLoot compatibility: enable hover comparison for AtlasLoot tooltips too.
	if TooltipName == "GameTooltip" or TooltipName == "AtlasLootTooltip" then
		PawnLastHoveredItem = Item.Link
	end
	
	-- Now, just update the tooltip with the item data we got from the previous call.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then
		VgerCore.Fail("Where'd the tooltip go?  I seem to have misplaced it.")
		return
	end
	
	-- If necessary, add a blank line to the tooltip.
	local AddSpace = PawnOptions.ShowSpace
	
	-- Add the scale values to the tooltip.
	if AddSpace and #Item.Values > 0 then Tooltip:AddLine(" ") AddSpace = false end
	PawnAddValuesToTooltip(Tooltip, Item.Values)
	
	-- If there were unrecognized values, annotate those lines.
	local Annotated = false
	if Item.UnknownLines and (PawnOptions.ShowAsterisks == PawnShowAsterisksAlways) or ((PawnOptions.ShowAsterisks == PawnShowAsterisksNonzero or PawnOptions.ShowAsterisks == PawnShowAsterisksNonzeroNoText) and #Item.Values > 0) then
		Annotated = PawnAnnotateTooltipLines(TooltipName, Item.UnknownLines)
	end
	-- If we annotated the tooltip for unvalued stats, display a message.
	if (Annotated and PawnOptions.ShowAsterisks ~= PawnShowAsterisksNonzeroNoText) then
		Tooltip:AddLine(PawnLocal.AsteriskTooltipLine, VgerCore.Color.BlueR, VgerCore.Color.BlueG, VgerCore.Color.BlueB)
	end

	-- Add the item ID to the tooltip if known.
	if PawnOptions.ShowItemID and Item.Link then
		local IDs = PawnGetItemIDsForDisplay(Item.Link)
		if IDs then
			if PawnOptions.AlignNumbersRight then
				Tooltip:AddDoubleLine(PawnLocal.ItemIDTooltipLine, IDs, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
			else
				Tooltip:AddLine(PawnLocal.ItemIDTooltipLine .. ":  " .. IDs, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
			end
		end
	end
	-- Add the item level to the tooltip, but don't show it for items level 1 or lower.
	if PawnOptions.ShowItemLevel and Item.Level and (Item.Level > 1) then
		if PawnOptions.AlignNumbersRight then
			Tooltip:AddDoubleLine(PawnLocal.ItemLevelTooltipLine,  Item.Level, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
		else
			Tooltip:AddLine(PawnLocal.ItemLevelTooltipLine .. ":  " .. Item.Level, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
		end
	end
	
	-- Show the updated tooltip.	
	Tooltip:Show()
end

-- Returns a sorted list of all scale values for an item (and its unenchanted version, if supplied).
-- Parameters:
-- 	Item: A table of item values in the format returned by GetStatsFromTooltip.
-- 	SocketBonus: A table of socket bonus values in the format returned by GetStatsFromTooltip.
-- 	UnenchantedItem: A table of unenchanted item values in the format returned by GetStatsFromTooltip.
-- 	UnenchantedItemSocketBonus: A table of unenchanted item socket bonuses in the format returned by GetStatsFromTooltip.
--	DebugMessages: If true, debug messages will be printed.
-- Return value: ItemValues
-- 	ItemValues: A sorted table of scale values in the following format: { {"Scale 1", 100, 90}, {"Scale 2", 200, 175} }.
function PawnGetAllItemValues(Item, SocketBonus, UnenchantedItem, UnenchantedItemSocketBonus, DebugMessages)
	local ItemValues = {}
	for ScaleName, Scale in pairs(PawnOptions.Scales) do
		if DebugMessages then
			PawnDebugMessage(" ")
			PawnDebugMessage(ScaleName .. " --------------------")
		end
		local Value
		if Item then
			Value = PawnGetItemValue(Item, SocketBonus, ScaleName, DebugMessages and PawnOptions.ShowEnchanted)
		end
		local UnenchantedValue
		if UnenchantedItem then
			if DebugMessages and PawnOptions.ShowEnchanted and PawnOptions.ShowUnenchanted then
				PawnDebugMessage(" ")
				PawnDebugMessage(PawnLocal.UnenchantedStatsHeader)
			end
			UnenchantedValue = PawnGetItemValue(UnenchantedItem, UnenchantedItemSocketBonus, ScaleName, DebugMessages and PawnOptions.ShowUnenchanted)
		end
		
		-- Add these values to the table.
		if Value == nil then Value = 0 end
		if UnenchantedValue == nil then UnenchantedValue = 0 end
		if Value > 0 or UnenchantedValue > 0 then
			table.insert(ItemValues, {ScaleName, Value, UnenchantedValue})
		end
	end
	
	-- Sort the table, then return it.
	table.sort(ItemValues, PawnItemValueCompare)
	return ItemValues
end

-- Adds an array of item values to a tooltip, handling formatting options.
-- Parameters: Tooltip, ItemValues
-- 	Tooltip: The tooltip to annotate.  (Not a name.)
-- 	ItemValues: An array of item values to use to annotate the tooltip, in the format returned by PawnGetAllItemValues.
--	OnlyFirstValue: If true, only the first value (the "enchanted" one) is used, regardless of the user's settings.
function PawnAddValuesToTooltip(Tooltip, ItemValues, OnlyFirstValue)
	-- First, check input arguments.
	if type(Tooltip) ~= "table" then
		VgerCore.Fail("Tooltip must be a valid tooltip, not '" .. type(Tooltip) .. "'.")
		return
	end
	if not ItemValues then return end
	
	-- Loop through all of the item value subtables.
	for _, Entry in pairs(ItemValues) do
		local ScaleName, Value, UnenchantedValue = Entry[1], Entry[2], Entry[3]
		local Scale = PawnOptions.Scales[ScaleName]
		VgerCore.Assert(Scale ~= nil, "Scale name in item value list doesn't exist!")
		
		if not Scale.Hidden then
			-- Ignore values that we don't want to display.
			if OnlyFirstValue then
				UnenchantedValue = 0
			else
				if not PawnOptions.ShowEnchanted then Value = 0 end
				if not PawnOptions.ShowUnenchanted then UnenchantedValue = 0 end
			end
		
			local TooltipText = nil
			local TextColor = VgerCore.Color.Blue
			local UnenchantedTextColor = VgerCore.Color.DarkBlue
			if Scale.Color and string.len(Scale.Color) == 6 then TextColor = "|cff" .. Scale.Color end
			if Scale.UnenchantedColor and string.len(Scale.UnenchantedColor) == 6 then UnenchantedTextColor = "|cff" .. Scale.UnenchantedColor end
			
			if Value and Value ~= UnenchantedValue and Value > 0 and UnenchantedValue and UnenchantedValue > 0 then
				TooltipText = string.format(PawnEnchantedAnnotationFormat, TextColor, ScaleName, tostring(Value), UnenchantedTextColor, tostring(UnenchantedValue))
			elseif Value and Value > 0 then
				TooltipText = string.format(PawnUnenchantedAnnotationFormat, TextColor, ScaleName, tostring(Value))
			elseif UnenchantedValue and UnenchantedValue > 0 then
				TooltipText = string.format(PawnUnenchantedAnnotationFormat, TextColor, ScaleName, tostring(UnenchantedValue))
			end
			
			-- Add the line to the tooltip.
			if TooltipText then
				-- This could be optimized a bit, but it's not incredibly necessary.
				if PawnOptions.AlignNumbersRight then
					local Pos = string.find(TooltipText, ":")
					local Left = string.sub(TooltipText, 0, Pos - 1) -- ignore the colon
					local Right = string.sub(TooltipText, 0, 10) .. string.sub(TooltipText, Pos + 3) -- add the color string and ignore the spaces following the colon
					Tooltip:AddDoubleLine(Left, Right)
				else
					Tooltip:AddLine(TooltipText)
				end
			end
		end
	end
end

-- Returns the total scale values of all equipped items.  Only counts enchanted values.
-- Parameters: UnitName
--		UnitName: The name of the unit from whom the inventory item should be retrieved.  Defaults to "player".
-- Return value: ItemValues, Count
-- 		ItemValues: Same as PawnGetAllItemValues, or nil if unsuccessful.
--		Count: The number of item values calculated.
function PawnGetInventoryItemValues(UnitName)
	local Total = {}
	local SlotStats
	for Slot = 0, 19 do
		SlotStats, SlotSocketBonusStats = PawnGetStatsForInventorySlot(Slot, false, UnitName)
		ItemValues = PawnGetAllItemValues(SlotStats, SlotSocketBonusStats)
		-- Now, add these values to our running totals.
		for _, Entry in pairs(ItemValues) do
			local ScaleName, Value = Entry[1], Entry[2]
			PawnAddStatToTable(Total, ScaleName, Value) -- (not actually stats, but the function does what we want)
		end
	end
	-- Once we're done, we need to convert our addition table to one that we can return.
	local TotalValues = {}
	local Count = 0
	for ScaleName, Value in pairs(Total) do
		table.insert(TotalValues, { ScaleName, Value, 0 })
		Count = Count + 1
	end
	return TotalValues, Count
end

-- Works around annoying inconsistencies in the way that Blizzard formats tooltip text.
-- Enchantments and random item properties ("of the whale") are formatted like this: "|cffffffff+15 Intellect|r\r\n".
-- We correct this here.
function PawnFixStupidTooltipFormatting(TooltipName)
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	for i = 1, Tooltip:NumLines() do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		local Text = LeftLine:GetText()
		local Updated = false
		if Text and string.sub(Text, 1, 2) ~= "\n" then
			-- First, look for a color.
			if string.sub(Text, 1, 10) == "|cffffffff" then
				Text = string.sub(Text, 11)
				LeftLine:SetTextColor(1, 1, 1)
				Updated = true
			end
			-- Then, look for a trailing \r\n, unless that's all that's left of the string.
			if (string.len(Text) > 2) and (string.byte(Text, -1) == 10) then
				Text = string.sub(Text, 1, -4)
				Updated = true
			end
			-- Then, look for a trailing color restoration flag.
			if string.sub(Text, -2) == "|r" then
				Text = string.sub(Text, 1, -3)
				Updated = true
			end
			-- Update the tooltip with the new string.
			if Updated then
				--VgerCore.Message("Old: [" .. PawnEscapeString(LeftLine:GetText()) .. "]")
				LeftLine:SetText(Text)
				--VgerCore.Message("New: [" .. PawnEscapeString(Text) .. "]")
			end
		end
	end
end

-- Calls a method on a tooltip and then returns stats from that tooltip.
-- Parameters: ItemID, DebugMessages
--		TooltipName: The name of the tooltip to use.
--		DebugMessages: If true, debug messages will be shown.
--		Method: The name of the method to call on the tooltip, followed optionally by arguments to that method.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsFromTooltipWithMethod(TooltipName, DebugMessages, MethodName, ...)
	if not TooltipName or not MethodName then
		VgerCore.Fail("PawnGetStatsFromTooltipWithMethod requires a valid tooltip name and method name.")
		return
	end
	local Tooltip = getglobal(TooltipName)
	Tooltip:ClearLines() -- Without this, sometimes SetHyperlink seems to fail when called rapidly
	local Method = Tooltip[MethodName]
	Method(Tooltip, ...)
	PawnFixStupidTooltipFormatting(TooltipName)
	return PawnGetStatsFromTooltip(TooltipName, DebugMessages)
end

-- Reads the stats for a given item ID, eventually calling PawnGetStatsFromTooltip.
-- Parameters: ItemID, DebugMessages
--		ItemID: The item ID for which to get stats.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForItemID(ItemID, DebugMessages)
	if not ItemID then
		VgerCore.Fail("PawnGetStatsForItemID requires a valid item ID.")
		return
	end
	return PawnGetStatsForItemLink("item:" .. ItemID, DebugMessages)
end

-- Reads the stats for a given item link, eventually calling PawnGetStatsFromTooltip.
-- Parameters: ItemLink, DebugMessages
--		ItemLink: The item link for which to get stats.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForItemLink(ItemLink, DebugMessages)
	if not ItemLink then
		VgerCore.Fail("PawnGetStatsForItemLink requires a valid item link.")
		return
	end
	-- Other types of hyperlinks, such as enchant, quest, or spell are ignored by Pawn.
	if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
	
	PawnPrivateTooltip:ClearLines() -- Without this, sometimes SetHyperlink seems to fail when called rapidly
	PawnPrivateTooltip:SetHyperlink(ItemLink)
	PawnFixStupidTooltipFormatting("PawnPrivateTooltip")
	return PawnGetStatsFromTooltip("PawnPrivateTooltip", DebugMessages)
end

-- Returns the stats of an equipped item, eventually calling PawnGetStatsFromTooltip.
-- 	Parameters: Slot
-- 		Slot: The slot number (0-19).  If not looping through all slots, use GetInventorySlotInfo("HeadSlot") to get the number.
--		DebugMessages: If true, debug messages will be shown.
--		UnitName: The name of the unit from whom the inventory item should be retrieved.  Defaults to "player".
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForInventorySlot(Slot, DebugMessages, UnitName)
	if type(Slot) ~= "number" then
		VgerCore.Fail("PawnGetStatsForInventorySlot requires a valid slot number.  Did you mean to use GetInventorySlotInfo to get a number?")
		return
	end
	if not UnitName then UnitName = "player" end
	return PawnGetStatsFromTooltipWithMethod("PawnPrivateTooltip", DebugMessages, "SetInventoryItem", UnitName, Slot)
end

-- Reads the stats from a tooltip.
-- Returns a table mapping stat name with a quantity of that statistic.
-- For example, ReturnValue["Strength"] = 12.
-- Parameters: TooltipName, DebugMessages
--		TooltipName: The tooltip to read.
--		DebugMessages: If true (default), debug messages will be shown.
-- Return value: Stats, UnknownLines
--		Stats: The table of stats for the item.
--		SocketBonusStats: The table of stats for the item's socket bonus.
--		UnknownLines: A list of lines in the tooltip that were not understood.
--		PrettyLink: A beautified item link, if available.
function PawnGetStatsFromTooltip(TooltipName, DebugMessages)
	local Stats, SocketBonusStats, UnknownLines = {}, {}, {}
	local HadUnknown = false
	local SocketBonusIsValid = false
	local Tooltip = getglobal(TooltipName)
	if DebugMessages == nil then DebugMessages = true end
	
	-- Get the item name.  It could be on line 2 if the first line is "Currently Equipped".
	local ItemName, ItemNameLineNumber = PawnGetItemNameFromTooltip(TooltipName)
	if (not ItemName) or (not ItemNameLineNumber) then
		--VgerCore.Fail("Failed to find name of item on the hidden tooltip")
		return
	end

	-- First, check for the ignored item names: for example, any item that starts with "Design:" should
	-- be ignored, because it's a jewelcrafting design, not a real item with stats.
	for _, ThisName in pairs(PawnIgnoreNames) do
		if string.sub(ItemName, 1, string.len(ThisName)) == ThisName then
			-- This is a known ignored item name; don't return any stats.
			return
		end
	end
	
	-- Now, read the tooltip for stats.
	for i = ItemNameLineNumber + 1, Tooltip:NumLines() do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		local LeftLineText = LeftLine:GetText()
		
		-- Look for this line in the "kill lines" list.  If it's there, we're done.
		local IsKillLine = false
		-- Dirty, dirty hack for 2.3: check the color of the text; if it's "name of item set" yellow, then treat it as a kill line.
		-- Not needed because we look for the (1/8) at the end instead.
		--local r, g, b = LeftLine:GetTextColor()
		--if (math.abs(r - 1) < .01) and (math.abs(g - .82) < .01) and (b < .01) then
		--	IsKillLine = true
		--end
		if not IsKillLine then
			for _, ThisKillLine in pairs(PawnKillLines) do
				if string.find(LeftLineText, ThisKillLine) then
					-- This is a known ignored kill line; stop now.
					IsKillLine = true
					break
				end
			end
		end
		if IsKillLine then break end
		
		for Side = 1, 2 do
			local CurrentParseText, RegexTable, CurrentDebugMessages, IgnoreErrors
			if Side == 1 then
				CurrentParseText = LeftLineText
				RegexTable = PawnRegexes
				CurrentDebugMessages = DebugMessages
				IgnoreErrors = false
			else
				local RightLine = getglobal(TooltipName .. "TextRight" .. i)
				CurrentParseText = RightLine:GetText()
				if (not CurrentParseText) or (CurrentParseText == "") then break end
				RegexTable = PawnRightHandRegexes
				CurrentDebugMessages = false
				IgnoreErrors = true
			end
			
			local ThisLineIsSocketBonus = false
			if Side == 1 and string.sub(CurrentParseText, 1, string.len(PawnSocketBonusPrefix)) == PawnSocketBonusPrefix then
				-- This line is the socket bonus.
				ThisLineIsSocketBonus = true
				if LeftLine.GetTextColor then
					SocketBonusIsValid = (LeftLine:GetTextColor() == 0) -- green's red component is 0, but grey's red component is .5	
				else -- *** Missing in WoW 3.0?
					PawnDebugMessage(VgerCore.Color.Blue .. "Failed to determine whether socket bonus was valid because of changes in Wrath.  Pawn is assuming that it is indeed valid.")
					SocketBonusIsValid = true
				end
				CurrentParseText = string.sub(CurrentParseText, string.len(PawnSocketBonusPrefix) + 1)
			end
			
			local Understood
			if ThisLineIsSocketBonus then
				Understood = PawnLookForSingleStat(RegexTable, SocketBonusStats, CurrentParseText, CurrentDebugMessages)
			else
				Understood = PawnLookForSingleStat(RegexTable, Stats, CurrentParseText, CurrentDebugMessages)
			end
			
			if not Understood then
				-- We don't understand this line.  Let's see if it's a complex stat.
				
				-- First, check to see if it starts with any of the ignore prefixes, such as "Use:".
				local IgnoreLine = false
				for _, ThisPrefix in pairs(PawnSeparatorIgnorePrefixes) do
					if string.sub(CurrentParseText, 1, string.len(ThisPrefix)) == ThisPrefix then
						-- We know that this line doesn't contain a complex stat, so ignore it.
						IgnoreLine = true
						if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. string.format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(CurrentParseText))) end
						if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[CurrentParseText] = 1 end
						break
					end
				end
				
				-- If this line wasn't ignorable, try to break it up.
				if not IgnoreLine then
					-- We'll assume the entire line was understood for now, but if we find any PART that
					-- we don't understand, we'll clear the "understood" flag again.
					Understood = true
					
					local Pos = 1
					local NextPos = 0
					local InnerStatLine = nil
					local InnerUnderstood = nil
					
					while Pos < string.len(CurrentParseText) do
						for _, ThisSeparator in pairs(PawnSeparators) do
							NextPos = string.find(CurrentParseText, ThisSeparator, Pos, false)
							if NextPos then
								-- One of the separators was found.  Check this string.
								InnerStatLine = string.sub(CurrentParseText, Pos, NextPos - 1)
								if ThisLineIsSocketBonus then
									InnerUnderstood = PawnLookForSingleStat(RegexTable, SocketBonusStats, InnerStatLine, CurrentDebugMessages)
								else
									InnerUnderstood = PawnLookForSingleStat(RegexTable, Stats, InnerStatLine, CurrentDebugMessages)
								end
								if not InnerUnderstood then
									-- We don't understand this line.
									Understood = false
									if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. string.format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(InnerStatLine))) end
									if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[InnerStatLine] = 1 end
								end
								-- Regardless of the outcome, advance to the next position.
								Pos = NextPos + string.len(ThisSeparator)
								break
							end -- (if NextPos...)
							-- If we didn't find that separator, continue the for loop to try the next separator.
						end -- (for ThisSeparator...)
						if (Pos > 1) and (not NextPos) then
							-- If there are no more separators left in the string, but we did find one before that, then we have
							-- one last string to check: everything after the last separator.
							InnerStatLine = string.sub(CurrentParseText, Pos)
							if ThisLineIsSocketBonus then
								InnerUnderstood = PawnLookForSingleStat(RegexTable, SocketBonusStats, InnerStatLine, CurrentDebugMessages)
							else
								InnerUnderstood = PawnLookForSingleStat(RegexTable, Stats, InnerStatLine, CurrentDebugMessages)
							end
							if not InnerUnderstood then
								-- We don't understand this line.
								Understood = false
								if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. string.format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(InnerStatLine))) end
								if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[InnerStatLine] = 1 end
							end
							break
						elseif not NextPos then
							-- If there are no more separators in the string and we hadn't found any before that, we're done.
							Understood = false
							if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. string.format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(CurrentParseText))) end
							if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[CurrentParseText] = 1 end
							break
						end 
						-- Continue on to the next portion of the string.  The loop ends when we run out of string.
					end -- (while Pos...)
				end -- (if not IgnoreLine...)
			end
		end
	end

	-- Before returning, some stats require special handling.
	
	if Stats["IsMainHand"] or Stats["IsOneHand"] or Stats["IsOffHand"] or Stats["IsTwoHand"] or Stats["IsRanged"] then
		-- Only perform this conversion if this is an actual weapon.  This works around a problem that occurs when you
		-- enchant your ring with weapon damage and then Pawn would try to calculate DPS for your ring with no Min/MaxDamage.
		if Stats["MinDamage"] and Stats["MaxDamage"] and Stats["Speed"] then
			PawnAddStatToTable(Stats, "Dps", (Stats["MinDamage"] + Stats["MaxDamage"]) / Stats["Speed"] / 2)
		else
			local WeaponStats = 0
			if Stats["MinDamage"] then WeaponStats = WeaponStats + 1 end
			if Stats["MaxDamage"] then WeaponStats = WeaponStats + 1 end
			if Stats["Speed"] then WeaponStats = WeaponStats + 1 end
			VgerCore.Assert(WeaponStats == 0 or WeaponStats == 3, "Weapon with mismatched or missing speed and damage stats was not converted to DPS")
		end
	end
	
	if Stats["IsMainHand"] then
		PawnAddStatToTable(Stats, "MainHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "MainHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "MainHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "MainHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsMainHand"] = nil
	end

	if Stats["IsOffHand"] then
		PawnAddStatToTable(Stats, "OffHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "OffHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "OffHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "OffHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsOffHand"] = nil
	end

	if Stats["IsOneHand"] then
		PawnAddStatToTable(Stats, "OneHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "OneHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "OneHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "OneHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsOneHand"] = nil
	end

	if Stats["IsTwoHand"] then
		PawnAddStatToTable(Stats, "TwoHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "TwoHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "TwoHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "TwoHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsTwoHand"] = nil
	end

	if Stats["IsMelee"] and Stats["IsRanged"] then
		VgerCore.Fail("Weapon that is both melee and ranged was converted to both Melee* and Ranged* stats")
	end	
	
	if Stats["IsMelee"] then
		PawnAddStatToTable(Stats, "MeleeDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "MeleeSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "MeleeMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "MeleeMaxDamage", Stats["MaxDamage"])
		Stats["IsMelee"] = nil
	end

	if Stats["IsRanged"] then
		PawnAddStatToTable(Stats, "RangedDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "RangedSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "RangedMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "RangedMaxDamage", Stats["MaxDamage"])
		Stats["IsRanged"] = nil
	end
	
	-- Now, socket bonuses require special handling.
	if SocketBonusIsValid then
		-- If the socket bonus is valid (green), then just add those stats directly to the main stats table and be done with it.
		PawnAddStatsToTable(Stats, SocketBonusStats)
		SocketBonusStats = {}
	else
		-- If the socket bonus is not valid, then we need to check for sockets.
		if Stats["RedSocket"] or Stats["YellowSocket"] or Stats["BlueSocket"] or Stats["MetaSocket"] then
			-- There are sockets left, so the player could still meet the requirements.
		else
			-- There are no sockets left and the socket bonus requirements were not met.  Ignore the
			-- socket bonus, since the user purposely chose to mis-socket.
			SocketBonusStats = {}
		end
	end
	
	-- Done!
	local _, PrettyLink = Tooltip:GetItem()
	if not HadUnknown then UnknownLines = nil end
	return Stats, SocketBonusStats, UnknownLines, PrettyLink
end

-- Looks for a single string in the regex table, and adds it to the stats table if it finds it.
-- Parameters: Stats, ThisString, DebugMessages
--		RegexTable: The regular expression table to look through.
--		Stats: The stats table to modify if anything is found.
--		ThisString: The string to look for.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Understood
--		Understood: True if the string was understood (even if empty or ignored), otherwise false.
function PawnLookForSingleStat(RegexTable, Stats, ThisString, DebugMessages)
	-- First, perform a series of normalizations on the string.  For example, "Stamina +5" should
	-- be converted to "+5 Stamina" so we don't need two strings for everything.
	ThisString = string.trim(ThisString)
	for _, Entry in pairs(PawnNormalizationRegexes) do
		local Regex, Replacement = unpack(Entry)
		local OldString = ThisString
		ThisString, Count = string.gsub(ThisString, Regex, Replacement, 1)
		--if Count > 0 then PawnDebugMessage("Normalized string using \"" .. PawnEscapeString(Regex) .. "\" -- was " .. PawnEscapeString(OldString) .. " and is now " .. PawnEscapeString(ThisString)) end
	end

	-- Now, look for the string in the main regex table.
	local Props, Matches = PawnFindStringInRegexTable(ThisString, RegexTable)
	if not Props then
		-- We don't understand this.  Return false to indicate this, so the caller can handle the case.
		return false
	else
		-- We understand this.  It could either be an ignored line like "Soulbound", or an actual stat.
		-- The same code handles both cases; just keep going until we find a stat of nil; in the ignored case, we hit this immediately.
		local Index = 2
		while true do
			local Stat, Number, Source = Props[Index], tonumber(Props[Index + 1]), Props[Index + 2]
			if not Stat then break end -- There are no more stats left to process.
			if not Number then Number = 1 end
			
			if Source == PawnMultipleStatsExtract or Source == nil then
				-- This is a variable number of a stat, the standard case.
				local ExtractedValue = string.gsub(Matches[math.abs(Number)], ",", ".")
				ExtractedValue = tonumber(ExtractedValue) -- replacing commas with dots for the German client
				if Number < 0 then ExtractedValue = -ExtractedValue end
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.FoundStatMessage, ExtractedValue, Stat)) end
				PawnAddStatToTable(Stats, Stat, ExtractedValue)
			elseif Source == PawnMultipleStatsFixed then
				-- This is a fixed number of a stat, such as a socket (1).
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.FoundStatMessage, Number, Stat)) end
				PawnAddStatToTable(Stats, Stat, Number)
			else
				VgerCore.Fail("Incorrect source value of '" .. Source .. "' for regex: " .. Props[1])
			end
			
			Index = Index + 3
		end
	end

	return true
end

-- Gets the name of an item given a tooltip name, and the line on which the item appears.
-- Normally this is line 1, but it can be line 2 if the first line is "Currently Equipped".
-- Parameters: TooltipName
--		TooltipName: The name of the tooltip to read.
-- Return value: ItemName, LineNumber
--		ItemName: The name of the item in the tooltip, or nil if the tooltip didn't have one.
--		LineNumber: The line number on which the name was found, or nil if no item was found.
function PawnGetItemNameFromTooltip(TooltipName)
	-- First, get the tooltip details.
	local TooltipTopLine = getglobal(TooltipName .. "TextLeft1")
	if not TooltipTopLine then return end
	local ItemName = TooltipTopLine:GetText()
	if not ItemName or ItemName == "" then return end
	
	-- If this is a Currently Equipped tooltip, skip the first line.
	if ItemName == CURRENTLY_EQUIPPED then
		ItemNameLineNumber = 2
		TooltipTopLine = getglobal(TooltipName .. "TextLeft2")
		if not TooltipTopLine then return end
		return TooltipTopLine:GetText(), 2
	end
	return ItemName, 1
end

-- Annotates zero or more lines in a tooltip with the name TooltipName, adding a (*) to the end
-- of each line specified by index in the list Lines.
-- Returns true if any lines were annotated.
function PawnAnnotateTooltipLines(TooltipName, Lines)
	if not Lines then return false end

	local Tooltip = getglobal(TooltipName)
	local LineCount = Tooltip:NumLines()
	for i = 2, LineCount do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		local LeftLineText = LeftLine:GetText()
		if Lines[LeftLineText] then
			-- Getting the line text can fail in the following scenario, observable with MobInfo-2:
			-- 1. Other mod modifies a tooltip to include unrecognized text.
			-- 2. Pawn reads the tooltip, noting those unrecognized lines and remembering them so that they
			-- can get marked with (*) later.
			-- 3. Something causes the tooltip to be refreshed.  For example, picking up the item.  All customizations
			-- by Pawn and other mods are lost.
			-- 4. Pawn re-annotates the tooltip with (*) before the other mod has added the lines that are supposed
			-- to get the (*).
			-- In this case, we just ignore the problem and leave off the (*), since we can't really come back later.
			LeftLine:SetText(LeftLineText .. PawnTooltipAnnotation)
		end
	end
end

-- Adds an amount of one stat to a table of stats, increasing the value if
-- it's already there, or adding it if it isn't.
function PawnAddStatToTable(Stats, Stat, Amount)
	if not Amount or Amount == 0 then return end
	if Stats[Stat] then
		Stats[Stat] = Stats[Stat] + Amount
	else
		Stats[Stat] = Amount
	end
end

-- Adds the contents of one stat table to another.
function PawnAddStatsToTable(Dest, Source)
	if not Dest then
		VgerCore.Fail("PawnAddStatsToTable requires a destination table!")
		return
	end
	if not Source then return end
	for Stat, Quantity in pairs(Source) do
		PawnAddStatToTable(Dest, Stat, Quantity)
	end
end

-- Looks for the first regular expression in a given table that matches the given string.
-- Parameters: String, RegexTable
--		String: The string to look for.
--		RegexTable: The table of regular expressions to look through.
--	Return value: Props, Matches
--		Props: The row from the table with a matching regex.
--		Matches: The array of captured matches.
-- 		Returns nil, nil if no matches were found.
--		Returns {}, {} if the string was ignored.
function PawnFindStringInRegexTable(String, RegexTable)
	if (String == nil) or (String == "") or (String == " ") then return {}, {} end
	for _, Entry in pairs(RegexTable) do
		local StartPos, EndPos, m1, m2, m3, m4, m5 = string.find(String, Entry[1])
		if StartPos then return Entry, { m1, m2, m3, m4, m5 } end
	end
	return nil, nil
end

-- Calculates the value of an item.
-- Returns the numeric value of an item based on the given scale values.
-- For example, 21.75.
-- The given item table and socket bonus table should be in the format returned by GetStatsFromTooltip.
function PawnGetItemValue(Item, SocketBonus, ScaleName, DebugMessages)
	-- If either the item or scale is empty, exit now.
	if (not Item) or (not ScaleName) then return end
	local ScaleOptions = PawnOptions.Scales[ScaleName]
	if not ScaleOptions then return end
	ScaleValues = ScaleOptions.Values
	if not ScaleValues then return end
	
	-- Calculate the value.
	local Total = 0
	local ThisValue, Stat, Quantity
	for Stat, Quantity in pairs(Item) do
		ThisValue = ScaleValues[Stat]
		-- Colored sockets are considered separately.
		if Stat ~= "RedSocket" and Stat ~= "YellowSocket" and Stat ~= "BlueSocket" then
			if ThisValue then
				-- This stat has a value; add it to the running total.
				if ScaleValues.SpeedBaseline and (
					Stat == "Speed" or
					Stat == "MeleeSpeed" or
					Stat == "MainHandSpeed" or
					Stat == "OffHandSpeed" or
					Stat == "OneHandSpeed" or
					Stat == "TwoHandSpeed" or
					Stat == "RangedSpeed"	
				) then
					-- Speed is a special case; subtract SpeedBaseline from the speed value.
					Quantity = Quantity - ScaleValues.SpeedBaseline
				end
				Total = Total + ThisValue * Quantity
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			else
				-- This stat doesn't have a value set; display a warning.
				if DebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. string.format(PawnLocal.NoValueMessage, Stat)) end
			end
		end
	end
	
	-- Decide what to do with socket bonuses.
	if SocketBonus then
		-- Start by counting the sockets; if there are no sockets, we can quit.
		local TotalColoredSockets = 0
		if Item["RedSocket"] then TotalColoredSockets = TotalColoredSockets + Item["RedSocket"] end
		if Item["YellowSocket"] then TotalColoredSockets = TotalColoredSockets + Item["YellowSocket"] end
		if Item["BlueSocket"] then TotalColoredSockets = TotalColoredSockets + Item["BlueSocket"] end
		if TotalColoredSockets > 0 then
			-- Find the value of the sockets if they are socketed properly.
			if DebugMessages then PawnDebugMessage(PawnLocal.SocketBonusValueCalculationMessage) end
			local ProperSocketValue = 0
			Stat = "RedSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			Stat = "YellowSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			Stat = "BlueSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			for Stat, Quantity in pairs(SocketBonus) do
				ThisValue = ScaleValues[Stat]
				if ThisValue then
					ProperSocketValue = ProperSocketValue + ThisValue * Quantity
					if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
				end
			end
			-- Then, find the value of the sockets if they are socketed with the best gem, ignoring the socket bonus.
			local BestGemValue, BestGemName = 0, ""
			local MissocketedValue = 0
			if ScaleOptions.SmartGemSocketing then
				if ScaleValues["RedSocket"] and ScaleValues["RedSocket"] > BestGemValue then
					BestGemValue = ScaleValues["RedSocket"]
					BestGemName = RED_GEM
				elseif ScaleValues["RedSocket"] == BestGemValue then
					BestGemName = BestGemName .. "/" .. RED_GEM
				end
				if ScaleValues["YellowSocket"] and ScaleValues["YellowSocket"] > BestGemValue then
					BestGemValue = ScaleValues["YellowSocket"]
					BestGemName = YELLOW_GEM
				elseif ScaleValues["YellowSocket"] == BestGemValue then
					BestGemName = BestGemName .. "/" .. YELLOW_GEM
				end
				if ScaleValues["BlueSocket"] and ScaleValues["BlueSocket"] > BestGemValue then
					BestGemValue = ScaleValues["BlueSocket"]
					BestGemName = BLUE_GEM
				elseif ScaleValues["BlueSocket"] == BestGemValue then
					BestGemName = BestGemName .. "/" .. BLUE_GEM
				end
				if BestGemValue and BestGemValue > 0 then MissocketedValue = TotalColoredSockets * BestGemValue end
			end
			-- So, which one should we use?
			if ScaleOptions.SmartGemSocketing and MissocketedValue > ProperSocketValue then
				-- It's better to mis-socket and ignore the socket bonus.
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.MissocketWorthwhileMessage, BestGemName)) end
				Total = Total + MissocketedValue
				if DebugMessages then PawnDebugMessage(string.format(PawnLocal.ValueCalculationMessage, TotalColoredSockets, BestGemName, BestGemValue, MissocketedValue)) end
			else
				-- It's better to socket this item normally.
				Total = Total + ProperSocketValue
			end
		end
	end

	-- Perform normalizations on the total if that option is enabled.
	if PawnOptions.NormalizationFactor and PawnOptions.NormalizationFactor > 0 then
		Total = PawnOptions.NormalizationFactor * Total / PawnScaleTotals[ScaleName]
		if DebugMessages then PawnDebugMessage(string.format(PawnLocal.NormalizationMessage, PawnOptions.NormalizationFactor)) end
	end
	
	if DebugMessages then PawnDebugMessage(string.format(PawnLocal.TotalValueMessage, Total)) end
	
	return Total
end

-- Returns the type of hyperlink passed in, or nil if it's not a hyperlink.
-- Possible values include: item, enchant, quest, spell
function PawnGetHyperlinkType(Hyperlink)
	-- First, try colored links.
	local _, _, LinkType = string.find(Hyperlink, "^|c%x%x%x%x%x%x%x%x|H(.-):")
	if not LinkType then
		-- Then, try raw links.
		_, _, LinkType = string.find(Hyperlink, "^(.-):")
	end
	return LinkType
end

-- If the item link is of the clickable form, strip off the initial hyperlink portion.
function PawnStripLeftOfItemLink(ItemLink)
	local _, _, InnerLink = string.find(ItemLink, "^|%x+|H(.+)")
	if InnerLink then return InnerLink else return ItemLink end
end

-- Extracts the item ID from an ItemLink string and returns it, or nil if unsuccessful.
function PawnGetItemIDFromLink(ItemLink)
	local Pos, _, ItemID = string.find(PawnStripLeftOfItemLink(ItemLink), "^item:(%-?%d+):")
	if Pos then return ItemID else return ItemLink end
end

-- Returns a new item link that represents an unenchanted version of the original item link, or
-- nil if unsuccessful or the item is not enchanted.
function PawnUnenchantItemLink(ItemLink)
	local Pos, _, ItemID, EnchantID, GemID1, GemID2, GemID3, GemID4, SuffixID, MoreInfo, ViewAtLevel = string.find(PawnStripLeftOfItemLink(ItemLink), "^item:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+):(%d+)")
	if not Pos then
		-- *** WoW 2.x doesn't support the ViewAtLevel parameter
		Pos, _, ItemID, EnchantID, GemID1, GemID2, GemID3, GemID4, SuffixID, MoreInfo = string.find(PawnStripLeftOfItemLink(ItemLink), "^item:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)")
		ViewAtLevel = "0"
	end
	if Pos then
		if EnchantID ~= "0" or GemID1 ~= "0" or GemID2 ~= "0" or GemID3 ~= "0" or GemID4 ~= "0" then
			-- This item is enchanted.  Return a new link.
			return "item:" .. ItemID .. ":0:0:0:0:0:" .. SuffixID .. ":" .. MoreInfo .. ":" .. ViewAtLevel
		else
			-- This item is not enchanted.  Return nil.
			return nil
		end
	else
		-- We couldn't parse this item link.  Return nil.
		VgerCore.Fail("Could not parse the item link: " .. PawnEscapeString(ItemLink))
		return nil
	end
end

-- Returns a nice-looking string that shows the item IDs for an item, its enchantments, and its gems.
function PawnGetItemIDsForDisplay(ItemLink)
	local Pos, _, ItemID, EnchantID, GemID1, GemID2, GemID3, GemID4, SuffixID, MoreInfo = string.find(ItemLink, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)")
	if not Pos then return end
	-- Figure out what the LAST enchantment or gem is.
	local LastGemSlot = -1
	if EnchantID ~= "0" then LastGemSlot = 0 end
	if GemID1 ~= "0" then LastGemSlot = 1 end
	if GemID2 ~= "0" then LastGemSlot = 2 end
	if GemID3 ~= "0" then LastGemSlot = 3 end
	if GemID4 ~= "0" then LastGemSlot = 4 end
	-- Then, build a string.
	if LastGemSlot >= 0 then
		local Display = ItemID .. VgerCore.Color.Silver .. ":" .. EnchantID
		if LastGemSlot >= 1 then Display = Display .. ":" .. GemID1 end
		if LastGemSlot >= 2 then Display = Display .. ":" .. GemID2 end
		if LastGemSlot >= 3 then Display = Display .. ":" .. GemID3 end
		if LastGemSlot >= 4 then Display = Display .. ":" .. GemID4 end
		return Display
	else
		-- If there are no enchantments or gems, just return the ID.
		return ItemID
	end
end

-- Reads a Pawn scale tag, and breaks it into parts.
-- 	Parameters: ScaleTag
--		ScaleTag: A Pawn scale tag.  Example:  '(Pawn:v1:"Healbot":Stamina=1,Intellect=1.24)'
--	Return value: Name, Values; or nil if unsuccessful, or if the version number is too high.
--		Name: The scale name.
--		Values: A table of scale stats and values.  Example: {["Stamina"] = 1, ["Intellect"] = 1.24}
function PawnParseScaleTag(ScaleTag)
	-- Read the scale and perform basic validation.
	local Pos, _, Version, Name, ValuesString = string.find(ScaleTag, "^%s*%(%s*Pawn%s*:%s*v(%d+)%s*:%s*\"([^\"]+)\"%s*:%s*(.+)%s*%)%s*$")
	Version = tonumber(Version)
	if (not Pos) or (not Version) or (not Name) or (Name == "") or (not ValuesString) or (ValuesString == "") then return end
	if Version > PawnCurrentScaleVersion then return end
	
	-- Now, parse the values string for stat names and values.
	local Values = {}
	local function SplitStatValuePair(Pair)
		local Pos, _, Stat, Value = string.find(Pair, "^%s*([%a%d]+)%s*=%s*(%-?[%d%.]+)%s*,$")
		Value = tonumber(Value)
		if Pos and Stat and (Stat ~= "") and Value then 
			Values[Stat] = Value
		end
	end
	string.gsub(ValuesString .. ",", "[^,]*,", SplitStatValuePair)
	
	-- Looks like everything worked.
	return Name, Values
end

-- Escapes a string so that it can be more easily printed.
function PawnEscapeString(String)
	return string.gsub(string.gsub(string.gsub(String, "\r", "\\r"), "\n", "\\n"), "|", "||")
end

-- Corrects errors in scales: either human errors, or to correct for bugs in current or past versions of Pawn.
function PawnCorrectScaleErrors(ScaleName)
	local ThisScaleOptions = PawnOptions.Scales[ScaleName]
	if not ThisScaleOptions then return end
	ThisScale = ThisScaleOptions.Values
	if not ThisScale then return end
	
	-- Pawn 1.0.1 adds a per-scale setting that defaults to on.
	if ThisScaleOptions.SmartGemSocketing == nil then ThisScaleOptions.SmartGemSocketing = true end
	
	-- Some versions of Pawn call resilience rating Resilience and some call it ResilienceRating.
	PawnReplaceStat(ThisScale, "Resilience", "ResilienceRating")
	
	-- Early versions of Pawn 0.7.x had a typo in the configuration UI so that none of the special DPS stats worked.
	PawnReplaceStat(ThisScale, "MeleeDPS", "MeleeDps")
	PawnReplaceStat(ThisScale, "RangedDPS", "RangedDps")
	PawnReplaceStat(ThisScale, "MainHandDPS", "MainHandDps")
	PawnReplaceStat(ThisScale, "OffHandDPS", "OffHandDps")
	PawnReplaceStat(ThisScale, "OneHandDPS", "OneHandDps")
	PawnReplaceStat(ThisScale, "TwoHandDPS", "TwoHandDps")
	
	-- Pawn 1.0.3 re-added the SpellPower stat for Wrath of the Lich King.
	-- Keep SpellDamage and Healing in the scale because they're needed for Vanilla WoW.
	if not ThisScale.SpellPower and (ThisScale.SpellDamage or ThisScale.Healing) then
		local Healing = ThisScale.Healing
		if not Healing then Healing = 0 end
		local SpellDamage = ThisScale.SpellDamage
		if not SpellDamage then SpellDamage = 0 end
		ThisScale.SpellPower = SpellDamage + (13 * Healing / 7)
		if ThisScale.SpellDamage and ThisScale.SpellDamage > ThisScale.SpellPower then ThisScale.SpellPower = ThisScale.SpellDamage end
		if ThisScale.SpellPower <= 0 then ThisScale.SpellPower = nil end
	end
end

-- Replaces one incorrect stat with a correct stat.
function PawnReplaceStat(ThisScale, OldStat, NewStat)
	if ThisScale[OldStat] then
		if not ThisScale[NewStat] then ThisScale[NewStat] = ThisScale[OldStat] end
		ThisScale[OldStat] = nil
	end
end

-- Causes the Pawn private tooltip to be shown when next hovering an item.
--function PawnTestShowPrivateTooltip()
--	PawnPrivateTooltip:SetOwner(UIParent, "ANCHOR_TOPRIGHT")
--end

-- Hides the Pawn private tooltip (normal).
--function PawnTestHidePrivateTooltip()
--	PawnPrivateTooltip:SetOwner(UIParent, "ANCHOR_NONE")
--	PawnPrivateTooltip:Hide()
--end

-- Depending on the user's current tooltip icon settings, show and hide icons as appropriate.
function PawnToggleTooltipIcons()
	PawnAttachIconToTooltip(ItemRefTooltip)
	PawnAttachIconToTooltip(ShoppingTooltip1, true)
	PawnAttachIconToTooltip(ShoppingTooltip2, true)
	
	-- MultiTips compatibility
	PawnAttachIconToTooltip(ItemRefTooltip2)
	PawnAttachIconToTooltip(ItemRefTooltip3)
	PawnAttachIconToTooltip(ItemRefTooltip4)
	PawnAttachIconToTooltip(ItemRefTooltip5)
	
	-- EquipCompare compatibility
	PawnAttachIconToTooltip(ComparisonTooltip1, true)
	PawnAttachIconToTooltip(ComparisonTooltip2, true)
end

-- If tooltip icons are enabled, attaches an icon to the upper-left corner of a tooltip.  Otherwise, hides
-- any icons attached to that tooltip if they exist.
-- Optionally, the caller may include an item link so this function doesn't need to get one.
function PawnAttachIconToTooltip(Tooltip, AttachAbove, ItemLink)
	-- If the tooltip doesn't exist, exit now.
	if not Tooltip then return end

	-- Find the right texture to use, but skip all this if the user has icons turned off.
	local TextureName
	if PawnOptions.ShowTooltipIcons then
		-- Don't retrieve an item link if one was passed in.
		if not ItemLink then
			_, ItemLink = Tooltip:GetItem()
		end
		if ItemLink then
			TextureName = GetItemIcon(ItemLink)
		end
	end
	
	-- Now, if we don't have a texture to use, or icons are disabled, hide this icon if it's visible
	-- and then exit.
	local IconFrame = Tooltip.PawnIconFrame
	if not TextureName then
		if IconFrame then
			IconFrame:Hide()
			IconFrame.PawnIconTexture = nil
			Tooltip.PawnIconFrame = nil
		end
		return
	end
	
	-- Create the icon's frame if it doesn't already exist.
	if not IconFrame then
		IconFrame = CreateFrame("Frame", nil, Tooltip)
		Tooltip.PawnIconFrame = IconFrame
		IconFrame:SetWidth(37)
		IconFrame:SetHeight(37)
		
		local IconTexture = IconFrame:CreateTexture(nil, "BACKGROUND")
		IconTexture:SetTexture(TextureName)
		IconTexture:SetAllPoints(IconFrame)
		IconFrame.PawnIconTexture = IconTexture
	else
		-- If the icon already existed, then we just need to update the texture.
		IconFrame.PawnIconTexture:SetTexture(TextureName)
	end

	-- Attach the icon frame and show it.
	if AttachAbove then
		IconFrame:SetPoint("BOTTOMLEFT", Tooltip, "TOPLEFT", 2, -2)
	else
		IconFrame:SetPoint("TOPRIGHT", Tooltip, "TOPLEFT", 2, -2)
	end
	IconFrame:Show()
	
	return IconFrame
end

-- Hides any icons on a tooltip, if there are any.
function PawnHideTooltipIcon(TooltipName)
	-- Find the tooltip.  If it doesn't exist, we can skip out now.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	
	-- Is there an icon on it?  If not, exit.
	local IconFrame = Tooltip.PawnIconFrame
	if not IconFrame then return end
	
	-- Hide the icon frame if it's there, and remove the reference to it so it can be garbage-collected.
	IconFrame:Hide()
	IconFrame.PawnIconTexture = nil
	Tooltip.PawnIconFrame = nil
end

-- Comparer function for use in table.sort that sorts strings alphabetically, ignoring case, and also ignoring a
-- 10-character color format at the beginning of the string.
function PawnColoredStringCompare(a, b)
	return string.lower(string.sub(a, 11)) < string.lower(string.sub(b, 11))
end

-- Comparer function for use in table.sort that sorts sub-tables alphabetically by the first element in the sub-table, ignoring case.
-- For example, { {"A", 1}, {"B", -2}, {"C", .5} }.
function PawnItemValueCompare(a, b)
	return string.lower(a[1]) < string.lower(b[1])
end

-- Returns a string representation of a number to a maximum of one decimal place.  If the number passed is nil, nil is returned.
function PawnFormatShortDecimal(Number)
	-- REVIEW: Comparing floats directly is usually not correct... epsilon?
	if Number == nil then
		return nil
	elseif Number == floor(Number) then
		return tostring(Number)
	else
		return string.format("%.1f", Number)
	end
end

-- Takes an ItemEquipLoc and returns one or two slot IDs where that item type can be equipped.
-- Bags are not supported.
function PawnGetSlotsForItemType(ItemEquipLoc)
	if (not ItemEquipLoc) or (ItemEquipLoc == "") then return end
	return PawnItemEquipLocToSlot1[ItemEquipLoc], PawnItemEquipLocToSlot2[ItemEquipLoc]
end

------------------------------------------------------------
-- Pawn API
------------------------------------------------------------

-- Resets all Pawn scales, creating one default scale named "Pawn value" (localized).
-- Returns true.
function PawnResetScales()
	PawnOptions.Scales = {}
	PawnOptions.Scales[PawnDefaultScaleName] = PawnGetDefaultScale()
	return true
end

-- Adds a new scale with no values.  Returns true if successful.
function PawnAddEmptyScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnAddEmptyScale(\"ScaleName\")")
		return false
	elseif PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnOptions.Scales[ScaleName] = PawnGetEmptyScale()
	return true
end

-- Adds a new scale with the default values.  Returns true if successful.
function PawnAddDefaultScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnAddDefaultScale(\"ScaleName\")")
		return false
	elseif PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnOptions.Scales[ScaleName] = PawnGetDefaultScale()
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return true
end

-- Deletes a scale.  Returns true if successful.
function PawnDeleteScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnDeleteScale(\"ScaleName\")")
		return false
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnOptions.Scales[ScaleName] = nil
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return true
end

-- Renames an existing scale.  Returns true if successful.
function PawnRenameScale(OldScaleName, NewScaleName)
	if (not OldScaleName) or (OldScaleName == "") or (not NewScaleName) or (NewScaleName == "") then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be empty.  Usage: PawnRenameScale(\"OldScaleName\", \"NewScaleName\")")
		return false
	elseif OldScaleName == NewScaleName then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be the same.")
		return false
	elseif not PawnOptions.Scales[OldScaleName] then
		VgerCore.Fail("OldScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnOptions.Scales[NewScaleName] then
		VgerCore.Fail("NewScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnOptions.Scales[NewScaleName] = PawnOptions.Scales[OldScaleName]
	PawnOptions.Scales[OldScaleName] = nil
	PawnRecalculateScaleTotal(OldScaleName)
	PawnRecalculateScaleTotal(NewScaleName)
	PawnResetTooltips()
	return true
end

-- Creates a new scale based on an old one.  Returns true if successful.
function PawnDuplicateScale(OldScaleName, NewScaleName)
	if (not OldScaleName) or (OldScaleName == "") or (not NewScaleName) or (NewScaleName == "") then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be empty.  Usage: PawnDuplicateScale(\"OldScaleName\", \"NewScaleName\")")
		return false
	elseif OldScaleName == NewScaleName then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be the same.")
		return false
	elseif not PawnOptions.Scales[OldScaleName] then
		VgerCore.Fail("OldScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnOptions.Scales[NewScaleName] then
		VgerCore.Fail("NewScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end

	-- Create the copy.
	PawnOptions.Scales[NewScaleName] = {}
	PawnOptions.Scales[NewScaleName].Color = PawnOptions.Scales[OldScaleName].Color
	PawnOptions.Scales[NewScaleName].Hidden = PawnOptions.Scales[OldScaleName].Hidden
	PawnOptions.Scales[NewScaleName].SmartGemSocketing = PawnOptions.Scales[OldScaleName].SmartGemSocketing
	PawnOptions.Scales[NewScaleName].Values = {}
	local NewScale = PawnOptions.Scales[NewScaleName].Values
	for StatName, Value in pairs(PawnOptions.Scales[OldScaleName].Values) do
		NewScale[StatName] = Value
	end
	
	PawnRecalculateScaleTotal(NewScaleName)
	PawnResetTooltips()
	return true
end

-- Returns the value of one stat in a scale, or nil if unsuccessful.
function PawnGetStatValue(ScaleName, StatName)
	if (not ScaleName) or (ScaleName == "") or (not StatName) or (StatName == "") then
		VgerCore.Fail("ScaleName and StatName cannot be empty.  Usage: x = PawnGetStatValue(\"ScaleName\", \"StatName\")")
		return nil
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	return PawnOptions.Scales[ScaleName].Values[StatName]
end

-- Sets the value of one stat in a scale, and returns true if successful.  Use nil or 0 as the new value to remove the stat.
function PawnSetStatValue(ScaleName, NewValue)
	if (not ScaleName) or (ScaleName == "") or (not StatName) or (StatName == "") then
		VgerCore.Fail("ScaleName and StatName cannot be empty.  Usage: x = PawnGetStatValue(\"ScaleName\", \"StatName\")")
		return nil
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	if NewValue == 0 then NewValue = nil end
	PawnOptions.Scales[ScaleName].Values[StatName] = NewValue
	return true
end

-- Returns true if a particular scale exists, or false if not.
function PawnDoesScaleExist(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnDoesScaleExist(\"ScaleName\")")
		return false
	end
	
	if PawnOptions.Scales[ScaleName] then
		return true
	else
		return false
	end
end

-- Returns a table of all stats and their values for a particular scale, or nil if unsuccessful.
-- This returns the actual internal table of stat values, so be careful not to modify it!
function PawnGetAllStatValues(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnGetAllStatValues(\"ScaleName\")")
		return nil
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	--local TableCopy = {}
	--for StatName, Value in pairs(PawnOptions.Scales[ScaleName].Values) do
	--	TableCopy[StatName] = Value
	--end
	--return TableCopy
	return PawnOptions.Scales[ScaleName].Values
end

-- Sets the value of one stat in a scale.  Returns true if successful.
-- Use 0 or nil as the Value to remove a stat from the scale.
function PawnSetStatValue(ScaleName, StatName, Value)
	if (not ScaleName) or (ScaleName == "") or (not StatName) or (StatName == "") then
		VgerCore.Fail("ScaleName and StatName cannot be empty.  Usage: PawnSetStatValue(\"ScaleName\", \"StatName\", Value)")
		return false
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	if Value == 0 then Value = nil end
	PawnOptions.Scales[ScaleName].Values[StatName] = Value
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return true
end

-- Returns a table of all Pawn scale names.
function PawnGetAllScales()
	local TableCopy = {}
	for ScaleName in pairs(PawnOptions.Scales) do
		table.insert(TableCopy, ScaleName)
	end
	table.sort(TableCopy, VgerCore.CaseInsensitiveComparer)
	return TableCopy
end

-- Creates a Pawn scale tag for a scale.
--	Parameters: ScaleName
--		ScaleName: The name of a Pawn scale.
--	Return value: ScaleTag, or nil if unsuccessful.
--		ScaleTag: A Pawn scale tag.  Example:  '(Pawn:v1:"Healbot":Stamina=1,Intellect=1.24)'
function PawnGetScaleTag(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnGetScaleTag(\"ScaleName\")")
		return
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return
	elseif not PawnOptions.Scales[ScaleName].Values then
		return
	end
	
	local ScaleTag = "( Pawn: v" .. PawnCurrentScaleVersion .. ": \"" .. ScaleName .. "\": "
	local AddComma = false
	for StatName, Value in pairs(PawnOptions.Scales[ScaleName].Values) do
		if Value and Value ~= 0 then
			if AddComma then ScaleTag = ScaleTag .. ", " end
			ScaleTag = ScaleTag .. StatName .. "=" .. tostring(Value)
			AddComma = true
		end
	end
	ScaleTag = ScaleTag .. " )"
	
	return ScaleTag
end

-- Imports a Pawn scale tag, adding that scale to the current character.
--	Parameters: ScaleTag, Overwrite
--		ScaleTag: A Pawn scale tag to add.  Example:  '( Pawn: v1: "Healbot": Stamina=1, Intellect=1.24 )'
--		Overwrite: If true, this function will overwrite an existing scale with the same name.
--	Return value: Status, ScaleName
--		Status: One of the PawnImportScaleResult* constants.
--		ScaleName: The name of the Pawn scale specified by ScaleTag, or nil if ScaleTag could not be parsed.
function PawnImportScale(ScaleTag, Overwrite)
	local ScaleName, Values = PawnParseScaleTag(ScaleTag)
	if not ScaleName then
		-- This tag couldn't be parsed.
		return PawnImportScaleResultTagError
	end
	
	if PawnOptions.Scales[ScaleName] and not Overwrite then
		-- A scale with this name already exists.  You can't import a scale with the same name as an existing one,
		-- unless you specify Overwrite = true.
		return PawnImportScaleResultAlreadyExists, ScaleName
	end
	
	-- Looks like everything's okay.  Import the scale.  If the scale already exists but Overwrite = true was passed,
	-- don't change other options about this scale, such as the color.
	if not PawnOptions.Scales[ScaleName] then PawnOptions.Scales[ScaleName] = {} end
	PawnOptions.Scales[ScaleName].Values = Values	
	PawnCorrectScaleErrors(ScaleName)
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return PawnImportScaleResultSuccess, ScaleName
end

-- Sets whether or not a scale is visible.  If Visible is nil, it will be considered as false.
function PawnSetScaleVisible(ScaleName, Visible)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnSetScaleVisible(\"ScaleName\", Visible)")
		return nil
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	if PawnOptions.Scales[ScaleName].Hidden ~= not Visible then
		PawnOptions.Scales[ScaleName].Hidden = not Visible
		PawnResetTooltips()
	end
	return true
end

-- Sets true if a given scale is visible in tooltips.
function PawnIsScaleVisible(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnIsScaleVisible(\"ScaleName\")")
		return nil
	elseif not PawnOptions.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	return not PawnOptions.Scales[ScaleName].Hidden
end

-- Shows or hides the Pawn UI.
function PawnUIShow()
	if not PawnUIFrame then
		VgerCore.Fail("Pawn UI is not loaded!")
		return
	end
	if PawnUIFrame:IsShown() then
		PawnUIFrame:Hide()
	else
		PawnUIFrame:Show()
	end
end
