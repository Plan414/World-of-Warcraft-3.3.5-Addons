--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0
-- Module started by Destard/Stormstalker fixes by Caleb & Xus

if FW.CLASS == "HUNTER" then
	local FW = FW;
	local FWL = FW.L;
	local HT = FW:ClassModule("Hunter");

	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");

	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(0) -- set abilities to not use haste in their durations by default

		:AddSpell(20736,   6,"Crowd",	F.UNIQUE) -- Distracting Shot
		
		:AddSpell( 1543,  20,"Crowd",	F.UNIQUE+F.NOTARGET) -- Flare
		:AddSpell( 1130, 300,"Crowd",	F.UNIQUE) -- Hunter's Mark
		:AddSpell( 1513,  20,"Crowd",	F.UNIQUE) -- Scare Beast
		:AddSpell(  136,  10,"Pet",		F.NOTARGET) -- Mend Pet
		:AddSpell( 6991,  10,"Pet",		F.NOTARGET) -- Feed Pet
		:AddSpell( 1978,  15,"Default",	F.TICKS) -- Serpent Sting
		:AddSpell(53301,   2,"Default"):SetTickSpeed(1) -- Explosive Shot
		
		:AddSpell(82654,  30,"Crowd") -- Widow Venom
		:AddSpell( 5116,   4,"Crowd") -- Concussive Shot
		:AddSpell(19503,   4,"Crowd",	F.UNIQUE) -- scatter shot
		:AddSpell(19386,  30,"Crowd",	F.UNIQUE) -- wyvern sting
		:AddSpell(34490,   3,"Crowd",	F.UNIQUE) -- silencing shot
		:AddSpell(50245,   4,"Pet") -- pet pin
		
		:AddSpell( 3674,  15,"Default",	F.TICKS):SetTickSpeed(2) -- black arrow
		:AddSpell(53234, 000,"Default",	F.TICKS):SetTickSpeed(1) -- Piercing Shots
		
		:AddSpell(131894, 30,"Default",F.TICKS):SetTickSpeed(1) -- A Murder of Crows DOES NOT HAVE A DURATION DISPLAYED INGAME
		-- HAVE TO ADD SOMETHING FOR BINDING SHOT

		:AddCooldown(781,025):SetCooldownModGlph(56844,-5) -- Disengage

		-- pet buffs/debuffs
		--:AddSpell(19615, 0,010,0,"Default") -- Frenzy Effect on pet

		:AddBuff(90355) -- Bloodlust / Heroism - Core Hound E
		:AddBuff(90361) -- Spirit Mend - Spirit Beast E
		:AddBuff(90363) -- Stat Boost (Bok) - Shale Spider
		:AddBuff(90364) -- Stamina Buff - Silithid E
		:AddBuff(24604) -- Critical Strike Buff - Wolf/Dog
		:AddBuff(90309) -- Critical Strike Buff - Devilsaur
		

		:AddSpell(58604,  10,"Pet") -- Casting Speed Reduction - Core Hound E
		:AddSpell(50274,   9,"Pet") -- Casting Speed Reduction - Sporebat
		:AddSpell(50285,   8,"Pet") -- Attack Speed Reduction - Tallstrider
		:AddSpell(90314,   8,"Pet") -- Attack Speed Reduction - Fox
		:AddSpell(50433,   6,"Pet") -- Movement speed Reduction - Crocolisk
		:AddSpell(54644,   5,"Pet") -- Movement speed Reduction - Chimaera E
		:AddSpell(35346,   6,"Pet") -- Movement speed Reduction - Warp Stalker
		:AddSpell(54680,   8,"Pet") -- Healing Debuff - Devilsaur E
		:AddSpell(54706,   5,"Pet") -- Root - Silithid E
		:AddSpell( 4167,   5,"Pet") -- Root - Spider
		:AddSpell(50318,   2,"Pet") -- Silence / Interrupt - Moth
		:AddSpell(50498,  30,"Pet") -- Armor Reduction (Sunder Armor) - Raptor
		:AddSpell(35290,  15,"Pet") -- Increased Bleed Damage - Boar
		:AddSpell(34889,  45,"Pet") -- Increased Magic Damage - Dragonhawk
		:AddSpell(24844,  45,"Pet") -- Increased Magic Damage - Wind Serpent
		:AddSpell(55749,  25,"Pet") -- Increased Physical Damage - Worm E
		:AddSpell(50518,  25,"Pet") -- Increased Physical Damage - Ravager
		:AddSpell(50519,   2,"Pet") -- Stun - Bird of Pray ?
		:AddSpell(56626,   2,"Pet") -- Stun - Wasp
		:AddSpell(50256,  15,"Pet") -- Physical Damage Reduction - Bear
		:AddSpell(50541,  10,"Pet") -- Disarm - Scorpid
		:AddSpell(24394,   3,"Pet") -- Intimidation

		-- hunter buffs
		:AddBuff(82692) -- Focus Fire <NNF>
		:AddBuff(34692) -- The Beast Within
		:AddBuff( 3045) -- Rapid Fire
		:AddBuff(56453) -- Lock and Load
		:AddBuff(40487) -- Deadly Aim
		:AddBuff(53271) -- Master's call
		:AddBuff(19263) -- Deterrence
		:AddBuff(34477) -- Misdirection
		:AddBuff(53304) -- Sniper Training
		:AddBuff(34839) -- Master Tactician
		:AddBuff(70728) -- Exploit Weakness (t10)
		:AddBuff(63087) -- Glyph of Raptor Strike
		:AddBuff(77769):SetStacks(0) -- Trap Launcher
		:AddBuff(105919) -- Wyrmstalker 4set bonus, Chronohunter
		:AddBuff(53220) -- Improved Steady Shot
		
		:AddBuff(93435) -- Roar of Courage
		:AddBuff(82726):SetTickSpeed(1) -- Fervor
		:AddBuff(51755) -- Camouflage

		:AddSpell(34600,  60,"Crowd",	F.NOTARGET)-- Snake Trap
		:AddSpell(13809,  60,"Crowd",	F.NOTARGET)-- Ice Trap
		:AddSpell(13813,  60,"Crowd",	F.NOTARGET)-- Explosive Trap
		:AddSpell(13795,  60,"Crowd") -- Immolation Trap
		:AddSpell( 1499,  60,"Crowd") -- Freezing Trap
			
		--debuffname
		:AddDebuff(3355) -- Freezing Trap Effect
		:AddDebuff(1130) -- Hunter's Mark
		:AddDebuff(20736) -- Distracting Shot
		:AddDebuff(35101) -- Concussive Barrage

		:AddMeleeBuffs()
		:AddCasterBuffs()
		do
			local steady_shot = FW:SpellName(56641);
			FW:RegisterSpecialCastTime(53220,
				function()
					if FW.SpellInfo[steady_shot] then
						return FW.SpellInfo[steady_shot][2]*2;
					end
				end
			);
		end
		do
			local explosive_trap = FW:SpellName(13813); -- use name instead of id because of possible diff ids
			local ice_trap = FW:SpellName(13809); -- use name instead of id because of possible diff ids
			local snake_trap = FW:SpellName(34600); -- use name instead of id because of possible diff ids
			local PLAYER = FW.PLAYER;
			local select = select;
			local strsub = strsub;
			local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE;
			local band = bit.band;
			local SNAKE1 = FWL.SNAKE1;
			
			local function HT_CombatLogEvent(event,...)
				if select(5,...) == PLAYER then
					if select(2,...) == "SPELL_AURA_APPLIED" then
						if select(13,...) == explosive_trap then
							local i = ST.ST:find(explosive_trap,8);
							if i and ST.ST[i][15] == 1 then
								ST.ST[i][1] = GetTime()+20;
								ST.ST[i][14] = 0;
								ST.ST[i][15] = 0; -- use this to set as already triggered
								ST.ST[i][12] = 0; -- reset the fade event on refresh
							end
						elseif select(13,...) == ice_trap then
							local i = ST.ST:find(ice_trap,8);
							if i and ST.ST[i][15] == 1 then
								ST.ST[i][1] = GetTime()+30;
								ST.ST[i][14] = 0;
								ST.ST[i][15] = 0; -- use this to set as already triggered
								ST.ST[i][12] = 0; -- reset the fade event on refresh
							end
						end
					end
				elseif select(2,...) == "SWING_DAMAGE" then
					-- pet is mine and it's a snake
					if select(5,...) == SNAKE1 and band(select(6,...),COMBATLOG_OBJECT_AFFILIATION_MINE)>0 then
						local i = ST.ST:find(snake_trap,8);
						if i and ST.ST[i][15] == 1 then
							ST.ST[i][1] = GetTime()+15;
							ST.ST[i][14] = 0;
							ST.ST[i][15] = 0; -- use this to set as already triggered
							ST.ST[i][12] = 0; -- reset the fade event on refresh
						end
					end
				end
			end
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	HT_CombatLogEvent);
		end

	end
	if CD then
		tinsert(CD.Masters,{"^"..FW:SpellName(13795)}); -- immolation trap
		tinsert(CD.Masters,{"^"..FW:SpellName(1499)}); -- freezing trap

		CD:AddMeleePowerupCooldowns();
		CD:AddCasterPowerupCooldowns();

		CD:AddHiddenCooldown(nil,56453,22); -- Lock and Load
		CD:AddHiddenCooldown(nil,105919,105); -- Wyrmstalker 4set bonus, Chronohunter

		local readiness = FW:SpellName(23989);
		local bestial_wrath = FW:SpellName(19574);

		CD:RegisterOnCooldownUsed(function(s,d)
			if s == readiness then
				local i = 1; -- needs testing, but should work in theory
				while i<=CD.CD.rows do
					if CD.CD[i][6]==1 then -- FLAG_SPELL only
						local spell = CD.CD[i][1];
						if spell ~= readiness and spell ~= bestial_wrath then
							CD:CheckCooldown(spell,GetTime(),0,"",1);
						end
					end
					i=i+1;
				end
			end
		end);
	end
end