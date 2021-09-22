-- **************************************************************************
-- * TitanPals.lua
-- *
-- * By: Holycurves
-- *       (Holycurves@Laughing Skull)
-- **************************************************************************

-- ******************************** Variables *******************************
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("TitanPals", true)
local AceTimer = LibStub("AceTimer-3.0")
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelPals_Init()
-- DESC : For first time addon use
-- **************************************************************************
function TitanPanelPals_Init()
     if ( not TitanPals or TitanPals == nil ) then TitanPals = {}; end
     if ( not TitanPals["Init"] or TitanPals["Init"] == nil ) then
          local authors = {
               "Holycurves@Laughing Skull",
	       "Nagdand@Laughing Skull",
	       "Lindarena@Laughing Skull",
	       "Holytree@laughing Skull",
          }
          local presets = {
               { name = "Style #1", value = "!s (!l !c) !p ~ !n !z", },
               { name = "Style #2", value = "!s (!l) !uc ~ !n !z", },
               { name = "Style #3", value = "!s (!l) !p - !c !z ~ !n", },
               { name = "Style #4", value = "!s (!l) !c - !p !z ~ !n", },
               { name = "Style #5", value = "!s (!l) !uc !z ~ !n", },
               { name = "Style #6", value = "!s !p (!l) - !c !n ~ !z", },
               { name = "Style #7", value = "!s !z (!l) - !c !n ~ !p", },
               { name = "Style #8", value = "!s !c (!l) !z !n ~ !p", },
          }
          local realidformats = {
               { name = "Format #1", value = "!cn" },
               { name = "Format #2", value = "!cn - !rn" },
               { name = "Format #3", value = "!sn/!cn" },
               { name = "Format #4", value = "!ln/!cn" },
               { name = "Format #5", value = "!fn/!cn" },
               { name = "Format #6", value = "!fn/!cn - !rn" },
	       { name = "Format #7", value = "!fn ( !cn )" },
               { name = "Format #8", value = "!cn ( !fn )" },
	  }
          local sTypes = {
               { name = "<Away>", value = "<Away>" },
               { name = "<AFK>", value = "<AFK>" },
               { name = "<A>", value = "<A>" },
               { name = "(Away)", value = "(Away)" },
               { name = "(AFK)", value = "(AFK)" },
               { name = "(A)", value = "(A)" },
               { name = "[Away]", value = "[Away]" },
               { name = "[AFK]", value = "[AFK]" },
               { name = "[A]", value = "[A]" },
          }
	  if ( not TitanPals["authors"] ) then TitanPals["authors"] = authors; end
	  if ( not TitanPals["presets"] ) then TitanPals["presets"] = presets; end
	  if ( not TitanPals["sTypes"] ) then TitanPals["sTypes"] = sTypes; end
	  if ( not TitanPals["realidformats"] ) then TitanPals["realidformats"] = realidformats; end
          if ( not TitanPals["RealIDs"] ) then TitanPals["RealIDs"] = {}; end
          if ( not TitanPals["Master"] ) then TitanPals["Master"] = {}; end
               TitanPals["Master"]["Debug"] = false;
               TitanPals["Master"]["DebugEvent"] = false;
               TitanPals["Master"]["DebugLogEvent"] = false;
               TitanPals["Master"]["dLine"] = "";
          if ( not TitanPals["Settings"] ) then
               TitanPals["Settings"] = {};
               TitanPals["Settings"]["ShowIgnored"] = false;
               TitanPals["Settings"]["ShowMem"] = true;
	       TitanPals["Settings"]["ShowBNTooltip"] = true;
               TitanPals["Settings"]["UpDateDB"] = true;
               TitanPals["Settings"]["DisplayB"] = true;
               TitanPals["Settings"]["ShowMem"] = true;
               TitanPals["Settings"]["NoAlts"] = true;
               TitanPals["Settings"]["TFormat"] = "!s (!l !c) !p ~ !n !z";
               TitanPals["Settings"]["SFormat"] = "<Away>";
	       TitanPals["Settings"]["RealIDFormat"] = "!cn";
          end
	  if ( not TitanPals["DBVer"] ) then TitanPals["DBVer"] = {}; end
          if ( not TitanPals["Lists"] ) then TitanPals["Lists"] = {}; end
          if ( not TitanPals["Alts"] ) then TitanPals["Alts"] = {}; end
          if ( not TitanPals["Temp"] ) then TitanPals["Temp"] = {}; end
	  if ( not TitanPals["AddVer"] ) then TitanPals["AddVer"] = LB["TITAN_PALS_CORE_ADDVER"]; end
	  if ( not TitanPals["Profile"] ) then
               TitanPals["Profile"] = {};
	       TitanPals["Profile"]["Player"] = "UnKnown";
	       TitanPals["Profile"]["Faction"] = "UnKnown";
	       TitanPals["Profile"]["Realm"] = "UnKnown";
	       TitanPals["Profile"]["Level"] = "UnKnown";
	       TitanPals["Profile"]["Class"] = "UnKnown";
	  end
          TitanPals["Init"] = true;
     end
end

-- **************************************************************************
-- NAME : TitanPanelPalsButton_OnEvent()
-- DESC : Event Handler
-- **************************************************************************
function TitanPanelPalsButton_OnEvent(self, event, ...)

          if ( TitanPals.Master["DebugEvent"] ) then TitanPanelPals_DebugUtils("bug", "OnEvent", "["..TitanPanelPals_ColorUtils("GetCText", "gray", event).."]"); end
          if ( event == "ADDON_LOADED" and arg1 == "TitanPals" ) then
               if ( not BNFeaturesEnabled() ) then TitanPals.Settings["ShowBNTooltip"] = false; end
	       self:UnregisterEvent("ADDON_LOADED");
          elseif ( event == "PLAYER_ENTERING_WORLD" ) then
               if ( not TitanPalsBannor ) then
                    Titan__PalsBannor = true;
                    local Fac = UnitFactionGroup("player");
                    local Rea = GetCVar("realmName");
                    local Pla = GetUnitName("player");
                    local Lev = UnitLevel("player");
                    local Cla = UnitClass("player");
                    if ( not TitanPals.Profile["Player"] or TitanPals.Profile["Player"] ~= Pla ) then TitanPals.Profile["Player"] = Pla; end
                    if ( not TitanPals.Profile["Faction"] or TitanPals.Profile["Faction"] ~= Fac ) then TitanPals.Profile["Faction"] = Fac; end
                    if ( not TitanPals.Profile["Level"] or TitanPals.Profile["Level"] ~= Lev ) then TitanPals.Profile["Level"] = Lev; end
                    if ( not TitanPals.Profile["Class"] or TitanPals.Profile["Class"] ~= Cla ) then TitanPals.Profile["Class"] = Cla; end
                    if ( not TitanPals.Profile["Realm"] or TitanPals.Profile["Realm"]~= Rea ) then TitanPals.Profile["Realm"] = Rea; end
                    if ( not palsDB or palsDB ~= Fac..":"..Rea ) then palsDB = Fac..":"..Rea; end
                    if ( not palsAuthor or palsAuthor ~= Pla..":"..Rea ) then palsAuthor = Pla.."@"..Rea; end
                    if ( not TitanPals.Lists[palsDB] ) then TitanPals.Lists[palsDB] = {}; end
                    if ( TitanPals.Lists[palsDB][Pla] ) then
                         TitanPals.Lists[palsDB][Pla]["Class"] = Cla;
                         TitanPals.Lists[palsDB][Pla]["Level"] = Lev;
                         TitanPals.Lists[palsDB][Pla]["Note"] = "na";
                    end
                    if ( not TitanPals.Alts[palsDB] ) then TitanPals.Alts[palsDB] = {}; end
                    if ( not TitanPals.Alts[palsDB][Pla] ) then TitanPals["Alts"][palsDB][Pla] = Cla; end
                    if ( not TitanPals.Settings["SFormat"] ) then
                         TitanPals.Settings["SFormat"] = "<Away>";
                         TitanPals["presets"] = { { name = "Style #1", value = "!s (!l !c) !p ~ !n !z", }, { name = "Style #2", value = "!s (!l) !uc ~ !n !z", }, { name = "Style #3", value = "!s (!l) !p - !c !z ~ !n", }, { name = "Style #4", value = "!s (!l) !c - !p !z ~ !n", }, { name = "Style #5", value = "!s (!l) !uc !z ~ !n", }, { name = "Style #6", value = "!s !p (!l) - !c !n ~ !z", }, { name = "Style #7", value = "!s !z (!l) - !c !n ~ !p", }, { name = "Style #8", value = "!s !c (!l) !z !n ~ !p", }, }
                         TitanPals["sTypes"] = { { name = "<Away>", value = "<Away>" }, { name = "<AFK>", value = "<AFK>" }, { name = "<A>", value = "<A>" }, { name = "(Away)", value = "(Away)" }, { name = "(AFK)", value = "(AFK)" }, { name = "(A)", value = "(A)" }, { name = "[Away]", value = "[Away]" }, { name = "[AFK]", value = "[AFK]" }, { name = "[A]", value = "[A]" }, }
                         TitanPals["AddVer"] = LB["TITAN_PALS_CORE_ADDVER"];
                    end
                    if ( TitanPals.Settings["DisplayB"] ) then 
                         TitanPanelPals_CoreUtils("load");
                         TitanPanelPals_CoreUtils("mem");
                    end
                    TitanPanelPals_CheckOffLine();
               end
          elseif ( event == "BN_FRIEND_ACCOUNT_ONLINE" or event == "BN_FRIEND_ACCOUNT_OFFILNE" or event == "FRIENDLIST_UPDATE" or event == "IGNORELIST_UPDATE" )then
               TitanPanelButton_UpdateButton(LB["TITAN_PALS_CORE_ID"]);
               TitanPanelButton_UpdateTooltip();
          end

end

-- **************************************************************************
-- NAME : TitanPanelPalsButton_GetButtonText()
-- DESC : Build Button Text
-- **************************************************************************
function TitanPanelPalsButton_GetButtonText()
     local NumIgnore = GetNumIgnores();
     local NumPals, NumPalsOnline = GetNumFriends();
     local _, BNetCount = BNGetNumFriends();
     local buttonRichText
     -- create string for Titan bar display
     if ( TitanPals.Settings.ShowBNTooltip ) then
          buttonRichText = format(LB["TITAN_PALS_BUTTON_TEXT"], TitanPanelPals_ColorUtils("GetCText", "green", NumPalsOnline), TitanPanelPals_ColorUtils("GetCText", "blue", BNetCount), TitanPanelPals_ColorUtils("GetCText", "red", NumIgnore));
     else
          buttonRichText = format(LB["TITAN_PALS_BUTTON_TEXT_NOREALID"], TitanPanelPals_ColorUtils("GetCText", "green", NumPalsOnline), TitanPanelPals_ColorUtils("GetCText", "red", NumIgnore));
     end
     return LB["TITAN_PALS_BUTTON_LABEL"], buttonRichText;
end

-- **************************************************************************
-- NAME : TitanPanelPalsButton_OnClick()
-- DESC : Toggles Friends Dialog
-- **************************************************************************
function TitanPanelPalsButton_OnClick(self, button)
     if ( button == "LeftButton" ) then
          ToggleFriendsFrame(1);
     else
          TitanPanelButton_OnClick(self, button);
     end
end

-- **************************************************************************
-- NAME : TitanPanelPalsButton_CheckOffLine()
-- DESC : Check Offline data for new data storage format
-- **************************************************************************
function TitanPanelPals_CheckOffLine()
     local change = 0;
     for n, v in pairs(TitanPals.Lists[palsDB]) do
          local focus = TitanPals.Lists[palsDB][n];
          if ( type( focus ) == "string" ) then
               local l, c, no = string.match( focus, "(.*):(.*):(.*)");
               TitanPals.Lists[palsDB][n] = {};
               TitanPals.Lists[palsDB][n]["Class"] = c;
	       TitanPals.Lists[palsDB][n]["Level"] = l;
	       TitanPals.Lists[palsDB][n]["Note"] = no;
	       change = change + 1;
          end
     end
     if ( change > 0 ) then
          local authors = {
               "Holycurves@Laughing Skull",
	       "Nagdand@Laughing Skull",
	       "Lindarena@Laughing Skull",
	       "Holytree@laughing Skull",
          }
          local presets = {
               { name = "Style #1", value = "!s (!l !c) !p ~ !n !z", },
               { name = "Style #2", value = "!s (!l) !uc ~ !n !z", },
          }
          local realidformats = {
               { name = "Format #1", value = "!cn" },
               { name = "Format #2", value = "!cn - !rn" },
               { name = "Format #3", value = "!sn/!cn" },
               { name = "Format #4", value = "!ln/!cn" },
               { name = "Format #5", value = "!fn/!cn" },
               { name = "Format #6", value = "!fn/!cn - !rn" },
	       { name = "Format #7", value = "!fn ( !cn )" },
               { name = "Format #8", value = "!cn ( !fn )" },
	  }
	  TitanPals["authors"] = {};
	  TitanPals["authors"] = authors;
	  TitanPals["presets"] = {};
	  TitanPals["presets"] = presets;
	  TitanPals["realidformats"] = {};
	  TitanPals["realidformats"] = realidformats;
          TitanPals["Settings"] = {};
          TitanPals["Settings"]["ShowIgnored"] = false;
          TitanPals["Settings"]["ShowMem"] = true;
	  TitanPals["Settings"]["ShowBNTooltip"] = true;
          TitanPals["Settings"]["UpDateDB"] = true;
          TitanPals["Settings"]["DisplayB"] = true;
          TitanPals["Settings"]["ShowMem"] = true;
          TitanPals["Settings"]["NoAlts"] = true;
          TitanPals["Settings"]["TFormat"] = "!s (!l !c) !p ~ !n !z";
	  TitanPals["Settings"]["RealIDFormat"] = "!cn";
          TitanPals["AddVer"] = LB["TITAN_PALS_CORE_ADDVER"];
     end
end

-- **************************************************************************
-- NAME : TitanPanelPals_SyncAlts()
-- DESC : This adds your alts to your friends list for things like mailing
-- **************************************************************************
function TitanPanelPals_SyncAlts()
     -- Alts to Pals List Syncing
     local np = GetNumFriends();
     local aIndex = TitanPals.Alts[palsDB];
     local fI, palsn, palsl, palsc, palsa, palsco, palss, palsno;
     for n, v in pairs(aIndex) do
          local tp = 0;
          local fI;
          for fI=1, np do
               palsn = GetFriendInfo(fI);
               if ( n == palsn ) then tp = 1; end
          end
          if ( tp == 0 and n ~= TitanPals.Profile["Player"] ) then
               TitanPanelPals_DebugUtils("info", "SyncAlts", "Adding Alt "..n.." to firends list");
               AddFriend(n); 
          end
     end
     TitanPanelPals_DebugUtils("info", "Sybc Alts", "Sync Finished.");
end

-- **************************************************************************
-- NAME : TitanPanelPals_SyncAlts()
-- DESC : This syncs your alts friend to your friends list
-- **************************************************************************

function TitanPanelPals_SyncAltsFriends()
     local np = GetNumFriends();
     local iTable = TitanPals.Lists[palsDB];
     local palsn, palsl, palsc, palsa, palsco, palss, palsno;
     for n, v in pairs(iTable) do
          if ( n ~= TitanPals.Profile["Player"] ) then
               --local v2, v3 = string.match(n, '(.*):(.*)');
               local tp = 0;
               local fI;
               for fI=1, np do
                    palsn = GetFriendInfo(fI);
                    if ( n == palsn ) then tp = 1; end
               end
               if ( tp == 0 and n ~= TitanPals.Profile["Player"] ) then
                    TitanPanelPals_DebugUtils("info", "SyncAltsFriends", "Adding "..n.." to friends list");
                    AddFriend(n);
               end
	  end
     end
     TitanPanelPals_DebugUtils("info", "Sybc Alts", "Sync Finished.");
end