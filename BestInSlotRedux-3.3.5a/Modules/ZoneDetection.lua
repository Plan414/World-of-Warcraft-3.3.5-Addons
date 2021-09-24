--lua
local unpack, select, wipe, pairs, GetInstanceInfo, strsplit, tonumber, type, tContains, tinsert 
=     unpack, select, wipe, pairs, GetInstanceInfo, strsplit, tonumber, type, tContains, tinsert
local SetMapToCurrentZone, GetCurrentMapAreaID, GetSpecializationInfo, UnitAffectingCombat, UnitGUID, GetSpecializationInfoByID
=     SetMapToCurrentZone, GetCurrentMapAreaID, GetSpecializationInfo, UnitAffectingCombat, UnitGUID, GetSpecializationInfoByID
local BestInSlot, L = unpack(select(2, ...))
local ZoneDetect = BestInSlot:NewModule("ZoneDetect", "AceEvent-3.0", "AceHook-3.0")
ZoneDetect.colorDisable = "|cff777777"
local bossTracking = false
local waitingForMovement = false
local mapIds = {}
local npcIds = {}

function ZoneDetect:OnEnable()
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  self:ZONE_CHANGED_NEW_AREA()
end

function ZoneDetect:OnDisable()
  self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

function ZoneDetect:EnableBossTracking()
  if bossTracking then return end
  self:Print("Enabled boss tracking")
  self:HookScript(GameTooltip, "OnTooltipSetUnit", "TooltipSetUnit")
  bossTracking = true
end

function ZoneDetect:DisableBossTracking()
  if not bossTracking then return end
  self:Print("Disabled boss tracking")
  self:Unhook(GameTooltip, "OnTooltipSetUnit")
  bossTracking = false
end

local difficultyTable = {
  [1] = 1,
  [2] = 2,
  [3] = 1,
  [4] = 1,
  [5] = 2,
  [6] = 2,
  [7] = 4,
  [8] = 2,
  [9] = 1,
  [11] = 2,
  [12] = 1,
  [14] = 1,
  [15] = 2,
  [16] = 3,
  [17] = 4,
  [23] = 3, -- Mythic Dungeon
}

function ZoneDetect:GetDifficulty()
  local _,_, difficId = GetInstanceInfo()
  return difficultyTable[difficId]
end

function ZoneDetect:GetItemText(item)
  local diffic = self:GetDifficulty()
  local activeSpec = GetSpecializationInfo(self:GetSpecialization())
  local specs = {}
  if item.isBiS and item.isBiS[diffic] then
    for k,v in pairs(item.isBiS[diffic]) do
      local specName = select(2, GetSpecializationInfoByID(k))
      tinsert(specs, (activeSpec == k and self.colorHighlight or self.colorDisable)..specName..self.colorNormal)
    end
  end
  return item.link .. (#specs == 0 and "" or " ("..strjoin(",", unpack(specs)) ..")")
end

function ZoneDetect:TooltipSetUnit(tooltip)
  if not self.db.char.options.tooltipCombat and UnitAffectingCombat("player") then return end
  local _, unit = tooltip:GetUnit()
  if not unit then return end
  local guid = UnitGUID(unit)
  local npcType,_,_,_,_,npcId = strsplit("-", guid)
  if npcType and (npcType == "Creature" or npcType == "Vehicle") then
    npcId = tonumber(npcId)
    if npcId and self.options.DEBUG then
      tooltip:AddLine(("%sBiS Debug%s: NPCID: "..npcId):format(self.colorHighlight, self.colorNormal))
    end
    if npcId and npcIds[npcId] then
      local instance = npcIds[npcId][1]
      local boss = npcIds[npcId][2]
      local bossName = self:GetDescription(self.BOSS, instance, boss)
      local raidTier = self:GetRaidTiers(self.INSTANCE, instance)
      local difficulty = self:GetDifficulty()
      local BiSList = self:GetBestInSlotItems(raidTier, difficulty)
      local neededItems = {}
      local obtainedItems = {}
      self.console:Add("Needed items", neededItems)
      self.console:Add("Obtained Items", obtainedItems)
      for specId, specdata in pairs(BiSList) do
        if type(specdata) == "table" then
          for i in pairs(specdata) do
            local itemid = specdata[i].item
            local obtained = specdata[i].obtained
            local item = self:GetItem(itemid, difficulty)
            if item then
              if item.multiplesources then
                if item.multiplesources[instance] and item.multiplesources[instance][boss] then
                  if obtained then obtainedItems[itemid] = item else neededItems[itemid] = item end
                end
              elseif item.bossid == boss and item.dungeon == instance then
                if obtained then obtainedItems[itemid] = item else neededItems[itemid] = item end
              end
            end
          end
        end
      end
      if self.options.DEBUG then
        tooltip:AddLine(("%sBiS Debug%s: This is a known boss: "..bossName):format(self.colorHighlight, self.colorNormal))
      end
      local first = true
      for id, item in pairs(neededItems) do
        if first then
          tooltip:AddLine((L["These items from %s are %sBestInSlot%s:"]):format(bossName, self.colorHighlight, self.colorNormal), nil,nil,nil,true)
          first = false
        end
        tooltip:AddLine(("- %s"):format(self:GetItemText(item)))
      end
      first = true
      for id, item in pairs(obtainedItems) do
        if first then
          tooltip:AddLine((L["You already have these %sBestInSlot%s items from %s"]):format(self.colorHighlight, self.colorNormal, bossName), nil,nil,nil,true)
          first = false
        end
        tooltip:AddLine(("- %s"):format(self:GetItemText(item)))
      end
    end
  end 
end

function ZoneDetect:ZONE_CHANGED_NEW_AREA()
  if not waitingForMovement then
    self:RegisterEvent("PLAYER_STARTED_MOVING")
    waitingForMovement = true
  end
end

function ZoneDetect:PLAYER_STARTED_MOVING()
  if not WorldMapFrame:IsVisible() then
    --SetMapToCurrentZone()
    local id = C_Map.GetBestMapForUnit("player")
    if mapIds[id] and tContains(self:GetInstances(), mapIds[id]) then
      local raidTier = self:GetRaidTiers(self.INSTANCE, mapIds[id])
      self:SetSelected(self.INSTANCE, mapIds[id])
      self:SetSelected(self.DIFFICULTY, self:GetDifficulty())
      ZoneDetect:EnableBossTracking()
    else
      ZoneDetect:DisableBossTracking()
    end
    waitingForMovement = false
    self:UnregisterEvent("PLAYER_STARTED_MOVING")
  end
end

function ZoneDetect:RegisterMapID(id, raid)
  mapIds[id] = raid
end

function ZoneDetect:RegisterNPCID(id, instance, bossid)
  npcIds[id] = {instance, bossid}
end