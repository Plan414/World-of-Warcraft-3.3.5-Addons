--[[
	This file contains compatibility code for all relevant addon included with comsos:
		- AllInOneInventory
		- BarOptions
		- PopBar
	
--]]

CooldownCountAllInOneInventory_Saved_GenerateButtonUpdateList = nil;
CooldownCountAllInOneInventory_BarName = "AllInOneInventoryFrameItem";
CooldownCountAllInOneInventory_NumberOfButtons = 109;
CooldownCountAllInOneInventory_NormalBar = 0;
CooldownCountAllInOneInventory_ButtonUpdateList = {};

function CooldownCountAllInOneInventory_OnLoad()
	if ( CooldownCountAllInOneInventory_NormalBar == 1 ) then
		if ( getglobal(CooldownCountAllInOneInventory_BarName.."1") ) then
			table.insert(CooldownCount_ButtonNames, CooldownCountAllInOneInventory_BarName);
		end
	else
		CooldownCountAllInOneInventory_GenerateList();
		if ( not CooldownCountAllInOneInventory_Saved_GenerateButtonUpdateList ) then
			CooldownCountAllInOneInventory_Saved_GenerateButtonUpdateList = CooldownCount_GenerateButtonUpdateList;
			CooldownCount_GenerateButtonUpdateList = CooldownCountAllInOneInventory_GenerateButtonUpdateList;
		end
	end
	CooldownCount_RegenerateList();
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function CooldownCountAllInOneInventory_GenerateList()
	local barName = CooldownCountAllInOneInventory_BarName;
	for i = 1, CooldownCountAllInOneInventory_NumberOfButtons do
		name = barName..i;
		if ( getglobal(name) ) then
			table.insert(CooldownCountAllInOneInventory_ButtonUpdateList, name);
		end
	end
end

function CooldownCountAllInOneInventory_DoUpdate(force)
	if ( not CooldownCountAllInOneInventory_ButtonUpdateList ) then
		CooldownCount_DoUpdate(force);
	else
		for k, v in pairs( CooldownCountAllInOneInventory_ButtonUpdateList ) do
			CooldownCount_DoUpdateCooldownCount(v, force);
		end
	end
end

function CooldownCountAllInOneInventory_OnEvent()
	if ( event == "BAG_UPDATE_COOLDOWN" ) then
		CooldownCountAllInOneInventory_DoUpdate();
		return;
	end
end


function CooldownCountAllInOneInventory_GenerateButtonUpdateList()
	local updateList = CooldownCountAllInOneInventory_Saved_GenerateButtonUpdateList();
	for k, v in pairs( CooldownCountAllInOneInventory_ButtonUpdateList ) do
		table.insert(updateList, v);
	end
	return updateList;
end

CooldownCountBarOptions_Saved_GenerateButtonUpdateList = nil;
CooldownCountBarOptions_BarName = "BOBonusActionButton";
CooldownCountBarOptions_ButtonNameFormat = "BOBonusActionButton%d";
CooldownCountBarOptions_NumberOfButtons = 12;
CooldownCountBarOptions_NormalBar = 1;

function CooldownCountBarOptions_OnLoad()
	if ( CooldownCountBarOptions_NormalBar == 1 ) then
		table.insert(CooldownCount_ButtonNames, CooldownCountBarOptions_BarName);
	else
		if ( not CooldownCountBarOptions_Saved_GenerateButtonUpdateList ) then
			CooldownCountBarOptions_Saved_GenerateButtonUpdateList = CooldownCount_GenerateButtonUpdateList;
			CooldownCount_GenerateButtonUpdateList = CooldownCountBarOptions_GenerateButtonUpdateList;
		end
	end
	CooldownCount_RegenerateList();
end


function CooldownCountBarOptions_GenerateButtonUpdateList()
	local updateList = CooldownCountBarOptions_Saved_GenerateButtonUpdateList();
	for i = 1, CooldownCountBarOptions_NumberOfButtons do
		name = format(CooldownCountBarOptions_ButtonNameFormat, i);
		if ( getglobal(name) ) then
			table.insert(updateList, name);
		end
	end
	return updateList;
end

CooldownCountPopBar_Saved_GenerateButtonUpdateList = nil;
CooldownCountPopBar_BarName = "PopBarButton";
CooldownCountPopBar_ButtonNameFormat = "PopBarButton%d%02d";
CooldownCountPopBar_NumberOfButtons = 12;
CooldownCountPopBar_NumberOfBars = 12;
CooldownCountPopBar_NormalBar = 0;

function CooldownCountPopBar_OnLoad()
	if ( CooldownCountPopBar_NormalBar == 1 ) then
		table.insert(CooldownCount_ButtonNames, CooldownCountPopBar_BarName);
	else
		if ( not CooldownCountPopBar_Saved_GenerateButtonUpdateList ) then
			CooldownCountPopBar_Saved_GenerateButtonUpdateList = CooldownCount_GenerateButtonUpdateList;
			CooldownCount_GenerateButtonUpdateList = CooldownCountPopBar_GenerateButtonUpdateList;
		end
	end
	CooldownCount_RegenerateList();
end


function CooldownCountPopBar_GenerateButtonUpdateList()
	local updateList = CooldownCountPopBar_Saved_GenerateButtonUpdateList();
	for bar = 1, CooldownCountPopBar_NumberOfBars do
		for i = 1, CooldownCountPopBar_NumberOfButtons do
			name = format(CooldownCountPopBar_ButtonNameFormat, bar, i);
			if ( getglobal(name) ) then
				table.insert(updateList, name);
			end
		end
	end
	return updateList;
end
