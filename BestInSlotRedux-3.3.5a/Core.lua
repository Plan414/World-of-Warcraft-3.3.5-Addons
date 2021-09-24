--  lua functions
local select, setmetatable, error, type, rawget, rawset, pairs, tonumber, strsplit, tContains, unpack, tostring, wipe, tinsert, tsort, tconcat, tremove 
    = select, setmetatable, error, type, rawget, rawset, pairs, tonumber, strsplit, tContains, unpack, tostring, wipe, table.insert, table.sort, table.concat, table.remove
-- WoW API
local GetNumSpecializations, GetSpecializationInfo, GetItemInfo, IsEquippedItem, GetContainerNumSlots, GetContainerItemID, UnitClass, GetInventorySlotInfo, GetNumGuildMembers, ConvertRGBtoColorString, GetInventoryItemLink, GetContainerItemInfo, GetAddOnMetadata, GetItemSpecInfo, GetItemUniqueness, IsInGuild, GetGuildInfo, GetSpecialization, GetSpecializationInfoByID, IsInRaid, UnitName, IsInGroup, GetGuildRosterInfo, UnitFullName, UnitRace, UnitSex
    = GetNumSpecializations, GetSpecializationInfo, GetItemInfo, IsEquippedItem, GetContainerNumSlots, GetContainerItemID, UnitClass, GetInventorySlotInfo, GetNumGuildMembers, ConvertRGBtoColorString, GetInventoryItemLink, GetContainerItemInfo, GetAddOnMetadata, GetItemSpecInfo, GetItemUniqueness, IsInGuild, GetGuildInfo, GetSpecialization, GetSpecializationInfoByID, IsInRaid, UnitName, IsInGroup, GetGuildRosterInfo, UnitFullName, UnitRace, UnitSex

local E = select(2, ...)
local BestInSlot = LibStub("AceAddon-3.0"):NewAddon("BestInSlotRedux", "AceComm-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BestInSlotRedux")
local AceEvent = LibStub("AceEvent-3.0")
E[1] = BestInSlot
E[2] = L
E[3] = AceGUI
BestInSlot.unsafeIDs = {}
BestInSlot.options = {}
BestInSlot.defaultModuleState = false
BestInSlot.options.DEBUG = false
-- Authors
BestInSlot.Author1 = ("%s%s @ %s"):format("|c"..RAID_CLASS_COLORS.DEMONHUNTER.colorStr, "Beleria".."|r",ConvertRGBtoColorString(PLAYER_FACTION_COLORS[1]).."Argent Dawn-EU|r")
BestInSlot.Author2 = ("%s%s @ %s"):format("|c"..RAID_CLASS_COLORS.PALADIN.colorStr, "Anhility".."|r",ConvertRGBtoColorString(PLAYER_FACTION_COLORS[1]).."Ravencrest-EU|r")
BestInSlot.Author3 = ("%s%s @ %s"):format("|c"..RAID_CLASS_COLORS.ROGUE.colorStr, "Sar\195\173th".."|r",ConvertRGBtoColorString(PLAYER_FACTION_COLORS[1]).."Tarren Mill-EU|r")
--[===[@non-debug@ 
BestInSlot.version = @project-date-integer@
--@end-non-debug@]===]
BestInSlot.AlphaVersion = not (GetAddOnMetadata("BestInSlotRedux", "Version"):find("Release") and true or false)
--@do-not-package@
BestInSlot.version = 1337
BestInSlot.options.DEBUG = true
--@end-do-not-package@
local slashCommands = {}
local defaults = {
  char = {
    ['*'] = { --raidTier
      ['*'] = { --raidDifficulty
         ['*'] = { --listType (spec as number, customList as string)
           ['*'] = nil
         }
       },
    },
    latestVersion = 1,
    selected = {},
    windowpos = {},
    customlists = {},
    tutorials = {},
    options = {
      windowFixed = false,
      showBiSTooltip = true,
      sendAutomaticUpdates = true,
      receiveAutomaticUpdates = true,
      minimapButton = true,
      guildtooltip = true,
      showBossTooltip = true,
      keepHistory = false,
      tooltipCombat = false,
      historyLength = "30d",
      historyAutoDelete = true,
      tooltipSource = true,
      statsInManager = true,
      showGuildRankInTooltip = {
        ['*'] = true
      },
      overviewfilter = {},
    },
  },
  global = {
    options = {
      instantAnimation = false,
    },
    customitems = {
      
    },
    tutorials = true,
  },
  factionrealm = {
    _history = {
      ['*'] = {}, --players database 
    },
    ['*'] = { --guildname
      ['*'] = { -- charactername
        ['*'] = { -- raidTier
          ['*'] = { -- difficulty
          
          }
        }
      }
    }
  },
  profile = {
    minimap = {
      hide = false,
    }
  },
}
---
--Datatypes to be used with some of BestInSlots functions
---
BestInSlot.EXPANSION = 1
BestInSlot.RAIDTIER = 2
BestInSlot.INSTANCE = 3
BestInSlot.BOSS = 4
BestInSlot.DIFFICULTY = 5
BestInSlot.SPECIALIZATION = 6

BestInSlot.MSGPREFIX = "BiS"
---
--Color codes used by the add-on
---
BestInSlot.colorHighlight = RED_FONT_COLOR_CODE
BestInSlot.colorNormal = NORMAL_FONT_COLOR_CODE
---
--data = {
--  raidTiers = {
--    [raidTierId] = {
--      description = "Raid Tier Description",
--      difficulties = {"difficultyName1", "difficultyName2"},
--      expansion = expansionId, 
--      instances = {},
--      tierTokens = {},
--      tierItems = {
--        [Class1] = {
--          [difficultyName1] = {
--            tierItemId1,
--            tierItemId2,
--            tierItemId3,
--          },
--          [difficultyName2] = {
--            tierItemId1,
--            tierItemId2,
--            tierItemId3,
--          },
--        }
--      } 
--    }
--  },
--  instances = {
--    [instanceId] = {
--      raidTier = raidTierID,
--      expansion = expansionId,
--      description = "Description
--    }    
--  },
--  expansions = {
--    [expansionId] = {
--      raidTiers = {},
--      instances = {},
--      description = "Description",
--    }
--  }
--}
---
local data = {
  raidTiers = {},
  instances = {__default={
    difficultyconversion = {
      -- [1] = 3, --default conversion of difficulties, normal -> 0
      -- [2] = 5, --Heroic -> 5
      -- [3] = 6,  --Mythic -> 6
      -- [4] = 23,  --Mythic -> 6
      [3] = 1, --default conversion of difficulties, normal -> 0
      [2] = 2, --"Heroic" (Dungeons)
      [5] = 2, --"10 Player (Heroic)"
      [6] = 3,  --Mythic
      [14] = 1, --Raid Normal
      [15] = 2, --Raid Heroic
      [16] = 3, --Raid Mythic
      [23] = 3, --Dungeon Mythic
    },
    bonusids = {
      [1] = 0,
      [2] = 1798,
      [3] = 1799,
      [4] = 0
    },
  }},
  expansions = {},
  bosses = {},
  tiertokens = {},
}
---
--itemData = {
--  [instanceName]={
--    [bossId] = {
--      [itemid] = {
--        dungeon = "dungeon",
--        link = "link",
--        isBiS = {
--          [difficulty] = {
--            [specId] = true
--          }
--        }
--        [difficulty] = ..
--        equipSlot = "INVTYPE_[SLOT]"
--      }
--    }
--  }
--}
--
--itemData's metatable can accept itemids. When it is requested an itemid it'll look in nested tables to find the item in question
---
local itemDataCache = {}
local itemData = setmetatable({},{
   __index = function(tbl, key)
      local value = itemDataCache[key]
      if value then return value end
      for dungeon,dungeonData in pairs(tbl) do --we can do this without error checking because the __newindex metamethod will check if it's a table
        for bossId, bossData in pairs(dungeonData) do
          if bossData[key] then itemDataCache[key] = bossData[key] return itemDataCache[key] end
        end
      end
   end,
   __newindex = function(table, key, value)
      if type(value) ~= "table" then error("Can only add tables to the itemData table") end
      rawset(table, key, value)
   end
})
local tierTokenData = {}
local customItems = {}
BestInSlot.slots = {"HeadSlot", "NeckSlot","ShoulderSlot","BackSlot","ChestSlot","WristSlot","HandsSlot","WaistSlot","LegsSlot","FeetSlot", "Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot", "MainHandSlot","SecondaryHandSlot"}
BestInSlot.invSlots = {
  [1] = "INVTYPE_HEAD",
  [2] = "INVTYPE_NECK",
  [3] = "INVTYPE_SHOULDER",
  [4] = "INVTYPE_BODY",
  [5] = {"INVTYPE_CHEST", "INVTYPE_ROBE"},
  [6] = "INVTYPE_WAIST",
  [7] = "INVTYPE_LEGS",
  [8] = "INVTYPE_FEET",
  [9] = "INVTYPE_WRIST",
  [10] = "INVTYPE_HAND",
  [11] = "INVTYPE_FINGER",
  [12] = "INVTYPE_FINGER",
  [13] = "INVTYPE_TRINKET",
  [14] = "INVTYPE_TRINKET",
  [15] = "INVTYPE_CLOAK",
  [16] = {"INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT"},
  [17] = {"INVTYPE_WEAPONOFFHAND", "INVTYPE_SHIELD", "INVTYPE_WEAPON", "INVTYPE_HOLDABLE"},
  --[18] = {"INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT", "INVTYPE_RELIC"} 
}
BestInSlot.dualWield = {250, 251, 252, 268, 269, 259, 260, 261, 263, 71, 72}

------------------------------------------------------------------------------------------------------------------------------------------------
-- MODULE REGISTRATION 
------------------------------------------------------------------------------------------------------------------------------------------------

--- This function can be used by modules to add their data to the add-on. It checks if the proper values are set
--@param #string unlocalizedName the Localized Name of the expansion to register
--@param #string localizedDescription The localized description of the expansion to add
function BestInSlot:RegisterExpansion(unlocalizedName, localizedDescription)
  if data.expansions[unlocalizedName]  then
    return
  end
  data.expansions[unlocalizedName] = {description = localizedDescription, raidTiers = {}, instances = {}}
end
--- Registers a raid tier to BestInSlot
-- @param #string expansion The expansion ID, must have been registered before by using BestInSlot:RegisterExpansion
-- @param #number raidTier The number corresponding with the Raid Tier, must be unique. The standard is to use the patch version the raid tier belongs to (e.g. 50400 for patch 5.4)
-- @param #string description The description of the raid tier. By default 'Patch 5.4'
-- @param #... The next parameters are considered the difficulties you would like to add, can be "Normal", "Heroic", and "Mythic".
function BestInSlot:RegisterRaidTier(expansion, raidTier, description, ...)
  local difficulties = {...}
  if data.raidTiers[raidTier] then error("This raid tier is already registered!") end
  if not data.expansions[expansion] then error("The expansion has not been registered yet!") end
  if not description or type(description) ~= "string" then error("The raid tier needs to provide a description!") end
  if not difficulties or #difficulties == 0  then error("The raid tier "..description.." needs to provide difficulties!") end
  for i = 1,#difficulties do
    if type(difficulties[i]) ~= "string" then error("Difficulty parameter not set correctly") end
  end
  data.raidTiers[raidTier] = {description = description, difficulties = difficulties}
  data.raidTiers[raidTier].expansion = expansion
  data.raidTiers[raidTier].instances = {}
  data.raidTiers[raidTier].module = (raidTier >= 69000) and "PvP" or (raidTier < 60000) and "WoDDungeon" or "WoD"
  tinsert(data.expansions[expansion].raidTiers, raidTier)
end

local newInstanceMetatable = {
  --[[__index = function(tbl, key)
    local value = rawget(tbl, key)
    if value then return value end
    for k,v in pairs(tbl) do
      if v[key] then return v[key] end
    end
  end,]]
  __newindex = function(tbl, key, value)
    if type(value) ~= "table" then error("Can only add tables with item info inside instance tables") end
    if key == "tieritems" or key == "misc" or key == "customitems" then
      rawset(tbl, key, value)
      return
    end
    key = tonumber(key)
    if not key then error("Key must be a number!") end
    rawset(tbl, key, value)
  end
}

local instanceDefaultIndexMetatable = {
  __index = function(tbl, key)
    return data.instances.__default[key]
  end
}

---Register a raid instance to BestInSlot
--@param #number raidTier The raidTier ID as used at BestInSlot:RegisterRaidTier
--@param #string unlocalizedName An unlocalized name of the raid to add, to identify the instance, must be unique!
--@param #string description A localized description of the raid instance to add
--@param #table args Optional arguments to override default values. See data.instances.__default
function BestInSlot:RegisterRaidInstance(raidTier, unlocalizedName, description, args)
  if not data.raidTiers[raidTier] then error("The raid tier "..raidTier.." has not been registered yet!") end
  local localizedExpansion = data.raidTiers[raidTier].expansion
  if not data.expansions[localizedExpansion] then error("The expansion "..localizedExpansion.." has not been registered yet!") end
  if not data.raidTiers[raidTier] then error("The raid tier "..raidTier.." has not been registered yet") end
  if data.instances[unlocalizedName] then error("This raid instance has already been registered!") end
  data.instances[unlocalizedName] = setmetatable({expansion = localizedExpansion, raidTier = raidTier, description = description}, instanceDefaultIndexMetatable)
  if args then
    for k,v in pairs(args) do
      data.instances[unlocalizedName][k] = v
    end
  end
  tinsert(data.expansions[localizedExpansion].instances, unlocalizedName)
  tinsert(data.raidTiers[raidTier].instances, unlocalizedName)
  itemData[unlocalizedName] = setmetatable({}, newInstanceMetatable)
  if self.db.global.customitems[unlocalizedName] then
    for itemlink in pairs(self.db.global.customitems[unlocalizedName]) do
      self:RegisterCustomItem(unlocalizedName, nil, itemlink) --The second parameter will be extracted out of the itemlink if not supplied
    end
  end
end

---Register tier items that drop in the supplied raidTier
--@param #number raidTier The raid tier that drops the tier items
--@param #table tierItems A table in the following format: {DEATHKNIGHT = { NORMAL = { normalItem1, normalItem2, ...}, HEROIC = { heroicItem1, heroicItem2},} SHAMAN = {....}} Where the difficulties must correspond with the earlier registered difficulties
function BestInSlot:RegisterTierItems(dungeon, tierItems)
  if not data.instances[dungeon] then error("This dungeon is not registered yet") end
  local tieritems = {}
  for class in pairs(RAID_CLASS_COLORS) do
    if not tierItems[class] then error("You are missing class "..class.." in the tier item list.") end 
    for i=1,#tierItems[class] do
      local itemid = tierItems[class][i]
      local _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(i)
      if not link then self.unsafeIDs[itemid] = true end
      tieritems[itemid] = {
        bossid = equipSlot and data.tiertokens[dungeon][self:GetItemSlotID(equipSlot)].bossid,
        dungeon = dungeon,
        difficulty = -1,
        link = link,
        equipSlot = equipSlot,
        isBiS = {},
        tieritem = class,
      }
    end
  end
  itemData[dungeon].tieritems = tieritems
end
---Register tier tokens, not supported for MoP or lower
function BestInSlot:RegisterTierTokens(raidTier, tierTokens)
  if not data.raidTiers[raidTier] then error("This raid tier is not registered yet") end
  local raidTierData = data.raidTiers[raidTier]
  local difficulties = raidTierData.difficulties
  for slotId, tierSlots in pairs(tierTokens) do
    for tokenId, tokenClasses in pairs(tierSlots) do
      tierTokenData[tokenId] = {classes = tokenClasses, raidtier = raidTier, slotid = slotId}
    end
  end
end
---Adds the named difficulty to the available difficulty
--@param #number raidtier The Raidtier to append the difficulty to
--@param #string difficulty The name of the difficulty
function BestInSlot:AddDifficultyToRaidTier(raidtier, difficulty)
  if not data.raidTiers[raidtier] then error("Raidtier '"..tostring(raidtier).."' does not exist!") end
  tinsert(data.raidTiers[raidtier].difficulties, difficulty)
end


--- Register Miscelaneous items
-- @param #number raidTier The Raid tier to add the misc items to
-- @param #table miscItems A table containing the miscelaneous items, should be formatted in the following format: {["Legendary Cloak Quest"] = {idCloak1, idCloak2, ...}, ["Ordos"] = {idOrdos1, idOrdos2, ...}}
-- @param #bool legionLegendary
function BestInSlot:RegisterMiscItems(instance, miscItems, legionLegendary)
  if not data.instances[instance] then error("This instance is not registered yet") end
  local misc = {}
  for miscName,miscLootTable in pairs(miscItems) do
    if type(miscName) ~= "string" or type(miscLootTable) ~= "table" then error("Misc table is not formatted properly, should be {key = {itemId1, itemId2}} Where key is a description of the source}") end
    for i=1,#miscLootTable do
      local itemid = miscLootTable[i]
      local itemtable
      if type(itemid) == "table" then
        itemtable = itemid
        itemid = itemtable.id
        if not itemid then self.console:AddError("ItemTable didn't provide id", itemid) end
      end
      local link, equipSlot
      if legionLegendary == true then --fix for Legion Legendaries itemlevel
        _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(("item:%d::::::::::::1:3630"):format(itemid))
      else
        _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(("item:%d::::::::::::1:3524"):format(itemid))
      end
      if not link then self.unsafeIDs[itemid] = true end
      misc[itemid] = {
        dungeon = instance,
        difficulty = miscLootTable.difficulty,
        link = link,
        equipSlot = equipSlot,
        isBiS = {},
        misc = miscName,
      }
    end
  end
  itemData[instance].misc = misc
end

local  bossNewIndexMetatable = {
  __newindex = function(tbl, key, value)
    if type(value) ~= "table" then BestInSlot.console:AddError("Item info must be a table!", key, value) end
    key = tonumber(key)
    if not key then BestInSlot.console:AddError("Item info must be a table!", key, value) end
    rawset(tbl, key, value)
  end
}

--- Register boss loot of an instance. Must call this function in the order you want to put the bosses in
-- @param #string unlocalizedInstanceName The unlocalized name of the instance to add the loot to.
-- @param #table lootTable The table containing the loot for the boss, must be formatted as follows: {["Normal"] = {itemId1, itemId2}, ["Heroic"] = {itemId1, itemId2}}
-- @param #string bossName Localized name of the boss, you can use LibBabbleBoss-3.0 for this.
-- @param #number tierToken If supplied, registers this item as a boss that drops the supplied tiertoken. 1 = HeadSlot, 3 = ShoulderSlot, 5 = ChestSlot, 7 = LegsSlot, 10 = Handslot, 15 = BackSlot.
function BestInSlot:RegisterBossLoot(unlocalizedInstanceName, lootTable, bossName, tierToken, bossId) 
  local instance = data.instances[unlocalizedInstanceName]                                                                                                 
  if not instance then error("The instance \""..unlocalizedInstanceName.."\" has not yet been registered!") end
  lootTable.info = {name = bossName}
  local bossLootTable = bossId and itemData[unlocalizedInstanceName][bossId] or setmetatable({}, bossNewIndexMetatable)
  local addToBoss = bossId ~= nil
  local bossId = bossId or #itemData[unlocalizedInstanceName] + 1
  for i=1,#lootTable do
    local itemid = lootTable[i]
    local itemtable
    if type(itemid) == "table" then
      itemtable = itemid
      itemid = itemtable.id
      if not itemid then self.console:AddError("ItemTable didn't provide id", itemid) end
    end
    local item = itemData[itemid]
    if item and not item.customitem then --The item already existed
      if not item.multiplesources then 
        item.multiplesources = {}
        if item.bossid and item.dungeon then
          item.multiplesources[item.dungeon] = {}
          item.multiplesources[item.dungeon][item.bossid] = true
        else
          self:Print(item)
          self:Print(self.unsafeIDs)
        end
      end
      item.multiplesources[unlocalizedInstanceName] = item.multiplesources[unlocalizedInstanceName] or {}
      item.multiplesources[unlocalizedInstanceName][bossId] = true
      bossLootTable[itemid] = item
    else
      if item and item.customitem then
        self:Print("You have added a custom item that is being registered as a module. This is being removed from your custom items.", true)
        self:Print("Removing: "..item.link, true)
        self:UnregisterCustomItem(itemid)
      end
      local _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(itemid)
      if not link then self.unsafeIDs[itemid] = true end
      bossLootTable[itemid] = {
        dungeon = unlocalizedInstanceName,
        bossid = bossId,
        difficulty = itemtable and itemtable.difficulty or -1,
        link = link,
        equipSlot = equipSlot,
        exceptions = itemtable and itemtable.exceptions,
      }
    end
  end
  data.bosses[unlocalizedInstanceName] = data.bosses[unlocalizedInstanceName] or {}
  if not addToBoss then 
    tinsert(itemData[unlocalizedInstanceName], bossLootTable) --add loot to itemData
    tinsert(data.bosses[unlocalizedInstanceName], bossName) --add Boss info to data
  end
  if tierToken then
    data.tiertokens[unlocalizedInstanceName] = data.tiertokens[unlocalizedInstanceName] or {}
    data.tiertokens[unlocalizedInstanceName][tierToken] = {dungeon = unlocalizedInstanceName, bossid = #data.bosses[unlocalizedInstanceName]}
  end
  BestInSlot.hasModules = true
end

--Simple helper to check if an array has any key
local function hasItems(array)
  for _ in pairs(array) do
    return true
  end
  return false
end

--- Called on initializing the add-on
function BestInSlot:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("BestInSlotDB", defaults)
  SLASH_BESTINSLOT1, SLASH_BESTINSLOT2 = '/bestinslot', '/bis'
  self:RegisterComm(self.MSGPREFIX)
  self.options.instantAnimation = self.db.global.options.instantAnimation
  self.options.showBiSTooltip = self.db.char.options.showBiSTooltip
  self.options.windowFixed = self.db.char.options.windowFixed
  self.options.sendAutomaticUpdates = self.db.char.options.sendAutomaticUpdates
  self.options.receiveAutomaticUpdates = self.db.char.options.receiveAutomaticUpdates
  
  AceEvent:RegisterEvent("GET_ITEM_INFO_RECEIVED", function(event, itemid) BestInSlot:SendEvent("GET_ITEM_INFO_RECEIVED", itemid) end)
  self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnItemInfoGenerated")
  
  self:Print((L["has been initialized, use %s to show the GUI"]):format((L["%s or %s"]):format(self.colorHighlight.."/bis"..self.colorNormal, self.colorHighlight.."/bestinslot"..self.colorNormal)))
end

--- Called on enabling the add-on
function BestInSlot:OnEnable()
  self:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
  if AtlasLootTooltip then
    self:HookScript(AtlasLootTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
  end
  self:HookScript(ItemRefTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
  AceEvent:RegisterEvent("PLAYER_GUILD_UPDATE", function()
    BestInSlot:SendEvent("PLAYER_GUILD_UPDATE")
  end)
  self:MiniMapButtonVisible(self.db.char.options.minimapButton)
  self:SetBestInSlotInfo()
  local coreModules = {
    "ZoneDetect",
    "History",
    "History",
    "Timer"
  }
  for i=1, #coreModules do
    self:EnableModule(coreModules[i])
  end
  
  --Enable BiS Core modules
  local loadOrder = {}
  local waitList = {}
  local ZoneDetect = self:GetModule("ZoneDetect")
  for k,v in pairs(BestInSlot.modules) do
    if not v.enabledState then 
      if v.dependancy then
        waitList[v.dependancy] = waitList[v.dependancy] or {}
        tinsert(waitList[v.dependancy], v)
      else
        tinsert(loadOrder, v)
      end
    end
  end
  while #loadOrder ~= 0 do
    local module = tremove(loadOrder)
    local moduleName = module.moduleName
    module:Enable()
    module:InitializeZoneDetect(ZoneDetect)
    if waitList[moduleName] then
      local addToList = waitList[moduleName]
      for i=1,#addToList do
        tinsert(loadOrder, addToList[i])
      end
    end
  end
end

function BestInSlot:OnDisable()
  self:Unhook(GameTooltip, "OnTooltipSetItem")
  self:Unhook(ItemRefTooltip, "OnTooltipSetItem")
end

function BestInSlot:GetDifficultyIdForDungeon(bisId, dungeon, toBiS)
  local returnId, bonusIds = nil
  if not toBiS then
    if dungeon and data.instances[dungeon] then
      returnId, bonusIds = data.instances[dungeon].difficultyconversion[bisId], data.instances[dungeon].bonusids[bisId]
    else
      returnId, bonusIds = data.instances.__default.difficultyconversion[bisId], data.instances.__default.bonusids[bisId]
    end
  else
    local tbl = data.instances[dungeon] or data.instances.__default
    for BiSId, WoWId in pairs(tbl.difficultyconversion) do
      if bisId == WoWId then
        returnId, bonusIds = WoWId, tbl.bonusids[WoWId]
      end
    end
  end
  if not returnId then return end
  if type(bonusIds) == "table" then
    return returnId, unpack(bonusIds)
  else
    return returnId, bonusIds
  end
end

--- Checks wether the player has the supplied item equipped, it should consider normal and warforged items the same
-- @param #number itemid The item ID to check if it's equipped
-- @return #boolean True if item equipped, otherwise false
function BestInSlot:HasItemEquipped(itemid, difficulty)
  local item = self:GetItem(itemid, difficulty)
  if not item then return end
  for i=1,#self.slots do
    local slotID = GetInventorySlotInfo(self.slots[i])
    local link = GetInventoryItemLink("player", slotID)
    if link then
      local id, instanceDifficulty = self:GetItemInfoFromLink(link)
      instanceDifficulty = tonumber(instanceDifficulty)
      if id == itemid then
        if difficulty == nil then
          local bisId = self:GetDifficultyIdForDungeon(instanceDifficulty, item.dungeon, true)
          if bisId then
            return {bisId}
          end
        elseif self:GetDifficultyIdForDungeon(difficulty, item.dungeon) == instanceDifficulty then
          return true
        end
      end
    end
  end
  if difficulty then
    return {}
  end
end

function BestInSlot:GetItemInfoFromLink(itemlink)
  local _,itemid, enchantId, gemId1, gemId2, gemId3, gemId4, suffixId, uniqueId, linkLevel, specId, upgradeId, instanceDifficultyID, numBonusId, bonusId1, bonusId2, bonusId3, upgradeVal = (":"):split(itemlink)
  return tonumber(itemid), tonumber(instanceDifficultyID), bonusId1, bonusId2
end

--- Checks if the player has an item in their bags, or an item similar to it (warforged version for example)
-- @param #number itemid The itemID to check if the player has it in their bags
-- @return #boolean true if the player has the item in their bag, otherwise false
function BestInSlot:HasItemInBag(itemid, difficulty)
  local item = self:GetItem(itemid)
  if not item then return false end
  local bags = NUM_BAG_SLOTS
  local difficulties
  local name = GetItemInfo(itemid)
  for i=0,bags do
    local bagSize = GetContainerNumSlots(i)
    for j=1,bagSize do
      local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(i, j)
      if link then
        local id, instanceDifficulty = self:GetItemInfoFromLink(link)
        instanceDifficulty = tonumber(instanceDifficulty)
        if id == itemid then
          if difficulty == nil then 
            difficulties = difficulties or {}
            local bisId = self:GetDifficultyIdForDungeon(instanceDifficulty, item.dungeon, true)
            if bisId then
              tinsert(difficulties, bisId)
            end
          elseif self:GetDifficultyIdForDungeon(difficulty, item.dungeon) == instanceDifficulty then
            return true
          end
        end
      end
    end
  end
  return difficulties
end

function BestInSlot:OnItemInfoGenerated(event, itemid)
  local item = itemData[itemid]
  if item then
    local _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(item.customitem or itemid)
    if not link then return end
    item.link = link
    item.equipSlot = equipSlot
    if item.tieritem then
      item.bossid = equipSlot and data.tiertokens[item.dungeon][self:GetItemSlotID(equipSlot)].bossid
    end
    if self.unsafeIDs[itemid] then self.unsafeIDs[itemid] = nil end
  end
end

--- Checks if the player has an item either in their bags, or equipped
-- @param #number itemid The itemID to check if the player has
-- @param #number [difficulty] The DifficultyId that the item must have.
-- @param #bool [checkHigherDifficulties] When true will check higher difficulties and return the difficulty number when found, or nil when not found. 
-- @return #boolean true if the player has it, otherwise false
function BestInSlot:HasItem(itemid, difficulty, checkHigherDifficulties)
  if not difficulty or not checkHigherDifficulties then
    return self:HasItemEquipped(itemid, difficulty) or self:HasItemInBag(itemid, difficulty)
  else
    local equippedResult = self:HasItemEquipped(itemid)
    local result = self:HasItemInBag(itemid) or {}
    if equippedResult then
      if not tContains(result, equippedResult[1]) then
        tinsert(result, equippedResult[1])
      end
    end
    if #result > 0 then
      tsort(result)
      if result[#result] >= difficulty then
        return result[#result]
      end
    end
  end
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------------------------------------------------------------------------------------------

--- A BestInSlot function to register a custom slash command. This will automatically be displayed at /help and should be able to be called through /bis [cmd]
-- @param #string cmd The command to register
-- @param #string descr The description to be displayed when '/bis help' is being typed
-- @param #function func The function to be called when this slash command is invoked
-- @param #number prefOrder The preferred location of this message in the '/bis help' dialog. Can be nil
function BestInSlot:RegisterSlashCmd(cmd, descr, func, prefOrder)
  if type(cmd) ~= "string" then error("Command should be a string") end
  if type(func) ~= "function" then error("Second argument of RegisterSlashCmd should be the function that should be called when the command is given") end
  if type(descr) ~= "string"  then error("Slashcommand should provide a description as third parameter") end
  if prefOrder and type(prefOrder) ~= "number" then error("If provided, prefOrder should be a number") end
  cmd = (cmd):lower()
  if slashCommands[cmd] then error("Slash command "..cmd.." is already registered!") end
  slashCommands[cmd] = {func = func, descr = descr, prefOrder = prefOrder}
end
                  
function SlashCmdList.BESTINSLOT(msg, editbox)
  local args = {}
  local first = true
  local command
  for w in (msg):gmatch("%w+") do
    if first then
      command = w
      first = false
    else
      tinsert(args, w)
    end
  end
  if not command then
    slashCommands.show.func()
  else
    command = (command):lower()
    if not slashCommands[command] then
      BestInSlot:Print((L["Command not recognized, try '%s' for help"]):format("/bis help"), true)
    else
      slashCommands[command].func(unpack(args))
    end
  end
end

BestInSlot:RegisterSlashCmd("help", (L["%s - this dialog"]):format("/bis help"), function()
  local orderedList = {}
  for k in pairs(slashCommands) do
    tinsert(orderedList, k)
  end
  tsort(orderedList)
  for i=1,#orderedList do
    if slashCommands[orderedList[i]].prefOrder then
      tinsert(orderedList, slashCommands[orderedList[i]].prefOrder, orderedList[i])
      tremove(orderedList, i + 1)
    end
  end
  DEFAULT_CHAT_FRAME:AddMessage(BestInSlot.colorHighlight..("-"):rep(5)..BestInSlot.colorNormal.."BestInSlotRedux "..L["commands"]..BestInSlot.colorHighlight..("-"):rep(5).."|r")
  BestInSlot:Print(("%s: %s (%s)"):format(GAME_VERSION_LABEL, GetAddOnMetadata("BestInSlotRedux", "Version"), BestInSlot.version))
  for i=1,#orderedList do
    BestInSlot:Print(slashCommands[orderedList[i]].descr, true)
  end
  DEFAULT_CHAT_FRAME:AddMessage(BestInSlot.colorHighlight..("-"):rep(36).."|r")
end)

BestInSlot:RegisterSlashCmd("debug", (L["%s - enable/disable debug messages"]):format("/bis debug"), function()
  if BestInSlot.options.DEBUG then
    BestInSlot:Print(L["Disabling debug messages"])
    BestInSlot.options.DEBUG = false
  else
    BestInSlot.options.DEBUG = true
    BestInSlot:Print(L["Enabling debug messages"])
  end
  BestInSlot:SendEvent("DebugOptionsChanged", BestInSlot.options.DEBUG) 
end)

local itemslotidCache = {}

function BestInSlot:GetItemSlotID(equipSlot, spec)
  if not equipSlot then return end
  if spec == 72 and equipSlot == "INVTYPE_2HWEAPON" then return 16,17 end --fury warrior 2-handers
  if itemslotidCache[equipSlot] then
    if #itemslotidCache[equipSlot] == 1 then return itemslotidCache[equipSlot][1] else return itemslotidCache[equipSlot][1], itemslotidCache[equipSlot][2] end
  end
  local result = {}
  for i=1,#self.invSlots do
    if type(self.invSlots[i]) == "string" then
      if self.invSlots[i] == equipSlot then
        tinsert(result, i)
      end
    elseif type(self.invSlots[i]) == "table" then
      for j=1,#self.invSlots[i] do
        if self.invSlots[i][j] == equipSlot then
          tinsert(result, i)
        end
      end
    end
  end
  itemslotidCache[equipSlot] = result
  return unpack(result)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- Getters for data
------------------------------------------------------------------------------------------------------------------------------------------------

---
-- This function returns an array of items by id to define in what order it should show the items provided in the itemArray
-- @param #array itemArray The array of items to sort
-- @param #string mode The mode to sort at, currently only supports "SORT_MODE_ILVL" and defaults to that
---
function BestInSlot:GetLootOrder(itemArray, mode)
  local sortArray = {}
  local mode = mode or "SORT_MODE_ILVL"
  if mode == "SORT_MODE_ILVL" then
    for k,v in pairs(itemArray) do
      if #sortArray == 0 then
        tinsert(sortArray, k)
      else
        local position
        for i=1,#sortArray do
          if sortArray[i] > k then
            position = i
            break
          end
        end
        position = position or #sortArray + 1
        tinsert(sortArray, position, k)
      end
    end
  end
  return sortArray
end

--- Retrieve the loot table that's personalized for the player.
-- @param #number raidTier The raidtier to retrieve the loot table for
-- @param #number slotID The slotID to retrieve the loot table for
-- @param #number difficulty The difficulty ID to retrieve the loot table for
-- @param #number specializationId The specializationID to retrieve the loot for
-- @param #boolean lowerRaidTiers Show loot for lower raid tiers as well
-- @param #number The specialization to use to compare uniquness for
-- @return #table The loot table for the player
function BestInSlot:GetPersonalizedLootTableBySlot(raidTier, slotId, difficulty, specializationId, lowerRaidTiers, uniquenessSpec)
  local specRole, class = select(6, GetSpecializationInfoByID(specializationId))
  uniquenessSpec = uniquenessSpec or specializationId
  if specializationId == 261 then --Subtlety Rogues
    return self:GetPersonalizedLootTableBySlot(raidTier, slotId, difficulty, 260, lowerRaidTiers, 261) --Return table for combat rogues. Non-Daggers can be used by sub aswell
  end
  if specializationId == 72 and slotId == 17 then --Fury warriors can wield everything in their offhand
    return self:GetPersonalizedLootTableBySlot(raidTier, 16, difficulty, specializationId, lowerRaidTiers) --return main hand loot list instead
  end

  local items = self:GetLootTableBySlot(raidTier, slotId, difficulty, lowerRaidTiers)
  if not items then
    return
  end
  for id, item in pairs(items) do
    local canUse
    local statFilter = GetItemSpecInfo(item.itemid)
    if item.exceptions then
      local checks = {specRole, class}
      for i, check in pairs({"role", "class"}) do
        local checkitem = item.exceptions[check]
        if checkitem and type(checkitem) == "table" and tContains(checkitem, checks[i]) or checkitem == checks[i] then
          exceptions[item.itemid] = true
          break
        end
      end
    end
    if statFilter then
      if #statFilter == 0 then --There is no itemspecinfo available for this item, normally the table should be nil
        if raidTier > 70000 and (slotId == 2 or slotId == 11 or slotId == 12) and item.misc ~= LOOT_JOURNAL_LEGENDARIES then
          canUse = true
        else
          canUse = item.customitem ~= nil
        end
      else
        canUse = tContains(statFilter, specializationId)
      end
    else
      canUse = false
    end
    if canUse and tContains(data.raidTiers[raidTier].instances, item.dungeon) then --check item uniqueness
      local family, count = GetItemUniqueness(item.itemid)
      if count == 1 and self:IsItemBestInSlot(item.itemid, difficulty, uniquenessSpec) then
        canUse = false
      end
    end
    if canUse and slotId == 17 and item.equipSlot == "INVTYPE_WEAPON" then
      canUse = false
      for i=1,#self.dualWield do
        if self.dualWield[i] == specializationId then
          canUse = true
          break
        end
      end
    end
    if not canUse then
      items[id] = nil
    end
  end
  local addSpec
  if specializationId == 73 then --Prot warriors
    addSpec = 71 --Arms
  elseif specializationId == 104 then --Guardian Druid
    addSpec = 103 --Feral Druid
  elseif specializationId == 66 then --Prot Pally
    addSpec = 70 --Ret Pally
  elseif specializationId == 250 then --Blood DK
    addSpec = 252 --Unholy DK
  elseif specializationId == 268 then --Brewmaster Monk
    addSpec = 269 --Windwalker Monk
  elseif specializationId == 105 then --Resto Druid
    addSpec = 102 --Balance Druid
  elseif specializationId == 264 then --Resto Shaman
    addSpec = 262 --Elemental Shaman
  elseif specializationId == 257 or specializationId == 256 then --Both Healing Priests
    addSpec = 258 --Shadow Priest
  end
  --ToDo Implement fix for paladin
  if addSpec then
    local dpsItems = self:GetPersonalizedLootTableBySlot(raidTier, slotId, difficulty, addSpec, lowerRaidTiers, specializationId)
    for itemid, item in pairs(dpsItems) do
      if not items[itemid] then
        items[itemid] = item
      end
    end
  end
  return items
end

local function addLootToTableByFilter(tbl, itemlist, slotId, difficulty)
  for id in pairs(itemlist) do
    local item = BestInSlot:GetItem(id, difficulty)
    if (not slotId) or (type(BestInSlot.invSlots[slotId]) == "string" and BestInSlot.invSlots[slotId] == item.equipSlot) or (type(BestInSlot.invSlots[slotId]) == "table" and tContains(BestInSlot.invSlots[slotId],item.equipSlot)) then
      if difficulty == 4 and (item.difficulty == -1) then --do nothing
      elseif (not difficulty) or (not item.difficulty or (item.difficulty == -1 or item.difficulty == difficulty or (type(item.difficulty) == "table") and tContains(item.difficulty, difficulty)) ) then
        tbl[id] = item
      end
    end
  end
end

--- Gets the loottable for the supplied dungeon
-- @param #string dungeon Unlocalized name of the dungeon
-- @param #number slotId Optional slotId to add
function BestInSlot:GetLootTableByDungeon(dungeon, slotId, difficulty)
  local items = {}
  local dungeonData = itemData[dungeon]
  for bossId=1,#dungeonData do
    addLootToTableByFilter(items, dungeonData[bossId], slotId, difficulty)
  end
  if dungeonData.tieritems then
    addLootToTableByFilter(items, dungeonData.tieritems, slotId, difficulty)
  end
  if dungeonData.misc then
    addLootToTableByFilter(items, dungeonData.misc, slotId, difficulty)
  end
  if dungeonData.customitems then
    addLootToTableByFilter(items, dungeonData.customitems, slotId, difficulty)
  end
  return items
end

local function helperFullLootTable(tbl, itemlist, difficulty)
  for id in pairs(itemlist) do
    local item = BestInSlot:GetItem(id, difficulty)
    if difficulty == 4 and (item.difficulty == -1) then 
      --do nothing
    elseif (not difficulty) or (not item.difficulty or (item.difficulty == -1 or item.difficulty == difficulty or (type(item.difficulty) == "table") and tContains(item.difficulty, difficulty)) ) then
      tbl[id] = item
    end
  end
end

function BestInSlot:GetFullLootTableForRaidTier(raidTier, difficulty)
  local items = {}
  for _, dungeon in pairs(self:GetInstances(self.RAIDTIER, raidTier)) do
    local dungeonData = itemData[dungeon]
    for bossId=1,#dungeonData do
      helperFullLootTable(items, dungeonData[bossId], difficulty)
    end
    if dungeonData.tieritems then
      helperFullLootTable(items, dungeonData.tieritems, difficulty)
    end
    if dungeonData.misc then
      helperFullLootTable(items, dungeonData.misc, difficulty)
    end
    if dungeonData.customitems then
      helperFullLootTable(items, dungeonData.customitems, difficulty)
    end
  end
  return items
end

--- Get the loottable for the supplied raidTier, slot, and difficulty
-- @param #number raidTier The raidtier to request the loot table off
-- @param #number slotId The Slot ID to request
-- @param #number difficulty The difficulty ID of the raidTier to request the data off
-- @param #boolean lowerRaidTiers Get data for lower raid tiers as well
-- @return #table The loot table
function BestInSlot:GetLootTableBySlot(raidTier, slotId, difficulty, lowerRaidTiers)  
  local items = {}
  local dungeons = data.raidTiers[raidTier].instances
  for i=1,#dungeons do
    for id, item in pairs(self:GetLootTableByDungeon(dungeons[i], slotId, difficulty)) do
      items[id] = item
    end
  end
  if lowerRaidTiers then
    local module = data.raidTiers[raidTier].module
    local raidTiers = self:GetRaidTiers()
    for i=1,#raidTiers do
      if raidTiers[i] == raidTier then break end --stop the loop at the raidTier that we already have data from
      if module == data.raidTiers[raidTiers[i]].module then
        for id, item in pairs(self:GetLootTableBySlot(raidTiers[i], slotId, difficulty)) do
          items[id] = item
        end
      end
    end
  end
  return items
end

function BestInSlot:ItemExists(itemid)
  if itemData[itemid] ~= nil then
    return true, "item"
  elseif tierTokenData[itemid] ~= nil then
    return true, "tiertoken"
  else
    return false
  end
end


--- Gets an item string for use in the WoWAPI
--@param #number itemid The itemid of the itemstring
function BestInSlot:GetItemString(itemid, difficulty)
  if not itemid then error("You should provide an itemid!") end
  difficulty = difficulty or 1
  local instanceDifficulty, bonusID1, bonusID2, bonusID3 = self:GetDifficultyIdForDungeon(difficulty, itemData[itemid] and itemData[itemid].dungeon)
  numBonusIDs = (bonusID3 ~= 0 and 3) or (bonusID2 ~= 0 and 2) or (bonusID1 ~= 0 and 1) or 0
  --item:itemId:enchantId:gemId1:gemId2:gemId3:gemId4:suffixId:uniqueId:linkLevel:specializationID:upgradeId:instanceDifficultyId:numBonusIds:bonusId1:bonusId2:upgradeValue
  return ("item:%d:::::::::::%d:%d:%d:%d:%d:"):format(itemid, instanceDifficulty, numBonusIDs, bonusID1, bonusID2, bonusID3)
end

--- Gets the internal item table for the specified itemid
--@param #number itemid The ID of the item
--@param #string difficulty The difficulty of the item
--@return #table The internal item table
function BestInSlot:GetItem(itemid, difficulty)
  if type(itemid) == "string" then
    itemid = tonumber(itemid)
  end  
  if itemid then
    if self.unsafeIDs[itemid] then
      self:OnItemInfoGenerated(nil, itemid)
    end
    if self.unsafeIDs[itemid] then self.console:AddError("Couldn't fetch data for itemid: "..itemid) end
    if itemData[itemid] then
      local newItemTable = setmetatable({}, {__index=itemData[itemid]})
      if difficulty and difficulty ~= 4 and newItemTable.difficulty == -1 then --This is an item that has multiple states and not LFR, therefore we need to set it's state
        newItemTable.itemstr = self:GetItemString(itemid, difficulty)
        local link = select(2,GetItemInfo(newItemTable.itemstr))
        newItemTable.link = link
        newItemTable.difficulty = difficulty
      else
        newItemTable.itemstr = "item:"..itemid
      end
      newItemTable.itemid = itemid
      return newItemTable
    end
  end
end

function BestInSlot:GetItemSources(itemid)
  if self:ItemExists(itemid) then
    local item = itemData[itemid]
    local sources = {}
    sources[item.dungeon] = {}
    sources[item.dungeon][item.bossid] = true
    if item.multiplesources then
      for k,v in pairs(item.multiplesources) do
        sources[k] = sources[k] or {}
        for bossId in pairs(v) do
          sources[k][bossId] = true
        end
      end
    end
    return sources
  end
end

function BestInSlot:AddCustomItem(itemid, itemstr, dungeon, updatePrevious)--, warlordsCrafted, stage, suffix)
  if updatePrevious then
    local item = itemData[itemid]
    if item then
      itemData[item.dungeon].customitems[itemid] = nil
      rawset(itemData, itemid, nil)
      self.db.global.customitems[item.dungeon][item.customitem] = nil
    end
  end
  self.db.global.customitems[dungeon] = self.db.global.customitems[dungeon] or {}
  self.db.global.customitems[dungeon][itemstr] = true
  self:RegisterCustomItem(dungeon, itemid, itemstr)
end

local function helperGetCustomItems(dungeon)
  local result = {}
  local count = 0
  if itemData[dungeon] and itemData[dungeon].customitems then 
    for itemid, item in pairs(itemData[dungeon].customitems) do
      tinsert(result, itemid)
      count = count + 1
    end
  end
  return result, count
end

function BestInSlot:GetCustomItems(dungeon)
  if not dungeon then
    local result = {}
    local totalcount = 0
    for _, instance in pairs(self:GetInstances()) do
      local count
      result[instance], count = helperGetCustomItems(instance)
      totalcount = totalcount + count
    end
    return result, totalcount
  end
  return helperGetCustomItems(dungeon)
end

function BestInSlot:RegisterCustomItem(dungeon, itemid, itemlink)
  if not itemData[dungeon] then error("Invalid dungeon given to RegisterCustomItem!") end
  if not itemid then
    itemid = self:GetItemInfoFromLink(itemlink)
    itemid = tonumber(itemid)
    if not itemid then error("Couldn't convert itemlink to itemid!") end
  end
  itemData[dungeon].customitems = itemData[dungeon].customitems or {}
  local _, link, _, _, _, _, _, _, equipSlot = GetItemInfo(itemlink)
  if not link then self.unsafeIDs[itemid] = true end
  itemData[dungeon].customitems[itemid] = {
    dungeon = dungeon,
    isBiS = {
    
    },
    link = link,
    equipSlot = equipSlot,
    customitem = itemlink,
  }
end

function BestInSlot:UnregisterCustomItem(itemid)
  local item = itemData[itemid]
  self:Print(item)
  if not item or not item.customitem then return end
  local dungeon = item.dungeon
  local raidtier = self:GetRaidTiers(self.INSTANCE, dungeon)
  for difficulty, difficTable in pairs(item.isBiS) do
    for specId, bis in pairs(difficTable) do
      if bis then
        self:SetItemBestInSlot(raidtier, difficulty, specId, self:GetItemSlotID(item.equipSlot), nil)
      end
    end
  end
  self.db.global.customitems[dungeon][item.customitem] = nil
  itemData[dungeon].customitems[itemid] = nil
  rawset(itemData, itemid, nil) --rawSet overrides default prevention of removing item info.
end
--- Gets a localized description for the supplied unlocalized identifier
-- @param #number datatype Optional datatype to query can be BestInSlot.EXPANSION, BestInSlot_TYPE_RAIDTIER, BestInSlot.INSTANCE, BestInSlot.BOSS or BestInSlot.DIFFICULTY
-- @param #multiple arg1 The filter for the supplied datatype
-- @param #multiple arg2 The second filter for the supplied datatype, needed for TYPE_BOSS and TYPE_DIFFUCLTY
function BestInSlot:GetDescription(datatype, arg1, arg2)
  if not arg1 or not datatype then error("This function requires atleast 2 arguments, a datatype and an argument for that datatype") end
  if datatype == self.RAIDTIER then
    arg1 = tonumber(arg1)
    if not arg1 or not data.raidTiers[arg1] then return "" end
    return data.raidTiers[arg1].description
  elseif datatype == self.EXPANSION then
    if not data.expansions[arg1] then return "" end
    return data.expansions[arg1].description
  elseif datatype == self.INSTANCE then
    if not data.instances[arg1] then return "" end
    return data.instances[arg1].description
  elseif datatype == self.BOSS then
    arg2 = tonumber(arg2)
    if not arg2 then error("The GetDescription function for datatype TYPE_BOSS requires 2 arguments") end
    if not data.bosses[arg1] then return "" end
    return data.bosses[arg1][arg2]
  elseif datatype == self.DIFFICULTY then
    arg2 = tonumber(arg2)
    if not arg2 then error("The GetDescription function for datatype TYPE_DIFFICULTY requires 2 argumets") end
    if type(arg1) == "number" then --assume it's a raid tier
      return data.raidTiers[arg1].difficulties[arg2]
    elseif type(arg1) == "string" then --assume it's a dungeon
      return data.raidTiers[data.instances[arg1].raidTier].difficulties[arg2]
    else
      error(tostring(arg1).." is not a string or number.")
    end
  end
  error(tostring(datatype).." is an invalid datatype!")
end
--- Gets the expansions
-- @param #number datatype Optional datatype to query, if nil it will give all expansions as result can be BestInSlot.EXPANSION, BestInSlot_TYPE_RAIDTIER, BestInSlot.INSTANCE, BestInSlot.BOSS or BestInSlot.DIFFICULTY
-- @param #multiple arg The filter for the supplied datatype
function BestInSlot:GetExpansions(datatype, arg)
  if not datatype then
    local expansions = {}
    for k,v in pairs(data.expansions) do
      tinsert(expansions, k)
    end
    return expansions
  elseif datatype == self.RAIDTIER then
    if data.raidTiers[arg] then
      return data.raidTiers[arg].expansion
    end
    return ""
  elseif datatype == self.INSTANCE then
    if data.instances[arg] then
      return data.instances[arg].expansion
    end
    return ""
  else
    error("Invalid type given!")
  end
end

--- Gets the raidtiers
-- @param #number datatype Optional datatype to query, if nil it will give everything as result can be BestInSlot.EXPANSION, BestInSlot_TYPE_RAIDTIER, BestInSlot.INSTANCE
-- @param #multiple arg The filter for the supplied datatype
function BestInSlot:GetRaidTiers(datatype, arg)
  local raidTiers = {} 
  -- No Filter
  if not datatype or datatype == self.RAIDTIER then
    for k,v in pairs(data.raidTiers) do
      if not datatype or (v.module == data.raidTiers[arg].module and k < arg) then
        tinsert(raidTiers, k)
      end
    end
    tsort(raidTiers)
    return raidTiers
  elseif not arg then return
  -- Expansion filter
  elseif datatype == self.EXPANSION then
    if not data.expansions[arg] then return raidTiers end
    for i=1,#data.expansions[arg].raidTiers do
      tinsert(raidTiers, data.expansions[arg].raidTiers[i])
    end
    tsort(raidTiers)
    return raidTiers
  -- Instance filter, will return a single raidTier, not as table!
  elseif datatype == self.INSTANCE then
    if data.instances[arg] then
      return data.instances[arg].raidTier
    else return end
  end
end

--- Gets the difficulties
-- @param #number datatype Optional datatype to query, if nil it will give everything as result can be BestInSlot.EXPANSION, BestInSlot_TYPE_RAIDTIER, BestInSlot.INSTANCE
-- @param #multiple The filter for the supplied datatype
function BestInSlot:GetDifficulties(datatype, arg)
  local difficulties = {}
  if datatype == self.RAIDTIER then
    if not data.raidTiers[arg] then return difficulties end
    for i=1,#data.raidTiers[arg].difficulties do
      tinsert(difficulties, data.raidTiers[arg].difficulties[i])
    end
    return difficulties
  elseif datatype == self.INSTANCE then
    if not arg or not data.instances[arg] then return difficulties end
    local raidTier = data.instances[arg].raidTier
    for i=1,#data.raidTiers[raidTier].difficulties do
      tinsert(difficulties, data.raidTiers[raidTier].difficulties[i])
    end
    return difficulties
  end
  error("Invalid datatype given!")
end

--- Gets the instances
-- @param #number datatype Optional datatype to query, if nil it will give everything as result can be BestInSlot.EXPANSION, BestInSlot_TYPE_RAIDTIER, BestInSlot.INSTANCE
-- @param #multiple The filter for the supplied datatype
function BestInSlot:GetInstances(datatype, arg)
  local instances = {}
  if not datatype then
    for k,v in pairs(data.instances) do
      if k ~= "__default" then
        tinsert(instances, k)
      end
    end
    return instances
  elseif datatype == BestInSlot.RAIDTIER then
    if not data.raidTiers[arg] then return instances end
    for i=1, #data.raidTiers[arg].instances do
      tinsert(instances, data.raidTiers[arg].instances[i])
    end
    return instances
  end
  error("Invalid datatype given!")
end

function BestInSlot:GetLatest(datatype, filterdatatype, arg)
  -- Get Latest Expansion
  if datatype == self.EXPANSION then
    local selectedExpansion
    local selectedRaidTier = 0
    for k,v in pairs(data.expansions) do
      for i=1,#v.raidTiers do
        if v.raidTiers[i] > selectedRaidTier then
          selectedRaidTier = v.raidTiers[i]
          selectedExpansion = k
        end
      end
    end
    return selectedExpansion
    
 -- Get Latest Raid Tier
  elseif datatype == self.RAIDTIER then
    local selected = 0
    for k,v in pairs(data.raidTiers) do
      local isFiltered = false
      if filterdatatype then
        if filterdatatype == self.EXPANSION and v.expansion ~= arg then
          isFiltered = true
        end
      end
      if not isFiltered then
        selected = math.max(selected, k)
      end
    end
    return selected
  -- Get Latest Instance (based on latest raid tier, if no args given)
  elseif datatype == self.INSTANCE then
    local raidTier
    if arg then
      if filterdatatype == self.RAIDTIER then
        raidTier = arg
      else
        error("This has not been implemented yet!")
      end
    else
      raidTier = self:GetLatest(self.RAIDTIER)
    end
    return data.raidTiers[raidTier].instances[#data.raidTiers[raidTier].instances]
  elseif datatype == self.DIFFICULTY then
    if arg then
      if filterdatatype == self.INSTANCE then
        local raidTier = self:GetRaidTiers(self.INSTANCE, arg)
        return self:GetLatest(self.DIFFICULTY, self.RAIDTIER, raidTier)
      elseif filterdatatype == self.RAIDTIER then
        local raidTierData = data.raidTiers[arg].difficulties
        return #raidTierData
      end
    end
    error("This has not been implemented yet!")
  end
  error(tostring(datatype).." is an invalid datatype")
end

---Gets the bosses for the instance
--@param #string instance The instance to get the bosses for
--@return #table Table with boss names, the id of the boss is the same as the table index
function BestInSlot:GetInstanceBosses(instance)
  local bosses = {}
  local instanceData = data.bosses[instance]
  if not instanceData then return bosses end
  for i=1,#instanceData do
    bosses[i] = instanceData[i]
  end
  return bosses
end

local function helperGetBestInSlotItems(raidTier, difficulty, specialization, slotId)
  if not raidTier or not difficulty or not specialization then
    BestInSlot.console:AddError("Not enough parameters given for function 'helperGetBestInSlotItems'", raidTier, difficulty, specialization, slotId)
    if slotId then return nil else return {} end
  end
  local slots = BestInSlot.slots
  local requiredItems = {}
  local slotInfo = {}
  if not data.raidTiers[raidTier] then return requiredItems end
  for i=1,#slots do
    local slotid = GetInventorySlotInfo(slots[i])
    local itemid = BestInSlot.db.char[raidTier][difficulty][specialization][slotid]
    if type(itemid) == "number" then
      local item = BestInSlot:GetItem(itemid)
      local itemRecord = {item = itemid, obtained = BestInSlot:HasItem(itemid, difficulty, true) or false, customitem = item and item.customitem}
      requiredItems[i] = itemRecord
      slotInfo[i] = slotid
    end
  end
  if raidTier >= 70000 and raidTier < 80000 and BestInSlot.Artifacts then
    local relics = { BestInSlot.Artifacts:GetBestInSlotRelics(raidTier, difficulty, specialization) }
    for i=1,3 do
      if relics[i] then
        requiredItems[29 + i] = {item = relics[i], obtained = BestInSlot:HasItem(relics[i], difficulty, true) or false}
        slotInfo[29 + i] = 29 + i
      end
    end
  end
  return requiredItems, slotInfo
end

--- Get the current BestInSlot items for the raidTier and difficulty
-- @param #number raidTier The raidTier to get the BestInSlot from
-- @param #number difficulty The Difficulty to request
function BestInSlot:GetBestInSlotItems(raidTier, difficulty, specialization, slotId)
  if not raidTier or not difficulty then 
    BestInSlot.console:AddError("BestInSlot:GetBestInSlot() missed parameter RaidTier or difficulty", raidTier, difficulty, specialization)
    return {} 
  end
  if not specialization then
    local bisItems = {}
    local slotInfo = {}
    for i=1,GetNumSpecializations() do
      local specId = GetSpecializationInfo(i)
      bisItems[specId], slotInfo[specId] = helperGetBestInSlotItems(raidTier,difficulty,specId, slotId)
    end
    bisItems.spec = GetSpecializationInfo(self:GetSpecialization())
    return bisItems, slotInfo
  else
    return helperGetBestInSlotItems(raidTier,difficulty,specialization, slotId)
  end
end

local function helperOrderBiSItems(table, orderTable)
  local newTable = {}
  for i in pairs(orderTable) do
    newTable[orderTable[i]] = table[i] 
  end
  return newTable
end
--- Get the current BestInSlot items for the raidTier and difficulty ordered by SlotId instead of a plain list
-- @param #number raidTier The raidTier to get the BestInSlot from
-- @param #number difficulty The Difficulty to request
-- @param #number specialization The specialization ID to request
function BestInSlot:GetOrderedBestInSlotItems(raidTier, difficulty, specialization)
  local BiSList, OrderedList = self:GetBestInSlotItems(raidTier, difficulty, specialization)
  if specialization then
    return helperOrderBiSItems(BiSList, OrderedList)
  else
    local newTable = {}
    for k,v in pairs(BiSList) do
      if v and OrderedList[k] then
        newTable[k] = helperOrderBiSItems(v, OrderedList[k])
      end
    end
    return newTable
  end
end

---
function BestInSlot:SetBestInSlotInfo()
  local raidTiers = self:GetRaidTiers()
  local specs = self:GetCustomLists(self:GetAllSpecializations())
  local result
  for i=1,#raidTiers do
    local raidTier = raidTiers[i]
    local bisList = self.db.char[raidTier]
    local difficulties = self:GetDifficulties(self.RAIDTIER, raidTier)
    for difficId in pairs(bisList) do
      for specId in pairs(specs) do
        local specBiS = bisList[difficId][specId]
        for j in pairs(specBiS) do
          local item = itemData[specBiS[j]]
          if item then
            item.isBiS = item.isBiS or {}
            item.isBiS[difficId] = item.isBiS[difficId] or {}
            item.isBiS[difficId][specId] = true
          end
        end
      end
    end
  end
end


function BestInSlot:IsItemTierToken(itemId)
  return (tierTokenData[itemId] ~= nil)
end

local function helperIsTokenBestInSlot(BiSList, difficulty, specId, slotid)
  for i, iteminfo in pairs(BiSList) do
    local item = BestInSlot:GetItem(iteminfo.item, difficulty)
    if item.tieritem and BestInSlot:GetItemSlotID(item.equipSlot) == slotid then
      return BestInSlot:IsItemBestInSlot(item.itemid, difficulty, specId)
    end
  end
end

function BestInSlot:IsTokenBestInSlot(tokenItemId, difficulty, specId)
  if not self:IsItemTierToken(tokenItemId) then return false end
  local iteminfo = tierTokenData[tokenItemId]
  local _, class = UnitClass("player")
  if not tContains(iteminfo.classes, class) then return false end
  if not specId then 
    local array = {}
    for specId, BiSList in pairs(self:GetBestInSlotItems(iteminfo.raidtier, difficulty)) do
      if specId ~= "spec" then
        array[specId] = helperIsTokenBestInSlot(BiSList, difficulty, specId, iteminfo.slotid)
      end
    end
    return array;
  else
    return helperIsTokenBestInSlot(self:GetBestInSlotItems(iteminfo.raidtier, difficulty, specId), difficulty, specId, iteminfo.slotid)
  end
end

--- Checks wether the supplied itemid is BestInSlot
-- @param number itemdId The itemid to check
-- @param number difficulty The difficulty for which to query the list
-- @return table Table with the specs for which this item is BiS.
-- @return boolean false if not best in slot
function BestInSlot:IsItemBestInSlot(itemId, difficulty, specId)
  if self:IsItemTierToken(itemId) then
    return self:IsTokenBestInSlot(itemId, difficulty, specId)
  end
  
  local item = BestInSlot:GetItem(itemId)
  if item then
    if not item.isBiS then
      self:SetBestInSlotInfo()
      if not item.isBiS then --assume theere are no BiS items
        itemData[itemId].isBiS = {}
      end
    end
    if difficulty == nil then
      return item.isBiS
    elseif specId == nil then
      return item.isBiS[difficulty]
    else
      if item.isBiS[difficulty] then
        return item.isBiS[difficulty][specId]
      else
        return item.isBiS[difficulty]
      end
    end
  end
end

local automaticUpdateQueue = {}
local automaticUpdateTimers

local function doAutomaticUpdate()
  for i=1,#automaticUpdateQueue do
    BestInSlot:SendAddonMessage("automaticUpdate",automaticUpdateQueue[i], "GUILD")
  end
  wipe(automaticUpdateQueue)
end

local function queueAutomaticUpdate(data)
  local wasPresent = false
  for i=1,#automaticUpdateQueue do
    local item = automaticUpdateQueue[i]
    if item.raidTier == data.raidTier and item.difficulty == data.difficulty and item.spec == data.spec and item.spec == data.spec then
      item.bis = data.bis
      if automaticUpdateTimers ~= nil then
        automaticUpdateTimers:Cancel()
      end
      automaticUpdateTimers = C_Timer.NewTimer(10, doAutomaticUpdate)
      wasPresent = true
      break
    end
  end
  if not wasPresent then
    tinsert(automaticUpdateQueue, data)
    if automaticUpdateTimers == nil or automaticUpdateTimers._remainingIterations == 0 then
      automaticUpdateTimers = C_Timer.NewTimer(10, doAutomaticUpdate)
    end
  end
end

--- Set the item as BestInSlot item
-- @param #number raidTier The raid tier to add the item to
-- @param #number difficultyId The difficulty to add the item to
-- @param #number specialization The specialization ID
-- @param #number slotId The slot to add the item to
-- @param #number itemId The item ID to add
function BestInSlot:SetItemBestInSlot(raidTier, difficultyId, specialization, slotId, itemId)
  local currentId = self.db.char[raidTier][difficultyId][specialization][slotId]
  if type(currentId) == "number" then --Checks if the number was fetched, default return from DB is an empty array
    if itemData[currentId] then --checks if the item is present in the cahce, if so we need to set it's BiS to false
      if itemData[currentId].isBiS and itemData[currentId].isBiS[difficultyId] then
        local lowerRaidTiers = self:GetRaidTiers(self.RAIDTIER, raidTier)
        local isStillBiS = false
        local compareSlots
        if slotId == 11 or slotId == 12 then compareSlots = {11,12}
        elseif slotId == 13 or slotId == 14 then compareSlots = {13,14}
        elseif slotId == 16 or slotId == 17 then compareSlots = {16,17}
        else compareSlots = {slotId} end
        local i = 1
        while i <= #lowerRaidTiers and not isStillBiS do
          for j=1,#compareSlots do
            local id = self.db.char[lowerRaidTiers[i]][difficultyId][specialization][compareSlots[j]]
            if id == currentId then
              isStillBiS = true
              break
            end
          end
          i = i + 1 
        end
        if not isStillBiS then
          itemData[currentId].isBiS[difficultyId][specialization] = nil
        end
      end
    end
  end
  self.db.char[raidTier][difficultyId][specialization][slotId] = itemId
  if IsInGuild() and self.options.sendAutomaticUpdates and type(specialization) ~= "string" then
    queueAutomaticUpdate({raidTier = raidTier, difficulty = difficultyId, bis = self:GetBestInSlotItems(raidTier, difficultyId, specialization), spec = specialization})
  end
  if itemId and itemData[itemId] then
    itemData[itemId].isBiS = itemData[itemId].isBiS or {}
    itemData[itemId].isBiS[difficultyId] = itemData[itemId].isBiS[difficultyId] or {}
    itemData[itemId].isBiS[difficultyId][specialization] = true
  end
end

local function helperSaveBestInSlotList(tierdb, guildname, guildplayer, bislist, raidtier, difficulty, spec, registerHistory)
  if not tierdb[spec] then
    if registerHistory and not BestInSlot.History:HasHistory(guildplayer, raidtier, difficulty, spec) then
      BestInSlot.History:Add(guildplayer, {raidtier = raidtier, difficulty = difficulty, spec = spec} , BestInSlot.History.NEWLIST)
    end
    tierdb[spec] = bislist
  else
    for slot, slotdata in pairs(bislist) do
      local previtem = tierdb[spec][slot]
      if not previtem or previtem.item ~= slotdata.item then
        tierdb[spec][slot] = slotdata
        if registerHistory then
          BestInSlot.History:Add(guildplayer, {raidtier = raidtier, difficulty = difficulty, slot = slot, previtem = previtem and previtem.item, newitem = slotdata.item})
        end
      end
    end
  end
end

function BestInSlot:SaveGuildBestInSlotList(guildname, guildplayer, bislist, raidtier, difficulty, spec, version)
  local chardb = self.db.factionrealm[guildname][guildplayer]
  chardb.activeSpec = bislist.spec
  local tierdb = chardb[raidtier][difficulty]
  local registerHistory = version > 275
  self.console:Add("Save guild bis list", guildname, guildplayer, raidtier, difficulty, spec, version, registerHistory, bislist)
  if not spec then
    for specid, specdata in pairs(bislist) do
      if specid ~= "spec" then
        helperSaveBestInSlotList(tierdb, guildname, guildplayer, specdata, raidtier, difficulty, specid, registerHistory)
      end
    end
  else
    helperSaveBestInSlotList(tierdb, guildname, guildplayer, bislist, raidtier, difficulty, spec, registerHistory)
  end
  self:SendEvent("GuildCacheUpdated")
end

local function tableHasItems(table)
  if type(table) == "table" then
    for _ in pairs(table) do
      return true
    end
  end
  return false
end

local GetCacheDataCache = {}
local GuildBiSCache = {}

local function refreshCache()
  BestInSlot:UnregisterEvent("GuildCacheUpdated", GetCacheDataCache.eventId)
  wipe(GetCacheDataCache)
  wipe(GuildBiSCache)
end
--- Gets the cached BiS lists
-- @return The Bis lists
function BestInSlot:GetCacheData()
  if #GetCacheDataCache > 0 then
    return unpack(GetCacheDataCache)
  end
  local db = self.db.factionrealm
  local result = {}
  local raidTiers = {}
  local guilds = {}
  local difficulties = {}
  for guildName, guildData in pairs(db) do
    if guildName ~= "_history" then
      if tableHasItems(guildData) then
        tinsert(guilds, guildName)
        for playerName, playerData in pairs(guildData) do
          if tableHasItems(playerData) then
            --checks if the player allready exists in the table
            result[playerName] = {guild = guildName}
            
            for raidTier, raidTierData in pairs(playerData) do
              if tableHasItems(raidTierData) then
                --checks if the raidTier allready exists in the table
                local addRaidTier = true
                for i=1,#raidTiers do
                  if raidTiers[i] == raidTier then
                    addRaidTier = false
                    break
                  end
                end
                if addRaidTier then
                  tinsert(raidTiers, raidTier)
                end
                
                for difficulty, bisList in pairs(raidTierData) do
                  if tableHasItems(bisList) then
                    difficulties[raidTier] = difficulties[raidTier] or {}
                    local addDifficulty = true
                    for i=1,#difficulties[raidTier] do
                      if difficulties[raidTier][i] == difficulty then
                        addDifficulty = false
                        break
                      end
                    end
                    if addDifficulty then
                      tinsert(difficulties[raidTier], difficulty)
                      tsort(difficulties[raidTier])
                    end
                    tinsert(result[playerName], {raidTier, difficulty})
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  GetCacheDataCache = {
    result, raidTiers, guilds, difficulties
  }
  GetCacheDataCache.eventId = self:RegisterEvent("GuildCacheUpdated", refreshCache)
  return unpack(GetCacheDataCache)
end

---Gets a list with players who need the specified itemid
-- @return table Table with player as key, and their specs as table as value
function BestInSlot:GetGuildMembersByItemID(itemid, difficulty)
  if GuildBiSCache[itemid] and GuildBiSCache[itemid][difficulty] then 
    return GuildBiSCache[itemid][difficulty] 
  end
  if not IsInGuild() then return {} end
  local guildName = GetGuildInfo("player")
  local playerData, raidData, guildData, difficultyData = self:GetCacheData() 
  if not tContains(guildData, guildName) then return {} end
  local result = {}
  local tokenData = tierTokenData[itemid]
  for player, playerInfo in pairs(playerData) do
    local class = self:GetPlayerClass(player)
    for i=1, #playerInfo do
      local raidInfo = playerInfo[i]
      if raidInfo[2] == difficulty then --Check if the player has set the difficulty that we ask
        local raidBiSList = self.db.factionrealm[guildName][player][raidInfo[1]][raidInfo[2]]
        for specId, specData in pairs(raidBiSList) do
          if type(specData) == "table" then
            for j in pairs(specData) do
              if not tokenData then
                if specData[j].item == itemid then
                  result[player] = result[player] or {}
                  result[player][specId] = specData[j].obtained
                  break
                end
              else
                local itemid2 = specData[j].item
                local item2 = itemData[itemid2]
                if item2 then
                  local raidtier = self:GetRaidTiers(self.INSTANCE, item2.dungeon)
                  local equipslot = BestInSlot:GetItemSlotID(item2.equipSlot)
                  if tokenData.raidtier == raidtier and tContains(tokenData.classes, class) and equipslot == tokenData.slotid then
                    result[player] = result[player] or {}
                    result[player][specId] = specData[j].obtained
                    break
                  end
                end
              end 
            end
          end
        end
      end
    end
  end
  if not GuildBiSCache[itemid] then GuildBiSCache[itemid] = {} end
  GuildBiSCache[itemid][difficulty] = result
  return result
end
--- Function to catch the nil that GetSpecialization() returns
-- @return 1,2,3,4 depending on the character's specialization, defaults to 1 if none selected
function BestInSlot:GetSpecialization()
  return GetSpecialization() or 1
end

--- Function to get all the specializations of the player
-- @return table Table with as index the global ID and value the localized description
function BestInSlot:GetAllSpecializations()
  local result = {}
  for i=1,GetNumSpecializations() do
    local id, name = GetSpecializationInfo(i)
    result[id] = name
  end
  return result
end

local playerClassCache = setmetatable({DEFAULT = {}}, {
  __index = function(table, key)
    if rawget(table, key) then return rawget(table, key) end
    local searchRealm
    local searchName = key
    if (key):find("-") then
      searchName, searchRealm = (key):match("(%D+)-(%D+)")
    end
    if IsInRaid() then
      for i=1,40 do
        local name, realm = UnitName("raid"..i)
        if name and (not realm or realm == searchRealm) and name == searchName then
          local class, localized = UnitClass("raid"..i) --1 = Hunter, 2==HUNTER
          table[key] = {localized, class}
          return {class, localized}
        end
      end
    elseif IsInGroup() then
      for i=1,5 do
        local name, realm = UnitName("party"..i)
        if name and (not realm or realm == searchRealm) and name == searchName then
          local localized, class = UnitClass("party"..i) --1 = Hunter, 2==HUNTER
          table[key] = {class, localized}
          return {class, localized}
        end
      end
    end
    if IsInGuild() then
      local playerRealm = select(2, UnitFullName("player"))
      for i=1,GetNumGuildMembers() do
        local nameWithRealm, _, _, _, localizedClass, _, _, _, _, _, class = GetGuildRosterInfo(i) --Warrior, WARRIOR 
        local playerName, realm = (nameWithRealm):match("(%D+)-(%D+)")
        if playerName == searchName and ((not searchRealm and realm == playerRealm) or realm == searchRealm) then
          table[key] = {class, localizedClass}
          return {class, localizedClass}
        end
      end
    end
    return rawget(table, "DEFAULT")
  end
})

--- Lookup what class a player in the guild is
-- @param #string name The name of the player to lookup
-- @return #string The class of the player if found
-- @return #nil Nil if the player was not found
function BestInSlot:GetPlayerClass(name)
  if not name then return end
  return playerClassCache[name][1], playerClassCache[name][2]
end

function BestInSlot:GetPlayerString(name)
  local playerClass = self:GetPlayerClass(name)
  if not playerClass then
    return ("|cffb5b4ff%s|r"):format(name or "Unknown name")
  else
    return ("%s%s|r"):format(self:GetClassColor(playerClass) or "|cffb5b4ff", name or "Unknown name")
  end
end

function BestInSlot:GetClassColor(class)
  if RAID_CLASS_COLORS[class] then
    return "|c"..RAID_CLASS_COLORS[class].colorStr
  end
end

function BestInSlot:GetClassString(class)
  return (self:GetClassColor(class) or "|cffb5ffb4")..(LOCALIZED_CLASS_NAMES_MALE[class] or "Unknown class").."|r"
end

local guildRankCache = {}
function BestInSlot:GetGuildRank(player)
  if not guildRankCache[player] then
    local searchName, searchRealm = player, nil
    local playerRealm = select(2, UnitFullName("player"))
    if((player):find("-")) then
      searchName, searchRealm = (player):match("(%D+)-(%D+)")
    end
    for i=1,GetNumGuildMembers() do
      local nameWithRealm, rankDescr, guildRank = GetGuildRosterInfo(i)
      local playerName, realmName = (nameWithRealm):match("(%D+)-(%D+)")
      if playerName == searchName and ((not searchRealm and realmName == playerRealm) or (searchRealm and realmName == searchRealm) )then
        guildRankCache[player] = {guildRank + 1, rankDescr}
      end
    end
  end
  if guildRankCache[player] then return unpack(guildRankCache[player]) end
end

function BestInSlot:GetPlayerInfo()
  return {race = select(2, UnitRace("player")), sex = UnitSex("player") - 2, name = UnitName("player"), class  = select(2, UnitClass("player"))}
end
--@do-not-package@
_G.BestInSlot = BestInSlot
_G.data = data
_G.itemData = itemData
_G.itemDataCache = itemDataCache
_G.tierTokenData = tierTokenData
_G.customItems = customItems
--@end-do-not-package@