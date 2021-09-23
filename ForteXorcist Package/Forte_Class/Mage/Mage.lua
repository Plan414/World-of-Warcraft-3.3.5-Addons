--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0
-- Forte Mage Module attempt by Amros of Gilneas

if FW.CLASS == "MAGE" then
	local FW = FW;
	local FWL = FW.L;
	local MG = FW:ClassModule("Mage");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(1)
		:AddChannel(10,0,1) -- Blizzard
	
		:AddSpell(  118,  50,"Crowd",	F.UNIQUE):SetDurationPVP(10) -- Polymorph
		:AddSpell(44457,  12,"Default",	F.TICKS) -- Living Bomb
		:AddSpell(12654,   4,"Default",	F.TICKS):SetTickSpeed(2) -- Ignite
		:AddSpell(11366, 000,"Default",	F.TICKS) -- Pyroblast
		:AddSpell( 2120,   8,"Default",	F.AOE_DMG):SetTickSpeed(2) -- Flamestrike
		:AddSpell(114954, 12,"Default",	F.TICKS):SetTickSpeed(1) -- Nether Tempest
		:AddSpell(11129,  10,"Default",	F.TICKS):SetTickSpeed(1) -- Combustion
		
		:AddSpell(113092,  4,"Default") -- Frost Bomb
		
		:AddSpell(31589, 000,"Crowd",	F.UNIQUE) -- Slow
		:AddSpell( 2139,   4,"Crowd",	F.UNIQUE) -- Counterspell
		:AddSpell(  120,   6,"Crowd",	F.AOE) -- Cone of Cold
		:AddSpell(  122,   8,"Crowd",	F.AOE) -- Frost Nova
		:AddSpell(113724, 10,"Crowd",	F.AOE) -- Ring of Frost
		:AddSpell(44572,   5,"Crowd",	F.UNIQUE) -- Deep Freeze
		:AddSpell(31661,   4,"Crowd",	F.UNIQUE) -- Dragon's Breath
		:AddSpell(102051,  8,"Crowd",	F.UNIQUE):SetDurationPVP(4) -- Frostjaw
		
		:AddSpell(44614, 000,"Crowd") -- Frostfire Bolt
		:AddSpell(55342,  30,"Pet",		F.SUMMON) -- Mirror Image
		:AddSpell(84714,  10,"Pet",		F.SUMMON):SetTickSpeed(1) -- Frozen Orb
		
		:AddBuff(44448) -- Pyroblast Clearcasting ??
		:AddBuff(37445)	-- Mana Surge
		
		:AddBuff(12042) -- Arcane Power
		:AddBuff(1463) -- Mana Shield
		:AddBuff(12472) -- Icy Veins
		:AddBuff(57761) -- Brain Freeze
		:AddBuff(70753) -- Pushing the Limit
		
		:AddBuff(66) -- Invisibility
		:AddBuff(12051):SetTickSpeed(2) -- Evocation
		:AddBuff(45438) -- Ice Block
		
		:AddBuff(6117) -- Mage Armor
		:AddBuff(30482) -- Molten Armor
		:AddBuff(7302) -- Frost Armor
		
		:AddBuff(112965) -- Fingers of Frost
		:AddBuff(11426) -- Ice Barrier
		:AddBuff(105068) -- Arcane Missile Barrage
		
		:AddBuff(105785) -- Stolen Time
		:AddBuff(115610) -- Temporal Shield
		:AddBuff(108839) -- Ice Floes
		
		-- self debuffs
		:AddSelfDebuff(36032) -- Arcane Blast

		--target debuffs
		:AddDebuff(120) -- Cone of Cold
		:AddDebuff(122) -- frost nova
		:AddDebuff(11113) -- Blast Wave
		:AddDebuff(113724) -- Ring of Frost
		:AddDebuff(33395) -- Freeze
		:AddDebuff(12486) -- Chilled
		:AddDebuff(44614) -- Frostfire Bolt
		:AddDebuff(102051) -- Frostjaw
		:AddDebuff(84721) -- Frozen orb
		
		:AddCooldown(2136,008) -- Fire Blast
		:AddCooldown(44425,003) -- Arcane Barrage

		:AddCasterBuffs()
		
		local poly = FW:SpellName(118);
		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == poly then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("PolymorphBreak",unit);
			end
		end);
		ST:RegisterOnTimerFade(poly,"PolymorphFade");
		
		--[[local clearcasting = FW:SpellName(12536);
		ST:RegisterOnBuffGain(function(buff)
			if buff == clearcasting then
				FW:PlaySound("TimerClearcastingSound");
			end
		end);]]
		
	end
	if CD then
		CD:AddHiddenCooldown(nil,86949,60); -- Cauterize
		CD:AddCasterPowerupCooldowns();
	end

	FW:SetMainCategory(FWL.RAID_MESSAGES);

	if ST then

		FW:SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2);
			FW:AddOption("INF",FWL.BREAK_FADE_HINT1);
			FW:AddOption("MS2",FWL.POLYMORPH_BREAK,		"",    "PolymorphBreak");
			FW:AddOption("MS2",FWL.POLYMORPH_FADE,		"",    "PolymorphFade");

	--[[FW:SetMainCategory(FWL.SOUND);
		FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
			FW:AddOption("SND",FWL.CLEARCASTING,"","TimerClearcastingSound");]]
	end
	
	FW.Default.PolymorphBreak = 	{[0]=0,">> Polymorph on %s Broke Early! <<"};
	FW.Default.PolymorphFade = 		{[0]=0,">> Polymorph on %s Fading in 3 seconds! <<"};

end