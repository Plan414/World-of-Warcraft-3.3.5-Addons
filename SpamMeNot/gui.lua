--[[    
    SpamMeNot: Detects and blocks commercial spam
    Copyright (C) 2008 Robert Stiles (robs@codexsoftware.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--[[
	I was going to use AceGUI for this but I don't fully understand it, and
	to make it usable for me I think it would mean more coding than just doing
	it all myself - SpamMeNot's UI isn't very complicated.
]]

local L = LibStub("AceLocale-3.0"):GetLocale("SpamMeNot")

local GUI = {}

function GUI:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

function GUI:New()
	local o = self:new()		
	
	local FrameBackdrop = {
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	}	
	
	-- Main frame	
	local frame = CreateFrame("Frame","SpamMeNot_UI",UIParent)	
	frame:SetWidth(400)
	frame:SetHeight(300)
	frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:EnableMouse()
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")	
	frame:SetScript("OnDragStart", function() local o = this or self o:StartMoving() end)
	frame:SetScript("OnDragStop", function() local o = this or self o:StopMovingOrSizing() end)		
	frame:SetBackdrop(FrameBackdrop)
	frame:SetBackdropColor(0,0,0,1)
	frame:Hide()
	tinsert(UISpecialFrames, "SpamMeNot_UI") -- allows escape key to close window
	o.frame = frame
		
	-- Header frame	
	local header = CreateFrame("Frame", nil, frame)
	header:SetWidth(frame:GetWidth() - (12 *2))
	header:SetHeight(40)
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -10)
	--header:SetBackdrop(FrameBackdrop)
	--header:SetBackdropColor(1,1,1,1)
	
	-- Combo
	local combo = CreateFrame("Frame", "SpamMeNot_Combo", header, "UIDropDownMenuTemplate")
	combo:SetWidth(60)
	combo:SetPoint("TOPLEFT", header, "TOPLEFT", -15, -5)
	combo:SetScript("OnShow", function()
		SpamMeNot.gui:InitializeCombo()
	end)
	
	o.combo = combo

	-- Actual Score
	local label = header:CreateFontString("", "OVERLAY", "GameFontWhite")
	label:SetPoint("TOPRIGHT", header, "TOPRIGHT", -10, -10)
	label:SetText("0")
	o.score = label
	
	-- Score label	
	local title = header:CreateFontString("", "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPRIGHT", label, "TOPLEFT", -10, 0)
	title:SetText(string.format("%s:", L["Score"]))
		
	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", "SpamMeNotScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
	scrollFrame:SetWidth(355)
	scrollFrame:SetHeight(210)
	scrollFrame:SetScript("OnShow", function()
		local o = this or self
		o:UpdateScrollChildRect()
	end)
	
	-- The text frame
	local textFrame = CreateFrame("Frame", nil, scrollFrame)
	textFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
	textFrame:SetWidth(scrollFrame:GetWidth())
	textFrame:SetHeight(scrollFrame:GetHeight())
	scrollFrame:SetScrollChild(textFrame)
	
	-- The actual text
	local text = textFrame:CreateFontString("", "OVERLAY", "GameFontWhite")
	text:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 0 ,0)
	text:SetWidth(textFrame:GetWidth())
	text:SetJustifyH("LEFT")
	text:SetText("...")	
	o.text = text
		
	-- Report button
	local button = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
	button:SetText(L["Report"])
	button:SetScript("OnClick", function()
		SpamMeNot.gui:OnReportClicked()
	end)
	button:Disable()
	o.btnReport = button
	
	-- Innocent button
	old = button
	button = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button:SetPoint("TOPLEFT", old, "TOPRIGHT", 0, 0)
	button:SetText(L["Innocent"])
	button:SetScript("OnClick", function()
		SpamMeNot.gui:OnInnocentClicked()
	end)
	button:Disable()
	o.btnInnocent = button
	
	-- Whitelist button
	old = button
	button = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button:SetPoint("TOPLEFT", old, "TOPRIGHT", 0, 0)
	button:SetText(L["Whitelist"])
	button:SetScript("OnClick", function()
		SpamMeNot.gui:OnWhitelistClicked()
	end)
	button:Disable()
	button:Hide()
	o.btnWhitelist = button
	
	-- Close button
	--local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	--closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
	button = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	button:SetText(L["Close"])
	button:SetScript("OnClick", function() 
		local o = this or self
		o:GetParent():Hide()
	end)
		
	o.displayedSpammer = ""
	
	return o
end

function GUI:InitializeCombo()
	UIDropDownMenu_Initialize(self.combo, self.PopulateSpammerCombo);
	if self.displayedSpammer then
		UIDropDownMenu_SetSelectedValue(self.combo, self.displayedSpammer);
	end
	
	UIDropDownMenu_SetWidth(self.combo, 100, 2);
	
end

function GUI.PopulateSpammerCombo()
	local info = {};
	local me = this or self
	local found = false
	
	for spammer,_ in pairs(SpamMeNot.spammers.db) do
		info = {}
		info.text = spammer
		info.value = spammer
		info.justifyH = "LEFT"
		info.func = function () 
			SpamMeNot.gui:ShowSpam(this.value)
			UIDropDownMenu_SetSelectedValue(SpamMeNot.gui.combo, me.value)
		end
		UIDropDownMenu_AddButton(info)
		found = true
	end
	
	if not found then
		info = {}
		info.text = "(none)"
		info.value = nil
		info.justifyH = "LEFT"
		info.func = nil
		UIDropDownMenu_AddButton(info)
	end

end

function GUI:ShowSpam(name)	
	self:Hide()
	name = name or ""
	self.displayedSpammer = name
	local player = SpamMeNot.players:GetPlayer(name)
	UIDropDownMenu_SetSelectedValue(SpamMeNot.gui.combo, name)
	
	self.score:SetText(player:GetRating())
	local text = ""
	for i,evidence in ipairs(player.evidence) do
		text = text .. string.format("|cffffd100|h%.02d:%.02d:%.02d:|r %s\n", 
		evidence.time.serverHour, evidence.time.serverMin, evidence.time.sec, evidence.text)	
	end
	self.text:SetText(text)
		
	if player:IsReported() then
		self.btnReport:Disable()
		self.btnInnocent:Disable()
		self.btnWhitelist:Disable()
	else
		self.btnReport:Enable()
		self.btnInnocent:Enable()		
	end
	
	self.btnWhitelist:Disable()
	self:Show()
end

function GUI:Show()
	self.frame:Show()
end

function GUI:Hide()
	self.frame:Hide()
end

function GUI:OnReportClicked()
	local player = SpamMeNot.players:GetPlayer(self.displayedSpammer)
	player:Report()
	self.btnReport:Disable()
	self.btnInnocent:Disable()
	self.btnWhitelist:Disable()
end

function GUI:OnInnocentClicked()
	SpamMeNot.spammers:Remove(self.displayedSpammer)
	self:Hide()
	self:ShowSpam(nil)
end

function GUI:OnWhitelistClicked()

end

SpamMeNot.GUI = GUI