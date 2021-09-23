--[[
Copyright 2010 João Cardoso
CustomTutorials is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of CustomTutorials.

CustomTutorials is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CustomTutorials is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CustomTutorials. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib, Old = LibStub:NewLibrary('CustomTutorials-1.0', 1)
if not Lib then
	return
else
	LibStub('EmbedHandler-1.0'):Embed(Lib)
	Lib.GetNext, Lib.GetPrev = GetNextCompleatedTutorial, GetPrevCompleatedTutorial
	Lib.FlagTutorial, Lib.Flagged = FlagTutorial, IsTutorialFlagged
	Lib.Reg, Lib.Flag, Lib.Prev, Lib.After = {}, {}, {}, {}
end

local Reg, Flag, Prev, After = Lib.Reg, Lib.Flag, Lib.Prev, Lib.After
local type, tonumber = type, tonumber -- speed up!


--[[ API ]]--

function Lib:NewTutorial(id, data)
	if type(tonumber(id)) ~= 'number' and type(data) == 'table' and not Reg[id] then
		Reg[id] = data
		TutorialFrame_NewTutorial(id)
	end
end

function Lib:ShowTutorial(id)
	TutorialFrame_Update(id)
end

function Lib:GetTutorial(id)
	return id and Reg[id]
end


--[[ Update ]]--

function Lib.OnUpdate(id)
	local data = id and Reg[id]
	
	if data then
		TutorialFrameTitle:SetText(data.title or '')
		TutorialFrameText:SetText(data.text or '')
	
		TutorialFrameTextScrollFrame:ClearAllPoints()
		TutorialFrameTextScrollFrame:SetPoint('TOPLEFT', TutorialFrame, 33, data.textOff or -75)
		TutorialFrameTextScrollFrame:SetPoint('BOTTOMRIGHT', TutorialFrame, -29, 35)
		
		if data.height then
			for i = 8, data.height do
				local rightTexture = _G['TutorialFrameRight'..i]
				local leftTexture = _G['TutorialFrameLeft'..i]
				
				rightTexture:SetPoint('TOPRIGHT', _G['TutorialFrameRight'.. i - 1], 'BOTTOMRIGHT', 0, 0)
				leftTexture:SetPoint('TOPLEFT', _G['TutorialFrameLeft'.. i - 1], 'BOTTOMLEFT', 0, 0)
				rightTexture:Show()
				leftTexture:Show()
			end
		
			TutorialFrameBottom:SetPoint('TOPLEFT', _G['TutorialFrameLeft' .. data.height], 'BOTTOMLEFT', 0, 0)
			TutorialFrameBottom:SetPoint('TOPRIGHT', _G['TutorialFrameRight' .. data.height], 'TOPRIGHT', 0, 0)
			TutorialFrame:SetHeight(110 + data.height * 10)
		end	
		
		TutorialFrame:ClearAllPoints()
		TutorialFrame:SetPoint(data.point or 'LEFT', data.x or 15, data.y or 30)
		
		if data.image then
			TutorialFrameImage1:SetTexture(data.image)
			TutorialFrameImage1:SetPoint('TOP', TutorialFrame, 5, data.imageOff or 0)
			TutorialFrameImage1:Show()
		end
		
		if data.pulse then
			TutorialFrameCallOut:SetParent(data.pulse)
			TutorialFrameCallOut:SetPoint(data.pulsePoint or 'CENTER', data.pulse, data.pulseX or 0, data.pulseY or 0)
			TutorialFrameCallOut:SetSize(data.pulseWidth, data.pulseHeight)
			TutorialFrameCallOutPulser:Play()
			TutorialFrameCallOut:Show()
		end
	else
		TutorialFrameCallOut:SetParent(TutorialFrame)
	end
end

function Lib.OnShow()
	TutorialFrameCallOut:Show()
end

function Lib.OnHide()
	if not TutorialFrame:IsShown() then
		TutorialFrameCallOut:Hide()
	end
end


--[[ Taints ]]--

function FlagTutorial(id)
	if id and not IsTutorialFlagged(id) then
		local Last = Lib.Last
		if Last then
			After[Last] = id
			Prev[id] = Last
		end
	
		if Reg[id] then
			Flag[id] = true
		else
			Lib.FlagTutorial(id)
		end
		
		Lib.Last = id
	end
end

function IsTutorialFlagged(id)
	local isFake = id and Reg[id]
	if isFake then
		return Flag[id]
	else
		return Lib.Flagged(id)
	end
end

function GetPrevCompleatedTutorial(id, force)
	if id then
		return Prev[id] or not Reg[id] and Lib.GetPrev(id)
	end
end

function GetNextCompleatedTutorial(id)
	if id then
		return After[id] or not Reg[id] and Lib.GetNext(id)
	end
end


--[[ Hooks ]]--

hooksecurefunc('TutorialFrame_Update', function(...) Lib.OnUpdate(...) end)
TutorialFrame:HookScript('OnShow', function(...) Lib.OnShow(...) end)
TutorialFrame:HookScript('OnHide', function(...) Lib.OnHide(...) end)