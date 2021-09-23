--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

if FW.CLASS == "WARLOCK" then
	local FW = FW;
	local WL = FW:ClassModule("Warlock");
	local FWL = FW.L;
	
	local UnitName = FW.FullUnitName;
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	FW:RegisterSet("Voidheart Raiment",28963,28968,28966,28967,28964);
	FW:RegisterSet("Vestments of the Faceless Shroud",
	76339,76340,76341,76342,76343,
	78776,78797,78816,78844,78825,
	78681,78702,78721,78749,78730);


	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(1)
		
		-- id/name, hastarget, tickspeed
		:AddChannel( 1120,1,3) -- Drain Soul
		:AddChannel(103103,1,1) -- Malefic Grasp
		:AddChannel(  689,1,1) -- Drain Life
		:AddChannel(108371,1,1) -- Harvest Life
		
		:AddChannel( 1949,0,1) -- Hellfire
		:AddChannel( 5740,0,2) -- Rain of Fire
		-- RAIN OF FIRE IS NOT CHANNELED IN DESTRUCTION
		
		-- 108647 -- Burning Embers
		:AddSpell(  348,  15,"Default",	F.TICKS+F.REFRESH):SetStacks(0):SetSpellModSetB("Voidheart Raiment",4,3) -- Immolate, refresh by Fel Flame
		:AddSpell(  172,  18,"Default",	F.TICKS+F.REFRESH):SetTickSpeed(2):SetSpellModSetB("Voidheart Raiment",4,3)-- Corruption, refresh by Life Drain, Drain Soul, Haunt
		:AddSpell(30108,  15,"Default",	F.TICKS+F.REFRESH):SetTickSpeed(2)-- Unstable Affliction, refresh by Fel Flame
		
		:AddSpell( 5740,   8,"Default",	F.AOE_DMG):SetTickSpeed(2) -- Rain of Fire

		:AddSpell(80240,  15,"Bane") -- Havoc THIS IS NOW ALSO A SELF BUFF WITH 3 STACKS
		:AddSpell(  980,  24,"Bane",	F.TICKS):SetTickSpeed(2):SetSpellModGlph(56241,4) -- Agony
		:AddSpell(  603,  60,"Bane",	F.TICKS):SetTickSpeed(15) -- Doom
		
		:AddSpell( 1490, 300,"Curse",	F.SHARED) -- Curse of the Elements
		:AddSpell(109466, 30,"Curse",	F.SHARED) -- Curse of Enfeeblement
		:AddSpell(46434,  30,"Curse",	F.SHARED):SetDurationPVP(12) -- Curse of Exhaustion
		
		:AddSpell(  710,  30,"Crowd",	F.UNIQUE):SetDurationPVP(10) -- Banish
		:AddSpell( 5782,  20,"Crowd",	F.UNIQUE):SetDurationPVP(10) -- Fear
		:AddSpell( 6789,   3,"Crowd",	F.UNIQUE) -- Mortal coil
		:AddSpell( 5484,   8,"Crowd",	F.AOE) -- Howl of Terror
		
		:AddSpell( 1098, 300,"Pet",		F.CHARM) -- Enslave Demon
		:AddSpell( 1122,  60,"Pet",		F.SUMMON):SetSpellModSetB("Vestments of the Faceless Shroud",2,30) -- Infernal
		:AddSpell(18540,  60,"Pet",		F.SUMMON):SetSpellModSetB("Vestments of the Faceless Shroud",2,30) -- Doomguard
		
		:AddSpell(111859, 20,"Pet",		F.SUMMON) -- Grimoire: Imp
		:AddSpell(111895, 20,"Pet",		F.SUMMON) -- Grimoire: Voidwalker
		:AddSpell(111896, 20,"Pet",		F.SUMMON) -- Grimoire: Succubus
		:AddSpell(111897, 20,"Pet",		F.SUMMON) -- Grimoire: Felhunter
		:AddSpell(111898, 20,"Pet",		F.SUMMON) -- Grimoire: Felguard
		
		:AddSpell( 5697, 600,"Buff",	F.BUFF) -- Unending Breath
		:AddSpell(48181, 000,"Default") -- Haunt (12sec set to 0 for travel time)
		:AddSpell(27243,  18,"Default",	F.TICKS) -- SoC
		:AddSpell(30283,   3,"Crowd",	F.AOE) -- Shadowfury
		
		:AddSpell(47960, 000,"Default",	F.TICKS):SetTickSpeed(1) -- Shadowflame,  Hand of Gul'dan NEED TO LOOK AT THIS
		
		:AddSpell(109773,3600,"Buff",	F.BUFF) -- Dark Intent
		:AddSpell( 6358,  30,"Pet") -- Seduction
		:AddSpell(115268, 30,"Pet") -- Mesmerize
				
		:AddCooldown(17962,012):SetCooldownModGlph(56235,-2) -- Conflag
		:AddCooldown(105174,015) -- Hand of Gul'dan NEED TO LOOK AT THIS
		
		--buffname
		:AddBuff(48018) -- Demonic Circle: Summon
		:AddBuff(37378) -- Shadowflame
		:AddBuff(37379) -- Flameshadow 
		:AddBuff(17941) -- Shadow Trance
		:AddBuff(51439) -- Backlash
		:AddBuff(103958) -- Metamorphosis
		:AddBuff(122351) -- Molten Core
		:AddBuff(117828) -- backdraft
		:AddBuff(61595) -- demonic soul (t7 bonus)
		:AddBuff(61082) -- spirits of the damned (t7 bonus)
		:AddBuff(70840) -- Devious Minds
		:AddBuff(7812) -- Sacrifice
			
		:AddBuff(57669) -- Replenishment
		
		:AddBuff(108559) -- Demonic Rebirth
		:AddBuff(89937) -- Fel Spark
		
		:AddBuff(111400) -- Burning Rush
		
		
		:AddBuff(108359) -- Dark Regeneration
		:AddBuff(110913) -- Dark Bargain
		:AddBuff(104773) -- Unending Resolve
		:AddBuff(108416) -- Sacrificial Pact
		:AddBuff(113858) -- Dark Soul: Instability
		:AddBuff(113860) -- Dark Soul: Misery
		:AddBuff(113861) -- Dark Soul: Knowledge
		
		-- important debuffs from others i want to track
		:AddDebuff(710) -- Banish
		:AddDebuff(5782) -- Fear
		:AddDebuff(1098) -- Enslave Demon
		:AddDebuff(5484) -- Howl of Terror
		

		:AddCasterBuffs()

		FW.InstanceDefault.Timer.Filter[FW:SpellName(48018)] = {nil,{-2,0.00,0.67,0.00}}; -- Demonic Circle: Summon
	end
	
	local t1,t2,t3,t4,t5,t6;
	local BP = {};
	
	local bp = FW:SpellName(6307);
	
	local function WL_ScanBloodpact(unit)
		local unitClass = select(2,UnitClass(unit));
		local unitName = UnitName(unit);
		if not unitClass or not unitName then return; end
		t1 = strlower(FW.Settings.BloodPact[1]);
		if strfind(t1,strlower(unitName)) or strfind(t1,strlower(unitClass)) or strfind(t1,"all") or (unit == "player" and strfind(t1,"self")) then
			t2 = UnitBuff(unit,bp);
			if BP[unitName] ~= t2 then
				if FW.Settings.BloodPact[0] then
					if t2 then
						FW:Show(string.format(FWL._GAINED_BLOOD_PACT,unitName),unpack(FW.Settings.BloodpactGainColor));
					else
						FW:Show(string.format(FWL._LOST_BLOOD_PACT,unitName),unpack(FW.Settings.BloodpactLossColor));
					end
				end
				BP[unitName] = t2;
			end
		end
	end
	local function WL_BloodpactScan()
		FW:ForGroupMembers(WL_ScanBloodpact);
	end
		
	FW:RegisterVariablesEvent(function()
		FW:RegisterTimedEvent("UpdateInterval",		WL_BloodpactScan);
	end);
	
	local devour = FW:SpellName(19505);
	local clone = FW:SpellName(115284);
	
	local spelllock = FW:SpellName(19647);
	local opticalblast = FW:SpellName(115781);
	
	--local consume = FW:SpellName(17767);
	local seduction = FW:SpellName(6358);
	local mesmerize = FW:SpellName(115268);
	
	if CA then
		local sscast = FW:SpellName(20707);
		local summon = FW:SpellName(46546);
		local meeting = FW:SpellName(23598);
		local ritual = FW:SpellName(34143);
		
		CA:RegisterIsChannel(summon);
		
		CA:RegisterOnSelfCastStart(function(s,t)
			if s == summon then
				CA:CastShow("SummonStart",t);
			elseif s == sscast then
				CA:CastShow("SoulstoneStart",t);

			end
		end);
		CA:RegisterOnSelfCastCancel(function(s,t)
			if s == sscast then
				CA:CastShow("SoulstoneCancel",t); 
			elseif s == summon then
				CA:CastShow("SummonCancel",t);
			end
		end);
		CA:RegisterOnSelfCastSuccess(function(s,t,rank)
			if s == sscast then
				CA:CastShow("SoulstoneSuccess",t);
			elseif s == summon then
				CA:CastShow("SummonFinish",t);
			elseif s == ritual then
				CA:CastShow("SoulwellStart");
			elseif spell == seduction or spell == mesmerize then
				CA:CastShow("SeduceSuccess",t);
			end
		end);
		CA:RegisterOnPetCastSuccess(function(spell)
			if spell == devour or spell == clone then
				CA:CastShow("DevourMagicSuccess");
			elseif spell == spelllock or spell == opticalblast then
				CA:CastShow("SpellLockSuccess");
			end
		end);
		CA:RegisterOnPetCastFailed(function(spell)
			if spell == devour or spell == clone then
				CA:CastShow("DevourMagicFailed");
			elseif spell == spelllock or spell == opticalblast then
				CA:CastShow("SpellLockFailed");
			elseif spell == seduction or spell == mesmerize then
				CA:CastShow("SeduceFailed");
			end
		end);
		local function DelayedSeduceMessage()
			CA:CastShow("SeduceStart",(UnitName("pettarget")) or "?" );
		end
		CA:RegisterOnPetCastStart(function(spell)
			if spell == seduction or spell == mesmerize then
				FW:DelayedExec(FW.Settings.PetTargetDelay,1,DelayedSeduceMessage);
			end
		end);
	end
	if ST then
		local fear = FW:SpellName(5782);
		local banish = FW:SpellName(710);
		local enslave = FW:SpellName(1098);

		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == fear then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("FearBreak",unit);
				return 1;
			elseif spell == banish then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("BanishBreak",unit);
				return 1;
			elseif spell == enslave then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("EnslaveBreak",unit);
				return 1;
			elseif spell == seduction  or spell == mesmerize then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("SeduceBreak",unit);
				return 1;
			end
		end);
		ST:RegisterOnTimerFade(fear,"FearFade");
		ST:RegisterOnTimerFade(banish,"BanishFade");
		ST:RegisterOnTimerFade(enslave,"EnslaveFade");
		ST:RegisterOnTimerFade(seduction,"SeduceFade");
		ST:RegisterOnTimerFade(mesmerize,"SeduceFade");

		local backlash = FW:SpellName(51439);
		local shadowtrance = FW:SpellName(17941);
		--local decimation = FW:SpellName(63158);
		ST:RegisterOnBuffGain(function(buff)
			if buff == backlash or buff == shadowtrance then
				FW:PlaySound("TimerInstantSound");
			end
		end);
	end
	if CD then
		local _,gost = FW:SpellName(108501); -- Grimoire texture
		local gos = FW:SpellName(111859); -- Grimoire: Imp as master
		tinsert(CD.Masters,{"^"..gos,gost});
	
	
		CD:RegisterOnCooldownReady(function(spell)
			if spell == devour or spell == clone then
				CA:CastShow("DevourMagicReady");
			elseif spell == spelllock or spell == opticalblast then
				CA:CastShow("SpellLockReady");
			end
		end);
		
		CD:AddCooldownBuff(18789); -- burning wish
		CD:AddCooldownBuff(18792); -- fel energy
		CD:AddCooldownBuff(35701); -- touch of shadow
		CD:AddCooldownBuff(18790); -- fel stamina
		
		CD:AddHiddenCooldown(nil,34936,08); -- Backlash	
		--CD:AddHiddenCooldown(nil,85113,15); -- Improved Soul Fire
		CD:AddHiddenCooldown(nil,108559,120); -- Demonic Rebirth
		
		CD:AddCasterPowerupCooldowns();
	end
	
	FW:SetMainCategory(FWL.RAID_MESSAGES);
		
		if CA then
		FW:SetSubCategory(FWL.SUMMONING,FW.ICON.SPECIFIC,2);
			FW:AddOption("MS2",FWL.SUMMON_PORTAL,		"",	"SummonFinish");
							  
		FW:SetSubCategory(FWL.SOULSTONE_NORMAL,FW.ICON.SPECIFIC,2);
			FW:AddOption("MS2",FWL.SOULTONE_START,		"",	"SoulstoneStart");
			FW:AddOption("MS2",FWL.SOULTONE_CANCEL,		"",	"SoulstoneCancel");
			FW:AddOption("MS2",FWL.SOULTONE_SUCCESS,	"",	"SoulstoneSuccess");
			FW:AddOption("MSG",FWL.SOULTONE_START_W,	"",	"SoulstoneStartWhisper"):SetSpan(2);
			FW:AddOption("MSG",FWL.SOULTONE_CANCEL_W,	"",	"SoulstoneCancelWhisper"):SetSpan(2);
			FW:AddOption("MSG",FWL.SOULTONE_SUCCESS_W,	"",	"SoulstoneSuccessWhisper"):SetSpan(2);
			
		FW:SetSubCategory(FWL.SOULWELL,FW.ICON.SPECIFIC,2);
			FW:AddOption("MS2",FWL.SOULWELL,			"",	"SoulwellStart");
		end

		FW:SetSubCategory(FWL.PET,FW.ICON.SPECIFIC,2);
			if CA then
			FW:AddOption("MS2",FWL.SEDUCE_START,		"",	"SeduceStart");
			FW:AddOption("MS2",FWL.SEDUCE_SUCCESS,		"",	"SeduceSuccess");
			FW:AddOption("MS2",FWL.SEDUCE_FAILED,		"",	"SeduceFailed");
			end
			if ST then
			FW:AddOption("MS2",FWL.SEDUCE_BREAK,		"",	"SeduceBreak");
			FW:AddOption("MS2",FWL.SEDUCE_FADE,			"",	"SeduceFade");
			end
			if CA then
			FW:AddOption("MS2",FWL.SPELL_LOCK_SUCCESS,	"",	"SpellLockSuccess");
			FW:AddOption("MS2",FWL.SPELL_LOCK_FAILED,	"",	"SpellLockFailed");
			end
			if CD then
			FW:AddOption("MS2",FWL.SPELL_LOCK_READY,	"",	"SpellLockReady");
			end
			if CA then
			FW:AddOption("MS2",FWL.DEVOUR_MAGIC_SUCCESS,"",	"DevourMagicSuccess");
			FW:AddOption("MS2",FWL.DEVOUR_MAGIC_FAILED,	"",	"DevourMagicFailed");
			end
			if CD then
			FW:AddOption("MS2",FWL.DEVOUR_MAGIC_READY,	"",	"DevourMagicReady");
			end
		if ST then
		FW:SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2);
			FW:AddOption("INF",FWL.BREAK_FADE_HINT1);
			FW:AddOption("MS2",FWL.FEAR_BREAK,		"",	"FearBreak");
			FW:AddOption("MS2",FWL.FEAR_FADE,		"",	"FearFade");
			FW:AddOption("MS2",FWL.BANISH_BREAK,	"",	"BanishBreak");
			FW:AddOption("MS2",FWL.BANISH_FADE,		"",	"BanishFade");
			FW:AddOption("MS2",FWL.ENSLAVE_BREAK,	"",	"EnslaveBreak");
			FW:AddOption("MS2",FWL.ENSLAVE_FADE,	"",	"EnslaveFade");
		end
		
	if ST then
	FW:SetMainCategory(FWL.SPELL_TIMER):SetSubCategory(FWL.MY_SPELLS)
		:AddOption("CO2",FWL.CURSE,	"",				"Curse"):SetFunc(ST.FilterChange)
		:AddOption("CO2",FWL.BANE,	"",				"Bane"):SetFunc(ST.FilterChange)

	FW:SetMainCategory(FWL.SOUND):SetSubCategory(FWL.SPELL_TIMER)
		:AddOption("SND","Instant","","TimerInstantSound")
	end

	FW:SetMainCategory(FWL.SELF_MESSAGES):SetSubCategory(FWL.BLOOD_PACT,FW.ICON.BASIC,2)
		:AddOption("MSG",FWL.BLOOD_PACT_ON,	FWL.BLOOD_PACT_TT,	"BloodPact")
		:AddOption("COL",FWL.BLOOD_PACT_GAIN,		"",		"BloodpactGainColor")
		:AddOption("COL",FWL.BLOOD_PACT_LOSS,		"",		"BloodpactLossColor")
	
	if CA then
	FW:SetMainCategory(FWL.ADVANCED):SetSubCategory(FWL.CASTING)
		:AddOption("NUM",FWL.DELAY_PET_TARGET		,"",	"PetTargetDelay"):SetRange(0.1,1)
	end
	FW.Default.PetTargetDelay = 0.5; -- delay between pet cast start and target check

	FW.Default.SoulstoneSuccessWhisper = 	{[0]=true,">> You are now soulstoned! <<"};
	FW.Default.SoulstoneStartWhisper = 		{[0]=false,">> Soulstoning you now <<"};
	FW.Default.SoulstoneCancelWhisper = 	{[0]=false,"<< Soulstoning cancelled >>"};

	FW.Default.SummonFinish = 				{[0]=1,">> Opening Summoning Portal << Clicky clicky!"};
	FW.Default.SoulstoneSuccess = 			{[0]=0,"Soulstoned >> %s << Use it well!"};
	FW.Default.SoulstoneStart = 			{[0]=1,"Soulstoning >> %s << Now"};
	FW.Default.SoulstoneCancel = 			{[0]=1,"Soulstoning >> %s << Cancelled"};

	FW.Default.SeduceSuccess = 				{[0]=0,"Seduced >> %s << Don't hit it!"};
	FW.Default.SeduceStart = 				{[0]=0,"Seducing >> %s << Now"};
	FW.Default.SeduceFailed = 				{[0]=0,">> Seduction Failed! <<"};
	FW.Default.SeduceBreak = 				{[0]=1,">> Seduction on %s Broke Early! <<"};
	FW.Default.SeduceFade = 				{[0]=1,">> Seduction on %s Fading in 3 seconds! <<"};
	
	FW.Default.DevourMagicSuccess = 		{[0]=0,">> Devour Magic Used <<"};
	FW.Default.DevourMagicFailed = 			{[0]=0,">> Devour Magic Failed! <<"};
	FW.Default.DevourMagicReady = 			{[0]=0,">> Devour Magic ready <<"};

	FW.Default.SpellLockSuccess = 			{[0]=0,">> Spell Lock Used <<"};
	FW.Default.SpellLockFailed = 			{[0]=0,">> Spell Lock Failed! <<"};
	FW.Default.SpellLockReady = 			{[0]=0,">> Spell Lock ready <<"};
	
	FW.Default.SoulwellStart = 				{[0]=0,"Summoning >> Soulwell << Yummie!"};
	FW.Default.RitualOfDoomStart = 			{[0]=0,"Want to end it all? Clicky clicky!"};
	
	FW.Default.FearBreak = 					{[0]=0,">> Fear on %s Broke Early! <<"};
	FW.Default.FearFade = 					{[0]=0,">> Fear on %s Fading in 3 seconds! <<"};
	FW.Default.BanishBreak = 				{[0]=1,">> Banish on %s Broke Early! <<"};
	FW.Default.BanishFade = 				{[0]=1,">> Banish on %s Fading in 3 seconds! <<"};
	FW.Default.EnslaveBreak = 				{[0]=1,">> Enslave on %s Broke Early! <<"};
	FW.Default.EnslaveFade = 				{[0]=1,">> Enslave on %s Fading in 3 seconds! <<"};

	FW.Default.BloodPact = 			{[0]=false,"warrior self"};
	FW.Default.BloodpactGainColor = {1.00,0.40,0.00};
	FW.Default.BloodpactLossColor = {1.00,0.00,0.00};
	
	if CD then
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(48020)] = 		{nil,nil,{-2,0.00,0.67,0.00}}; -- Demonic Circle: Teleport
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(6789)] = 		{nil,nil,{-2,0.00,0.63,0.05}};--death coil
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(6229)] = 		{nil,nil,{-2,0.63,0.00,1.00}};--shadow ward
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(91713)] = 		{nil,nil,{-2,0.63,0.00,1.00}};--nether ward
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(29893)] = 		{nil,nil,{-2,0.64,0.21,0.93}};--ritual of souls
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(29858)] = 		{nil,nil,{-2,0.00,0.38,1.00}};--soulshatter
		FW.InstanceDefault.Cooldown.Filter[FW:SpellName(34936)] = 		{nil,nil,{-1}};--backlash
	end
end
