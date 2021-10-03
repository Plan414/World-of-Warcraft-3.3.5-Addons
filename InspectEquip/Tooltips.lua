if not InspectEquip then return end

local IE = InspectEquip
local L = LibStub("AceLocale-3.0"):GetLocale("InspectEquip")

function IE:AddToTooltip(tip, itemLink)
  if InspectEquipConfig.tooltips == false then return end

  -- prevent adding information twice for recipe links
  if tip.InspectEquipItem == itemLink then return end
  tip.InspectEquipItem = itemLink

  local sources = IE:FindItem(itemLink)
  if sources then
    for _, entry in pairs(sources) do
      --local src, subsrc, lootTable, boss, cost, setname = unpack(entry)
      local src, subsrc, lootTable, boss, cost, setname = entry[1], entry[2], entry[3], entry[4], entry[5], entry[6]
      local str = src
      local r,g,b = InspectEquipConfig.ttR, InspectEquipConfig.ttG, InspectEquipConfig.ttB
      if subsrc then str = str .. ": " .. subsrc end
      if lootTable then str = str .. " (" .. lootTable .. ")" end
      if boss then str = str .. ": " .. boss end
      if cost and cost ~= 0 then str = str .. " (" .. cost .. ")" end
      if setname then str = str .. " (" .. setname .. ")" end
      tip:AddDoubleLine(L["Source"] .. ":", str, r, g, b, r, g, b)
    end
    tip:Show()
  end
end


local function clearTip(tooltip)
  tooltip.InspectEquipItem = nil
end

local function hookTip(tooltip, method, action)
  if not tooltip then return end
  hooksecurefunc(tooltip, method, function(tip, ...)
    local link, count = action(...)
    if link then
      IE:AddToTooltip(tip, link)
    end
  end)
end

local function hookCompareTip(tooltip)
  if not tooltip then return end
  hooksecurefunc(tooltip, 'SetHyperlinkCompareItem', function(tip, mainLink)
    local _, link = tip:GetItem()
    if link then
      IE:AddToTooltip(tip, link)
    end
  end)
end

local function hookTipScript(tooltip)
  if tooltip and tooltip.HookScript then
    tooltip:HookScript('OnTooltipSetItem', function(tip, ...)
      local _, link = tip:GetItem()
      if link and GetItemInfo(link) then
        IE:AddToTooltip(tip, link)
      end
    end)
    tooltip:HookScript('OnTooltipCleared', clearTip)
  end
end

function IE:HookTooltips()
  if IE.tooltipsHooked then return end
  IE.tooltipsHooked = true

  hookTipScript(GameTooltip)
  hookTipScript(ItemRefTooltip)

  hookCompareTip(ShoppingTooltip1)
  hookCompareTip(ShoppingTooltip2)
  hookCompareTip(ShoppingTooltip3)
  hookCompareTip(ItemRefShoppingTooltip1)
  hookCompareTip(ItemRefShoppingTooltip2)
  hookCompareTip(ItemRefShoppingTooltip3)

  -- Not really needed, but... :-)
  if AtlasLootTooltip then
    hookTipScript(AtlasLootTooltip)
  end

  if LinkWrangler and LinkWrangler.RegisterCallback then
    LinkWrangler.RegisterCallback("InspectEquip", function(frame,link)
      IE:AddToTooltip(frame,link)
    end, "item")
  end
end

