-- ******************************** Variables *******************************
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("TitanPals", true)
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelPals_CoreUtils(b, b1, b2, b3, b4, b5)
-- DESC : This makes everything happen
-- **************************************************************************
function TitanPanelPals_CoreUtils(b, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10)
     if ( TitanPals.Master["Debug"] ) then
          if ( b ) then TitanPals.Master["dLine"] = "[|cffff9900"..b.."|r]" end
          if ( b1 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b1.."|r]" end
          if ( b2 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b2.."|r]" end
          if ( b3 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b3.."|r]" end
          if ( b4 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b4.."|r]" end
          if ( b5 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b5.."|r]" end
          if ( b6 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b6.."|r]" end
          if ( b7 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b7.."|r]" end
          if ( b8 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b8.."|r]" end
          if ( b9 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b9.."|r]" end
          if ( b10 ) then TitanPals.Master["dLine"] = TitanPals.Master["dLine"].."[|cff808080"..b10.."|r]" end
          TitanPals.Master["dLine"] = "Recieved "..TitanPals.Master["dLine"];
	  TitanPanelPals_DebugUtils("bug", "dLine", TitanPals.Master["dLine"]);
     end
     if ( b == "ReSetDB" ) then
          TitanPals = nil;
	  ReloadUI();
     elseif ( b == "UpDate" ) then
          -- [b     ][b1     ][b2   ][b3    ]
          -- [Action][Faction][Realm][Player]
          local NumPals = GetNumFriends();
	  local Palsn, Palsl, Palsc, Palsa, Palsco, Palss, Palsno, fIndex;
	  for fIndex=1, NumPals do
	       --[Name][Level][Class][Area][Connected][Status][Note]
	       Palsn, Palsl, Palsc, Palsa, Palsco, Palss, Palsno = GetFriendInfo(fIndex);
               if ( not TitanPals.Lists[palsDB][Palsn] ) then
                    TitanPals.Lists[palsDB][Palsn] = {};
                    TitanPals.Lists[palsDB][Palsn]["Note"] = "na";
                    TitanPals.Lists[palsDB][Palsn]["Class"] = "Unknown";
                    TitanPals.Lists[palsDB][Palsn]["Level"] = 0;
              else
                    if ( Palsco ) then 
                         if ( not Palsno ) then TitanPals.Lists[palsDB][Palsn]["Note"] = "na";
                         else TitanPals.Lists[palsDB][Palsn]["Note"] = Palsno; end
                         TitanPals.Lists[palsDB][Palsn]["Level"] = Palsl;
                         TitanPals.Lists[palsDB][Palsn]["Class"] = Palsc;
                    end
               end
	  end
     elseif ( b == "ToolTipN" ) then
          --[b     ][b1   ][b2  ][b3  ][b4   ][b5   ][b6  ][b7    ][b8  ][b9     ]
          --[Action][Right][Left][Name][Level][Class][Area][Status][Note][Offline]
	  --[[
               !s - Status
               !l - Level
               !p - Player
               !z - Zone
               !n - Note
               !c - Class
               !uc - Colored Players Name
	  --]]
          if ( b4 == 0 ) then b4 = "-"; end
          if ( string.match(b7, "(.*):(.*)") ) then
               local BNA, BND = string.match(b7, "(.*):(.*)");
	       if ( BNA ~= "nil" or BND ~= "nil" ) then
                    if ( BNA ) then
                         if ( BNA == "<Away>" ) then BNA = TitanPals.Settings.SFormat end
                         b1 = string.gsub(b1, "!s", BNA); end
                    if ( BND ) then b1 = string.gsub(b1, "!s", BND); end
	       else b1 = string.gsub(b1, "!s", " "); end
          else
               if ( b7 == "<AFK>" or b7 == "<Away>" or b7 == "<DND>" or b7 == "<ALT>" ) then
                    if ( b7 == "<Away>" ) then b7 = TitanPals.Settings.SFormat; end
                    b1 = string.gsub(b1, "!s", b7);
               else b1 = string.gsub(b1, "!s", " "); end
          end
	  if ( b4 == "SC2" ) then
               b1 = string.gsub(b1, "!l", TitanPanelPals_ColorUtils("GetCText", "gray", b4))
	  else
               b1 = string.gsub(b1, "!l", TitanPanelPals_ColorUtils("GetCText", "orange", b4))
          end
	  b1 = string.gsub(b1, "!p", TitanPanelPals_ColorUtils("GetCText", "orange", b3))
	  b1 = string.gsub(b1, "!c", TitanPanelPals_ColorUtils("GetCClass", "color", b5, b5))
	  if ( not b8 ) then b1 = string.gsub(b1, "!n", "");
	  else b1 = string.gsub(b1, "!n", TitanPanelPals_ColorUtils("GetCText", "gray", b8)); end
	  if ( b6 ) then b1 = string.gsub(b1, "!z", b6)
	  else b1 = string.gsub(b1, "!z", b9) end
	  b1 = string.gsub(b1, "!uc", TitanPanelPals_ColorUtils("GetCClass", "color", b5, b3))
	  TitanPanelPals_DebugUtils( "bug", "ToolTipN", b1 )
          b2, b3 = string.match(b1, '(.*)~(.*)')
	  return b2, b3;
     elseif ( b == "ToolTipID" ) then
          --[b     ][b1    ][b2        ][b3       ][b4       ][b5        ][b6       ][b7   ][b8    ]
          --[Action][Format][First Name][Last Name][Character][Realm Name][Full Name][Class][Client]
	  b1 = string.gsub( b1, "!sn", TitanPanelPals_ColorUtils( "GetCClass", "color", b7, b2 ) )
	  b1 = string.gsub( b1, "!ln", TitanPanelPals_ColorUtils( "GetCClass", "color", b7, b3 ) )
	  b1 = string.gsub( b1, "!fn", TitanPanelPals_ColorUtils( "GetCClass", "color", b7, b6 ) )
	  b1 = string.gsub( b1, "!cn", TitanPanelPals_ColorUtils( "GetCClass", "color", b7, b4 ) )
	  b1 = string.gsub( b1, "!rn", TitanPanelPals_ColorUtils( "GetCClass", "color", b7, b5 ) )
          --local client = "["..b8.."]";
	  b1 = string.gsub( b1, "!gn", TitanPanelPals_ColorUtils( "GetCText", "gray", b8 ) )
	  return b1;
     elseif ( b == "Toggle" ) then
          --[b      ][b1 ]
	  --[Action][Var]
	  b2, b3 = string.match( b1, '(.*):(.*)' )
          if ( TitanPals[b2][b3] ) then 
	       TitanPals[b2][b3] = false;
	       if ( b3 == "DebugLogEvent" ) then wipe(TitanPals["Temp"]); end
	       if ( b3 == "Debug") then TitanPals.Master["dLine"] = ""; end
	       TitanPanelPals_DebugUtils("bug", "Toggle", "Toggled var to false")
          elseif ( not TitanPals[b2][b3] ) then 
               TitanPals[b2][b3] = true;
               TitanPanelPals_DebugUtils("bug", "Toggle", "Toggled var to true")
          end
     elseif ( b == "mem" ) then
          --[b     ]
	  --[Action]
          UpdateAddOnMemoryUsage();
          TitanPals.Master["dLine"] = TitanPanelPals_ColorUtils("GetCText", "green", floor(GetAddOnMemoryUsage('TitanPals')).."kb");
          TitanPanelPals_DebugUtils("info", "mem", "Titan Panel [|cffeda55fPals|r] is using "..TitanPals.Master["dLine"].." of memory");
     elseif ( b == "load" ) then 
          --[b     ]
	  --[Action]
          TitanPanelPals_DebugUtils("info", "load", "Titan Panel [|cffeda55fPals|r] |cff00aa00"..LB["TITAN_PALS_CORE_VERSION"].."|r Loaded...")
     elseif ( b == "playList" ) then
          --[b     ]
	  --[Action]
          local pTable = TitanPals["Temp"];
          for n, v in pairs( pTable ) do
	       TitanPanelPals_DebugUtils("info", "playList", "Name = "..n.." Value = "..v);
          end
     elseif ( b == "playFriends" ) then
          --[b     ]
	  --[Action]
          local pTable = TitanPals.Lists[palsDB];
	  for n, v in pairs(pTable) do
               local nn = TitanPanelPals_ColorUtils("GetCText", "green", n);
               local vv = TitanPanelPals_ColorUtils("GetCText", "gray", "["..v.."]");
               TitanPanelPals_DebugUtils("info", "playFriends", nn..vv);
          end
     elseif ( b == "playAlts" ) then
          --[b     ]
	  --[Action]
	  local pTable = TitanPals.Alts[palsDB];
	  for n, v in pairs(pTable) do
	       local nn = TitanPanelPals_ColorUtils("GetCText", "green", n);
	       local vv = TitanPanelPals_ColorUtils("GetCText", "gray", "["..v.."]");
               TitanPanelPals_DebugUtils("info", "playAlts", nn..vv);
	  end
     elseif ( b == "playAuthors" ) then
          table.foreach(TitanPals["authors"], print)
     elseif ( b == "playLog" ) then
          table.foreach(TitanPals["Temp"], print)
     elseif ( b == "fixDB" ) then
          --[b     ][b1      ][b2            ]
	  --[Action][Database][Name to Remove]
	  TitanPals["Temp"] = {};
	  for n, v in pairs( TitanPals[b1][palsDB] ) do
	       if ( n ~= b2 ) then
	            TitanPals.Temp[n] = v;
		    TitanPals[b1][palsDB] = {};
		    TitanPals[b1][palsDB] = TitanPals["Temp"];
               end
	  end
     elseif ( b == "fixClass" ) then
          --[b     ][b1  ][b2   ]
          --[Action][Name][Class]
          TitanPanelPals_DebugUtils("info", "fixClass", "Name = "..b1.." Class = "..b2);
          TitanPals.Lists[palsDB][b1] = b2;
     elseif ( b == "ToUpperEnglish") then
          if ( b1 == LB["TITAN_PALS_CLASSES_WARLOCK_M"] ) then return "WARLOCK";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_WARLOCK_F"] ) then return "WARLOCK";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_DEATHKNIGHT_M"] ) then return "DEATH KNIGHT";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_DEATHKNIGHT_F"] ) then return "DEATH KNIGHT";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_HUNTER_M"] ) then return "HUNTER";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_HUNTER_F"] ) then return "HUNTER";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_PRIEST_M"] ) then return "PRIEST";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_PRIEST_F"] ) then return "PRIEST";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_PALADIN_M"] ) then return "PALADIN";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_PALADIN_F"] ) then return "PALADIN";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_MAGE_M"] ) then return "MAGE";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_MAGE_F"] ) then return "MAGE";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_ROGUE_M"] ) then return "ROGUE";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_ROGUE_F"] ) then return "ROGUE";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_DRUID_M"] ) then return "DRUID";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_DRUID_F"] ) then return "DRUID";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_SHAMAN_M"] ) then return "SHAMAN";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_SHAMAN_F"] ) then return "SHAMAN";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_WARRIOR_M"] ) then return "WARRIOR";
          elseif ( b1 == LB["TITAN_PALS_CLASSES_WARRIOR_F"] ) then return "WARRIOR"; end
     elseif ( b == "AddAuthor" ) then
          b2 = TitanPals.Profile.Player.."@"..TitanPals.Profile.Realm; 
          TitanPanelPals_DebugUtils("info", "CoreUtils", "Name = "..b2);
          tinsert(TitanPals.authors, b2)
     end
end

-- **************************************************************************
-- NAME : TitanPAnelPals_DebugUtils()
-- DESC : For debug messaging and print messages to chat frame
-- **************************************************************************
function TitanPanelPals_DebugUtils(d, d1, d2)
     --[d     ][d1      ][d2   ]
     --[Action][Function][error]
     if ( d == "bug" and TitanPals.Master["Debug"] ) then
          local iDebug = TitanPanelPals_ColorUtils("GetCText", "red", LB["TITAN_PALS_CORE_DTAG"]);
          if ( d1 ~= "dLine" ) then DEFAULT_CHAT_FRAME:AddMessage(iDebug.."["..TitanPanelPals_ColorUtils("GetCText", "orange", d1).."] "..d2); end
	  if ( TitanPals.Master["DebugLogEvent"] ) then tinsert(TitanPals["Temp"], d2); end
     elseif ( d == "info" ) then
          local iInfo = TitanPanelPals_ColorUtils("GetCText", "orange", LB["TITAN_PALS_CORE_ITAG"]);
	  DEFAULT_CHAT_FRAME:AddMessage(iInfo..d2);
     elseif ( d == "error" ) then
          local iErr = TitanPanelPals_ColorUtils("GetCText", "orange", LB["TITAN_PALS_CORE_ETAG"]);
          DEFAULT_CHAT_FRAME:AddMessage(iErr..d2);
     end
end

-- **************************************************************************
-- NAME : TitanPanelPals_ColorUtils()
-- DESC : for coloring the tooltip and messages
-- **************************************************************************
function TitanPanelPals_ColorUtils(c, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
     if ( c == "GetCText") then
          --[c     ][c1   ][c2  ]
          --[Action][Color][Text]
          if ( c1 == "gray" ) then return LB["TITAN_PALS_COLORS_GRAY"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "red") then return LB["TITAN_PALS_COLORS_RED"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "green" ) then return LB["TITAN_PALS_COLORS_GREEN"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "orange") then return LB["TITAN_PALS_COLORS_ORANGE"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "blue") then return LB["TITAN_PALS_COLORS_BLUE"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "normal" ) then return LB["TITAN_PALS_COLORS_NORMAL"]..c2..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "hlight" ) then return LB["TITAN_PALS_COLORS_HLIGHT"]..c2..LB["TITAN_PALS_COLORS_CTAG"]; end
     elseif ( c == "GetCClass" ) then
          --[c     ][c1   ][c2   ][c3    ]
          --[Action][Style][Class][Player]
          local colorCode;
          if ( c2 == LB["TITAN_PALS_CLASSES_WARLOCK_M"] ) then colorCode = "|cff9482c9";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_WARLOCK_F"] ) then colorCode = "|cff9482c9";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_DEATHKNIGHT_M"] ) then colorCode = "|cffc41f3b";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_DEATHKNIGHT_F"] ) then colorCode = "|cffc41f3b";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_HUNTER_M"] ) then colorCode = "|cffabd473";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_HUNTER_F"] ) then colorCode = "|cffabd473";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_PRIEST_M"] ) then colorCode = "|cffffffff";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_PRIEST_F"] ) then colorCode = "|cffffffff";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_PALADIN_M"] ) then colorCode = "|cfff58cba";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_PALADIN_F"] ) then colorCode = "|cfff58cba";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_MAGE_M"] ) then colorCode = "|cff69ccf0";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_MAGE_F"] ) then colorCode = "|cff69ccf0";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_ROGUE_M"] ) then colorCode = "|cfffff569";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_ROGUE_F"] ) then colorCode = "|cfffff569";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_DRUID_M"] ) then colorCode = "|cffff7d0a";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_DRUID_F"] ) then colorCode = "|cffff7d0a";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_SHAMAN_M"] ) then colorCode = "|cff2459ff";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_SHAMAN_F"] ) then colorCode = "|cff2459ff";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_WARRIOR_M"] ) then colorCode = "|cffc79c6e";
          elseif ( c2 == LB["TITAN_PALS_CLASSES_WARRIOR_F"] ) then colorCode = "|cffc79c6e";
	  elseif ( c2 == "S2" ) then colorCode = "|cff00ffff";
          else colorCode = "|cffFFFFFF";
          end
          if ( c1 == "color" ) then return colorCode..c3..LB["TITAN_PALS_COLORS_CTAG"];
          elseif ( c1 == "normal" ) then return c3; end
     end
end

-- **************************************************************************
-- NAME : TitanPals StaticPopupDialogs
-- DESC : Dialog for custom Notes
-- **************************************************************************

StaticPopupDialogs["TITAN_PALS_CUSTOM_NOTE"] = {
     text = "Please enter friends note for %s :",
     button1 = TEXT(ACCEPT),
     button2 = TEXT(CANCEL),
     hasEditBox = 1,
     maxLetters = 250,
     OnAccept = function()
          local editBox = getglobal(this:GetParent():GetName().."EditBox");
          local pNote = editBox:GetText();
	  local pID = TitanPals.RealIDs.pID;
          if ( TitanPals.RealIDs.Type == "Normal" ) then
               SetFriendNotes( TitanPals.Temp.Player, pNote )
          elseif ( TitanPals.RealIDs.Type == "BNet" ) then
               BNSetFriendNote(pID, pNote);
          end
     end,
     OnShow = function()
          getglobal(this:GetName().."EditBox"):SetFocus();
     end,
     OnHide = function()
          if ( ChatFrame1EditBox:IsVisible() ) then
               ChatFrame1EditBox:SetFocus();
          end
          getglobal(this:GetName().."EditBox"):SetText("");
     end,
     EditBoxOnEnterPressed = function()
          local editBox = getglobal(this:GetParent():GetName().."EditBox");
          local pNote=editBox:GetText();
          this:GetParent():Hide();
     end,
     EditBoxOnEscapePressed = function()
          this:GetParent():Hide();
     end,
     timeout = 0,
     exclusive = 1,
     whileDead = 1,
     hideOnEscape = 1
};
