--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

if FW.CLASS == "ROGUE" then
	local FW = FW;
	local FWL = FW.L;
	local PR = FW:ClassModule("Rogue");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	--FW:SetCustomName(89775,FWL.HEMORRHAGE_GLYPH);
	
	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(0) -- set abilities to not use haste in their durations by default
		
		-- Abilities
		:AddSpell(  408, 000,"Crowd",	F.UNIQUE) -- Kidney Shot
		:AddSpell(108210, 000,"Crowd",	F.UNIQUE) -- Nerve Strike
		:AddSpell( 2094, 000,"Crowd",	F.UNIQUE) -- Blind
		:AddSpell( 6770, 000,"Crowd",	F.UNIQUE) -- Sap
		:AddSpell(32748, 000,"Crowd",	F.UNIQUE) -- Deadly Throw interrupt
		:AddSpell( 1330, 000,"Crowd",	F.UNIQUE) -- Garrote silence	
		:AddSpell( 1833, 004,"Crowd",	F.UNIQUE) -- Cheap Shot
		:AddSpell( 1776, 000,"Crowd",	F.UNIQUE) -- Gouge
		:AddSpell(51722, 000,"Crowd",	F.UNIQUE) -- Dismantle
		:AddSpell(79140, 020,"Crowd",	F.UNIQUE) -- Vendetta

		:AddSpell(84617, 000,"Crowd",	F.UNIQUE) -- Revealing Strike
		:AddSpell(  703, 000,"Default",	F.TICKS) -- Garrote
		:AddSpell( 1943, 000,"Default",	F.TICKS):SetTickSpeed(2) -- Rupture
		:AddSpell(16511,  24,"Default",	F.TICKS) -- Hemorrhage
		
		:AddSpell(121411, 12,"Default",	F.TICKS):SetTickSpeed(2) -- Crimson Tempest
				
		-- Poisons
		:AddSpell(30981, 000,"Crowd") -- Crippling Poison
		:AddSpell( 5760, 000,"Crowd") -- Mind-numbing Poison
		:AddSpell( 8679, 000,"Crowd") -- Wound Poison
		:AddSpell(108215,000,"Crowd") -- Paralytic Poison
		:AddSpell(113953,000,"Crowd") -- Paralysis
		:AddSpell(108211,000,"Default") -- Leeching Poison
		:AddSpell( 2818, 000,"Default",	F.TICKS) -- Deadly Poison
	
		-- Self buffs
		:AddBuff(13750) -- Adrenaline Rush
		:AddBuff(13877) -- Blade Flurry
		:AddBuff(5277) -- Evasion
		:AddBuff(2983) -- Sprint
		:AddBuff(31224) -- Cloak of Shadows
		:AddBuff(1856) -- Vanish
		:AddBuff(1966) -- Feint
		:AddBuff(60177) -- Hunger for Blood
		:AddBuff(57934) -- Tricks of the Trade
		:AddBuff(5171) -- Slice and Dice
		:AddBuff(32645) -- Envenom
		:AddBuff(73651):SetTickSpeed(3) -- Recuperate
		
		:AddBuff(84745) -- Shallow Insight
		:AddBuff(84746) -- Moderate Insight
		:AddBuff(84747) -- Deep Insight
		:AddBuff(51690) -- Killing Spree
		:AddBuff(74001) -- Combat Readiness
		:AddBuff(108212) -- Burst of Speed
		:AddBuff(51713) -- Shadow Dance
		
		:AddDebuff(113953) -- Paralysis
		:AddDebuff(108210) -- Nerve Strike
		
		:AddMeleeBuffs()

		local sap = FW:SpellName(6770);
		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == sap then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("SapBreak",unit);
			end
		end);
		ST:RegisterOnTimerFade(sap,"SapFade");		
	end
	if CD then
		-- Poisons
		CD:AddCooldownBuff(30981) -- Crippling Poison
		:AddCooldownBuff( 5761) -- Mind-numbing Poison
		:AddCooldownBuff( 8679) -- Wound Poison
		:AddCooldownBuff( 2818) -- Deadly Poison
		:AddCooldownBuff(108215) -- Paralytic Poison
		:AddCooldownBuff(108211) -- Leeching Poison
	
		:AddMeleePowerupCooldowns()
	end

	if ST then
	FW:SetMainCategory(FWL.RAID_MESSAGES):SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2)
		:AddOption("INF",FWL.BREAK_FADE_HINT1)
		:AddOption("MS2",FWL.SAP_BREAK,"","SapBreak")
		:AddOption("MS2",FWL.SAP_FADE,"","SapFade")
	end

	FW.Default.SapBreak = 	{[0]=0,">> Sap on %s Broke Early! <<"};
	FW.Default.SapFade = 	{[0]=0,">> Sap on %s Fading in 3 seconds! <<"};
	
end
