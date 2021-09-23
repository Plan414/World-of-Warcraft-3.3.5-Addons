--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0
-- Monk module for ForteXorcist

if FW.CLASS == "MONK" then

	local FW = FW;
	local FWL = FW.L;
	local PA = FW:ClassModule("Monk");
	
	local ST = FW:Module("Timer");
	local CA = FW:Module("Casting");
	local CD = FW:Module("Cooldown");

	if ST then
		local F = ST.F;
		ST:SetDefaultHasted(0)
		
		:AddChannel(117952,1,1)
		
		:AddSpell(115181,  0,"Default",F.TICKS):SetTickSpeed(2) -- Breath of Fire (only when Dizzying Haze is up)
		:AddSpell(100784,  0,"Default",F.TICKS):SetTickSpeed(1) -- Blackout Kick (only when behind target)
		
		:AddSpell(116095, 15,"Crowd") -- Disable
		:AddSpell(115180, 15,"Crowd",F.AOE) -- Dizzying Haze
		:AddSpell(119381,  5,"Crowd",F.AOE) -- Leg Sweep
		:AddSpell(119392,  3,"Crowd",F.AOE) -- Charging Ox Wave
		:AddSpell(116705,  0,"Crowd") -- Spear Hand Strike (only when in front of target)
		:AddSpell(115078, 30,"Crowd",F.UNIQUE) -- Paralysis (doubled when behind target???)
		
		:AddSpell(122470,  6,"Default",F.UNIQUE) -- Touch of Karma UNIQUE FLAG IS MISBEHAVING because of self buff
		
		:AddSpell(124081,  16,"Heal",F.HOT):SetTickSpeed(2) -- Zen Sphere
		:AddSpell(115151,  20,"Buff",F.BUFF) -- Renewing Mist
		:AddSpell(119611,  18,"Heal",F.HOT) -- Renewing Mist
		
		:AddBuff(115213) -- Avert Harm
		:AddBuff(121125):SetStacks(0) -- Death Note
		:AddBuff(115308) -- Elusive Brew
		:AddBuff(115203) -- Fortifying Brew
		:AddBuff(115295) -- Guard
		:AddBuff(119085) -- Momentum (movement speed)
		:AddBuff(125359) -- Tiger Power
		:AddBuff(115176) -- Zen Meditation
		:AddBuff(115307) -- Shuffle
		:AddBuff(122783) -- Diffuse Magic
		:AddBuff(122278) -- Dampen Harm
		:AddBuff(115288):SetTickSpeed(1) -- Energizing Brew
		:AddBuff(120273) -- Tiger Strikes
		:AddBuff(116740) -- Tigereye Brew
		:AddBuff(122470) -- Touch of Karma
		:AddBuff(116841) -- Tiger's Lust
		
		:AddBuff(116849) -- Life Cocoon
		:AddBuff(115294):SetTickSpeed(1) -- Mana Tea
		:AddBuff(116680) -- Thunder Focus Tea
		
		:AddBuff(122465) -- Dematerialize
		:AddBuff(93099) -- Vengeance
		
		:AddDebuff(115180) -- Dizzying Haze
		:AddDebuff(119381) -- Leg Sweep
		:AddDebuff(119392) -- Charging Ox Wave
		:AddDebuff(107428) -- Rising Sun Kick
		
		:AddCasterBuffs()
		:AddMeleeBuffs()
		
		do
			-- Old shaman code Code to track totems, also used for the statues!
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
			FW:RegisterDelayedLoadEvent(function(self)
				for i=1,4,1 do
					SH_TotemUpdate(self,i);
				end
			end);
		end
	end
	if CD then
		CD:AddCooldownBuff(115921); -- Legacy of the Emperor
		CD:AddCooldownBuff(116781); -- Legacy of the White Tiger	
		
		CD:AddHiddenCooldown(nil,122465,10); -- Dematerialize
		
		CD:AddCasterPowerupCooldowns();
		CD:AddMeleePowerupCooldowns();
	end
	
	--[[if CA then -- added by 'fakeh'
		
		local am = FW:SpellName(31821);
		local salv = FW:SpellName(1038);
		local sac = FW:SpellName(6940);
		local free = FW:SpellName(1044);
		local bop = FW:SpellName(1022);
		local dp = FW:SpellName(498);
		local gotak = FW:SpellName(86659);
		local ad = FW:SpellName(31850);

		CA:RegisterOnSelfCastSuccess(
			function(s, t)
				if s == am then CA:CastShow('AMStart');
				elseif s == salv then CA:CastShow('SalvStart', t);
				elseif s == sac then CA:CastShow('SacStart', t);
				elseif s == free then CA:CastShow('FreeStart', t);
				elseif s == bop then CA:CastShow('BOPStart', t);
				elseif s == dp then CA:CastShow('DPStart');
				elseif s == gotak and (GetSpecialization(nil,nil,GetActiveSpecGroup()) or 0) == 2 then CA:CastShow('GOTAKStart');
				elseif s == ad then CA:CastShow('ADStart'); end
			end
		);
		
		FW:SetMainCategory(FWL.RAID_MESSAGES);

			FW:SetSubCategory("Raid Damage Reduction",FW.ICON.SPECIFIC,2);
				FW:AddOption("MS2",am,	 "",	"AMStart"); 
				FW.Default.AMStart = {[0]=1,"+++ Aura Mastery (6sec) +++"};

			FW:SetSubCategory("Hands",FW.ICON.SPECIFIC,3);
				FW:AddOption("MS2",salv,	 "",	"SalvStart"); 
				FW.Default.SalvStart = {[0]=1,"+++ Salvation on %s (10sec) +++"};
				FW:AddOption("MS2",sac,	 "",	"SacStart"); 
				FW.Default.SacStart = {[0]=1,"+++ Sacrifice on %s (12sec) +++"};
				FW:AddOption("MS2",free,	 "",	"FreeStart"); 
				FW.Default.FreeStart = {[0]=1,"+++ Freedom on %s (6sec) +++"};
				FW:AddOption("MS2",bop,	 "",	"BOPStart"); 
				FW.Default.BOPStart = {[0]=1,"+++ Hand of Protection on %s (12sec) +++"};

			FW:SetSubCategory("Self Damage Reduction",FW.ICON.SPECIFIC,4);
				FW:AddOption("MS2",dp,	 "",	"DPStart"); 
				FW.Default.DPStart = {[0]=1,"+++ Divine Protection (10sec) +++"};
				FW:AddOption("MS2",gotak,	"",	"GOTAKStart"); 
				FW.Default.GOTAKStart = {[0]=1,"+++ Guardian of Ancient Kings (12sec) +++"};
				FW:AddOption("MS2",ad,	"",	"ADStart"); 
				FW.Default.ADStart = {[0]=1,"+++ Ardent Defender (10sec) +++"};
				
		
	end]]
end

