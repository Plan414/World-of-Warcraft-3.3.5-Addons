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


local MONEY_TYPES = {'Gold', 'Silver', 'Copper'}
local L, List = Scrap_Locals, Scrap_List
local Background, Icon, Border


--[[ Startup ]]--

function Scrap:CreateButton()
	-- Regions --
	Background = self:CreateTexture(nil, 'BORDER')
	Background:SetHeight(27) Background:SetWidth(27)
	Background:SetPoint('CENTER', -0.5, -1.2)
	Background:SetTexture(0, 0, 0)
	
	Icon = self:CreateTexture(self:GetName()..'Icon')
	Icon:SetTexture('Interface\\Addons\\Scrap\\Textures\\Enabled Box')
	Icon:SetHeight(33) Icon:SetWidth(33)
	Icon:SetPoint('CENTER')
	
	Border = self:CreateTexture(self:GetName() .. 'Border', 'OVERLAY')
	Border:SetTexture('Interface\\Addons\\Scrap\\Textures\\Merchant Border')
	Border:SetHeight(35.9) Border:SetWidth(35.9)
	Border:SetPoint('CENTER')
	
	-- Appearance --
	self:SetHighlightTexture('Interface/Buttons/ButtonHilight-Square', 'ADD')
	self:SetPushedTexture('Interface/Buttons/UI-Quickslot-Depress')
	self:SetHeight(37) self:SetWidth(37)
	self:SetParent(MerchantBuyBackItem)
	
	-- Scripts --
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	self:SetScript('OnClick', self.OnClick)
	
	-- Misc --
	self:RegisterEvent('MERCHANT_CLOSED')
	self:UpdateButtonPosition()

	-- Hooks --
	hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
		self:UpdateButtonPosition()
	end)
end


--[[ Events ]]--

function Scrap:MERCHANT_SHOW()
	self:RegisterEvent('BAG_UPDATE')
	
	if Scrap_AutoSell then
		self:SellJunk()
	else
		self:UpdateButtonState()
	end
	
	if not Scrap_Tutorials then
		LoadAddOn('Scrap_Options')
	end
end

function Scrap:MERCHANT_CLOSED()
	self:UnregisterEvent('BAG_UPDATE')
end

function Scrap:BAG_UPDATE()
	self:UpdateButtonState()
end


--[[ Button Scripts ]]--

function Scrap:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	self:OnTooltipShow()
	GameTooltip:Show()
end

function Scrap:OnTooltipShow(title)
	local infoType, itemID = GetCursorInfo()
	if infoType == 'item' then
		if self:IsJunk(itemID) then
			GameTooltip:SetText(L.Remove, 1, 1, 1)
		else
			GameTooltip:SetText(L.Add, 1, 1, 1)
		end
	else
		local value = self:GetJunkValue()
		if value > 0 then
			GameTooltip:SetText(title or L.SellJunk, 1, 0.82, 0)
			SetTooltipMoney(GameTooltip, value)
		end
	end
end

function Scrap:OnLeave()
	GameTooltip:Hide()
end

function Scrap:OnClick(button, ...)
	if button == 'LeftButton' then
		self:SellJunk()
	elseif button == 'RightButton' then
		LoadAddOn('Scrap_Options')
		
		if IsAddOnLoaded('Scrap_Options') then
			ScrapOptions:ToggleDropdown(...)
		end
	end
	self:GetScript('OnLeave')()
end

function Scrap:OnReceiveDrag()
	local infoType, itemID = GetCursorInfo()
	GameTooltip:Hide()
	ClearCursor()
	
	if infoType == 'item' then
		List[itemID] = not List[itemID] or nil
	
		local itemLink = select(2, GetItemInfo(itemID))
		if self:IsJunk(itemID) then
			self:Print(L.Added, itemLink, 'LOOT')
		else
			self:Print(L.Removed, itemLink, 'LOOT')
		end
		
		self:UpdateButtonState()
	end
end


--[[ Button API ]]--

function Scrap:UpdateButtonState()
	local disabled = self:GetJunkValue() == 0
	Border:SetDesaturated(disabled)
	Icon:SetDesaturated(disabled)
end

function Scrap:UpdateButtonPosition()
	if CanMerchantRepair() then
		local off, scale
		if CanGuildBankRepair() then
			off, scale = -3.5, 0.9
			MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, 'BOTTOMLEFT', 132.5, 89)
		else
			off, scale = -1.5, 1
		end
		self:SetPoint('RIGHT', MerchantRepairItemButton, 'LEFT', off, 0)
		self:SetScale(scale)
	else
		self:SetPoint('RIGHT', MerchantBuyBackItem, 'LEFT', -17, 0.5)
		self:SetScale(1.1)
	end
end


--[[ Selling API ]]--

function Scrap:SellJunk()
	local value = self:GetJunkValue()
	if value > 0 then
		self:Print(L.SoldJunk, GetCoinTextureString(value), 'MONEY')
	end

	for bag, slot, id in self:IterateJunk() do
		local value = select(11, GetItemInfo(id))
		if value > 0 then
			UseContainerItem(bag, slot)
		else
			PickupContainerItem(bag, slot)
			DeleteCursorItem()
		end
	end
	
	self:UpdateButtonState()
end


--[[ Messages API ]]--

function Scrap:Print(pattern, value, channel)
	channel = 'CHAT_MSG_' .. channel
	arg1 = format(pattern, value)
	arg2, arg3 = nil, nil
	arg4 = ''
	
	for i = 1,7 do
		local frame = _G['ChatFrame'..i]
		if frame:IsEventRegistered(channel) then
			ChatFrame_MessageEventHandler(frame, channel, arg1, nil, nil, arg4)
		end
	end
end


--[[ Load Addon ]]--

Scrap:CreateButton()
MerchantRepairText:SetAlpha(0)