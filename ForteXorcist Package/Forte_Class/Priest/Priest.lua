--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

if FW.CLASS == "PRIEST" then
	local FW = FW;
	local FWL = FW.L;
	local PR = FW:ClassModule("Priest");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	FW:RegisterSet("Absolution Regalia",31061,31064,31067,31070,31065,34434,34528,34563);
	FW:RegisterSet("Velen's/Zabra's Regalia",
		48072,48073,48074,48075,48076,
		48077,48078,48079,48080,48081,
		48082,48083,48084,48085,48086,
		48087,48088,48089,48090,48091,
		48092,48093,48094,48095,48096,
		48097,48098,48099,48100,48101
	);	
		
	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(1)
		
		:AddChannel(64843,1,2) -- Divine Hymn
 		
 		:AddSpell(  589,  18,"Default",	F.TICKS+F.REFRESH):SetSpellModSetB("Absolution Regalia",2,3) -- Shadow Word: Pain
		:AddSpell(34914,  15,"Default",	F.TICKS):SetSpellModSetB("Velen's/Zabra's Regalia",2,6) -- Vampiric Touch
 		:AddSpell(34433,  12,"Pet",		F.SUMMON) -- Shadowfiend
 		:AddSpell( 8122,   8,"Crowd",	F.AOE):SetSpellModGlph(56177,2) -- Psychic Scream
 		:AddSpell( 9484,  50,"Crowd",	F.UNIQUE) -- Shackle Undead
		--:AddSpell(  453,  15,"Crowd",	F.UNIQUE) -- Mind Soothe
		:AddSpell(   17,  15,"Buff",	F.BUFF) -- Power Word: Shield
		:AddSpell(  139,  12,"Heal",	F.HOT) -- Renew
		:AddSpell( 2944,  24,"Default",	F.UNIQUE+F.TICKS):SetTickSpeed(1) -- Devouring Plague 
		:AddSpell(15487,   5,"Crowd",	F.UNIQUE) -- Silence
		:AddSpell(14914,   7,"Default",	F.TICKS):SetTickSpeed(1) -- holy fire
		:AddSpell(33076,  30,"Buff",	F.BUFF) -- Prayer of Mending
		--:AddSpell(14893,  15,"Buff",	F.BUFF) -- Inspiration
		:AddSpell(33206,   8,"Buff",	F.BUFF) -- Pain Suppression
		:AddSpell(10060,  15,"Buff",	F.BUFF) -- Power Infusion
		:AddSpell(47788,  10,"Buff",	F.BUFF) -- Guardian Spirit
		:AddSpell(47515,  12,"Buff",	F.BUFF) -- Divine Aegis (PASSIVE)
		:AddSpell(77613,  15,"Buff",	F.BUFF):SetStacks(3) -- Grace (PASSIVE)
		:AddSpell(70772,   9,"Heal",	F.HOT) -- Blessed Healing (2 set T10)
		
		:AddSpell(77485,   6,"Heal",	F.HOT):SetTickSpeed(1) -- Echo of Light
		
		:AddSpell(605,    30,"Pet",		F.CHARM) -- Dominate Mind
		
		:AddSpell(88625,   3,"Crowd",	F.UNIQUE) --Holy Word: Chastise
		
		:AddCooldown( 8092, 8) -- Mind Blast
		:AddCooldown(32379,12) -- Shadow Word: Death
		
		:AddCooldown(88625,25) -- Holy Word: Chastise 
		:AddCooldown(88684,20) -- Holy Word: Serenity 
		:AddCooldown(88686,18) -- Holy Word: Sanctuary
		----------
				
		-- id/name, hastarget, tickspeed
		:AddChannel(15407,1,1) -- Mind Flay
		:AddChannel(48045,1,1) -- Mind Sear
		
		--Priest Buffs
		:AddBuff(63735) -- Serendipity
		:AddBuff(128654) -- Surge of Light
		:AddBuff(59889) -- Borrowed Time
		--:AddBuff(34754) -- Holy Concentration
		:AddBuff(586) -- Fade
		:AddBuff(588) -- Inner fire
		:AddBuff(73413) -- Inner Will
		--:AddBuff(15257) -- Shadow Weaving
		:AddBuff(47585):SetTickSpeed(1) -- Dispersion
		:AddBuff(15286) -- Vampiric Embrace
		--:AddBuff(45237) -- Focused Will
		:AddBuff(77487) -- Shadow Orb
		--:AddBuff(95799) -- Empowered Shadow
		
		:AddBuff(81662) -- Evangelism
		--:AddBuff(87118) -- Dark Evangelism
		:AddBuff(81700) -- Archangel
		:AddBuff(87153) -- Dark Archangel
		
		-- weakened soul
 		:AddDebuff(6788)
		:AddCasterBuffs()
	end
	if CD then
		do
			local PLAYER = FW.PLAYER;
			local rapture,texture = FW:SpellName(47755); -- use name instead of id because of diff ranks
			local select = select;
			local function PR_CombatLogEvent(event,...)
				if select(5,...) == PLAYER and select(13,...) == rapture then
					CD:HiddenCooldown(rapture, 012, texture);
				end
			end
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	PR_CombatLogEvent);
		end
	
		CD:AddCasterPowerupCooldowns();
	end
end
