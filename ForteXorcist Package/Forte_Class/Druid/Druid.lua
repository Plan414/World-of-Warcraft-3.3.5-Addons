--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0
-- Module started by Lurosara and some additions by 'Joseph Toth'

-- TODO:
-- Forte_Timer:
--   Feral: Feral Charge Effect (Possibly too painful to implement in a reasonable manner.)

if FW.CLASS == "DRUID" then
	local FW = FW;
	local FWL = FW.L;
	local DR = FW:ClassModule("Druid");
		
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	--
	-- Spell Timer
	--
	-- Note that the Cyclone timer is always going to be inaccurate past the first cast
	
	-- Register ID renames first!
	FW:SetCustomName(50334,FWL.BERSERK_FERAL);
	FW:SetCustomName(16979,FWL.FERAL_CHARGE_BEAR);
	FW:SetCustomName(49376,FWL.FERAL_CHARGE_CAT);
	
	FW:SetCustomName(33878,FWL.MANGLE_BEAR);
	FW:SetCustomName(33876,FWL.MANGLE_CAT);
	
	FW:SetCustomName(80964,FWL.SKULL_BASH_BEAR);
	FW:SetCustomName(80965,FWL.SKULL_BASH_CAT);
	
	FW:SetCustomName(779,FWL.SWIPE_BEAR);
	FW:SetCustomName(62078,FWL.SWIPE_CAT);
	
	FW:RegisterSet("Thunderheart Regalia",31043,31035,31040,31046,31049,34572,34446,34555);
	FW:RegisterSet("Nordrassil Raiment",30216,30217,30219,30220,30220);	
	
	if ST then
		local F = ST.F;
		--ST:AddSpellRemap(16857,770); -- Faerie Fire (Feral) -> Faerie Fire
				
		-- id/name, hastarget, tickspeed
		ST:AddChannel( 16914, 0, 1); -- Hurricane
		ST:AddChannel(127663, 0, 1); -- Astral Communion
		ST:AddChannel(106996, 0, 1); -- Astral Storm
		ST:AddChannel(740, 0, 2); -- Astral Storm
		
		-- Balance Spells
		ST:SetDefaultHasted(1)
		:AddSpell(33786, 000,"Crowd",	F.UNIQUE) -- Cyclone
		:AddSpell(19975,  30,"Crowd",	F.UNIQUE):SetDurationPVP(12) -- Entangling Roots
		:AddSpell( 2637,  40,"Crowd",	F.UNIQUE):SetDurationPVP(12) -- Hibernate
		:AddSpell(  770, 300,"Default") -- Faerie Fire
		:AddSpell(102355, 300,"Default") -- Faerie Swarm
		:AddSpell(33831,  15,"Pet",		F.SUMMON) -- Force of Nature
		:AddSpell( 5570,  12,"Default",	F.TICKS):SetTickSpeed(2) -- Insect Swarm
		:AddSpell( 8921,  12,"Default",	F.TICKS):SetTickSpeed(2):SetSpellModSetB("Thunderheart Regalia",2,3) -- Moonfire
		:AddSpell(93402,  12,"Default",	F.TICKS):SetTickSpeed(2) -- Sunfire
		
		-- Resto Spells
		:AddSpell(29166,  10,"Buff",	F.BUFF) -- Innervate
		:AddSpell(33763,   7,"Heal",	F.HOT):SetTickSpeed(1):SetStacks(3) -- Lifebloom
		:AddSpell( 8936,   6,"Heal",	F.HOT):SetTickSpeed(2):SetSpellModSetB("Nordrassil Raiment",2,6) -- Regrowth
		:AddSpell(  774,  12,"Heal",	F.HOT) -- Rejuvenation
		:AddSpell(48503,  15,"Heal",	F.BUFF) -- Living Seed
		:AddSpell(48438,   7,"Heal",	F.HOT):SetTickSpeed(1) -- Wild Growth

		-- Feral Spells
		:SetDefaultHasted(0)
		:AddSpell( 5211,   5,"Crowd",	F.UNIQUE) -- Mighty Bash
		:AddSpell(106839, 10,"Crowd",	F.UNIQUE) -- Skull Bash
		:AddSpell(   99,   3,"Crowd",	F.AOE) -- Disorienting Roar
		:AddSpell( 6795,   3,"Crowd",	F.UNIQUE) -- Growl
		:AddSpell(33878,  60,"Default") -- Mangle Bear
		:AddSpell(33876,  60,"Default") -- Mangle Cat
		:AddSpell( 9005,   3,"Default"):AddExtraSpell(9007) -- Pounce
		:AddSpell( 9007,  18,"Default",	F.TICKS) -- Pounce Bleed
		
		:AddSpell( 1822,   9,"Default",	F.TICKS) -- Rake
		:AddSpell( 1079,  12,"Default",	F.TICKS):SetTickSpeed(2) -- Rip
		:AddSpell(22570,   1,"Default",	F.UNIQUE):SetSpellModComb({1,2,3,4,5}) -- Maim
		:AddSpell(58180,  12,"Crowd") -- Infected Wounds (Movement speed slowed by 50%.)
		:AddSpell(33745,  15,"Default",	F.TICKS):SetStacks(3) -- Lacerate
		
		:AddSpell(106830, 15,"Default",	F.TICKS) -- Thrash
		
		:AddSpell(78675,  10,"Crowd",	F.AOE) -- Solar Beam
		
		:AddSpell(102351, 30,"Buff",	F.BUFF) -- Cenarion Ward
		
		:AddSpell(102795, 3,"Default", F.TICKS):SetTickSpeed(1) -- Bear Hug
		
		
		
		:AddBuff(48517) -- eclipse (solar)
		:AddBuff(48518) -- eclipse (lunar)
		:AddBuff(52610) -- savage roar
		:AddBuff(132158) -- Nature's Swiftness
		:AddBuff(102342) -- Ironbark
		
		:AddBuff(102558) -- Incarnation: Son of Ursoc
		:AddBuff(102543) -- Incarnation: King of the Jungle
		:AddBuff(102560) -- Incarnation: Chosen of Elune	

		-- Balance Buffs
		:AddBuff(22812) -- Barkskin
		:AddBuff(16689) -- Nature's Grasp
		:AddBuff(16886) -- Nature's Grace
		:AddBuff(48505) -- Starfall
		:AddBuff(77495) -- Harmony

		-- Feral Buffs
		:AddBuff(61684) -- Dash
		:AddBuff(59828) -- Enrage
		:AddBuff(22842) -- Frenzied Regeneration
		:AddBuff(5217) -- Tiger's Fury
		:AddBuff(37316) -- Nurture 2 piece Feral T5
		:AddBuff(50334) -- Berserk
		:AddBuff(61336) -- Survival Instincts
		:AddBuff(106922) -- Might of Ursoc
		:AddBuff(77761) -- Stampeding Roar
		:AddBuff(102547):SetStacks(0) -- Prowl
		:AddBuff(62606) -- Savage Defense

		-- Resto Buffs
		:AddBuff(16870) -- Clearcasting

		-- Feral Procs/Trinkets
		:AddBuff(43738) -- Primal Instinct, Idol of Terror
		
		:AddBuff(69369):SetStacks(0) -- Predator's Swiftness
		:AddBuff(90164) -- Astral Alignment Balance 4P T11 bonus
		:AddBuff(90166) -- Strength of the Panther Feral 4P T11 bonus
		
		:AddCooldown(5217,030)
		
		:AddDebuff(99) -- Disorienting Roar
		:AddDebuff(78675) -- Solar Beam
		:AddDebuff(106996) -- Astral Storm
			
		:AddCasterBuffs()
		:AddMeleeBuffs()
		
		--[[local clearcasting = FW:SpellName(12536);
		ST:RegisterOnBuffGain(function(buff)
			if buff == clearcasting then
				FW:PlaySound("TimerClearcastingSound");
			end
		end);]]

	end
	--
	-- Cooldown Timer
	--
	if CD then
		-- Note: One day, this will correctly track Clearcasting/Nature's Gasp/Nature's Grace.
		
		-- Balance buffs
		--CD:AddCooldownBuff(22812); -- barkskin
		--CD:AddCooldownBuff(53307); -- thorns

		-- Resto buffs
		CD:AddCooldownBuff(1126); -- Mark of the Wild
		CD:AddCooldownBuff(16864); -- Omen of Clarity
		
		CD:AddHiddenCooldown(nil,48517,30); -- Eclipse (Solar)
		CD:AddHiddenCooldown(nil,48518,30); -- Eclipse (Lunar)
		
		---16886CD:AddHiddenCooldown(nil,16886,60); -- Nature's Grace 
		
		-- Powerups
		CD:AddCasterPowerupCooldowns();
		CD:AddMeleePowerupCooldowns();
	end
	if ST then
	--[[FW:SetMainCategory(FWL.SOUND);
		FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
			FW:AddOption("SND",FWL.CLEARCASTING,"","TimerClearcastingSound");]]
	end
	if CA then
	
		local bs = FW:SpellName(22812);
		local si = FW:SpellName(61336);
		local fr = FW:SpellName(22842);
		
		local rebirth = FW:SpellName(20484);
		local innervate = FW:SpellName(29166);
		local tranquility = FW:SpellName(740);
		
		CA:RegisterOnSelfCastSuccess(
			function(s, t)
				if s == bs then
					CA:CastShow("BSStart");
				elseif s == si then
					CA:CastShow("SIStart");
				elseif s == fr then
					CA:CastShow("FRStart");
				elseif s == rebirth then
					CA:CastShow("RebirthStart",t);
				elseif s == innervate then
					CA:CastShow("InnervateStart",t);
				elseif s == tranquility then
					CA:CastShow("TranquilityStart");
				end
			end
		);

		FW:SetMainCategory(FWL.RAID_MESSAGES);

			FW:SetSubCategory("Self Damage Reduction",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",bs,	 "",	"BSStart"); 
				FW.Default.BSStart = {[0]=1,"+++ Barkskin (10 sec) +++"};

				FW:AddOption("MS2",si,	"",	"SIStart"); 
				FW.Default.SIStart = {[0]=1,"+++ Survival Instincts (12 sec) +++"};

				FW:AddOption("MS2",fr,	"",	"FRStart"); 
				FW.Default.FRStart = {[0]=1,"+++ Frenzied Regeneration (20 sec) +++"};
				
			FW:SetSubCategory("Other",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",rebirth,	"",	"RebirthStart"); 
				FW.Default.RebirthStart = {[0]=1,">>> Rebirth on %s <<<"};

				FW:AddOption("MS2",innervate,	"",	"InnervateStart"); 
				FW.Default.InnervateStart = {[0]=1,">>> Innervate on %s <<<"};

				FW:AddOption("MS2",tranquility,	 "",	"TranquilityStart"); 
				FW.Default.TranquilityStart = {[0]=1,">>> Tranquility up <<<"};

	end
end
