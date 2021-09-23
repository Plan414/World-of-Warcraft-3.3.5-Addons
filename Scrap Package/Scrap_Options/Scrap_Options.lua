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

local Options = CreateFrame('Frame', 'ScrapOptions', nil, 'UIDropDownMenuTemplate')
local Tutorials = LibStub('CustomTutorials-1.0')
local L = Scrap_Locals


--[[ Dropdown ]]--

function Options:ToggleDropdown(anchor)
	local info = {
		{
		    text = 'Scrap',
		    isTitle = 1
    	},
   		{
		    text = L.AutoSell,
		    tooltipTitle = L.AutoSell,
		    tooltipText = L.AutoSellDesc,
		    func = function() Scrap_AutoSell = not Scrap_AutoSell or nil end,
		    checked = function() return Scrap_AutoSell end
    	},
    	{
		    text = L.ShowTutorials,
		    func = function() self:ShowTutorials() end
    	}
	}

	EasyMenu(info, self, anchor or 'Scrap', 0, 0, 'MENU')
end


--[[ Tutorials ]]--

function Options:ShowTutorials()
	if not Tutorials:GetTutorial('Scrap') then
		self:ShowTutorial('Scrap', L.Tutorial, 'Interface\\Addons\\Scrap_Options\\Textures\\Tutorial', 22, Scrap)
		self:ShowTutorial('Scrap2', L.Tutorial2, 'Interface\\Addons\\Scrap_Options\\Textures\\Tutorial2', 18, MainMenuBarBackpackButton)
	end
	
	Tutorials:ShowTutorial('Scrap')
end

function Options:ShowTutorial(id, text, image, height, target)
	Tutorials:NewTutorial(id, {
		title = 'Scrap',
		textOff = -190,
		text = text,
			
		imageOff = -55,
		image = image,
			
		x = -25, y = -180,
		point = 'TOPRIGHT',
		height = height,
			
		pulse = target,
		pulseHeight = 48,
		pulseWidth = 48,
	})
end


--[[ Startup ]]--

if not Scrap_Tutorials then
	Options:ShowTutorials()
	Scrap_Tutorials = true
end