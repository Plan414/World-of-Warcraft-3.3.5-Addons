assert(RaidCooldowns, "RaidCooldowns not found!")
if (select(2, UnitClass("player"))) ~= "PRIEST" then return end

local guardian = GetSpellInfo(47788)
local mod = RaidCooldowns:NewModule("Priest", RaidCooldowns.ModuleBase, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
mod.cooldowns = RaidCooldowns.cooldowns["PRIEST"]

function mod:OnEnable()
	--[===[@debug@
	self:Print("OnEnable override")
	--@end-debug@]===]
	
	self:Super("OnEnable")
	
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "PriestSpellSuccess")
end

function mod:PriestSpellSuccess(event, unit, spell)
	if unit ~= "player" then return end
	
	if spell == guardian then
		-- Guardian Spirit cast; schedule an event in, like, 12 seconds to scan the
		-- cooldown to see if the Glyph reset it.
		self:ScheduleTimer("GuardianScan", 12)
	end
	
	-- Let our generic method run as normal
	self:GenericSpellSuccess(event, unit, spell)
end

function mod:GuardianScan()
	self.canScanCooldowns = true
	self:ScanSpells()
end