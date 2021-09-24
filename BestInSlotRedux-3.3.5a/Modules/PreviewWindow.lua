local unpack, select, type, pairs, tinsert, max, floor, abs
=     unpack, select, type, pairs, table.insert, math.max, math.floor, math.abs

local UnitFactionGroup, DressUpTexturePath, CreateFrame, GetItemIcon, GetSpecializationInfoByID, GetClassInfoByID, GetInventorySlotInfo, UnitStat, BreakUpLargeNumbers, UnitName
=     UnitFactionGroup, DressUpTexturePath, CreateFrame, GetItemIcon, GetSpecializationInfoByID, GetClassInfoByID, GetInventorySlotInfo, UnitStat, BreakUpLargeNumbers, UnitName
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local Preview = BestInSlot:NewModule("Preview Window")
local iconsize = 37
Preview.raceids = {
  Human = 1,
  Dwarf = 3,
  Gnome = 7,
  NightElf = 4,
  Draenei = 11,
  Worgen = 22, 
  Orc = 2,
  Undead = 5,
  Tauren = 6,
  Troll = 8,
  BloodElf = 10,
  Goblin = 9,
  Pandaren = 25,
}
Preview.classes = {}
Preview.attributes = PAPERDOLL_STATCATEGORIES[1].stats
local temp = PAPERDOLL_STATCATEGORIES.ENHANCEMENTS.stats
Preview.enhancements = {}
for i=1,#temp do
  Preview.enhancements[i] = temp[i]
end
tinsert(Preview.enhancements, "ATTACK_AP")
tinsert(Preview.enhancements, "SPELLPOWER")
temp = nil
local noBenefit = {text = "STAT_NO_BENEFIT_TOOLTIP"}
Preview.classinfo = {
  __default = {
    basestat = {
      CRITCHANCE = 5,
      SPIRIT = 781,
    },
    stats = {
      STRENGTH = {
        noBenefit,
        {text = "DEFAULT_STAT1_TOOLTIP"}, 
        {text = "STAT_TOOLTIP_BONUS_AP_SP"}
      },
      AGILITY = {
        noBenefit, 
        {text = "DEFAULT_STAT2_TOOLTIP"}
      },
      INTELLECT = {
        noBenefit,
        {text = "DEFAULT_STAT4_TOOLTIP"}
      },
      STAMINA = {
        {text = "DEFAULT_STAT3_TOOLTIP", func = function(str, value) return _G[str]:format(BreakUpLargeNumbers(value * 60)) end}
      },
      CRITCHANCE = {
        {text = "CR_CRIT_TOOLTIP"},
        {text = "CR_CRIT_PARRY_RATING_TOOLTIP"}
      },
      HASTE = {
        {text = "STAT_HASTE_BASE_TOOLTIP", func = function(str, value1, value2) return _G.STAT_HASTE_TOOLTIP.._G[str]:format(BreakUpLargeNumbers(value1), value2) end},
      },
      MASTERY = {
        {text = "", func = function() return L["Mastery tooltips are not supported due to technical limitations"] end},
      },
      SPIRIT = {
        noBenefit,
        {text = "MANA_REGEN_FROM_SPIRIT", func = function(str, value) return _G[str]:format(BreakUpLargeNumbers(floor((961.93469238281 + 0.41220703160998 * value)*5))) end},
      },
      BONUS_ARMOR = {
        noBenefit,
        {text = "STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP"}
      },
      MULTISTRIKE = {
        {text = "CR_MULTISTRIKE_TOOLTIP"},
      },
      LIFESTEAL = {
        {text = "CR_LIFESTEAL_TOOLTIP"},
      },
      VERSATILITY = {
        {text = "CR_VERSATILITY_TOOLTIP"},
      },
      AVOIDANCE = {
        {text = "CR_AVOIDANCE_TOOLTIP"},
      },
      SPELLPOWER = {
        {text = "STAT_SPELLPOWER_TOOLTIP"}
      },
      ATTACK_AP = {
        {text = "ITEM_MOD_MELEE_ATTACK_POWER_SHORT"}
      }
    }
  },
  MAGE = {
    modifiers = {INTELLECT = "*1.05"}, 
    stats = {INTELLECT = 2}
  },
  [62] = { -- Mage: Arcane
    basestat = {MASTERY = 550}, 
    modifiers = {MASTERY = "* 1.05"}
  }, 
  [63] = {-- Mage: Fire
    basestat = {CRITCHANCE = 15}, 
    modifiers = {CRITCHANCE = "* 1.15"}
  }, 
  [64] = {-- Mage: Frost
    basestat = {MULTISTRIKE = 8}, 
    modifiers = {MULTISTRIKE = "* 1.05"}
  }, 
  --PALADIN = {},
  [65] =  { -- Paladin: Holy
    modifiers = {INTELLECT = "* 1.05", CRITCHANCE = "*1.05"}, 
    stats = {INTELLECT = 2, SPIRIT = 2}
  },
  [66] =  { -- Paladin: Protection
    modifiers = {HASTE = "* 1.3", STAMINA = "* 1.15", HASTE = "* 1.3"}, 
    stats = {STRENGTH = 3, BONUS_ARMOR = 2, CRITCHANCE = 2}
  },
  [70] =  { -- Paladin: Retribution
    modifiers = {STRENGTH = "* 1.05", MASTERY = "* 1.05"},
    stats = {STRENGTH = 3}
  },
  WARRIOR = {
    stats = {STRENGTH = 2}
  },
  [71] =  { -- Warrior: Arms
    modifiers = {STRENGTH = "* 1.05", MASTERY = "* 1.05"}
  },
  [72] =  { -- Warrior: Fury
    modifiers = {STRENGTH = "* 1.05", CRITCHANCE = "* 1.05"}
  },
  [73] =  { -- Warrior: Protection
    modifiers = {STAMINA = "* 1.05 * 1.15"}, 
    stats = {BONUS_ARMOR = 2, CRITCHANCE = 2}
  },
  --DRUID = {},
  [102] = { -- Druid: Balance
    modifiers = {INTELLECT = "* 1.05", MASTERY = "* 1.05"}, 
    stats = {INTELLECT = 2}
  },
  [103] = { -- Druid: Feral
    modifiers = {CRITCHANCE = "* 1.05", AGILITY = "* 1.05"}, 
    stats = {AGILITY = 2}
  },
  [104] = {  -- Druid: Guardian
    modifiers = {STAMINA = "* 1.05 * 1.2", MASTERY = "* 1.05", ARMOR = "* 3.5"}, 
    stats = {AGILITY = 2, BONUS_ARMOR = 2}
  },
  [105] = { -- Druid: Restoration
    modifiers = {INTELLECT = "* 1.05", HASTE = "* 1.05"}, 
    stats = {INTELLECT = 2, SPIRIT = 2}
  },
  DEATHKNIGHT = {
    stats = {STRENGTH = 2}
  },
  [250] = { -- Death Knight: Blood
    modifiers = {STAMINA = "* 1.05", TOTALSTAMINA = "* 1.2", ARMOR = "*1.3", MULTISTRIKE = "* 1.05"}, 
    stats = {BONUS_ARMOR = 2},
    basestat = {MULTISTRIKE = 10, HASTE = 10}
  },
  [251] = { -- Death Knight: Frost
    modifiers = {STRENGTH = "* 1.05", HASTE = "* 1.2"},
    basestat = {HASTE = 10}
  },
  [252] = { -- Death Knight: Unholy
    modifiers = {STRENGTH = "* 1.05", MULTISTRIKE = "* 1.05"},
    basestat = {HASTE = 20}
  },
  HUNTER = {
    modifiers = {AGILITY = "*1.05"}, 
    stats = {AGILITY = 2}
  },
  [253] = { -- Hunter: Beast Mastery
    modifiers = {MASTERY = "* 1.05"}
  },
  [254] = { -- Hunter: Marksmanship
    modifiers = {CRITCHANCE = "* 1.05"}
  },
  [255] = { -- Hunter: Survival
    modifiers = {MULTISTRIKE = "* 1.05", MULTISTRIKEEFFECT = "* 1.2"}
  },
  PRIEST = {
    modifiers = {INTELLECT = "* 1.05"}, 
    stats = {INTELLECT = 2}
  },
  [256] = { -- Priest: Discipline
    modifiers = {CRITCHANCE = "* 1.05"}, 
    stats = {SPIRIT = 2}
  },
  [257] = { -- Priest: Holy
    modifiers = {MULTISTRIKE = "* 1.05"}, 
    stats = {SPIRIT = 2}
  },
  [258] = { -- Priest: Shadow
    modifiers = {HASTE = "* 1.05"}
  },
  ROGUE = {
    modifiers = {AGILITY = "*1.05"}, 
    stats = {AGILITY = 2}
  },
  [259] = { -- Rogue: Assassination
    modifiers = {MASTERY = "* 1.05"}
  },
  [260] = { -- Rogue: Combat
    modifiers = {HASTE = "* 1.05"},
  },
  [261] = { -- Rogue: Subtlety
    modifiers = {TOTALAGILITY = "* 1.15", MULTISTRIKE = "* 1.05"},
  },
  --SHAMAN = {},
  [262] = { -- Shaman: Elemental
    basestat = {MULTISTRIKE = 20}, 
    modifiers = {MULTISTRIKE = "* 1.05", MULTISTRIKEEFFECT = "* 1.35"}, 
    stats = {INTELLECT = 2, BONUS_ARMOR = 2}
  },
  [263] = { -- Shaman: Enhancement
    stats = {AGILITY = 2},
    modifiers = {HASTE = "* 1.05", AGILITY = "* 1.05"}
  },
  [264] = { -- Shaman: Restoration
    stats = {INTELLECT = 2, SPIRIT = 2},
    modifiers = {INTELLECT = "* 1.05", MASTERY = "* 1.05"}
  },
  WARLOCK = {
    modifiers = {INTELLECT = "*1.05"}, 
    stats = {INTELLECT = 2}
  },
  [265] = { -- Warlock: Affliction
    modifiers = {HASTE = "* 1.05"}
  },
  [266] = { -- Warlock: Demonology
    modifiers = {MASTERY = "* 1.05"}
  },
  [267] = {modifiers = { -- Warlock: Destruction
    CRITCHANCE = "* 1.15"}
  },
  --MONK = {},
  [268] = { -- Monk: Brewmaster
    modifiers = {ARMOR = "* 1.75", TOTALSTAMINA = "* 1.25", STAMINA = "* 1.05", CRITCHANCE = "* 1.05"}, 
    stats = {AGILITY = 2, BONUS_ARMOR = 2}
  },
  [269] = { -- Monk: Windwalker
    modifiers = {MULTISTRIKE = "* 1.05", AGILITY = "* 1.05"}, 
    stats = {AGILITY = 2}
  },
  [270] = { -- Monk: Mistweaver
    modifiers = {MULTISTRIKE = "* 1.05", INTELLECT = "* 1.05"}, 
    stats = {INTELLECT = 2, SPIRIT = 2}
  },
}

local function requestCharInfo(data, channel, source)
  Preview:SendAddonMessage("charinforeply", Preview:GetPlayerInfo(), "WHISPER", source)
end

local function charInfoReply(data, channel, source)
  
end

local function defaultFormat(str, ...)
  return str:format(...)
end

function Preview:GetTooltipForSpec(attrType, class, spec, ...)
  local tooltips = self.classinfo.__default.stats[attrType]
  if not tooltips then error("Tried to get tooltip for unknown type!") end
  local spectooltips = self.classinfo[spec] and self.classinfo[spec].stats and self.classinfo[spec].stats[attrType]
  local classtooltips = self.classinfo[class] and self.classinfo[class].stats and  self.classinfo[class].stats[attrType]
  local returnString
  if spectooltips  then if type(spectooltips) == "function" then return spectooltips(...) else returnString = tooltips[spectooltips] end
  elseif classtooltips then if type(classtooltips) == "function" then return classtooltips(...) else returnString = tooltips[classtooltips] end
  else returnString = tooltips[1] end
  if type(attrType) == "function" then return attrTywpe(...) end
  if returnString.func then
    return returnString.func(returnString.text, ...)
  else
    return defaultFormat(_G[returnString.text], ...)
  end
end

function Preview:GetBaseStatForSpec(stat, class, spec)
  for _,v in pairs({class, spec}) do
    if self.classinfo[v] and self.classinfo[v].basestat and self.classinfo[v].basestat[stat] then return self.classinfo[v].basestat[stat] end
  end
  return self.classinfo.__default.basestat[stat] or 0
end

function Preview:OnInitialize()
  BestInSlot.Preview = Preview
  self:RegisterCommFunction("requestcharinfo", requestCharInfo)
  self:RegisterCommFunction("charinforeply", charInfoReply)
  self.slots = CopyTable(self.slots)
  tinsert(self.slots, 6, "ShirtSlot")
  tinsert(self.slots, 7, "TabardSlot")
  for i=1,MAX_CLASSES do
    local name = select(2, GetClassInfoByID(i))
    self.classes[name] = i
  end
  local d = date("*t")
  self.aprilfools = d.day == 1 and d.month == 4
end

--[[
function Preview:OnEnable()
  local unitinfo = self:GetPlayerInfo()
  unitinfo.spec = self:GetSelected(self.SPECIALIZATION)
  self:Show(self:GetBestInSlotItems(60001, 2, unitinfo.spec), 2, unitinfo)
end
]]

local function iconOnEnter(widget)
  local link = widget:GetUserData("itemlink")
  local id = widget:GetUserData("id")
  if link then
    GameTooltip:SetOwner(widget.frame)
    GameTooltip:SetAnchorType(id and id <= 8 and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(link, Preview.class, Preview.spec)
    GameTooltip:Show()
  end
end

local function iconOnLeave(widget)
  if GameTooltip:IsShown() then
    GameTooltip:Hide()
  end
end

function Preview:GetClassForSpec(specid)
  local className = select(7, GetSpecializationInfoByID(specid))
  return (self.classes[className] or self.classes[select(3, UnitClass("player"))]), className
end

function Preview:CreateSlotIcon(id)
  local slotid, texture = GetInventorySlotInfo(self.slots[id])
  local icon = self:QuickCreate("Icon", {SetImage=texture, SetImageSize={iconsize, iconsize}, SetWidth=iconsize, SetHeight=iconsize})
  icon:SetUserData("id", id)
  icon:SetCallback("OnEnter", iconOnEnter)
  icon:SetCallback("OnLeave", iconOnLeave)
  self.icons[slotid] = icon
  return icon
end

function Preview:GetScanTooltip()
  if self.scantooltip then return self.scantooltip end
  if BestInSlotPreviewScanTooltip then
    self.scantooltip = BestInSlotPreviewScanTooltip 
    return BestInSlotPreviewScanTooltip
  end
  local tooltip = CreateFrame("GameTooltip", "BestInSlotPreviewScanTooltip", nil, "GameTooltipTemplate")
  self.scantooltip = tooltip
  return tooltip
end

function Preview:SetCharacter(bislist, difficulty, charname, charspec, charsex, charrace, slots)
  local playermodel = self.playermodel
  for i in pairs(bislist) do
    local item = bislist[i]
    if type(bislist[i]) == "number" then
      item = self:GetItem(bislist[i], difficulty)
    elseif type(bislist[i]) == "table" and bislist[i].item then
      item = self:GetItem(bislist[i].item, difficulty)
    end
    if item then
      local slotid, slotid2 = slots and slots[i]
      if not slotid then
        slotid, slotid2 = self:GetItemSlotID(item.equipSlot, charspec)
      end
      if slotid then
        local icon = self.icons[slotid]
        local udt = icon:GetUserDataTable()
        if udt.itemlink and slotid2 then
          icon = self.icons[slotid2]
          udt = icon:GetUserDataTable()
        end
        icon:SetImage(GetItemIcon(item.itemid))
        udt.itemlink = item.link
      end 
      playermodel:TryOn(item.link)
    end
  end
end

function Preview:Show(bislist, difficulty, charparams, slots)
  local charname = charparams and charparams.name or UNKNOWN
  local charrace = charparams and charparams.race or (UnitFactionGroup("player") == "Alliance" and "Human" or "Orc")
  local charsex = charparams and charparams.sex or 0
  local charspec = charparams and charparams.spec or self:GetSelected(self.SPECIALIZATION)
  self.spec = charspec
  self.classid, self.classname = self:GetClassForSpec(charspec)
  if self.previewframe then
    self:SetCharacter(bislist, difficulty, charparams, charname, charspec, charsex, charrace, slots)
    return
  end
  local frame = AceGUI:Create("Window")
  frame.frame:SetFrameStrata("DIALOG")
  frame:SetHeight(400)
  frame:SetWidth(538)
  frame:SetTitle("BestInSlot "..PREVIEW)
  frame:EnableResize(false)
  frame:SetCallback("OnClose", function() Preview:ClosePreview() end)
  self.previewframe = frame
  frame:PauseLayout()
  local previewPanel = AceGUI:Create("SimpleGroup")
  previewPanel:SetWidth(338)
  previewPanel:SetHeight(400)
  previewPanel:PauseLayout()
  previewPanel:SetPoint("TOPLEFT", frame.frame, "TOPLEFT", 10, -25)
  previewPanel:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOMLEFT", 10, 10)
  frame:AddChild(previewPanel)
  self.icons = {}
  for i=1,#self.slots do
    local icon = self:CreateSlotIcon(i)
    if i < 17 then
      local point = i < 9 and "TOPLEFT" or "TOPRIGHT"
      local yOffset = - (i < 9 and i - 1 or i - 9) * (iconsize + 3)
      local xOffset = i < 9 and 0 or -10
      icon:SetPoint(point, previewPanel.frame, point, xOffset, yOffset)
    else
      icon:SetPoint("BOTTOM", previewPanel.frame, "BOTTOM", i == 17 and -iconsize / 2 or iconsize / 2 ,-5)
    end
    previewPanel:AddChild(icon)
  end
  local panel = AceGUI:Create("SimpleGroup")
  panel.frame:SetFrameStrata("BACKGROUND")
  self.oldbackdrop = panel.frame:GetBackdrop()
  self.panel = panel
  panel.frame:SetBackdrop({
    bgFile = DressUpTexturePath(charrace).."1",  
    tile = false,
  })
  panel:SetPoint("TOPLEFT", self.icons[1].frame, "TOPRIGHT")
  panel:SetPoint("BOTTOMRIGHT", self.icons[14].frame, "BOTTOMLEFT")
  previewPanel:AddChild(panel)
  local playermodel = self:CreatePlayerModel(panel.frame, charrace, charsex)
  playermodel:SetPoint("BOTTOM", panel.frame)
  self:SetCharacter(bislist, difficulty, charparams, charname, charspec, charsex, charrace, slots)
  local statFrame = AceGUI:Create("ScrollFrame")
  statFrame:SetPoint("TOPLEFT", self.icons[10].frame, "TOPRIGHT", 5, -5)
  statFrame:SetPoint("BOTTOMRIGHT", frame.frame, -7, 10)
  frame:AddChild(statFrame)
  self:FillStatPanel(statFrame, bislist, difficulty, self.classname, charspec)
end

local function onMouseUp(self, button)
  if ( button == "RightButton" and self.panning ) then
    Model_StopPanning(self);
  elseif ( self.mouseDown ) then
    self.onMouseUpFunc(self, button);
  end
end

local function onMouseDown(self, button)
  if ( button == "RightButton" and not self.mouseDown ) then
    Model_StartPanning(self);
  else
    Model_OnMouseDown(self, button);
  end
end

local function onMouseWheel(self, delta)
  Model_OnMouseWheel(self, delta);
end

local function onReleaseGroup(widg)
  widg.frame:SetScript("OnEnter", nil) --Remove the hooked script
  widg.frame:SetScript("OnLeave", nil)
  widg.frame.ace = nil
  widg.value.label:SetJustifyH("LEFT") --reset justify H
  widg.value = nil
  widg.descr = nil
end

local function onEnterStatGroup(frame)
  GameTooltip:ClearLines()
  GameTooltip:SetOwner(frame)
  GameTooltip:SetAnchorType("ANCHOR_RIGHT")
  GameTooltip:AddLine(frame.ace.tooltip, nil, nil, nil, true)
  GameTooltip:AddLine(frame.ace.tooltip2, nil, nil, nil, true)
  GameTooltip:Show()
  GameTooltip:SetWidth(250)
end

local function onLeaveStatGroup(frame)
  GameTooltip:Hide()
end

local function errorHandler(error)
  Preview.console:AddError("Error caught", error)
end

function Preview:ApplyStatModifier(statName, class, spec, value)
  local modifiers = {self.classinfo[spec] and self.classinfo[spec].modifiers, self.classinfo[class] and self.classinfo[class].modifiers}
  if #modifiers == 0 then return value end
  for _, modifier in pairs(modifiers) do
    if modifier[statName] then
      local f, err = loadstring("return "..value..modifier[statName])
      if err then self.console:AddError("Failed to add modifier.", statName, class, spec, value, err)
      else
        local success, result = xpcall(f, errorHandler)
        if success then value = result
        else self.console:AddError("Failed to add modifier.") end
      end
    end
  end
  return value
end

function Preview:FillStatPanel(panel, bislist, difficulty, class, spec)
  panel:SetLayout("Flow")
  self:QuickCreate("Heading", {SetText=STAT_CATEGORY_ATTRIBUTES, SetFullWidth=true}, panel)
  local bonusStats = self:GetTotalStats(bislist, difficulty, class, spec)
  for i=1,#self.attributes do
    local locName = self.attributes[i]
    local attrId = _G["LE_UNIT_STAT_"..locName]
    local attrName = _G["SPELL_STAT"..attrId.."_NAME"]
    local group = self:QuickCreate("SimpleGroup", {SetWidth=200, PauseLayout=true}, panel)
    local stat, effectiveStat, posBuff, negBuff = UnitStat("player", attrId)
    local baseStat = stat - posBuff + negBuff
    local bonusStat = bonusStats[attrName] or 0
    bonusStat = floor(self:ApplyStatModifier(locName, class, spec, bonusStat))
    local totalStat = floor(self:ApplyStatModifier("TOTAL"..locName, class, spec, baseStat + bonusStat))
    group.frame:SetScript("OnEnter", onEnterStatGroup)
    group.frame:SetScript("OnLeave", onLeaveStatGroup)
    group:SetCallback("OnRelease", onReleaseGroup)
    group.frame.ace = group
    group.descr = self:QuickCreate("Label", {SetWidth=150, SetText=attrName}, group, "TOPLEFT")
    group.value = self:QuickCreate("Label", {SetWidth=50, SetText=BreakUpLargeNumbers(totalStat)}, group, "TOPRIGHT")
    if bonusStat > 0 then
      group.value:SetColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
    end
    group.value.label:SetJustifyH("RIGHT")
    group.tooltip, group.tooltip2 = self:GetTooltipForStat(attrId, attrName, locName, baseStat, bonusStat, totalStat, class, spec)
    group:SetHeight(max(group.value.frame:GetHeight(), group.descr.frame:GetHeight()))
  end
  self:QuickCreate("Heading", {SetText=STAT_CATEGORY_ENHANCEMENTS, SetFullWidth=true}, panel)
  for i=1,#self.enhancements do
    local group = self:QuickCreate("SimpleGroup", {SetWidth=200, PauseLayout=true}, panel)
    local locName = self.enhancements[i]
    local enhanceName = _G["STAT_"..locName]
    if not enhanceName then
      if locName == "CRITCHANCE" then enhanceName = STAT_CRITICAL_STRIKE
      elseif locName == "SPIRIT" then enhanceName = SPELL_STAT5_NAME
      elseif locName == "ATTACK_AP" then enhanceName = ATTACK_POWER_TOOLTIP end
    end
    local baseStat;
    if locName == "BONUS_ARMOR" then baseStat = self:ApplyStatModifier("ARMOR", class, spec, bonusStats.ARMOR or 0)
    else baseStat = self:GetBaseStatForSpec(locName, class, spec) end
    local bonusStat = bonusStats[enhanceName] or 0
    bonusStat = floor(self:ApplyStatModifier(locName, class, spec, bonusStat))
    local totalStat = baseStat + bonusStat
    group.frame:SetScript("OnEnter", onEnterStatGroup)
    group.frame:SetScript("OnLeave", onLeaveStatGroup)
    group:SetCallback("OnRelease", onReleaseGroup)
    group.frame.ace = group
    group.descr = self:QuickCreate("Label", {SetWidth=150, SetText=enhanceName}, group, "TOPLEFT")
    group.value = self:QuickCreate("Label", {SetWidth=50}, group, "TOPRIGHT")
    group.value.label:SetJustifyH("RIGHT")
    group:SetHeight(max(group.value.frame:GetHeight(), group.descr.frame:GetHeight()))
    group.tooltip, group.tooltip2 = self:GetTooltipForEnhancement(enhanceName, locName, baseStat, bonusStat, class, spec, group.value)
  end
  local label = self:QuickCreate("Label", {SetFullWidth=true, SetText=self.colorHighlight.."BETA NOTICE: Stats are in beta and calculation might differ slightly. Please report huge differences."}, panel)
end

function Preview:GetTooltipForEnhancement(name, locName, baseStat, bonusStat, class, spec, valueWidget)
  local header
  local content
  if locName == "SPIRIT" then
    header = self:GetTooltipHeader(name, baseStat, bonusStat)
    content = self:GetTooltipForSpec(locName, class, spec, baseStat + bonusStat)
    valueWidget:SetText(BreakUpLargeNumbers(baseStat + bonusStat))
  elseif locName == "BONUS_ARMOR" then
    header = self:GetTooltipHeader(name, 0, bonusStat) --use 0 here, because baseStat contains the armor value of gear
    content = self:GetTooltipForSpec(locName, class, spec, PaperDollFrame_GetArmorReduction(baseStat + bonusStat, 100), bonusStat)
    valueWidget:SetText(BreakUpLargeNumbers(bonusStat))
  elseif locName == "CRITCHANCE" then
    local effectiveStat = 0.009090908809347 * bonusStat
    header = self:GetTooltipHeader(name, baseStat, effectiveStat, true)
    content = self:GetTooltipForSpec(locName, class, spec, bonusStat, effectiveStat, effectiveStat)
    valueWidget:SetText(("%.2F%%"):format(baseStat + effectiveStat))
  elseif locName == "HASTE" then
    local effectiveStat = bonusStat / 90
    header = self:GetTooltipHeader(name, baseStat, effectiveStat, true)
    content = self:GetTooltipForSpec(locName, class, spec, bonusStat, effectiveStat)
    valueWidget:SetText(("%.2F%%"):format(baseStat + effectiveStat))
  elseif locName == "MASTERY" then
    header = self:GetTooltipHeader(name, baseStat, bonusStat)
    content = self:GetTooltipForSpec(locName, class, spec, baseStat + bonusStat)
    valueWidget:SetText(BreakUpLargeNumbers(baseStat + bonusStat))
  elseif locName == "MULTISTRIKE" then
    local effectiveStat = bonusStat / 66
    local multistrikeEffect = self:ApplyStatModifier("MULTISTRIKEEFFECT", class, spec, 30)
    local totalEffect = effectiveStat + baseStat
    
    header = self:GetTooltipHeader(name, baseStat, effectiveStat, true)
    content = self:GetTooltipForSpec(locName, class, spec, totalEffect, multistrikeEffect, BreakUpLargeNumbers(bonusStat), effectiveStat)
    valueWidget:SetText(("%.2F%%"):format(totalEffect))
  elseif locName == "VERSATILITY" then
    local effectiveStat = bonusStat / 130
    local totalStat = baseStat + effectiveStat
    header = self:GetTooltipHeader(name, baseStat, effectiveStat, true)
    content = self:GetTooltipForSpec(locName, class, spec, totalStat, totalStat / 2, BreakUpLargeNumbers(bonusStat), effectiveStat, effectiveStat / 2)
    valueWidget:SetText(("%.2F%%"):format(totalStat))
  elseif locName == "LIFESTEAL" or locName == "AVOIDANCE" then
    header = self:GetTooltipHeader(name, 0, 0)
    content = self:GetTooltipForSpec(locName, class, spec, 0, 0, 0)
    valueWidget:SetText(("%.2F%%"):format(0))
  elseif locName == "ATTACK_AP" or locName == "SPELLPOWER" then
    header = self:GetTooltipHeader(name, bonusStat, 0)
    content = self:GetTooltipForSpec(locName, class, spec, bonusStat)
    valueWidget:SetText(BreakUpLargeNumbers(bonusStat))
  end
  return header or "NYI", content or "NYI"
end

local function BreakUpLargeNumbersWithPercentage(value)
  return BreakUpLargeNumbers(value) .. "%"
end

function Preview:GetTooltipHeader(name, baseStat, bonusStat, isPercentage, totalStat)
  local tooltip = HIGHLIGHT_FONT_COLOR_CODE..PAPERDOLLFRAME_TOOLTIP_FORMAT:format(name).." "
  totalStat = totalStat or baseStat + bonusStat
  local formatFunc = isPercentage and BreakUpLargeNumbersWithPercentage or BreakUpLargeNumbers
  bonusStat = formatFunc(bonusStat)
  if bonusStat == "0" then
    tooltip = tooltip .. formatFunc(baseStat) .. FONT_COLOR_CODE_CLOSE
  elseif isPercentage then
    tooltip = tooltip .. formatFunc(totalStat) .. FONT_COLOR_CODE_CLOSE
  else
    tooltip = tooltip .. formatFunc(totalStat) .. " ( "  .. (baseStat > 0 and formatFunc(baseStat) or "")  .. FONT_COLOR_CODE_CLOSE .. GREEN_FONT_COLOR_CODE .. "+" .. bonusStat .. FONT_COLOR_CODE_CLOSE .. HIGHLIGHT_FONT_COLOR_CODE .. ")" 
  end
  return tooltip
end

function Preview:GetTooltipForStat(statId, statName, locName, baseStat, bonusStat, totalStat, class, spec)
  return self:GetTooltipHeader(statName, baseStat, bonusStat, false, totalStat), self:GetTooltipForSpec(locName, class, spec, totalStat)
end

local function isColorDisabledColor(r,g,b)
  r = (floor(r * 10))
  g = (floor(g * 10))
  b = (floor(b * 10))
  return abs(r - GRAY_FONT_COLOR.r * 10) <= 5 and abs(g - GRAY_FONT_COLOR.g * 10) <= 5 and abs(b - GRAY_FONT_COLOR.b * 10) <= 1 
end

local searchPattern1 = "+(%d+) (.+)"
local searchPattern2 = "+(%d+),(%d%d%d) (.+)"
local searchArmorPattern = ARMOR_TEMPLATE:format("(%d+)")
local function readLine(line, arr)
  local text = line:GetText()
  if not text then return end
  if text:find(DISABLED_FONT_COLOR_CODE) then return end
  local thousands, amount, statName = text:match(searchPattern2)
  if not thousands then
    amount, statName = text:match(searchPattern1)
    if not amount then
      amount = text:match(searchArmorPattern)
      if not amount then 
        return
      else
        statName = "ARMOR"
      end 
    end
  else
    amount = amount + thousands * 1000
  end
  local r,g,b = line:GetTextColor()
  if isColorDisabledColor(r,g,b) then
    return
  end
  arr[statName] = (arr[statName] or 0) + amount
end

function Preview:GetTotalStats(bislist, difficulty, class, spec)
  local totalStats = {}
  local tooltip = self:GetScanTooltip()
  --[[Normal functionality
  for i in pairs(bislist) do
    local item = self:GetItem(bislist[i].item, difficulty)
    if item then
      tooltip:SetOwner(UIParent, "ANCHOR_NONE")
      tooltip:ClearLines()
      tooltip:SetHyperlink(item.itemstr, class, spec)
      tooltip:Show()
      local line = _G["BestInSlotPreviewScanTooltipTextLeft1"]
      local i = 1
      while line do
        readLine(line, totalStats)
        i = i + 1
        line = _G["BestInSlotPreviewScanTooltipTextLeft"..i]
      end
      tooltip:Hide()
    end
  end --]]
  --DEBUG WITH CURRENT GEAR
  for j=1,19 do
    local link = GetInventoryItemLink("player", j)
    if link then
      tooltip:SetOwner(UIParent, "ANCHOR_NONE")
      tooltip:ClearLines()
      tooltip:SetHyperlink(link, class, spec)
      tooltip:Show()
      local line = _G["BestInSlotPreviewScanTooltipTextLeft1"]
      local i = 1
      while line do
        readLine(line, totalStats)
        i = i + 1
        line = _G["BestInSlotPreviewScanTooltipTextLeft"..i]
      end
      tooltip:Hide()
    end
  end--]]
  return totalStats
end

function Preview:CreatePlayerModel(parent, race, sex)
  local playermodel = self.playermodel 
  if not playermodel then
    playermodel = CreateFrame("DressUpModel", "BestInSlotPlayerModel", UIParent)
    playermodel:SetHeight(self.panel.frame:GetHeight())
    playermodel:SetFrameStrata("FULLSCREEN")
    playermodel:SetWidth(244)
    playermodel:SetScript("OnLoad", Model_OnLoad)
    playermodel:SetScript("OnEvent", Model_OnEvent)
    playermodel:SetScript("OnUpdate", Model_OnUpdate)
    playermodel:SetScript("OnMouseUp", onMouseUp)
    playermodel:SetScript("OnMouseDown", onMouseDown)
    playermodel:SetScript("OnMouseWheel", onMouseWheel)
    Model_OnLoad(playermodel)
    self.playermodel = playermodel
  end
  playermodel:Show()
  playermodel:SetUnit("PLAYER")
  if self.aprilfools then
    playermodel:SetCreature(1211)
  else
    playermodel:SetCustomRace(self.raceids[race], sex)
  end
  playermodel:Undress()
  
  return playermodel
end

function Preview:ClosePreview()
  local frame = self.previewframe
  self.panel.frame:SetBackdrop(self.oldbackdrop)
  frame:Release()
  self.previewframe = nil
  self.panel = nil
  self.oldbackdrop = nil
  self.icons = nil
  self.spec = nil
  self.class = nil
  self.playermodel:Hide()
end