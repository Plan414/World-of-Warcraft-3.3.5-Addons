assert(RaidCooldowns, "RaidCooldowns not found!")

local MINOR_VERSION = tonumber(("$Revision: 48 $"):match("%d+"))
local AceConfig = LibStub("AceConfigDialog-3.0")
local Media = LibStub("LibSharedMedia-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCooldowns")

local RaidCooldowns = RaidCooldowns
local mod = RaidCooldowns:NewModule("Display", nil, "AceComm-3.0", "AceEvent-3.0", "AceConsole-3.0", "LibBars-1.0")

local pairs = _G.pairs
local UnitName, UnitClass = _G.UnitName, _G.UnitClass
local tonumber, tostring, type = _G.tonumber, _G.tostring, _G.type

local barGroup = nil
local function sortFunc(a, b)
	if a.isTimer ~= b.isTimer then
		return a.isTimer
	end
	
	if a.value == b. value then
		return a.name > b.name
	else
		return a.value > b.value
	end
end

local playerName
local defaults = {
	profile = {
		locked      = false,
		scale       = 100.0,
		texture     = "Smooth v2",
		growUp      = false,
		clamped     = true,
		fontFace    = nil,
		fontSize    = 10,
		orientation = 1,
		alpha       = 100.0,
		
		width  = 150,
		height = 14,
		
		hideSelf = false,
		readyMsg = false,
		spells = { },
	}
}
local optFrame
function mod:OnInitialize()
	--[===[@debug@
	self:Print("OnInitialize()")
	--@end-debug@]===]
end

function mod:OnEnable()
	--[===[@debug@
	self:Print("OnEnable()")
	--@end-debug@]===]
	
	self.db = LibStub("AceDB-3.0"):New("RCD_DB", nil, "Default")
	
	if not self.db.profile.spells or #self.db.profile.spells == 0 then
		-- Default all spells to enabled
		for k,v in pairs(RaidCooldowns.cooldowns) do
			for k2, v2 in pairs(v) do
				defaults.profile.spells[v2.id] = true
			end
		end
	end
	
	self.db:RegisterDefaults(defaults)
	
	optFrame = AceConfig:AddToBlizOptions(L["RaidCooldowns"], L["RaidCooldowns"])
	
	--self:UnregisterAllEvents()
	--self:RegisterEvent("PLAYER_LOGIN")

	playerName = UnitName("player")
	
	self:CreateFrame()
	self:SetAnchors(true)
	self:UpdateDisplay()
end

function mod:OnDisable()
	--[===[@debug@
	self:Print("OnDisable()")
	--@end-debug@]===]
	
	--self:UnregisterAllEvents()
	--barGroup = nil
end

function mod:StartCooldown(sender, spellId, cooldown)
	if self.db.profile.hideSelf and sender == playerName then return end
	if not self.db.profile.spells[spellId] then return end -- Only show a bar for this spell if the user enabled it
	
	-- Because we now scan all spells whenever a Spell Cooldown event is fired,
	-- a sync might be sent multiple times for the same spell. This block prevents
	-- the bar from constantly updating its max time, making it look like the
	-- cooldown is being used again.
	local bar = barGroup:GetBar(sender .. "_" .. spellId)
	if bar == nil then
		bar = barGroup:NewTimerBar((sender .. "_" .. spellId), sender, cooldown, cooldown, spellId)
		bar.caster  = sender
		bar.spellId = spellId
	else
		bar:SetTimer(cooldown, bar.maxValue)
	end

	local _, c = UnitClass(sender)
	if not c then
		-- Get the class name from our cooldown table; this is used exclusively for testing
		for k, v in pairs(RaidCooldowns.cooldowns) do
			for k2, v2 in pairs(v) do
				if v2.id == spellId then
					c = k
				end
			end
		end
	end
	
	local color = RAID_CLASS_COLORS[c]
	if type(color) == "table" then
		bar:SetColorAt(1.00, color.r, color.g, color.b, 1)
		bar:SetColorAt(0.00, color.r, color.g, color.b, 1)
	end
end

function mod:StopCooldown(sender, spellId)
	local bar = barGroup:GetBar(sender .. "_" .. spellId)
	if bar ~= nil then
		barGroup:RemoveBar(bar)
		self:UpdateDisplay() -- Removes a gap that appears in edge cases
	end
end

function mod:PLAYER_LOGIN()
	--[===[@debug@
	--self:Print("PLAYER_LOGIN()")
	--@end-debug@]===]
	--self:UnregisterEvent("PLAYER_LOGIN")
end

--[[		Configuration Methods		]]--

function mod:ShowConfig()
	AceConfig:SetDefaultSize(L["RaidCooldowns"], 500, 550)
	AceConfig:Open(L["RaidCooldowns"], configFrame)
end

function mod:Test()
	self = mod
	
	local i = 1
	for _, v in pairs(RaidCooldowns.cooldowns) do
		for _, v2 in pairs(v) do
			self:StartCooldown(L["RaidCooldowns"], v2.id, i * 3)
			i = i + 1
		end
	end
end

function mod:Reset()
	local bars = barGroup:GetBars()
	if type(bars) == "table" then
		for k, v in pairs(bars) do
			barGroup:RemoveBar(k)
		end
	end
end

function mod:SpellToggle(spell, val)
	if val == true then return end -- Don't need to do anything when the spell's enabled
	
	-- Remove any running bars that represent the spell we just disabled
	local bars = barGroup:GetBars()
	local removed = false
	if type(bars) == "table" then
		for k, v in pairs(bars) do
			if spell == v.spellId then
				barGroup:RemoveBar(k)
				removed = true
			end
		end
	end
	
	-- A bar was removed, force our anchor to update so that the gap gets removed
	if removed then
		self:UpdateDisplay()
	end
end

--[[		Bar Group Anchor		]]--

function mod:CreateFrame()
	barGroup = nil
	
	barGroup = self:NewBarGroup(L["RaidCooldowns"], nil, self.db.profile.width, self.db.profile.height, "RCDD_Anchor")
	barGroup:SetFlashPeriod(0)
	barGroup:SetSortFunction(sortFunc)
	
	-- Callbacks
	barGroup.RegisterCallback(self, "AnchorClicked")
	barGroup.RegisterCallback(self, "AnchorMoved")
	barGroup.RegisterCallback(self, "TimerFinished")
end

function mod:UpdateDisplay()
	if not barGroup then return end
	
	if self.db.profile.locked then
		barGroup:Lock()
		barGroup:HideAnchor()
	else
		barGroup:Unlock()
		barGroup:ShowAnchor()
	end

	barGroup:SetOrientation(self.db.profile.orientation)
	barGroup:SetClampedToScreen(self.db.profile.clamped)
	barGroup:SetFont(Media:Fetch("font", self.db.profile.fontFace), self.db.profile.fontSize)
	barGroup:SetTexture(Media:Fetch("statusbar", self.db.profile.texture))
	barGroup:SetScale(self.db.profile.scale / 100.0)
	barGroup:ReverseGrowth(self.db.profile.growUp)
	barGroup:SetAlpha(self.db.profile.alpha / 100.0)
	barGroup:SetWidth(self.db.profile.width)
	barGroup:SetHeight(self.db.profile.height)
end

-- Omen rip
function mod:SetAnchors(useDB)
	local t = self.db.profile.growUp
	local x, y
	if useDB then
		x, y = self.db.profile.posX, self.db.profile.posY
		if not x and not y then
			barGroup:ClearAllPoints()
			barGroup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			return
		end
	elseif t then
		x, y = barGroup:GetLeft(), barGroup:GetBottom()
	else
		x, y = barGroup:GetLeft(), barGroup:GetTop()
	end
	barGroup:ClearAllPoints()
	if t then
		barGroup:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
	else
		barGroup:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
	self.db.profile.posX, self.db.profile.posY = x, y
end

function mod:AnchorClicked(cbk, group, button)
	if button == "RightButton" then
		self:ShowConfig()
	end
end

function mod:AnchorMoved(cbk, group, x, y)
	self:SetAnchors()
end

function mod:TimerFinished(cbk, group, bar, name)
	if not self.db.profile.readyMsg then return end

	RaidCooldowns:Print(L["%s's %s is up."]:format(bar.caster, GetSpellInfo(bar.spellId)))
end