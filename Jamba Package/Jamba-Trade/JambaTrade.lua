--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--

-- Create the addon using AceAddon-3.0 and embed some libraries.
local AJM = LibStub( "AceAddon-3.0" ):NewAddon( 
	"JambaTrade", 
	"JambaModule-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the Jamba Utilities Library.
local JambaUtilities = LibStub:GetLibrary( "JambaUtilities-1.0" )
local JambaHelperSettings = LibStub:GetLibrary( "JambaHelperSettings-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
local LibGratuity = LibStub( "LibGratuity-3.0" )
local AceGUI = LibStub( "AceGUI-3.0" )

--  Constants and Locale for this module.
AJM.moduleName = "Jamba-Trade"
AJM.settingsDatabaseName = "JambaTradeProfileDB"
AJM.chatCommand = "jamba-trade"
local L = LibStub( "AceLocale-3.0" ):GetLocale( AJM.moduleName )
AJM.parentDisplayName = L["Interaction"]
AJM.moduleDisplayName = L["Trade"]

AJM.inventorySeperator = "\008"
AJM.inventoryPartSeperator = "\009"

-- Settings - the values to store and their defaults for the settings database.
AJM.settings = {
	profile = {
		messageArea = JambaApi.DefaultMessageArea(),
		framePoint = "CENTER",
		frameRelativePoint = "CENTER",
		frameXOffset = 0,
		frameYOffset = 0,
		showJambaTradeWindow = true,
		adjustMoneyWithGuildBank = false,
		goldAmountToKeepOnToon = 200,
		ignoreSoulBound = false
	},
}

-- Configuration.
function AJM:GetConfiguration()
	local configuration = {
		name = AJM.moduleDisplayName,
		handler = AJM,
		type = 'group',
		childGroups  = "tab",
		get = "JambaConfigurationGetSetting",
		set = "JambaConfigurationSetSetting",
		args = {
			loadname = {
				type = "input",
				name = L["Load Item By Name"],
				desc = L["Load a certain amount of an item by name into the trade window."],
				usage = "/jamba-trade loadname <item-name>,<amount>",
				get = false,
				set = "JambaTradeLoadNameCommand",
				guiHidden = true,
			},				
			loadtype = {
				type = "input",
				name = L["Load Items By Type"],
				desc = L["Load items by type into the trade window."],
				usage = "/jamba-trade loadtype <class>,<subclass>",
				get = false,
				set = "JambaTradeLoadTypeCommand",
				guiHidden = true,
			},		
			push = {
				type = "input",
				name = L["Push Settings"],
				desc = L["Push the trade settings to all characters in the team."],
				usage = "/jamba-trade push",
				get = false,
				set = "JambaSendSettings",
				guiHidden = true,
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

AJM.COMMAND_SHOW_INVENTORY = "ShowInventory"
AJM.COMMAND_HERE_IS_MY_INVENTORY = "HereIsMyInventory"
AJM.COMMAND_LOAD_ITEM_INTO_TRADE = "LoadItemIntoTrade"
AJM.COMMAND_LOAD_ITEM_CLASS_INTO_TRADE = "LoadItemClassIntoTrade"
AJM.COMMAND_GET_SLOT_COUNT = "GetSlotCount"
AJM.COMMAND_HERE_IS_MY_SLOT_COUNT = "HereIsMySlotCount"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function AJM:OnInitialize()
	AJM.inventory = ""
	AJM.inventoryInDisplayTable = {}
	AJM.inventorySortedTable = {}
	AJM.itemClassList = {}
	AJM.itemClassSubList = {}
	AJM.itemClassSubListLastSelection = {}
	AJM.itemClassCurrentSelection = ""
	AJM.itemSubClassCurrentSelection = ""
	-- Create the settings control.
	AJM:SettingsCreate()
	-- Initialse the JambaModule part of this module.
	AJM:JambaModuleInitialize( AJM.settingsControl.widgetSettings.frame )
	AJM:CreateInventoryFrame()	
	-- Populate the settings.
	AJM:SettingsRefresh()	
end

-- Called when the addon is enabled.
function AJM:OnEnable()
	AJM:RegisterEvent( "TRADE_SHOW" )
	AJM:RegisterEvent( "TRADE_CLOSED" )
	AJM:RegisterEvent( "GUILDBANKFRAME_OPENED" )
end

-- Called when the addon is disabled.
function AJM:OnDisable()
	-- AceHook-3.0 will tidy up the hooks for us. 
end

function AJM:SettingsCreate()
	AJM.settingsControl = {}
	-- Create the settings panel.
	JambaHelperSettings:CreateSettings( 
		AJM.settingsControl, 
		AJM.moduleDisplayName, 
		AJM.parentDisplayName, 
		AJM.SettingsPushSettingsClick 
	)
	local bottomOfInfo = AJM:SettingsCreateTrade( JambaHelperSettings:TopOfSettings() )
	AJM.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	JambaHelperSettings:CreateHelp( AJM.settingsControl, helpTable, AJM:GetConfiguration() )		
end

function AJM:SettingsPushSettingsClick( event )
	AJM:JambaSendSettings()
end

function AJM:SettingsCreateTrade( top )
	local checkBoxHeight = JambaHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = JambaHelperSettings:GetEditBoxHeight()
	local left = JambaHelperSettings:LeftOfSettings()
	local headingHeight = JambaHelperSettings:HeadingHeight()
	local headingWidth = JambaHelperSettings:HeadingWidth( false )
	local dropdownHeight = JambaHelperSettings:GetDropdownHeight()
	local verticalSpacing = JambaHelperSettings:GetVerticalSpacing()
	local movingTop = top
	JambaHelperSettings:CreateHeading( AJM.settingsControl, L["Trade Options"], movingTop, false )
	movingTop = movingTop - headingHeight
	AJM.settingsControl.checkBoxShowJambaTradeWindow = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["Show Jamba Trade Window On Trade"],
		AJM.SettingsToggleShowJambaTradeWindow
	)	
	movingTop = movingTop - checkBoxHeight
	AJM.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["Adjust Toon Money While Visiting The Guild Bank"],
		AJM.SettingsToggleAdjustMoneyOnToonViaGuildBank
	)	
	movingTop = movingTop - checkBoxHeight
	AJM.settingsControl.editBoxGoldAmountToLeaveOnToon = JambaHelperSettings:CreateEditBox( AJM.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["Amount of Gold"]
	)	
	AJM.settingsControl.editBoxGoldAmountToLeaveOnToon:SetCallback( "OnEnterPressed", AJM.EditBoxChangedGoldAmountToLeaveOnToon  )
	movingTop = movingTop - editBoxHeight	
	AJM.settingsControl.dropdownMessageArea = JambaHelperSettings:CreateDropdown( 
		AJM.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["Message Area"] 
	)
	AJM.settingsControl.dropdownMessageArea:SetList( JambaApi.MessageAreaList() )
	AJM.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", AJM.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing
	return movingTop	
end

function AJM:SettingsSetMessageArea( event, value )
	AJM.db.messageArea = value
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleShowJambaTradeWindow( event, checked )
	AJM.db.showJambaTradeWindow = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAdjustMoneyOnToonViaGuildBank( event, checked )
	AJM.db.adjustMoneyWithGuildBank = checked
	AJM:SettingsRefresh()
end

function AJM:EditBoxChangedGoldAmountToLeaveOnToon( event, text )
	AJM.db.goldAmountToKeepOnToon = tonumber( text )
	if AJM.db.goldAmountToKeepOnToon == nil then
		AJM.db.goldAmountToKeepOnToon = 0
	end
	AJM:SettingsRefresh()
end

-- Settings received.
function AJM:JambaOnSettingsReceived( characterName, settings )	
	if characterName ~= AJM.characterName then
		-- Update the settings.
		AJM.db.messageArea = settings.messageArea
		AJM.db.framePoint = settings.framePoint
		AJM.db.frameRelativePoint = settings.frameRelativePoint
		AJM.db.frameXOffset = settings.frameXOffset
		AJM.db.frameYOffset = settings.frameYOffset
		AJM.db.showJambaTradeWindow = settings.showJambaTradeWindow
		AJM.db.adjustMoneyWithGuildBank = settings.adjustMoneyWithGuildBank
		AJM.db.goldAmountToKeepOnToon = settings.goldAmountToKeepOnToon  
		-- Refresh the settings.
		AJM:SettingsRefresh()
		-- Tell the player.
		AJM:Print( L["Settings received from A."]( characterName ) )
	end
end

function AJM:BeforeJambaProfileChanged()	
end

function AJM:OnJambaProfileChanged()	
	AJM:SettingsRefresh()
end

function AJM:SettingsRefresh()
	AJM.settingsControl.checkBoxShowJambaTradeWindow:SetValue( AJM.db.showJambaTradeWindow )
	AJM.settingsControl.dropdownMessageArea:SetValue( AJM.db.messageArea )
	AJM.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank:SetValue( AJM.db.adjustMoneyWithGuildBank )
	AJM.settingsControl.editBoxGoldAmountToLeaveOnToon:SetText( tostring( AJM.db.goldAmountToKeepOnToon ) )
	AJM.settingsControl.editBoxGoldAmountToLeaveOnToon:SetDisabled( not AJM.db.adjustMoneyWithGuildBank )
end

-- A Jamba command has been received.
function AJM:JambaOnCommandReceived( characterName, commandName, ... )
	if characterName == self.characterName then
		return
	end
	if commandName == AJM.COMMAND_SHOW_INVENTORY then
		AJM:SendInventory( characterName )
	end
	if commandName == AJM.COMMAND_HERE_IS_MY_INVENTORY then
		AJM:ShowOtherToonsInventory( characterName, ... )
	end
	if commandName == AJM.COMMAND_LOAD_ITEM_INTO_TRADE then
		AJM:LoadItemIntoTrade( ... )
	end
	if commandName == AJM.COMMAND_LOAD_ITEM_CLASS_INTO_TRADE then
		AJM:LoadItemClassIntoTradeWindow( ... )
	end
	if commandName == AJM.COMMAND_GET_SLOT_COUNT then
		AJM:GetSlotCountAndSendToToon( characterName )
	end
	if commandName == AJM.COMMAND_HERE_IS_MY_SLOT_COUNT then
		AJM:SetOtherToonsSlotCount( characterName, ... )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Trade functionality.
-------------------------------------------------------------------------------------------------------------

function AJM:CreateInventoryFrame()	
	local frame = CreateFrame( "Frame", "JambaTradeInventoryWindowFrame", UIParent )
	frame.parentObject = AJM
	frame:SetFrameStrata( "LOW" )
	frame:SetToplevel( true )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	frame:RegisterForDrag( "LeftButton" )
	frame:SetScript( "OnDragStart", 
		function( this ) 
			--if IsAltKeyDown() == 1 then
				this:StartMoving() 
			--end
		end )
	frame:SetScript( "OnDragStop", 
		function( this ) 
			this:StopMovingOrSizing() 
			point, relativeTo, relativePoint, xOffset, yOffset = this:GetPoint()
			AJM.db.framePoint = point
			AJM.db.frameRelativePoint = relativePoint
			AJM.db.frameXOffset = xOffset
			AJM.db.frameYOffset = yOffset
		end	)	
	frame:ClearAllPoints()
	frame:SetPoint( AJM.db.framePoint, UIParent, AJM.db.frameRelativePoint, AJM.db.frameXOffset, AJM.db.frameYOffset )
	frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = true, tileSize = 10, edgeSize = 20, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )

	frame:SetWidth( 323 )
	frame:SetHeight( 452 )
	
	frame.title = frame:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	frame.title:SetText( "Jamba-Trade" )
	frame.title:SetPoint( "TOPLEFT", frame, "TOPLEFT", 10, -7 )
	frame.title:SetJustifyH( "LEFT" )
	frame.title:SetJustifyV( "TOP" )

	local left, right, top, bottom, width, height
	left = 86
	right = 400
	top = 10
	bottom = 35
	width = right - left
	height = bottom - top

	local header = frame:CreateTexture( nil, "ARTWORK" )
	header:SetTexture( "Interface\\BankFrame\\UI-BankFrame" )
	header:ClearAllPoints()
	header:SetPoint( "TOPLEFT", frame, "TOPLEFT", 7, 0 )
	header:SetWidth( width )
	header:SetHeight( height )
	header:SetTexCoord( left/512, right/512, top/512, bottom/512 )
	frame.header = header

	local closeButton = CreateFrame( "Button", "JambaTradeInventoryWindowFrameButtonClose", frame, "UIPanelCloseButton" )
	closeButton:SetScript( "OnClick", AJM.JambaTradeWindowCloseButtonClicked )
	closeButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 1, 2 )	

	local dropDownClass = AceGUI:Create( "Dropdown" )
	dropDownClass.frame:SetParent( frame )
	dropDownClass:SetLabel( "" )
	dropDownClass:SetPoint( "TOPLEFT", frame, "TOPLEFT", 8, -28 )
	dropDownClass:SetWidth( 130 )
	dropDownClass:SetList( AJM.itemClassList )
	dropDownClass:SetCallback( "OnValueChanged", AJM.JambaTradeClassDropDownChanged )
	frame.dropDownClass = dropDownClass

	local dropDownSubClass = AceGUI:Create( "Dropdown" )
	dropDownSubClass.frame:SetParent( frame )
	dropDownSubClass:SetLabel( "" )
	dropDownSubClass:SetPoint( "TOPLEFT", frame, "TOPLEFT", 142, -28 )
	dropDownSubClass:SetWidth( 170 )
	dropDownSubClass:SetCallback( "OnValueChanged", AJM.JambaTradeSubClassDropDownChanged )
	frame.dropDownSubClass = dropDownSubClass

	local checkBoxIgnoreSoulBound = CreateFrame( "CheckButton", "JambaTradeInventoryWindowFrameCheckButtonIgnoreSoulbound", frame, "ChatConfigCheckButtonTemplate" )
	checkBoxIgnoreSoulBound:SetPoint( "TOPLEFT", frame, "TOPLEFT", 142, -95 )
	checkBoxIgnoreSoulBound:SetHeight( 24 )
	checkBoxIgnoreSoulBound:SetWidth( 24 )
	checkBoxIgnoreSoulBound:SetScript( "OnClick", AJM.JambaTradeIgnoreSoulBoundCheckboxChanged )
	frame.checkBoxIgnoreSoulBound = checkBoxIgnoreSoulBound
	
	local labelIgnoreSoulBound = frame:CreateFontString( nil, "BACKGROUND", "GameFontHighlight" )
	labelIgnoreSoulBound:SetText( L["Ignore Soulbound"] )
	labelIgnoreSoulBound:SetPoint( "TOPLEFT", frame, "TOPLEFT", 167, -100 )
	labelIgnoreSoulBound:SetJustifyH( "LEFT" )
	labelIgnoreSoulBound:SetJustifyV( "TOP" )
	labelIgnoreSoulBound:SetWidth( 150 )
	frame.labelIgnoreSoulBound = labelIgnoreSoulBound
	
	local labelMineBags = frame:CreateFontString( nil, "BACKGROUND", "GameFontHighlight" )
	labelMineBags:SetText( "" )
	labelMineBags:SetPoint( "TOPLEFT", frame, "TOPLEFT", 145, -63 )
	labelMineBags:SetJustifyH( "LEFT" )
	labelMineBags:SetJustifyV( "TOP" )
	labelMineBags:SetWidth( 370 )
	frame.labelMineBags = labelMineBags

	local labelTheirsBags = frame:CreateFontString( nil, "BACKGROUND", "GameFontHighlight" )
	labelTheirsBags:SetText( "")
	labelTheirsBags:SetPoint( "TOPLEFT", frame, "TOPLEFT", 145, -80 )
	labelTheirsBags:SetJustifyH( "LEFT" )
	labelTheirsBags:SetJustifyV( "TOP" )	
	labelTheirsBags:SetWidth( 370 )
	frame.labelTheirsBags = labelTheirsBags
	
	local loadMineButton = CreateFrame( "Button", "JambaTradeInventoryWindowFrameButtonLoadMine", frame, "UIPanelButtonTemplate" )
	loadMineButton:SetScript( "OnClick", AJM.JambaTradeLoadMineButtonClicked )
	loadMineButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 10, -60 )
	loadMineButton:SetHeight( 24 )
	loadMineButton:SetWidth( 100 )
	loadMineButton:SetText( L["Load Mine"] )
	frame.loadMineButton = loadMineButton

	local loadTheirsButton = CreateFrame( "Button", "JambaTradeInventoryWindowFrameButtonLoadTheirs", frame, "UIPanelButtonTemplate" )
	loadTheirsButton:SetScript( "OnClick", AJM.JambaTradeLoadTheirsButtonClicked )
	loadTheirsButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 10, -87 )
	loadTheirsButton:SetHeight( 24 )
	loadTheirsButton:SetWidth( 100 )
	loadTheirsButton:SetText( L["Load Theirs"] )
	frame.loadTheirsButton = loadTheirsButton
	
	local blockNumber = 0
	local cellCounter = 0
	local blockRowSize = 7
	local blockColumnSize = 8
	local cellXOffset = 4
	local cellYOffset = -4
	local cellXSpacing = 4
	local cellYSpacing = 4
	local xOffset = 6
	local yOffset = header:GetHeight() + 93
	local blockXLocation, blockYLocation
	local cellHeight, cellWidth
		
	local tempButton = CreateFrame( "Button", "JambaTradeInventoryWindowFrameButtonTemp", frame, "ItemButtonTemplate" )	
	cellWidth = tempButton:GetWidth()
	cellHeight = tempButton:GetHeight()
	tempButton:Hide()

	AJM.tradeScrollRowHeight = cellHeight + cellYSpacing
	AJM.tradeScrollRowsToDisplay = 1 * blockColumnSize
	AJM.tradeScrollMaximumRows = AJM.tradeScrollRowsToDisplay
	AJM.tradeScrollOffset = 0
	AJM.tradeScrollItemsPerRow = 1 * blockRowSize
	
	frame.tradeScrollFrame = CreateFrame( "ScrollFrame", frame:GetName().."ScrollFrame", frame, "FauxScrollFrameTemplate" )
	frame.tradeScrollFrame:SetPoint( "TOPLEFT", frame, "TOPLEFT", -27, -yOffset )
	frame.tradeScrollFrame:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -27, 5 )
	frame.tradeScrollFrame:SetScript( "OnVerticalScroll", 
		function( self, offset )
			FauxScrollFrame_OnVerticalScroll( 
				self, 
				offset, 
				AJM.tradeScrollRowHeight, 
				AJM.TradeScrollRefreshCallback )			
		end 
	)
	
	frame.slotBackgrounds = {}
	frame.slots = {}
	left = 79
	right = 121
	top = 255
	bottom = 296
	width = right - left
	height = bottom - top
	for blockY = 0, (blockColumnSize - 1) do
		for blockX = 0, (blockRowSize - 1) do
			blockNumber = blockX + (blockY * blockColumnSize)
			local slotTexture = frame:CreateTexture( nil, "ARTWORK" )
			slotTexture:SetTexture( "Interface\\ContainerFrame\\UI-Bag-Components-Bank" )
			slotTexture:ClearAllPoints()
			blockXLocation = xOffset + (1 * (blockX * width))
			blockYLocation = -yOffset + (-1 * (blockY * height))
			slotTexture:SetPoint( "TOPLEFT", frame, "TOPLEFT", blockXLocation, blockYLocation )
			slotTexture:SetWidth( width )
			slotTexture:SetHeight( height )
			slotTexture:SetTexCoord( left/256, right/256, top/512, bottom/512 )
			frame.slotBackgrounds[blockNumber] = slotTexture
			frame.slots[cellCounter] = CreateFrame( "Button", "JambaTradeInventoryWindowFrameButton"..cellCounter, frame, "ItemButtonTemplate" )
			frame.slots[cellCounter]:SetPoint( "TOPLEFT", frame, "TOPLEFT", cellXOffset + blockXLocation, cellYOffset + blockYLocation )
			frame.slots[cellCounter]:SetScript( "OnClick", function( self ) AJM:OtherToonInventoryButtonClick( self ) end)
			frame.slots[cellCounter]:SetScript( "OnEnter", function( self ) AJM:OtherToonInventoryButtonEnter( self ) end )
			frame.slots[cellCounter]:SetScript( "OnLeave", function( self )  AJM:OtherToonInventoryButtonLeave( self ) end)					
			frame.slots[cellCounter]:Hide()
			cellCounter = cellCounter + 1
		end
	end
	JambaTradeInventoryFrame = frame
	table.insert( UISpecialFrames, "JambaTradeInventoryWindowFrame" )
	JambaTradeInventoryFrame:Hide()
end

function AJM:JambaTradeWindowCloseButtonClicked()
	JambaTradeInventoryFrame:Hide()
end

function AJM:JambaTradeClassDropDownChanged( event, value )
	AJM.itemClassCurrentSelection = value
	JambaTradeInventoryFrame.dropDownSubClass:SetList( AJM.itemClassSubList[value] )
	JambaTradeInventoryFrame.dropDownSubClass:SetValue( AJM.itemClassSubListLastSelection[value] )
	AJM:TradeScrollRefreshCallback()
end

function AJM:JambaTradeSubClassDropDownChanged( event, value )
	AJM.itemSubClassCurrentSelection = value
	AJM.itemClassSubListLastSelection[AJM.itemClassCurrentSelection] = AJM.itemSubClassCurrentSelection
	AJM:TradeScrollRefreshCallback()
end

function AJM:JambaTradeIgnoreSoulBoundCheckboxChanged()
	if JambaTradeInventoryFrame.checkBoxIgnoreSoulBound:GetChecked() == 1 then
		AJM.db.ignoreSoulBound = true
	else
		AJM.db.ignoreSoulBound = false
	end
end

function AJM.JambaTradeLoadMineButtonClicked()
	AJM:LoadItemClassIntoTradeWindow( AJM.itemClassCurrentSelection, AJM.itemSubClassCurrentSelection, AJM.db.ignoreSoulBound )
end

function AJM.JambaTradeLoadTheirsButtonClicked()
	AJM:JambaSendCommandToToon( UnitName( "npc" ), AJM.COMMAND_LOAD_ITEM_CLASS_INTO_TRADE, AJM.itemClassCurrentSelection, AJM.itemSubClassCurrentSelection, AJM.db.ignoreSoulBound )
end

function AJM:OtherToonInventoryButtonEnter( self )
	if self.link ~= nil then
		GameTooltip_SetDefaultAnchor( GameTooltip, self )
		GameTooltip:SetOwner( self, "ANCHOR_LEFT" )
		GameTooltip:ClearLines()
		GameTooltip:SetHyperlink( self.link )
		CursorUpdate()
	end
end

function AJM:OtherToonInventoryButtonLeave( self )
	if self.link ~= nil then
		GameTooltip:Hide()
		ResetCursor()
	end
end

function AJM:OtherToonInventoryButtonClick( self )
	AJM:JambaSendCommandToToon( UnitName( "npc" ), AJM.COMMAND_LOAD_ITEM_INTO_TRADE, self.bag, self.slot, false )
	SetItemButtonDesaturated( self, 1, 0.5, 0.5, 0.5 )
end

function AJM:GetInventory()
	local itemId
	AJM.inventory = ""
	for bag, slot, link in LibBagUtils:Iterate( "BAGS" ) do
		-- Don't send slots that have no items and don't send anything in the keyring bag (-2)
		if link ~= nil and bag ~= -2 then
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo( bag, slot )
			itemId = JambaUtilities:GetItemIdFromItemLink( link )
			AJM.inventory = AJM.inventory..bag..AJM.inventoryPartSeperator..slot..AJM.inventoryPartSeperator..itemId..AJM.inventoryPartSeperator..itemCount..AJM.inventorySeperator
		end
	end
end

function AJM:JambaTradeLoadTypeCommand(  info, parameters )
	local class, subclass = strsplit( ",", parameters )
	if class ~= nil and class:trim() ~= "" and subclass ~= nil and subclass:trim() ~= "" then
		AJM:LoadItemClassIntoTradeWindow( class:trim(), subclass:trim(), false )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Jamba-Trade: Please provide a class and a subclass seperated by a comma for the loadtype command."])
	end	
end

function AJM:JambaTradeLoadNameCommand(  info, parameters )
	local itemName, amount = strsplit( ",", parameters )
	if itemName ~= nil and itemName:trim() ~= "" and amount ~= nil and amount:trim() ~= "" then
		AJM:SplitStackItemByNameLimitAmount( itemName:trim(), amount:trim() )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Jamba-Trade: Please provide a name and an amount seperated by a comma for the loadname command."])
	end	
end

function AJM:TRADE_SHOW( event, ... )
	if AJM.db.showJambaTradeWindow == false then
		return
	end
	local slotsFree, totalSlots = LibBagUtils:CountSlots( "BAGS", 0 )
	JambaTradeInventoryFrame.labelMineBags:SetText( self.characterName..": "..(totalSlots - slotsFree).."/"..totalSlots )
	if slotsFree < 6 then
		JambaTradeInventoryFrame.labelMineBags:SetTextColor( 0.9, 0.0, 0.0 )
	end
	JambaTradeInventoryFrame.checkBoxIgnoreSoulBound:SetChecked( AJM.db.ignoreSoulBound )
	AJM:JambaTradeIgnoreSoulBoundCheckboxChanged()
	AJM:JambaSendCommandToToon( UnitName( "npc" ), AJM.COMMAND_GET_SLOT_COUNT )
	AJM:LoadThisToonsClasses()
	AJM:JambaSendCommandToToon( UnitName( "npc" ), AJM.COMMAND_SHOW_INVENTORY )
end

function AJM:TRADE_CLOSED()
	if AJM.db.showJambaTradeWindow == false then
		return
	end
	JambaTradeInventoryFrame:Hide()	
end

function AJM:GUILDBANKFRAME_OPENED()
	if AJM.db.adjustMoneyWithGuildBank == true then
		local moneyToKeepOnToon = tonumber( AJM.db.goldAmountToKeepOnToon ) * 10000
		local moneyOnToon = GetMoney()
		local moneyToDepositOrWithdraw = moneyOnToon - moneyToKeepOnToon
		if CanWithdrawGuildBankMoney() == 1 then
			if moneyToDepositOrWithdraw > 0 then
				DepositGuildBankMoney( moneyToDepositOrWithdraw )
			else
				WithdrawGuildBankMoney( -1 * moneyToDepositOrWithdraw )
			end
		end
	end	
end

function AJM:SendInventory( characterName )
	AJM:GetInventory()
	AJM:JambaSendCommandToToon( characterName, AJM.COMMAND_HERE_IS_MY_INVENTORY, AJM.inventory )
end

function AJM:GetSlotCountAndSendToToon( characterName )
	local slotsFree, totalSlots = LibBagUtils:CountSlots( "BAGS", 0 )
	AJM:JambaSendCommandToToon( characterName, AJM.COMMAND_HERE_IS_MY_SLOT_COUNT, slotsFree, totalSlots )
end

function AJM:SetOtherToonsSlotCount( characterName, slotsFree, totalSlots )
	JambaTradeInventoryFrame.labelTheirsBags:SetText( characterName..": "..(totalSlots - slotsFree).."/"..totalSlots )
	if slotsFree < 6 then
		JambaTradeInventoryFrame.labelTheirsBags:SetTextColor( 0.9, 0.0, 0.0 )
	end
end

function AJM:LoadItemIntoTrade( bag, slot, ignoreSoulBound )
	ClearCursor()
	LibGratuity:SetBagItem( bag,slot )
	if LibGratuity:Find( ITEM_SOULBOUND, 1, 3 ) then
		-- SOULBOUND
		if ignoreSoulBound == true then
			return true
		end
		if GetTradePlayerItemLink( MAX_TRADE_ITEMS ) == nil then
			PickupContainerItem( bag, slot )
			ClickTradeButton( MAX_TRADE_ITEMS )
			return true
		end	
	else
		for iterateTradeSlots = 1, (MAX_TRADE_ITEMS - 1) do
			if GetTradePlayerItemLink( iterateTradeSlots ) == nil then
				PickupContainerItem( bag, slot )
				ClickTradeButton( iterateTradeSlots )
				return true
			end
		end	
	end
	ClearCursor()
	return false
end

function AJM:LoadItemClassIntoTradeWindow( requiredClass, requiredSubClass, ignoreSoulBound )
	for bag, slot, link in LibBagUtils:Iterate( "BAGS" ) do
		-- Ignore slots that have no items and ignore anything in the keyring bag (-2)
		if link ~= nil and bag ~= -2 then
			local itemId = JambaUtilities:GetItemIdFromItemLink( link )
			local name, link, quality, iLevel, reqLevel, class, subClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemId )
			if requiredClass == L["!Single Item"] then
				if requiredSubClass == name then
					if AJM:LoadItemIntoTrade( bag, slot, ignoreSoulBound ) == false then
						return
					end
				end			
			end
			if requiredClass == L["!Quality"] then
				if requiredSubClass == AJM:GetQualityName( quality ) then
					if AJM:LoadItemIntoTrade( bag, slot, ignoreSoulBound ) == false then
						return
					end
				end						
			end
			if requiredClass == class and requiredSubClass == subClass then
				if AJM:LoadItemIntoTrade( bag, slot, ignoreSoulBound ) == false then
					return
				end
			end
		end
	end
end

function AJM:SplitStackItemByNameLimitAmount( name, amount )
	amount = tonumber( amount )
	local foundAndSplit = false
	for bag, slot, link in LibBagUtils:Iterate( "BAGS", name ) do
		-- If the item has been found and split, then finish up this section.
		if foundAndSplit == true then
			break
		end
		-- Attempt to split the item to the request amount.
		SplitContainerItem( bag, slot, amount )
		-- If successful, cursor will have item, stick it into an empty spot in the bags.
		if CursorHasItem() == 1 then
			LibBagUtils:PutItem( "BAGS" )
			foundAndSplit = true
		end
	end
	-- If item was found and split successfully then look for item stack of the request size and attempt to put it in the trade window.
	if foundAndSplit == true then
		AJM:ScheduleTimer( "LoadItemByNameLimitAmountIntoTradeWindow", 5, name..","..tostring( amount ) )		
	end
end

function AJM:LoadItemByNameLimitAmountIntoTradeWindow( nameAndAmount )
	local name, amount = strsplit( ",", nameAndAmount )
	amount = tonumber( amount )	
	for bag, slot, link in LibBagUtils:Iterate( "BAGS", name ) do
		local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo( bag, slot )
		if count == amount then
			-- This stack is the required size.
			AJM:LoadItemIntoTrade( bag, slot, false )
			break
		end
	end
end

local function JambaInventoryClassSort( a, b )
	local aClass = ""
	local bClass = ""
	local aSubClass = ""
	local bSubClass = ""
	local aName = ""
	local bName = ""
	if a ~= nil then
		aClass = a.class
		aSubClass = a.subClass
		aName = a.name
	end	
	if b ~= nil then
		bClass = b.class
		bSubClass = b.subClass
		bName = b.name
	end
	if aClass == bClass then
		if aSubClass == bSubClass then
			return aName > bName
		end
		return aSubClass > bSubClass
	end
	return aClass > bClass
end

function AJM:AddToClassAndSubClassLists( class, subClass )
	if class ~= nil then
		if AJM.itemClassList[class] == nil then
			AJM.itemClassList[class] = class 
			AJM.itemClassSubList[class] = {}
			AJM.itemClassSubListLastSelection[class] = ""
		end
		if class ~= nil and subClass ~= nil then
			AJM.itemClassSubList[class][subClass] = subClass
		end
	end
end

function AJM:GetQualityName( quality )
	if quality == 0 then
		return L["0. Poor (gray)"]
	end
	if quality == 1 then
		return L["1. Common (white)"]
	end
	if quality == 2 then
		return L["2. Uncommon (green)"]
	end
	if quality == 3 then
		return L["3. Rare / Superior (blue)"]
	end
	if quality == 4 then
		return L["4. Epic (purple)"]
	end
	if quality == 5 then
		return L["5. Legendary (orange)"]
	end
	if quality == 6 then
		return L["6. Artifact (golden yellow)"]
	end
	if quality == 7 then
		return L["7. Heirloom (light yellow)"]
	end
	return L["Unknown"]		
end

function AJM:LoadThisToonsClasses()
	local itemId
	for bag, slot, link in LibBagUtils:Iterate( "BAGS" ) do
		-- Don't send slots that have no items and don't send anything in the keyring bag (-2)
		if link ~= nil and bag ~= -2 then
			itemId = JambaUtilities:GetItemIdFromItemLink( link )
			local name, link, quality, iLevel, reqLevel, class, subClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemId )
			if name ~= nil then
				AJM:AddToClassAndSubClassLists( L["!Single Item"], name )
			end
			if quality ~= nil then
				AJM:AddToClassAndSubClassLists( L["!Quality"], AJM:GetQualityName( quality ) )
			end
			AJM:AddToClassAndSubClassLists( class, subClass )
		end
	end
end

function AJM:ShowOtherToonsInventory( characterName, inventory )
	table.wipe( AJM.inventorySortedTable )
	local inventoryLines = { strsplit( AJM.inventorySeperator, inventory ) }
	local inventoryInfo
	for index, line in ipairs( inventoryLines ) do
		local bag, slot, inventoryItemID, itemCount = strsplit( AJM.inventoryPartSeperator, line )
		if inventoryItemID ~= nil and inventoryItemID ~= "" then
			local name, link, quality, iLevel, reqLevel, class, subClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( inventoryItemID )
			AJM:AddToClassAndSubClassLists( class, subClass )
			if name ~= nil then
				AJM:AddToClassAndSubClassLists( L["!Single Item"], name )
			end
			if quality ~= nil then
				AJM:AddToClassAndSubClassLists( L["!Quality"], AJM:GetQualityName( quality ) )
			end			
			if texture == nil then
				class = "?"
				name = "?"
			end
			inventoryInfo = {}
			inventoryInfo.bag = bag
			inventoryInfo.slot = slot
			inventoryInfo.inventoryItemID = inventoryItemID
			inventoryInfo.itemCount = itemCount
			inventoryInfo.class = class
			inventoryInfo.subClass = subClass
			inventoryInfo.name = name
			table.insert( AJM.inventorySortedTable, inventoryInfo )
		end
	end
	table.sort( AJM.inventorySortedTable, JambaInventoryClassSort )
	-- Start the row at 1, and the column at 0.
	local rowCounter = 0
	local columnCounter = AJM.tradeScrollItemsPerRow - 1
	table.wipe( AJM.inventoryInDisplayTable )
	for index, line in ipairs( AJM.inventorySortedTable ) do
		columnCounter = columnCounter + 1
		if columnCounter == AJM.tradeScrollItemsPerRow then
			rowCounter = rowCounter + 1
			columnCounter = 0
		end	
		if AJM.inventoryInDisplayTable[rowCounter] == nil then
			AJM.inventoryInDisplayTable[rowCounter] = {}
		end
		AJM.inventoryInDisplayTable[rowCounter][columnCounter] = {}
		AJM.inventoryInDisplayTable[rowCounter][columnCounter]["bag"] = line.bag
		AJM.inventoryInDisplayTable[rowCounter][columnCounter]["slot"] = line.slot
		AJM.inventoryInDisplayTable[rowCounter][columnCounter]["inventoryItemID"] = line.inventoryItemID
		AJM.inventoryInDisplayTable[rowCounter][columnCounter]["itemCount"] = line.itemCount
	end
	AJM.tradeScrollMaximumRows = rowCounter
	AJM:TradeScrollRefreshCallback()
	JambaTradeInventoryFrame.dropDownClass:SetList( AJM.itemClassList )
	JambaTradeInventoryFrame:Show()
end

function AJM:TradeScrollRefreshCallback()
	FauxScrollFrame_Update(
		JambaTradeInventoryFrame.tradeScrollFrame, 
		AJM.tradeScrollMaximumRows,
		AJM.tradeScrollRowsToDisplay, 
		AJM.tradeScrollRowHeight
	)
	AJM.tradeScrollOffset = FauxScrollFrame_GetOffset( JambaTradeInventoryFrame.tradeScrollFrame )
	local slotNumber, columnNumber, slot
	local r, g, b
	for iterateDisplayRows = 1, AJM.tradeScrollRowsToDisplay do
		-- Reset cells.
		for columnNumber = 0, (AJM.tradeScrollItemsPerRow - 1) do
			slotNumber = columnNumber + ((iterateDisplayRows - 1) * AJM.tradeScrollItemsPerRow)			
			slot = JambaTradeInventoryFrame.slots[slotNumber]
			SetItemButtonTexture( slot, "" )
			slot:Hide()
		end
		-- Get data.
		local dataRowNumber = iterateDisplayRows + AJM.tradeScrollOffset
		if dataRowNumber <= AJM.tradeScrollMaximumRows then
			-- Put items in cells.
			for columnNumber, inventoryInfoTable in pairs( AJM.inventoryInDisplayTable[dataRowNumber] ) do
				slotNumber = columnNumber + ((iterateDisplayRows - 1) * AJM.tradeScrollItemsPerRow)
				slot = JambaTradeInventoryFrame.slots[slotNumber]
				local name, link, quality, iLevel, reqLevel, class, subClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( inventoryInfoTable["inventoryItemID"] )
				if texture == nil then
					texture = "Interface\\Icons\\Temp"
					r = 0.9
					g = 0.0
					b = 0.0
				else
					r, g, b = GetItemQualityColor( quality )
				end		
				SetItemButtonTexture( slot, texture )
				SetItemButtonCount( slot, tonumber( inventoryInfoTable["itemCount"] ) )
				if AJM.itemClassCurrentSelection == class and AJM.itemSubClassCurrentSelection == subClass then
					SetItemButtonTextureVertexColor( slot, 0.4, 0.9, 0.0 )
					SetItemButtonNormalTextureVertexColor( slot, 0.9, 0.9, 0.0 )
				elseif AJM.itemClassCurrentSelection == L["!Single Item"] and AJM.itemSubClassCurrentSelection == name then
					SetItemButtonTextureVertexColor( slot, 0.4, 0.9, 0.0 )
					SetItemButtonNormalTextureVertexColor( slot, 0.9, 0.9, 0.0 )
				elseif AJM.itemClassCurrentSelection == L["!Quality"] and AJM.itemSubClassCurrentSelection == AJM:GetQualityName( quality ) then
					SetItemButtonTextureVertexColor( slot, 0.4, 0.9, 0.0 )
					SetItemButtonNormalTextureVertexColor( slot, 0.9, 0.9, 0.0 )				
				else
					SetItemButtonTextureVertexColor( slot, 1.0, 1.0, 1.0 )
					SetItemButtonNormalTextureVertexColor( slot, r, g, b )
				end
				slot.link = link
				slot.bag = inventoryInfoTable["bag"]
				slot.slot = inventoryInfoTable["slot"]
				slot:Show()
			end
		end
	end
end
