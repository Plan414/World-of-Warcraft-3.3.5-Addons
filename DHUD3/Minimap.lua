--[[
DHUD3
	Copyright (c) 2006 by Markus Inger, 2006 by Caeryn Dryad, 2007-2009 by Horacio Hoyos
	Copyright (c) 2008 Tuller
	
	The Minimap code is from Tuller's Bongos Minimap Button (Based on the fubar and item rack minimap buttons)
	Thanks Tuller!

    This file is part of DHUD3.

    DHUD3 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DHUD3 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DHUD3.  If not, see <http://www.gnu.org/licenses/>.
]]--

local DHUD3 = LibStub("AceAddon-3.0"):GetAddon("DHUD3");
local L = LibStub("AceLocale-3.0"):GetLocale("DHUD3");

DHUD3.Minimap = CreateFrame('Button', 'DHUD3_MinimapButton', Minimap);
local MinimapButton = DHUD3.Minimap;

function MinimapButton:Load()
	
	self:SetFrameStrata('MEDIUM');
	self:SetWidth(31);
	self:SetHeight(31);
	self:SetFrameLevel(8);
	self:RegisterForClicks('anyUp');
	self:RegisterForDrag('LeftButton');
	self:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight');

	local overlay = self:CreateTexture(nil, 'OVERLAY');
	overlay:SetWidth(53);
	overlay:SetHeight(53);
	overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder');
	overlay:SetPoint('TOPLEFT');

	local icon = self:CreateTexture(nil, 'BACKGROUND');
	icon:SetWidth(20);
	icon:SetHeight(20);
	icon:SetTexture("Interface\\AddOns\\DHUD3\\icon");
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);
	icon:SetPoint('TOPLEFT', 7, -5);
	self.icon = icon;

	self:SetScript('OnEnter', self.OnEnter);
	self:SetScript('OnLeave', self.OnLeave);
	self:SetScript('OnClick', self.OnClick);
	self:SetScript('OnDragStart', self.OnDragStart);
	self:SetScript('OnDragStop', self.OnDragStop);
	self:SetScript('OnMouseDown', self.OnMouseDown);
	self:SetScript('OnMouseUp', self.OnMouseUp);
end

function MinimapButton:OnClick(button)
	if button == 'LeftButton' then
		InterfaceOptionsFrame_OpenToCategory(DHUD3.optionsFrames.DHUD3);
	elseif button == 'RightButton' then
		--DHUD3:Debug("Mimap Right Button", DHUD3:GetModule("Player"):IsEnabled());
		if DHUD3:GetModule("Player"):IsEnabled() then
			ToggleDropDownMenu(1, nil, DHUD3_playerDropDown, DHUD3_MinimapButton, 120, 10);
		end
	end
	self:OnEnter()
end

function MinimapButton:OnMouseDown()
	self.icon:SetTexCoord(0, 1, 0, 1)
end

function MinimapButton:OnMouseUp()
	self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
end

function MinimapButton:OnEnter()
	if not self.dragging then
		GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
		GameTooltip:SetText('DHUD3', 1, 1, 1)
		GameTooltip:Show()
	end
end

function MinimapButton:OnLeave()
	GameTooltip:Hide()
end

function MinimapButton:OnDragStart()
	self.dragging = true
	self:LockHighlight()
	self.icon:SetTexCoord(0, 1, 0, 1)
	self:SetScript('OnUpdate', self.OnUpdate)
	GameTooltip:Hide()
end

function MinimapButton:OnDragStop()
	self.dragging = nil
	self:SetScript('OnUpdate', nil)
	self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	self:UnlockHighlight()
end

function MinimapButton:OnUpdate()
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()

	px, py = px / scale, py / scale

	DHUD3:SetMinimapButtonPosition(math.deg(math.atan2(py - my, px - mx)) % 360)
	self:UpdatePosition()
end

--magic fubar code for updating the minimap button's position
--I suck at trig, so I'm not going to bother figuring it out
function MinimapButton:UpdatePosition()
	local angle = math.rad(DHUD3:GetMinimapButtonPosition() or random(0, 360))
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local minimapShape = GetMinimapShape and GetMinimapShape() or 'ROUND'

	local round = false
	if minimapShape == 'ROUND' then
		round = true
	elseif minimapShape == 'SQUARE' then
		round = false
	elseif minimapShape == 'CORNER-TOPRIGHT' then
		round = not(cos < 0 or sin < 0)
	elseif minimapShape == 'CORNER-TOPLEFT' then
		round = not(cos > 0 or sin < 0)
	elseif minimapShape == 'CORNER-BOTTOMRIGHT' then
		round = not(cos < 0 or sin > 0)
	elseif minimapShape == 'CORNER-BOTTOMLEFT' then
		round = not(cos > 0 or sin > 0)
	elseif minimapShape == 'SIDE-LEFT' then
		round = cos <= 0
	elseif minimapShape == 'SIDE-RIGHT' then
		round = cos >= 0
	elseif minimapShape == 'SIDE-TOP' then
		round = sin <= 0
	elseif minimapShape == 'SIDE-BOTTOM' then
		round = sin >= 0
	elseif minimapShape == 'TRICORNER-TOPRIGHT' then
		round = not(cos < 0 and sin > 0)
	elseif minimapShape == 'TRICORNER-TOPLEFT' then
		round = not(cos > 0 and sin > 0)
	elseif minimapShape == 'TRICORNER-BOTTOMRIGHT' then
		round = not(cos < 0 and sin < 0)
	elseif minimapShape == 'TRICORNER-BOTTOMLEFT' then
		round = not(cos > 0 and sin < 0)
	end

	local x, y
	if round then
		x = cos*80
		y = sin*80
	else
		x = math.max(-82, math.min(110*cos, 84))
		y = math.max(-86, math.min(110*sin, 82))
	end

	self:SetPoint('CENTER', x, y)
end

MinimapButton:Load();