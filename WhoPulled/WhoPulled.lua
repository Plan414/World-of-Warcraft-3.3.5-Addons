WhoPulled_GUIDs = {};
WhoPulled_MobToPlayer = {};
WhoPulled_LastMob = "";
WhoPulled_Settings = {
["yonboss"] = false,
["rwonboss"] = false,
["silent"] = false,
["msg"] = "%p PULLED %e!!!",
}
WhoPulled_PetsToMaster = {};
WhoPulled_Tanks = "";
WhoPulled_RageList = {};
WhoPulled_Ignore = {
["Rat"]=true,["Spider"]=true,["Risen Zombie"]=true,
};
WhoPulled_NotifiedOf = {};

function WhoPulled_ClearPulledList()
	wipe(WhoPulled_GUIDs);
end

function WhoPulled_PullBlah(player,enemy,msg)
	if(not WhoPulled_GUIDs[enemy[1]]) then
		WhoPulled_GUIDs[enemy[1]] = true;
		WhoPulled_MobToPlayer[enemy[2]] = player;
		WhoPulled_LastMob = enemy[2];
		if(WhoPulled_Settings["yonboss"]) then
			--Check if it's a boss:
			local i,boss;
			i = 1;
			while(UnitExists("boss"..i)) do
				if(UnitName("boss"..i) == enemy[2]) then
					if(not strfind(WhoPulled_Tanks,"[ ,.|]"..player.."[ ,.|]") and not WhoPulled_Ignore[enemy[2]]) then
						if(UnitInRaid("player") and WhoPulled_Settings["rwonboss"] and (IsRaidOfficer() or IsRaidLeader())) then
							WhoPulled_RaidWarning(enemy[2]);
						else
							WhoPulled_Yell(enemy[2]);
						end
					end
					break;
				end
				i = i+1;
			end
		else
			if(not WhoPulled_Settings["silent"] and not WhoPulled_Ignore[enemy[2]] and 
			   not strfind(WhoPulled_Tanks,"[ ,.|]"..player.."[ ,.|]")) then
				DEFAULT_CHAT_FRAME:AddMessage(msg);
			end
		end
	end
end

function WhoPulled_GetPetOwner(pet)
	if(WhoPulled_PetsToMaster[pet]) then return WhoPulled_PetsToMaster[pet]; end
	if(UnitInRaid("player")) then
		for i=1,40,1 do
			if(UnitGUID("raidpet"..i) == pet) then
				return UnitName("raid"..i);
			end
		end
	else
		if(UnitGUID("pet") == pet) then return UnitName("player"); end
		for i=1,4,1 do
			if(UnitGUID("partypet"..i) == pet) then
				return UnitName("party"..i);
			end
		end
	end
	return "Unknown";
end

function WhoPulled_ScanForPets()
	if(UnitInRaid("player")) then
		for i=1,40,1 do
			if(UnitExists("raidpet"..i)) then
				WhoPulled_PetsToMaster[UnitGUID("raidpet"..i)] = UnitName("raid"..i);
			end
		end
	else
		if(UnitExists("pet")) then WhoPulled_PetsToMaster[UnitGUID("pet")] = UnitName("player"); end
		for i=1,4,1 do
			if(UnitExists("partypet"..i)) then
				WhoPulled_PetsToMaster[UnitGUID("partypet"..i)] = UnitName("party"..i);
			end
		end
	end
end

function WhoPulled_ScanMembersSub(combo)
	local name,serv;
	name,serv = WhoPulled_GetNameServ(combo);
	if(name and WhoPulled_RageList[serv] and WhoPulled_RageList[serv][name] and not WhoPulled_NotifiedOf[name.."-"..serv]) then
		DEFAULT_CHAT_FRAME:AddMessage(name.." who pulled "..WhoPulled_RageList[serv][name].." against your team is in this team!")
		WhoPulled_NotifiedOf[name.."-"..serv] = true;
	end
end

function WhoPulled_ScanMembers()
	local num,name,i;
	if(UnitInRaid("player")) then
		num=GetNumRaidMembers();
		for i=1,num,1 do
			name=UnitName("raid"..i);
			WhoPulled_ScanMembersSub(name);
		end
	else
		--This is called for each party member every time the event fires
		--therefore I can use this more efficient method of evaluating them
		num=GetNumPartyMembers();
		if(num == 0) then return; end
		name=UnitName("party"..num);
		WhoPulled_ScanMembersSub(name);
	end
end

function WhoPulled_OnLeaveParty()
	wipe(WhoPulled_PetsToMaster);
	WhoPulled_Tanks = "";
	wipe(WhoPulled_NotifiedOf);
end

function WhoPulled_IgnoredSpell(spell)
	if(spell == "Hunter's Mark" or spell == "Sap" or spell == "Soothe") then
		return true;
	end
	return false;
end

function WhoPulled_CheckWho(...)
	local time,event,sguid,sname,sflags,dguid,dname,dflags,arg1,arg2,arg3,itype;
	if(IsInInstance()) then
		time,event,sguid,sname,sflags,dguid,dname,dflags,arg1,arg2,arg3 = ...;
		if(dname and sname and dname ~= sname and 
		   not strfind(event,"_RESURRECT") and not strfind(event,"_CREATE") and 
		   (strfind(event,"SWING") or strfind(event,"RANGE") or strfind(event,"SPELL"))) then
		 if(not strfind(event,"_SUMMON")) then
			if(bit.band(sflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
				--A player is attacking a mob
				if(not WhoPulled_IgnoredSpell(arg2)) then
					--Put this here so it still counts as aggro if a mob casts one of these on a player.
					WhoPulled_PullBlah(sname,{dguid,dname},
						sname.." pulled "..dname.."! /ywho to tell everyone!");
				end
			elseif(bit.band(dflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
				--A mob is attacking a player (stepped onto, perhaps?)
				WhoPulled_PullBlah(dname,{sguid,sname},
					dname.." pulled "..sname.."! /ywho to tell everyone!");
			elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
				--Player's pet attacks a mob
				--DEFAULT_CHAT_FRAME:AddMessage("Testing pet pull 1. Did "..sname.." ("..sflags..") pull "..dname.." ("..dflags..")?");
				local pullname;
				pname = WhoPulled_GetPetOwner(sguid);
				if(pname == "Unknown") then pullname = sname.." (pet)";
				else pullname = pname;
				end
				WhoPulled_PullBlah(pullname,{dguid,dname},
					pname.."'s "..sname.." pulled "..dname.."! /ywho to tell everyone!");
			elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
				--Mob attacks a player's pet
				--DEFAULT_CHAT_FRAME:AddMessage("Testing pet pull 1. Did "..dname.." ("..dflags..") pull "..sname.." ("..sflags..")?");
				local pullname;
				pname = WhoPulled_GetPetOwner(dguid);
				if(pname == "Unknown") then pullname = dname.." (pet)";
				else pullname = pname;
				end
				WhoPulled_PullBlah(pullname,{sguid,sname},
					pname.."'s "..dname.." pulled "..sname.."! /ywho to tell everyone!");
			end
		 else
		 	--Record summon
			WhoPulled_PetsToMaster[dguid] = sname;
		 end
		end
	end
end

function WhoPulled_GetNameServ(combo)
	if not combo then return nil; end
	local name,serv = combo:match("([^%- ]+)%-?(.*)");
	if(name == "") then return nil,nil; end
	if(serv == "") then
		serv = GetRealmName();
		if not serv then serv = ""; end --whatever
	end
	return name,serv;
end

function WhoPulled_NameOrTarget(combo)
	if(name == "%t") then return UnitName("playertarget");
	else return combo;
	end
end

function WhoPulled_CLI(line)
	local pos,comm;
	pos = strfind(line," ");
	if(pos) then
		comm = strlower(strsub(line,1,pos-1));
		line = strsub(line,pos+1);
	else
		comm = line;
		line = "";
	end
	if(comm == "clear")then
		wipe(WhoPulled_MobToPlayer);
		WhoPulled_LastMob = "";
	elseif(comm == "boss")then
		line = strlower(line);
		if(line == "rw") then
			WhoPulled_Settings["rwonboss"] = true;
			WhoPulled_Settings["yonboss"] = true;
			DEFAULT_CHAT_FRAME:AddMessage("Automatic raid warning of who pulled a boss: on");
		elseif(line == "true" or line == "yell" or line == "on") then
			WhoPulled_Settings["rwonboss"] = false;
			WhoPulled_Settings["yonboss"] = true;
			DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: on");
		else
			WhoPulled_Settings["rwonboss"] = false;
			WhoPulled_Settings["yonboss"] = false;
			DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: off");
		end
	elseif(comm == "msg")then
		WhoPulled_Settings["msg"] = line;
	elseif(comm == "silent")then
		line = strlower(line);
		if(line == "true" or line == "yell" or line == "on") then
			WhoPulled_Settings["silent"] = true;
			DEFAULT_CHAT_FRAME:AddMessage("Silent mode: on");
		else
			WhoPulled_Settings["silent"] = false;
			DEFAULT_CHAT_FRAME:AddMessage("Silent mode: off");
		end
	elseif(comm == "tank" or comm == "tanks") then
		line = WhoPulled_NameOrTarget(line);
		WhoPulled_Tanks = " "..line.." ";
		DEFAULT_CHAT_FRAME:AddMessage("Set tanks to:"..WhoPulled_Tanks);
	elseif(comm == "rage") then
		line = WhoPulled_NameOrTarget(line);
		if(WhoPulled_MobToPlayer[line]) then
			local name,serv = WhoPulled_GetNameServ(WhoPulled_MobToPlayer[line]);
			if not WhoPulled_RageList[serv] then WhoPulled_RageList[serv] = {}; end
			WhoPulled_RageList[serv][name] = line;
			DEFAULT_CHAT_FRAME:AddMessage("Your rage for "..name.." from "..serv.." for pulling "..line.." is now set in stone. You will be reminded should they ever join your party again.");
		else
			DEFAULT_CHAT_FRAME:AddMessage("No one pulled a "..line..".");
		end
	elseif(comm == "forgive") then
		local name,serv = WhoPulled_GetNameServ(line);
		if(name) then
			local i,v,x;
			WhoPulled_RageList[serv][name] = nil;
			x=0;
			for i,v in pairs(WhoPulled_RageList[serv]) do
				x=x+1;
			end
			if(x == 0) then WhoPulled_RageList[serv] = nil; end
			DEFAULT_CHAT_FRAME:AddMessage("You have decided to give "..name.." of "..serv.." a second chance.");
		else
			DEFAULT_CHAT_FRAME:AddMessage("You have nothing against that player anyway.");
		end
	elseif(comm == "list") then
		local i,i2,v,v2,t;
		if(line ~= "") then
			line = WhoPulled_NameOrTarget(line);
			t = {};
			for i2,v2 in pairs(WhoPulled_RageList) do
				for i,v in pairs(v2) do
					if(i2 == line or v == line) then
						if not t[i2] then t[i2] = {}; end
						t[i2][i] = v;
					end
				end
			end
		else
			t = WhoPulled_RageList;
		end
		for i2,v2 in pairs(t) do
			DEFAULT_CHAT_FRAME:AddMessage("~~~~["..i2.."]~~~~");
			for i,v in pairs(v2) do
				DEFAULT_CHAT_FRAME:AddMessage(" * "..i..": Pulled "..v);
			end
		end
	elseif(comm == "ignore")then
		line = WhoPulled_NameOrTarget(line);
		if(WhoPulled_Ignore[line]) then 
			WhoPulled_Ignore[line] = nil;
			DEFAULT_CHAT_FRAME:AddMessage("Now listening to pulls of "..line);
		else
			WhoPulled_Ignore[line] = true;
			DEFAULT_CHAT_FRAME:AddMessage("Now ignoring pulls of "..line);
		end
	elseif(comm == "help")then
		line = strlower(line);
		if(line == "clear") then
			DEFAULT_CHAT_FRAME:AddMessage("Clears stored data on who pulled what for this session.");
		elseif(line == "boss" or line == "wpyb") then
			DEFAULT_CHAT_FRAME:AddMessage("Turns automatically yelling on boss pull on or off. Say rw if you want to use raid warning insted of yell. The short hand toggle for this is /wpyb");
		elseif(line == "msg") then
			DEFAULT_CHAT_FRAME:AddMessage("Message that you say. Use %p for the player who pulled, and %e for the enemy he pulled.");
		elseif(line == "who" or line == "swho" or line == "ywho" or line == "rwho" or line == "pwho" or line == "bwho" or line == "gwho" or line == "owho" or line == "rwwho") then
			DEFAULT_CHAT_FRAME:AddMessage("/Xwho Announce who pulled the latest pull or the given enemy where X can be s for Say, y for Yell, r for Raid, rw for Raid Warning, p for Party, g for Guild, o for Officer, b for Battlground, or m (Me/My) for only showing it to yourself.");
		elseif(line == "silent" or line == "wpsm") then
			DEFAULT_CHAT_FRAME:AddMessage("When active, do not show who pulled what when it happens. The short hand toggle for this is /wpsm");
		elseif(line == "tank" or line == "tanks") then
			DEFAULT_CHAT_FRAME:AddMessage("Any players you pass in this list will not be shown to pull enemies. This way you can ignore tank pulls, and only see when someone else pulls. List can be space, comma, period, or | separated. This list will be cleared when you leave the party or raid group.");
		elseif(line == "rage") then
			DEFAULT_CHAT_FRAME:AddMessage("Add the player who killed the given enemy to your rage list for future warnings about that player.");
		elseif(line == "forgive") then
			DEFAULT_CHAT_FRAME:AddMessage("Remove the given player from your rage list. Remember to give the name as Name-Realm if they're not on the realm you're currently on.");
		elseif(line == "list") then
			DEFAULT_CHAT_FRAME:AddMessage("Dump your rage list to the console, optionally filtered by what they killed or what raelm they're from.");
		elseif(line == "ignore") then
			DEFAULT_CHAT_FRAME:AddMessage("Toggles ignoring messages about pulls of a certain enemy, such as critters.");
		elseif(line == "help") then
			DEFAULT_CHAT_FRAME:AddMessage("Are you serious? lol");
		else
			DEFAULT_CHAT_FRAME:AddMessage("{} surround required parameters, [] surround optional ones.");
			DEFAULT_CHAT_FRAME:AddMessage("/wp help [topic] For help on a specific function.");
			DEFAULT_CHAT_FRAME:AddMessage("/wp clear");
			DEFAULT_CHAT_FRAME:AddMessage("/wp boss {on/off}");
			DEFAULT_CHAT_FRAME:AddMessage("/wp silent {on/off}");
			DEFAULT_CHAT_FRAME:AddMessage("/wp msg {custom message}");
			DEFAULT_CHAT_FRAME:AddMessage("/wp tanks [list of tanks]");
			DEFAULT_CHAT_FRAME:AddMessage("/wp rage {enemy}");
			DEFAULT_CHAT_FRAME:AddMessage("/wp forgive {player}");
			DEFAULT_CHAT_FRAME:AddMessage("/wp list [enemy/realm]");
			DEFAULT_CHAT_FRAME:AddMessage("/wp ignore [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/swho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/ywho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/rwho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/rwwho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/pwho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/bwho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/gwho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/owho [enemy]");
			DEFAULT_CHAT_FRAME:AddMessage("/mwho [enemy]");
		end
	end
end

function WhoPulled_SendMsg(chat,enemy)
	local msg,player;
	if enemy == "" then enemy = WhoPulled_LastMob; end
	player = WhoPulled_MobToPlayer[enemy];
	if player then
		msg = WhoPulled_Settings["msg"]:gsub("%%p",player);
		msg = msg:gsub("%%e",enemy);
		if(chat == "ECHO") then
			DEFAULT_CHAT_FRAME:AddMessage(msg);
		else
			SendChatMessage(msg,chat);
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("No information on who pulled that enemy.");
	end
end

function WhoPulled_Say(enemy)
	WhoPulled_SendMsg("SAY",enemy)
end
function WhoPulled_Yell(enemy)
	WhoPulled_SendMsg("YELL",enemy)
end
function WhoPulled_Raid(enemy)
	WhoPulled_SendMsg("RAID",enemy)
end
function WhoPulled_Party(enemy)
	WhoPulled_SendMsg("PARTY",enemy)
end
function WhoPulled_BG(enemy)
	WhoPulled_SendMsg("BATTLEGROUND",enemy)
end
function WhoPulled_Guild(enemy)
	WhoPulled_SendMsg("GUILD",enemy)
end
function WhoPulled_Officer(enemy)
	WhoPulled_SendMsg("OFFICER",enemy)
end
function WhoPulled_RaidWarning(enemy)
	WhoPulled_SendMsg("RAID_WARNING",enemy)
end
function WhoPulled_Me(enemy)
	WhoPulled_SendMsg("ECHO",enemy)
end

function WhoPulled_YoB()
	WhoPulled_Settings["yonboss"] = not WhoPulled_Settings["yonboss"];
	if(WhoPulled_Settings["yonboss"]) then DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: on");
	else DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: off");
	end
end

function WhoPulled_Silent()
	WhoPulled_Settings["silent"] = not WhoPulled_Settings["silent"];
	if(WhoPulled_Settings["silent"]) then DEFAULT_CHAT_FRAME:AddMessage("Silent mode: on");
	else DEFAULT_CHAT_FRAME:AddMessage("Silent mode: off");
	end
end

SlashCmdList["YWHOPULLED"] = WhoPulled_Yell;
SLASH_YWHOPULLED1 = "/ywho";
SlashCmdList["SWHOPULLED"] = WhoPulled_Say;
SLASH_SWHOPULLED1 = "/swho";
SlashCmdList["RWHOPULLED"] = WhoPulled_Raid;
SLASH_RWHOPULLED1 = "/rwho";
SlashCmdList["PWHOPULLED"] = WhoPulled_Party;
SLASH_PWHOPULLED1 = "/pwho";
SlashCmdList["BWHOPULLED"] = WhoPulled_BG;
SLASH_BWHOPULLED1 = "/bwho";
SlashCmdList["MWHOPULLED"] = WhoPulled_Me;
SLASH_MWHOPULLED1 = "/mwho";
SlashCmdList["GWHOPULLED"] = WhoPulled_Guild;
SLASH_BWHOPULLED1 = "/gwho";
SlashCmdList["OWHOPULLED"] = WhoPulled_Officer;
SLASH_BWHOPULLED1 = "/owho";
SlashCmdList["RWWHOPULLED"] = WhoPulled_RaidWarning;
SLASH_RWWHOPULLED1 = "/rwwho";
SlashCmdList["WHOPULLED"] = WhoPulled_CLI;
SLASH_WHOPULLED1 = "/wp";
SlashCmdList["WHOPULLEDB"] = WhoPulled_YoB;
SLASH_WHOPULLEDB1 = "/wpyb";
SlashCmdList["WHOPULLEDSM"] = WhoPulled_Silent;
SLASH_WHOPULLEDSM1 = "/wpsm";
