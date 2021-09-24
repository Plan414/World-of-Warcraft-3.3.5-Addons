assert(RaidCooldowns, "RaidCooldowns not found!")

--[[
	["Localized Spell Name"] = {
		id = 12345, -- Spell ID
		cd = 123,   -- Spell's cooldown, in seconds
		ora = x,    -- Spell's oRA sync id, if available
	}
]]

local hero = (UnitFactionGroup("player") == "Alliance") and 32182 or 2825
local cooldowns = {
	["DEATHKNIGHT"] = {
		[GetSpellInfo(51052)] = { id = 51052, cd = 120 },           -- Anti-magic Zone
		[GetSpellInfo(49222)] = { id = 49222, cd = 120 },           -- Bone Shield
		[GetSpellInfo(49576)] = { id = 49576, cd = 35 },            -- Death Grip
		[GetSpellInfo(48792)] = { id = 48792, cd = 60 },            -- Icebound Fortitude
		[GetSpellInfo(49039)] = { id = 49039, cd = 180 },           -- Lichborne
		[GetSpellInfo(47528)] = { id = 47528, cd = 10 },            -- Mind Freeze
	},
	["DRUID"] = {
		[GetSpellInfo(22812)] = { id = 22812, cd = 60 },            -- Barkskin
		[GetSpellInfo(5209)]  = { id = 5209,  cd = 180 },           -- Challenging Roar
		[GetSpellInfo(29166)] = { id = 29166, cd = 180 },           -- Innervate
		[GetSpellInfo(17116)] = { id = 17116, cd = 180 },           -- Nature's Swiftness
		[GetSpellInfo(48477)] = { id = 48477, cd = 600, ora = 1 },  -- Rebirth
		[GetSpellInfo(48447)] = { id = 48447, cd = 480 },           -- Tranquility
	},
	["HUNTER"] = {
		[GetSpellInfo(5384)]  = { id = 5384,  cd = 30 },            -- Feign Death
		[GetSpellInfo(34477)] = { id = 34477, cd = 30 },            -- Misdirection
	},
	["MAGE"] = {
		[GetSpellInfo(2139)]  = { id = 2139,  cd = 24 },            -- Counterspell
		[GetSpellInfo(45438)] = { id = 45438, cd = 300 },           -- Ice Block
	},
	["PALADIN"] = {
		[GetSpellInfo(19752)] = { id = 19752, cd = 600, ora = 4 },  -- Divine Intervention
		[GetSpellInfo(498)]   = { id = 498,   cd = 180 },           -- Divine Protection
		[GetSpellInfo(64205)] = { id = 64205, cd = 120 },           -- Divine Sacrifice
		[GetSpellInfo(642)]   = { id = 642,   cd = 300 },           -- Divine Shield
		[GetSpellInfo(10278)] = { id = 10278, cd = 300 },           -- Hand of Protection
		[GetSpellInfo(48788)] = { id = 48788, cd = 1200 },          -- Lay on Hands
		[GetSpellInfo(31821)] = { id = 31821, cd = 120 },			-- Aura Mastery
		[GetSpellInfo(6940)]  = { id = 6940, cd = 120 },			-- Hand of Sacrifice
		[GetSpellInfo(1038)]  = { id = 1038, cd = 120 },			-- Hand of Salvation
	},
	["PRIEST"] = {
		[GetSpellInfo(64843)] = { id = 64843, cd = 480 },           -- Divine Hymn
		[GetSpellInfo(6346)]  = { id = 6346,  cd = 180 },           -- Fear Ward
		[GetSpellInfo(47788)] = { id = 47788, cd = 180 },           -- Guardian Spirit
		[GetSpellInfo(64901)] = { id = 64901, cd = 360 },           -- Hymn of Hope
		[GetSpellInfo(33206)] = { id = 33206, cd = 144 },           -- Pain Suppression
		--[===[@debug@
		--[GetSpellInfo(48066)] = { id = 48066, cd = 4 },             -- Power Word: Shield (Debug)
		--@end-debug@]===]
	},
	["ROGUE"] = {
		[GetSpellInfo(31224)] = { id = 31224, cd = 90 },            -- Cloak of Shadows
		[GetSpellInfo(1725)]  = { id = 1725,  cd = 30 },            -- Distract
		[GetSpellInfo(1766)]  = { id = 1766,  cd = 10 },            -- Kick
	},
	["SHAMAN"] = {
		[GetSpellInfo(hero)]  = { id = hero,  cd = 300 },           -- Bloodlust/Heroism
		[GetSpellInfo(57994)] = { id = 57994, cd = 6 },            	-- Wind Shear
		[GetSpellInfo(51514)] = { id = 51514, cd = 45 },            -- Hex
		[GetSpellInfo(16190)] = { id = 16190, cd = 300 },           -- Mana Tide Totem
		[GetSpellInfo(16188)] = { id = 16188, cd = 180 },           -- Nature's Swiftness
		[GetSpellInfo(20608)] = { id = 20608, cd = 1800, ora = 2 }, -- Reincarnation
	},
	["WARLOCK"] = {
		[GetSpellInfo(29858)] = { id = 29858, cd = 300 },           -- Soulshatter
		[GetSpellInfo(47883)] = { id = 47883, cd = 900, ora = 3 },  -- Soulstone Resurrection
	},
	["WARRIOR"] = {
		[GetSpellInfo(1161)]  = { id = 1161,  cd = 180 },           -- Challenging Shout
		[GetSpellInfo(12975)] = { id = 12975, cd = 180 },           -- Last Stand
		[GetSpellInfo(6554)]  = { id = 6554,  cd = 10 },            -- Pummel
		[GetSpellInfo(72)]    = { id = 72,    cd = 12 },            -- Shield Bash
		[GetSpellInfo(871)]   = { id = 871,   cd = 300 },           -- Shield Wall
	},
}

RaidCooldowns.cooldowns = cooldowns
