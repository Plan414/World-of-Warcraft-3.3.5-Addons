-- InspectEquip

InspectEquip = LibStub("AceAddon-3.0"):NewAddon("InspectEquip", "AceConsole-3.0", "AceHook-3.0", "AceTimer-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("InspectEquip")
local IE = InspectEquip
local IS = InspectEquip_ItemSources --> ItemSources.lua
local WIN = InspectEquip_InfoWindow --> InfoWindow.xml
local TITLE = InspectEquip_InfoWindowTitle
local AVGIL = InspectEquip_InfoWindowAvgItemLevel
local exMod = nil

local slots = { "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
                "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot",
                "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
                "SecondaryHandSlot", "RangedSlot" } -- TabardSlot, ShirtSlot
local noEnchantWarningSlots = {
  ["NeckSlot"] = true, ["WaistSlot"] = true, ["Finger0Slot"] = true, ["Finger1Slot"] = true,
  ["Trinket0Slot"] = true, ["Trinket1Slot"] = true, ["SecondaryHandSlot"] = true, ["RangedSlot"] = true,
}
      
local lines = {}
local numlines = 0
local curline = 0
local curUnit = nil
local curUnitName = nil
local curUser = nil
local cached = false

local headers = {}
local numheaders = 0

local yoffset = -40
local hooked = false
local autoHidden = false

local origInspectUnit

local tonumber = tonumber
local gmatch = string.gmatch
local tinsert = table.insert
local tsort = table.sort
local Examiner = Examiner

local _,_,_,gameToc = GetBuildInfo()
local namesInitialized = false
local tooltipTimer = nil
local embJustice = "Badge of Justice"
local embHeroism = "Emblem of Heroism"
local embValor = "Emblem of Valor"
local embConquest = "Emblem of Conquest"
local embTriumph = "Emblem of Triumph"
local embFrost = "Emblem of Frost"

--------------------------------------------------------------------------------------

InspectEquipConfig = {}
local defaults = {
  tooltips = true,
  showUnknown = true,
  inspectWindow = true,
  charWindow = true,
  checkEnchants = true,
  listItemLevels = true,
  showAvgItemLevel = true,
  ttR = 1.0,
  ttG = 0.75,
  ttB = 0.0,
}

local options = {
  name = "InspectEquip",
  type = "group",
  args = {
    tooltips = {
      order = 1, type = "toggle", width = "full",
      name = L["Add drop information to tooltips"],
      desc = L["Add item drop information to all item tooltips"],
      get = function() return InspectEquipConfig.tooltips end,
      set = function(_,v) InspectEquipConfig.tooltips = v; if v then IE:HookTooltips() end end,
    },
    showunknown = {
      order = 2, type = "toggle", width = "full",
      name = L["Include unknown items in overview"],
      desc = L["Show items that cannot be categorized in a seperate category"],
      get = function() return InspectEquipConfig.showUnknown end,
      set = function(_,v) InspectEquipConfig.showUnknown = v end,
    },
    inspectwindow = {
      order = 3, type = "toggle", width = "full",
      name = L["Attach to inspect window"],
      desc = L["Show the equipment list when inspecting other characters"],
      get = function() return InspectEquipConfig.inspectWindow end,
      set = function(_,v) InspectEquipConfig.inspectWindow = v end,
    },
    charwindow = {
      order = 4, type = "toggle", width = "full",
      name = L["Attach to character window"],
      desc = L["Also show the InspectEquip panel when opening the character window"],
      get = function() return InspectEquipConfig.charWindow end,
      set = function(_,v) InspectEquipConfig.charWindow = v end,
    },
    checkenchants = {
      order = 5, type = "toggle", width = "full",
      name = L["Check for unenchanted items"],
      desc = L["Display a warning for unenchanted items"],
      get = function() return InspectEquipConfig.checkEnchants end,
      set = function(_,v) InspectEquipConfig.checkEnchants = v end,
    },
    listitemlevels = {
      order = 6, type = "toggle", width = "full",
      name = L["Show item level in equipment list"],
      desc = L["Show the item level of each item in the equipment panel"],
      get = function() return InspectEquipConfig.listItemLevels end,
      set = function(_,v) InspectEquipConfig.listItemLevels = v end,
    },
    showavgitemlevel = {
      order = 7, type = "toggle", width = "full",
      name = L["Show average item level in equipment list"],
      desc = L["Show the average item level of all items in the equipment panel"],
      get = function() return InspectEquipConfig.showAvgItemLevel end,
      set = function(_,v) InspectEquipConfig.showAvgItemLevel = v end,
    },
    tooltipcolor = {
      order = 7, type = "color", 
      name = L["Tooltip text color"],
      get = function() return InspectEquipConfig.ttR, InspectEquipConfig.ttG, InspectEquipConfig.ttB, 1.0 end,
      set = function(_,r,g,b,a)
        InspectEquipConfig.ttR = r
        InspectEquipConfig.ttG = g
        InspectEquipConfig.ttB = b
      end,
    }
  },
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("InspectEquip", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("InspectEquip")

--------------------------------------------------------------------------------------

function IE:OnInitialize()
  setmetatable(InspectEquipConfig, {__index = defaults})

  self:SetParent(Examiner or InspectFrame)
  WIN:Hide()
  TITLE:SetText("InspectEquip")

  if Examiner and Examiner.CreateModule then
    exMod = Examiner:CreateModule("InspectEquip")
    exMod.OnCacheLoaded = function(s, entry, unit) 
      if InspectEquipConfig.inspectWindow then
        IE:Inspect("cache", entry)
      end
    end
    exMod.OnClearInspect = function(s) WIN:Hide() end
    exMod.OnInspect = function(s, unit)
      if InspectEquipConfig.inspectWindow then
        IE:SetParent(Examiner); IE:Inspect(unit)
      end
    end
  end

  self:GetItemNames()
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("ADDON_LOADED")
end

function IE:OnEnable()
  origInspectUnit = origInspectUnit or InspectUnit
  InspectUnit = function(...) IE:InspectUnit(...) end
  self:SecureHookScript(PaperDollFrame, "OnShow", "PaperDollFrame_OnShow")
  self:SecureHookScript(PaperDollFrame, "OnHide", "PaperDollFrame_OnHide")
  self:SecureHookScript(GearManagerDialog, "OnShow", "GearManagerDialog_OnShow")
  self:SecureHookScript(GearManagerDialog, "OnHide", "GearManagerDialog_OnHide")
  if OutfitterFrame then
    self:SecureHookScript(OutfitterFrame, "OnShow", "GearManagerDialog_OnShow")
    self:SecureHookScript(OutfitterFrame, "OnHide", "GearManagerDialog_OnHide")
  end
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function IE:OnDisable()
  InspectUnit = origInspectUnit
  if hooked then
    hooked = false
    self:Unhook("InspectFrame_UnitChanged")
  end
  self:UnhookAll()
  self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
  self:CancelAllTimers()
  WIN:Hide()
end

local entered = false

function IE:PLAYER_ENTERING_WORLD()
  entered = true
  self:ScheduleTooltipHook()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function IE:ADDON_LOADED(e, name)
  if entered then
    self:ScheduleTooltipHook()
  end
end

-- Ugly hack, but some addons override the OnTooltipSetItem handler on
-- ItemRefTooltip, breaking IE. Using this timer, IE hopefully hooks after them.
function IE:ScheduleTooltipHook()
  if InspectEquipConfig.tooltips then
    if tooltipTimer then
      self:CancelTimer(tooltipTimer, true)
    end
    tooltipTimer = self:ScheduleTimer('HookTooltips', 3)
  end
end

function IE:SetParent(frame)
  WIN:SetParent(frame)
  WIN:ClearAllPoints()
  WIN:SetPoint("TOPLEFT", frame, "TOPRIGHT", -25, -13)
end

function IE:NewLine()
  local row = CreateFrame("Frame", nil, WIN)
  row:SetHeight(12)
  row:SetWidth(200)
  row:SetPoint("TOPLEFT", WIN, "TOPLEFT", 15, yoffset)

  local txt = row:CreateFontString(nil, "ARTWORK")
  txt:SetJustifyH("LEFT")
  txt:SetFontObject(GameFontHighlightSmall)
  txt:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
  
  row.text = txt
  yoffset = yoffset - 15
  numlines = numlines + 1
  lines[numlines] = row
  
  row:EnableMouse(true)
  row:SetScript("OnEnter", IE.Line_OnEnter)
  row:SetScript("OnLeave", IE.Line_OnLeave)
  row:SetScript("OnMouseDown", IE.Line_OnClick)
end

function IE:ResetDisplay()
  for i = 1, numlines do
    lines[i].text:SetText("")
    lines[i]:Hide()
  end
  curline = 0
end

function IE:AddLine(text, link, item)
  curline = curline + 1
  if curline > numlines then
    self:NewLine()
  end
  local line = lines[curline]
  line.link = link
  line.item = item
  line.text:SetText(text)
  line:SetWidth(line.text:GetStringWidth())
  line:SetFrameLevel(WIN:GetFrameLevel() + 1)
  line:Show()
end

function IE:FullUnitName(name, realm)
  if realm and realm ~= "" then
    return name .. "-" .. realm
  else
    return name
  end
end

function IE:GetExaminerCache(unit)
  local name, realm = UnitName(unit)
  return Examiner_Cache and Examiner_Cache[self:FullUnitName(name, realm)]
end

function IE:InspectUnit(unit, ...)
  origInspectUnit(unit, ...)

  if InspectEquipConfig.inspectWindow then
    self:SetParent(Examiner or InspectFrame)
    WIN:Hide()
    if not hooked and InspectFrame_UnitChanged then
      hooked = true
      self:SecureHook("InspectFrame_UnitChanged")
    end

    self:Inspect(unit)
  end
end

function IE:InspectFrame_UnitChanged()
  if InspectFrame.unit and InspectEquipConfig.inspectWindow then
    self:InspectUnit(InspectFrame.unit)
  else
    WIN:Hide()
  end
end

function IE:PaperDollFrame_OnShow()
  if InspectEquipConfig.charWindow then
    IE:SetParent(CharacterFrame)
    IE:Inspect("player")
  end
end

function IE:PaperDollFrame_OnHide()
  if WIN:GetParent() == CharacterFrame then
    WIN:Hide()
    autoHidden = false
  end
end

function IE:GearManagerDialog_OnShow()
  if WIN:GetParent() == CharacterFrame and WIN:IsShown() then
    WIN:Hide()
    autoHidden = true
  end
end

function IE:GearManagerDialog_OnHide()
  if autoHidden and WIN:GetParent() == CharacterFrame then
    WIN:Show()
    autoHidden = false
  end
end

function IE:UNIT_INVENTORY_CHANGED(event, unit)
  if (unit == "player") and (WIN:IsVisible() or autoHidden) and (WIN:GetParent() == CharacterFrame) then
    IE:Inspect("player")
  end
end

function IE:Inspect(unit, entry)
  local unitName, unitRealm
  cached = (unit == "cache")

  if (cached and (not entry)) or (not self:IsEnabled()) then
    WIN:Hide()
    return
  end

  local cacheItems = cached and entry.Items or nil

  if cached then
    unitName, unitRealm = entry.name, entry.realm
  else
    if (not unit or not UnitExists(unit)) then
      unit = "player"
    end
    unitName, unitRealm = UnitName(unit)

    if not CanInspect(unit) then
      entry = self:GetExaminerCache(unit)
      if entry then
        cached = true
        cacheItems = entry.Items
      end
    else
      --ClearInspectPlayer()
      --NotifyInspect(unit)
    end
  end
  if unitRealm == "" then unitRealm = nil end
  curUnit = unit
  curUnitName = unitName
  curUser = self:FullUnitName(unitName, unitRealm)
  TITLE:SetText("InspectEquip: " .. curUser .. (cached and " (Cache)" or ""))

  self:ResetDisplay()

  local items = {}
  local itemsFound = false
  local getItem
  if cached then
    getItem = function(slot)
      local istr = cacheItems[slot]
      if istr then
        local itemId = tonumber(istr:match("item:(%d+)"))
        return select(2, GetItemInfo(istr)) or ("[" .. itemId .. "]")
      else
        return nil
      end
    end
  else
    getItem = function(slot) return GetInventoryItemLink(unit, GetInventorySlotInfo(slot)) end
  end

  local calciv = InspectEquipConfig.showAvgItemLevel
  local iLevelSum, iCount = 0,0

  for _,slot in pairs(slots) do
    local itemLink = getItem(slot)
    if itemLink then
      local sources = self:FindItem(itemLink, InspectEquipConfig.showUnknown)
      if sources then
        local src, subsrc, lootTable, boss, cost, setname = unpack(sources[1])
        local enchantId = tonumber(itemLink:match("Hitem:%d+:(%d+):"))
        itemsFound = true
        if items[src] == nil then
          items[src] = {count = 0}
        end
        cat = items[src]
        if subsrc then
          -- subcategory
          if lootTable == L["Heroic"] then subsrc = subsrc .. " (" .. lootTable .. ")" end
          if cat[subsrc] == nil then
            cat[subsrc] = {count = 0, hasItems = true}
          end
          cat.count = cat.count + 1
          local subcat = cat[subsrc]
          subcat.count = subcat.count + 1
          subcat[subcat.count] = {link = itemLink, lootTable = lootTable, boss = boss, cost = cost, slot = slot, enchant = enchantId}
        else
          -- no subcategory
          cat.hasItems = true
          cat.count = cat.count + 1
          cat[cat.count] = {link = itemLink, lootTable = lootTable, boss = boss, cost = cost, slot = slot, enchant = enchantId}
        end
      end
      if calciv then
        local _,_,rar,lvl = GetItemInfo(itemLink)
        if lvl then
          iLevelSum = iLevelSum + lvl
          iCount = iCount + 1
        end
      end
    end
  end

  if itemsFound then
    self:AddCats(items, "")
    if calciv and iCount > 0 then
      local avgLvl = iLevelSum / iCount
      AVGIL:SetText(L["Avg. Item Level"] .. ": " .. string.format("%.2f", avgLvl))
      AVGIL:Show()
    else
      AVGIL:Hide()
    end
    self:FixWindowSize()
    if WIN:GetParent() == CharacterFrame and (GearManagerDialog:IsVisible() or (OutfitterFrame and OutfitterFrame:IsVisible())) then
      autoHidden = true
    else
      WIN:Show()
    end
  else
    WIN:Hide()
  end
end

function IE:AddCats(tab, prefix)
  local t = {}
  for cat, items in pairs(tab) do
    if cat ~= "count" then
      tinsert(t, {name = cat, items = items})
    end
  end
  tsort(t, function(a,b) return a.items.count < b.items.count end)

  for i = #t, 1, -1 do
    local cat = t[i]
    self:AddLine(prefix .. cat.name .. " (" .. cat.items.count .. ")")
    if cat.items.hasItems then
      self:AddItems(cat.items, prefix .. "  ")
    else
      self:AddCats(cat.items, prefix .. "  ")
    end
  end
end

function IE:AddItems(tab, padding)
  for i = 1, tab.count do
    local item = tab[i]
    local suffix = ""
    local prefix = padding
    if InspectEquipConfig.listItemLevels then
      local _,_,_,ilvl = GetItemInfo(item.link)
      if ilvl then
        prefix = padding .. "|cffaaaaaa[" .. ilvl .. "]|r "
      end
    end
    if InspectEquipConfig.checkEnchants and (item.enchant == 0) and (not noEnchantWarningSlots[item.slot]) then
      suffix = "|cffff0000*|r"
    end
    self:AddLine(prefix .. item.link .. suffix, item.link, item)
  end
end

local srctypes_d = { -- Instances
  ["n"] = L["Normal"], ["h"] = L["Heroic"], ["q"] = L["Quest Reward"], 
}
local srctypes_r = { -- Raids with 10 man, 25 man, 10 man heroic, 25 man heroic modes
  ["N"] = L["Heroic"], ["H"] = L["Heroic"], ["q"] = L["Quest Reward"], ["Q"] = L["Quest Reward"] 
}
local pvptypes = {
  ["m"] = L["Accessories"], ["l"] = L["Low level PvP"], ["w"] = L["World PvP"], ["s1"] = L["Season 1"],
  ["s2"] = L["Season 2"], ["s3"] = L["Season 3"], ["s4"] = L["Season 4"], ["s5"] = L["Season 5"], 
  ["s6"] = L["Season 6"], ["s7"] = L["Season 7"], ["s8"] = L["Season 8"], ["g"] = L["Lake Wintergrasp"],
}

function IE:FindItem(itemLink, includeUnknown)
  local id = tonumber(itemLink:match("item:(%d+)"))
  if not id then return nil end

  -- Returns a list of (strings localized):
  --  category name ("Raid", "PvP", ...)
  --  subcategory ("Naxxramas", "Season 1", nil, ...)
  --  loot table ("Normal", "Heroic", "Quest Reward", nil, ...)
  --  boss ("Patchwerk", nil, ...)
  --  price (100, nil, ...) <- for badge rewards
  --  set (T7, nil, ...)

  local data = IS.Items[id]
  if data then
    sources = {}
    for entry in gmatch(data, "[^;]+") do
      local next_field = gmatch(entry, "[^_]+")
      local cat = next_field()

      if cat == "r" or cat == "d" then -- Raid/Dungeon: r_ZONE_SRCTYPE_BOSS
        local catname
        if cat == "r" then catname = L["Raid"] else catname = L["Instances"] end
        local zoneId = tonumber(next_field() or 0)
        local zone = IS.Zones[zoneId]
        local lootTable = next_field()
        local srctype
        if cat == "r" then
          srctype = srctypes_r[lootTable]
          if lootTable == "n" or lootTable == "N" or lootTable == "q" then
            zone = zone .. "-10"
          elseif lootTable == "h" or lootTable == "H" or lootTable == "Q" then
            zone = zone .. "-25"
          elseif lootTable == "4" then
            zone = zone .. "-40"
          end
        else
          srctype = srctypes_d[lootTable]
        end
        local boss = IS.Bosses[tonumber(next_field() or 0)]
        local setname = next_field()
        if setname == "+" then
          setname = L["Hard mode"]
        end
        tinsert(sources, {catname, zone, srctype, boss, nil, setname})
      elseif cat == "j" then -- Badge of Justice: j_COST
        tinsert(sources, {L["Emblem rewards"], embJustice, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "h" then -- Emblem of Heroism: h_COST
        tinsert(sources, {L["Emblem rewards"], embHeroism, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "v" then -- Emblem of Valor: v_COST
        tinsert(sources, {L["Emblem rewards"], embValor, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "u" then -- Emblem of Conquest: u_COST
        tinsert(sources, {L["Emblem rewards"], embConquest, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "i" then -- Emblem of Triumph: u_COST
        tinsert(sources, {L["Emblem rewards"], embTriumph, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "o" then -- Emblem of Frost: o_COST
        tinsert(sources, {L["Emblem rewards"], embFrost, nil, nil, tonumber(next_field()), next_field()})
      elseif cat == "t" then -- Argent Tournament: t_COST
        tinsert(sources, {L["Argent Tournament"], nil, nil, nil, tonumber(next_field())})
      elseif cat == "c" then -- Crafted: c_PROFESSION
        local prof = GetSpellInfo(tonumber(next_field() or "0"))
        tinsert(sources, {L["Crafted"], nil, nil, prof})
      elseif cat == "f" then -- Faction rewards: f
        tinsert(sources, {L["Reputation rewards"]})
      elseif cat == "e" then -- World events: e
        tinsert(sources, {L["World events"]})
      elseif cat == "m" then -- Darkmoon Cards: m
        tinsert(sources, {L["Darkmoon Faire"]})
      elseif cat == "g" then -- Vendor (Gold): g
        tinsert(sources, {L["Vendor"]})
      elseif cat == "p" then -- PvP: p_PVPTYPE
        local pvptype = pvptypes[next_field()]
        tinsert(sources, {L["PvP"], pvptype})
      end

    end
    if #sources > 0 then
      return sources
    end
  else
    if includeUnknown then
      local _,_,rarity,lvl = GetItemInfo(id)
      if rarity >= 2 then
        return {{L["Unknown"]}}
      end
    end
  end
  return nil
end

function IE:GetItemNames()
  embJustice = GetItemInfo(29434) or embJustice
  embHeroism = GetItemInfo(40752) or embHeroism
  embValor = GetItemInfo(40753) or embValor
  embConquest = GetItemInfo(45624) or embConquest
  embTriumph = GetItemInfo(47241) or embTriumph
  if gameToc >= 30300 then
    embFrost = GetItemInfo(49426) or embFrost
  end
  namesInitialized = true
end

function IE:FixWindowSize()
  local maxwidth = TITLE:GetStringWidth()
  for i = 1, numlines do
    local width = lines[i].text:GetStringWidth()
    if maxwidth < width then maxwidth = width end
  end
  local height = (curline * 15) + 55
  if InspectEquipConfig.showAvgItemLevel then
    height = height + 15
  end
  WIN:SetWidth(maxwidth + 40)
  WIN:SetHeight(height)
end

function IE.Line_OnEnter(row)
  if row.link then
    GameTooltip:SetOwner(row, "ANCHOR_TOPLEFT")
    if (not cached) and (UnitName(curUnit) == curUnitName) then
      row.link = GetInventoryItemLink(curUnit, GetInventorySlotInfo(row.item.slot)) or row.link
    end
    GameTooltip:SetHyperlink(row.link)
    if row.item and InspectEquipConfig.checkEnchants and (row.item.enchant == 0) and (not noEnchantWarningSlots[row.item.slot]) then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("|cffff0000" .. L["Item is not enchanted"] .. "|r")
    end
    GameTooltip:Show()
  end
end

function IE.Line_OnLeave(row)
  GameTooltip:Hide()
end

function IE.Line_OnClick(row, button)
  if row.link then
    if IsControlKeyDown() then
      DressUpItemLink(row.link)
    elseif IsShiftKeyDown() then
      ChatEdit_InsertLink(row.link)
    end
  end
end

