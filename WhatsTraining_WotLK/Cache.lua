--[[	file meta info
	@file 		Cache.lua
	@brief		Cache functions to build table with data from client
--]]

--[[
	@brief		Accessing the addons private table

	@var 	_		addonName, thrown away
	@var	wt		Global addonTable
--]]
local _, wt = ...

--[[
	@brief		Tables for Spell Cache

	@var		wt.spellInfoCache	Global table for spell cache
	@param		spell				The Spell ID to cache
	@param		level				The level the spell is learned at
	@param		done				If already cached, set to true and return
--]]
wt.spellInfoCache = {}	-- Table init
function wt:CacheSpell(spell, level, done)
	if (self.spellInfoCache[spell.id] ~= nil) then		-- If cache for spell id already exists
		done(true)										-- Set done to true and return
		return
	end
	local subText = select(2, GetSpellInfo(spell.id))	-- Get spell rank/subtext
	local formattedSubText =	(subText and subText ~= "") and format(PARENS_TEMPLATE, subText)	-- If subtext is not empty, format string
								or ""																-- If subtext is empty, set as empty string
	self.spellInfoCache[spell.id] = {							-- Getting spell info and set into cache table
		id = spell.id,											-- Id
		name = select(1, GetSpellInfo(spell.id)),				-- Name
		subText = subText,										-- Rank/subtext
		formattedSubText = formattedSubText,					-- Formatted subtext
		icon = select(3, GetSpellInfo(spell.id)),				-- Icon path
		cost = spell.cost,										-- Cost
		formattedCost = GetCoinTextureString(spell.cost),		-- Formatted cost
		level = level,											-- Level
		formattedLevel = format(wt.L.LEVEL_FORMAT, level)		-- Formatted level
	}
	done(false)		-- When done, set done as false
end

-- @brief		Function to easier use the spell info function
function wt:SpellInfo(spellId)
	return self.spellInfoCache[spellId]
end
