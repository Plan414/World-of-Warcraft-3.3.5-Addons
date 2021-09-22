-- ******************************** Variables *******************************
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("TitanPals", true)
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelPalsButton_SetTooltipText()
-- DESC : Build Firends Tooltip for Titan Panel
-- **************************************************************************
function TitanPanelPals_SetTooltip()
     local np, op = GetNumFriends();
     if ( np > 0 ) then TitanPanelPals_CoreUtils( "UpDate" ) end
     local BNNumF, BNetCount = BNGetNumFriends();
     local ofI, opn, opl, opc, opa, opco, ops, opno, tpcnp, tpai, TStatus;
     local right, left;
     -- RealID Friends
     if ( TitanPals.Settings.ShowBNTooltip ) then
          if ( BNNumF == 0 ) then
               GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
               GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_NOREALID_FRIENDS"] );
               GameTooltip:AddLine( "\n" );
          else
               local BNNumF, BNetCount = BNGetNumFriends();
               local BNI, TText, FirstN, LastN, BNAFK, BNDND, ToonID, TName, TClient, TRealm, TFaction, TRace, TClass, TGuild, TZone, TLevel, TStatus, TNote, right, left, BNToonCount;
               GameTooltip:AddLine( LB["TITAN_PALS_REAL_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
               if ( BNetCount > 0 ) then
	            for BNI=1, BNetCount do
                         BNToonCount = BNGetNumFriendToons( BNI );
	                 _, FirstN, LastN, _, ToonID, TGame, _, _, BNAFK, BNDND, _, TNote = BNGetFriendInfo( BNI );
                         AccountN = FirstN.." "..LastN
                         for i=1, BNToonCount do
                              TFocus, TName, TClient, TRealm, TFaction, TRace, TClass, TGuild, TZone, TLevel, TText = BNGetFriendToonInfo( BNI, i );
                              --[[ This is ALPHA code and will be altered as needed ]]--
                              if ( TGame == "S2" ) then
                                   TLevel = "SC2";
                                   TClass = "S2";
                                   TRealm = "Starcraft II"
                              end
                              if ( BNAFK ) then BNAFK = "<Away>";
                              else BNAFK = "nil"; end
                              if ( BNDND ) then BNDND = "<DND>";
                              else BNDND = "nil"; end
                              TStatus = BNAFK..":"..BNDND;
                              RealIDName = TitanPanelPals_CoreUtils( "ToolTipID", TitanPals.Settings.RealIDFormat, FirstN, LastN, TName, TRealm, AccountN, TClass, TGame )
                              if ( TGame == "S2" ) then
                                   right, left = TitanPanelPals_CoreUtils( "ToolTipN", TitanPals.Settings.TFormat, nil, RealIDName, TLevel, TClass, TText, TStatus, nil, nil );
                              else
                                   right, left = TitanPanelPals_CoreUtils( "ToolTipN", TitanPals.Settings.TFormat, nil, RealIDName, TLevel, TClass, TZone, TStatus, TNote, nil );
                              end
                              GameTooltip:AddDoubleLine( right, left );
                         end
                    end
                    GameTooltip:AddLine( "\n" );
               else 
                    GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_NOREALPALS"] );
                    GameTooltip:AddLine( "\n" );
               end
          end
     end
     GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
     if ( np == 0 ) then
          GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_EMPTY"] );
     else
          -- For showing online friends
          if ( op == 0 ) then
               GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_NOPALS"] );
          else
               for ofI=1, np do
                    opn, opl, opc, opa, opco, ops, opno = GetFriendInfo(ofI);
                    if ( opco ) then
                         right, left = TitanPanelPals_CoreUtils( "ToolTipN", TitanPals.Settings.TFormat, nil, opn, opl, opc, opa, ops, opno, nil );
                         GameTooltip:AddDoubleLine( right, left );
                    end
               end
          end
          -- For showing offline friends  
          if ( TitanPals.Settings.ShowOffline ) then
               GameTooltip:AddLine( "\n" );
               GameTooltip:AddLine( TitanPanelPals_ColorUtils( "GetCText", "hlight", LB["TITAN_PALS_TOOLTIP_OFF"] ) );
	       local fIndex = TitanPals.Lists[palsDB];
               local aIndex = TitanPals.Alts[palsDB];
               local lpl, lpc, lpno;
	       local pcount = 0;
               for ofI=1, np do
                    opn, _, _, _, opco = GetFriendInfo(ofI);
                    if ( not opco ) then
                         if ( aIndex[opn] ) then
                              ops = "<ALT>";
                         else ops = ""; end
                         --local lpl, lpc, lpno = string.match(fIndex[opn], '(.*):(.*):(.*)');
                         lpl = fIndex[opn].Level
                         lpc = fIndex[opn].Class
                         lpno = fIndex[opn].Note
                         if ( fIndex[opn].Note == "na" ) then lpno = "";
                         else lpno = fIndex[opn].Note; end
                         local ol = TitanPanelPals_ColorUtils( "GetCText", "gray", LB["TITAN_PALS_TOOLTIP_OFFLINE"] )
                         right, left = TitanPanelPals_CoreUtils( "ToolTipN", TitanPals.Settings.TFormat, nil, opn, lpl, lpc, nil, ops, lpno, ol );
		         --TitanPanelPals_DebugUtils( "bug", "tooltip", "Right -> "..opn.." \nLeft -> "..left)
                         if ( TitanPals.Settings.NoAlts and not aIndex[opn] ) then 
                              GameTooltip:AddDoubleLine( " "..right, left );
                         elseif ( not TitanPals.Settings.NoAlts ) then
                              GameTooltip:AddDoubleLine( " "..right, left );
                              pcount = pcount + 1;
                         end
                    end
               end
	       if ( pcount == 0 ) then GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_NO_OFF"] ) end
          end
          -- For showing ignored ppl
          if ( TitanPals.Settings.ShowIgnored ) then
               GameTooltip:AddLine( "\n" );
               GameTooltip:AddLine(TitanPanelPals_ColorUtils( "GetCText", "hlight", LB["TITAN_PALS_TOOLTIP_IGNORE"] ) );
               ni = GetNumIgnores();
               if ( ni == 0 ) then 
	            GameTooltip:AddLine( LB["TITAN_PALS_TOOLTIP_IGNORE_EMPTY"] );
               else
                    for ofI=1, ni do
                         local tpit = TitanPanelPals_ColorUtils( "GetCText", "red", LB["TITAN_PALS_TOOLTIP_OFFLINE_IGNORED"] );
                         GameTooltip:AddDoubleLine( "  "..TitanPanelPals_ColorUtils( "GetCText", "normal", GetIgnoreName(ofI) ), tpit );
                    end
               end
          end
     end
     -- For showing AddOn memory Usage
     if ( TitanPals.Settings.ShowMem ) then
          GameTooltip:AddLine( "\n" );
          GameTooltip:AddLine( TitanPanelPals_ColorUtils( "GetCText", "hlight", LB["TITAN_PALS_TOOLTIP_MEM"] ) );
	  GameTooltip:AddDoubleLine( "  "..LB["TITAN_PALS_CONFIG"], TitanPanelPals_ColorUtils( "GetCText", "green", floor( GetAddOnMemoryUsage( "TitanPals" ) ).."kb" ) )
     end
end