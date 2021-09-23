--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

if FW.CLASS == "DEATHKNIGHT" then
	local FW = FW;
	local FWL = FW.L;
	local DK = FW:ClassModule("DeathKnight");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");
	
	if ST then
		local F = ST.F;
		CA:SetGCDStance(3,1.0);
		
		ST:SetDefaultHasted(0)
		:AddSpellRemap(45477,55095) -- Icy Touch to Frost Fever
		:AddSpellRemap(45462,59879) -- Plague Strike to Blood Plague

		:AddSpell(55095,  21,"Default",	F.TICKS+F.REFRESH) -- Frost Fever, refreshed by Festering Strike
		:AddSpell(59879,  21,"Default",	F.TICKS+F.REFRESH) -- Blood Plague, refreshed by Festering Strike
		:AddSpell(45524,   8,"Crowd") -- Chains of Ice
		:AddSpell(47528,   4,"Crowd") -- Mind Freeze
		:AddSpell(47476,   5,"Crowd") -- Strangulate
		:AddSpell(108194,   5,"Crowd") -- Asphyxiate
		:AddSpell(49576,   3,"Crowd") -- Death Grip
		:AddSpell(56222,   3,"Crowd") -- Dark Command
		
		:AddSpell(77606,   8,"Crowd") -- Dark Simulacrum
		:AddSpell(49016,  30,"Buff",	F.BUFF) -- Unholy Frenzy
		:AddSpell(57532, 300,"Pet",		F.SUMMON) -- "Eye of Acherus"
		:AddSpell(43265,  10,"Default",	F.AOE_DMG):SetTickSpeed(1) -- D&D
		--:AddSpell(49194, 000,"Default",	F.TICKS):SetTickSpeed(1) -- Unholy Blight
		:AddSpell(51714,  20,"Default") -- Frost Vulnerability
		:AddSpell(49206,  30,"Pet",		F.SUMMON) -- Gargoyle
		:AddSpell(63560,  30,"Pet",		F.SUMMON) -- Dark Transformation
		--:AddSpell(65142, 1,000,0,ST.DEFAULT) -- Ebon Plague
		
		:AddSpell(111673, 300,"Pet",	F.CHARM) -- Control Undead
		
		
		:AddBuff(60068) -- Path of Frost
		--
		:AddBuff(55972) -- "Abominable Might"
		:AddBuff(50421) -- "Scent of Blood"
		:AddBuff(55233) -- "Vampiric Blood" (prolly not the debuff id)
		
		:AddBuff(58130) -- Icebound Fortitude
		:AddBuff(53766) -- Anti-Magic Shell		
		:AddBuff(53365) -- Unholy Strength
		:AddBuff(49028) -- Dancing Rune Weapon	
		:AddBuff(51271) -- Unbreakable Armor
		:AddBuff(50887) -- Icy Talons
		
		:AddBuff(49222) -- Bone Shield
	
		:AddBuff(52424) -- Retaliation, from DK trinket

		:AddBuff(49039) -- Lichborne
		:AddBuff(51124) -- Killing Machine (instant cast)
		
		:AddBuff(66803) -- Desolation
		:AddBuff(59052) -- Freezing Fog (no runes used for howling blast)
		:AddBuff(51460) -- Runic Corruption
		:AddBuff(81340):SetStacks(0) -- Sudden Doom
		
		:AddBuff(51052) -- Anti-Magic Zone
		:AddBuff(115994) -- Unholy Blight
		
		:AddBuff(119975) -- Conversion
		:AddBuff(96268) -- Death's Advance
		
		:AddBuff(77535) -- Blood Shield
		
		
		:AddMeleeBuffs()
		:AddCasterBuffs()
		do
			local PLAYER = FW.PLAYER;
			local select = select;
			local aotd,icon = FW:SpellName(42651);
			local aotd_active = 0;
			local aotd_ghouls = {};
			local duration = 40;
			
			ST:AddManualSpellOfType(aotd,ST.DEFAULT);
			
			CA:RegisterOnSelfChannelStart(function(spell)
				if spell == aotd then
					FW.ERASE(aotd_ghouls);
					aotd_active = 0;
				end
			end);
			
			local function DK_CombatLogEvent(event,...)
				if select(5,...) == PLAYER and select(2,...) == "SPELL_SUMMON" and select(13,...) == aotd then
					aotd_active = aotd_active + 1;
					aotd_ghouls[select(8,...)] = true;
					local startTime = GetTime();
					local i = ST.ST:find(aotd,8);
					if i then
						ST.ST[i][1] = startTime+duration;
						ST.ST[i][14] = 0;
						ST.ST[i][12] = 0; -- reset the fade event on refresh
						ST.ST[i][16] = aotd_active;
					else
						ST.ST:insert(startTime+duration,0,duration,aotd,0,ST.DEFAULT,icon,aotd,0,0,"none",0,ST.PRIOR_NONE,0,1,aotd_active,0,00000,0,startTime+duration,"Pet",1.0,0,0,0,1,"",0);
					end
				elseif aotd_active > 0 and select(2,...) == "UNIT_DIED" and aotd_ghouls[select(8,...)] then
					aotd_ghouls[select(8,...)] = nil;
					aotd_active = aotd_active - 1;
					local i = ST.ST:find(aotd,8);
					if i then
						ST.ST[i][16] = aotd_active;
						if aotd_active == 0 then
							ST:Fade(i,(ST.ST[i][1]-GetTime()<0.75) and 2 or 3);
						end
					end
				end
			end
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	DK_CombatLogEvent);
		end
		
		-- Old shaman code Code to track totems, also used for the ghoul!
		local SH_CurrentTotem = {"","","",""};
		local function SH_TotemUpdate(event,index)
			if not index or index < 1 or index > 4 then return; end 
			-- Fire = 1 Earth = 2 Water = 3 Air = 4
			local _, name, startTime, duration, icon = GetTotemInfo(index);
			--FW:Show(tostring(name))
			--FW:Show(tostring(startTime))
			--FW:Show(tostring(duration))
			if SH_CurrentTotem[index] ~= "" then
				local i = ST.ST:find(SH_CurrentTotem[index],8);
				if i then
					if name ~= "" then
						ST.ST:remove(i);
					else
						ST:Fade(i,(ST.ST[i][1]-GetTime()<0.75) and 2 or 3);
					end
				end
			end
			if name ~= "" then
				ST:AddManualSpellOfType(name,ST.DEFAULT);
				ST.ST:insert(startTime+duration,0,duration,name,0,ST.DEFAULT,icon,name,0,0,"none",0,ST.PRIOR_NONE,0,1,0,0,00000,0,startTime+duration,"Pet",1.0,0,0,0,1,"",0);
			end
			SH_CurrentTotem[index] = name;
		end
		FW:RegisterToEvent("PLAYER_TOTEM_UPDATE", SH_TotemUpdate);

	end
	if CD then
		CD:AddMeleePowerupCooldowns();
		
		local RUNETYPE_BLOOD = 1;
		local RUNETYPE_UNHOLY = 2;
		local RUNETYPE_FROST = 3;
		local RUNETYPE_DEATH = 4;
		
		local iconTextures = {
			[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood",
			[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy",
			[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost",
			[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death",
		}
		-- don't alter the texture for these group masters
		tinsert(CD.Masters,{"^"..FWL.RUNE_BLOOD});
		tinsert(CD.Masters,{"^"..FWL.RUNE_UNHOLY});
		tinsert(CD.Masters,{"^"..FWL.RUNE_FROST});
		
		local runeNames = {
			FWL.RUNE_BLOOD,
			FWL.RUNE_UNHOLY,
			FWL.RUNE_FROST,
		}
		local runeToType = {
			1,1,
			2,2,
			3,3
		}
		local runeFlags = {"RuneBlood","RuneDeath","RuneFrost"};
		-- add a system to support runes, will use new icon override system	in future	
		local function DK_RuneUpdate(event,rune--[[,usable]])
			local r = GetRuneType(rune);
			local t = runeToType[rune];
			--FW:Show(event.." "..tostring(r));
			if r then
				local start, duration, runeReady = GetRuneCooldown(rune);
				--FW:Show(start.." "..duration.." "..tostring(runeReady));
				if runeReady then
					CD:CheckCooldown(runeNames[t].." ("..rune..")",0,0,iconTextures[r],runeFlags[t])
				else
					CD:CheckCooldown(runeNames[t].." ("..rune..")",start,duration,iconTextures[r],runeFlags[t])
				end
			end
		end
		FW:RegisterVariablesEvent(function() -- make sure variables are loaded
			FW:RegisterToEvent("RUNE_POWER_UPDATE",DK_RuneUpdate);
			FW:RegisterToEvent("RUNE_TYPE_UPDATE", DK_RuneUpdate);
		end);
		
		CD:AddCooldownBuff(49222); -- bone shield
		CD:AddCooldownBuff(60068); -- path of frost
		CD:AddCooldownBuff(57330); -- horn of winter
		
		FW:SetMainCategory(FWL.COOLDOWN_TIMER);
			FW:SetSubCategory(FWL.MY_COOLDOWNS);
				FW:AddOption("CO2",FWL.RUNE_BLOOD,	"",	"RuneBlood"):SetFunc(CD.FilterChange);
				FW:AddOption("CO2",FWL.RUNE_UNHOLY,	"",	"RuneDeath"):SetFunc(CD.FilterChange);
				FW:AddOption("CO2",FWL.RUNE_FROST,	"",	"RuneFrost"):SetFunc(CD.FilterChange);
		
		FW.InstanceDefault.Cooldown.RuneBlood = {[0]=true,1.00,0.00,0.00};
		FW.InstanceDefault.Cooldown.RuneDeath = {[0]=true,0.20,0.80,0.00};
		FW.InstanceDefault.Cooldown.RuneFrost = {[0]=true,0.00,0.43,1.00};
		

	end
	if CA then
		local ibf = FW:SpellName(48792);
		local vb = FW:SpellName(55233);
		local ams = FW:SpellName(48707);
		local lb = FW:SpellName(49039);
		local drw = FW:SpellName(49028);
		local ra = FW:SpellName(61999);
		
		CA:RegisterOnSelfCastSuccess(
			function(s, t)
				if s == ibf then
					CA:CastShow("IBFStart");
				elseif s == vb then
					CA:CastShow("VBStart");
				elseif s == ams then
					CA:CastShow("AMSStart");
				elseif s == lb then
					CA:CastShow("LBStart");	
				elseif s == drw then
					CA:CastShow("DRWStart");
				elseif s == ra then
					CA:CastShow("RAStart",t);
				end
			end
		);

		FW:SetMainCategory(FWL.RAID_MESSAGES);

			FW:SetSubCategory("Self Damage Reduction",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",ibf,	 "",	"IBFStart"); 
				FW.Default.IBFStart = {[0]=1,"+++ Icebound Fortitude (12 sec) +++"};

				FW:AddOption("MS2",vb,	"",	"VBStart"); 
				FW.Default.VBStart = {[0]=1,"+++ Vamparic Blood (10 sec) +++"};

				FW:AddOption("MS2",ams,	"",	"AMSStart"); 
				FW.Default.AMSStart = {[0]=1,"+++ Anti-Magic Shell (7 sec) +++"};
				
				FW:AddOption("MS2",lb,	"",	"LBStart"); 
				FW.Default.LBStart = {[0]=1,"+++ Lichborne (10 sec) +++"};
				
				FW:AddOption("MS2",drw,	"",	"DRWStart"); 
				FW.Default.DRWStart = {[0]=1,"+++ Dancing Rune Weapon (12 sec) +++"};
				
			FW:SetSubCategory("Other",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",ra,	"",	"RAStart"); 
				FW.Default.RAStart = {[0]=1,">>> Raise Ally on %s <<<"};
	end
end
