--[[
Copyright 2008, 2009, 2010 João Cardoso
Scrap is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Scrap.

Scrap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Scrap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Scrap. If not, see <http://www.gnu.org/licenses/>.
--]]

local Tooltip = CreateFrame('GameTooltip', 'ScrapTooltip', nil, 'GameTooltipTemplate')
local Scrap = CreateFrame('Button', 'Scrap')

local MatchClass, Class = ITEM_CLASSES_ALLOWED:format(''), UnitClass('player')
local MatchTrade = BIND_TRADE_TIME_REMAINING:format('.*')
local Unusable, List = Scrap_Unusable


--[[ Events ]]--

function Scrap:Startup()
	self:SetScript('OnReceiveDrag', function() self:OnReceiveDrag() end) -- for the plugins to hook
	self:SetScript('OnEvent', function() self[event](self) end)
	self:RegisterEvent('VARIABLES_LOADED')
	self:RegisterEvent('MERCHANT_SHOW')
end

function Scrap:VARIABLES_LOADED()
	Scrap_List = Scrap_List or {}
	List = Scrap_List
end

function Scrap:MERCHANT_SHOW()
	if not LoadAddOn('Scrap_Merchant') then
		self:UnregisterEvent('MERCHANT_SHOW')
	else
		self:MERCHANT_SHOW()
	end
end


--[[ Item API ]]--

function Scrap:IsJunk(itemID)
	if itemID then
		local _, itemLink, itemQuality, _,_, itemType, itemSubType, _, itemSlot, _, itemValue = GetItemInfo(itemID)
		local valuable = itemQuality ~= ITEM_QUALITY_POOR or itemValue == 0
		
		if valuable and (itemType == 'Armor' or itemType == 'Weapon') then
			Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
			Tooltip:SetHyperlink(itemLink)
			
			local numLines = Tooltip:NumLines()
			local lastLine = _G['ScrapTooltipTextLeft'..numLines]:GetText()
			
			if not strmatch(lastLine, MatchTrade) then
				for i = 2,4 do
					if _G['ScrapTooltipTextLeft'..i]:GetText() == ITEM_BIND_ON_PICKUP then
						if Unusable[itemSubType] or Unusable['Off Hand'] and itemSlot == "INVTYPE_WEAPONOFFHAND" then
							valuable = nil
						else
							for i = numLines, i, -1 do
								local text = _G['ScrapTooltipTextLeft'..i]:GetText()
								if strmatch(text, MatchClass) then
									valuable = strmatch(text, Class)
									break
								end
							end
						end
						break
					end
				end
			end
		end

		return valuable and List[itemID] or not valuable and not List[itemID]
	end
end

function Scrap:IsLocked(bag, slot)
	return select(3, GetContainerItemInfo(bag, slot))
end

function Scrap:IterateJunk()
	local bagNumSlots, bag, slot = GetContainerNumSlots(BACKPACK_CONTAINER), BACKPACK_CONTAINER, 0
	local match, itemID
	
	return function()
		match = nil
		
		while not match do
			if slot < bagNumSlots then
				slot = slot + 1
			elseif bag < NUM_BAG_FRAMES then
				bag = bag + 1
				bagNumSlots = GetContainerNumSlots(bag)
				slot = 1
			else
				bag, slot = nil
				break
			end
			
			itemID = GetContainerItemID(bag, slot)
			match = self:IsJunk(itemID) and not self:IsLocked(bag, slot)
		end
		
		return bag, slot, itemID
	end
end

function Scrap:GetJunkValue()
    local value = 0
    for bag, slot, id in self:IterateJunk() do
    	local itemValue = select(11, GetItemInfo(id))
    	local stack = select(2, GetContainerItemInfo(bag, slot))
    	
		value = value + itemValue * stack
	end
	return value
end


--[[ Call Addon ]]--

Scrap:Startup()