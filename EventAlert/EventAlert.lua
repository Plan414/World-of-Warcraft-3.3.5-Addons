EA_Config = { DoAlertSound, AlertSound, AlertSoundValue, LockFrame, ShowFrame, ShowFlash, ShowTimer, Version, AllowESC, AllowAltAlerts, ShowSpellInfo };
EA_Position = { Anchor, relativePoint, xLoc, yLoc, xOffset, yOffset };


function EventAlert_OnLoad(self)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:RegisterEvent("COMBAT_TEXT_UPDATE");

    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("PLAYER_DEAD");
    self:RegisterEvent("ADDON_LOADED");

    SlashCmdList["EVENTALERT"] = EventAlert_SlashHandler;
    SLASH_EVENTALERT1 = "/eventalert";
    SLASH_EVENTALERT2 = "/ea";

    EA_TempBuffsTable = { };
    EA_PreLoadAlts = { };
    EA_PreLoadComplete = 0;

    EA_tempVer = "4.3.6";
end


function EventAlert_OnEvent(event)

    if (event == "ADDON_LOADED") then
        if (arg1 == "EventAlert") then

            EventAlert_VersionCheck();

            if EA_Config.AlertSound == nil then EA_Config.AlertSound = "Sound\\Spells\\ShaysBell.wav" end;
            if EA_Config.AlertSoundValue == nil then EA_Config.AlertSoundValue = 1 end;
            if EA_Config.DoAlertSound == nil then EA_Config.DoAlertSound = true end;
            if EA_Config.LockFrame == nil then EA_Config.LockFrame = true end;
            if EA_Config.ShowFrame == nil then EA_Config.ShowFrame = true end;
            if EA_Config.ShowName == nil then EA_Config.ShowName = true end;
            if EA_Config.ShowFlash == nil then EA_Config.ShowFlash = false end;
            if EA_Config.ShowTimer == nil then EA_Config.ShowTimer = true end;
            if EA_Config.IconSize == nil then EA_Config.IconSize = 60 end;
            if EA_Config.ChangeTimer == nil then EA_Config.ChangeTimer = false end;
            if EA_Config.AllowESC == nil then EA_Config.AllowESC = false end;
            if EA_Config.AllowAltAlerts == nil then EA_Config.AllowAltAlerts = false end;
            if EA_Config.ShowSpellInfo == nil then EA_Config.ShowSpellInfo = false end;

            if EA_Position.Anchor == nil then EA_Position.Anchor = "CENTER" end;
            if EA_Position.relativePoint == nil then EA_Position.relativePoint = "CENTER" end;
            if EA_Position.xLoc == nil then EA_Position.xLoc = 0 end;
            if EA_Position.yLoc == nil then EA_Position.yLoc = 0 end;
            if EA_Position.xOffset == nil then EA_Position.xOffset = 0 end;
            if EA_Position.yOffset == nil then EA_Position.yOffset = 0 end;

            if EA_SacredShield == nil then EA_SacredShield = {} end;
            if EA_SacredShield.ceArg7 == nil then EA_SacredShield.ceArg7 = "noPlayerActive" end;
            if EA_SacredShield.spellActive == nil then EA_SacredShield.spellActive = false end;
            if EA_SacredShield.expire == nil then EA_SacredShield.expire = 0 end;
            if EA_SacredShield.timer == nil then EA_SacredShield.timer = 0 end;

            _, EA_playerClass = UnitClass("player");
            EventAlert_LoadTextArray();
            EventAlert_LoadSpellArray();
            EventAlert_RemoveOldSpells();
            EventAlert_Options_Init();
            EA_Icon_Options_Init();
            EventAlert_CreateFrames();
            EventAlert_CreateCustomFrames();


            if (EA_playerClass == EA_CLASS_WARRIOR) then
                Alt_Alerts_Frame:SetWidth(325);
                Alt_Alerts_Frame:SetHeight(675);
            else
                Alt_Alerts_Frame:SetWidth(325);
                Alt_Alerts_Frame:SetHeight(500);
            end

            -- Set up Sacred Shield stuff
            EA_SacredShield.ceArg7 = "noPlayerActive";
            EA_SacredShield.expire = 0;
            EA_SacredShield.spellActive = false;

            if (EA_playerClass == EA_CLASS_PALADIN) then
                EA_nameTalent, _, _, _, EA_talentCurrentRank, _, _, _ = GetTalentInfo(2, 9);

                if (EA_talentCurrentRank == 0) then
                    EA_SacredShield.timer = 6;
                elseif (EA_talentCurrentRank == 1) then
                    EA_SacredShield.timer = 9;
                elseif (EA_talentCurrentRank == 2) then
                    EA_SacredShield.timer = 12;
                end
            end

        end
    end


    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local EA_eventType = arg2;

        -- Code specifically for Sacred Shield
        if (EA_eventType == "SPELL_CAST_SUCCESS") then
            if (arg4 == UnitName("player")) then
            	if (arg9 == 53601) then
                    EA_SacredShield.ceArg7 = arg7;
                    EA_SacredShield.spellActive = true;
                end
            end
        end

        if (EA_eventType == "SPELL_AURA_APPLIED" or EA_eventType == "SPELL_AURA_APPLIED_DOSE") then

            if (EA_Items[EA_playerClass][arg9]) then
	            if (arg9 == 58597) then
	            	if (EA_SacredShield.spellActive) then
	            		if (arg7 == EA_SacredShield.ceArg7) then
							EA_SacredShield.expire = GetTime() + EA_SacredShield.timer;
                            table.insert(EA_TempBuffsTable, arg9);
                            EventAlert_PositionFrames();
							EventAlert_DoAlert();
	                    end
	                end
	            end
            end

        	if (arg7 == UnitName("player")) then

				if (EA_Config.ShowSpellInfo) then
	        		DEFAULT_CHAT_FRAME:AddMessage("Spell Name: "..arg10.."  --  Spell ID: "..arg9);
	            end

				if (EA_Items[EA_playerClass][arg9] or EA_Items[EA_CLASS_OTHER][arg9] or EA_CustomItems[EA_playerClass][arg9]) then

                    -- Not Sacred Shield
                    if (arg9 ~= 58597) then
	                    -- Serendipity
	                    if (arg9 == 63731 or arg9 == 63734 or arg9 == 63734) then
		                    if (arg13 == 3) then
			                    table.insert(EA_TempBuffsTable, arg9);
	                            EventAlert_PositionFrames();
								EventAlert_DoAlert();
		                    end
                        -- Maelstrom Weapon
                        elseif (arg9 == 53817) then
			            	if (arg13 == 5) then
				            	table.insert(EA_TempBuffsTable, arg9);
								EventAlert_PositionFrames();
				                EventAlert_DoAlert();
							end
                        -- All other spells
                        else
                        	table.insert(EA_TempBuffsTable, arg9);
							EventAlert_PositionFrames();
							EventAlert_DoAlert();
                        end
                    end

                end
    	   	end
        end

        if (EA_eventType == "SPELL_AURA_REMOVED" or EA_eventType == "SPELL_AURA_REMOVED_DOSE") then

            if (arg9 == 53601) then
        		if (EA_SacredShield.spellActive) then
		   			if (arg7 == EA_SacredShield.ceArg7) then
						EA_SacredShield.spellActive = false;
    	            end
		        end
            end

            if (EA_Items[EA_playerClass][arg9]) then
	            if (arg9 == 58597) then
	           		if (arg7 == EA_SacredShield.ceArg7) then
						local v = table.foreach(EA_TempBuffsTable, function(i, v) if v==arg9 then return v end end)
							if v then
		                    	local f = _G["EAFrame_"..v];
			                    f:Hide();
						    	removeBuffValue(EA_TempBuffsTable, v);
								EventAlert_PositionFrames();
                                f:SetScript("OnUpdate", nil);
			                end
					end
	            end
            end

        	if (arg7 == UnitName("player")) then
	            if (EA_Items[EA_playerClass][arg9] or EA_Items[EA_CLASS_OTHER][arg9] or EA_CustomItems[EA_playerClass][arg9]) then

                    if (arg13 == nil) then
	                	local v = table.foreach(EA_TempBuffsTable, function(i, v) if v==arg9 then return v end end)
							if v then
		                    	local f = _G["EAFrame_"..v];
			                    f:Hide();
						    	removeBuffValue(EA_TempBuffsTable, v);
								EventAlert_PositionFrames();
	                            f:SetScript("OnUpdate", nil);
			                end
                    end

	            end
            end

		end
    end

	if (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD") then
		local v = table.foreach(EA_TempBuffsTable, function(i, v) if v==arg9 then return v end end)
			if v then
	        	local f = _G["EAFrame_"..v];
	            f:Hide();
				EA_TempBuffsTable = table.wipe(EA_TempBuffsTable);
			end
		EA_SacredShield.ceArg7 = "noPlayerActive";
		EA_SacredShield.spellActive = false;


        -- I'm annoyed that this code has to be here and not above in the ADDON_LOADED event.  >-(
        if (EA_PreLoadComplete == 0) then
            for i,v in pairs(EA_AltItems[EA_playerClass]) do
                local name, rank = GetSpellInfo(i);
                local EA_link = GetSpellLink(name, "");

                if (EA_link ~= nil) then
                    local _, _, spellString = string.find(EA_link, "^|c%x+|Hspell:(.+)|h%[.*%]")

                    if (EA_PreLoadAlts[name] == nil) then
                        EA_PreLoadAlts[name] = spellString;
                    elseif (EA_PreLoadAlts[name] < spellString) then
                        EA_PreLoadAlts[name] = spellString;
                    elseif (EA_PreLoadAlts[name] >= spellString) then
                        -- Do Nothing
                    end
                end
            end
        EA_PreLoadComplete = 1;
        end
	end

	if (event == "COMBAT_TEXT_UPDATE") then
    	if (EA_Config.AllowAltAlerts == true) then
            if (arg1 == "SPELL_ACTIVE") then
                 local v = table.foreach(EA_PreLoadAlts, function(i, v) if i==arg2 then return v end end)
                    if v then
                        v = tonumber(v);

                        if (EA_AltItems[EA_playerClass][v]) then
                            local v2 = table.foreach(EA_TempBuffsTable, function(i2, v2) if v2==v then return v2 end end)
                                if (not v2) then
                                    table.insert(EA_TempBuffsTable, v);
                                    EventAlert_PositionFrames();
                                    EventAlert_DoAlert();
                                end
                        end
                    end
            end
        end
    end
end

function EventAlert_OnUpdate()
    if #EA_TempBuffsTable ~= 0 then

    	-- Check for stuck buffs on the screen
        for i,v in ipairs (EA_TempBuffsTable) do
        	local check_name, check_rank = GetSpellInfo(v);

            local _, _, _, _, _, _, _, _, _, _, check_spellId = UnitBuff("player", check_name);

            if (check_spellId == nil) then
	            if (EA_AltItems[EA_playerClass][v] or v == 58597 or v == 53601) then
                 -- Do Nothing
				else
                	local v2 = table.foreach(EA_TempBuffsTable, function(i2, v2) if v2==v then return v2 end end)
							if v2 then
							   	local f = _G["EAFrame_"..v2];
							    f:Hide();
							   	removeBuffValue(EA_TempBuffsTable, v2);
								EventAlert_PositionFrames();
						        f:SetScript("OnUpdate", nil);
							end
                end
            end


		end
        -- End Check


        local timerFontSize = 0;
        for i,v in ipairs (EA_TempBuffsTable) do
            local eaf = _G["EAFrame_"..v];
            local name, rank = GetSpellInfo(v);

            if (EA_Config.AllowAltAlerts == true) then
                if (EA_AltItems[EA_playerClass][v]) then
                    local EA_usable, EA_nomana = IsUsableSpell(name);

                    if (EA_usable ~= 1) then
                        eaf:Hide();
                        removeBuffValue(EA_TempBuffsTable, v);
                        EventAlert_PositionFrames();
                    end
                end
            end

            if (EA_Config.ShowTimer == true) then

                local _,_,_,_,_,_,EA_expirationTime,_,_ = UnitAura("player", name, rank);

                if (v == 58597) then
                    -- I realize this is a nasty hack.  But for some damned reason it keeps pulling the time of the full
                    -- sacred shield buff and not the procced buff.  So until I figure it out, this is how it's getting done!
                    EA_expirationTime = EA_SacredShield.expire;
                end


                if (EA_expirationTime ~= nil) then
                    local EA_time = 0;

                    EA_time = EA_time + EA_expirationTime;
                    EA_currentTime = GetTime();
                    EA_timeLeft = EA_expirationTime - EA_currentTime;

                    if EA_timeLeft > 0 then
                        if (EA_Config.ChangeTimer == true) then
                            timerFontSize = 28;
                            eaf.spellTimer:ClearAllPoints();
                            eaf.spellTimer:SetPoint("CENTER", 0, 0);
                        else
                            timerFontSize = 18;
                            eaf.spellTimer:ClearAllPoints();
                            eaf.spellTimer:SetPoint("TOP", 0, 20);
                        end

                        eaf.spellTimer:SetFont("Fonts\\\FRIZQT__.TTF", timerFontSize, "OUTLINE");
                        eaf.spellTimer:SetFormattedText("%d", EA_timeLeft);
                    end
                end
            else
            	eaf.spellTimer:SetText("");
            end
        end
    end
end


function EventAlert_DoAlert()

	if (EA_Config.ShowFlash == true) then
	   UIFrameFadeIn(LowHealthFrame, 1, 0, 1);
	   UIFrameFadeOut(LowHealthFrame, 2, 1, 0);
	end

	if (EA_Config.DoAlertSound == true) then
	   PlaySoundFile(EA_Config.AlertSound);
	end
end


function EventAlert_PositionFrames(event)

	if (EA_Config.ShowFrame == true) then

    	EA_Main_Frame:ClearAllPoints();
   		EA_Main_Frame:SetPoint(EA_Position.Anchor, UIParent, EA_Position.relativePoint, EA_Position.xLoc, EA_Position.yLoc);

		local prevFrame = "EA_Main_Frame";

        for k,v in ipairs(EA_TempBuffsTable) do
            local eaf = _G["EAFrame_"..v];

            if (v == 48517) then
            	_, _, gsiIcon, _, _, _, _, _, _ = GetSpellInfo(5176);
				gsiName, _, _, _, _, _, _, _, _ = GetSpellInfo(v);
            elseif (v == 48518) then
				_, _, gsiIcon, _, _, _, _, _, _ = GetSpellInfo(2912);
				gsiName, _, _, _, _, _, _, _, _ = GetSpellInfo(v);
            else
				gsiName, _, gsiIcon, _, _, _, _, _, _ = GetSpellInfo(v);
            end

        	eaf:ClearAllPoints();

            if (prevFrame == "EA_Main_Frame") then
                eaf:SetPoint("CENTER", prevFrame, "CENTER", 0, 0);
			elseif (prevFrame == eaf) then
              	prevFrame = "EA_Main_Frame";
	            eaf:SetPoint("CENTER", prevFrame, "CENTER", 0, 0);
            else
				eaf:SetPoint("CENTER", prevFrame, "CENTER", 100+EA_Position.xOffset, 0+EA_Position.yOffset);
            end

            eaf:SetWidth(EA_Config.IconSize);
			eaf:SetHeight(EA_Config.IconSize);

			eaf:SetBackdrop({bgFile = gsiIcon});

            if (EA_Config.ShowName == true) then
	    		eaf.spellName:SetText(gsiName);
		    else
	    		eaf.spellName:SetText("");
			end


            eaf:SetScript("OnUpdate", EventAlert_OnUpdate);
            prevFrame = eaf;
	    	eaf:Show();
        end
	end
end


function EventAlert_SlashHandler(msg)

    msg = string.lower(msg);

	if (msg == "options" or msg == "opt") then

    	if not EA_Options_Frame:IsVisible() then
            ShowUIPanel(EA_Options_Frame);
	    else
	        HideUIPanel(EA_Options_Frame);
	    end
    elseif (msg == "version" or msg == "ver") then
        DEFAULT_CHAT_FRAME:AddMessage("EventAlert version: "..EA_Config.Version);
    elseif (msg == "print") then
        EventAlert_PrintTable();
    else
        DEFAULT_CHAT_FRAME:AddMessage("EventAlert commands (/eventalert or /ea):");
        DEFAULT_CHAT_FRAME:AddMessage("/ea options (/ea opt) - Toggle the options window on or off");
        DEFAULT_CHAT_FRAME:AddMessage("/ea version (/ea ver) - Shows the current version of EventAlert.");
    end

end


function EventAlert_VersionCheck()

	if (EA_Config.Version == EA_tempVer) then
	   -- Do Nothing

	elseif (EA_Config.Version ~= EA_tempVer and EA_Config.Version ~= nil) then
	    EA_Config.Version = EA_tempVer;

        EA_Version_Frame_EditBox:SetFontObject(ChatFontNormal);
		EA_Version_Frame_EditBox:SetText("EventAlert new version detected!\n\n\n- Ok, after much testing and pulling my hair out, I think the bug with alerts getting stuck on the screen is finally gone.  If it isn't, PLEASE post on WoWInterface or Curse that you are still having trouble.  If you can include a way for me to contact you, that would be great as well!  Thanks!\n\n\n\nEventAlert version "..EA_Config.Version.." loaded.")
		EA_Version_Frame:Show();

	elseif (EA_Config.Version == nil) then
	   	EA_Config.Version = EA_tempVer;
		EA_Version_Frame_EditBox:SetFontObject(ChatFontNormal);
		EA_Version_Frame_EditBox:SetText("- EventAlert first load detected.\n- EventAlert is setting all settings to default.\n\nKnown Bugs:\n          \n\n\nEventAlert version "..EA_Config.Version.." loaded.")

		EA_Version_Frame:Show();

		EventAlert_FunctionOfDoom();
	end
end


-- THE CAKE IS A LIE!
function EventAlert_FunctionOfDoom()

	EA_Config = nil;
	EA_Config = { DoAlertSound, AlertSound, AlertSoundValue, LockFrame, ShowFrame, ShowFlash, ShowTimer, Version, AllowESC };

    EA_Position = nil;
    EA_Position = { Anchor, relativePoint, xLoc, yLoc, xOffset, yOffset };

	EA_Items = nil;

    EA_Config.Version = EA_tempVer;
end


-- Just used for debugging.
function EventAlert_PrintTable()
	table.foreach(EA_TempBuffsTable, print)
end


function removeBuffValue(tab, value)
	for pos, name in ipairs(tab) do
		if (name == value) then
			table.remove(tab, pos)
		end
	end
end

function pairsByKeys (t, f)
	local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end