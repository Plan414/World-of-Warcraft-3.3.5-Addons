-- ******************************** Variables *******************************
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("TitanPals", true)
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PreparePalsMenu()
-- DESC : Builds Right Click Interactive Menu
-- **************************************************************************
function TitanPanelRightClickMenu_PreparePalsMenu()
     --TitanPanelPals_CoreUtils("UpDateBNIDS")
     local info = {};
     local NumPals, NumPalsO = GetNumFriends();
     local BNnumP, BNnumPo = BNGetNumFriends();
     local palsName, palsClass, givenName, realmName, surName, pID, fullName, toonID, BNI, BNToonCount, TName, TClass, TGame, TNote, BNAFK, BNDND
     -- Start Menu 2
     if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
          -- This is for whispering a friend
          if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_WHISPER"] ) then
               -- Normal Friends
               if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_WHISPER"].." "..LB["TITAN_PALS_MENU_NORMAL"], UIDROPDOWNMENU_MENU_LEVEL); end
               for BNI=1, NumPalsO do
                    palsName, _, palsClass = GetFriendInfo(BNI);
                    info = {};
                    info.text = TitanPanelPals_ColorUtils("GetCClass", "color", palsClass, palsName);
                    info.func = palsWhisper;
                    info.value = palsName;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               end
               -- Battle Net Friends
               if ( TitanPals.Settings.ShowBNTooltip and BNnumPo > 0 ) then 
                    if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL); end
                    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_WHISPER"].." "..LB["TITAN_PALS_MENU_REALID"], UIDROPDOWNMENU_MENU_LEVEL);
                    for BNI=1, BNnumPo do
	                 _, givenName, surName, _, ToonID, TGame, _, _, BNAFK, BNDND, _, TNote = BNGetFriendInfo(BNI);
                         fullName = givenName.." "..surName;
                         BNToonCount = BNGetNumFriendToons(BNI);
                         for i=1, BNToonCount do
                              pID, TName, _, realmName, _, _, TClass = BNGetFriendToonInfo(BNI, i);
                              info = {};
                              info.text = TitanPanelPals_ColorUtils("GetCClass", "color", TClass, givenName.." "..surName.." ( "..TName.." )" );
                              info.func = palsWhisper;
                              info.value = givenName.." "..surName;
                              UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			 end
                    end
               end
          end
          -- This is for group Invites
          if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_INVITE"] ) then
               -- Normal Friends
               if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_INVITE"].." "..LB["TITAN_PALS_MENU_NORMAL"], UIDROPDOWNMENU_MENU_LEVEL); end
               for BNI=1, NumPalsO do
                    palsName, _, palsClass = GetFriendInfo(BNI);
                    info = {};
                    info.text = TitanPanelPals_ColorUtils("GetCClass", "color", palsClass, palsName);
                    info.func = PalsInvite;
                    info.value = palsName;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               end
               -- Battle Net Friends
               if ( TitanPals.Settings.ShowBNTooltip and BNnumPo > 0 ) then
                    if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL); end
                    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_INVITE"].." "..LB["TITAN_PALS_MENU_REALID"], UIDROPDOWNMENU_MENU_LEVEL);
                    for BNI=1, BNnumPo do
                         _, givenName, surName, toonName, toonID = BNGetFriendInfo(BNI);
                         _, _, _, realmName, _, _, BNClass = BNGetToonInfo(toonID);
                         fullName = givenName.." "..surName.." ( "..toonName.." )";
                         info = {};
                         info.text = TitanPanelPals_ColorUtils("GetCClass", "color", BNClass, fullName);
			 if ( realmName == TitanPals.Profile.Realm ) then
                              info.func = PalsInvite;
                         else
			      info.func = PalsRealmError;
			 end
                         info.value = toonName;
                         UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    end
               end
          end
          -- This is for removing a friend from friends list
          if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_REMOVE"] ) then
               -- Normal Friends
               if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_REMOVE"].." "..LB["TITAN_PALS_MENU_NORMAL"], UIDROPDOWNMENU_MENU_LEVEL); end
               for BNI=1, NumPalsO do
                    palsName, _, palsClass = GetFriendInfo(BNI);
                    info = {};
                    info.text = TitanPanelPals_ColorUtils("GetCClass", "color", palsClass, palsName);
                    info.func = PalsRemove;
                    info.value = palsName;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               end
               -- Battle Net Friends
               if ( TitanPals.Settings.ShowBNTooltip and BNnumPo > 0 ) then
                    if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL); end
                    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_REMOVE"].." "..LB["TITAN_PALS_MENU_REALID"], UIDROPDOWNMENU_MENU_LEVEL);
                    for BNI=1, BNnumPo do
                         pID, givenName, surName, toonName, toonID = BNGetFriendInfo(BNI);
                         _, _, _, _, _, _, BNClass = BNGetToonInfo(toonID);
                         fullName = givenName.." "..surName.." ( "..toonName.." )";
                         info = {};
                         info.text = TitanPanelPals_ColorUtils("GetCClass", "color", BNClass, fullName);
                         info.func = PalsBNRemove;
                         info.value = pID;
                         UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    end
               end
          end
          -- This is for setting friends note
          if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_NOTE"] ) then
               -- Normal Friends
               if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_NOTE"].." "..LB["TITAN_PALS_MENU_NORMAL"], UIDROPDOWNMENU_MENU_LEVEL); end
               for BNI=1, NumPalsO do
                    palsName, _, palsClass = GetFriendInfo(BNI);
                    info = {};
                    info.text = TitanPanelPals_ColorUtils("GetCClass", "color", palsClass, palsName);
                    info.func = PalsNotePopUp;
                    info.value = "Normal".."0"..palsName..":"..TitanPanelPals_ColorUtils("GetCClass", "color", palsClass, palsName);
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               end
               -- Battle Net Frineds
               if ( TitanPals.Settings.ShowBNTooltip and BNnumPo > 0 ) then
                    if ( NumPalsO > 0 ) then TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL); end
                    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_NOTE"].." "..LB["TITAN_PALS_MENU_REALID"], UIDROPDOWNMENU_MENU_LEVEL);
                    for BNI=1, BNnumPo do
                         pID, givenName, surName, toonName, toonID = BNGetFriendInfo(BNI);
                         _, _, _, _, _, _, BNClass = BNGetToonInfo(toonID);
                         fullName = givenName.." "..surName;
                         info = {};
                         info.text = TitanPanelPals_ColorUtils("GetCClass", "color", BNClass, fullName);
                         info.func = PalsNotePopUp;
                         info.value = "BNet"..":"..pID..":"..fullName..":"..TitanPanelPals_ColorUtils("GetCClass", "color", BNClass, fullName);
                         UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    end
               end
          end
	  if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_SYNC"] ) then
	       TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_SYNC"], UIDROPDOWNMENU_MENU_LEVEL);
               -- Sync Alts To Friends List Setting Option
               info = {};
               info.text = LB["TITAN_PALS_MENU_SYNCALTS"];
               info.func = TitanPanelPals_SyncAlts;
               UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               -- Sync Alts To Friends List Setting Option
               info = {};
               info.text = LB["TITAN_PALS_MENU_SYNCALTSFRIENDS"];
               info.func = TitanPanelPals_SyncAltsFriends;
               UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	  end
          if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_DEBUG_MDEBUG"] ) then
                    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_DEBUG_DEBUG1"], UIDROPDOWNMENU_MENU_LEVEL);
                    info = {};
                    info.text = LB["TITAN_PALS_DEBUG_DEV"];
                    info.func = TitanPals_DevDebug;
                    info.checked = TitanPals.Master["Debug"];
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    info = {};
                    info.text = LB["TITAN_PALS_DEBUG_DEVEVENT"];
                    info.func = TitanPals_DevDebugEvent;
                    info.checked = TitanPals.Master["DebugEvent"];
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    info = {};
                    info.text = LB["TITAN_PALS_DEBUG_DEVLOGEVENT"];
                    info.func = TitanPals_DevDebugLogEvent;
                    info.checked = TitanPals.Master["DebugLogEvent"];
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		    TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		    TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_DEBUG_PLAY"], UIDROPDOWNMENU_MENU_LEVEL);
		    info = {};
		    info.text = LB["TITAN_PALS_DEBUG_PLAYFRIENDS"];
		    info.func = TitanPals_MenuProssess;
		    info.value = "playFriends";
		    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		    info = {};
		    info.text = LB["TITAN_PALS_DEBUG_PLAYALTS"];
		    info.func = TitanPals_MenuProssess;
		    info.value = "playAlts";
		    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
          end
	  if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_REMOVEDATA"] ) then
	       TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_REMOVEDATA"], UIDROPDOWNMENU_MENU_LEVEL);
	       -- Outdated Friends
               if ( NumPals > 0 ) then
                    info = {};
                    info.text = LB["TITAN_PALS_MENU_REMOVE_FRIEND"];
                    info.hasArrow = 1;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               end
	       -- Outdated Alts
	       info = {};
	       info.text = LB["TITAN_PALS_MENU_REMOVE_ALT"];
	       info.hasArrow = 1;
	       UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	  end
          return;
     end
     -- End Menu 2
     -- Start Menu 3
     if ( UIDROPDOWNMENU_MENU_LEVEL == 3 ) then
	  if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_REMOVE_FRIEND"] ) then
               TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_REMOVE_FRIENDDATA"], UIDROPDOWNMENU_MENU_LEVEL);
	       local a, b, c, n, v;
	       for n, v in pairs(TitanPals.Lists[palsDB]) do
                    TitanPanelPals_DebugUtils("bug", "Menu", "N = "..n.." V = "..v);
                    info = {};
                    info.text = LB["TITAN_PALS_MENU_SUB_REMOVE"]..TitanPanelPals_ColorUtils("GetCClass", "color", v, n);
                    info.value = "Lists:"..n;
                    info.func = TitanPals_MenuProssess;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	       end
	  end
	  if ( UIDROPDOWNMENU_MENU_VALUE == LB["TITAN_PALS_MENU_REMOVE_ALT"] ) then
	       TitanPanelRightClickMenu_AddTitle(LB["TITAN_PALS_MENU_REMOVE_ALTDATA"], UIDROPDOWNMENU_MENU_LEVEL);
	       local d, n, v;
               for n, v in pairs(TitanPals.Alts[palsDB]) do
                    TitanPanelPals_DebugUtils("bug", "Menu", "N = "..n.." V = "..v);
                    info = {};
                    info.text = LB["TITAN_PALS_MENU_SUB_REMOVE"]..n;
                    info.value = "Alts:"..n;
                    info.func = TitanPals_MenuProssess;
                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	       end
	  end
          return;
     end
     -- End Menu 3
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[LB["TITAN_PALS_CORE_ID"]].menuText);
     if ( NumPalsO > 0 or BNnumPo > 0 and TitanPals.Settings.ShowBNTooltip == true ) then
          -- create the title for the Whisper submenu
          info = {};
          info.text = LB["TITAN_PALS_MENU_WHISPER"];
          info.hasArrow = 1;
          UIDropDownMenu_AddButton(info);
          -- create the title for the Invite submenu
          info = {};
          info.text = LB["TITAN_PALS_MENU_INVITE"];
          info.hasArrow = 1;
          UIDropDownMenu_AddButton(info);
          -- create the title for the Ignore submenu
          info = {};
          info.text = LB["TITAN_PALS_MENU_REMOVE"];
          info.hasArrow = 1;
          UIDropDownMenu_AddButton(info);
          -- create the title for the Note submenu
          info = {};
          info.text = LB["TITAN_PALS_MENU_NOTE"];
          info.hasArrow = 1;
          UIDropDownMenu_AddButton(info);
          TitanPanelRightClickMenu_AddSpacer();
     end
     -- Syncing Alts / Alts Friends
     info = {};
     info.text = LB["TITAN_PALS_MENU_SYNC"];
     info.hasArrow = 1;
     UIDropDownMenu_AddButton(info);
     -- Removing Friends From Database
     info = {};
     info.text = LB["TITAN_PALS_MENU_REMOVEDATA"]
     info.hasArrow = 1;
     UIDropDownMenu_AddButton(info);
     TitanPanelRightClickMenu_AddSpacer();
     -- Debuging Menu
     local TitanUser = TitanPals.Profile.Player.."@"..TitanPals.Profile.Realm;
     for i=1, table.getn(TitanPals["authors"]) do
          if ( TitanUser == TitanPals.authors[i]) then 
               info = {};
               info.text = LB["TITAN_PALS_DEBUG_MDEBUG"];
               info.hasArrow = 1;
               UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
               TitanPanelRightClickMenu_AddSpacer();
          end
     end
     info = {};
     info.text = LB["TITAN_PALS_MENU_SETTINGS"];
     info.value = LB["TITAN_PALS_MENU_SETTINGS"];
     info.func = function() InterfaceOptionsFrame_OpenToCategory(LB["TITAN_PALS_CONFIG"]); end
     UIDropDownMenu_AddButton(info);
     TitanPanelRightClickMenu_AddSpacer();
     -- Standard Menu
     TitanPanelRightClickMenu_AddToggleIcon(LB["TITAN_PALS_CORE_ID"]);
     TitanPanelRightClickMenu_AddToggleLabelText(LB["TITAN_PALS_CORE_ID"]);
     -- default Titan Panel right-click menu options
     TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], LB["TITAN_PALS_CORE_ID"], TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : palsWhisper()
-- DESC : Opens a wisper with the selected person
-- **************************************************************************
function palsWhisper()
     if ( not ChatFrame1EditBox:IsVisible() ) then
          ChatFrame_OpenChat("/w "..this.value.." ");
     else
          ChatFrame1EditBox:SetText("/w "..this.value.." ");
     end
end
function BNpalsWhisper()
     BNSendWhisper(this.value, "")
end

-- **************************************************************************
-- NAME : PalsRemove()
-- DESC : <research>
-- **************************************************************************
function PalsRemove()
     local IgnoreRemove = this.value;
     RemoveFriend( this.value );
end

-- **************************************************************************
-- NAME : PalsBNRemove()
-- DESC : <research>
-- **************************************************************************
function PalsBNRemove()
     local IgnoreRemove = this.value;
     BNRemoveFriend( this.value );
end

-- **************************************************************************
-- NAME : PalsInvite()
-- DESC : <research>
-- **************************************************************************
function PalsInvite()
     InviteUnit( this.value );
end

-- **************************************************************************
-- NAME : PalsNotePopUp()
-- DESC : <research>
-- **************************************************************************
function PalsNotePopUp()
     local a, b, c, d = string.match( this.value, '(.*):(.*):(.*):(.*)' );
     TitanPals["RealIDs"] = {};
     TitanPals.RealIDs["Type"] = a;
     TitanPals.RealIDs["pID"] = b;
     TitanPals.RealIDs["Player"] = c;
     TitanPals.RealIDs["PlayerColored"] = d;
     StaticPopup_Show("TITAN_PALS_CUSTOM_NOTE", TitanPals.RealIDs.PlayerColored);
end

-- **************************************************************************
-- NAME : TitanPals_DevDebug()
-- DESC : <research>
-- **************************************************************************
function TitanPals_DevDebug()
     TitanPanelPals_CoreUtils("Toggle", "Master:Debug")
     TitanPanelButton_UpdateButton(LB["TITAN_PALS_CORE_ID"]);
end

-- **************************************************************************
-- NAME : TitanPals_DevDebugEvent()
-- DESC : <research>
-- **************************************************************************
function TitanPals_DevDebugEvent()
     TitanPanelPals_CoreUtils("Toggle", "Master:DebugEvent")
     TitanPanelButton_UpdateButton(LB["TITAN_PALS_CORE_ID"]);
end

-- **************************************************************************
-- NAME : TitanPals_DevDebugLogEvent()
-- DESC : <research>
-- **************************************************************************
function TitanPals_DevDebugLogEvent()
     TitanPanelPals_CoreUtils("Toggle", "Master:DebugLogEvent")
     TitanPanelButton_UpdateButton(LB["TITAN_PALS_CORE_ID"]);
end

-- **************************************************************************
-- NAME : PalsRealmError()
-- DESC : <research>
-- **************************************************************************
function PalsRealmError()
     local thisName = this.value
     local msg = format(LB["TITAN_PALS_REALM_ERROR"], thisName)
     TitanPanelPals_DebugUtils("error", "PalsRealmError", msg);
end

-- **************************************************************************
-- NAME : TitanPals_MenuProssess()
-- DESC : <research>
-- **************************************************************************
function TitanPals_MenuProssess()
     --[arg1   ]
     --[Command]
     local cmd = this.value;
     local a, b = string.match( cmd, '(.*):(.*)' );
     if ( a and b ) then
          TitanPanelPals_CoreUtils("fixDB", a, b);
     elseif ( cmd == "playFriends" or cmd == "playAlts" ) then
          TitanPanelPals_CoreUtils(cmd);
     else TitanPanelPals_DebugUtils("bug", "MenuProssess", "Menu Prossessing failed."); end
end