--[[	file meta info
	@file		Utils.lua
	@brief		Utility functions. Filtering and table injections.
--]]

--[[
	@brief		Accessing the addons private table

	@var 	_		addonName, thrown away
	@var	wt		Global addonTable
--]]
local _, wt = ...

--	Invoking lua functions to local variables
local tinsert = tinsert
local ipairs = ipairs

--	Get player class
wt.currentClass = select(2, UnitClass("player"))
--[[
	@brief		Filtering function of spells table with custom predicate

	@param		spellsByLevel	Invoking table of spells from <Class>.lua file
	@param		pred			Custom function to use as filter

	@return		output			Filtered output table
--]]
local function filter(spellsByLevel, pred)
	local output = {}	-- Local table init
	for level, spells in pairs(spellsByLevel) do		-- Looping through each level entry in spellsByLevel
		output[level] = {}	-- Sub-table init
		for _, spell in ipairs(spells) do				-- Looping through each spell entry at current level entry
			if (pred(spell) == true) then				-- If custom pred(spell) is true,
				tinsert(output[level], spell)			-- Insert spell at end of sub-table
			end
		end
	end
	return output
end

--[[
	@brief		Filter by player faction

	@var		playerFaction	The player's current active faction
	@param		spellsByLevel	Table of spells from <Class>.lua file

	@return						Returns output from filter()
--]]
local playerFaction = UnitFactionGroup("player")
function wt.FactionFilter(spellsByLevel)
	return filter(spellsByLevel, function(spell) return spell.faction == nil or spell.faction == playerFaction end)	-- Invoking filter() with custom function as @param pred
end

--[[
	@brief		When called from <Class>.lua file,
				creates new sub-table in global scope table "wt" for spells that do not show multiple ranks in the spellbook

		varargs is just a set of tables, where each table is a list of spell ids that
		totally overwrite a previous rank of that ability ordered by rank.
		Most warrior and rogue abilities are like this, as they cost the same amount
		of resources but just last longer or do more damage.
--]]
function wt:AddOverriddenSpells(...)
	local abilityMap = {}	-- Local table init
	for _, abilityIds in ipairs({...}) do			-- Looping through each sub-table
		for _, abilityId in ipairs(abilityIds) do	-- Looping through each spell in table
			abilityMap[abilityId] = abilityIds		-- Add spell IDs to sub-table
		end
	end
	self.overriddenSpellsMap = abilityMap			-- Creates new table in global scope and insert data from local table
end
