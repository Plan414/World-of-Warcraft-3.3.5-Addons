local Baggins = Baggins
local pt = LibStub("LibPeriodicTable-3.1", true)
local gratuity = LibStub("LibGratuity-3.0")
local L = AceLibrary("AceLocale-2.2"):new("Baggins")
local dewdrop = AceLibrary("Dewdrop-2.0")
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local LBU = LibStub("LibBagUtils-1.0")

local RuleTypes = {}

local wipe=wipe
local tinsert = table.insert
local band=bit.band

local categorycache = {}
local useditems = {}
local slotcache = {}

function Baggins:GetCategoryCache()
    return categorycache
end

local ptsets = {
		type = "group",
		args = {},
	}

local bankuseditems = {}
local bankcategorycache = {}

local categories

local colors = {
		black = {r=0,g=0,b=0,hex="|cff000000"},
		white = {r=1,g=1,b=1,hex="|cffffffff"},
		blue = {r=0,g=0.5,b=1,hex="|cff007fff"},
		purple = {r=1,g=0.4,b=1,hex="|cffff66ff"},
	}

function Baggins:SetCategoryTable(cats)
	categories = cats
end


local BagNames = {
	[KEYRING_CONTAINER] = L["KeyRing"],
	[BANK_CONTAINER] = L["Bank Frame"],
	[BACKPACK_CONTAINER] = L["Backpack"],
}
local BagTypes = { 
	[BACKPACK_CONTAINER] = 1,
	[BANK_CONTAINER] = 2,
	[KEYRING_CONTAINER] = 3,
}
for i=1,NUM_BAG_SLOTS do
	BagNames[i] = L["Bag"..i]
	BagTypes[i] = 1
end
for i=1,NUM_BANKBAGSLOTS do
	BagNames[NUM_BAG_SLOTS+i] = L["Bank Bag"..i]
	BagTypes[NUM_BAG_SLOTS+i] = 2
end


local QualityNames = {
}
for i=0,99 do
	QualityNames[i]=_G["ITEM_QUALITY"..i.."_DESC"]
	if not QualityNames[i] then
		break
	end
end
	




local EquipLocs = {
	"INVTYPE_AMMO",
	"INVTYPE_HEAD",
	"INVTYPE_NECK",
	"INVTYPE_SHOULDER",
	"INVTYPE_BODY", 
	"INVTYPE_CHEST",
	"INVTYPE_ROBE",
	"INVTYPE_WAIST",
	"INVTYPE_LEGS",
	"INVTYPE_FEET",
	"INVTYPE_WRIST",
	"INVTYPE_HAND",
	"INVTYPE_FINGER",
	"INVTYPE_TRINKET",
	"INVTYPE_CLOAK",
	"INVTYPE_WEAPON",
	"INVTYPE_SHIELD",
	"INVTYPE_2HWEAPON",
	"INVTYPE_WEAPONMAINHAND",
	"INVTYPE_WEAPONOFFHAND",
	"INVTYPE_HOLDABLE",
	"INVTYPE_RANGED",
	"INVTYPE_THROWN",
	"INVTYPE_RANGEDRIGHT",
	"INVTYPE_RELIC",
	"INVTYPE_TABARD",
	"INVTYPE_BAG"
}







function Baggins:AddCustomRule(type,description)
	RuleTypes[type] = description
end

--removes any fields not used by the current rule type and sets up defaults if needed
function Baggins:CleanRule(rule)
	local type = rule.type
	wipe(rule)
	rule.type = type

	if RuleTypes[rule.type].CleanRule then
		RuleTypes[rule.type].CleanRule(rule)
	end
end



local currentRule = nil
function Baggins:OpenRuleDewdrop(rule,...)
	if RuleTypes[rule.type] then
		currentRule = rule
		RuleTypes[rule.type].DewDropOptions(rule, ...)
	end
end

function Baggins:RuleTypeIterator(sorted)
	if not sorted then
		return pairs(RuleTypes)
	end
	local t = {}
	for k,v in pairs(RuleTypes) do
		tinsert(t,k)
	end
	table.sort(t, function(a,b) return RuleTypes[a].DisplayName < RuleTypes[b].DisplayName end)
	local i=0
	return function(k)
		i=i+1
		local rt=t[i]
		if not rt then
			return nil,nil
		end
		return rt, RuleTypes[rt]
	end
end

function Baggins:GetRuleDesc(rule)
	if RuleTypes[rule.type] then
		return RuleTypes[rule.type].GetName(rule)
	else
		return format("(|cffff8080%s not loaded|r)", rule.type);
	end
end

function Baggins:IsSpecialBag(bag)
	if not bag then return end
	if type(bag) == "string" then bag = tonumber(bag) end
	local prefix = ""
	if bag == BANK_CONTAINER then
		return "b", 0
	end
	if BagTypes[bag] == 2 then
		prefix = "b"
	end
	if BagTypes[bag] == 3 then
		return "k", 256
	end
	if bag>=1 and bag<= 11 then
		local _,fam = GetContainerNumFreeSlots(bag)
		if type(fam)~="number" then
			-- assume normal bag
		elseif fam==0 then
			-- normal bag
		elseif fam==1 or fam==2 then	-- quiver / ammo 
			return prefix.."a", fam
		elseif fam==4 then		-- soul
			return prefix.."s", fam
		elseif fam==8 then		-- leatherworking
			return prefix.."l", fam
		elseif fam==16 then		-- inscription
			return prefix.."i", fam
		elseif fam==32 then		-- herb
			return prefix.."h", fam
		elseif fam==64 then		-- eNchant
			return prefix.."n", fam
		elseif fam==128 then	-- engineering
			return prefix.."e", fam
		elseif fam==256 then	-- keyring
			return prefix.."k", fam
		elseif fam==512 then	-- gems
			return prefix.."g", fam
		elseif fam==1024 then	-- mining
			return prefix.."m", fam
		else
			return prefix.."?", fam
		end
	end
	
	if prefix ~= "" then
		return prefix, 0
	end
	return nil,0
end

--------------------
-- Item Filtering --
--------------------
function Baggins:CheckSlotsChanged(bag, forceupdate)
	local slot
	local itemschanged
	for slot = 1, GetContainerNumSlots(bag) do
		local key = bag..":"..slot
		local iteminfo
		
		local link = GetContainerItemLink(bag, slot)
		local itemCount = select(2, GetContainerItemInfo(bag, slot))
		local itemid, itemName
		if link then
			itemid = link:match("item:(%d+)")
			itemName = GetItemInfo(link)
			iteminfo = itemid.." "..itemCount.." "..(itemName or "_")
		end
		
		if slotcache[key] ~= iteminfo or forceupdate then
			local olditemid = (slotcache[key] or ""):match("^(%d+)")
			if itemid ~= olditemid then
				itemschanged = true
			end
			slotcache[key] = iteminfo
			self:OnSlotChanged(bag, slot)
		end
	end
	return itemschanged
end

local categoriesrun = { [true] = {}, [false] = {}}
local recursionmagic = 12345


local function CheckCategory(catid, category, bag, slot, key, isbank, cache, used)
	if (categoriesrun[isbank][catid] or 0) == recursionmagic then return end
	categoriesrun[isbank][catid] = recursionmagic
	
	if not cache[catid] then
		cache[catid] = {}
	end
	local wasMatch = cache[catid][key]
	cache[catid][key] = nil
	local anymatch
	local catmatch = false
	cache[catid]["Other"] = nil
	for ruleid, rule in ipairs(category) do
		local rulematch
		if rule.type == "Other" then
			cache[catid]["Other"] = true
		else
			if rule.type == "Category" then
				if rule.category and categories[rule.category] then
					anymatch = (CheckCategory(rule.category,categories[rule.category], bag, slot, key, isbank, cache, used) and Baggins:CategoryInUse(rule.category, isbank)) or anymatch
				end
			end
			
			if ruleid == 1 then 
				operation = "OR"
			else
				operation = rule.operation or "OR"
			end
			rulematch = (RuleTypes[rule.type] and RuleTypes[rule.type].Matches(bag,slot,rule))
			if operation == "OR" then
				catmatch = catmatch or rulematch
			elseif operation == "AND" then
				catmatch = catmatch and rulematch
			elseif operation == "NOT" then
				catmatch = catmatch and (not rulematch)
			end
		end
	end

	
	if catmatch then
		cache[catid][key] = true
	end
	
	if not wasMatch and catmatch then
		Baggins:FireSignal("CategoryMatchAdded", catid, key, isbank)
	elseif wasMatch and not catmatch then
		Baggins:FireSignal("CategoryMatchRemoved", catid, key, isbank)
	elseif catmatch and wasMatch then
		Baggins:FireSignal("SlotMoved", catid, key, isbank)
	end
	
	return catmatch or anymatch
end

function Baggins:OnSlotChanged(bag, slot)
	recursionmagic = recursionmagic + 1
	local isbank
	local cache
	if BagTypes[bag] == 2 then
		used = bankuseditems
		cache = bankcategorycache
		isbank = true
	else
		used = useditems
		cache = categorycache
		isbank = false	-- nil ain't good enuf because of how :CategoryInUse treats nils
	end
	
	local key = bag..":"..slot
	if not used[key] then
		used[key] = false
	end
	local anymatch
	for catid, category in pairs(categories) do
		if self:CategoryInUse(catid, isbank) then
		--if true then
			anymatch = CheckCategory(catid, category, bag, slot, key, isbank, cache, used) or anymatch
		end
	end
	
		
	for catid, category in pairs(categories) do
		if cache[catid] and cache[catid]["Other"] then
			local wasMatch = cache[catid][key]
			local catmatch
			if not anymatch then
				cache[catid][key] = true
				catmatch = true
			else
				cache[catid][key] = nil
			end
			if not wasMatch and catmatch then
				self:FireSignal("CategoryMatchAdded", catid, key, isbank)
			elseif wasMatch and not catmatch then
				self:FireSignal("CategoryMatchRemoved", catid, key, isbank)
			elseif catmatch and wasMatch then
				self:FireSignal("SlotMoved", catid, key, isbank)
			end	
			cache[catid]["Other"] = nil			
		end
	end
	
end

function Baggins:OnRuleChanged()
	--self:ForceFullUpdate()
	currentRule = nil
	self:CategoriesChanged()
end

local function ClearCache(cache)
	for k, v in pairs(cache) do
		if type(v) == "table" then
			ClearCache(v)
		else
			cache[k] = nil
		end
	end
end

function Baggins:ClearSortingCaches()
	ClearCache(bankuseditems)
	ClearCache(bankcategorycache)
	ClearCache(useditems)
	ClearCache(categorycache)
	ClearCache(slotcache)
end


function Baggins:ForceFullRefresh()
	self:ClearSortingCaches()
	self:ClearSectionCaches()
	self:ForceFullUpdate()
end

function Baggins:ForceFullUpdate()
	--local start = GetTime()
	local bagid
	for bagid = 0, 11 do
		self:CheckSlotsChanged(bagid, true)
	end
	self:CheckSlotsChanged(-2,true)
	self:CheckSlotsChanged(-1,true)
	self:CategoriesChanged()
	--self:Print("Full Update took "..(math.floor((GetTime()-start)*1000)/1000).." seconds")
end

function Baggins:CategoriesChanged()
	self:TriggerEvent("Baggins_CategoriesChanged")
end

function Baggins:ForceFullBankUpdate()
	for bagid in LBU:IterateBags("BANK") do
		self:CheckSlotsChanged(bagid, true)
	end
end

function Baggins:GetIncludeRule(category,create)
	local numrules = #category
	for i = numrules,1,-1 do
		if category[i].type == "ItemID" then
			if category[i].operation ~= "NOT" then
				return category[i]
			end
		end		
	end
	if create then
		local newrule = { type="ItemID", operation="OR"}
		table.insert( category, newrule )
		return newrule
	end
end

function Baggins:GetExcludeRule(category,create)
	local numrules = #category
	for i = numrules,1,-1 do
		if category[i].type == "ItemID" then
			if category[i].operation == "NOT" then
				return category[i]
			end
		end
	end
	if create then
		local newrule = { type="ItemID", operation="NOT"}
		table.insert( category, newrule )
		return newrule
	end
end

function Baggins:IncludeItemInCategory(catname, itemid)
	local cat = categories[catname]
	if not cat then return end
	
	for i, rule in ipairs(cat) do
		if rule.ids and rule.operation == "NOT" then
			rule.ids[itemid] = nil
		end
	end
	local rule = self:GetIncludeRule(cat,true)
	if not rule.ids then
		rule.ids = {}
	end
	rule.ids[itemid] = true
	--tablet:Refresh("BagginsEditCategories")
	self:RefreshEditWaterfall() 
	self:ForceFullUpdate()
end

function Baggins:ExcludeItemFromCategory(catname, itemid)
	local cat = categories[catname]
	if not cat then return end
	
	for i, rule in ipairs(cat) do
		if rule.ids and rule.operation ~= "NOT" then
			rule.ids[itemid] = nil
		end
	end
	local rule = self:GetExcludeRule(cat,true)
	if not rule.ids then
		rule.ids = {}
	end
	rule.ids[itemid] = true
	--tablet:Refresh("BagginsEditCategories")
	self:RefreshEditWaterfall() 
	self:ForceFullUpdate()
end

function Baggins:GetRuleDefinition(rulename)
	return RuleTypes[rulename] 
end

function Baggins:GetCachedItem(item)
	return slotcache[item]
end











-----------------------------------------------------------------------
-- ItemType

--------------------------
-- scanned 08/13/09 16:52:00 - patch 3.2.0

local ItemTypes = {
  ["Weapon"] = {"One-Handed Axes", "Two-Handed Axes", "Bows", "Guns", "One-Handed Maces", "Two-Handed Maces", "Polearms", "One-Handed Swords", "Two-Handed Swords", "Staves", "Fist Weapons", "Miscellaneous", "Daggers", "Thrown", "Crossbows", "Wands", "Fishing Poles"},
  ["Armor"] = {"Miscellaneous", "Cloth", "Leather", "Mail", "Plate", "Shields", "Librams", "Idols", "Totems", "Sigils"},
  ["Container"] = {"Bag", "Soul Bag", "Herb Bag", "Enchanting Bag", "Engineering Bag", "Gem Bag", "Mining Bag", "Leatherworking Bag", "Inscription Bag"},
  ["Consumable"] = {"Food & Drink", "Potion", "Elixir", "Flask", "Bandage", "Item Enhancement", "Scroll", "Other"},
  ["Glyph"] = {"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Death Knight", "Shaman", "Mage", "Warlock", "Druid"},
  ["Trade Goods"] = {"Elemental", "Cloth", "Leather", "Metal & Stone", "Meat", "Herb", "Enchanting", "Jewelcrafting", "Parts", "Devices", "Explosives", "Materials", "Other", "Armor Enchantment", "Weapon Enchantment"},
  ["Projectile"] = {"Arrow", "Bullet"},
  ["Quiver"] = {"Quiver", "Ammo Pouch"},
  ["Recipe"] = {"Book", "Leatherworking", "Tailoring", "Engineering", "Blacksmithing", "Cooking", "Alchemy", "First Aid", "Enchanting", "Fishing", "Jewelcrafting", "Inscription"},
  ["Gem"] = {"Red", "Blue", "Yellow", "Purple", "Green", "Orange", "Meta", "Simple", "Prismatic"},
  ["Miscellaneous"] = {"Junk", "Reagent", "Pet", "Holiday", "Other", "Mount"},
  ["Quest"] = {},
}

-- Manually added types that do not appear in AH scan
assert(#ItemTypes["Quest"]==0)	-- alert dev if scanned array suddenly looks different
ItemTypes["Quest"] = { "Quest" }
assert(not ItemTypes["Key"])    -- alert dev if scanned array suddenly looks different
ItemTypes["Key"] = { "Key" }


--[[
SELECTED_CHAT_FRAME:AddMessage("--------------------------")
SELECTED_CHAT_FRAME:AddMessage("-- scanned "..date("%c").. " - patch "..(GetBuildInfo()))
SELECTED_CHAT_FRAME:AddMessage("local ItemTypes = {")
for i,class in pairs{GetAuctionItemClasses()} do
  local subs={GetAuctionItemSubClasses(i)}
  if #subs>0 then
    
    SELECTED_CHAT_FRAME:AddMessage('  ["'..class..'"] = {"'..
      table.concat(subs, '", "') ..
    '"},')
  else
    SELECTED_CHAT_FRAME:AddMessage('  ["'..class..'"] = {},')
  end
end
SELECTED_CHAT_FRAME:AddMessage("}")
--]]

Baggins:AddCustomRule("ItemType", {
		DisplayName = L["Item Type"],
		Description = L["Filter by Item type and sub-type as returned by GetItemInfo"],
		Matches = function(bag,slot,rule) 
			if not (rule.itype or rule.isubtype) then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				local Type, SubType = select(6, GetItemInfo(link))
				if Type and SubType then
					return Type == BI[rule.itype] and (rule.isubtype == nil or SubType == BI[rule.isubtype] )	
				end
			end
		end,
		GetName = function(rule) 
			local ltype, lsubtype = "*", "*"
			if rule.itype then
				ltype = BI[rule.itype] or "?"
			end
			if rule.isubtype then
				lsubtype = BI[rule.isubtype] or "?"
			end
			return L["ItemType - "]..ltype..":"..lsubtype
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Item Type Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Item Type"], 'hasArrow', true,'value',"ItemType")
				dewdrop:AddLine('text', L["Item Subtype"], 'hasArrow', true,'value',"ItemSubtype")

			elseif level == 2 and value == "ItemType" then	
				for k, v in pairs(ItemTypes) do
					dewdrop:AddLine('text', BI[k], "checked", rule.itype == k,"func",function(k) rule.itype = k rule.isubtype = nil Baggins:OnRuleChanged() end,"arg1",k)
				end
			elseif level == 2 and value == "ItemSubtype" then
				dewdrop:AddLine('text', L["All"], "checked", rule.isubtype == nil,"func",function() rule.isubtype = nil Baggins:OnRuleChanged() end)
				dewdrop:AddLine()
				if rule.itype and ItemTypes[rule.itype] then
					for k, v in ipairs(ItemTypes[rule.itype]) do
						dewdrop:AddLine('text', BI[v], "checked", rule.isubtype == v,"func",function(v) rule.isubtype = v Baggins:OnRuleChanged() end,"arg1",v)
					end
				end
			end
		end,
		CleanRule = function(rule)
			rule.itype="Miscellaneous"
		end
})

-----------------------------------------------------------------------
-- ContainerType

Baggins:AddCustomRule("ContainerType", {
		DisplayName = L["Container Type"],
		Description = L["Filter by the type of container the item is in."],	
		Matches = function(bag,slot,rule)
			if bag < 1 or bag > 11 then return end
			if not rule.ctype then return end
			local link = GetInventoryItemLink("player",ContainerIDToInventoryID(bag))
			if link then
				local SubType = select(7, GetItemInfo(link))
				if SubType then
					return SubType == BI[rule.ctype]
				end
			end
		end,
		GetName = function(rule) 
			local ctype
			if rule.ctype then
				ctype = BI[rule.ctype]
			else
				ctype = L["None"]
			end
			return L["Container : "]..ctype
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Container Type Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Container Type"], 'hasArrow', true,'value',"ContainerType")
	
			elseif level == 2 and value == "ContainerType" then
				dewdrop:AddLine('text', L["All"], "checked", rule.ctype == nil,"func",function() rule.ctype = nil Baggins:OnRuleChanged() end)
				dewdrop:AddLine()
				for k, v in ipairs(ItemTypes["Container"]) do
					dewdrop:AddLine('text', BI[v], "checked", rule.ctype == v,"func",function(v) rule.ctype = v Baggins:OnRuleChanged() end,"arg1",v)
				end	
				for k, v in ipairs(ItemTypes["Quiver"]) do
					dewdrop:AddLine('text', BI[v], "checked", rule.ctype == v,"func",function(v) rule.ctype = v Baggins:OnRuleChanged() end,"arg1",v)
				end		
			end
		end
})





-----------------------------------------------------------------------
-- ItemID

Baggins:AddCustomRule("ItemID", {
		DisplayName = L["Item ID"],
		Description = L["Filter by ItemID, this can be a space delimited list or ids to match."],
		Matches = function(bag,slot,rule) 
			if not rule.ids then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemid = link:match("item:(%d+)")
				return rule.ids[tonumber(itemid)]
			end
		end,
		GetName = function(rule) 
			return L["ItemIDs "]
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["ItemID Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Current IDs, click to remove"], 'isTitle', true)
				if rule.ids then
					for k, v in pairs(rule.ids) do
						local name = GetItemInfo(k)
						dewdrop:AddLine('text', k.." "..(name or ""),"func", function(id) rule.ids[id] = nil end, "arg1", k )
					end
				end
				dewdrop:AddLine('text', L["New"], 'hasArrow', true,'value',"NewID","hasEditBox",true,"editBoxText", "",
								"editBoxFunc", function(text) 
									local id = tonumber(text)
									if not id then
										id = tonumber(text:match("item:(%d+)"))
									end
									if id ~= 0 then
										if not rule.ids then
											rule.ids = {}
										end
										rule.ids[id] = true 
									end
									Baggins:OnRuleChanged() 
								end )

			end
		end,
})


-----------------------------------------------------------------------
-- Bag

Baggins:AddCustomRule("Bag", {
		DisplayName = L["Bag"],
		Description = L["Filter by the bag the item is in"],	
		Matches = function(bag,slot,rule) 
			if rule.noempty then
				local link = GetContainerItemLink(bag, slot)
				if link then
					return bag == rule.bagid 
				end
			else
				return bag == rule.bagid
			end
		end,
		GetName = function(rule) 
			return "Bag "..(BagNames[rule.bagid] or rule.bagid or "*none*")..((rule.noempty and " *NotEmpty*") or "")
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Bag Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Bag"], 'hasArrow', true,'value',"Bag")
				dewdrop:AddLine('text', L["Ignore Empty Slots"], "checked", rule.noempty ,"func",function() rule.noempty = not rule.noempty Baggins:OnRuleChanged() end)	
			elseif level == 2 and value == "Bag" then
				dewdrop:AddLine('text', L["Backpack"], "checked", rule.bagid == 0,"func",function() rule.bagid = 0 Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["Bag1"], "checked", rule.bagid == 1,"func",function() rule.bagid = 1 Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["Bag2"], "checked", rule.bagid == 2,"func",function() rule.bagid = 2 Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["Bag3"], "checked", rule.bagid == 3,"func",function() rule.bagid = 3 Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["Bag4"], "checked", rule.bagid == 4,"func",function() rule.bagid = 4 Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["KeyRing"], "checked", rule.bagid == -2,"func",function() rule.bagid = -2 Baggins:OnRuleChanged() end)
			end
		end,
		CleanRule = function(rule)
			rule.bagid=0
		end,
})


-----------------------------------------------------------------------
-- ItemName

Baggins:AddCustomRule("ItemName", {
		DisplayName = L["Item Name"],
		Description = L["Filter by Name or partial name"],	
		Matches = function(bag,slot,rule) 
			if not rule.match then return end
			local link = GetContainerItemLink(bag, slot)
			
			if link then
				local itemname = GetItemInfo(link)
				if itemname and itemname:lower():match(rule.match:lower()) then
					return true
				end
			end
		end,
		GetName = function(rule) 
			return L["Name: "]..(rule.match or "")
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Item Name Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["String to Match"], 'hasArrow', true,"hasEditBox",true,"editBoxText", rule.match or "","editBoxFunc", function(text) rule.match = text Baggins:OnRuleChanged() end )	
			end
		end,
})


-----------------------------------------------------------------------
-- Empty

Baggins:AddCustomRule("Empty", {
		DisplayName = L["Empty Slots"],
		Description = L["Empty bag slots"],
		Matches = function(bag,slot,rule) 
			if not (bag and slot) then return end
			if BagTypes[bag] == 3 then return end
			local link = GetContainerItemLink(bag, slot)
			if not link then 
				return true 
			end
		end,
		GetName = function(rule) 
			return L["Empty Slots"]
		end,
		DewDropOptions = function(rule, level, value) 
		end,
})


-----------------------------------------------------------------------
-- NewItems

Baggins:AddCustomRule("NewItems", {
		DisplayName = L["New Items"],
		Description = L["New Items"],
		Matches = function(bag,slot,rule) 
			if not (bag and slot) then return end
			if BagTypes[bag] ~= 1 then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				return Baggins:IsNew(link)			
			end
		end,
		GetName = function(rule) 
			return L["New Items"]
		end,
		DewDropOptions = function(rule, level, value) 
		end,
})




-----------------------------------------------------------------------
-- Category

Baggins:AddCustomRule("Category", {
		DisplayName = L["Category"],
		Description = L["Items that match another category"],
		Matches = function(bag,slot,rule) 
			if not (bag and slot and rule.category) then return end
			local key = bag..":"..slot
			if BagTypes[bag] == 2 then
				return bankcategorycache[rule.category] and bankcategorycache[rule.category][key]
			else
				return categorycache[rule.category] and categorycache[rule.category][key]
			end
		end,
		GetName = function(rule) 
			if rule.category then
				return L["Category"].." :"..rule.category
			else
				return L["Category"]
			end
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Category Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Category"], 'hasArrow', true,'value',"Category")

			elseif level == 2 and value == "Category" then	
				for k, v in pairs(categories) do
					dewdrop:AddLine('text', k, "checked", rule.category == k,"func",function(v) rule.category = k Baggins:OnRuleChanged() end,"arg1",v)
				end
			end
		end,
})



-----------------------------------------------------------------------
-- AmmoBag

Baggins:AddCustomRule("AmmoBag", {
		DisplayName = L["Ammo Bag"],
		Description = L["Items in an ammo pouch or quiver"],
		Matches = function(bag,slot,rule) 
			local _,fam = GetContainerNumFreeSlots(bag)
			return fam and band(fam, 3)~=0
		end,
		GetName = function(rule) 
			return L["Ammo Bag Slots"]
		end,
		DewDropOptions = function(rule, level, value)
		end,
})



-----------------------------------------------------------------------
-- Quality

Baggins:AddCustomRule("Quality", {
		DisplayName = L["Quality"],
		Description = L["Filter by Item Quality"],
		Matches = function(bag,slot,rule) 
			if not (rule.comp and rule.quality) then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				local Rarity = select(3, GetItemInfo(link))
				if Rarity then
					return ( rule.comp == "==" and Rarity == rule.quality ) or
					       ( rule.comp == "<=" and Rarity <= rule.quality ) or
					       ( rule.comp == ">=" and Rarity >= rule.quality )
				end
			end
		end,
		GetName = function(rule) 
			if rule.quality then
				local r,g,b,hex = GetItemQualityColor(rule.quality)
				qualname = hex..QualityNames[rule.quality]
			else
				qualname = "*none*"
			end
			return L["Quality"].." "..(rule.comp or "==").." "..qualname
		end,
		DewDropOptions = function(rule, level, value)
			if level == 1 then
				dewdrop:AddLine('text', L["Quality Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Quality"], 'hasArrow', true,'value',"Quality")
				dewdrop:AddLine('text', L["Comparison"], 'hasArrow', true, 'value', "QualComp")
		
			elseif level == 2 and value == "Quality" then
				for i = 0, #QualityNames do
					local r,g,b = GetItemQualityColor(i)
					dewdrop:AddLine('text', QualityNames[i], "checked", rule.quality == i,"func",function() rule.quality = i Baggins:OnRuleChanged() end,
									'textR',r,'textG',g,'textB',b)
				end
			elseif level == 2 and value == "QualComp" then		
				dewdrop:AddLine('text', "==", "checked", rule.comp == "==","func",function() rule.comp = "==" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', "<=", "checked", rule.comp == "<=","func",function() rule.comp = "<=" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', ">=", "checked", rule.comp == ">=","func",function() rule.comp = ">=" Baggins:OnRuleChanged() end)
			end
		end,
		CleanRule = function(rule)
			rule.quality = 1
			rule.comp = "=="
		end,
})


-----------------------------------------------------------------------
-- EquipLoc

Baggins:AddCustomRule("EquipLoc", {
		DisplayName = L["Equip Location"],
		Description = L["Filter by Equip Location as returned by GetItemInfo"],
		Matches = function(bag,slot,rule) 
			if not rule.equiploc then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				local EquipLoc = select(9, GetItemInfo(link))
				if EquipLoc then
					return EquipLoc == rule.equiploc
				end
			end
		end,
		GetName = function(rule) 
			return "Equip Location: "..(getglobal(rule.equiploc) or rule.equiploc or "*None*")
		end,
		DewDropOptions = function(rule, level, value) 
			if level == 1 then
				dewdrop:AddLine('text', L["Equip Location Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Location"], 'hasArrow', true,'value',"Location")

			elseif level == 2 and value == "Location" then	
				for k, v in pairs(EquipLocs) do
					dewdrop:AddLine('text', getglobal(v) or v or "", "checked", rule.equiploc == v,"func",function(v) rule.equiploc = v Baggins:OnRuleChanged() end,"arg1",v)
				end
			end
		end,
		CleanRule = function(rule)
			rule.equiploc = EquipLocs[1]
		end,
})



-----------------------------------------------------------------------
-- ItemLevel

Baggins:AddCustomRule("ItemLevel", {
		DisplayName = L["Item Level"],
		Description = L["Filter by item's level - either \"ilvl\" or minimum required level"],
		Matches = function(bag,slot,rule)
			local link = GetContainerItemLink(bag, slot)
			if not link then return false end
			
			local _,_,_, itemLevel, itemMinLevel = GetItemInfo(link)
			local lvl = rule.useminlvl and itemMinLevel or itemLevel
			
			if not lvl then	-- can happen if itemcache hasn't been updated yet
				return false
			end
			
			if rule.include0 and lvl==0 then
				return true
			end
			if rule.include1 and lvl==1 then
				return true
			end
			
			local minlvl = rule.minlvl or -999
			local maxlvl = rule.maxlvl or 999
			if rule.minlvl_rel then
				minlvl = UnitLevel("player")+minlvl
			end
			if rule.maxlvl_rel then
				maxlvl = UnitLevel("player")+maxlvl
			end
			
			return lvl>=minlvl and lvl<=maxlvl
		end,
		GetName = function(rule)
			local minlvl = rule.minlvl or -999
			local maxlvl = rule.maxlvl or 999
			if rule.minlvl_rel then
				minlvl = UnitLevel("player")+minlvl
			end
			if rule.maxlvl_rel then
				maxlvl = UnitLevel("player")+maxlvl
			end
			return (rule.useminlvl and L["ReqLvl"] or L["ILvl"]) .. ": " ..
				(rule.include0 and "0, " or "") ..
				(rule.include1 and "1, " or "") ..
				max(minlvl,0) .. "-" ..
				min(maxlvl,999);
		end,
		DewDropOptions = function(rule, level, value)
			if level==1 then
				dewdrop:AddLine('text', L["Item Level Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Include Level 0"], "checked", rule.include0, "func",
					function(b) rule.include0=not rule.include0; Baggins:OnRuleChanged() end);
				dewdrop:AddLine('text', L["Include Level 1"], "checked", rule.include1, "func",
					function(b) rule.include1=not rule.include1; Baggins:OnRuleChanged() end);
				dewdrop:AddLine('text', L["Look at Required Level"], "checked", rule.useminlvl, "func",
					function(b) rule.useminlvl=not rule.useminlvl; Baggins:OnRuleChanged() end);
				dewdrop:AddLine('text', L["Look at Item's \"ILvl\""], "checked", not rule.useminlvl, "func",
					function(b) rule.useminlvl=not rule.useminlvl; Baggins:OnRuleChanged() end);
				dewdrop:AddSeparator()
				dewdrop:AddLine('text', L["From level:"], "hasArrow", true, "hasEditBox", true, 
					"editBoxText", tonumber(rule.minlvl) or -15, "editBoxFunc",
					function(text) rule.minlvl = tonumber(text) or -15; Baggins:OnRuleChanged() end);
				dewdrop:AddLine('text', L["... plus Player's Level"], "checked", rule.minlvl_rel, "func",
					function(b) rule.minlvl_rel=not rule.minlvl_rel; Baggins:OnRuleChanged() end);
				dewdrop:AddSeparator()
				dewdrop:AddLine('text', L["To level:"], "hasArrow", true, "hasEditBox", true, 
					"editBoxText", tonumber(rule.maxlvl) or 999, "editBoxFunc",
					function(text) rule.maxlvl = tonumber(text) or 999; Baggins:OnRuleChanged() end);
				dewdrop:AddLine('text', L["... plus Player's Level"], "checked", rule.maxlvl_rel, "func",
					function(b) rule.maxlvl_rel=not rule.maxlvl_rel; Baggins:OnRuleChanged() end);
			end
		end,
		CleanRule = function(rule)
			rule.include0 = true
			rule.include1 = false
			rule.useminlvl = false
			rule.minlvl_rel = true
			rule.minlvl = -15
			rule.maxlvl_rel = true
			rule.maxlvl = 10
		end,
})



-----------------------------------------------------------------------
-- Other

Baggins:AddCustomRule("Other", {
		DisplayName = L["Unfiltered Items"],
		Description = L["Matches all items that arent matched by any other bag, NOTE: this should be the only rule in a category, others will be ignored"],
		Matches = function(bag,slot,rule) 
			
			--local key = bag..":"..slot
			--return not useditems[key]
		end,
		GetName = function(rule) 
			return L["Unfiltered"]
		end,
		DewDropOptions = function(rule, level, value) 
			
		end,
})


-----------------------------------------------------------------------
-- Bind

Baggins:AddCustomRule("Bind", {
		DisplayName = L["Bind"],
		Description = L["Filter based on if the item binds, or if it is already bound"],
		Matches = function(bag, slot, rule)
			if not rule.bindtype then return end
			if rule.bindtype == "Soulbound" then
				if bag == -1 then
					gratuity:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
				else
					gratuity:SetBagItem(bag,slot)
				end
				if gratuity:Find(ITEM_SOULBOUND,2,3,false,false,true) then
					return true
				end
			elseif rule.bindtype == "Unbound" then
				local link = GetContainerItemLink(bag,slot)
				if link then
					if bag == -1 then
						gratuity:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
					else
						gratuity:SetBagItem(bag,slot)
					end
					if not gratuity:Find(ITEM_SOULBOUND,2,3,false,false,true) then
						return true
					end
				end
			elseif rule.bindtype == "BoP" then
				local link = GetContainerItemLink(bag,slot)
				if link then
					gratuity:SetHyperlink(link)
					if gratuity:Find(ITEM_BIND_ON_PICKUP,2,3) then
						return true
					end
				end
			elseif rule.bindtype == "BoE" then
				local link = GetContainerItemLink(bag,slot)
				if link then
					gratuity:SetHyperlink(link)
					if gratuity:Find(ITEM_BIND_ON_EQUIP,2,3) then
						return true
					end
				end
			elseif rule.bindtype == "BoU" then
				local link = GetContainerItemLink(bag,slot)
				if link then
					gratuity:SetHyperlink(link)
					if gratuity:Find(ITEM_BIND_ON_USE,2,3) then
						return true
					end
				end
			elseif rule.bindtype == "BoA" then
				local link = GetContainerItemLink(bag,slot)
				if link then
					gratuity:SetHyperlink(link)
					if gratuity:Find(ITEM_BIND_TO_ACCOUNT,2,3) then
						return true
					end
				end
			end
		end,
		GetName = function(rule)
			if rule.bindtype == "Soulbound" then
				return ITEM_SOULBOUND
			elseif rule.bindtype == "Unbound" then
				return L["Unbound"]
			elseif rule.bindtype == "BoP" then
				return ITEM_BIND_ON_PICKUP
			elseif rule.bindtype == "BoE" then
				return ITEM_BIND_ON_EQUIP
			elseif rule.bindtype == "BoU" then
				return ITEM_BIND_ON_USE
			elseif rule.bindtype == "BoA" then
				return ITEM_BIND_TO_ACCOUNT
			else
				return L["Bind *unset*"]
			end
		end,
		DewDropOptions = function(rule, level, value)
			if level == 1 then
				dewdrop:AddLine('text', L["Bind Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["Bind Type"], 'hasArrow', true,'value',"BindType")

			elseif level == 2 and value == "BindType" then	
				dewdrop:AddLine('text', ITEM_SOULBOUND, "checked", rule.bindtype == "Soulbound","func",function() rule.bindtype = "Soulbound" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', L["Unbound"], "checked", rule.bindtype == "Unbound","func",function() rule.bindtype = "Unbound" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', ITEM_BIND_ON_PICKUP, "checked", rule.bindtype == "BoP","func",function() rule.bindtype = "BoP" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', ITEM_BIND_ON_EQUIP, "checked", rule.bindtype == "BoE","func",function() rule.bindtype = "BoE" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', ITEM_BIND_ON_USE, "checked", rule.bindtype == "BoU","func",function() rule.bindtype = "BoU" Baggins:OnRuleChanged() end)
				dewdrop:AddLine('text', ITEM_BIND_TO_ACCOUNT, "checked", rule.bindtype == "BoA","func",function() rule.bindtype = "BoA" Baggins:OnRuleChanged() end)
			end
		end,
})




-----------------------------------------------------------------------
-- Tooltip

Baggins:AddCustomRule("Tooltip", {
		DisplayName = L["Tooltip"],
		Description = L["Filter based on text contained in its tooltip"],
		Matches = function(bag, slot, rule)
			if not rule.text then return end
			local text = rule.text
			--if the text is the name of a global string then match against that
			if text:upper() == text then
				local gtext = getglobal(rule.text)
				if type(gtext) == "string" then
					text = gtext
				end
			end
			if bag == -1 then
				gratuity:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
			else
				gratuity:SetBagItem(bag,slot)
			end
			if gratuity:Find(text) then
				return true
			end
		end,
		GetName = function(rule)
			return L["Tooltip"]..": "..(rule.text or "")
		end,
		DewDropOptions = function(rule, level, value)
			if level == 1 then
				dewdrop:AddLine('text', L["Tooltip Options"], 'isTitle', true)
				dewdrop:AddLine('text', L["String to Match"], 'hasArrow', true,"hasEditBox",true,"editBoxText", rule.text or "","editBoxFunc", function(text) rule.text = text Baggins:OnRuleChanged() end )	
			end
		end,
})




-----------------------------------------------------------------------
-- PTSet

---------------------
-- PT Set Browser  --
---------------------
function Baggins:BuildPTSetTable()
	if not (pt and self.ptsetsdirty) then return end
	ptsets.args = {}

	local sets = pt.sets

	for setname in pairs(sets) do
		local workingLevel = ptsets.args
		local oldLevel, oldParent, allowedFlag
		for parent in setname:gmatch("([^%.]+)") do
			if not workingLevel[parent] then
				workingLevel[parent] = {
					type = "group",
					name = parent,
					desc = parent,
					args = {}
				}
				allowedFlag = true
			else
				allowedFlag = false
			end
			for k, v in pairs(workingLevel) do
				local kname = k:match("0077ff([^%*]+)")
				if kname == parent then
					workingLevel[k] = nil
				end
			end

			oldLevel = workingLevel
			oldParent = parent
			workingLevel = workingLevel[parent].args
		end
		if allowedFlag then
			oldLevel[oldParent].name = oldLevel[oldParent].name
			oldLevel[oldParent].type = "execute"
			oldLevel[oldParent].func = function()
				currentRule.setname = setname
				self:OnRuleChanged()
			end
		end
	end

	local function addSelfSetToOptions(table, name)
		if table.args then
			for k, v in pairs(table.args) do
				local x = name
				if v.args then
					if x then
						x = x .. "." .. k
					else
						x = k
					end
					addSelfSetToOptions(v, x)
				end
			end
			table.args.spacer = {
				type = "header",
				name = " ",
				order = 999,
			}
			
			table.args.thisSet = {
				order = 1000,
				type = "execute",
				name = name,
				desc = name,
				func = function()
					currentRule.setname = name
					self:OnRuleChanged()
				end
			}
		end
	end

	addSelfSetToOptions(ptsets)
	ptsets.args.spacer = nil
	ptsets.args.thisSet = nil
	self.ptsetsdirty = false
end


if pt then
	Baggins:AddCustomRule("PTSet", {
		DisplayName = L["PeriodicTable Set"],
		Description = L["Filter by PeriodicTable Set"],	
		Matches = function(bag,slot,rule) 
			if not rule.setname then return end
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemid = link:match("item:(%d+)")
				itemid = tonumber(itemid)
				return pt:ItemInSet(itemid,rule.setname)
			end
		end,
		GetName = function(rule) 
			return "PTSet:"..(rule.setname or "*none*")
		end,
		DewDropOptions = function(rule, level, value, value_1, value_2)
			Baggins:BuildPTSetTable()
			if level == 1 then
				dewdrop:AddLine('text', L["Periodic Table Set Options"], 'isTitle', true)
			end
			dewdrop:FeedAceOptionsTable(ptsets)
		end,
	})
end
