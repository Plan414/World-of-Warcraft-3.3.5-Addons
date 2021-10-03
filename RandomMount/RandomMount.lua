RandomMountData = {};

RandomMount_MyNonFlying60 = {};
RandomMount_MyNonFlying100 = {};
RandomMount_MyFlying60 = {};
RandomMount_MyFlying280 = {};
RandomMount_MyFlying310 = {};

RandomMountData.last = nil;
RandomMountData.favorite = nil;

local LBF = LibStub("LibButtonFacade", true);
local buttongroup = nil;

-- functions

function RandomMount_OnLoad()

 	DEFAULT_CHAT_FRAME:AddMessage("|c333399ffNirriti's |rRandomMount loaded.", 1.0, 1.0, 1.0, 1, 10);

	local button = CreateFrame("Button", "RandomMountButton", RandomMountFrame, "RandomMountButtonTemplate");
	button:ClearAllPoints();
	button:SetPoint("CENTER", RandomMountFrame, "CENTER", 0, 0);
	texture = "Interface\\Icons\\Ability_Mount_WhiteTiger";
			
	local icon = _G["RandomMountButtonIcon"];
	icon:SetTexture(texture);
	
	button:SetScript("OnClick", function(self, button, down)
		if (button == "LeftButton") then
			if (IsControlKeyDown()) then
 				DEFAULT_CHAT_FRAME:AddMessage("RandomMount: "..RandomMount_DOINITMOUNTS, 1.0, 1.0, 0, 1, 10); 
				RandomMount_InitCharacterMounts(1);
			else
				RandomMount_MountAuswaehlen();
			end
		elseif (button == "RightButton") then
			RandomMount_MountWegschicken();
		end
	end);
	
	if (LBF) then
	    buttongroup = LBF:Group("RandomMount");
	    buttongroup:AddButton(button);
	end
	
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("ZONE_CHANGED");
	this:RegisterEvent("ZONE_CHANGED_INDOORS");
	
	RandomMount_InitSlashCommandHandler();

	RandomMount_InitCharacterMounts(1);
end

function RandomMount_InitSlashCommandHandler()

	SLASH_RANDOMMOUNT1 = "/rmount";
  	SLASH_RANDOMMOUNT2 = "/randommount";
  	SlashCmdList["RANDOMMOUNT"] = function(msg)
		RandomMount_SlashCommandHandler(msg);
	end
end

function RandomMount_SlashCommandHandler(msg)
	if (msg == "reload") then
	 	ReloadUI();
	elseif (string.find(msg, "favorite") == 1) then
		local name = string.sub(msg, 10);
		
		if (not name or strlen(name) == 0) then
	 	    RandomMountData.favorite = RandomMountData.last;
	 	else
	 	    RandomMountData.favorite = name;
	 	end;
	end
end

function RandomMount_OnUpdate(self, elapsed)
    if (UnitInVehicle("player")) then
        RandomMountFrame:SetAlpha(0.15);
    else
        RandomMountFrame:SetAlpha(1);
    end
		
	RandomMount_UpdateUsable();
end

function RandomMounts_OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED") then
		RandomMount_InitCharacterMounts(0);
	end
		
	RandomMount_UpdateUsable();
end

function RandomMount_InitCharacterMounts(ckeckfound)

	local count = GetNumCompanions("MOUNT");

	RandomMount_MyNonFlying60 = {};
	RandomMount_MyNonFlying100 = {};
	RandomMount_MyFlying60 = {};
	RandomMount_MyFlying280 = {};
	RandomMount_MyFlying310 = {};

	for i=1, count, 1 do
 		creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo("MOUNT", i);
 		
 		local found = 0;
 		
		for f=1, #(RandomMount_NonFlying60), 1 do
			if (creatureSpellID == RandomMount_NonFlying60[f]) then
				table.insert(RandomMount_MyNonFlying60, creatureName);
				found = 1;
			end
		end 
		
		for f=1, #(RandomMount_NonFlying100), 1 do
			if (creatureSpellID == RandomMount_NonFlying100[f]) then
				table.insert(RandomMount_MyNonFlying100, creatureName);
				found = 1;
			end
		end 
		
		for f=1, #(RandomMount_Flying60), 1 do
			if (creatureSpellID == RandomMount_Flying60[f]) then
				table.insert(RandomMount_MyFlying60, creatureName);
				found = 1;
			end
		end
		
		for f=1, #(RandomMount_Flying280), 1 do
			if (creatureSpellID == RandomMount_Flying280[f]) then
				table.insert(RandomMount_MyFlying280, creatureName);
				found = 1;
			end
		end
		
		for f=1, #(RandomMount_Flying310), 1 do
			if (creatureSpellID == RandomMount_Flying310[f]) then
				table.insert(RandomMount_MyFlying310, creatureName);
				found = 1;
			end
		end
		
		if (found == 0 and checkfound == 1) then
            DEFAULT_CHAT_FRAME:AddMessage("    |c333399ffRandomMount|r: "..creatureName.." ("..creatureSpellID..") not found.", 1.0, 1.0, 1.0, 1, 10);
 		end
	end
end

function RandomMount_FavoriteMountAuswaehlen()
 	if (RandomMountData.favorite) then
 	    RandomMount_MountRufen(RandomMountData.favorite);
 	end
end

function RandomMount_FavoriteMountWegschicken()
    RandomMount_MountWegschicken();
end

function RandomMount_MountAuswaehlen()
	local count = GetNumCompanions("MOUNT");
	
	if (count > 0 and IsOutdoors() == 1) then
			
		local flyable = RandomMount_IsFlyable();
				
		local countFlying310 = #(RandomMount_MyFlying310);
		local countFlying280 = #(RandomMount_MyFlying280);
		local countFlying60 = #(RandomMount_MyFlying60);
		local countNonFlying100 = #(RandomMount_MyNonFlying100);
		local countNonFlying60 = #(RandomMount_MyNonFlying60);

		if (flyable == 1) then
			-- flyable
				
			if (countFlying310 > 0) then
				local rnd = math.random(1, countFlying310);
				local name = RandomMount_MyFlying310[rnd];
					
				RandomMount_MountRufen(name);
				return;
			end
			
			if (countFlying280 > 0) then
				local rnd = math.random(1, countFlying280);
				local name = RandomMount_MyFlying280[rnd];
				
				RandomMount_MountRufen(name);
				return;
			end
				
			if (countFlying60 > 0) then
				local rnd = math.random(1, countFlying60);
				local name = RandomMount_MyFlying60[rnd];
					
				RandomMount_MountRufen(name);
				return;
			end
		else
			-- non flyable
				
			if (countNonFlying100 > 0) then
				local rnd = math.random(1, countNonFlying100);
				local name = RandomMount_MyNonFlying100[rnd];
					
				RandomMount_MountRufen(name);
				return;
			end
				
			if (countNonFlying60 > 0) then
				local rnd = math.random(1, countNonFlying60);
				local name = RandomMount_MyNonFlying60[rnd];
					
				RandomMount_MountRufen(name);
				return;
			end
		end
	end
end

function RandomMount_MountRufen(name)

	local count = GetNumCompanions("MOUNT");
	
	for i=1,count,1 do
 		creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo("MOUNT", i);
 				
 		if (creatureName == name) then
 		    RandomMountData.last = name;
 			CallCompanion("MOUNT", i);
 		end
 	end
end

function RandomMount_MountWegschicken()
	if (IsMounted()) then
		Dismount();
	end
end

function RandomMount_IsFlyable()
	local flyable = 1;
	
	local countFlyable = #(RandomMount_MyFlying60) + #(RandomMount_MyFlying280) + #(RandomMount_MyFlying310);
	local zone = GetZoneText();
	local subzone = GetSubZoneText();
			
	if (IsAltKeyDown() or countFlyable == 0) then
		flyable = 0;
	elseif (zone == RandomMount_DALARAN and subzone ~= RandomMount_DALARAN_LANDING) then
		flyable = 0;
	elseif (GetCurrentMapAreaID() == WORLDMAP_WINTERGRASP_ID) then
	    local nextBattleTime = GetWintergraspWaitTime();
	    
	    if (nextBattleTime == nil) then
		    flyable = 0;
		end
	elseif (IsFlyableArea() == nil) then
		flyable = 0;
	end
	
	return flyable;
end

function RandomMount_UpdateUsable()

	local button = getglobal("RandomMountButton");
	
	local icon = _G["RandomMountButtonIcon"];

    color = {r=1.0, g=1.0, b=1.0};
    icon:SetVertexColor(color.r, color.g, color.b);
    
    if (IsOutdoors() == 1) then
    else
        color = {r=0.3, g=0.3, b=0.3};
        icon:SetVertexColor(color.r, color.g, color.b);
    end
end

function RandomMount_MouseOver()
	RandomMount_SetTooltip(this);
end

function RandomMount_MouseOut()
	GameTooltip:Hide();
end

function RandomMount_SetTooltip()
	if (this:GetName() == "RandomMountButton") then
	
		local flyable = RandomMount_IsFlyable();

		GameTooltip_SetDefaultAnchor(GameTooltip, this);
        GameTooltip:SetText("|cffffffffRandomMount|r");
        
        if (flyable == 1) then
			GameTooltip:AddLine(RandomMount_FLYABLEAREA, nil, nil, nil, 1);
		else
			GameTooltip:AddLine(RandomMount_NONFLYABLEAREA, nil, nil, nil, 1);
		end
		
		GameTooltip:AddLine("|c333399ff"..RandomMount_LEFTMOUSE..":|r "..RandomMount_CALLMOUNT, nil, nil, nil, 1);
		GameTooltip:AddLine("|c333399ff"..RandomMount_RIGHTMOUSE..":|r "..RandomMount_SENDMOUNTAWAY, nil, nil, nil, 1);
		GameTooltip:AddLine("|c333399ff[alt] + "..RandomMount_LEFTMOUSE..":|r "..RandomMount_CALLNONFLYING, nil, nil, nil, 1);
		GameTooltip:AddLine("|c333399ff[ctrl] + "..RandomMount_LEFTMOUSE..":|r "..RandomMount_INITMOUNTS, nil, nil, nil, 1);
			
		GameTooltip:Show();
		
	end
end
