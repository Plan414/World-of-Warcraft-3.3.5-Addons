local Skada = Skada

local mod = Skada:NewModule("Friendly Fire")
local playermod = Skada:NewModule("Friendly Fire - List of players damaged")
local spellmod = Skada:NewModule("Friendly Fire - List of damaging spells")

local function log_ffdamage_done(set, dmg)
	-- Get the player.
	local player = Skada:get_player(set, dmg.playerid, dmg.playername)
	if player then
		-- 
		-- Also add to set total ff damage done.
		set.ffdamagedone = set.ffdamagedone + dmg.amount
		
		-- Add spell to player if it does not exist.
		if not player.ffdamagedonespells[dmg.spellname] then
			player.ffdamagedonespells[dmg.spellname] = {id = dmg.spellid, name = dmg.spellname, damage = 0}
		end
		
		-- Add damage to target if it does not exist.
		if not player.ffdamagedonetargets[dmg.targetname] then
			player.ffdamagedonetargets[dmg.targetname] = {id = dmg.targetid, name = dmg.targetname, damage = 0}
		end
		
		-- Add to player total damage.
		player.ffdamagedone = player.ffdamagedone + dmg.amount
		
		-- Get the spell from player.
		local spell = player.ffdamagedonespells[dmg.spellname]
	    spell.damage = spell.damage + dmg.amount
	    
	    -- Get the target from player
	    local target = player.ffdamagedonetargets[dmg.targetname]
	    target.damage = target.damage + dmg.amount
	end
end

local dmg = {}

local function SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	local spellId, spellName, spellSchool, samount, soverkill, sschool, sresisted, sblocked, sabsorbed, scritical, sglancing, scrushing = ...
	--Skada:Print("Friendly Fire : ", spellName, "(", srcName, ">", dstName, ")")

	dmg.playerid = srcGUID
	dmg.playername = srcName
	dmg.spellid = spellId
	dmg.spellname = spellName
	dmg.amount = samount
	dmg.targetid = dstGUID
	dmg.targetname = dstName
	
	log_ffdamage_done(Skada.current, dmg)
	log_ffdamage_done(Skada.total, dmg)
end

local function SwingDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	-- White melee.
	local samount, soverkill, sschool, sresisted, sblocked, sabsorbed, scritical, sglancing, scrushing = ...
	
	dmg.playerid = srcGUID
	dmg.playername = srcName
	dmg.spellid = 6603
	dmg.spellname = "Attack"
	dmg.amount = samount
    dmg.targetid = dstGUID
	dmg.targetname = dstName
		
	log_ffdamage_done(Skada.current, dmg)
	log_ffdamage_done(Skada.total, dmg)
end

function mod:Update(win, set)
	local max = 0
	
	local nr = 1
	for i, player in ipairs(set.players) do
		if player.ffdamagedone > 0 then
			local d = win.dataset[nr] or {}
			win.dataset[nr] = d

			d.label = player.name
			d.value = player.ffdamagedone
			d.valuetext = Skada:FormatNumber(player.ffdamagedone)..(" (%02.1f%%)"):format(player.ffdamagedone / set.ffdamagedone * 100)
			d.id = player.id
			d.class = player.class
			
			if player.ffdamagedone > max then
				max = player.ffdamagedone
			end
			nr = nr + 1
		end
	end
	
	-- Sort the possibly changed bars.
	win.metadata.maxvalue = max
end

function spellmod:Enter(win, id, label)
	spellmod.playerid = id
	spellmod.title = label.."'s Friendly Fire (spells)"
end

function playermod:Enter(win, id, label)
	playermod.playerid = id
	playermod.title = label.."'s Friendly Fire (targets)"
end

-- Detail view of a player - spells.
function spellmod:Update(win, set)
	-- View spells for this player.
		
	local player = Skada:find_player(set, self.playerid)
	
	local nr = 1
	if player then
		for spellname, spell in pairs(player.ffdamagedonespells) do
				
			local d = win.dataset[nr] or {}
			win.dataset[nr] = d
			
			d.label = spellname
			d.value = spell.damage
			d.icon = select(3, GetSpellInfo(spell.id))
			d.id = spellname
			d.valuetext = Skada:FormatNumber(spell.damage)..(" (%02.1f%%)"):format(spell.damage / player.ffdamagedone * 100)
			
			nr = nr + 1
		end
		
		-- Sort the possibly changed bars.
		win.metadata.maxvalue = player.ffdamagedone
	end
end

-- Detail view of a player - targets.
function playermod:Update(win, set)
	-- View targets for this player.
		
	local player = Skada:find_player(set, self.playerid)
	
	local nr = 1
	if player then
		for targetname, target in pairs(player.ffdamagedonetargets) do
				
			local d = win.dataset[nr] or {}
			win.dataset[nr] = d
			
			d.label = targetname
			d.value = target.damage
			d.icon = ""
			d.id = targetname
			d.valuetext = Skada:FormatNumber(target.damage)..(" (%02.1f%%)"):format(target.damage / player.ffdamagedone * 100)
			
			nr = nr + 1
		end
		
		-- Sort the possibly changed bars.
		win.metadata.maxvalue = player.ffdamagedone
	end
end

function mod:OnEnable()
	spellmod.metadata 		= {}
	playermod.metadata 		= {}
	mod.metadata 			= {click1 = spellmod, click2 = playermod, showspots = true}

	Skada:RegisterForCL(SpellDamage, 'SPELL_DAMAGE', {dst_is_interesting_nopets = true, src_is_interesting_nopets = true})
	Skada:RegisterForCL(SpellDamage, 'SPELL_PERIODIC_DAMAGE', {dst_is_interesting_nopets = true, src_is_interesting_nopets = true})
	Skada:RegisterForCL(SpellDamage, 'SPELL_BUILDING_DAMAGE', {dst_is_interesting_nopets = true, src_is_interesting_nopets = true})
	Skada:RegisterForCL(SpellDamage, 'RANGE_DAMAGE', {dst_is_interesting_nopets = true, src_is_interesting_nopets = true})
	
	Skada:RegisterForCL(SwingDamage, 'SWING_DAMAGE', {dst_is_interesting_nopets = true, src_is_interesting_nopets = true})

	Skada:AddMode(self)
end

function mod:OnDisable()
	Skada:RemoveMode(self)
end

-- Called by Skada when a new player is added to a set.
function mod:AddPlayerAttributes(player)
	if not player.ffdamagedone then
		player.ffdamagedone = 0
		player.ffdamagedonespells = {}
		player.ffdamagedonetargets = {}
	end
end

-- Called by Skada when a new set is created.
function mod:AddSetAttributes(set)
	if not set.ffdamagedone then
		set.ffdamagedone = 0
	end
end

function mod:GetSetSummary(set)
	return Skada:FormatNumber(set.ffdamagedone)
end