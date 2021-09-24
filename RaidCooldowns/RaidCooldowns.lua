local MINOR_VERSION = tonumber(("$Revision: 2 $"):match("%d+"))

RaidCooldowns = LibStub("AceAddon-3.0"):NewAddon("RaidCooldowns", "AceConsole-3.0", "AceComm-3.0", "AceEvent-3.0")
RaidCooldowns.MINOR_VERSION = MINOR_VERSION

local UnitName = _G.UnitName

function RaidCooldowns:OnInitialize()
	self:UnregisterAllEvents()
	self:SetEnabledState(false) -- Enabled when we join a raid
	
	--[===[@debug@
	self:Print("OnInitialize")
	--@end-debug@]===]

	self.prefix = "RCD2"
	
	self:RegisterEvent("PLAYER_LOGIN")
end

function RaidCooldowns:OnEnable()
	self:RegisterComm(self.prefix)
	self:RegisterComm("oRA")
	self:RegisterComm("CTRA")
	
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	
	local name, module
	for name, module in self:IterateModules() do
		if not module:IsEnabled() then
			self:EnableModule(name)
		end
	end
end

function RaidCooldowns:OnDisable()
	--[[
	local name, module
	for name, module in self:IterateModules() do
		self:DisableModule(name)
	end
	]]
end

--------------[[		Events		]]--------------

function RaidCooldowns:PLAYER_LOGIN()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RAID_ROSTER_UPDATE()
end

-- oRA2
do
	local inRaid = false
	function RaidCooldowns:RAID_ROSTER_UPDATE()
		local inRaidNow = UnitInRaid("player")
		if not inRaid and inRaidNow then
			--[===[@debug@
			self:Print("In raid, calling self:Enable()")
			--@end-debug@]===]
			self:Enable()
			inRaid = true
		elseif inRaid and not inRaidNow then
			--[===[@debug@
			self:Print("Not in raid, calling self:Disable()")
			--@end-debug@]===]
			self:Disable()
		end
	end
end

function RaidCooldowns:COMBAT_LOG_EVENT_UNFILTERED(event, _, eventType, _, srcName, _, _, dstName, _, spellId, spellName, _, ...)
	if eventType ~= "SPELL_CAST_SUCCESS" and eventType ~= "SPELL_RESURRECT" and eventType ~= "SPELL_AURA_APPLIED" then return end
	if not srcName or srcName == UnitName("player") then return end
	if eventType == "SPELL_AURA_APPLIED" and spellId ~= 47883 then return end
	
	local _, c = UnitClass(srcName)
	if self.cooldowns[c] then
		local spells = self.cooldowns[c]
		if spells[spellName] then
			self:GetModule("Display"):StartCooldown(srcName, spellId, spells[spellName].cd)
			return
		end
	end
	
	return
end

--------------[[		Comm Methods		]]--------------

function RaidCooldowns:OnCommReceived(prefix, msg, distro, sender)
	if self:GetModule("Display").db.profile.hideSelf and sender == playerName then return end
	
	local spellId, cooldown = 0, 0
	
	if prefix == "oRA" or prefix == "CTRA" then
		spellId, cooldown = select(3, msg:find("CD (%d) (%d+)"))
		spellId  = tonumber(spellId)
		cooldown = tonumber(cooldown)
		
		if spellId == 0 or cooldown == 0 then return end
		
		local _, c = UnitClass(sender)
		if self.cooldowns[c] then
			for k, v in pairs(self.cooldowns[c]) do
				if v.ora and v.ora == spellId then -- spellId is, in this case, the oRA ID
					spellId = v.id
					self:GetModule("Display"):StartCooldown(sender, spellId, v.cd)
					
					return
				end
			end
		end
	else
		--[===[@debug@
		--self:Print("OnCommReceived(", prefix, msg, distro, sender, ")")
		--@end-debug@]===]
		spellId, cooldown = select(3, msg:find("(%d+) (%d+)"))
		spellId  = tonumber(spellId)
		cooldown = tonumber(cooldown)
		
		if cooldown == 0 then
			self:GetModule("Display"):StopCooldown(sender, spellId)
		else
			self:GetModule("Display"):StartCooldown(sender, spellId, cooldown)
		end
	end
end