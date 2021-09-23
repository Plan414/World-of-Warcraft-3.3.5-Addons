-- **************************************************************************
-- * TitanDefense.lua
-- *
-- * Originally By Tekkub
-- * Adopted by HonorGoG of the Titan Development Team
-- **************************************************************************
-- * 2009-12-01 : 3.0.7.30200 Subzone update, fixed linefeed MacOS problem
-- * 2009-08-04 : 3.0.6.30200 Subzone, API and WoW 3.2 updates
-- * 2009-04-06 : 3.0.5.30200 Subzone update (internal)
-- * 2009-04-16 : 3.0.4.30100a Removed imbedded SVN directory
-- * 2009-04-15 : 3.0.4.30100 Subzone update and toc for WoW 3.1
-- * 2009-04-06 : 3.0.3.30000 Subzone update
-- * 2009-03-12 : 3.0.2.30000 Subzone update and a minor bug removed
-- * 2009-02-16 : 3.0.1.30000 Subzone update and added color for local attacks
-- * 2009-02-02 : 3.0.0.30000 Massive Ace3 update completed for new release
-- * 2008-03-16 : 2.3.0.20300 Massive overall structure update
-- * 2008-03-11 : 2.2.1.20300 Bug fixes
-- * 2008-02-20 : 2.2.0.20300 Released for Titan Panel 3.2.0
-- * 2007-11-13 : 2.1.1.20300 Adopted and released for WoW 2.3.3
-- **************************************************************************

-- ********************************** Ace3 **********************************
TPD = LibStub("AceAddon-3.0"):NewAddon("TitanPanelDefense", "AceHook-3.0", "AceTimer-3.0")

-- ******************************** Constants *******************************
TITAN_DEFENSE_ID = "Defense";
local TITAN_DEFENSE_DEBUG = false;

-- ******************************** Variables *******************************
TitanDefense_warningDuration = 40;
TitanDefense_uploadNotRequested = false;
TitanDefense_subzones = {};
TitanDefense_pname = "";
TitanDefense_laststamp = 0;
TitanDefense_attacks = {};                -- [index] = Subzone, Timestamp
TitanDefense_SubzoneSum = {};             -- [Subzone] = Sum
TitanDefense_ZoneSum = {};                -- [Zone] = Sum
TitanDefense_SubzoneTimestamp = {};       -- [Subzone] = timestamp
TitanDefense_ZoneTimestamp = {};          -- [Zone] = timestamp
TitanDefense_SortedSubzoneSum = {};       -- [Rank] = Subzone
TitanDefense_SortedZoneSum = {};          -- [Rank] = Zone
TitanDefense_SortedSubzoneTimestamp = {}; -- [Rank] = Subzone
TitanDefense_SortedZoneTimestamp = {};    -- [Rank] = Zone
TitanDefenseTimer = nil;

-- ***************************** SavedVariables *****************************
-- TitanDefense_options : Stored options
-- TitanDefense_newSubzones : ["Subzone"] = "Zone"
-- TitanDefense_unknowns : List of unknown subzones

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelDefenseButton_OnLoad(self)
-- DESC : Register event and display versioning to chat frame
-- **************************************************************************
function TitanPanelDefenseButton_OnLoad(self)
     TPDefense_Debug("TitanPanelDefenseButton_OnLoad");
     if (DEFAULT_CHAT_FRAME) then
         DEFAULT_CHAT_FRAME:AddMessage(TITAN_DEFENSE_STRINGS_VERSION_INFO.." Loaded");
     end
     self.registry = { 
          id = TITAN_DEFENSE_ID,
          version = TITAN_DEFENSE_STRINGS_VERSION,
          menuText = TITAN_DEFENSE_STRINGS_MENUTEXT, 
          category = "Information",           
          buttonTextFunction = "TitanPanelDefenseButton_GetButtonText", 
          tooltipTitle = TITAN_DEFENSE_STRINGS_TOOLTIP,
          tooltipTextFunction = "TitanPanelDefenseButton_GetTooltipText", 
          icon = "Interface\\Icons\\Ability_Parry.blp",     
          iconWidth = 16,
          savedVariables = {
               ShowLabelText = 1,
               ShowColoredText = 1,
               ShowIcon = 1,               
               SZT = true,
               ZT = true,
               SZS = true,
               ZS = true,
               numSZT = 5,
               numZT = 5,
               numSZS = 5,
               numZS = 5,
               hideWD = true,
               hideLD = true,
          }
     };
     self:RegisterEvent("VARIABLES_LOADED");
     self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
     self:RegisterEvent("ZONE_CHANGED");
     self:RegisterEvent("ZONE_CHANGED_INDOORS");
end

-- **************************************************************************
-- NAME : TitanPanelDefense_OnEvent(self,event)
-- DESC : Create three second countdown timer for variables loaded event and
--        handle zone change events
-- VARS : event = the triggered event we are watching
-- **************************************************************************
function TitanPanelDefense_OnEvent(self,event)
     TPDefense_DebugFunc("TitanPanelDefense_OnEvent", {event});
     if (event == "VARIABLES_LOADED") then
          if not TitanDefenseTimer then
               TPD:ScheduleTimer(TitanPanelDefense_Init, 5)
          end
     end 
     if ((event == "ZONE_CHANGED_NEW_AREA") or (event == "ZONE_CHANGED") or (event == "ZONE_CHANGED_INDOORS")) then
          TitanPanelDefense_handleZoneChange();
     end
end

-- **************************************************************************
-- NAME : TPD:ChatFrame_MessageEventHandler(event, handler)
-- DESC : 
-- **************************************************************************
function TPD:ChatFrame_MessageEventHandler(event, handler)
     TPDefense_DebugFunc("ChatFrame_MessageEventHandler", {event});
     if ( event == "CHAT_MSG_CHANNEL" ) then
          local message = arg1
          local sender = arg2
          local channel = arg9
          local source = strlower(tostring(arg4))
          if ( channel == TITAN_DEFENSE_STRINGS_WDCHANNAME ) then
               TPDefense_Debug("Chatter on WD: ".. sender.. "> ".. message);
               local _, _, zone = string.find(message, TITAN_DEFENSE_STRINGS_ZONEATTACKSEARCH)
               if (zone) then
                    TitanPanelDefense_HandleWorld(zone);
                    if (TitanDefense_options[TitanDefense_pname]["hideWD"]) then
                         TPDefense_Debug("Blocking WD: ".. message);
                         return false;
                    end
               end
          elseif (string.find(channel, TITAN_DEFENSE_STRINGS_LDCHANNAME)) then
               TPDefense_Debug("Chatter on LD: ".. sender.. "> ".. message);
               local _, _, zone = string.find(message, TITAN_DEFENSE_STRINGS_ZONEATTACKSEARCH)
               if (zone) then
                    TitanPanelDefense_HandleLocal(zone);
                    if (TitanDefense_options[TitanDefense_pname]["hideLD"]) then
                         TPDefense_Debug("Blocking LD: ".. message);
                         return false;
                    end
               end
          end
     end
     return TPD:CallChatOut(self, event, handler)
end

-- **************************************************************************
-- NAME : TPD:CallChatOut(cf, event, handler)
-- DESC : 
-- **************************************************************************
function TPD:CallChatOut(cf, event, handler)
     if handler and type(handler)=="function" then
          TPDefense_Debug("TPD:CallChatEvent:Option1");
          handler(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
     else
          TPDefense_Debug("TPD:CallChatEvent:Option2");
          TPD.hooks["ChatFrame_MessageEventHandler"](cf, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
     end
end


-- **************************************************************************
-- NAME : TitanPanelDefense_OnUpdate()
-- DESC : Nothing
-- **************************************************************************
function TitanPanelDefense_OnUpdate()
end

-- **************************************************************************
-- NAME : TitanPanelDefense_Init()
-- DESC : Nothing
-- **************************************************************************
--function TitanPanelDefense_Init()
function TitanPanelDefense_Init()
     TPDefense_DebugFunc("TitanPanelDefense_Init");

     -- Remove timer
     TPD:CancelTimer("TitanPanelDefense_Init", true)
     TitanDefenseTimer = nil;

     -- Init some variables
     if (not TitanDefense_newSubzones) then TitanDefense_newSubzones = {}; end
     if (not TitanDefense_unknowns) then TitanDefense_unknowns = {}; end
     TitanPanelDefense_cleanNewSubzones();

     -- Hook the chat event so we can supress server alerts
     TPD:RawHook("ChatFrame_MessageEventHandler", TPD.ChatFrame_MessageEventHandler, true)

     -- Check that we're in the Def Channels
     TPDefense_Debug("GetChannelNameWD:"..GetChannelName(TITAN_DEFENSE_STRINGS_WDCHANNAME));
     TPDefense_Debug("GetChannelNameLD:"..GetChannelName(TITAN_DEFENSE_STRINGS_LDCHANNAME));
     if (GetChannelName(TITAN_DEFENSE_STRINGS_WDCHANNAME) == 0) then
          JoinPermanentChannel(TITAN_DEFENSE_STRINGS_WDCHANNAME);
          TPDefense_Debug("JoinPermanentChannel("..TITAN_DEFENSE_STRINGS_WDCHANNAME..")");
     end
     if (GetChannelName(TITAN_DEFENSE_STRINGS_LDCHANNAME) == 0) then
          JoinPermanentChannel(TITAN_DEFENSE_STRINGS_LDCHANNAME);
          TPDefense_Debug("JoinPermanentChannel("..TITAN_DEFENSE_STRINGS_LDCHANNAME..")");
     end

     TitanDefense_pname = GetCVar("realmName").. UnitName("player");
     if (not TitanDefense_options) then TitanDefense_options = {}; end
     if (not TitanDefense_options[TitanDefense_pname]) then
          TitanDefense_options[TitanDefense_pname] = {};
          TitanDefense_options[TitanDefense_pname]["SZT"] = true;
          TitanDefense_options[TitanDefense_pname]["ZT"] = true;
          TitanDefense_options[TitanDefense_pname]["SZS"] = true;
          TitanDefense_options[TitanDefense_pname]["ZS"] = true;
          TitanDefense_options[TitanDefense_pname]["numSZT"] = 5;
          TitanDefense_options[TitanDefense_pname]["numZT"] = 5;
          TitanDefense_options[TitanDefense_pname]["numSZS"] = 5;
          TitanDefense_options[TitanDefense_pname]["numZS"] = 5;
          TitanDefense_options[TitanDefense_pname]["hideWD"] = true;
          TitanDefense_options[TitanDefense_pname]["hideLD"] = true;
     end
end

------------------------------
--      Chat Functions      --
------------------------------
-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_HandleWorld(location)
     if (TitanDefense_laststamp == time()) then return; end
     TitanDefense_laststamp = time();
     TPDefense_DebugFunc("TitanPanelDefense_HandleWorld", {location});          
     TitanPanelDefense_RecordAttack(location, time());
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_HandleLocal(location)
     TPDefense_DebugFunc("TitanPanelDefense_HandleLocal", {location});
     local zone = GetZoneText();
     TitanPanelDefense_updateZoneList(location, zone);
end

------------------------------
--Attack Tracking Functions --
------------------------------
-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_RecordAttack(subzone, timestamp)
     TPDefense_DebugFunc("TitanPanelDefense_RecordAttack", {subzone, timestamp});
     
     table.insert(TitanDefense_attacks, {subzone, timestamp});
     TitanPanelDefense_AddToTables(timestamp, subzone);
     TitanPanelDefense_SortTables();
     TitanPanelButton_UpdateButton(TITAN_DEFENSE_ID);
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_AddToTables(timestamp, subzone)
     local mainzone = TitanPanelDefense_getMainZone(subzone);

     if (not TitanDefense_SubzoneSum[subzone]) then TitanDefense_SubzoneSum[subzone] = 0; end
     if (not TitanDefense_ZoneSum[mainzone]) then TitanDefense_ZoneSum[mainzone] = 0; end

     TitanDefense_SubzoneSum[subzone] = TitanDefense_SubzoneSum[subzone] + 1;
     TitanDefense_ZoneSum[mainzone] = TitanDefense_ZoneSum[mainzone] + 1;
     TitanDefense_SubzoneTimestamp[subzone] = timestamp;
     TitanDefense_ZoneTimestamp[mainzone] = timestamp;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_SortTables()
     TitanDefense_SortedSubzoneSum = TitanPanelDefense_Sort(TitanDefense_SubzoneSum);
     TitanDefense_SortedZoneSum = TitanPanelDefense_Sort(TitanDefense_ZoneSum);
     TitanDefense_SortedSubzoneTimestamp = TitanPanelDefense_Sort(TitanDefense_SubzoneTimestamp);
     TitanDefense_SortedZoneTimestamp = TitanPanelDefense_Sort(TitanDefense_ZoneTimestamp);
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_Sort(intable)
     local table1 = {};     
     local returntable = {};
     for key,val in pairs(intable) do table1[key] = val; end;
     
     local tablesize = 0;
     for key,val in pairs(table1) do tablesize = tablesize+1; end;
     
     for i=1, tablesize do
          local maxval = 0;
          local maxkey = "";
          for key,val in pairs(table1) do
               if (val > maxval) then
                    maxval = val;
                    maxkey = key;
               end
          end
          returntable[i] = maxkey;
          table1[maxkey] = nil;
     end
     
     return returntable;
end

------------------------------
--  Zone Tracking Functions --
------------------------------
-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_handleZoneChange()
     local subzone = GetSubZoneText();
     local zone = GetZoneText();
     
     if (subzone == nil) then
          subzone = zone;
     end
     if (subzone == "") then
          subzone = zone;
     end

     TitanPanelDefense_updateZoneList(subzone, zone);     
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_updateZoneList(subzone, zone)
     if (TitanDefense_subzones[subzone] == nil) then
          if (TitanDefense_newSubzones[subzone] == nil) then
               -- Subzone has not been seen before
               TitanDefense_newSubzones[subzone] = zone;
               if (TitanDefense_uploadNotRequested) then
                    DEFAULT_CHAT_FRAME:AddMessage(TITAN_DEFENSE_STRINGS_NEWZONE1.. subzone.. "/".. zone.. TITAN_DEFENSE_STRINGS_NEWZONE2);
                    TitanDefense_uploadNotRequested = false;
               end
               return 1;
          end
     end
     
     return 0;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_isLocal(subzone)
     local zone = GetZoneText();

     if (TitanDefense_subzones[subzone] == zone) then
          return true;
     end

     if (TitanDefense_newSubzones[subzone] == zone) then
          return true;
     end
     
     return false;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_cleanNewSubzones()
     local TitanDefense_oldNewSubzones = TitanDefense_newSubzones;
     TitanDefense_newSubzones = {};
     
     for loc in pairs(TitanDefense_oldNewSubzones) do
          if(TitanDefense_subzones[loc] == nil) then
               TitanDefense_newSubzones[loc] = TitanDefense_oldNewSubzones[loc];
          end
     end
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_getMainZone(subzone)
     if (TitanDefense_subzones[subzone]) then
          return TitanDefense_subzones[subzone];
     end

     if (TitanDefense_newSubzones[subzone]) then
          return TitanDefense_newSubzones[subzone];
     end
     
     if (not TitanDefense_unknowns[subzone]) then
          TitanDefense_unknowns[subzone] = 1;
     end
     
     return TITAN_DEFENSE_STRINGS_UNKNOWNZONE;

end



------------------------------
--     Output Functions     --
--     Used in plugins      --
------------------------------
-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_GetTimeText(secs)
     local returnstring = "";
     
     if (secs < 60) then
          returnstring = secs.. TITAN_DEFENSE_STRINGS_SECONDS;
     elseif (secs < 300) then
          returnstring = math.floor(secs/60*4)/4 .. TITAN_DEFENSE_STRINGS_MINUTES;
     elseif (secs < 3600) then
          returnstring = math.floor(secs/60) .. TITAN_DEFENSE_STRINGS_MINUTES;
     else
          returnstring = math.floor(secs/3600*4)/4 .. TITAN_DEFENSE_STRINGS_HOUR;
     end
     
     return returnstring
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_GetTooltipRawData(dataarray)     
     if (table.getn(TitanDefense_attacks) == 0) then return nil; end
     
     local returnstring = "";
     
     if dataarray then
          for key,val in pairs(dataarray) do
               returnstring = returnstring.. "[".. key.. "] ".. val.. "\n";
          end
     end
     
     return returnstring;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_GetTooltipData(dataarray, numvals, isSubzone)     
     local returnstring = "";
          
     for i=1,numvals do
          if (dataarray[i]) then
               local zone = dataarray[i];
               local atttime = 0;
               local numatt = 0;
               
               if (isSubzone) then
                    numatt = TitanDefense_SubzoneSum[zone];
                    atttime = TitanDefense_SubzoneTimestamp[zone];
               else
                    numatt = TitanDefense_ZoneSum[zone];
                    atttime = TitanDefense_ZoneTimestamp[zone];
               end
               
               local elapsedtime = TitanPanelDefense_GetTimeText(time() - atttime);
               local mainzone = TitanPanelDefense_getMainZone(zone);
               
               if (isSubzone) then
                    if (TitanPanelDefense_isLocal(zone)) then
                         returnstring = returnstring.. TITAN_DEFENSE_STRINGS_LOCALHEADER.. zone.. " (".. numatt.. ")\t".. elapsedtime.. TITAN_DEFENSE_STRINGS_AGOENDER.. "\n";
                    elseif (mainzone == loc) then
                         returnstring = returnstring.. zone.. " (".. numatt.. ")\t".. elapsedtime.. TITAN_DEFENSE_STRINGS_AGOENDER.. "\n";
                    else
                         returnstring = returnstring.. mainzone.. ": ".. zone.. " (".. numatt.. ")\t".. elapsedtime.. TITAN_DEFENSE_STRINGS_AGOENDER.. "\n";
                    end
               else
                    returnstring = returnstring.. zone.. " (".. numatt.. ")\t".. elapsedtime.. TITAN_DEFENSE_STRINGS_AGOENDER.. "\n";
               end
          end
     end
     
     return returnstring;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_getLastAttack()
     if (table.getn(TitanDefense_attacks) == 0) then return nil; end

     local lasttime = TitanDefense_attacks[table.getn(TitanDefense_attacks)][2];
     local lastsubzone = TitanDefense_attacks[table.getn(TitanDefense_attacks)][1];
               
     local returnstring = ""..lastsubzone.." ("..TitanDefense_SubzoneSum[lastsubzone]..")";
     local islocal = false;
     
     if (TitanPanelDefense_isLocal(lastsubzone)) then
          islocal = true;
     end
     
     return returnstring, islocal, lasttime;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_GetNumAttText()
     if (table.getn(TitanDefense_attacks) == 0) then
          return TITAN_DEFENSE_STRINGS_NOATTACKS;
     elseif (table.getn(TitanDefense_attacks) == 1) then
          return TITAN_DEFENSE_STRINGS_ATTACKTEXT;
     else
          return table.getn(TitanDefense_attacks).. TITAN_DEFENSE_STRINGS_ATTACKSTEXT;
     end
end

------------------------------
--    Titan Panel Support   --
------------------------------

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefenseButton_GetButtonText(id)
     local button, id = TitanUtils_GetButton(id, true);
     
     local att, islocal, atttime = TitanPanelDefense_getLastAttack();
     
     if (not att) then 
          att = TitanPanelDefense_GetNumAttText();
          return TitanUtils_GetGreenText(att);
     elseif (atttime + TitanDefense_warningDuration < time()) then
          att = TitanPanelDefense_GetNumAttText();
          return TitanUtils_GetGreenText(att);
     elseif (islocal) then
          return TitanUtils_GetNormalText(att);
     else
          return TitanUtils_GetRedText(att);
     end
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefenseButton_GetTooltipText()
     if (TitanDefense_numAttacks == 0) then return TITAN_DEFENSE_STRINGS_NOATTACKS; end

     local rawdataset = {
          {"------SubzoneSum-----\n", TitanDefense_SortedSubzoneSum},
          {"------ZoneSum-----\n", TitanDefense_SortedZoneSum},
          {"------SubzoneTime-----\n", TitanDefense_SortedSubzoneTimestamp},
          {"------ZoneTime-----\n", TitanDefense_SortedZoneTimestamp},
          {"------Unknowns-----\n", TitanDefense_unknowns},
          {"------Attacks-----\n", TitanDefense_attacks}
     };
     
     local dataset = {
          {TITAN_DEFENSE_STRINGS_SZTIMETITLE, TitanDefense_options[TitanDefense_pname]["SZT"],
               TitanDefense_options[TitanDefense_pname]["numSZT"], TitanDefense_SortedSubzoneTimestamp, true},
          {TITAN_DEFENSE_STRINGS_ZTIMETITLE, TitanDefense_options[TitanDefense_pname]["ZT"],
               TitanDefense_options[TitanDefense_pname]["numZT"], TitanDefense_SortedZoneTimestamp, false},
          {TITAN_DEFENSE_STRINGS_SZFRQTITLE, TitanDefense_options[TitanDefense_pname]["SZS"], 
               TitanDefense_options[TitanDefense_pname]["numSZS"], TitanDefense_SortedSubzoneSum, true},
          {TITAN_DEFENSE_STRINGS_ZFRQTITLE, TitanDefense_options[TitanDefense_pname]["ZS"], 
               TitanDefense_options[TitanDefense_pname]["numZS"], TitanDefense_SortedZoneSum, false}
     };

     local returnstring = "";
     
     returnstring = returnstring.. TitanPanelDefense_GetNumAttText().. "\n";
          

     if (TITAN_DEFENSE_DEBUG) then
          for i,arrayinfo in pairs(rawdataset) do
          DEFAULT_CHAT_FRAME:AddMessage("DefTrackDebug: ".. arrayinfo[1]..":".. arrayinfo[2]);
               if (arrayinfo[2]) then
                    returnstring = returnstring..arrayinfo[1];
                    returnstring = returnstring..TitanPanelDefense_GetTooltipRawData(arrayinfo[2]);
                    returnstring = returnstring.."\n";
               end
          end
     end


     for i,arrayinfo in pairs(dataset) do
          if (arrayinfo[2]) then
               returnstring = returnstring.."\n".. TitanUtils_GetHighlightText(arrayinfo[1]).. "\n";
               returnstring = returnstring..TitanPanelDefense_GetTooltipData(arrayinfo[4], arrayinfo[3], arrayinfo[5]);
          end
     end
     
     return returnstring;
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareDefenseMenu()
     if (not TitanDefense_options) or (not TitanDefense_options[TitanDefense_pname]) then return false; end

     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_DEFENSE_ID].menuText);
     
     local id = TITAN_DEFENSE_ID;
     local info = {};

     local items = {
          {"Supress WorldDef Alerts", "hideWD"},
          {"Supress LocalDef Alerts", "hideLD"},
          {"Show Recent Subzones", "SZT"},
          {"Show Recent Zones", "ZT"},
          {"Show Freq Subzones", "SZS"},
          {"Show Freq Zones", "ZS"},
     };
     
     local items2 = {
          {"numSZT", 5},
          {"numZT", 5},
          {"numSZS", 5},
          {"numZS", 5},
     };
     
     for i,arr in pairs(items) do
          info.text = arr[1];
          info.value = arr[2];
          info.checked = TitanDefense_options[TitanDefense_pname][arr[2]];
          info.func = TitanPanelDefense_Toggle;
          UIDropDownMenu_AddButton(info, 1);
     end
     
     info = {};
     info.disabled = 1;
     UIDropDownMenu_AddButton(info, 1);
          
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, id, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : 
-- DESC : 
-- **************************************************************************
function TitanPanelDefense_Toggle()
     local setting = this.value;

     if (TitanDefense_options[TitanDefense_pname][setting]) then 
          TitanDefense_options[TitanDefense_pname][setting] = false;
     else 
          TitanDefense_options[TitanDefense_pname][setting] = true;
     end
end

-- **************************************************************************
-- NAME : TPDefense_DebugFunc(func, args)
-- DESC : Display function and arguments if debug mode is active
-- VARS : func = name of the function, args = arguments passed to function
-- **************************************************************************
function TPDefense_DebugFunc(func, args)
     local argstring = "(";
     if args then
          for i=1, table.getn(args) do
               if (not (i==1)) then argstring = argstring.. ", "; end
               argstring = argstring.. args[i];
          end
     end
     argstring = argstring.. ")";
--     if (TITAN_DEFENSE_DEBUG) and (DEFAULT_CHAT_FRAME) then DEFAULT_CHAT_FRAME:AddMessage("DefTrackDebug: ".. func.. argstring); end
     if (TITAN_DEFENSE_DEBUG) then DEFAULT_CHAT_FRAME:AddMessage("TitanDefenseDebug: ".. func.. argstring); end
end

-- **************************************************************************
-- NAME : TPDefense_Debug(msg)
-- DESC : Display message if debug mode is active
-- VARS : msg = message to display
-- **************************************************************************
function TPDefense_Debug(msg)
--     if (TITAN_DEFENSE_DEBUG) and (DEFAULT_CHAT_FRAME) then DEFAULT_CHAT_FRAME:AddMessage("DefTrackDebug: ".. msg); end
     if (TITAN_DEFENSE_DEBUG) then DEFAULT_CHAT_FRAME:AddMessage("TitanDefenseDebug: ".. msg); end
end
