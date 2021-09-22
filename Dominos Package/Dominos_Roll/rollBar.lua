﻿--[[
	rollBar
		A dominos frame for rolling on items when in a party
--]]

--[[
	Copyright (c) 2008-2009 Jason Greer
	All rights reserved.

	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright notice, 
		  this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in the 
		  documentation and/or other materials provided with the distribution.
		* Neither the name of the author nor the names of its contributors may 
		  be used to endorse or promote products derived from this software 
		  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
	LIABLE FORANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
--]]


--[[ Module Stuff ]]--

local DRB = Dominos:NewModule('roll')
local L = LibStub('AceLocale-3.0'):GetLocale('Dominos')
local RollBar

function DRB:Load()
	self.frame = RollBar:New()
end

function DRB:Unload()
	self.frame:Free()
end


--[[ Roll Bar Object ]]--

RollBar = Dominos:CreateClass('Frame', Dominos.Frame)

function RollBar:New()
	local f = self.super.New(self, 'roll', L.TipRollBar)
	f:LoadButtons()
	f:Layout()

	return f
end

function RollBar:GetDefaults()
	return {
		point = 'LEFT',
		numButtons = NUM_GROUP_LOOT_FRAMES,
		columns = 1,
		spacing = 2
	}
end

function RollBar:AddButton(i)
	local b =  _G['GroupLootFrame' .. (5 - i)]
	b:SetParent(self.header)
	self.buttons[i] = b
end

function RollBar:RemoveButton(i)
	local b = self.buttons[i]
	b:SetParent(nil)
	self.buttons[i] = nil
end

UIPARENT_MANAGED_FRAME_POSITIONS['GroupLootFrame1'] = nil