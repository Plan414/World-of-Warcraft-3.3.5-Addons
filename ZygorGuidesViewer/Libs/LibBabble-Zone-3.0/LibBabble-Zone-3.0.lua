--[[
Name: LibBabble-Zone-3.0
Revision: $Rev: 135 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Description: A library to provide localizations for zones.
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "LibBabble-Zone-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 135 $"):match("%d+"))

-- #AUTODOC_NAMESPACE prototype

local GAME_LOCALE = GetLocale()
do
	-- LibBabble-Core-3.0 is hereby placed in the Public Domain
	-- Credits: ckknight
	local LIBBABBLE_MAJOR, LIBBABBLE_MINOR = "LibBabble-3.0", 2

	local LibBabble = LibStub:NewLibrary(LIBBABBLE_MAJOR, LIBBABBLE_MINOR)
	if LibBabble then
		local data = LibBabble.data or {}
		for k,v in pairs(LibBabble) do
			LibBabble[k] = nil
		end
		LibBabble.data = data

		local tablesToDB = {}
		for namespace, db in pairs(data) do
			for k,v in pairs(db) do
				tablesToDB[v] = db
			end
		end

		local function warn(message)
			local _, ret = pcall(error, message, 3)
			geterrorhandler()(ret)
		end

		local lookup_mt = { __index = function(self, key)
			local db = tablesToDB[self]
			local current_key = db.current[key]
			if current_key then
				self[key] = current_key
				return current_key
			end
			local base_key = db.base[key]
			local real_MAJOR_VERSION
			for k,v in pairs(data) do
				if v == db then
					real_MAJOR_VERSION = k
					break
				end
			end
			if not real_MAJOR_VERSION then
				real_MAJOR_VERSION = LIBBABBLE_MAJOR
			end
			if base_key then
				warn(("%s: Translation %q not found for locale %q"):format(real_MAJOR_VERSION, key, GAME_LOCALE))
				rawset(self, key, base_key)
				return base_key
			end
			warn(("%s: Translation %q not found."):format(real_MAJOR_VERSION, key))
			rawset(self, key, key)
			return key
		end }

		local function initLookup(module, lookup)
			local db = tablesToDB[module]
			for k in pairs(lookup) do
				lookup[k] = nil
			end
			setmetatable(lookup, lookup_mt)
			tablesToDB[lookup] = db
			db.lookup = lookup
			return lookup
		end

		local function initReverse(module, reverse)
			local db = tablesToDB[module]
			for k in pairs(reverse) do
				reverse[k] = nil
			end
			for k,v in pairs(db.current) do
				reverse[v] = k
			end
			tablesToDB[reverse] = db
			db.reverse = reverse
			db.reverseIterators = nil
			return reverse
		end

		local prototype = {}
		local prototype_mt = {__index = prototype}

		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will warn but allow the code to pass through.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local BL = B:GetLookupTable()
			assert(BL["Some english word"] == "Some localized word")
			DoSomething(BL["Some english word that doesn't exist"]) -- warning!
		-----------------------------------------------------------------------------]]
		function prototype:GetLookupTable()
			local db = tablesToDB[self]

			local lookup = db.lookup
			if lookup then
				return lookup
			end
			return initLookup(self, {})
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local B_has = B:GetUnstrictLookupTable()
			assert(B_has["Some english word"] == "Some localized word")
			assert(B_has["Some english word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetUnstrictLookupTable()
			local db = tablesToDB[self]

			return db.current
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
			* This is useful for checking if the base (English) table has a key, even if the localized one does not have it registered.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local B_hasBase = B:GetBaseLookupTable()
			assert(B_hasBase["Some english word"] == "Some english word")
			assert(B_hasBase["Some english word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetBaseLookupTable()
			local db = tablesToDB[self]

			return db.base
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
			* This will return only one English word that it maps to, if there are more than one to check, see :GetReverseIterator("word")
		Returns:
			A lookup table for localized to english words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local BR = B:GetReverseLookupTable()
			assert(BR["Some localized word"] == "Some english word")
			assert(BR["Some localized word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetReverseLookupTable()
			local db = tablesToDB[self]

			local reverse = db.reverse
			if reverse then
				return reverse
			end
			return initReverse(self, {})
		end
		local blank = {}
		local weakVal = {__mode='v'}
		--[[---------------------------------------------------------------------------
		Arguments:
			string - the localized word to chek for.
		Returns:
			An iterator to traverse all English words that map to the given key
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			for word in B:GetReverseIterator("Some localized word") do
				DoSomething(word)
			end
		-----------------------------------------------------------------------------]]
		function prototype:GetReverseIterator(key)
			local db = tablesToDB[self]
			local reverseIterators = db.reverseIterators
			if not reverseIterators then
				reverseIterators = setmetatable({}, weakVal)
				db.reverseIterators = reverseIterators
			elseif reverseIterators[key] then
				return pairs(reverseIterators[key])
			end
			local t
			for k,v in pairs(db.current) do
				if v == key then
					if not t then
						t = {}
					end
					t[k] = true
				end
			end
			reverseIterators[key] = t or blank
			return pairs(reverseIterators[key])
		end
		--[[---------------------------------------------------------------------------
		Returns:
			An iterator to traverse all translations English to localized.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			for english, localized in B:Iterate() do
				DoSomething(english, localized)
			end
		-----------------------------------------------------------------------------]]
		function prototype:Iterate()
			local db = tablesToDB[self]

			return pairs(db.current)
		end

		-- #NODOC
		-- modules need to call this to set the base table
		function prototype:SetBaseTranslations(base)
			local db = tablesToDB[self]
			local oldBase = db.base
			if oldBase then
				for k in pairs(oldBase) do
					oldBase[k] = nil
				end
				for k, v in pairs(base) do
					oldBase[k] = v
				end
				base = oldBase
			else
				db.base = base
			end
			for k,v in pairs(base) do
				if v == true then
					base[k] = k
				end
			end
		end

		local function init(module)
			local db = tablesToDB[module]
			if db.lookup then
				initLookup(module, db.lookup)
			end
			if db.reverse then
				initReverse(module, db.reverse)
			end
			db.reverseIterators = nil
		end

		-- #NODOC
		-- modules need to call this to set the current table. if current is true, use the base table.
		function prototype:SetCurrentTranslations(current)
			local db = tablesToDB[self]
			if current == true then
				db.current = db.base
			else
				local oldCurrent = db.current
				if oldCurrent then
					for k in pairs(oldCurrent) do
						oldCurrent[k] = nil
					end
					for k, v in pairs(current) do
						oldCurrent[k] = v
					end
					current = oldCurrent
				else
					db.current = current
				end
			end
			init(self)
		end

		for namespace, db in pairs(data) do
			setmetatable(db.module, prototype_mt)
			init(db.module)
		end

		-- #NODOC
		-- modules need to call this to create a new namespace.
		function LibBabble:New(namespace, minor)
			local module, oldminor = LibStub:NewLibrary(namespace, minor)
			if not module then
				return
			end

			if not oldminor then
				local db = {
					module = module,
				}
				data[namespace] = db
				tablesToDB[module] = db
			else
				for k,v in pairs(module) do
					module[k] = nil
				end
			end

			setmetatable(module, prototype_mt)

			return module
		end
	end
end

local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then
	return
end

lib:SetBaseTranslations {
	["Azeroth"] = true,
	["Eastern Kingdoms"] = true,
	["Kalimdor"] = true,
	["Northrend"] = true,
	["Outland"] = true,
	["Cosmic map"] = true,

	["Ahn'Qiraj"] = true,
	["Alterac Mountains"] = true,
	["Alterac Valley"] = true,
	["Arathi Basin"] = true,
	["Arathi Highlands"] = true,
	["Ashenvale"] = true,
	["Auberdine"] = true,
	["Azshara"] = true,
	["Badlands"] = true,
	["The Barrens"] = true,
	["Blackfathom Deeps"] = true,
	["Blackrock Depths"] = true,
	["Blackrock Mountain"] = true,
	["Blackrock Spire"] = true,
	["Blackwing Lair"] = true,
	["Blasted Lands"] = true,
	["Booty Bay"] = true,
	["Burning Steppes"] = true,
	["Darkshore"] = true,
	["Darnassus"] = true,
	["The Deadmines"] = true,
	["Deadwind Pass"] = true,
	["Deeprun Tram"] = true,
	["Desolace"] = true,
	["Dire Maul"] = true,
	["Dire Maul (East)"] = true,
	["Dire Maul (West)"] = true,
	["Dire Maul (North)"] = true,
	["Dun Morogh"] = true,
	["Durotar"] = true,
	["Duskwood"] = true,
	["Dustwallow Marsh"] = true,
	["Eastern Plaguelands"] = true,
	["Elwynn Forest"] = true,
	["Everlook"] = true,
	["Felwood"] = true,
	["Feralas"] = true,
	["The Forbidding Sea"] = true,
	["Gadgetzan"] = true,
	["Gates of Ahn'Qiraj"] = true,
	["Gnomeregan"] = true,
	["The Great Sea"] = true,
	["Grom'gol Base Camp"] = true,
	["Hall of Legends"] = true,
	["Hillsbrad Foothills"] = true,
	["The Hinterlands"] = true,
	["Hyjal"] = true,
	["Hyjal Summit"] = true,
	["Ironforge"] = true,
	["Loch Modan"] = true,
	["Lower Blackrock Spire"] = true,
	["Maraudon"] = true,
	["Menethil Harbor"] = true,
	["Molten Core"] = true,
	["Moonglade"] = true,
	["Mulgore"] = true,
	["Naxxramas"] = true,
	["Onyxia's Lair"] = true,
	["Orgrimmar"] = true,
	["Ratchet"] = true,
	["Ragefire Chasm"] = true,
	["Razorfen Downs"] = true,
	["Razorfen Kraul"] = true,
	["Redridge Mountains"] = true,
	["Ruins of Ahn'Qiraj"] = true,
	["Scarlet Monastery"] = true,
	["Scholomance"] = true,
	["Searing Gorge"] = true,
	["Shadowfang Keep"] = true,
	["Silithus"] = true,
	["Silverpine Forest"] = true,
	["The Stockade"] = true,
	["Stonard"] = true,
	["Stonetalon Mountains"] = true,
	["Stormwind City"] = true,
	["Stormwind"] = true,
	["Stranglethorn Vale"] = true,
	["Stratholme"] = true,
	["Swamp of Sorrows"] = true,
	["Tanaris"] = true,
	["Teldrassil"] = true,
	["Temple of Ahn'Qiraj"] = true,
	["The Temple of Atal'Hakkar"] = true,
	["Theramore Isle"] = true,
	["Thousand Needles"] = true,
	["Thunder Bluff"] = true,
	["Tirisfal Glades"] = true,
	["Uldaman"] = true,
	["Un'Goro Crater"] = true,
	["Undercity"] = true,
	["Upper Blackrock Spire"] = true,
	["Wailing Caverns"] = true,
	["Warsong Gulch"] = true,
	["Western Plaguelands"] = true,
	["Westfall"] = true,
	["Wetlands"] = true,
	["Winterspring"] = true,
	["Zul'Farrak"] = true,
	["Zul'Gurub"] = true,

	["Champions' Hall"] = true,
	["Hall of Champions"] = true,
	["Blade's Edge Arena"] = true,
	["Nagrand Arena"] = true,
	["Ruins of Lordaeron"] = true,
	["Twisting Nether"] = true,
	["The Veiled Sea"] = true,
	["The North Sea"] = true,
	["Armory"] = true,
	["Library"] = true,
	["Cathedral"] = true,
	["Graveyard"] = true,

	-- Burning Crusade

	-- Subzones used for displaying instances.
	["Plaguewood"] = true,
	["Hellfire Citadel"] = true,
	["Auchindoun"] = true,
	["The Bone Wastes"] = true, -- Substitute for Auchindoun, since this is what shows on the minimap.
	["Ring of Observance"] = true,
	["Coilfang Reservoir"] = true,
	["Amani Pass"] = true,

	["Azuremyst Isle"] = true,
	["Bloodmyst Isle"] = true,
	["Eversong Woods"] = true,
	["Ghostlands"] = true,
	["The Exodar"] = true,
	["Silvermoon City"] = true,
	["Shadowmoon Valley"] = true,
	["Black Temple"] = true,
	["Terokkar Forest"] = true,
	["Auchenai Crypts"] = true,
	["Mana-Tombs"] = true,
	["Shadow Labyrinth"] = true,
	["Sethekk Halls"] = true,
	["Hellfire Peninsula"] = true,
	["The Dark Portal"] = true,
	["Hellfire Ramparts"] = true,
	["The Blood Furnace"] = true,
	["The Shattered Halls"] = true,
	["Magtheridon's Lair"] = true,
	["Nagrand"] = true,
	["Zangarmarsh"] = true,
	["The Slave Pens"] = true,
	["The Underbog"] = true,
	["The Steamvault"] = true,
	["Serpentshrine Cavern"] = true,
	["Blade's Edge Mountains"] = true,
	["Gruul's Lair"] = true,
	["Netherstorm"] = true,
	["Tempest Keep"] = true,
	["The Mechanar"] = true,
	["The Botanica"] = true,
	["The Arcatraz"] = true,
	["The Eye"] = true,
	["Eye of the Storm"] = true,
	["Shattrath City"] = true,
	["Shattrath"] = true,
	["Karazhan"] = true,
	["Caverns of Time"] = true,
	["Old Hillsbrad Foothills"] = true,
	["The Black Morass"] = true,
	["Night Elf Village"] = true,
	["Horde Encampment"] = true,
	["Alliance Base"] = true,
	["Zul'Aman"] = true,
	["Quel'thalas"] = true,
	["Isle of Quel'Danas"] = true,
	["Sunwell Plateau"] = true,
	["Magisters' Terrace"] = true,

	-- Blade's Edge Plateau
	["Forge Camp: Terror"] = true,
	["Vortex Pinnacle"] = true,
	["Rivendark's Perch"] = true,
	["Ogri'la"] = true,
	["Obsidia's Perch"] = true,
	["Skyguard Outpost"] = true,
	["Shartuul's Transporter"] = true,
	["Forge Camp: Wrath"] = true,
	["Bash'ir Landing"] = true,
	["Crystal Spine"] = true,
	["Insidion's Perch"] = true,
	["Furywing's Perch"] = true,

	["Tirisfal"] = true,
	["Sunken Temple"] = true,

	-- WRATH OF THE LICH KING
	-- Zones
	["Borean Tundra"] = true,
	["Crystalsong Forest"] = true,
	["Dalaran"] = true,
	["Dragonblight"] = true,
	["Grizzly Hills"] = true,
	["Howling Fjord"] = true,
	["Icecrown"] = true,
	["Sholazar Basin"] = true,
	["The Storm Peaks"] = true,
	["Wintergrasp"] = true,
	["Zul'Drak"] = true,
	["The Frozen Sea"] = true,

	-- Instances (and subzones used for displaying these instances)
	["Ahn'kahet: The Old Kingdom"] = true,
	["Azjol-Nerub"] = true,
	["Coldarra"] = true,
	["The Culling of Stratholme"] = true,
	["Drak'Tharon Keep"] = true,
	["The Eye of Eternity"] = true,
	["Gundrak"] = true,
	["Halls of Lightning"] = true,
	["Halls of Stone"] = true,
	["The Nexus"] = true,
	["The Obsidian Sanctum"] = true,
	["The Oculus"] = true,
	["Ulduar"] = true,
	["Utgarde Keep"] = true,
	["Utgarde Pinnacle"] = true,
	["The Violet Hold"] = true,
	["Wyrmrest Temple"] = true,
	["Old Stratholme"] = true,
	["Icecrown Citadel"] = true,

	-- PvP Instances
	["Dalaran Sewers"] = true,
	["The Ring of Valor"] = true,
	["Strand of the Ancients"] = true,

	-- Special Zones
	["Plaguelands: The Scarlet Enclave"] = true,
}

if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "Azeroth",
		["Eastern Kingdoms"] = "Östliche Königreiche",
		["Kalimdor"] = "Kalimdor",
		["Northrend"] = "Nordend",
		["Outland"] = "Scherbenwelt",
		["Cosmic map"] = "Kosmische Karte",

		["Ahn'Qiraj"] = "Ahn'Qiraj",
		["Alterac Mountains"] = "Alteracgebirge",
		["Alterac Valley"] = "Alteractal",
		["Arathi Basin"] = "Arathibecken",
		["Arathi Highlands"] = "Arathihochland",
		["Ashenvale"] = "Eschental",
		["Auberdine"] = "Auberdine",
		["Azshara"] = "Azshara",
		["Badlands"] = "Ödland",
		["The Barrens"] = "Brachland",
		["Blackfathom Deeps"] = "Tiefschwarze Grotte",
		["Blackrock Depths"] = "Schwarzfelstiefen",
		["Blackrock Mountain"] = "Der Schwarzfels",
		["Blackrock Spire"] = "Schwarzfelsspitze",
		["Blackwing Lair"] = "Pechschwingenhort",
		["Blasted Lands"] = "Verwüstete Lande",
		["Booty Bay"] = "Beutebucht",
		["Burning Steppes"] = "Brennende Steppe",
		["Darkshore"] = "Dunkelküste",
		["Darnassus"] = "Darnassus",
		["The Deadmines"] = "Die Todesminen",
		["Deadwind Pass"] = "Gebirgspass der Totenwinde",
		["Deeprun Tram"] = "Die Tiefenbahn",
		["Desolace"] = "Desolace",
		["Dire Maul"] = "Düsterbruch",
		["Dire Maul (North)"] = "Düsterbruch (Nord)",
		["Dire Maul (East)"] = "Düsterbruch (Ost)",
		["Dire Maul (West)"] = "Düsterbruch (West)",
		["Dun Morogh"] = "Dun Morogh",
		["Durotar"] = "Durotar",
		["Duskwood"] = "Dämmerwald",
		["Dustwallow Marsh"] = "Düstermarschen",
		["Eastern Plaguelands"] = "Östliche Pestländer",
		["Elwynn Forest"] = "Wald von Elwynn",
		["Everlook"] = "Ewige Warte",
		["Felwood"] = "Teufelswald",
		["Feralas"] = "Feralas",
		["The Forbidding Sea"] = "Das verbotene Meer",
		["Gadgetzan"] = "Gadgetzan",
		["Gates of Ahn'Qiraj"] = "Tore von Ahn'Qiraj",
		["Gnomeregan"] = "Gnomeregan",
		["Grom'gol Base Camp"] = "Basislager von Grom'gol",
		["The Great Sea"] = "Das große Meer",
		["Hall of Legends"] = "Halle der Legenden",
		["Hillsbrad Foothills"] = "Vorgebirge des Hügellands",
		["The Hinterlands"] = "Hinterland",
		["Hyjal"] = "Hyjal",
		["Hyjal Summit"] = "Hyjalgipfel",
		["Ironforge"] = "Eisenschmiede",
		["Loch Modan"] = "Loch Modan",
		["Lower Blackrock Spire"] = "Untere Schwarzfelsspitze",
		["Maraudon"] = "Maraudon",
		["Menethil Harbor"] = "Hafen von Menethil",
		["Molten Core"] = "Geschmolzener Kern",
		["Moonglade"] = "Mondlichtung",
		["Mulgore"] = "Mulgore",
		["Naxxramas"] = "Naxxramas",
		["Onyxia's Lair"] = "Onyxias Hort",
		["Orgrimmar"] = "Orgrimmar",
		["Ratchet"] = "Ratschet",
		["Ragefire Chasm"] = "Der Flammenschlund",
		["Razorfen Downs"] = "Hügel der Klingenhauer",
		["Razorfen Kraul"] = "Kral der Klingenhauer",
		["Redridge Mountains"] = "Rotkammgebirge",
		["Ruins of Ahn'Qiraj"] = "Ruinen von Ahn'Qiraj",
		["Scarlet Monastery"] = "Das Scharlachrote Kloster",
		["Scholomance"] = "Scholomance",
		["Searing Gorge"] = "Sengende Schlucht",
		["Shadowfang Keep"] = "Burg Schattenfang",
		["Silithus"] = "Silithus",
		["Silverpine Forest"] = "Silberwald",
		["The Stockade"] = "Das Verlies",
		["Stonard"] = "Steinard",
		["Stonetalon Mountains"] = "Steinkrallengebirge",
		["Stormwind City"] = "Sturmwind",
		["Stormwind"] = "Sturmwind",
		["Stranglethorn Vale"] = "Schlingendorntal",
		["Stratholme"] = "Stratholme",
		["Swamp of Sorrows"] = "Sümpfe des Elends",
		["Tanaris"] = "Tanaris",
		["Teldrassil"] = "Teldrassil",
		["Temple of Ahn'Qiraj"] = "Tempel von Ahn'Qiraj",
		["The Temple of Atal'Hakkar"] = "Der Tempel von Atal'Hakkar",
		["Theramore Isle"] = "Insel Theramore",
		["Thousand Needles"] = "Tausend Nadeln",
		["Thunder Bluff"] = "Donnerfels",
		["Tirisfal Glades"] = "Tirisfal",
		["Uldaman"] = "Uldaman",
		["Un'Goro Crater"] = "Krater von Un'Goro",
		["Undercity"] = "Unterstadt",
		["Upper Blackrock Spire"] = "Obere Schwarzfelsspitze",
		["Wailing Caverns"] = "Die Höhlen des Wehklagens",
		["Warsong Gulch"] = "Kriegshymnenschlucht",
		["Western Plaguelands"] = "Westliche Pestländer",
		["Westfall"] = "Westfall",
		["Wetlands"] = "Sumpfland",
		["Winterspring"] = "Winterquell",
		["Zul'Farrak"] = "Zul'Farrak",
		["Zul'Gurub"] = "Zul'Gurub",

		["Champions' Hall"] = "Halle der Champions",
		["Hall of Champions"] = "Halle der Champions",
		["Blade's Edge Arena"] = "Arena des Schergrats",
		["Nagrand Arena"] = "Arena von Nagrand",
		["Ruins of Lordaeron"] = "Ruinen von Lordaeron",
		["Twisting Nether"] = "Wirbelnder Nether",
		["The Veiled Sea"] = "Das verhüllte Meer",
		["The North Sea"] = "Das nördliche Meer",
		["Armory"] = "Waffenkammer",
		["Library"] = "Bibliothek",
		["Cathedral"] = "Kathedrale",
		["Graveyard"] = "Friedhof",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "Seuchenwald",
		["Hellfire Citadel"] = "Höllenfeuerzitadelle",
		["Auchindoun"] = "Auchindoun",
		["The Bone Wastes"] = "Die Knochenwüste", -- Substitute for Auchindoun, since this is what shows on the minimap.
		["Ring of Observance"] = "Ring der Beobachtung",
		["Coilfang Reservoir"] = "Der Echsenkessel",
		["Amani Pass"] = "Amanipass",

		["Azuremyst Isle"] = "Azurmythosinsel",
		["Bloodmyst Isle"] = "Blutmythosinsel",
		["Eversong Woods"] = "Immersangwald",
		["Ghostlands"] = "Geisterlande",
		["The Exodar"] = "Die Exodar",
		["Silvermoon City"] = "Silbermond",
		["Shadowmoon Valley"] = "Schattenmondtal",
		["Black Temple"] = "Der Schwarze Tempel",
		["Terokkar Forest"] = "Wälder von Terokkar",
		["Auchenai Crypts"] = "Auchenaikrypta",
		["Mana-Tombs"] = "Managruft",
		["Shadow Labyrinth"] = "Schattenlabyrinth",
		["Sethekk Halls"] = "Sethekkhallen",
		["Hellfire Peninsula"] = "Höllenfeuerhalbinsel",
		["The Dark Portal"] = "Das Dunkle Portal",
		["Hellfire Ramparts"] = "Höllenfeuerbollwerk",
		["The Blood Furnace"] = "Der Blutkessel",
		["The Shattered Halls"] = "Die zerschmetterten Hallen",
		["Magtheridon's Lair"] = "Magtheridons Kammer",
		["Nagrand"] = "Nagrand",
		["Zangarmarsh"] = "Zangarmarschen",
		["The Slave Pens"] = "Die Sklavenunterkünfte",
		["The Underbog"] = "Der Tiefensumpf",
		["The Steamvault"] = "Die Dampfkammer",
		["Serpentshrine Cavern"] = "Höhle des Schlangenschreins",
		["Blade's Edge Mountains"] = "Schergrat",
		["Gruul's Lair"] = "Gruuls Unterschlupf",
		["Netherstorm"] = "Nethersturm",
		["Tempest Keep"] = "Festung der Stürme",
		["The Mechanar"] = "Die Mechanar",
		["The Botanica"] = "Die Botanika",
		["The Arcatraz"] = "Die Arkatraz",
		["The Eye"] = "Das Auge",
		["Eye of the Storm"] = "Auge des Sturms",
		["Shattrath City"] = "Shattrath",
		["Shattrath"] = "Shattrath",
		["Karazhan"] = "Karazhan",
		["Caverns of Time"] = "Die Höhlen der Zeit",
		["Old Hillsbrad Foothills"] = "Vorgebirge des Alten Hügellands",
		["The Black Morass"] = "Der schwarze Morast",
		["Night Elf Village"] = "Nachtelfen Dorf",
		["Horde Encampment"] = "Lager der Horde",
		["Alliance Base"] = "Basis der Allianz",
		["Zul'Aman"] = "Zul'Aman",
		["Quel'thalas"] = "Quel'Thalas",
		["Isle of Quel'Danas"] = "Insel von Quel'Danas",
		["Sunwell Plateau"] = "Sonnenbrunnenplateau",
		["Magisters' Terrace"] = "Terrasse der Magister",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "",
		["Vortex Pinnacle"] = "",
		["Rivendark's Perch"] = "",
		["Ogri'la"] = "",
		["Obsidia's Perch"] = "",
		["Skyguard Outpost"] = "",
		["Shartuul's Transporter"] = "",
		["Forge Camp: Wrath"] = "",
		["Bash'ir Landing"] = "",
		["Crystal Spine"] = "",
		["Insidion's Perch"] = "",
		["Furywing's Perch"] = "",

		["Tirisfal"] = "Tirisfal",
		["Sunken Temple"] = "Versunkener Tempel",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "Boreanische Tundra",
		["Crystalsong Forest"] = "Kristallsangwald",
		["Dalaran"] = "Dalaran",
		["Dragonblight"] = "Drachenöde",
		["Grizzly Hills"] = "Grizzlyhügel",
		["Howling Fjord"] = "Der heulende Fjord",
		["Icecrown"] = "Eiskrone",
		["Sholazar Basin"] = "Sholazarbecken",
		["The Storm Peaks"] = "Die Sturmgipfel",
		["Wintergrasp"] = "Tausendwinter",
		["Zul'Drak"] = "Zul'Drak",
	    ["The Frozen Sea"] = "The Frozen Sea",

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "Ahn'kahet - Das alte Königreich",
		["Azjol-Nerub"] = "Azjol-Nerub",
		["Coldarra"] = "Coldarra",
		["The Culling of Stratholme"] = "Ausmerzung in Stratholme",
		["Drak'Tharon Keep"] = "Feste Drak'Tharon",
		["The Eye of Eternity"] = "Das Auge der Ewigkeit",
		["Gundrak"] = "Gun'Drak",
		["Halls of Lightning"] = "Die Hallen der Blitze",
		["Halls of Stone"] = "Die Hallen des Steins",
		["The Nexus"] = "Der Nexus",
		["The Obsidian Sanctum"] = "Das Obsidian Heiligtum",
		["The Oculus"] = "Das Oculus",
		["Ulduar"] = "Ulduar",
		["Utgarde Keep"] = "Burg Utgarde",
		["Utgarde Pinnacle"] = "Turm Utgarde",
		["The Violet Hold"] = "Die Violette Festung",
		["Wyrmrest Temple"] = "Wyrmruhtempel",

-- PvP Instances
		["Dalaran Sewers"] = "Dalaran Kanalisation",
		["The Ring of Valor"] = "Der Ring des Mutes",
		["Strand of the Ancients"] = "Strand der Uralten",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = "Pestländer: Die Scharlachrote Enklave",
	}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "Azeroth",
		["Eastern Kingdoms"] = "Royaumes de l'est",
		["Kalimdor"] = "Kalimdor",
		["Northrend"] = "Norfendre",
		["Outland"] = "Outreterre",
		["Cosmic map"] = "Carte cosmique",

		["Ahn'Qiraj"] = "Ahn'Qiraj",
		["Alterac Mountains"] = "Montagnes d'Alterac",
		["Alterac Valley"] = "Vallée d'Alterac",
		["Arathi Basin"] = "Bassin d'Arathi",
		["Arathi Highlands"] = "Hautes-terres d'Arathi",
		["Ashenvale"] = "Orneval",
		["Auberdine"] = "Auberdine",
		["Azshara"] = "Azshara",
		["Badlands"] = "Terres ingrates",
		["The Barrens"] = "Les Tarides",
		["Blackfathom Deeps"] = "Profondeurs de Brassenoire",
		["Blackrock Depths"] = "Profondeurs de Rochenoire",
		["Blackrock Mountain"] = "Mont Rochenoire",
		["Blackrock Spire"] = "Pic Rochenoire",
		["Blackwing Lair"] = "Repaire de l'Aile noire",
		["Blasted Lands"] = "Terres foudroyées",
		["Booty Bay"] = "Baie-du-Butin",
		["Burning Steppes"] = "Steppes ardentes",
		["Darkshore"] = "Sombrivage",
		["Darnassus"] = "Darnassus",
		["The Deadmines"] = "Les Mortemines",
		["Deadwind Pass"] = "Défilé de Deuillevent",
		["Deeprun Tram"] = "Tram des profondeurs",
		["Desolace"] = "Désolace",
		["Dire Maul"] = "Hache-tripes",
		["Dire Maul (East)"] = "Hache-tripes (Est)",
		["Dire Maul (West)"] = "Hache-tripes (Ouest)",
		["Dire Maul (North)"] = "Hache-tripes (Nord)",
		["Dun Morogh"] = "Dun Morogh",
		["Durotar"] = "Durotar",
		["Duskwood"] = "Bois de la Pénombre",
		["Dustwallow Marsh"] = "Marécage d'Âprefange",
		["Eastern Plaguelands"] = "Maleterres de l'est",
		["Elwynn Forest"] = "Forêt d'Elwynn",
		["Everlook"] = "Long-guet",
		["Felwood"] = "Gangrebois",
		["Feralas"] = "Féralas",
		["The Forbidding Sea"] = "La Mer interdite",
		["Gadgetzan"] = "Gadgetzan",
		["Gates of Ahn'Qiraj"] = "Portes d'Ahn'Qiraj",
		["Gnomeregan"] = "Gnomeregan",
		["Grom'gol Base Camp"] = "Campement Grom'gol",
		["The Great Sea"] = "La Grande mer",
		["Hall of Legends"] = "Hall des Légendes",
		["Hillsbrad Foothills"] = "Contreforts de Hautebrande",
		["The Hinterlands"] = "Les Hinterlands",
		["Hyjal"] = "Hyjal",
		["Hyjal Summit"] = "Sommet d'Hyjal",
		["Ironforge"] = "Forgefer",
		["Loch Modan"] = "Loch Modan",
		["Lower Blackrock Spire"] = "Pic de Rochenoire inférieur",
		["Maraudon"] = "Maraudon",
		["Menethil Harbor"] = "Port de Menethil",
		["Molten Core"] = "Cœur du Magma",
		["Moonglade"] = "Reflet-de-Lune",
		["Mulgore"] = "Mulgore",
		["Onyxia's Lair"] = "Repaire d'Onyxia",
		["Naxxramas"] = "Naxxramas",
		["Orgrimmar"] = "Orgrimmar",
		["Ratchet"] = "Cabestan",
		["Ragefire Chasm"] = "Gouffre de Ragefeu",
		["Razorfen Downs"] = "Souilles de Tranchebauge",
		["Razorfen Kraul"] = "Kraal de Tranchebauge",
		["Redridge Mountains"] = "Les Carmines",
		["Ruins of Ahn'Qiraj"] = "Ruines d'Ahn'Qiraj",
		["Scarlet Monastery"] = "Monastère écarlate",
		["Scholomance"] = "Scholomance",
		["Searing Gorge"] = "Gorge des Vents brûlants",
		["Shadowfang Keep"] = "Donjon d'Ombrecroc",
		["Silithus"] = "Silithus",
		["Silverpine Forest"] = "Forêt des Pins argentés",
		["The Stockade"] = "La Prison",
		["Stonard"] = "Pierrêche",
		["Stonetalon Mountains"] = "Les Serres-Rocheuses",
		["Stormwind City"] = "Cité de Hurlevent",
		["Stormwind"] = "Hurlevent",
		["Stranglethorn Vale"] = "Vallée de Strangleronce",
		["Stratholme"] = "Stratholme",
		["Swamp of Sorrows"] = "Marais des Chagrins",
		["Tanaris"] = "Tanaris",
		["Teldrassil"] = "Teldrassil",
		["Temple of Ahn'Qiraj"] = "Le temple d'Ahn'Qiraj",
		["The Temple of Atal'Hakkar"] = "Le temple d'Atal'Hakkar",
		["Theramore Isle"] = "Île de Theramore",
		["Thousand Needles"] = "Mille pointes",
		["Thunder Bluff"] = "Les Pitons du Tonnerre",
		["Tirisfal Glades"] = "Clairières de Tirisfal",
		["Uldaman"] = "Uldaman",
		["Un'Goro Crater"] = "Cratère d'Un'Goro",
		["Undercity"] = "Fossoyeuse",
		["Upper Blackrock Spire"] = "Pic de Rochenoire supérieur",
		["Wailing Caverns"] = "Cavernes des lamentations",
		["Warsong Gulch"] = "Goulet des Chanteguerres",
		["Western Plaguelands"] = "Maleterres de l'ouest",
		["Westfall"] = "Marche de l'Ouest",
		["Wetlands"] = "Les Paluns",
		["Winterspring"] = "Berceau-de-l'Hiver",
		["Zul'Farrak"] = "Zul'Farrak",
		["Zul'Gurub"] = "Zul'Gurub",

		["Champions' Hall"] = "Hall des Champions",
		["Hall of Champions"] = "Hall des Champions",
		["Blade's Edge Arena"] = "Arène des Tranchantes",
		["Nagrand Arena"] = "Arène de Nagrand",
		["Ruins of Lordaeron"] = "Ruines de Lordaeron",
		["Twisting Nether"] = "Le Néant distordu",
		["The Veiled Sea"] = "La Mer voilée",
		["The North Sea"] = "La mer Boréale",
		["Armory"] = "Armurerie",
		["Library"] = "Bibliothèque",
		["Cathedral"] = "Cathédrale",
		["Graveyard"] = "Cimetière",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "Pestebois",
		["Hellfire Citadel"] = "Citadelle des Flammes infernales",
		["Auchindoun"] = "Auchindoun",
		["The Bone Wastes"] = "Le désert des Ossements", -- Substitute for Auchindoun, since this is what shows on the minimap.
		["Ring of Observance"] = "Cercle d'observance",
		["Coilfang Reservoir"] = "Réservoir de Glissecroc",
		["Amani Pass"] = "Passage des Amani",

		["Azuremyst Isle"] = "Île de Brume-azur",
		["Bloodmyst Isle"] = "Île de Brume-sang",
		["Eversong Woods"] = "Bois des Chants éternels",
		["Ghostlands"] = "Les Terres fantômes",
		["The Exodar"] = "L'Exodar",
		["Silvermoon City"] = "Lune-d'argent",
		["Shadowmoon Valley"] = "Vallée d'Ombrelune",
		["Black Temple"] = "Temple noir",
		["Terokkar Forest"] = "Forêt de Terokkar",
		["Auchenai Crypts"] = "Cryptes Auchenaï",
		["Mana-Tombs"] = "Tombes-mana",
		["Shadow Labyrinth"] = "Labyrinthe des ombres",
		["Sethekk Halls"] = "Les salles des Sethekk",
		["Hellfire Peninsula"] = "Péninsule des Flammes infernales",
		["The Dark Portal"] = "La Porte des ténèbres",
		["Hellfire Ramparts"] = "Remparts des Flammes infernales",
		["The Blood Furnace"] = "La Fournaise du sang",
		["The Shattered Halls"] = "Les Salles brisées",
		["Magtheridon's Lair"] = "Le repaire de Magtheridon",
		["Nagrand"] = "Nagrand",
		["Zangarmarsh"] = "Marécage de Zangar",
		["The Slave Pens"] = "Les enclos aux esclaves",
		["The Underbog"] = "La Basse-tourbière",
		["The Steamvault"] = "Le Caveau de la vapeur",
		["Serpentshrine Cavern"] = "Caverne du sanctuaire du Serpent",
		["Blade's Edge Mountains"] = "Les Tranchantes",
		["Gruul's Lair"] = "Repaire de Gruul",
		["Netherstorm"] = "Raz-de-Néant",
		["Tempest Keep"] = "Donjon de la Tempête",
		["The Mechanar"] = "Le Méchanar",
		["The Botanica"] = "La Botanica",
		["The Arcatraz"] = "L'Arcatraz",
		["The Eye"] = "L'Œil",
		["Eye of the Storm"] = "L'Œil du cyclone",
		["Shattrath City"] = "Shattrath",
		["Shattrath"] = "Shattrath",
		["Karazhan"] = "Karazhan",
		["Caverns of Time"] = "Grottes du temps",
		["Old Hillsbrad Foothills"] = "Contreforts de Hautebrande d'antan",
		["The Black Morass"] = "Le Noir Marécage",
		["Night Elf Village"] = "Village elfe de la nuit",
		["Horde Encampment"] = "Campement de la Horde",
		["Alliance Base"] = "Base de l'Alliance",
		["Zul'Aman"] = "Zul'Aman",
		["Quel'thalas"] = "Quel'thalas",
		["Isle of Quel'Danas"] = "Île de Quel'Danas",
		["Sunwell Plateau"] = "Plateau du Puits de soleil",
		["Magisters' Terrace"] = "Terrasse des Magistères",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "Camp de forge : Terreur",
		["Vortex Pinnacle"] = "Cime du vortex",
		["Rivendark's Perch"] = "Perchoir de Clivenuit",
		["Ogri'la"] = "Ogri'la",
		["Obsidia's Perch"] = "Perchoir d'Obsidia",
		["Skyguard Outpost"] = "Avant-poste de la Garde-ciel",
		["Shartuul's Transporter"] = "Transporteur de Shartuul",
		["Forge Camp: Wrath"] = "Camp de forge : Courroux",
		["Bash'ir Landing"] = "Point d'ancrage de Bash'ir",
		["Crystal Spine"] = "Éperon de cristal",
		["Insidion's Perch"] = "Perchoir d'Insidion",
		["Furywing's Perch"] = "Perchoir d'Aile-furie",

		["Tirisfal"] = "Tirisfal",
		["Sunken Temple"] = "Temple englouti",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "Toundra Boréenne",
		["Crystalsong Forest"] = "Forêt du Chant de cristal",
		["Dalaran"] = "Dalaran",
		["Dragonblight"] = "Désolation des dragons",
		["Grizzly Hills"] = "Les Grisonnes",
		["Howling Fjord"] = "Fjord Hurlant",
		["Icecrown"] = "La Couronne de glace",
		["Sholazar Basin"] = "Bassin de Sholazar",
		["The Storm Peaks"] = "Les pics Foudroyés",
		["Wintergrasp"] = "Joug-d'hiver",
		["Zul'Drak"] = "Zul'Drak",
		["The Frozen Sea"] = "La mer Gelée",

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "Ahn'kahet : l'Ancien royaume",
		["Azjol-Nerub"] = "Azjol-Nérub",
		["Coldarra"] = "Frimarra",
		["The Culling of Stratholme"] = "L'épuration de Stratholme",
		["Drak'Tharon Keep"] = "Donjon de Drak'Tharon",
		["The Eye of Eternity"] = "L'Œil d'Eternité",
		["Gundrak"] = "Gundrak",
		["Halls of Lightning"] = "Les salles de Foudre",
		["Halls of Stone"] = "Les salles de Pierre",
		["The Nexus"] = "Le Nexus",
		["The Obsidian Sanctum"] = "Le sanctum Obsidien",
		["The Oculus"] = "L'Oculus",
		["Ulduar"] = "Ulduar",
		["Utgarde Keep"] = "Donjon d'Utgarde",
		["Utgarde Pinnacle"] = "Cime d'Utgarde",
		["The Violet Hold"] = "Le Fort pourpre",
		["Wyrmrest Temple"] = "Temple du Repos du ver",
		["Old Stratholme"] = true, -- à traduire
		["Icecrown Citadel"] = "Citadelle de la Couronne de glace",

-- PvP Instances
		["Dalaran Sewers"] = "Égouts de Dalaran",
		["The Ring of Valor"] = "L'Arène des valeureux",
		["Strand of the Ancients"] = "Rivage des anciens",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = "Maleterres : l'enclave Écarlate",
	}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "艾泽拉斯",
		["Eastern Kingdoms"] = "东部王国",
		["Kalimdor"] = "卡利姆多",
		["Northrend"] = "诺森德",
		["Outland"] = "外域",
		["Cosmic map"] = "全部地图",

		["Ahn'Qiraj"] = "安其拉",
		["Alterac Mountains"] = "奥特兰克山脉",
		["Alterac Valley"] = "奥特兰克山谷",
		["Arathi Basin"] = "阿拉希盆地",
		["Arathi Highlands"] = "阿拉希高地",
		["Ashenvale"] = "灰谷",
		["Auberdine"] = "奥伯丁",
		["Azshara"] = "艾萨拉",
		["Badlands"] = "荒芜之地",
		["The Barrens"] = "贫瘠之地",
		["Blackfathom Deeps"] = "黑暗深渊",
		["Blackrock Depths"] = "黑石深渊",
		["Blackrock Mountain"] = "黑石山",
		["Blackrock Spire"] = "黑石塔",
		["Blackwing Lair"] = "黑翼之巢",
		["Blasted Lands"] = "诅咒之地",
		["Booty Bay"] = "藏宝海湾",
		["Burning Steppes"] = "燃烧平原",
		["Darkshore"] = "黑海岸",
		["Darnassus"] = "达纳苏斯",
		["The Deadmines"] = "死亡矿井",
		["Deadwind Pass"] = "逆风小径",
		["Deeprun Tram"] = "矿道地铁",
		["Desolace"] = "凄凉之地",
		["Dire Maul"] = "厄运之槌",
		["Dire Maul (East)"] = "厄运之槌 (东)",
		["Dire Maul (West)"] = "厄运之槌 (西)",
		["Dire Maul (North)"] = "厄运之槌 (北)",
		["Dun Morogh"] = "丹莫罗",
		["Durotar"] = "杜隆塔尔",
		["Duskwood"] = "暮色森林",
		["Dustwallow Marsh"] = "尘泥沼泽",
		["Eastern Plaguelands"] = "东瘟疫之地",
		["Elwynn Forest"] = "艾尔文森林",
		["Everlook"] = "永望镇",
		["Felwood"] = "费伍德森林",
		["Feralas"] = "菲拉斯",
		["The Forbidding Sea"] = "禁忌之海",
		["Gadgetzan"] = "加基森",
		["Gates of Ahn'Qiraj"] = "安其拉之门",
		["Gnomeregan"] = "诺莫瑞根",
		["The Great Sea"] = "无尽之海",
		["Grom'gol Base Camp"] = "格罗姆高营地",
		["Hall of Legends"] = "传说大厅",
		["Hillsbrad Foothills"] = "希尔斯布莱德丘陵",
		["The Hinterlands"] = "辛特兰",
		["Hyjal"] = "海加尔山",
		["Hyjal Summit"] = "海加尔峰",
		["Ironforge"] = "铁炉堡",
		["Loch Modan"] = "洛克莫丹",
		["Lower Blackrock Spire"] = "黑石塔 (下层)",
		["Maraudon"] = "玛拉顿",
		["Menethil Harbor"] = "米奈希尔港",
		["Molten Core"] = "熔火之心",
		["Moonglade"] = "月光林地",
		["Mulgore"] = "莫高雷",
		["Naxxramas"] = "纳克萨玛斯",
		["Onyxia's Lair"] = "奥妮克希亚的巢穴",
		["Orgrimmar"] = "奥格瑞玛",
		["Ratchet"] = "棘齿城",
		["Ragefire Chasm"] = "怒焰裂谷",
		["Razorfen Downs"] = "剃刀高地",
		["Razorfen Kraul"] = "剃刀沼泽",
		["Redridge Mountains"] = "赤脊山",
		["Ruins of Ahn'Qiraj"] = "安其拉废墟",
		["Scarlet Monastery"] = "血色修道院",
		["Scholomance"] = "通灵学院",
		["Searing Gorge"] = "灼热峡谷",
		["Shadowfang Keep"] = "影牙城堡",
		["Silithus"] = "希利苏斯",
		["Silverpine Forest"] = "银松森林",
		["The Stockade"] = "监狱",
		["Stonard"] = "斯通纳德",
		["Stonetalon Mountains"] = "石爪山脉",
		["Stormwind City"] = "暴风城",
		["Stormwind"] = "暴风城",--TaxiNodesDBC
		["Stranglethorn Vale"] = "荆棘谷",
		["Stratholme"] = "斯坦索姆",
		["Swamp of Sorrows"] = "悲伤沼泽",
		["Tanaris"] = "塔纳利斯",
		["Teldrassil"] = "泰达希尔",
		["Temple of Ahn'Qiraj"] = "安其拉神殿",
		["The Temple of Atal'Hakkar"] = "阿塔哈卡神庙",
		["Theramore Isle"] = "塞拉摩岛",
		["Thousand Needles"] = "千针石林",
		["Thunder Bluff"] = "雷霆崖",
		["Tirisfal Glades"] = "提瑞斯法林地",
		["Uldaman"] = "奥达曼",
		["Un'Goro Crater"] = "安戈洛环形山",
		["Undercity"] = "幽暗城",
		["Upper Blackrock Spire"] = "黑石塔 (上层)",
		["Wailing Caverns"] = "哀嚎洞穴",
		["Warsong Gulch"] = "战歌峡谷",
		["Western Plaguelands"] = "西瘟疫之地",
		["Westfall"] = "西部荒野",
		["Wetlands"] = "湿地",
		["Winterspring"] = "冬泉谷",
		["Zul'Farrak"] = "祖尔法拉克",
		["Zul'Gurub"] = "祖尔格拉布",

		["Champions' Hall"] = "勇士大厅",
		["Hall of Champions"] = "勇士大厅",--WMOAreaTableDBC
		["Blade's Edge Arena"] = "刀锋山竞技场",
		["Nagrand Arena"] = "纳格兰竞技场",
		["Ruins of Lordaeron"] = "洛丹伦废墟",
		["Twisting Nether"] = "扭曲虚空",
		["The Veiled Sea"] = "迷雾之海",
		["The North Sea"] = "北海",
		["Armory"] = "军械库",
		["Library"] = "图书馆",
		["Cathedral"] = "教堂",
		["Graveyard"] = "墓地",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "病木林",
		["Hellfire Citadel"] = "地狱火堡垒",
		["Auchindoun"] = "奥金顿",
		["The Bone Wastes"] = "白骨荒野",
		["Ring of Observance"] = "仪式广场",
		["Coilfang Reservoir"] = "盘牙水库",
		["Amani Pass"] = "阿曼尼小径",

		["Azuremyst Isle"] = "秘蓝岛",
		["Bloodmyst Isle"] = "秘血岛",
		["Eversong Woods"] = "永歌森林",
		["Ghostlands"] = "幽魂之地",
		["The Exodar"] = "埃索达",
		["Silvermoon City"] = "银月城",
		["Shadowmoon Valley"] = "影月谷",
		["Black Temple"] = "黑暗神殿",
		["Terokkar Forest"] = "泰罗卡森林",
		["Auchenai Crypts"] = "奥金尼地穴",
		["Mana-Tombs"] = "法力陵墓",
		["Shadow Labyrinth"] = "暗影迷宫",
		["Sethekk Halls"] = "塞泰克大厅",
		["Hellfire Peninsula"] = "地狱火半岛",
		["The Dark Portal"] = "黑暗之门",
		["Hellfire Ramparts"] = "地狱火城墙",
		["The Blood Furnace"] = "鲜血熔炉",
		["The Shattered Halls"] = "破碎大厅",
		["Magtheridon's Lair"] = "玛瑟里顿的巢穴",
		["Nagrand"] = "纳格兰",
		["Zangarmarsh"] = "赞加沼泽",
		["The Slave Pens"] = "奴隶围栏",
		["The Underbog"] = "幽暗沼泽",
		["The Steamvault"] = "蒸汽地窟",
		["Serpentshrine Cavern"] = "毒蛇神殿",
		["Blade's Edge Mountains"] = "刀锋山",
		["Gruul's Lair"] = "格鲁尔的巢穴",
		["Netherstorm"] = "虚空风暴",
		["Tempest Keep"] = "风暴要塞",
		["The Mechanar"] = "能源舰",
		["The Botanica"] = "生态船",
		["The Arcatraz"] = "禁魔监狱",
		["The Eye"] = "风暴要塞",
		["Eye of the Storm"] = "风暴之眼",
		["Shattrath City"] = "沙塔斯城",
		["Shattrath"] = "沙塔斯",--TaxiNodesDBC
		["Karazhan"] = "卡拉赞",
		["Caverns of Time"] = "时光之穴",
		["Old Hillsbrad Foothills"] = "旧希尔斯布莱德丘陵",
		["The Black Morass"] = "黑色沼泽",
		["Night Elf Village"] = "暗夜精灵村庄",
		["Horde Encampment"] = "部落营地",
		["Alliance Base"] = "联盟基地",
		["Zul'Aman"] = "祖阿曼",
		["Quel'thalas"] = "奎尔萨拉斯",
		["Isle of Quel'Danas"] = "奎尔丹纳斯岛",
		["Sunwell Plateau"] = "太阳之井高地",
		["Magisters' Terrace"] = "魔导师平台",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "铸魔营地：恐怖",
		["Vortex Pinnacle"] = "漩涡峰",
		["Rivendark's Perch"] = "雷文达克栖木",
		["Ogri'la"] = "奥格瑞拉",
		["Obsidia's Perch"] = "欧比斯迪栖木",
		["Skyguard Outpost"] = "天空卫队哨站",
		["Shartuul's Transporter"] = "沙图尔的传送器",
		["Forge Camp: Wrath"] = "铸魔营地：天罚",
		["Bash'ir Landing"] = "巴什伊尔码头",
		["Crystal Spine"] = "水晶之脊",
		["Insidion's Perch"] = "因斯迪安栖木",
		["Furywing's Perch"] = "弗雷文栖木",

		["Tirisfal"] = "提里斯法林地",--TaxiNodesDBC
		["Sunken Temple"] = "沉没的神庙",--AreaTableDBC

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "北风苔原",
		["Crystalsong Forest"] = "晶歌森林",
		["Dalaran"] = "达拉然",
		["Dragonblight"] = "龙骨荒野",
		["Grizzly Hills"] = "灰熊丘陵",
		["Howling Fjord"] = "嚎风峡湾",
		["Icecrown"] = "冰冠冰川",
		["Sholazar Basin"] = "索拉查盆地",
		["The Storm Peaks"] = "风暴峭壁",
		["Wintergrasp"] = "冬拥湖",
		["Zul'Drak"] = "祖达克",
		["The Frozen Sea"] = "冰冻之海",
		
	-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "安卡雷：古代王国",
		["Azjol-Nerub"] = "艾卓-尼鲁布",
		["Coldarra"] = "考达拉",
		["The Culling of Stratholme"] = "净化斯坦索姆",
		["Drak'Tharon Keep"] = "达克萨隆要塞",
		["The Eye of Eternity"] = "永恒之眼",
		["Gundrak"] = "古达克",
		["Halls of Lightning"] = "闪电大厅",
		["Halls of Stone"] = "岩石大厅",
		["The Nexus"] = "魔枢",
		["The Obsidian Sanctum"] = "黑曜石圣殿",
		["The Oculus"] = "魔环",
		["Ulduar"] = "奥杜尔", 
		["Utgarde Keep"] = "乌特加德城堡",
		["Utgarde Pinnacle"] = "乌特加德之巅",
		["The Violet Hold"] = "紫罗兰监狱",
		["Wyrmrest Temple"] = "龙眠神殿",
		["Old Stratholme"] = "旧斯坦索姆",
		["Icecrown Citadel"] = "冰冠堡垒",

	-- PvP Instances
		["Dalaran Sewers"] = "达拉然下水道",
		["The Ring of Valor"] = "勇气竞技场",
		["Strand of the Ancients"] = "远古海滩",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = true,
	}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "艾澤拉斯",
		["Eastern Kingdoms"] = "東部王國",
		["Kalimdor"] = "卡林多",
		["Northrend"] = "北裂境",
		["Outland"] = "外域",
		["Cosmic map"] = "宇宙地圖",

		["Ahn'Qiraj"] = "安其拉",
		["Alterac Mountains"] = "奧特蘭克山脈",
		["Alterac Valley"] = "奧特蘭克山谷",
		["Arathi Basin"] = "阿拉希盆地",
		["Arathi Highlands"] = "阿拉希高地",
		["Ashenvale"] = "梣谷",
		["Auberdine"] = "奧伯丁",
		["Azshara"] = "艾薩拉",
		["Badlands"] = "荒蕪之地",
		["The Barrens"] = "貧瘠之地",
		["Blackfathom Deeps"] = "黑暗深淵",
		["Blackrock Depths"] = "黑石深淵",
		["Blackrock Mountain"] = "黑石山",
		["Blackrock Spire"] = "黑石塔",
		["Blackwing Lair"] = "黑翼之巢",
		["Blasted Lands"] = "詛咒之地",
		["Booty Bay"] = "藏寶海灣",
		["Burning Steppes"] = "燃燒平原",
		["Darkshore"] = "黑海岸",
		["Darnassus"] = "達納蘇斯",
		["The Deadmines"] = "死亡礦坑",
		["Deadwind Pass"] = "逆風小徑",
		["Deeprun Tram"] = "礦道地鐵",
		["Desolace"] = "淒涼之地",
		["Dire Maul"] = "厄運之槌",
		["Dire Maul (East)"] = "厄運之槌 - 東",
		["Dire Maul (West)"] = "厄運之槌 - 西",
		["Dire Maul (North)"] = "厄運之槌 - 北",
		["Dun Morogh"] = "丹莫洛",
		["Durotar"] = "杜洛塔",
		["Duskwood"] = "暮色森林",
		["Dustwallow Marsh"] = "塵泥沼澤",
		["Eastern Plaguelands"] = "東瘟疫之地",
		["Elwynn Forest"] = "艾爾文森林",
		["Everlook"] = "永望鎮",
		["Felwood"] = "費伍德森林",
		["Feralas"] = "菲拉斯",
		["The Forbidding Sea"] = "禁忌之海",
		["Gadgetzan"] = "加基森",
		["Gates of Ahn'Qiraj"] = "安其拉之門",
		["Gnomeregan"] = "諾姆瑞根",
		["The Great Sea"] = "無盡之海",
		["Grom'gol Base Camp"] = "格羅姆高營地",
		["Hall of Legends"] = "傳說大廳",
		["Hillsbrad Foothills"] = "希爾斯布萊德丘陵",
		["The Hinterlands"] = "辛特蘭",
		["Hyjal"] = "海加爾山",
		["Hyjal Summit"] = "海加爾山",
		["Ironforge"] = "鐵爐堡",
		["Loch Modan"] = "洛克莫丹",
		["Lower Blackrock Spire"] = "低階黑石塔",
		["Maraudon"] = "瑪拉頓",
		["Menethil Harbor"] = "米奈希爾港",
		["Molten Core"] = "熔火之心",
		["Moonglade"] = "月光林地",
		["Mulgore"] = "莫高雷",
		["Naxxramas"] = "納克薩瑪斯",
		["Onyxia's Lair"] = "奧妮克希亞的巢穴",
		["Orgrimmar"] = "奧格瑪",
		["Ratchet"] = "棘齒城",
		["Ragefire Chasm"] = "怒焰裂谷",
		["Razorfen Downs"] = "剃刀高地",
		["Razorfen Kraul"] = "剃刀沼澤",
		["Redridge Mountains"] = "赤脊山",
		["Ruins of Ahn'Qiraj"] = "安其拉廢墟",
		["Scarlet Monastery"] = "血色修道院",
		["Scholomance"] = "通靈學院",
		["Searing Gorge"] = "灼熱峽谷",
		["Shadowfang Keep"] = "影牙城堡",
		["Silithus"] = "希利蘇斯",
		["Silverpine Forest"] = "銀松森林",
		["The Stockade"] = "監獄",
		["Stonard"] = "斯通納德",
		["Stonetalon Mountains"] = "石爪山脈",
		["Stormwind City"] = "暴風城",
		["Stormwind"] = "暴風城",
		["Stranglethorn Vale"] = "荊棘谷",
		["Stratholme"] = "斯坦索姆",
		["Swamp of Sorrows"] = "悲傷沼澤",
		["Tanaris"] = "塔納利斯",
		["Teldrassil"] = "泰達希爾",
		["Temple of Ahn'Qiraj"] = "安其拉神廟",
		["The Temple of Atal'Hakkar"] = "阿塔哈卡神廟",
		["Theramore Isle"] = "塞拉摩島",
		["Thousand Needles"] = "千針石林",
		["Thunder Bluff"] = "雷霆崖",
		["Tirisfal Glades"] = "提里斯法林地",
		["Uldaman"] = "奧達曼",
		["Un'Goro Crater"] = "安戈洛環形山",
		["Undercity"] = "幽暗城",
		["Upper Blackrock Spire"] = "高階黑石塔",
		["Wailing Caverns"] = "哀嚎洞穴",
		["Warsong Gulch"] = "戰歌峽谷",
		["Western Plaguelands"] = "西瘟疫之地",
		["Westfall"] = "西部荒野",
		["Wetlands"] = "濕地",
		["Winterspring"] = "冬泉谷",
		["Zul'Farrak"] = "祖爾法拉克",
		["Zul'Gurub"] = "祖爾格拉布",

		["Champions' Hall"] = "勇士大廳",
		["Hall of Champions"] = "勇士大廳",
		["Blade's Edge Arena"] = "劍刃競技場",
		["Nagrand Arena"] = "納葛蘭競技場",
		["Ruins of Lordaeron"] = "羅德隆廢墟",
		["Twisting Nether"] = "扭曲虛空",
		["The Veiled Sea"] = "迷霧之海",
		["The North Sea"] = "北方海岸",
		["Armory"] = "軍械庫",
		["Library"] = "圖書館",
		["Cathedral"] = "教堂",
		["Graveyard"] = "墓地",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "病木林",
		["Hellfire Citadel"] = "地獄火堡壘",
		["Auchindoun"] = "奧齊頓",
		["The Bone Wastes"] = "白骨荒野", -- Substitute for Auchindoun, since this is what shows on the minimap.
		["Ring of Observance"] = "儀式競技場",
		["Coilfang Reservoir"] = "盤牙洞穴",
		["Amani Pass"] = "阿曼尼小俓",

		["Azuremyst Isle"] = "藍謎島",
		["Bloodmyst Isle"] = "血謎島",
		["Eversong Woods"] = "永歌森林",
		["Ghostlands"] = "鬼魂之地",
		["The Exodar"] = "艾克索達",
		["Silvermoon City"] = "銀月城",
		["Shadowmoon Valley"] = "影月谷",
		["Black Temple"] = "黑暗神廟",
		["Terokkar Forest"] = "泰洛卡森林",
		["Auchenai Crypts"] = "奧奇奈地穴",
		["Mana-Tombs"] = "法力墓地",
		["Shadow Labyrinth"] = "暗影迷宮",
		["Sethekk Halls"] = "塞司克大廳",
		["Hellfire Peninsula"] = "地獄火半島",
		["The Dark Portal"] = "黑暗之門",
		["Hellfire Ramparts"] = "地獄火壁壘",
		["The Blood Furnace"] = "血熔爐",
		["The Shattered Halls"] = "破碎大廳",
		["Magtheridon's Lair"] = "瑪瑟里頓的巢穴",
		["Nagrand"] = "納葛蘭",
		["Zangarmarsh"] = "贊格沼澤",
		["The Slave Pens"] = "奴隸監獄",
		["The Underbog"] = "深幽泥沼",
		["The Steamvault"] = "蒸汽洞窟",
		["Serpentshrine Cavern"] = "毒蛇神殿洞穴",
		["Blade's Edge Mountains"] = "劍刃山脈",
		["Gruul's Lair"] = "戈魯爾之巢",
		["Netherstorm"] = "虛空風暴",
		["Tempest Keep"] = "風暴要塞",
		["The Mechanar"] = "麥克納爾",
		["The Botanica"] = "波塔尼卡",
		["The Arcatraz"] = "亞克崔茲",
		["The Eye"] = "風暴要塞",
		["Eye of the Storm"] = "暴風之眼",
		["Shattrath City"] = "撒塔斯城",
		["Shattrath"] = "撒塔斯城",
		["Karazhan"] = "卡拉贊",
		["Caverns of Time"] = "時光之穴",
		["Old Hillsbrad Foothills"] = "希爾斯布萊德丘陵舊址",
		["The Black Morass"] = "黑色沼澤",
		["Night Elf Village"] = "夜精靈村",
		["Horde Encampment"] = "部落營地",
		["Alliance Base"] = "聯盟營地",
		["Zul'Aman"] = "祖阿曼",
		["Quel'thalas"] = "奎爾薩拉斯",
		["Isle of Quel'Danas"] = "奎爾達納斯之島",
		["Sunwell Plateau"] = "太陽之井高地",
		["Magisters' Terrace"] = "博學者殿堂",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "煉冶場:驚駭",
		["Vortex Pinnacle"] = "漩渦尖塔",
		["Rivendark's Perch"] = "瑞文達科棲所",
		["Ogri'la"] = "歐格利拉",
		["Obsidia's Perch"] = "歐比希迪亞棲所",
		["Skyguard Outpost"] = "禦天者崗哨",
		["Shartuul's Transporter"] = "夏圖歐的傳送門",
		["Forge Camp: Wrath"] = "煉冶場:憤怒",
		["Bash'ir Landing"] = "貝許爾平臺",
		["Crystal Spine"] = "水晶背脊",
		["Insidion's Perch"] = "印希迪恩棲所",
		["Furywing's Perch"] = "狂怒之翼棲所",

		["Tirisfal"] = "提里斯法林地",
		["Sunken Temple"] = "沉沒的神廟",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "北風凍原",
		["Crystalsong Forest"] = "水晶之歌森林",
		["Dalaran"] = "達拉然",
		["Dragonblight"] = "龍骨荒野",
		["Grizzly Hills"] = "灰白之丘",
		["Howling Fjord"] = "凜風峽灣",
		["Icecrown"] = "寒冰皇冠",
		["Sholazar Basin"] = "休拉薩盆地",
		["The Storm Peaks"] = "風暴群山",
		["Wintergrasp"] = "冬握湖",
		["Zul'Drak"] = "祖爾德拉克",
		["The Frozen Sea"] = "冰凍之海",

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "安卡罕特:古王國",
		["Azjol-Nerub"] = "阿茲歐-奈幽",
		["Coldarra"] = "凜懼島",
		["The Culling of Stratholme"] = "斯坦索姆的抉擇",
		["Drak'Tharon Keep"] = "德拉克薩隆要塞",
		["The Eye of Eternity"] = "永恆之眼",
		["Gundrak"] = "剛德拉克",
		["Halls of Lightning"] = "雷光大廳",
		["Halls of Stone"] = "石之大廳",
		["The Nexus"] = "奧核之心",
		["The Obsidian Sanctum"] = "黑曜聖所",
		["The Oculus"] = "奧核之眼",
		["Ulduar"] = "奧杜亞",
		["Utgarde Keep"] = "俄特加德要塞",
		["Utgarde Pinnacle"] = "俄特加德之巔",
		["The Violet Hold"] = "紫羅蘭堡",
		["Wyrmrest Temple"] = "龍族神殿",
		["Old Stratholme"] = "舊斯坦索姆",
		["Icecrown Citadel"] = "冰冠城塞",

-- PvP Instances
		["Dalaran Sewers"] = "達拉然下水道",
		["The Ring of Valor"] = "勇武之環",
		["Strand of the Ancients"] = "遠祖灘頭",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = true,
	}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "아제로스",
		["Eastern Kingdoms"] = "동부 왕국",
		["Kalimdor"] = "칼림도어",
		["Northrend"] = "노스렌드",
		["Outland"] = "아웃랜드",
		["Cosmic map"] = "세계 지도",

		["Ahn'Qiraj"] = "안퀴라즈",
		["Alterac Mountains"] = "알터랙 산맥",
		["Alterac Valley"] = "알터랙 계곡",
		["Arathi Basin"] = "아라시 분지",
		["Arathi Highlands"] = "아라시 고원",
		["Ashenvale"] = "잿빛 골짜기",
		["Auberdine"] = "아우버다인",
		["Azshara"] = "아즈샤라",
		["Badlands"] = "황야의 땅",
		["The Barrens"] = "불모의 땅",
		["Blackfathom Deeps"] = "검은심연의 나락",
		["Blackrock Depths"] = "검은바위 나락",
		["Blackrock Mountain"] = "검은바위 산",
		["Blackrock Spire"] = "검은바위 첨탑",
		["Blackwing Lair"] = "검은날개 둥지",
		["Blasted Lands"] = "저주받은 땅",
		["Booty Bay"] = "무법항",
		["Burning Steppes"] = "불타는 평원",
		["Darkshore"] = "어둠의 해안",
		["Darnassus"] = "다르나서스",
		["The Deadmines"] = "죽음의 폐광",
		["Deadwind Pass"] = "죽음의 고개",
		["Deeprun Tram"] = "깊은굴 지하철",
		["Desolace"] = "잊혀진 땅",
		["Dire Maul"] = "혈투의 전장",
		["Dire Maul (East)"] = "혈투의 전장 동부",
		["Dire Maul (West)"] = "혈투의 전장 서부",
		["Dire Maul (North)"] = "혈투의 전장 북부",
		["Dun Morogh"] = "던 모로",
		["Durotar"] = "듀로타",
		["Duskwood"] = "그늘숲",
		["Dustwallow Marsh"] = "먼지진흙 습지대",
		["Eastern Plaguelands"] = "동부 역병지대",
		["Elwynn Forest"] = "엘윈 숲",
		["Everlook"] = "눈망루 마을",
		["Felwood"] = "악령의 숲",
		["Feralas"] = "페랄라스",
		["The Forbidding Sea"] = "성난폭풍 해안",
		["Gadgetzan"] = "가젯잔",
		["Gates of Ahn'Qiraj"] = "안퀴라즈 성문",
		["Gnomeregan"] = "놈리건",
		["The Great Sea"] = "대해",
		["Grom'gol Base Camp"] = "그롬골 주둔지",
		["Hall of Legends"] = "전설의 전당",
		["Hillsbrad Foothills"] = "힐스브래드 구릉지",
		["The Hinterlands"] = "동부 내륙지",
		["Hyjal"] = "하이잘",
		["Hyjal Summit"] = "하이잘 정상",
		["Ironforge"] = "아이언포지",
		["Loch Modan"] = "모단 호수",
		["Lower Blackrock Spire"] = "검은바위 첨탑 하층",
		["Maraudon"] = "마라우돈",
		["Menethil Harbor"] = "메네실 항구",
		["Molten Core"] = "화산 심장부",
		["Moonglade"] = "달의 숲",
		["Mulgore"] = "멀고어",
		["Naxxramas"] = "낙스라마스",
		["Onyxia's Lair"] = "오닉시아의 둥지",
		["Orgrimmar"] = "오그리마",
		["Ratchet"] = "톱니항",
		["Ragefire Chasm"] = "성난불길 협곡",
		["Razorfen Downs"] = "가시덩굴 구릉",
		["Razorfen Kraul"] = "가시덩굴 우리",
		["Redridge Mountains"] = "붉은마루 산맥",
		["Ruins of Ahn'Qiraj"] = "안퀴라즈 폐허",
		["Scarlet Monastery"] = "붉은십자군 수도원",
		["Scholomance"] = "스칼로맨스",
		["Searing Gorge"] = "이글거리는 협곡",
		["Shadowfang Keep"] = "그림자송곳니 성채",
		["Silithus"] = "실리더스",
		["Silverpine Forest"] = "은빛소나무 숲",
		["The Stockade"] = "스톰윈드 지하감옥",
		["Stonard"] = "스토나드",
		["Stonetalon Mountains"] = "돌발톱 산맥",
		["Stormwind City"] = "스톰윈드",
		["Stormwind"] = "스톰윈드",
		["Stranglethorn Vale"] = "가시덤불 골짜기",
		["Stratholme"] = "스트라솔름",
		["Swamp of Sorrows"] = "슬픔의 늪",
		["Tanaris"] = "타나리스",
		["Teldrassil"] = "텔드랏실",
		["Temple of Ahn'Qiraj"] = "안퀴라즈 사원",
		["The Temple of Atal'Hakkar"] = "아탈학카르 신전",
		["Theramore Isle"] = "테라모어 섬",
		["Thousand Needles"] = "버섯구름 봉우리",
		["Thunder Bluff"] = "썬더 블러프",
		["Tirisfal Glades"] = "티리스팔 숲",
		["Uldaman"] = "울다만",
		["Un'Goro Crater"] = "운고로 분화구",
		["Undercity"] = "언더시티",
		["Upper Blackrock Spire"] = "검은바위 첨탑 상층",
		["Wailing Caverns"] = "통곡의 동굴",
		["Warsong Gulch"] = "전쟁노래 협곡",
		["Western Plaguelands"] = "서부 역병지대",
		["Westfall"] = "서부 몰락지대",
		["Wetlands"] = "저습지",
		["Winterspring"] = "여명의 설원",
		["Zul'Farrak"] = "줄파락",
		["Zul'Gurub"] = "줄구룹",

		["Champions' Hall"] = "용사의 전당",
		["Hall of Champions"] = "용사의 전당",
		["Blade's Edge Arena"] = "칼날 투기장",
		["Nagrand Arena"] = "나그란드 투기장",
		["Ruins of Lordaeron"] = "로데론의 폐허",
		["Twisting Nether"] = "뒤틀린 황천",
		["The Veiled Sea"] = "장막의 바다",
		["The North Sea"] = "북해", -- check
		["Armory"] = "무기고",
		["Library"] = "도서관",
		["Cathedral"] = "대성당",
		["Graveyard"] = "묘지",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "역병의 숲",
		["Hellfire Citadel"] = "지옥불 성채",
		["Auchindoun"] = "아킨둔",
		["The Bone Wastes"] = "해골 무덤", -- Substitute for Auchindoun, since this is what shows on the minimap.
		["Ring of Observance"] = "규율의 광장",
		["Coilfang Reservoir"] = "갈퀴송곳니 저수지",
		["Amani Pass"] = "아마니 고개",

		["Azuremyst Isle"] = "하늘안개 섬",
		["Bloodmyst Isle"] = "핏빛안개 섬",
		["Eversong Woods"] = "영원노래 숲",
		["Ghostlands"] = "유령의 땅",
		["The Exodar"] = "엑소다르",
		["Silvermoon City"] = "실버문",
		["Shadowmoon Valley"] = "어둠달 골짜기",
		["Black Temple"] = "검은 사원",
		["Terokkar Forest"] = "테로카르 숲",
		["Auchenai Crypts"] = "아키나이 납골당",
		["Mana-Tombs"] = "마나 무덤",
		["Shadow Labyrinth"] = "어둠의 미궁",
		["Sethekk Halls"] = "세데크 전당",
		["Hellfire Peninsula"] = "지옥불 반도",
		["The Dark Portal"] = "어둠의 문",
		["Hellfire Ramparts"] = "지옥불 성루",
		["The Blood Furnace"] = "피의 용광로",
		["The Shattered Halls"] = "으스러진 손의 전당",
		["Magtheridon's Lair"] = "마그테리돈의 둥지",
		["Nagrand"] = "나그란드",
		["Zangarmarsh"] = "장가르 습지대",
		["The Slave Pens"] = "강제 노역소",
		["The Underbog"] = "지하수렁",
		["The Steamvault"] = "증기 저장고",
		["Serpentshrine Cavern"] = "불뱀 제단",
		["Blade's Edge Mountains"] = "칼날 산맥",
		["Gruul's Lair"] = "그룰의 둥지",
		["Netherstorm"] = "황천의 폭풍",
		["Tempest Keep"] = "폭풍우 요새",
		["The Mechanar"] = "메카나르",
		["The Botanica"] = "신록의 정원",
		["The Arcatraz"] = "알카트라즈",
		["The Eye"] = "눈", -- check
		["Eye of the Storm"] = "폭풍의 눈",
		["Shattrath City"] = "샤트라스",
		["Shattrath"] = "샤트라스",
		["Karazhan"] = "카라잔",
		["Caverns of Time"] = "시간의 동굴",
		["Old Hillsbrad Foothills"] = "옛 힐스브래드 구릉지",
		["The Black Morass"] = "검은늪",
		["Night Elf Village"] = "나이트 엘프 마을",
		["Horde Encampment"] = "호드 야영지",
		["Alliance Base"] = "얼라이언스 주둔지",
		["Zul'Aman"] = "줄아만",
		["Quel'thalas"] = "쿠엘탈라스",
		["Isle of Quel'Danas"] = "쿠엘다나스 섬",
		["Sunwell Plateau"] = "태양샘 고원",
		["Magisters' Terrace"] = "마법학자의 정원",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "공포의 괴철로 기지",
		["Vortex Pinnacle"] = "소용돌이 고원",
		["Rivendark's Perch"] = "리븐다크의 둥지",
		["Ogri'la"] = "오그릴라",
		["Obsidia's Perch"] = "옵시디아의 둥지",
		["Skyguard Outpost"] = "하늘경비대 전초기지",
		["Shartuul's Transporter"] = "샤툴의 순간이동기",
		["Forge Camp: Wrath"] = "격노의 괴철로 기지",
		["Bash'ir Landing"] = "바쉬르 영지",
		["Crystal Spine"] = "수정 돌기",
		["Insidion's Perch"] = "인시디온의 둥지",
		["Furywing's Perch"] = "퓨리윙의 둥지",

		["Tirisfal"] = "티리스팔",
		["Sunken Temple"] = "가라앉은 사원",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "북풍의 땅",
		["Crystalsong Forest"] = "수정노래 숲",
		["Dalaran"] = "달라란",
		["Dragonblight"] = "용의 안식처",
		["Grizzly Hills"] = "회색 구릉지",
		["Howling Fjord"] = "울부짖는 협만",
		["Icecrown"] = "얼음왕관",
		["Sholazar Basin"] = "숄라자르 분지",
		["The Storm Peaks"] = "폭풍우 봉우리",
		["Wintergrasp"] = "겨울손아귀 호수", -- check
		["Zul'Drak"] = "줄드락",
	    ["The Frozen Sea"] = "The Frozen Sea", -- check

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "앙크헤트: 고대 왕국",
		["Azjol-Nerub"] = "아졸네룹",
		["Coldarra"] = "콜다라",
		["The Culling of Stratholme"] = "옛 스트라솔름",	-- check
		["Drak'Tharon Keep"] = "드랙타론 요새",
		["The Eye of Eternity"] = "영원의 눈",	-- check
		["Gundrak"] = "군드락",
		["Halls of Lightning"] = "번개의 전당",
		["Halls of Stone"] = "돌의 전당",
		["The Nexus"] = "마력의 탑",
		["The Obsidian Sanctum"] = "흑요석 성소",	-- check
		["The Oculus"] = "마력의 눈",
		["Ulduar"] = "울두아",
		["Utgarde Keep"] = "우트가드 성채",
		["Utgarde Pinnacle"] = "우트가드 첨탑", -- check
		["The Violet Hold"] = "보라빛 요새",
		["Wyrmrest Temple"] = "고룡 요새",
		["Old Stratholme"] = "옛 스트라솔름",
		["Wyrmrest Temple"] = "고룡 요새",

-- PvP Instances
		["Dalaran Sewers"] = "달라란 하수도",	-- check
		["The Ring of Valor"] = "용맹의 투기장",
		["Strand of the Ancients"] = "고대의 해안",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = "동부 역병지대: 붉은십자군 초소",
	}
elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "Azeroth",
		["Eastern Kingdoms"] = "Reinos del Este",
		["Kalimdor"] = "Kalimdor",
		["Northrend"] = "Rasganorte",
		["Outland"] = "Terrallende",
		["Cosmic map"] = "Mapa cósmico",

		["Ahn'Qiraj"] = "Ahn'Qiraj",
		["Alterac Mountains"] = "Montañas de Alterac",
		["Alterac Valley"] = "Valle de Alterac",
		["Arathi Basin"] = "Cuenca de Arathi",
		["Arathi Highlands"] = "Tierras Altas de Arathi",
		["Ashenvale"] = "Vallefresno",
		["Auberdine"] = "Auberdine",
		["Azshara"] = "Azshara",
		["Badlands"] = "Tierras Inhóspitas",
		["The Barrens"] = "Los Baldíos",
		["Blackfathom Deeps"] = "Cavernas de Brazanegra",
		["Blackrock Depths"] = "Profundidades de Roca Negra",
		["Blackrock Mountain"] = "Montaña Roca Negra",
		["Blackrock Spire"] = "Cumbre de Roca Negra",
		["Blackwing Lair"] = "Guarida Alanegra",
		["Blasted Lands"] = "Las Tierras Devastadas",
		["Booty Bay"] = "Bahía del Botín",
		["Burning Steppes"] = "Las Estepas Ardientes",
		["Darkshore"] = "Costa Oscura",
		["Darnassus"] = "Darnassus",
		["The Deadmines"] = "Las Minas de la Muerte",
		["Deadwind Pass"] = "Paso de la Muerte",
		["Deeprun Tram"] = "Tranvía Subterráneo",
		["Desolace"] = "Desolace",
		["Dire Maul"] = "La Masacre",
		["Dire Maul (East)"] = "La Masacre (Este)",
		["Dire Maul (West)"] = "La Masacre (Oeste)",
		["Dire Maul (North)"] = "La Masacre (Norte)",
		["Dun Morogh"] = "Dun Morogh",
		["Durotar"] = "Durotar",
		["Duskwood"] = "Bosque del Ocaso",
		["Dustwallow Marsh"] = "Marjal Revolcafango",
		["Eastern Plaguelands"] = "Tierras de la Peste del Este",
		["Elwynn Forest"] = "Bosque de Elwynn",
		["Everlook"] = "Vista Eterna",
		["Felwood"] = "Frondavil",
		["Feralas"] = "Feralas",
		["The Forbidding Sea"] = "Mar Adusto",
		["Gadgetzan"] = "Gadgetzan",
		["Gates of Ahn'Qiraj"] = "Puertas de Ahn'Qiraj",
		["Gnomeregan"] = "Gnomeregan",
		["The Great Sea"] = "Mare Magnum",
		["Grom'gol Base Camp"] = "Campamento Grom'gol",
		["Hall of Legends"] = "Sala de las Leyendas",
		["Hillsbrad Foothills"] = "Laderas de Trabalomas",
		["The Hinterlands"] = "Tierras del Interior",
		["Hyjal"] = "Hyjal",
		["Hyjal Summit"] = "Hyjal Summit",
		["Ironforge"] = "Forjaz",
		["Loch Modan"] = "Loch Modan",
		["Lower Blackrock Spire"] = "Cumbre inferior de Roca Negra",
		["Maraudon"] = "Maraudon",
		["Menethil Harbor"] = "Puerto de Menethil",
		["Molten Core"] = "Núcleo de Magma",
		["Moonglade"] = "Claro de la Luna",
		["Mulgore"] = "Mulgore",
		["Naxxramas"] = "Naxxramas",
		["Onyxia's Lair"] = "Guarida de Onyxia",
		["Orgrimmar"] = "Orgrimmar",
		["Ratchet"] = "Trinquete",
		["Ragefire Chasm"] = "Sima ígnea",
		["Razorfen Downs"] = "Zahúrda Rajacieno",
		["Razorfen Kraul"] = "Horado Rajacieno",
		["Redridge Mountains"] = "Montañas Crestagrana",
		["Ruins of Ahn'Qiraj"] = "Ruinas de Ahn'Qiraj",
		["Scarlet Monastery"] = "Monasterio Escarlata",
		["Scholomance"] = "Scholomance",
		["Searing Gorge"] = "La Garganta de Fuego",
		["Shadowfang Keep"] = "Castillo de Colmillo Oscuro",
		["Silithus"] = "Silithus",
		["Silverpine Forest"] = "Bosque de Argénteos",
		["The Stockade"] = "Las Mazmorras",
		["Stonard"] = "Stonard", --check
		["Stonetalon Mountains"] = "Sierra Espolón",
		["Stormwind City"] = "Ciudad de Ventormenta",
		["Stormwind"] = "Ventormenta",
		["Stranglethorn Vale"] = "Vega de Tuercespina",
		["Stratholme"] = "Stratholme",
		["Swamp of Sorrows"] = "Pantano de las Penas",
		["Tanaris"] = "Tanaris",
		["Teldrassil"] = "Teldrassil",
		["Temple of Ahn'Qiraj"] = "El Templo de Ahn'Qiraj",
		["The Temple of Atal'Hakkar"] = "El Templo de Atal'Hakkar",
		["Theramore Isle"] = "Isla Theramore",
		["Thousand Needles"] = "Las Mil Agujas",
		["Thunder Bluff"] = "Cima del Trueno",
		["Tirisfal Glades"] = "Claros de Tirisfal",
		["Uldaman"] = "Uldaman",
		["Un'Goro Crater"] = "Cráter de Un'Goro",
		["Undercity"] = "Entrañas",
		["Upper Blackrock Spire"] = "Cumbre de Roca Negra",
		["Wailing Caverns"] = "Cuevas de los Lamentos",
		["Warsong Gulch"] = "Garganta Grito de Guerra",
		["Western Plaguelands"] = "Tierras de la Peste del Oeste",
		["Westfall"] = "Páramos de Poniente",
		["Wetlands"] = "Los Humedales",
		["Winterspring"] = "Cuna del Invierno",
		["Zul'Farrak"] = "Zul'Farrak",
		["Zul'Gurub"] = "Zul'Gurub",

		["Champions' Hall"] = "Sala de los Campeones",
		["Hall of Champions"] = "Sala de los Campeones",
		["Blade's Edge Arena"] = "Arena Filospada",
		["Nagrand Arena"] = "Arena de Nagrand",
		["Ruins of Lordaeron"] = "Ruinas de Lordaeron", -- check
		["Twisting Nether"] = "El Vacío Abisal",
		["The Veiled Sea"] = "Mar de la Bruma",
		["The North Sea"] = "El Mar Norte",
		["Armory"] = "Armería",
		["Library"] = "Biblioteca",
		["Cathedral"] = "Catedral",
		["Graveyard"] = "Cementerio",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "Bosque de la Plaga",
		["Hellfire Citadel"] = "Ciudadela del Fuego Infernal",
		["Auchindoun"] = "Auchindoun",
		["The Bone Wastes"] = "El Vertedero de Huesos",
		["Ring of Observance"] = "Círculo de la Observancia",
		["Coilfang Reservoir"] = "Reserva Colmillo Torcido",
		["Amani Pass"] = "Paso de Amani",

		["Azuremyst Isle"] = "Isla Bruma Azur",
		["Bloodmyst Isle"] = "Isla Bruma de Sangre",
		["Eversong Woods"] = "Bosque Canción Eterna",
		["Ghostlands"] = "Tierras Fantasma",
		["The Exodar"] = "El Exodar",
		["Silvermoon City"] = "Ciudad de Lunargenta",
		["Shadowmoon Valley"] = "Valle Sombraluna",
		["Black Temple"] = "El Templo Oscuro",          -- check
		["Terokkar Forest"] = "Bosque de Terokkar",
		["Auchenai Crypts"] = "Criptas Auchenai",
		["Mana-Tombs"] = "Tumbas de Maná",
		["Shadow Labyrinth"] = "Laberinto de las Sombras",
		["Sethekk Halls"] = "Salas Sethekk",
		["Hellfire Peninsula"] = "Península del Fuego Infernal",
		["The Dark Portal"] = "El Portal Oscuro",
		["Hellfire Ramparts"] = "Murallas del Fuego Infernal",
		["The Blood Furnace"] = "El Horno de Sangre",
		["The Shattered Halls"] = "Las Salas Arrasadas",
		["Magtheridon's Lair"] = "Guarida de Magtheridon",   -- check - Magtheradon /Magtheridon ??
		["Nagrand"] = "Nagrand",
		["Zangarmarsh"] = "Marisma de Zangar",
		["The Slave Pens"] = "Recinto de los Esclavos",
		["The Underbog"] = "La Sotiénaga",
		["The Steamvault"] = "La Cámara de Vapor",
		["Serpentshrine Cavern"] = "Caverna Santuario Serpiente",    -- check
		["Blade's Edge Mountains"] = "Montañas Filospada",
		["Gruul's Lair"] = "Guarida de Gruul",
		["Netherstorm"] = "Tormenta Abisal",
		["Tempest Keep"] = "El Castillo de la Tempestad",
		["The Mechanar"] = "El Mechanar",
		["The Botanica"] = "El Invernáculo",
		["The Arcatraz"] = "El Alcatraz",
		["The Eye"] = "El Ojo",  -- check
		["Eye of the Storm"] = "Ojo de la Tormenta",
		["Shattrath City"] = "Ciudad de Shattrath",
		["Shattrath"] = "Shattrath",
		["Karazhan"] = "Karazhan",
		["Caverns of Time"] = "Cavernas del Tiempo",
		["Old Hillsbrad Foothills"] = "Viejas Laderas de Trabalomas",   -- doesn't work in spanish anyway
		["The Black Morass"] = "La Ciénaga Negra",
		["Night Elf Village"] = "Night Elf Village",
		["Horde Encampment"] = "Horde Encampment",
		["Alliance Base"] = "Alliance Base",
		["Zul'Aman"] = "Zul'Aman",
		["Quel'thalas"] = "Quel'thalas",
		["Isle of Quel'Danas"] = "Isla de Quel'Danas",
		["Sunwell Plateau"] = "Meseta de la Fuente del Sol",
		["Magisters' Terrace"] = "Bancal Del Magister" ,

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "",
		["Vortex Pinnacle"] = "",
		["Rivendark's Perch"] = "",
		["Ogri'la"] = "",
		["Obsidia's Perch"] = "",
		["Skyguard Outpost"] = "",
		["Shartuul's Transporter"] = "",
		["Forge Camp: Wrath"] = "",
		["Bash'ir Landing"] = "",
		["Crystal Spine"] = "",
		["Insidion's Perch"] = "",
		["Furywing's Perch"] = "",

		["Tirisfal"] = "Tirisfal",
		["Sunken Temple"] = "El Templo de Sunken",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "Tundra Boreal",
		["Crystalsong Forest"] = "Canto de Cristal",
		["Dalaran"] = "Dalaran",
		["Dragonblight"] = "Cementerio de Dragones",
		["Grizzly Hills"] = "Colinas Pardas",
		["Howling Fjord"] = "Fiordo Aquilonal",
		["Icecrown"] = "Corona del Invierno",
		["Sholazar Basin"] = "Cuenca de Sholazar",
		["The Storm Peaks"] = "Cumbres Tormentosas",
		["Wintergrasp"] = "Conquista del Invierno",
		["Zul'Drak"] = "Zul'Drak",
	    ["The Frozen Sea"] = "The Frozen Sea",

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "Ahn'kahet: El antiguo Reino",
		["Azjol-Nerub"] = "Azjol-Nerub",
		["Coldarra"] = true, --check
		["The Culling of Stratholme"] = "El sacrificio de Stratholme", --Check
		["Drak'Tharon Keep"] = "Fortaleza de Drak'Tharon",
		["The Eye of Eternity"] = "El Ojo de la Eternidad",
		["Gundrak"] = "Gundrak",
		["Halls of Lightning"] = "Cámaras de Relámpagos",
		["Halls of Stone"] = "Cámaras de Piedra",
		["The Nexus"] = "El Nexo",
		["The Obsidian Sanctum"] = "El Sagrario Obsidiana",
		["The Oculus"] = "El Oculus",
		["Ulduar"] = "Ulduar",
		["Utgarde Keep"] = "Fortaleza de Utgarde",
		["Utgarde Pinnacle"] = "Pináculo de Utgarde",
		["The Violet Hold"] = "El Bastión Violeta",
		["Wyrmrest Temple"] = "Templo del Reposo del Dragón",

-- PvP Instances
		["Dalaran Sewers"] = true,
		["The Ring of Valor"] = true,
		["Strand of the Ancients"] = true,

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = "Tierras de la Peste del Este: El Enclave Escarlata",
	}
elseif GAME_LOCALE == "esMX" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "Azeroth",
		["Eastern Kingdoms"] = "Reinos del Este",
		["Kalimdor"] = "Kalimdor",
		--["Northrend"] = true,
		["Outland"] = "Terrallende",
		["Cosmic map"] = "Mapa cósmico",

		["Ahn'Qiraj"] = "Ahn'Qiraj",
		["Alterac Mountains"] = "Montañas de Alterac",
		["Alterac Valley"] = "Valle de Alterac",
		["Arathi Basin"] = "Cuenca de Arathi",
		["Arathi Highlands"] = "Tierras Altas de Arathi",
		["Ashenvale"] = "Vallefresno",
		["Auberdine"] = "Auberdine",
		["Azshara"] = "Azshara",
		["Badlands"] = "Tierras Inhóspitas",
		["The Barrens"] = "Los Baldíos",
		["Blackfathom Deeps"] = "Cavernas de Brazanegra",
		["Blackrock Depths"] = "Profundidades de Roca Negra",
		["Blackrock Mountain"] = "Montaña Roca Negra",
		["Blackrock Spire"] = "Cumbre de Roca Negra",
		["Blackwing Lair"] = "Guarida Alanegra",
		["Blasted Lands"] = "Las Tierras Devastadas",
		["Booty Bay"] = "Bahía del Botín",
		["Burning Steppes"] = "Las Estepas Ardientes",
		["Darkshore"] = "Costa Oscura",
		["Darnassus"] = "Darnassus",
		["The Deadmines"] = "Las Minas de la Muerte",
		["Deadwind Pass"] = "Paso de la Muerte",
		["Deeprun Tram"] = "Tranvía Subterráneo",
		["Desolace"] = "Desolace",
		["Dire Maul"] = "La Masacre",
		["Dire Maul (East)"] = "La Masacre (Este)",
		["Dire Maul (West)"] = "La Masacre (Oeste)",
		["Dire Maul (North)"] = "La Masacre (Norte)",
		["Dun Morogh"] = "Dun Morogh",
		["Durotar"] = "Durotar",
		["Duskwood"] = "Bosque del Ocaso",
		["Dustwallow Marsh"] = "Marjal Revolcafango",
		["Eastern Plaguelands"] = "Tierras de la Peste del Este",
		["Elwynn Forest"] = "Bosque de Elwynn",
		["Everlook"] = "Vista Eterna",
		["Felwood"] = "Frondavil",
		["Feralas"] = "Feralas",
		["The Forbidding Sea"] = "Mar Adusto",
		["Gadgetzan"] = "Gadgetzan",
		["Gates of Ahn'Qiraj"] = "Puertas de Ahn'Qiraj",
		["Gnomeregan"] = "Gnomeregan",
		["The Great Sea"] = "Mare Magnum",
		["Grom'gol Base Camp"] = "Campamento Grom'gol",
		["Hall of Legends"] = "Sala de las Leyendas",
		["Hillsbrad Foothills"] = "Laderas de Trabalomas",
		["The Hinterlands"] = "Tierras del Interior",
		["Hyjal"] = "Hyjal",
		["Hyjal Summit"] = "Hyjal Summit",
		["Ironforge"] = "Forjaz",
		["Loch Modan"] = "Loch Modan",
		["Lower Blackrock Spire"] = "Cumbre inferior de Roca Negra",
		["Maraudon"] = "Maraudon",
		["Menethil Harbor"] = "Puerto de Menethil",
		["Molten Core"] = "Núcleo de Magma",
		["Moonglade"] = "Claro de la Luna",
		["Mulgore"] = "Mulgore",
		["Naxxramas"] = "Naxxramas",
		["Onyxia's Lair"] = "Guarida de Onyxia",
		["Orgrimmar"] = "Orgrimmar",
		["Ratchet"] = "Trinquete",
		["Ragefire Chasm"] = "Sima ígnea",
		["Razorfen Downs"] = "Zahúrda Rajacieno",
		["Razorfen Kraul"] = "Horado Rajacieno",
		["Redridge Mountains"] = "Montañas Crestagrana",
		["Ruins of Ahn'Qiraj"] = "Ruinas de Ahn'Qiraj",
		["Scarlet Monastery"] = "Monasterio Escarlata",
		["Scholomance"] = "Scholomance",
		["Searing Gorge"] = "La Garganta de Fuego",
		["Shadowfang Keep"] = "Castillo de Colmillo Oscuro",
		["Silithus"] = "Silithus",
		["Silverpine Forest"] = "Bosque de Argénteos",
		["The Stockade"] = "Las Mazmorras",
		--["Stonard"] = "",
		["Stonetalon Mountains"] = "Sierra Espolón",
		["Stormwind City"] = "Ciudad de Ventormenta",
		["Stormwind"] = "Ventormenta",
		["Stranglethorn Vale"] = "Vega de Tuercespina",
		["Stratholme"] = "Stratholme",
		["Swamp of Sorrows"] = "Pantano de las Penas",
		["Tanaris"] = "Tanaris",
		["Teldrassil"] = "Teldrassil",
		["Temple of Ahn'Qiraj"] = "El Templo de Ahn'Qiraj",
		["The Temple of Atal'Hakkar"] = "El Templo de Atal'Hakkar",
		["Theramore Isle"] = "Isla Theramore",
		["Thousand Needles"] = "Las Mil Agujas",
		["Thunder Bluff"] = "Cima del Trueno",
		["Tirisfal Glades"] = "Claros de Tirisfal",
		["Uldaman"] = "Uldaman",
		["Un'Goro Crater"] = "Cráter de Un'Goro",
		["Undercity"] = "Entrañas",
		["Upper Blackrock Spire"] = "Cumbre de Roca Negra",
		["Wailing Caverns"] = "Cuevas de los Lamentos",
		["Warsong Gulch"] = "Garganta Grito de Guerra",
		["Western Plaguelands"] = "Tierras de la Peste del Oeste",
		["Westfall"] = "Páramos de Poniente",
		["Wetlands"] = "Los Humedales",
		["Winterspring"] = "Cuna del Invierno",
		["Zul'Farrak"] = "Zul'Farrak",
		["Zul'Gurub"] = "Zul'Gurub",

		["Champions' Hall"] = "Sala de los Campeones",
		["Hall of Champions"] = "Sala de los Campeones",
		["Blade's Edge Arena"] = "Arena Filospada",
		["Nagrand Arena"] = "Arena de Nagrand",
		["Ruins of Lordaeron"] = "Ruinas de Lordaeron", -- check
		["Twisting Nether"] = "El Vacío Abisal",
		["The Veiled Sea"] = "Mar de la Bruma",
		["The North Sea"] = "El Mar Norte",
		["Armory"] = "Armería",
		["Library"] = "Biblioteca",
		["Cathedral"] = "Catedral",
		["Graveyard"] = "Cementerio",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "Bosque de la Plaga",
		["Hellfire Citadel"] = "Ciudadela del Fuego Infernal",
		["Auchindoun"] = "Auchindoun",
		["The Bone Wastes"] = "El Vertedero de Huesos",
		["Ring of Observance"] = "Círculo de la Observancia",
		["Coilfang Reservoir"] = "Reserva Colmillo Torcido",
		["Amani Pass"] = "Paso de Amani",

		["Azuremyst Isle"] = "Isla Bruma Azur",
		["Bloodmyst Isle"] = "Isla Bruma de Sangre",
		["Eversong Woods"] = "Bosque Canción Eterna",
		["Ghostlands"] = "Tierras Fantasma",
		["The Exodar"] = "El Exodar",
		["Silvermoon City"] = "Ciudad de Lunargenta",
		["Shadowmoon Valley"] = "Valle Sombraluna",
		["Black Temple"] = "El Templo Oscuro",          -- check
		["Terokkar Forest"] = "Bosque de Terokkar",
		["Auchenai Crypts"] = "Criptas Auchenai",
		["Mana-Tombs"] = "Tumbas de Maná",
		["Shadow Labyrinth"] = "Laberinto de las Sombras",
		["Sethekk Halls"] = "Salas Sethekk",
		["Hellfire Peninsula"] = "Península del Fuego Infernal",
		["The Dark Portal"] = "El Portal Oscuro",
		["Hellfire Ramparts"] = "Murallas del Fuego Infernal",
		["The Blood Furnace"] = "El Horno de Sangre",
		["The Shattered Halls"] = "Las Salas Arrasadas",
		["Magtheridon's Lair"] = "Guarida de Magtheridon",   -- check - Magtheradon /Magtheridon ??
		["Nagrand"] = "Nagrand",
		["Zangarmarsh"] = "Marisma de Zangar",
		["The Slave Pens"] = "Recinto de los Esclavos",
		["The Underbog"] = "La Sotiénaga",
		["The Steamvault"] = "La Cámara de Vapor",
		["Serpentshrine Cavern"] = "Caverna Santuario Serpiente",    -- check
		["Blade's Edge Mountains"] = "Montañas Filospada",
		["Gruul's Lair"] = "Guarida de Gruul",
		["Netherstorm"] = "Tormenta Abisal",
		["Tempest Keep"] = "El Castillo de la Tempestad",
		["The Mechanar"] = "El Mechanar",
		["The Botanica"] = "El Invernáculo",
		["The Arcatraz"] = "El Alcatraz",
		["The Eye"] = "El Ojo",  -- check
		["Eye of the Storm"] = "Ojo de la Tormenta",
		["Shattrath City"] = "Ciudad de Shattrath",
		["Shattrath"] = "Shattrath",
		["Karazhan"] = "Karazhan",
		["Caverns of Time"] = "Cavernas del Tiempo",
		["Old Hillsbrad Foothills"] = "Viejas Laderas de Trabalomas",   -- doesn't work in spanish anyway
		["The Black Morass"] = "La Ciénaga Negra",
		["Night Elf Village"] = "Night Elf Village",
		["Horde Encampment"] = "Horde Encampment",
		["Alliance Base"] = "Alliance Base",
		["Zul'Aman"] = "Zul'Aman",
		["Quel'thalas"] = "Quel'thalas",
		["Isle of Quel'Danas"] = "Isla de Quel'Danas",
		["Sunwell Plateau"] = "Meseta de la Fuente del Sol",
		["Magisters' Terrace"] = "Bancal Del Magister" ,

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "",
		["Vortex Pinnacle"] = "",
		["Rivendark's Perch"] = "",
		["Ogri'la"] = "",
		["Obsidia's Perch"] = "",
		["Skyguard Outpost"] = "",
		["Shartuul's Transporter"] = "",
		["Forge Camp: Wrath"] = "",
		["Bash'ir Landing"] = "",
		["Crystal Spine"] = "",
		["Insidion's Perch"] = "",
		["Furywing's Perch"] = "",

		["Tirisfal"] = "Tirisfal",
		["Sunken Temple"] = "El Templo de Sunken",

-- WRATH OF THE LICH KING
-- Zones
		--["Borean Tundra"] = true,
		--["Crystalsong Forest"] = true,
		--["Dalaran"] = true,
		--["Dragonblight"] = true,
		--["Grizzly Hills"] = true,
		--["Howling Fjord"] = true,
		--["Icecrown"] = true,
		--["Sholazar Basin"] = true,
		--["The Storm Peaks"] = true,
		--["Wintergrasp"] = true,
		--["Zul'Drak"] = true,
	    --["The Frozen Sea"] = true,

-- Instances (and subzones used for displaying these instances)
		--["Ahn'kahet: The Old Kingdom"] = true,
		--["Azjol-Nerub"] = true,
		--["Coldarra"] = true,
		--["The Culling of Stratholme"] = true,
		--["Drak'Tharon Keep"] = true,
		--["The Eye of Eternity"] = true,
		--["Gundrak"] = true,
		--["Halls of Lightning"] = true,
		--["Halls of Stone"] = true,
		--["The Nexus"] = true,
		--["The Obsidian Sanctum"] = true,
		--["The Oculus"] = true,
		--["Ulduar"] = true,
		--["Utgarde Keep"] = true,
		--["Utgarde Pinnacle"] = true,
		--["The Violet Hold"] = true,
		--["Wyrmrest Temple"] = true,

-- PvP Instances
		--["Dalaran Sewers"] = true,
		--["The Ring of Valor"] = true,
		--["Strand of the Ancients"] = true,

-- Special Zones
--		["Plaguelands: The Scarlet Enclave"] = true,
	}
elseif GAME_LOCALE == "ruRU" then
	lib:SetCurrentTranslations {
		["Azeroth"] = "Азерот",
		["Eastern Kingdoms"] = "Восточные королевства",
		["Kalimdor"] = "Калимдор",
		["Northrend"] = "Нордскол",
		["Outland"] = "Запределье",
		["Cosmic map"] = "Карта Вселенной",

		["Ahn'Qiraj"] = "Ан'Кираж",
		["Alterac Mountains"] = "Альтеракские горы",
		["Alterac Valley"] = "Альтеракская долина",
		["Arathi Basin"] = "Низина Арати",
		["Arathi Highlands"] = "Нагорье Арати",
		["Ashenvale"] = "Ясеневый лес",
		["Auberdine"] = "Аубердин",
		["Azshara"] = "Азшара",
		["Badlands"] = "Бесплодные земли",
		["The Barrens"] = "Степи",
		["Blackfathom Deeps"] = "Непроглядная Пучина",
		["Blackrock Depths"] = "Глубины Черной горы",
		["Blackrock Mountain"] = "Черная гора",
		["Blackrock Spire"] = "Вершина Черной горы",
		["Blackwing Lair"] = "Логово Крыла Тьмы",
		["Blasted Lands"] = "Выжженные земли",
		["Booty Bay"] = "Пиратская Бухта",
		["Burning Steppes"] = "Пылающие степи",
		["Darkshore"] = "Темные берега",
		["Darnassus"] = "Дарнасс",
		["The Deadmines"] = "Мертвые копи",
		["Deadwind Pass"] = "Перевал Мертвого Ветра",
		["Deeprun Tram"] = "Подземный поезд",
		["Desolace"] = "Пустоши",
		["Dire Maul"] = "Забытый Город",
		["Dire Maul (East)"] = "Забытый Город: Восток",
		["Dire Maul (West)"] = "Забытый Город: Запад",
		["Dire Maul (North)"] = "Забытый Город: Север",
		["Dun Morogh"] = "Дун Морог",
		["Durotar"] = "Дуротар",
		["Duskwood"] = "Сумеречный лес",
		["Dustwallow Marsh"] = "Пылевые топи",
		["Eastern Plaguelands"] = "Восточные Чумные земли",
		["Elwynn Forest"] = "Элвиннский лес",
		["Everlook"] = "Круговзор",
		["Felwood"] = "Оскверненный лес",
		["Feralas"] = "Фералас",
		["The Forbidding Sea"] = "Зловещее море",
		["Gadgetzan"] = "Прибамбасск",
		["Gates of Ahn'Qiraj"] = "Врата Ан'Киража",
		["Gnomeregan"] = "Гномреган",
		["The Great Sea"] = "Великое море",
		["Grom'gol Base Camp"] = "Лагерь Гром'гол",
		["Hall of Legends"] = "Зал Легенд",
		["Hillsbrad Foothills"] = "Предгорья Хилсбрада",
		["The Hinterlands"] = "Внутренние земли",
		["Hyjal"] = "Хиджал",
		["Hyjal Summit"] = "Вершина Хиджала",
		["Ironforge"] = "Стальгорн",
		["Loch Modan"] = "Лок Модан",
		["Lower Blackrock Spire"] = "Нижний ярус Черной горы",
		["Maraudon"] = "Мародон",
		["Menethil Harbor"] = "Гавань Менетил",
		["Molten Core"] = "Огненные Недра",
		["Moonglade"] = "Лунная поляна",
		["Mulgore"] = "Мулгор",
		["Naxxramas"] = "Наксрамас",
		["Onyxia's Lair"] = "Логово Ониксии",
		["Orgrimmar"] = "Оргриммар",
		["Ratchet"] = "Кабестан",
		["Ragefire Chasm"] = "Огненная пропасть",
		["Razorfen Downs"] = "Курганы Иглошкурых",
		["Razorfen Kraul"] = "Лабиринты Иглошкурых",
		["Redridge Mountains"] = "Красногорье",
		["Ruins of Ahn'Qiraj"] = "Руины Ан'Киража",
		["Scarlet Monastery"] = "Монастырь Алого ордена",
		["Scholomance"] = "Некроситет",
		["Searing Gorge"] = "Тлеющее ущелье",
		["Shadowfang Keep"] = "Крепость Темного Клыка",
		["Silithus"] = "Силитус",
		["Silverpine Forest"] = "Серебряный бор",
		["The Stockade"] = "Тюрьма",
		["Stonard"] = "Каменор",
		["Stonetalon Mountains"] = "Когтистые горы",
		["Stormwind City"] = "Штормград",
		["Stormwind"] = "Штормград",
		["Stranglethorn Vale"] = "Тернистая долина",
		["Stratholme"] = "Стратхольм",
		["Swamp of Sorrows"] = "Болото Печали",
		["Tanaris"] = "Танарис",
		["Teldrassil"] = "Тельдрассил",
		["Temple of Ahn'Qiraj"] = "Храм Ан'Кираж",
		["The Temple of Atal'Hakkar"] = "Храм Атал'Хаккара",
		["Theramore Isle"] = "Остров Терамор",
		["Thousand Needles"] = "Тысяча Игл",
		["Thunder Bluff"] = "Громовой Утес",
		["Tirisfal Glades"] = "Тирисфальские леса",
		["Uldaman"] = "Ульдаман",
		["Un'Goro Crater"] = "Кратер Ун'Горо",
		["Undercity"] = "Подгород",
		["Upper Blackrock Spire"] = "Верхний ярус Черной горы",
		["Wailing Caverns"] = "Пещеры Стенаний",
		["Warsong Gulch"] = "Ущелье Песни Войны",
		["Western Plaguelands"] = "Западные Чумные земли",
		["Westfall"] = "Западный Край",
		["Wetlands"] = "Болотина",
		["Winterspring"] = "Зимние Ключи",
		["Zul'Farrak"] = "Зул'Фаррак",
		["Zul'Gurub"] = "Зул'Гуруб",

		["Champions' Hall"] = "Зал Защитника",
		["Hall of Champions"] = "Чертог Защитников",
		["Blade's Edge Arena"] = "Арена Острогорья",
		["Nagrand Arena"] = "Арена Награнда",
		["Ruins of Lordaeron"] = "Руины Лордерона",
		["Twisting Nether"] = "Круговерть Пустоты",
		["The Veiled Sea"] = "Сокрытое Море",
		["The North Sea"] = "Северное море",
		["Armory"] = "Оружейная",
		["Library"] = "Библиотека",
		["Cathedral"] = "Собор",
		["Graveyard"] = "Кладбище",

		-- Burning Crusade

		-- Subzones used for displaying instances.
		["Plaguewood"] = "Проклятый лес",
		["Hellfire Citadel"] = "Цитадель Адского Пламени",
		["Auchindoun"] = "Аукиндон",
		["The Bone Wastes"] = "Костяные пустоши",
		["Ring of Observance"] = "Ритуальный Круг",
		["Coilfang Reservoir"] = "Резервуар Кривого Клыка",
		["Amani Pass"] = "Перевал Амани",

		["Azuremyst Isle"] = "Остров Лазурной Дымки",
		["Bloodmyst Isle"] = "Остров Кровавой Дымки",
		["Eversong Woods"] = "Леса Вечной Песни",
		["Ghostlands"] = "Призрачные земли",
		["The Exodar"] = "Экзодар",
		["Silvermoon City"] = "Луносвет",
		["Shadowmoon Valley"] = "Долина Призрачной Луны",
		["Black Temple"] = "Черный храм",
		["Terokkar Forest"] = "Лес Тероккар",
		["Auchenai Crypts"] = "Аукенайские гробницы",
		["Mana-Tombs"] = "Гробницы Маны",
		["Shadow Labyrinth"] = "Темный Лабиринт",
		["Sethekk Halls"] = "Сетеккские залы",
		["Hellfire Peninsula"] = "Полуостров Адского Пламени",
		["The Dark Portal"] = "Темный портал",
		["Hellfire Ramparts"] = "Бастионы Адского Пламени",
		["The Blood Furnace"] = "Кузня Крови",
		["The Shattered Halls"] = "Разрушенные залы",
		["Magtheridon's Lair"] = "Логово Магтеридона",
		["Nagrand"] = "Награнд",
		["Zangarmarsh"] = "Зангартопь",
		["The Slave Pens"] = "Узилище",
		["The Underbog"] = "Нижетопь",
		["The Steamvault"] = "Паровое Подземелье",
		["Serpentshrine Cavern"] = "Змеиное святилище",
		["Blade's Edge Mountains"] = "Острогорье",
		["Gruul's Lair"] = "Логово Груула",
		["Netherstorm"] = "Пустоверть",
		["Tempest Keep"] = "Крепость Бурь",
		["The Mechanar"] = "Механар",
		["The Botanica"] = "Ботаника",
		["The Arcatraz"] = "Аркатрац",
		["The Eye"] = "Око",
		["Eye of the Storm"] = "Око Бури",
		["Shattrath City"] = "Шаттрат",
		["Shattrath"] = "Шаттрат",
		["Karazhan"] = "Каражан",
		["Caverns of Time"] = "Пещеры Времени",
		["Old Hillsbrad Foothills"] = "Старые предгорья Хилсбрада",
		["The Black Morass"] = "Черные топи",
		["Night Elf Village"] = "Деревня ночных эльфов",
		["Horde Encampment"] = "Стоянка Орды",
		["Alliance Base"] = "База Альянса",
		["Zul'Aman"] = "Зул'Аман",
		["Quel'thalas"] = "Кель'Талас",
		["Isle of Quel'Danas"] = "Остров Кель'Данас",
		["Sunwell Plateau"] = "Плато Солнечного Колодца",
		["Magisters' Terrace"] = "Терраса Магистров",

		-- Blade's Edge Plateau
		["Forge Camp: Terror"] = "Лагерь Легиона: Ужас",
		["Vortex Pinnacle"] = "Нагорье Смерчей",
		["Rivendark's Perch"] = "Гнездо Чернокрыла",
		["Ogri'la"] = "Огри'ла",
		["Obsidia's Perch"] = "Гнездо Обсидии",
		["Skyguard Outpost"] = "Застава Стражи Небес",
		["Shartuul's Transporter"] = "Транспортер Шартуула",
		["Forge Camp: Wrath"] = "Лагерь Легиона: Гнев",
		["Bash'ir Landing"] = "Лагерь Баш'ира",
		["Crystal Spine"] = "Хрустальное поле",
		["Insidion's Perch"] = "Гнездо Инсидиона",
		["Furywing's Perch"] = "Гнездовье Ярокрыла",

		["Tirisfal"] = "Тирисфальские леса",
		["Sunken Temple"] = "Затонувший храм",

-- WRATH OF THE LICH KING
-- Zones
		["Borean Tundra"] = "Борейская тундра",
		["Crystalsong Forest"] = "Лес Хрустальной Песни",
		["Dalaran"] = "Даларан",
		["Dragonblight"] = "Драконий Погост",
		["Grizzly Hills"] = "Седые холмы",
		["Howling Fjord"] = "Ревущий фьорд",
		["Icecrown"] = "Ледяная Корона",
		["Sholazar Basin"] = "Низина Шолазар",
		["The Storm Peaks"] = "Грозовая Гряда",
		["Wintergrasp"] = "Озеро Ледяных Оков",
		["Zul'Drak"] = "Зул'Драк",
	    ["The Frozen Sea"] = "Ледяное море",

-- Instances (and subzones used for displaying these instances)
		["Ahn'kahet: The Old Kingdom"] = "Ан'кахет: Старое Королевство",
		["Azjol-Nerub"] = "Азжол-Неруб",
		["Coldarra"] = "Хладарра",
		["The Culling of Stratholme"] = "Прошлое Стратхольма",
		["Drak'Tharon Keep"] = "Крепость Драк'Тарон",
		["The Eye of Eternity"] = "Глаз Вечности",
		["Gundrak"] = "Гундрак",
		["Halls of Lightning"] = "Чертоги Молний",
		["Halls of Stone"] = "Чертоги Камня",
		["The Nexus"] = "Нексус",
		["The Obsidian Sanctum"] = "Обсидиановое святилищ",
		["The Oculus"] = "Окулус",
		["Ulduar"] = "Ульдуар",
		["Utgarde Keep"] = "Крепость Утгард",
		["Utgarde Pinnacle"] = "Вершина Утгард",
		["The Violet Hold"] = "Аметистовая крепость",
		["Wyrmrest Temple"] = "Храм Драконьего Покоя",
		["Icecrown Citadel"] = "Цитадель Ледяной Короны",

-- PvP Instances
		["Dalaran Sewers"] = "Арена Даларана",
		["The Ring of Valor"] = "Круг Доблести",
		["Strand of the Ancients"] = "Берег древних",

-- Special Zones
		["Plaguelands: The Scarlet Enclave"] = "Чумные земли: Анклав Алого ордена",
	}
else
	error(("%s: Locale %q not supported"):format(MAJOR_VERSION, GAME_LOCALE))
end

