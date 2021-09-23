--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

if FW.CLASS == "WARRIOR" then
	local FW = FW;
	local FWL = FW.L;
	local WR = FW:ClassModule("Warrior");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(0) -- set abilities to not use haste in their durations by default
		
		
		:AddSpellRemap(7386,113746) -- Sunder Armor to  Weakened Armor
		:AddSpell(113746,  30,"Default"):SetStacks(3)-- Weakened Armor
		:AddSpell(  355,   3,"Crowd") -- Taunt
		:AddSpell(21008,   6,"Crowd") -- Mocking Blow
		:AddSpell(  676,  10,"Crowd") -- Disarm
		
		
		:AddSpellRemap(12294,115804) -- Mortal Strike to Mortal Wounds
		:AddSpell(115804, 10,"Default"):AddExtraSpell(115768)-- Mortal Wounds
		:AddSpell(115768, 15,"Default",	F.TICKS) -- Deep Wounds
		
		:AddSpell( 1715,  15,"Crowd") -- Hamstring
		:AddSpell( 1160,  10,"Crowd",	F.AOE) -- Demoralizing Shout 
		:AddSpell( 5246,   8,"Crowd",	F.AOE) -- Intimidating Shout
		:AddSpell( 6343,  30,"Crowd",	F.AOE) -- Thunder Clap (Weakened Blows)
		:AddSpell(12323,   6,"Crowd",	F.AOE) -- Piercing Howl
		:AddSpell(46968,   4,"Crowd",	F.AOE) -- Shockwave
		:AddSpell(114030, 12,"Buff",	F.BUFF) -- Vigilance
		:AddSpell(86346,   6,"Default") -- Colossus Smash
		
		--buffname
		:AddBuff(469) -- Commanding Shout
		:AddBuff(12880) -- Enrage
		:AddBuff(12328) -- Sweeping Strikes
		:AddBuff(12292)	-- Death Wish
		
		:AddBuff(6673) -- Battle Shout
		:AddBuff(18499) -- Berserker Rage
		:AddBuff(1719) -- Recklessness
		
		:AddBuff(118038) -- Die by the Sword
		:AddBuff(46916)	-- Slam!
		:AddBuff(85730) -- Deadly Calm
		:AddBuff(55694):SetTickSpeed(1) -- Enraged Regeneration
		:AddBuff(97462) -- Rallying Cry
		:AddBuff(23920) -- Spell Reflection
		:AddBuff(871) -- Shield Wall
		:AddBuff(12975) -- Last Stand
		:AddBuff(112048) -- Shield Barrier
		:AddBuff(2565) -- Shield Block
		
		--Debuffs (AOE spells)
		:AddDebuff(12294) -- Mortal Strike
		:AddDebuff(1715) -- Hamstring
		:AddDebuff(1160) -- Demoralizing Shout (only target damage reduction to you)
		:AddDebuff(20511) -- Intimidating Shout
		:AddDebuff(12323) -- Piercing Howl
		:AddDebuff(46968) -- Shockwave
		
		:AddDebuff(64382) -- Shattering Throw
		:AddDebuff(86346) -- Colossus Smash
		
		
		:AddMeleeBuffs()
	end
	if CD then
		CD:AddCooldownBuff(6673); -- Battle Shout
		--CD:AddHiddenCooldown(nil,60503,6); -- Taste for Blood
		CD:AddMeleePowerupCooldowns();
	end
	if CA then
	
		local sw = FW:SpellName(871);
		local ls = FW:SpellName(12975);
		local rc = FW:SpellName(97462);
		local er = FW:SpellName(55694);
		
		local intervene = FW:SpellName(3411);
		local vigilance = FW:SpellName(114030);
		--local recklessness = FW:SpellName(1719);
		
		CA:RegisterOnSelfCastSuccess(
			function(s, t)
				if s == sw then
					CA:CastShow("SWStart");
				elseif s == ls then
					CA:CastShow("LSStart");
				elseif s == rc then
					CA:CastShow("RCStart");
				elseif s == er then
					CA:CastShow("ERStart");
				elseif s == intervene then
					CA:CastShow("InterveneStart" , t);
				elseif s == vigilance then
					CA:CastShow("VigilanceStart" , t);
				--elseif s == recklessness then
					--CA:CastShow("RecklessnessStart");
				end
			end
		);

		FW:SetMainCategory(FWL.RAID_MESSAGES);
			FW:SetSubCategory("Raid Damage Reduction",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",rc,	 		"","RCStart"); 
				FW:AddOption("MS2",intervene,	"","InterveneStart"); 
				
			FW:SetSubCategory("Self Damage Reduction",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",sw,"","SWStart"); 
				FW:AddOption("MS2",ls,"","LSStart"); 
				FW:AddOption("MS2",er,"","ERStart"); 
				
			FW:SetSubCategory("Other",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",vigilance,		"","VigilanceStart"); 
				--FW:AddOption("MS2",recklessness,	"","RecklessnessStart"); 
		
		FW.Default.RCStart = 				{[0]=1,"+++ Rallying Cry (10 sec) +++"};		
		FW.Default.InterveneStart = 		{[0]=1,"+++ Intervene on %s (10 sec) +++"};				
		FW.Default.SWStart = 				{[0]=1,"+++ Shield Wall (12 sec) +++"};				
		FW.Default.LSStart = 				{[0]=1,"+++ Last Stand (20 sec) +++"};		
		FW.Default.ERStart = 				{[0]=1,"+++ Enraged Regeneration (10 sec) +++"};
		FW.Default.VigilanceStart = 		{[0]=0,">>> Vigilance on %s (12 sec) <<<"};
		--FW.Default.RecklessnessStart = 		{[0]=1,">>> Taking 20% more damage with Recklessness (12 sec) <<<"};	
	end
	
end
