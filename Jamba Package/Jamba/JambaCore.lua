--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--

-- The global private table for Jamba.
JambaPrivate = {}
JambaPrivate.Core = {}
JambaPrivate.Communications = {}
JambaPrivate.Message = {}
JambaPrivate.Team = {}
JambaPrivate.Tag = {}

-- The global public API table for Jamba.
JambaApi = {}

local AJM = LibStub( "AceAddon-3.0" ):NewAddon( 
	"JambaCore", 
	"AceConsole-3.0" 
)

-- JambaCore is not a module, but the same naming convention for these values is convenient.
AJM.moduleName = "Jamba-Core"
local L = LibStub( "AceLocale-3.0" ):GetLocale( AJM.moduleName )
AJM.moduleDisplayName = L["Jamba"]
AJM.settingsDatabaseName = "JambaCoreProfileDB"
AJM.parentDisplayName = "Jamba"
AJM.chatCommand = "jamba"
AJM.teamModuleName = "Jamba-Team"

-- Load libraries.
local JambaUtilities = LibStub:GetLibrary( "JambaUtilities-1.0" )
local JambaHelperSettings = LibStub:GetLibrary( "JambaHelperSettings-1.0" )
local AceGUI = LibStub("AceGUI-3.0")

-- Create frame for Jamba Settings.
JambaPrivate.SettingsFrame = {}
JambaPrivate.SettingsFrame.Widget = AceGUI:Create( "JambaWindow" )
JambaPrivate.SettingsFrame.Widget:SetTitle( L["Jamba"].." "..GetAddOnMetadata("Jamba", "version").." - "..L["Jafula's Awesome Multi-Boxer Assistant"] )
JambaPrivate.SettingsFrame.Widget:SetLayout( "Fill" )
JambaPrivate.SettingsFrame.WidgetTree = AceGUI:Create( "JambaTreeGroup" )
JambaPrivate.SettingsFrame.TreeGroupStatus = { treesizable = false, groups = {} }
JambaPrivate.SettingsFrame.WidgetTree:SetStatusTable( JambaPrivate.SettingsFrame.TreeGroupStatus )
JambaPrivate.SettingsFrame.WidgetTree:EnableButtonTooltips( false )
JambaPrivate.SettingsFrame.Widget:AddChild( JambaPrivate.SettingsFrame.WidgetTree )
JambaPrivate.SettingsFrame.WidgetTree:SetLayout( "Fill" )

local function JambaSettingsTreeSort( a, b )
	local aText = ""
	local bText = ""
	local aJambaOrder = 0
	local bJambaOrder = 0
	if a ~= nil then
		aText = a.text
		aJambaOrder = a.jambaOrder
	end	
	if b ~= nil then
		bText = b.text
		bJambaOrder = b.jambaOrder
	end
	if aText == L["Jamba"] or bText == L["Jamba"] then
		if aText == L["Jamba"] then
			return true
		end
		if bText == L["Jamba"] then
			return false
		end
	end
	if aJambaOrder == bJambaOrder then
		return aText < bText
	end
	return aJambaOrder < bJambaOrder
end

local function JambaTreeGroupTreeGetParent( parentName )
	local parent = nil
	for index, tableInfo in ipairs( JambaPrivate.SettingsFrame.Tree.Data ) do
		if tableInfo.value == parentName then
			parent = tableInfo			
		end
	end
	return parent
end

local function GetTreeGroupParentJambaOrder( parentName )
	local order = 1000
	if parentName == L["Team"] then
		order = 10
	end
	if parentName == L["Quest"] then
		order = 20
	end
	if parentName == L["Merchant"] then
		order = 30
	end
	if parentName == L["Interaction"] then
		order = 40
	end
	if parentName == L["Combat"] then
		order = 50
	end
	if parentName == L["Toon"] then
		order = 60
	end
	if parentName == L["Chat"] then
		order = 70
	end
	if parentName == L["Macro"] then
		order = 80
	end
	if parentName == L["Profiles"] then
		order = 90
	end
	if parentName == L["Advanced"] then
		order = 100
	end
	return order
end

local function GetTreeGroupParentIcon( parentName )
	local icon = "Interface\\Icons\\Temp"
	if parentName == L["Team"] then
		icon = "Interface\\Icons\\INV_Misc_FireDancer_01"
	end
	if parentName == L["Quest"] then
		icon = "Interface\\Icons\\Achievement_Quests_Completed_08"
	end
	if parentName == L["Merchant"] then
		icon = "Interface\\Icons\\INV_Drink_05"
	end
	if parentName == L["Interaction"] then
		icon = "Interface\\Icons\\Achievement_Reputation_01"
	end
	if parentName == L["Combat"] then
		icon = "Interface\\Icons\\INV_Sword_11"
	end
	if parentName == L["Toon"] then
		icon = "Interface\\Icons\\Achievement_Character_Bloodelf_Female"
	end
	if parentName == L["Chat"] then
		icon = "Interface\\Icons\\Ability_Warrior_RallyingCry"
	end
	if parentName == L["Macro"] then
		icon = "Interface\\Icons\\Spell_Holy_Dizzy"
	end
	if parentName == L["Profiles"] then
		icon = "Interface\\Icons\\INV_Misc_Dice_01"
	end
	if parentName == L["Advanced"] then
		icon = "Interface\\Icons\\Trade_Engineering"
	end
	return icon
end

local function JambaAddModuleToSettings( childName, parentName, moduleFrame, tabGroup )
	local parent = JambaTreeGroupTreeGetParent( parentName )
	if parent == nil then
		local order = GetTreeGroupParentJambaOrder( parentName )
		table.insert( JambaPrivate.SettingsFrame.Tree.Data, { value = parentName, text = parentName, jambaOrder = order, icon = GetTreeGroupParentIcon( parentName ) } )
		parent = JambaTreeGroupTreeGetParent( parentName )
	end
	if parent.children == nil then
		parent.children = {}
	end	
	table.insert( parent.children, { value = childName, text = childName } )
	table.sort( JambaPrivate.SettingsFrame.Tree.Data, JambaSettingsTreeSort )
	JambaPrivate.SettingsFrame.Tree.ModuleFrames[childName] = moduleFrame
	JambaPrivate.SettingsFrame.Tree.ModuleFramesTabGroup[childName] = tabGroup
end

local function JambaModuleSelected( tree, event, treeValue, selected )
	local parentValue, value = strsplit( "\001", treeValue )
	if tree == nil and event == nil then
		-- Came from chat command.
		value = treeValue
	end
	JambaPrivate.SettingsFrame.Widget:Show()
	if JambaPrivate.SettingsFrame.Tree.CurrentChild ~= nil then
		JambaPrivate.SettingsFrame.Tree.CurrentChild.frame:Hide()
		JambaPrivate.SettingsFrame.Tree.CurrentChild = nil
	end
	for moduleValue, moduleFrame in pairs( JambaPrivate.SettingsFrame.Tree.ModuleFrames ) do
		if moduleValue == value then
			moduleFrame:SetParent( JambaPrivate.SettingsFrame.WidgetTree )
			moduleFrame:SetWidth( JambaPrivate.SettingsFrame.WidgetTree.content:GetWidth() or 0 )
			moduleFrame:SetHeight( JambaPrivate.SettingsFrame.WidgetTree.content:GetHeight() or 0 )
			moduleFrame.frame:SetAllPoints( JambaPrivate.SettingsFrame.WidgetTree.content )
			moduleFrame.frame:Show()	
			JambaPrivate.SettingsFrame.Tree.CurrentChild = moduleFrame
			-- Hacky hack hack.
			if JambaPrivate.SettingsFrame.Tree.ModuleFramesTabGroup[value] ~= nil then
				JambaPrivate.SettingsFrame.Tree.ModuleFramesTabGroup[value]:SelectTab( "options" )
			else
				-- Hacky hack hack.
				LibStub( "AceConfigDialog-3.0" ):Open( AJM.moduleName.."-Profiles", moduleFrame )
			end
			return
		end
	end
end

JambaPrivate.SettingsFrame.Tree = {}
JambaPrivate.SettingsFrame.Tree.Data = {}
JambaPrivate.SettingsFrame.Tree.ModuleFrames = {}
JambaPrivate.SettingsFrame.Tree.ModuleFramesTabGroup = {}
JambaPrivate.SettingsFrame.Tree.CurrentChild = nil
JambaPrivate.SettingsFrame.Tree.Add = JambaAddModuleToSettings
JambaPrivate.SettingsFrame.Tree.ButtonClick = JambaModuleSelected
JambaPrivate.SettingsFrame.WidgetTree:SetTree( JambaPrivate.SettingsFrame.Tree.Data )
JambaPrivate.SettingsFrame.WidgetTree:SetCallback( "OnClick", JambaPrivate.SettingsFrame.Tree.ButtonClick )
JambaPrivate.SettingsFrame.Widget:Hide()
table.insert( UISpecialFrames, "JambaSettingsWindowsFrame" )

-- Settings - the values to store and their defaults for the settings database.
AJM.settings = {
	profile = {
		showMinimapIcon = true,
	},
}

-- Configuration.
local function GetConfiguration()
	local configuration = {
		name = "Jamba",
		handler = AJM,
		type = 'group',
		childGroups  = "tab",
		get = "ConfigurationGetSetting",
		set = "ConfigurationSetSetting",
		args = {	
			push = {
				type = "input",
				name = L["Push Settings"],
				desc = L["Push Settings"],
				usage = "/jamba push",
				get = false,
				set = "SendSettingsAllModules",
				order = 4,
				guiHidden = true,
			},
		},
	}
	return configuration
end

-- Get a settings value.
function AJM:ConfigurationGetSetting( key )
	return AJM.db[key[#key]]
end

-- Set a settings value.
function AJM:ConfigurationSetSetting( key, value )
	AJM.db[key[#key]] = value
end

local function DebugMessage( ... )
	AJM:Print( ... )
end

-------------------------------------------------------------------------------------------------------------
-- Module management.
-------------------------------------------------------------------------------------------------------------

-- Register a Jamba module.
local function RegisterModule( moduleAddress, moduleName )
	if AJM.registeredModulesByName == nil then
		AJM.registeredModulesByName = {}
	end
	if AJM.registeredModulesByAddress == nil then
		AJM.registeredModulesByAddress = {}
	end
	AJM.registeredModulesByName[moduleName] = moduleAddress
	AJM.registeredModulesByAddress[moduleAddress] = moduleName
end

-------------------------------------------------------------------------------------------------------------
-- Settings sending and receiving.
-------------------------------------------------------------------------------------------------------------

-- Send the settings for the module specified (using its address) to other Jamba Team characters.
local function SendSettings( moduleAddress, settings )
	-- Get the name of the module.
	local moduleName = AJM.registeredModulesByAddress[moduleAddress]
	-- Send the settings identified by the module name.
	JambaPrivate.Communications.SendSettings( moduleName, settings )
end

-- Settings are received, pass them to the relevant module.
local function OnSettingsReceived( sender, moduleName, settings )
	-- Get the address of the module.
	local moduleAddress = AJM.registeredModulesByName[moduleName]	
	-- Pass the module its settings.
	moduleAddress:JambaOnSettingsReceived( sender, settings )
end

function AJM:SendSettingsAllModules()
	AJM:Print( "Sending settings for all modules." )
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		AJM:Print( "Sending settings for: ", moduleName )
		moduleAddress:JambaSendSettings()
	end
end

-------------------------------------------------------------------------------------------------------------
-- Commands sending and receiving.
-------------------------------------------------------------------------------------------------------------

-- Send a command for the module specified (using its address) to other Jamba Team characters.
local function SendCommandToTeam( moduleAddress, commandName, ... )
	-- Get the name of the module.
	local moduleName = AJM.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	JambaPrivate.Communications.SendCommandAll( moduleName, commandName, ... )
end

-- Send a command for the module specified (using its address) to the master character.
local function SendCommandToMaster( moduleAddress, commandName, ... )
	-- Get the name of the module.
	local moduleName = AJM.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	JambaPrivate.Communications.SendCommandMaster( moduleName, commandName, ... )
end

local function SendCommandToToon( moduleAddress, characterName, commandName, ... )
	-- Get the name of the module.
	local moduleName = AJM.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	JambaPrivate.Communications.SendCommandToon( moduleName, characterName, commandName, ... )
end

-- A command is received, pass it to the relevant module.
local function OnCommandReceived( sender, moduleName, commandName, ... )
	-- Get the address of the module.
	local moduleAddress = AJM.registeredModulesByName[moduleName]
	-- Pass the module its settings.
	moduleAddress:JambaOnCommandReceived( sender, commandName, ... )
end

-------------------------------------------------------------------------------------------------------------
-- Jamba Core Profile Support.
-------------------------------------------------------------------------------------------------------------

function AJM:FireBeforeProfileChangedEvent()
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		if moduleName ~= AJM.moduleName then		
			moduleAddress:BeforeJambaProfileChanged()
		end
	end
end

function AJM:CanChangeProfileForModule( moduleName )
	if (moduleName ~= AJM.moduleName) and (moduleName ~= AJM.teamModuleName) then		
		return true
	end
	return false
end

function AJM:FireOnProfileChangedEvent( moduleAddress )
	moduleAddress.db = moduleAddress.completeDatabase.profile
	moduleAddress:OnJambaProfileChanged()
end

function AJM:OnProfileChanged( event, database, newProfileKey, ... )
	AJM:Print( "Profile changed - iterating all modules." )
	AJM:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = AJM.registeredModulesByName[AJM.teamModuleName]
	AJM:Print( "Changing profile: ", AJM.teamModuleName )
	teamModuleAddress.completeDatabase:SetProfile( newProfileKey )
	AJM:FireOnProfileChangedEvent( teamModuleAddress )
	-- Do the other modules.
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		if AJM:CanChangeProfileForModule( moduleName ) == true then		
			AJM:Print( "Changing profile: ", moduleName )
			moduleAddress.completeDatabase:SetProfile( newProfileKey )
			AJM:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function AJM:OnProfileCopied( event, database, sourceProfileKey )
	AJM:Print( "Profile copied - iterating all modules." )
	AJM:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = AJM.registeredModulesByName[AJM.teamModuleName]
	AJM:Print( "Copying profile: ", AJM.teamModuleName )
	teamModuleAddress.completeDatabase:CopyProfile( sourceProfileKey, true )
	AJM:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		if AJM:CanChangeProfileForModule( moduleName ) == true then		
			AJM:Print( "Copying profile: ", moduleName )
			moduleAddress.completeDatabase:CopyProfile( sourceProfileKey, true )
			AJM:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function AJM:OnProfileReset( event, database )
	AJM:Print( "Profile reset - iterating all modules." )
	AJM:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = AJM.registeredModulesByName[AJM.teamModuleName]
	AJM:Print( "Resetting profile: ", AJM.teamModuleName )
	teamModuleAddress.completeDatabase:ResetProfile()
	AJM:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.	
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		if AJM:CanChangeProfileForModule( moduleName ) == true then		
			AJM:Print( "Resetting profile: ", moduleName )
			moduleAddress.completeDatabase:ResetProfile()
			AJM:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function AJM:OnProfileDeleted( event, database, profileKey )
	AJM:Print( "Profile deleted - iterating all modules." )
	AJM:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = AJM.registeredModulesByName[AJM.teamModuleName]
	AJM:Print( "Deleting profile: ", AJM.teamModuleName )
	teamModuleAddress.completeDatabase:DeleteProfile( profileKey, true )
	AJM:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.		
	for moduleName, moduleAddress in pairs( AJM.registeredModulesByName ) do
		if AJM:CanChangeProfileForModule( moduleName ) == true then		
			AJM:Print( "Deleting profile: ", moduleName )
			moduleAddress.completeDatabase:DeleteProfile( profileKey, true )
			AJM:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

-------------------------------------------------------------------------------------------------------------
-- Jamba Core Initialization.
-------------------------------------------------------------------------------------------------------------

-- Initialize the addon.
function AJM:OnInitialize()
	-- Tables to hold registered modules - lookups by name and by address.  
	-- By name is used for communication between clients and by address for communication between addons on the same client.
	AJM.registeredModulesByName = {}
	AJM.registeredModulesByAddress = {}
	-- Create the settings database supplying the settings values along with defaults.
    AJM.completeDatabase = LibStub( "AceDB-3.0" ):New( AJM.settingsDatabaseName, AJM.settings )
	AJM.completeDatabase.RegisterCallback( AJM, "OnProfileChanged", "OnProfileChanged" )
	AJM.completeDatabase.RegisterCallback( AJM, "OnProfileCopied", "OnProfileCopied" )
	AJM.completeDatabase.RegisterCallback( AJM, "OnProfileReset", "OnProfileReset" )	
	AJM.completeDatabase.RegisterCallback( AJM, "OnProfileDeleted", "OnProfileDeleted" )	
	AJM.db = AJM.completeDatabase.profile
	-- Create the settings.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( 
		AJM.moduleName, 
		GetConfiguration() 
	)
	-- Create the settings frame.
	AJM:CoreSettingsCreate()
	AJM.settingsFrame = AJM.settingsControl.widgetSettings.frame
	-- Blizzard options frame.
	local frame = CreateFrame( "Frame" )
	frame.name = L["Jamba"]
	local button = CreateFrame( "Button", nil, frame, "OptionsButtonTemplate" )
	button:SetPoint( "CENTER" )
	button:SetText( "/jamba" )
	button:SetScript( "OnClick", AJM.LoadJambaSettings )
	InterfaceOptions_AddCategory( frame )
	-- Create the settings profile support.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( 
		AJM.moduleName.."-Profiles",
		LibStub( "AceDBOptions-3.0" ):GetOptionsTable( AJM.completeDatabase ) 
	)
	local profileContainerWidget = AceGUI:Create( "SimpleGroup" )
	profileContainerWidget:SetLayout( "Fill" )
	JambaPrivate.SettingsFrame.Tree.Add( L["Core"]..L[": Profiles"], L["Profiles"], profileContainerWidget, nil )
	-- Register the core as a module.
	RegisterModule( AJM, AJM.moduleName )
	-- Register the chat command.
	AJM:RegisterChatCommand( AJM.chatCommand, "JambaChatCommand" )	
end

function AJM:OnEnable()
end

function AJM:OnDisable()
end

function AJM:CoreSettingsCreateInfo( top )
	-- Get positions and dimensions.
	local buttonPushAllSettingsWidth = 300
	local buttonHeight = JambaHelperSettings:GetButtonHeight()
	local checkBoxHeight = JambaHelperSettings:GetCheckBoxHeight()
	local radioBoxHeight = JambaHelperSettings:GetRadioBoxHeight()
	local labelHeight = JambaHelperSettings:GetLabelHeight()
	local labelContinueHeight = JambaHelperSettings:GetContinueLabelHeight()
	local left = JambaHelperSettings:LeftOfSettings()
	local headingHeight = JambaHelperSettings:HeadingHeight()
	local headingWidth = JambaHelperSettings:HeadingWidth( false )
	local horizontalSpacing = JambaHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = JambaHelperSettings:GetVerticalSpacing()
	local indent = horizontalSpacing * 10
	local indentContinueLabel = horizontalSpacing * 18
	local indentSpecial = indentContinueLabel + 9
	local checkBoxThirdWidth = (headingWidth - indentContinueLabel) / 3
	local column1Left = left
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top

	JambaHelperSettings:CreateHeading( AJM.settingsControl, L["Jafula's Awesome Multi-Boxer Assistant"], movingTop, false )
	movingTop = movingTop - headingHeight
	
	AJM.settingsControl.labelInformation1 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Copyright 2008-2010 Michael 'Jafula' Miller"] 
	)	
	movingTop = movingTop - labelContinueHeight
	
	AJM.settingsControl.labelInformation2 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Made in New Zealand"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation3 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		""
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation4 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["For user manuals and documentation please visit:"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation5 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		""
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation6 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["http://wow.jafula.com/addons/jamba/"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation7 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		""
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation8 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Other useful websites:"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation9 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		""
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation10 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["http://dual-boxing.com/"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation11 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["http://multiboxing.com/"]
	)	
	movingTop = movingTop - labelContinueHeight

	AJM.settingsControl.labelInformation12 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		""
	)	
	movingTop = movingTop - labelContinueHeight
	
	AJM.settingsControl.labelInformation11 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Special thanks to olipcs on dual-boxing.com for writing the FTL Helper module."]
	)	
	movingTop = movingTop - labelContinueHeight
	
	-- Extra space.
	movingTop = movingTop - labelContinueHeight
	
	AJM.settingsControl.buttonPushSettingsForAllModules = JambaHelperSettings:CreateButton(	
		AJM.settingsControl, 
		buttonPushAllSettingsWidth, 
		column1Left, 
		movingTop, 
		L["Push Settings For All The Modules"],
		AJM.SendSettingsAllModules
	)
	movingTop = movingTop - buttonHeight
	
	return movingTop	
end

function AJM:CoreSettingsCreate()
	AJM.settingsControl = {}
	-- Create the settings panel.
	JambaHelperSettings:CreateSettings( 
		AJM.settingsControl, 
		AJM.moduleDisplayName, 
		AJM.parentDisplayName, 
		AJM.SendSettingsAllModules 
	)
	local bottomOfInfo = AJM:CoreSettingsCreateInfo( JambaHelperSettings:TopOfSettings() )
	AJM.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
end

-- Send core settings.
function AJM:JambaSendSettings()
	JambaPrivate.Communications.SendSettings( AJM.moduleName, AJM.db )
end

function AJM:OnJambaProfileChanged()	
	AJM:SettingsRefresh()
end

function AJM:SettingsRefresh()
end

-- Core settings received.
function AJM:JambaOnSettingsReceived( characterName, settings )
	if characterName ~= AJM.characterName then
		-- Update the settings.
		AJM.db.showMinimapIcon = settings.showMinimapIcon
		-- Refresh the settings.
		AJM:SettingsRefresh()
		-- Tell the player.
		AJM:Print( L["Settings received from A."]( characterName ) )
	end
end

function AJM:LoadJambaSettings()
	InterfaceOptionsFrameCancel_OnClick()
	HideUIPanel( GameMenuFrame )
	AJM:JambaChatCommand( "" )
end

-- Handle the chat command.
function AJM:JambaChatCommand( input )
    if not input or input:trim() == "" then
		JambaPrivate.SettingsFrame.Widget:Show()
		JambaPrivate.SettingsFrame.WidgetTree:SelectByValue( AJM.moduleDisplayName )
		JambaPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, AJM.moduleDisplayName, false)
    else
        LibStub( "AceConfigCmd-3.0" ):HandleCommand( AJM.chatCommand, AJM.moduleName, input )
    end    
end

-- Functions available from Jamba Core for other Jamba internal objects.
JambaPrivate.Core.RegisterModule = RegisterModule
JambaPrivate.Core.SendSettings = SendSettings
JambaPrivate.Core.OnSettingsReceived = OnSettingsReceived
JambaPrivate.Core.SendCommandToTeam = SendCommandToTeam
JambaPrivate.Core.SendCommandToMaster = SendCommandToMaster
JambaPrivate.Core.SendCommandToToon = SendCommandToToon
--JambaPrivate.Core.SendCommandToSlaves = SendCommandToSlaves
JambaPrivate.Core.OnCommandReceived = OnCommandReceived
