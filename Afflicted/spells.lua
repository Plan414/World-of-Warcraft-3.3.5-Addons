AfflictedSpells = {}
AfflictedSpells.version = 5

function AfflictedSpells:GetData()
	if( self.spells ) then
		return self.spells
	end
	
	self.spells = {
		-- Death Knight
		-- Strangulate
		[47476] = "{cooldown=120;cdAnchor='interrupts';class='DEATHKNIGHT';}",
		-- Icebound Fortitude
		[48792] = "{disabled=true;duration=12;cooldown=120;cdDisabled=true;anchor='defenses';cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Mind Freeze
		[47528] = "{cooldown=10;cdAnchor='interrupts';class='DEATHKNIGHT';}",
		-- Anti-Magic Shell
		[48707] = "{cdDisabled=true;type='buff';disabled=true;duration=5;cooldown=45;anchor='defenses';cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Death Grip
		[49576] = "{cdDisabled=true;cooldown=35;cdAnchor='spells';class='DEATHKNIGHT';}",
		-- Anti-Magic Zone
		[51052] = "{disabled=true;duration=10;anchor='defenses';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Dancing Rune Weapon
		[49028] = "{disabled=true;duration=17;anchor='damage';cooldown=90;cdDisabled=true;cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Lichborne
		[49039] = "{duration=10;anchor='defenses';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Vampiric Blood
		[55233] = "{duration=10;anchor='defenses';cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='DEATHKNIGHT';}",
		-- Leap (Ghoul)
		[47482] = "{cooldown=20;cdDisabled=true;cdAnchor='spells';class='DEATHKNIGHT';}",
		-- Gnaw (Ghoul)
		[47481] = "{cooldown=30;cdDisabled=true;cdAnchor='spells';class='DEATHKNIGHT';}",
		
		-- Paladin
		-- Ardent Defender
		[66233] = "{type='buff';disabled=true;cooldown=120;cdAnchor='cooldowns';class='PALADIN';}",
		-- Divine Plea
		[54428] = "{type='buff';disabled=true;duration=15;anchor='buffs';cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='PALADIN';}",
		-- Avenging Wrath
		[31884] = "{duration=20;anchor='damage';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='PALADIN';}",
		-- Hammer of Justice
		[10308] = "{cooldown=40;cdDisabled=true;cdAnchor='cooldowns';class='PALADIN';}",
		-- Hand of Protection
		[10278] = "{type='buff';duration=10;anchor='defenses';cdDisabled=true;cooldown=180;cdAnchor='cooldowns';class='PALADIN';}",
		-- Divine Shield
		[642] = "{type='buff';duration=12;anchor='defenses';cooldown=300;cdDisabled=true;cdAnchor='cooldowns';class='PALADIN';}",
		-- Hand of Freedom
		[1044] = "{type='buff';duration=14;anchor='spells';cdDisabled=true;cooldown=25;cdAnchor='cooldowns';class='PALADIN';}",
		-- Hand of Sacrifice
		[6940] = "{disabled=true;type='buff';duration=12;anchor='defenses';cdDisabled=true;cooldown=120;cdAnchor='cooldowns';class='PALADIN';}",
		-- Aura Mastery
		[31821] = "{duration=6;anchor='defenses';cooldown=120;cdAnchor='cooldowns';class='PALADIN';}",
		-- Divine Sacrifice
		[64205] = "{type='buff';duration=6;anchor='defenses';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='PALADIN';}",
		
		-- Warrior
		-- Shield Reflect
		[23920] = "{type='buff';disabled=true;duration=5;cdDisabled=true;cooldown=10;cdAnchor='buffs';class='WARRIOR';}",
		-- Shield Bash
		[72] = "{cooldown=12;cdAnchor='interrupts';class='WARRIOR';}",
		-- Pummel
		[6552] = "{cooldown=10;cdAnchor='interrupts';class='WARRIOR';}",
		-- Intervene
		[3411] = "{cooldown=30;cdDisabled=true;cdAnchor='defenses';class='WARRIOR';}",
		-- Recklessness
		[1719] = "{duration=12;anchor='damage';cooldown=300;cdDisabled=true;cdAnchor='cooldowns';class='WARRIOR';}",
		-- Charge
		[11578] = "{cooldown=13;cdAnchor='spells';class='WARRIOR';}",
		-- Berserker Rage
		[18499] = "{disabled=true;duration=10;anchor='spells';cooldown=30;cdAnchor='cooldowns';class='WARRIOR';}",
		-- Intercept
		[20252] = "{cooldown=15;cdAnchor='spells';class='WARRIOR';}",
		-- Shield Wall
		[871] = "{disabled=true;duration=12;anchor='defenses';cooldown=300;cdDisabled=true;cdAnchor='cooldowns';class='WARRIOR';}",
		-- Disarm
		[676] = "{cdDisabled=true;cooldown=60;cdAnchor='spells';class='WARRIOR';}",
		
		-- Druid
		-- Survival Instincts
		[61336] = "{duration=20;anchor='defenses';cooldown=300;cdDisabled=true;cdAnchor='cooldowns';class='DRUID';}",
		-- Berserk
		[50334] = "{duration=15;anchor='damage';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='DRUID';}",
		-- Nature's Grasp
		[17329] = 53312,
		[27009] = 53312,
		[53312] = "{type='buff';disabled=true;duration=45;anchor='buffs';cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='DRUID';}",
		-- Innervate
		[29166] = "{type='buff';disabled=true;duration=10;anchor='buffs';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='DRUID';}",
		-- Frenzied Regeneration
		[22842] = "{duration=10;anchor='defenses';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='DRUID';}",
		-- Feral Charge - Bear
		[16979] = "{cooldown=15;cooldownName='feral';cdAnchor='interrupts';class='DRUID';}",
		-- Feral Charge - Cat
		[49376] = "{cooldown=30;cooldownName='feral';cdAnchor='spells';class='DRUID';}",
		-- Bash
		[8983] = "{cooldown=30;cdDisabled=true;cdAnchor='interrupts';class='DRUID';}",
		
		-- Priest
		-- Hymn of Hope
		[64901] = "{duration=8;anchor='buffs';cooldown=360;cdDisabled=true;cdAnchor='cooldowns';class='PRIEST';}",
		-- Dispersion
		[47585] = "{duration=6;anchor='defenses';cooldown=75;cdAnchor='cooldowns';class='PRIEST';}",
		-- Guardian Spirit
		[47788] = "{type='buff';duration=10;anchor='defenses';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='PRIEST';}",
		-- Pain Suppression
		[33206] = "{type='buff';duration=8;anchor='defenses';cooldown=144;cdDisabled=true;cdAnchor='cooldowns';class='PRIEST';}",
		-- Silence
		[15487] = "{cooldown=45;cdAnchor='interrupts';class='PRIEST';}",
		-- Psychic Scream
		[8122] = 10890,
		[8124] = 10890,
		[10888] = 10890,
		[10890] = "{cooldown=26;cdAnchor='spells';cdDisabled=true;class='PRIEST';}",
		
		-- Warlock
		-- Fel Domination
		[18708] = "{type='buff';duration=15;anchor='spells';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='WARLOCK';}",
		-- Devour Magic (Felhunter)
		[27276] = 48011,
		[27277] = 48011,
		[48011] = "{cooldown=8;cdAnchor='spells';cdDisabled=true;class='WARLOCK';}",
		-- Intercept (Felguard)
		[30198] = 47996,
		[47996] = "{cooldown=30;cdDisabled=true;cdAnchor='spells';cdDisabled=true;class='WARLOCK';}",
		-- Spell Lock (Felhunter)
		[19647] = "{cooldown=24;cdAnchor='interrupts';class='WARLOCK';}",
		
		-- Shaman
		-- Hex
		[51514] = "{cooldown=45;cdDisabled=true;cdAnchor='spells';class='SHAMAN'}",
		-- Wind Shock
		[57994] = "{cooldown=6;cdAnchor='interrupts';class='SHAMAN';}",
		-- Heroism
		[32182] = 2825,
		-- Bloodlust
		[2825] = "{type='buff';duration=40;anchor='damage';cooldown=300;cdDisabled=true;cdAnchor='cooldowns';class='SHAMAN';}",
		-- Tremor Totem
		[8143] = "{type='totem';disabled=true;duration=5;anchor='buffs';repeating=true;class='SHAMAN';}",
		-- Shamanistic Rage
		[30823] = "{disabled=true;duration=15;anchor='defenses';cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='SHAMAN';}",
		-- Mana Tide Totem
		[16190] = "{type='totem';disabled=true;duration=12;anchor='buffs';cooldown=300;cdAnchor='cooldowns';class='SHAMAN';}",
		-- Grounding Totem
		[8177] = "{type='totem';disabled=true;duration=45;anchor='buffs';cooldown=15;cdAnchor='cooldowns';class='SHAMAN';}",
		
		-- Hunter
		-- Bestial Wrath
		[19574] = "{duration=10;anchor='damage';cdDisabled=true;cooldown=120;cdAnchor='cooldowns';class='HUNTER';}",
		-- Wyvern Sting
		[27068] = 49012,
		[49011] = 49012,
		[49012] = "{cooldown=60;cdAnchor='cooldowns';class='HUNTER';}",
		-- Silencing Shot
		[34490] = "{cooldown=20;cdAnchor='interrupts';class='HUNTER';}",
		-- Readiness
		[23989] = "{cooldown=180;cdDisabled=true;cdAnchor='cooldowns';resets={49012,34600,63670,19263,3034,14327,34490};class='HUNTER';}",
		-- Nether Shock (Nether Ray)
		[53588] = 53589,
		[53589] = "{cooldown=40;cdAnchor='interrupts';class='HUNTER';}",
		-- Pin (Crab)
		[53547] = 53548,
		[53548] = "{cooldown=40;cdDisabled=true;cdAnchor='spells';class='HUNTER';}",
		-- Pummel (Gorilla)
		[26090] = "{cooldown=30;cdAnchor='interrupts';class='HUNTER';}",
		-- Frost Trap
		[13809] = 14311,
		-- Freezing Arrow
		[60210] = 14311,
		-- Freezing Trap
		[14311] = "{type='trap';configName='frost';cooldownName='frost';disabled=true;duration=30;anchor='spells';cooldown=30;cdDisabled=true;cdAnchor='cooldowns';class='HUNTER';}",
		-- Explosive Trap
		[27025] = 49056,
		[49066] = 49056,
		[49067] = 49056,
		-- Black Arrow
		[63670] = 49056,
		[63671] = 49056,
		[63672] = 49056,
		-- Immolation Trap
		[27023] = 49056,
		[49055] = 49056,
		[49056] = "{type='trap';configName='fire';cooldownName='fire';disabled=true;duration=30;anchor='spells';cooldown=30;cdDisabled=true;cdAnchor='cooldowns';class='HUNTER';}",
		-- Snake Trap
		[34600] = "{type='trap';configName='nature';cooldownName='nature';disabled=true;duration=30;anchor='spells';cooldown=30;cdDisabled=true;cdAnchor='cooldowns';class='HUNTER';}",
		-- Deterrence
		[19263] = "{duration=5;anchor='defenses';cooldown=90;cdDisabled=true;cdAnchor='cooldowns';class='HUNTER';}",
		-- Viper Sting
		[3034] = "{cooldown=15;cdAnchor='spells';class='HUNTER';}",
		
		-- Mage
		-- Cold Snap
		[11958] = "{cooldown=384;cdDisabled=true;cdAnchor='cooldowns';resets={12472,44572,45438};class='MAGE'}",
		-- Deep Freeze
		[44572] = "{cooldown=30;cdAnchor='spells';class='MAGE';}",
		-- Icy Veins
		[12472] = "{type='buff';duration=20;anchor='damage';cooldown=144;cdDisabled=true;cdAnchor='cooldowns';class='MAGE';}",
		-- Invisibility
		[66] = "{disabled=true;duration=23;anchor='defenses';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='MAGE';}",
		-- Ice Block
		[45438] = "{type='buff';duration=10;anchor='defenses';cooldown=240;cdDisabled=true;cdAnchor='cooldowns';class='MAGE';}",
		-- Counterspell
		[2139] = "{cooldown=24;cdAnchor='interrupts';class='MAGE';}",
		-- Blink
		[1953] = "{cooldown=15;cdDisabled=true;cdAnchor='cooldowns';class='MAGE';}",
		
		-- Rogue
		-- Kick
		[1766] = "{cooldown=10;cdAnchor='interrupts';class='ROGUE';}",
		-- Kidney Shot
		[8643] = "{cooldown=20;cdAnchor='spells';class='ROGUE';}",
		--[51713] = "{duration=10;anchor='damage';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='ROGUE';}",
		-- Shadow Step
		[36554] = "{disabled=true;duration=3;anchor='buffs';cooldown=30;cdAnchor='cooldowns';class='ROGUE';}",
		-- Adrenaline Rush
		[13750] = "{duration=15;anchor='damage';cooldown=180;cdDisabled=true;cdAnchor='cooldowns';class='ROGUE';}",
		-- Preparation
		[14185] = "{cooldown=300;cdDisabled=true;cdAnchor='cooldowns';resets={14177,36554,26889,11305,26669};class='ROGUE'}",
		-- Cloak of Shadows
		[31224] = "{duration=5;anchor='defenses';cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='ROGUE';}",
		-- Vanish
		[26889] = "{type='buff';disabled=true;duration=10;anchor='defenses';cooldown=120;cdAnchor='cooldowns';class='ROGUE';}",
		-- Sprint
		[11305] = "{duration=15;disabled=true;anchor='buffs';cooldown=120;cdAnchor='cooldowns';class='ROGUE';}",
		-- Evasion
		[26669] = "{duration=15;anchor='defenses';cooldown=120;cdDisabled=true;cdAnchor='cooldowns';class='ROGUE';}",
		-- Blind
		[2094] = "{cooldown=120;cdAnchor='cooldowns';class='ROGUE';}",
		-- Dismantle
		[51722] = "{cooldown=60;cdDisabled=true;cdAnchor='cooldowns';class='ROGUE';}",
		
		-- Misc
		-- PvP Trinket
		[59752] = 42292,
		[42292] = "{cooldown=120;cdAnchor='defenses'}",
		-- Escape Artist
		[20589] = "{cooldown=105;cdAnchor='defenses'}",
	}
	
	return self.spells
end

function AfflictedSpells:Verify()
	AfflictedSpells:GetData()
	
	print("Verifying Afflicted database.")
	
	local found
	for id, data in pairs(self.spells) do
		if( not GetSpellInfo(id) ) then
			print(string.format("Spell does not exist %s.", id))
			found = true
		elseif( type(data) == "number" ) then
			if( type(self.spells[data]) ~= "string" ) then
				print(string.format("[%s] is linking to a spell that links to another spell.", id))
				found = true
			end
		elseif( type(data) == "string" ) then
			local tbl, error = loadstring("return " .. data)
			if( type(tbl) ~= "function" ) then
				print(string.format("[%s] = %s", id, error))
				found = true
			end
			
			tbl = tbl()
			
			if( not tbl.class ) then
				print(string.format("No class tag found on %s.", id))
				found = true
			end
		end
	end

	if( not found ) then
		print("All good, no spellIDs missing.")
	end
end

function AfflictedSpells:GetTotemClass(spellName)
	if( not self.totems ) then
		self.totems = {
			[GetSpellInfo(8227)] = "fire",
			[GetSpellInfo(8181)] = "fire",
			[GetSpellInfo(2894)] = "fire",
			[GetSpellInfo(8499)] = "fire",
			[GetSpellInfo(10585)] = "fire",
			[GetSpellInfo(6363)] = "fire",
			[GetSpellInfo(57720)] = "fire",
			[GetSpellInfo(8170)] = "water",
			[GetSpellInfo(8184)] = "water",
			[GetSpellInfo(5394)] = "water",
			[GetSpellInfo(5675)] = "water",
			[GetSpellInfo(16190)] = "water",
			[GetSpellInfo(8143)] = "earth",
			[GetSpellInfo(2062)] = "earth",
			[GetSpellInfo(8071)] = "earth",
			[GetSpellInfo(8075)] = "earth",
			[GetSpellInfo(2484)] = "earth",
			[GetSpellInfo(5730)] = "earth",
			[GetSpellInfo(8177)] = "air",
			[GetSpellInfo(10595)] = "air",
			[GetSpellInfo(6495)] = "air",
			[GetSpellInfo(8512)] = "air",
			[GetSpellInfo(3738)] = "air",
		}
	end
	
	return self.totems[spellName]
end
