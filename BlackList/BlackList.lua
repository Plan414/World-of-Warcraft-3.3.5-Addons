BlackList = {};

BL_Blocked_Channels = {"SAY", "YELL", "WHISPER", "WHISPER_INFORM", "PARTY", "RAID", "RAID_WARNING", "EMOTE", "TEXT_EMOTE", "CHANNEL", "CHANNEL_JOIN", "CHANNEL_LEAVE"};
-- removed "GUILD", "OFFICER"

Already_Warned_For = {};
Already_Warned_For["WHISPER"] = {};
Already_Warned_For["TARGET"] = {};
Already_Warned_For["PARTY_INVITE"] = {};
Already_Warned_For["PARTY"] = {};
Already_Warned_For["MOUSEOVER"] = {};
Already_Warned_For["GUILD_ROSTER"] = {};

BlackListedPlayers = {};

local SLASH_TYPE_ADD = 1;
local SLASH_TYPE_REMOVE = 2;

local BL_Default = {
	Sound = true,
	Center = true,
	Chat = true,
	Ignore = true,
	Ban = false,
	Kick = false,
	Rank = 5,
}

-- Function to handle onload event
function BlackList:OnLoad()

	-- constructions
	self:RegisterEvents();
	self:HookFunctions();
	self:RegisterSlashCmds();
	
	if (not BlackListConfig) then BlackListConfig = BL_Default; end
	if BlackListConfig.Sound == nil or "" then BlackListConfig.Sound = true; end
	if BlackListConfig.Center == nil or "" then BlackListConfig.Center = true; end
	if BlackListConfig.Chat == nil or "" then BlackListConfig.Chat = true; end
	if BlackListConfig.Ignore == nil or "" then BlackListConfig.Ignore = true; end
	if BlackListConfig.Ban == nil or "" then BlackListConfig.Ban = false; end
	if BlackListConfig.Kick == nil or "" then BlackListConfig.Kick = false; end
	if BlackListConfig.Rank == nil or "" then BlackListConfig.Rank = 5; end

	-- add target popup menu line "Add to BL"
	AddMenuItems();

end

-- Registers events to be recieved
function BlackList:RegisterEvents()

	local frame = getglobal("BlackListTopFrame");

	-- register events
	frame:RegisterEvent("VARIABLES_LOADED");
	frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	frame:RegisterEvent("PARTY_INVITE_REQUEST");
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	frame:RegisterEvent("WHO_LIST_UPDATE");
	frame:RegisterEvent("CHAT_MSG_SYSTEM");
	frame:RegisterEvent("GUILD_ROSTER_UPDATE");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");

end

function AddMenuItems()
	
	-- adding a guild invite and friends invite option also
	
	UnitPopupButtons["AddToBl"] = { text = "Black List", dist = 0 }
	UnitPopupButtons["GInv"] = { text = "Guild Invite", dist = 0 }
	UnitPopupButtons["FInv"] = { text = "Add to Friends", dist = 0 }
	
	hooksecurefunc("UnitPopup_HideButtons", function()
		local dropdownMenu = UIDROPDOWNMENU_INIT_MENU
		for i,v in pairs(UnitPopupMenus[dropdownMenu.which]) do
			if v=="AddToBl" then UnitPopupShown[i] = (dropdownMenu.name == UnitName("player") and 0) or 1 end
			if v=="GInv" then UnitPopupShown[i] = (dropdownMenu.name == UnitName("player") and 0) or 1 end
			if v=="FInv" then UnitPopupShown[i] = (dropdownMenu.name == UnitName("player") and 0) or 1 end
		end
	end)
	
	hooksecurefunc("UnitPopup_OnClick", function()
		local dropdownMenu = getglobal("UIDROPDOWNMENU_INIT_MENU")
		unit = dropdownMenu.name
		if (this.value == "AddToBl") and (dropdownMenu.name ~= UnitName("player")) then BlackList:AddPlayer(dropdownMenu.name, nil, BlackListConfig.Ignore, nil) end
		if (this.value == "GInv") and (dropdownMenu.name ~= UnitName("player")) then GuildInvite(dropdownMenu.name) end
		if (this.value == "FInv") and (dropdownMenu.name ~= UnitName("player")) then AddFriend(dropdownMenu.name) end
	end)

	--Insert it to the end -1;
	table.insert(UnitPopupMenus["PLAYER"], (#UnitPopupMenus["PLAYER"])-1, "AddToBl");
	table.insert(UnitPopupMenus["PARTY"], (#UnitPopupMenus["PARTY"])-1, "AddToBl");
	table.insert(UnitPopupMenus["RAID_PLAYER"], (#UnitPopupMenus["RAID_PLAYER"])-1, "AddToBl");
	table.insert(UnitPopupMenus["CHAT_ROSTER"], (#UnitPopupMenus["CHAT_ROSTER"])-1, "AddToBl");
	table.insert(UnitPopupMenus["FRIEND"], (#UnitPopupMenus["FRIEND"])-1, "AddToBl");
	
	table.insert(UnitPopupMenus["PLAYER"], (#UnitPopupMenus["PLAYER"])-1, "GInv");
	table.insert(UnitPopupMenus["PARTY"], (#UnitPopupMenus["PARTY"])-1, "GInv");
	table.insert(UnitPopupMenus["RAID_PLAYER"], (#UnitPopupMenus["RAID_PLAYER"])-1, "GInv");
	table.insert(UnitPopupMenus["CHAT_ROSTER"], (#UnitPopupMenus["CHAT_ROSTER"])-1, "GInv");
	table.insert(UnitPopupMenus["FRIEND"], (#UnitPopupMenus["FRIEND"])-1, "GInv");
	
	table.insert(UnitPopupMenus["PLAYER"], (#UnitPopupMenus["PLAYER"])-1, "FInv");
	table.insert(UnitPopupMenus["PARTY"], (#UnitPopupMenus["PARTY"])-1, "FInv");
	table.insert(UnitPopupMenus["RAID_PLAYER"], (#UnitPopupMenus["RAID_PLAYER"])-1, "FInv");
	table.insert(UnitPopupMenus["CHAT_ROSTER"], (#UnitPopupMenus["CHAT_ROSTER"])-1, "FInv");
	table.insert(UnitPopupMenus["FRIEND"], (#UnitPopupMenus["FRIEND"])-1, "FInv");
	
	--refresh menu for target frame
--	UIDropDownMenu_Initialize(TargetFrameDropDown, TargetFrameDropDown_Initialize, "MENU");
	-- BlackList.chatMsg("done");
end


local Orig_ChatFrame_MessageEventHandler;
-- Hooks onto the functions needed
function BlackList:HookFunctions()

	Orig_ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler;
	ChatFrame_MessageEventHandler = BL_MessageEventHandler;
end

-- Hooked ChatFrame_MessageEventHandler function
function BL_MessageEventHandler(event, ...)

	local warnplayer, warnname  = false, nil;
	
	if (strsub(tostring(event), 1, 8) == "CHAT_MSG") then
		local event = tostring(event);
		local type = string.sub(event, 10);

		for key, channel in pairs(BL_Blocked_Channels) do
			if (type == channel) then
				-- search for player name
				local name = arg2;
				if (BlackList:GetIndexByName(name) > 0) then
					local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));
					
					if (player["ignore"]) then
						-- respond to whisper
						if (type == "WHISPER") then
							local alreadywarned = false;
							for key, warnedname in pairs(Already_Warned_For["WHISPER"]) do
								if (name == warnedname) then
									alreadywarned = true;
								end
							end
							
							if (not alreadywarned) then
								table.insert(Already_Warned_For["WHISPER"], name);
								SendChatMessage(PLAYER_IGNORING, "WHISPER", nil, name);
							end
							-- block communication
							return;
						elseif (type == "WHISPER_INFORM") then
							warnplayer = true;
							warnname = name;
						end
					elseif (player["warn"]) then
						-- warn player
						if (type == "WHISPER") then
							local alreadywarned = false;

							for key, warnedname in pairs(Already_Warned_For["WHISPER"]) do
								if (name == warnedname) then
									alreadywarned = true;
								end
							end

							if (not alreadywarned) then
								table.insert(Already_Warned_For["WHISPER"], name);
								warnplayer = true;
								warnname = name;
							end
						end
					end
				end
			end
		end
	end

	local returnvalue = Orig_ChatFrame_MessageEventHandler(event, ...);

	if (warnplayer) then
		this:AddMessage(warnname .. " is on your blacklist", 1.0, 0.0, 0.0);
	end

	return returnvalue;

end

-- Registers slash cmds
function BlackList:RegisterSlashCmds()

	SlashCmdList["BlackList"]   = function(args)
							BlackList:HandleSlashCmd(SLASH_TYPE_ADD, args)
						end;
	SLASH_BlackList1 = "/blacklist";
	SLASH_BlackList2 = "/bl";

	SlashCmdList["RemoveBlackList"]   = function(args)
								BlackList:HandleSlashCmd(SLASH_TYPE_REMOVE, args)
							end;
	SLASH_RemoveBlackList1 = "/removeblacklist";
	SLASH_RemoveBlackList2 = "/removebl";

end

-- Handles the slash cmds
function BlackList:HandleSlashCmd(type, args)

	if (type == SLASH_TYPE_ADD) then
		if (args == "") then
			self:AddPlayer("target", nil, BlackListConfig.Ignore, nil);
		else
			local name = args;
			local reason = "";
			local index = string.find(args, " ", 1, true);
			if (index) then
				-- space found, have reason in args
				name = string.sub(args, 1, index - 1);
				reason = string.sub(args, index + 1);
			end

			self:AddPlayer(name, nil, BlackListConfig.Ignore, reason);
		end
	elseif (type == SLASH_TYPE_REMOVE) then
		if (args == "") then
			self:RemovePlayer("target");
		else
			self:RemovePlayer(args);
		end
	end

end

-- Function to handle events
function BlackList:HandleEvent(event)

	if (event == "PLAYER_ENTERING_WORLD") then

			self:InsertUI();
	end

	if (event == "VARIABLES_LOADED") then
		if (not BlackListedPlayers[GetRealmName()]) then BlackListedPlayers[GetRealmName()] = {}; end


	elseif (event == "PLAYER_TARGET_CHANGED") then
		-- search for player name
		local name = (UnitName("target"));
		local faction, localizedFaction = UnitFactionGroup("target");
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			-- warn player
			if (player["warn"]) then
                local alreadywarned = false;
				for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10)) then
						alreadywarned = true;
					end
				end

				if (not alreadywarned) then
					Already_Warned_For["TARGET"][name]=GetTime();
					BlackList:AddSound();
					BlackList:AddErrorMessage(name .. " is on your Black List (targeted)", "red", 5);
					BlackList:AddMessage(name .. " is on your Black List for reason: " .. player["reason"], "yellow");
				end
			end
		end
		
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		-- search for player name
		local name = UnitName("mouseover");
		local faction, localizedFaction = UnitFactionGroup("mouseover");
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			-- warn player
			if (player["warn"]) then
				local alreadywarned = false;
				for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10)) then
						alreadywarned = true;
					end
				end

				if (not alreadywarned) then
					Already_Warned_For["TARGET"][name]=GetTime();
					BlackList:AddSound();
					BlackList:AddErrorMessage(name .. " is on your Black List (mouseover)", "red", 5);
					BlackList:AddMessage(name .. " is on your Black List for reason: " .. player["reason"], "yellow");
					-- also update character info
					-- BlackList:UpdateDetails(BlackList:GetIndexByName(name), nil, nil, nil, UnitLevel("mouseover"), UnitClass("mouseover"), UnitRace("mouseover"));
				end
			end
		end
		
	elseif (event == "PARTY_INVITE_REQUEST") then
		-- search for player name
		local name = arg1;
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			if (player["ignore"]) then
				-- decline party invite
				DeclineGroup();
				StaticPopup_Hide("PARTY_INVITE");
            -- warn player
			elseif (player["warn"]) then
				local alreadywarned = false;
				for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10))  then
						alreadywarned = true;
					end
				end
                if (not alreadywarned) then
					Already_Warned_For["TARGET"][name]=GetTime()+300;
					BlackList:AddSound();
					BlackList:AddErrorMessage(name .. " is on your Black List (invited to party)", "red", 10);
				end
			end
		end
		
	elseif (event == "PARTY_MEMBERS_CHANGED") then
		for i = 0, GetNumPartyMembers(), 1 do
			-- search for player name
			local name = UnitName("party" .. i);
			if (BlackList:GetIndexByName(name) > 0) then
				local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

                -- warn player
				if (player["warn"]) then
 					local alreadywarned = false;
  					for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
						if ((name == warnedname) and (GetTime() < timepassed+10))  then
							alreadywarned = true;
						end
					end
					if (not alreadywarned) then
						Already_Warned_For["TARGET"][name]=GetTime()+300;
						BlackList:AddSound();
						BlackList:AddMessage(name .. " is on your Black List (in your party)", "red");
						if player["reason"] ~= "" then
							BlackList:AddMessage("for: " .. player["reason"], "red");
						end
					end
				end
			end
		end
		
	elseif (event == "WHO_LIST_UPDATE") then
		for i = 0, GetNumWhoResults(), 1 do 
			local whoname, guild, level, race, class, zone, group = GetWhoInfo(i);
			if (BlackList:GetIndexByName(whoname) > 0) then
				BlackList:AddMessage(whoname .. " is on your Black List (from your who search)", "red");
			end
		end
		
	elseif (event == "GUILD_ROSTER_UPDATE" and IsInGuild() ~= nil) then
		local bootNum = 0;
		for i = 0, GetNumGuildMembers(), 1 do 
			local Pname, Prank, PrankIndex = GetGuildInfo("player");
			local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
			local yearsOffline, monthsOffline, daysOffline = GetGuildRosterLastOnline(i);
			daysOffline = daysOffline and daysOffline or 0;
			monthsOffline = monthsOffline and monthsOffline or 0;

			-- check for blacklist
			if (BlackList:GetIndexByName(name) > 0) then
				local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

                -- warn player
				if (player["warn"]) then
					local alreadywarned = false;
					for warnedname, timepassed in pairs(Already_Warned_For["GUILD_ROSTER"]) do
						if ((name == warnedname) and (GetTime() < timepassed+10)) then
							alreadywarned = true;
						end
					end
					if (not alreadywarned) then
						Already_Warned_For["GUILD_ROSTER"][name]=GetTime()+300;
						BlackList:AddSound();
						BlackList:AddMessage(name .. " is on your Black List and is in your GUILD", "red");

						-- auto kick from guild
						if BlackListConfig.Ban and CanGuildRemove() and rankIndex >= BlackListConfig.Rank and rankIndex > PrankIndex and string.find(officernote, "[Kk][Ii][Cc][Kk]") == nil then
							GuildUninvite(name);
    	                    if player["reason"] ~= "" then
        	                    local bannedmsg = name .. " has been banned from the Guild for: " .. player["reason"] .. ". Do not reinvite!";
								SendChatMessage(bannedmsg,"GUILD",nil,index);
							else
                    	        local bannedmsg = name .. " has been banned from the Guild. Do not reinvite!";
								SendChatMessage(bannedmsg,"GUILD",nil,index);
							end
							if (online ~= nil) then SendChatMessage("You have been banned from the guild for life. Please do not join again!","WHISPER",nil,name); end
						end
					end
				end
			end	

--[[
			if BlackListConfig.Kick and CanGuildRemove() and rankIndex >= BlackListConfig.Rank and rankIndex > PrankIndex and string.find(officernote, "[Kk][Ii][Cc][Kk]") == nil then
				if (daysOffline >= 30 or monthsOffline >= 1) then
					local alreadykicked = false;
					for kickedname, timepassed in pairs(Already_Warned_For["GUILD_ROSTER"]) do
						if ((name == kickedname) and (GetTime() < timepassed+10)) then
							alreadykicked = true;
						end
					end
					if (not alreadykicked) then
						Already_Warned_For["GUILD_ROSTER"][name]=GetTime()+10;
						GuildUninvite(name);
						bootNum = bootNum + 1;
					end
				end
			end
]]		end
		
		if bootNum > 0 then
			local kickedmsg
			if (bootNum == 1) then kickedmsg = tostring(bootNum) .. " inactive kicked";
			else kickedmsg = tostring(bootNum) .. " inactives kicked"; end
			SendChatMessage(kickedmsg ,"GUILD",nil,index);
			bootNum = 0;
		end

	elseif (event == "CHAT_MSG_SYSTEM") then
		local whoname = string.match(arg1, "(%a+)", 10);
		if (BlackList:GetIndexByName(whoname) > 0) then
			BlackList:AddMessage(whoname .. " is on your Black List", "red");
		end
	end
end

-- Blacklists the given player, sets the ignore flag to be 'ignore' and enters the given reason
function BlackListPlayer(player, warn, ignore, reason)

	BlackList:AddPlayer(player, warn, ignore, reason);

end

function BL_TooltipOn(self)
	local TooltipText = getglobal(self:GetName() .. "_Tooltip")
	if TooltipText then
		local Label
		local FontString = getglobal(self:GetName() .. "_Label")
		if type(FontString) == "string" then
			Label = FontString
		elseif FontString then
			Label = FontString:GetText()
		elseif this.GetText and self:GetText() then
			Label = self:GetText()
		end
		if Label then
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:AddLine(Label, 1, 1, 1, 1)
			GameTooltip:AddLine(TooltipText, nil, nil, nil, 1, 1)
			GameTooltip:Show()
		end
	end
end

function BL_TooltipOff()
	GameTooltip:Hide()
end

BL_General_Label_Text = "General Options:"
BL_Guild_Label_Text = "Guild Officer Options:"
BL_RankBox_Label_Text = "+"

BL_RankBox_Label = "Rank filter"
BL_RankBox_Tooltip = "This number corresponds to guild member's ranks. The Ranks start at 0 for GM and values increase for lower ranks. Generally set this value at 3 or above to filter out officers. Default is rank 5."
BanCheckButton_Label = "Auto-Ban:"
BanCheckButton_Tooltip = "Automatically bans any BlackListed players from your guild, providing you have the permission to do so."
KickCheckButton_Label = "Auto-Kick:"
KickCheckButton_Tooltip = "Misc: Automatically removes any inactive players from your guild, providing you have the permission to do so. THIS FEATURE IS DISABLED"

SoundCheckButton_Label = "Play Sound:"
SoundCheckButton_Tooltip = "Play a sound when you mouse over a BlackListed player."
ChatCheckButton_Label = "Show Reason:"
ChatCheckButton_Tooltip = "Displays the reason text for a BlackListed player when you mouse over them."

IgnoreCheckButton_Label = "Auto-Ignore:"
IgnoreCheckButton_Tooltip = "Automatically ignores any future players you place on the BlackList."
CenterCheckButton_Label = "Warn at Center:"
CenterCheckButton_Tooltip = "Shows a warning message in the center of your screen when you mouse over a BlackListed player."