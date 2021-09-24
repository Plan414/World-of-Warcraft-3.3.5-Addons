assert(RaidCooldowns, "RaidCooldowns not found!")

local MINOR_VERSION = tonumber(("$Revision: 2 $"):match("%d+"))
if MINOR_VERSION > RaidCooldowns.MINOR_VERSION then RaidCooldowns.MINOR_VERSION = MINOR_VERSION end

local pairs = _G.pairs
local GetTime = _G.GetTime
local GetSpellCooldown = _G.GetSpellCooldown

local base = {}

function base:OnInitialize()
	self:SetEnabledState(false)
end

function base:OnEnable()
	--[===[@debug@
	self:Print("OnEnable")
	--@end-debug@]===]
	
	-- SPELL_UPDATE_COOLDOWN is fired every time a spell is cast, because of the
	-- global cooldown. Using this variable lets UNIT_SPELLCAST_SUCCEEDED determine
	-- whether or not the spell being cast might affect something OTHER than the
	-- global cooldown, and if so, sets this variable to true. If we didn't do this,
	-- the Comm channel would be sent a message (albeit a small one) every time the
	-- user casts a spell, regardless of what it was or if it even had a cooldown.
	self.canScanCooldowns = true
	self:ScanSpells()
	
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "Respec")
	self:RegisterEvent("CONFIRM_TALENT_WIPE", "Respec")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "Respec")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "GenericSpellSuccess")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "ScanSpells")
end

function base:OnDisable()
	self:UnregisterAllEvents()
end

function base:Super(t)
	local sup = getmetatable(self)["__index"]
	return sup[t](sup == base and self or sup)
end

--------------[[		Combat Events		]]--------------

function base:GenericSpellSuccess(event, unit, spell)
	if unit ~= "player" then return end
	if self.cooldowns[spell] == nil then return end
	
	-- If we scanned the spell's cooldown right now, we'd get the global cooldown
	-- instead of the actual cooldown; set canScanCooldowns = true so that the next
	-- SPELL_UPDATE_COOLDOWN event can process the cooldown correctly
	self.canScanCooldowns = true
end

function base:Respec(event)
	self.canScanCooldowns = true
	self:ScanSpells()
end

function base:GetCooldown(spell)
	local remaining = 0
	local startTime, cooldown, enabled = GetSpellCooldown(spell)
	
	if spell == "Soulstone Resurrection" then
		startTime, cooldown, enabled = GetItemCooldown(36895)
	end
	
	if startTime and startTime > 0 and cooldown >= 2 and enabled == 1 then
		remaining = math.ceil(startTime + cooldown - GetTime())
	end
	
	return remaining
end

--------------[[		Comm Methods		]]--------------

function base:Sync(data, cooldown)
	if cooldown == nil then return end
	
	local id = data
	if type(data) == "table" then
		id = data.id
		
		if not oRA and data.ora ~= nil then
			RaidCooldowns:SendCommMessage("oRA", "CD " .. data.ora .. " " .. (cooldown / 60), "RAID")
		end
	end
	
	--[===[@debug@
	--self:Print("Sync(", id, cooldown, ")")
	--@end-debug@]===]
	
	--[===[@debug@
	--RaidCooldowns:SendCommMessage(RaidCooldowns.prefix, (id .. " " .. cooldown), "WHISPER", UnitName("player"))
	--@end-debug@]===]
	--@non-debug@
	RaidCooldowns:SendCommMessage(RaidCooldowns.prefix, (id .. " " .. cooldown), "RAID")
	--@end-non-debug@
end

function base:ScanSpells()
	if self.canScanCooldowns == false then return end
	
	local cooldown
	for k, v in pairs(self.cooldowns) do
		cooldown = self:GetCooldown(k)
		-- Sync if the cooldown is 0 so we can stop bars that are no longer on
		-- cooldown, like after a respec, or if it's a cooldown greater than 2,
		-- meaning this isn't the global cooldown and it's a length worth syncing
		if cooldown == 0 or cooldown > 2 then
			self:Sync(v, cooldown)
		end
	end
	
	self.canScanCooldowns = false
end

RaidCooldowns.ModuleBase = base