--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--

-- Create the addon using AceAddon-3.0 and embed some libraries.
local AJM = LibStub( "AceAddon-3.0" ):NewAddon( 
	"JambaQuest", 
	"JambaModule-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Load libraries.
local JambaUtilities = LibStub:GetLibrary( "JambaUtilities-1.0" )
local JambaHelperSettings = LibStub:GetLibrary( "JambaHelperSettings-1.0" )
AJM.SharedMedia = LibStub( "LibSharedMedia-3.0" )

--  Constants and Locale for this module.
AJM.moduleName = "Jamba-Quest"
AJM.settingsDatabaseName = "JambaQuestProfileDB"
AJM.chatCommand = "jamba-quest"
local L = LibStub( "AceLocale-3.0" ):GetLocale( AJM.moduleName )
AJM.parentDisplayName = L["Quest"]
AJM.moduleDisplayName = L["Quest"]

-- Settings - the values to store and their defaults for the settings database.
AJM.settings = {
	profile = {
		mirrorMasterQuestSelectionAndDeclining = true,
		acceptQuests = true,
		slaveMirrorMasterAccept = true,
		allAutoSelectQuests = false,
		doNotAutoAccept = true,
		allAcceptAnyQuest = false,
		onlyAcceptQuestsFrom = false,
		acceptFromTeam = false,
		acceptFromNpc = false,
		acceptFromFriends = false,
		acceptFromParty = false,
		acceptFromRaid = false,
		acceptFromGuild = false,
		masterAutoShareQuestOnAccept = false,
		slaveAutoAcceptEscortQuest = true,
		showJambaQuestLogWithWoWQuestLog = true,
		enableAutoQuestCompletion = true,
		noChoiceAllDoNothing = false,
		noChoiceSlaveCompleteQuestWithMaster = true,
		noChoiceAllAutoCompleteQuest = false,
		hasChoiceSlaveDoNothing = false,
		hasChoiceSlaveCompleteQuestWithMaster = true,
		hasChoiceSlaveChooseSameRewardAsMaster = false,
		hasChoiceSlaveMustChooseOwnReward = true,
		hasChoiceSlaveRewardChoiceModifierConditional = false,
		hasChoiceAquireBestQuestRewardForCharacter = false,
		hasChoiceCtrlKeyModifier = false,
		hasChoiceShiftKeyModifier = false,
		hasChoiceAltKeyModifier = false,
		hasChoiceOverrideUseSlaveRewardSelected = true,
		messageArea = JambaApi.DefaultMessageArea(),
		warningArea = JambaApi.DefaultWarningArea(),
		framePoint = "CENTER",
		frameRelativePoint = "CENTER",
		frameXOffset = 0,
		frameYOffset = 0,
		overrideQuestAutoSelectAndComplete = false,
	},
}

-- Configuration.
function AJM:GetConfiguration()
	local configuration = {
		name = AJM.moduleDisplayName,
		handler = AJM,
		type = "group",
		get = "JambaConfigurationGetSetting",
		set = "JambaConfigurationSetSetting",
		args = {	
			autoselect = {
				type = "input",
				name = L["Set The Auto Select Functionality"],
				desc = L["Set the auto select functionality."],
				usage = "/jamba-quest autoselect <on | off | toggle> <tag>",
				get = false,
				set = "AutoSelectToggleCommand",
			},
			push = {
				type = "input",
				name = L["Push Settings"],
				desc = L["Push the quest settings to all characters in the team."],
				usage = "/jamba-quest push",
				get = false,
				set = "JambaSendSettings",
			},	
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

AJM.COMMAND_SELECT_GOSSIP_OPTION = "SelectGossipOption"
AJM.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST = "SelectGossipActiveQuest"
AJM.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST = "SelectGossipAvailableQuest"
AJM.COMMAND_SELECT_ACTIVE_QUEST = "SelectActiveQuest"
AJM.COMMAND_SELECT_AVAILABLE_QUEST = "SelectAvailableQuest"
AJM.COMMAND_ACCEPT_QUEST = "AcceptQuest"
AJM.COMMAND_COMPLETE_QUEST = "CompleteQuest"
AJM.COMMAND_CHOOSE_QUEST_REWARD = "ChooseQuestReward"
AJM.COMMAND_DECLINE_QUEST = "DeclineQuest"
AJM.COMMAND_SELECT_QUEST_LOG_ENTRY = "SelectQuestLogEntry"
AJM.COMMAND_QUEST_TRACK = "QuestTrack"
AJM.COMMAND_ABANDON_QUEST = "AbandonQuest"
AJM.COMMAND_ABANDON_ALL_QUESTS = "AbandonAllQuests"
AJM.COMMAND_TOGGLE_AUTO_SELECT = "ToggleAutoSelect"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

local function DebugMessage( ... )
	--AJM:Print( ... )
end

-- Initialise the module.
function AJM:OnInitialize()
	-- Create the settings control.
	AJM:SettingsCreate()
	-- Initialise the JambaModule part of this module.
	AJM:JambaModuleInitialize( AJM.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	AJM:SettingsRefresh()	
	-- Create the Jamba Quest Log frame.
	AJM.currentlySelectedQuest =  L["(No Quest Selected)"]
	AJM.jambaQuestLogFrame = nil
	AJM:CreateJambaQuestLogFrame()
	-- An empty table to hold the available and active quests at an npc.
	AJM.gossipQuests = {}
end

-- Called when the addon is enabled.
function AJM:OnEnable()
	-- No internal commands active.
	AJM.isInternalCommand = false
    -- Quest events.
	AJM:RegisterEvent( "QUEST_ACCEPTED" )
    AJM:RegisterEvent( "QUEST_DETAIL" )
    AJM:RegisterEvent( "QUEST_COMPLETE" )
    AJM:RegisterEvent( "QUEST_ACCEPT_CONFIRM" )
	AJM:RegisterEvent( "GOSSIP_SHOW" )
	AJM:RegisterEvent( "QUEST_GREETING" )
	AJM:RegisterEvent( "QUEST_PROGRESS" )
    -- Quest post hooks.
    AJM:SecureHook( "SelectGossipOption" )
    AJM:SecureHook( "SelectGossipActiveQuest" )
    AJM:SecureHook( "SelectGossipAvailableQuest" )
    AJM:SecureHook( "SelectActiveQuest" )
    AJM:SecureHook( "SelectAvailableQuest" )
    AJM:SecureHook( "AcceptQuest" )
    AJM:SecureHook( "CompleteQuest" )
    AJM:SecureHook( "DeclineQuest" )
	AJM:SecureHook( "GetQuestReward" )
	AJM:SecureHook( "ToggleFrame" )
	AJM:SecureHook( QuestLogFrame, "Hide", "QuestLogFrameHide" )
	AJM:SecureHook( "SelectQuestLogEntry" )
end

-- Called when the addon is disabled.
function AJM:OnDisable()
	-- AceHook-3.0 will tidy up the hooks for us. 
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

function AJM:SettingsCreate()
	AJM.settingsControl = {}
	AJM.settingsControlCompletion = {}
	-- Create the settings panels.
	JambaHelperSettings:CreateSettings( 
		AJM.settingsControl, 
		AJM.moduleDisplayName, 
		AJM.parentDisplayName, 
		AJM.SettingsPushSettingsClick 
	)
	JambaHelperSettings:CreateSettings( 
		AJM.settingsControlCompletion, 
		AJM.moduleDisplayName..L[": "]..L["Completion"], 
		AJM.parentDisplayName, 
		AJM.SettingsPushSettingsClick 
	)
	-- Create the quest controls.
	local bottomOfQuestOptions = AJM:SettingsCreateQuestControl( JambaHelperSettings:TopOfSettings() )
	AJM.settingsControl.widgetSettings.content:SetHeight( -bottomOfQuestOptions )
	local bottomOfQuestCompletionOptions = AJM:SettingsCreateQuestCompletionControl( JambaHelperSettings:TopOfSettings() )
	AJM.settingsControlCompletion.widgetSettings.content:SetHeight( -bottomOfQuestCompletionOptions )
	-- Help
	local helpTable = {}
	JambaHelperSettings:CreateHelp( AJM.settingsControl, helpTable, AJM:GetConfiguration() )		
end

function AJM:SettingsCreateQuestControl( top )
	-- Get positions and dimensions.
	local checkBoxHeight = JambaHelperSettings:GetCheckBoxHeight()
	local radioBoxHeight = JambaHelperSettings:GetRadioBoxHeight()
	local labelHeight = JambaHelperSettings:GetLabelHeight()
	local labelContinueHeight = JambaHelperSettings:GetContinueLabelHeight()
	local dropdownHeight = JambaHelperSettings:GetDropdownHeight()
	local left = JambaHelperSettings:LeftOfSettings()
	local headingHeight = JambaHelperSettings:HeadingHeight()
	local headingWidth = JambaHelperSettings:HeadingWidth( false )
	local horizontalSpacing = JambaHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = JambaHelperSettings:GetVerticalSpacing()
	local indent = horizontalSpacing * 10
	local indentContinueLabel = horizontalSpacing * 22
	local checkBoxThirdWidth = (headingWidth - indentContinueLabel) / 3
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local middle = left + halfWidth
	local column1Left = left
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top
	-- Create a heading for information.
	JambaHelperSettings:CreateHeading( AJM.settingsControl, AJM.moduleDisplayName..L[" "]..L["Information"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Information line 1.
	AJM.settingsControl.labelQuestInformation1 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Jamba-Quest treats any team member as the Master."] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 2.
	AJM.settingsControl.labelQuestInformation2 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Quest actions by one character will be actioned by the other"] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 3.
	AJM.settingsControl.labelQuestInformation3 = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["characters regardless of who the Master is."] 
	)	
	movingTop = movingTop - labelContinueHeight				
	-- Create a heading for quest selection.
	JambaHelperSettings:CreateHeading( AJM.settingsControl, L["Quest Selection & Acceptance"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Radio box: Slave select, accept and decline quest with master.
	AJM.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Select & Decline Quest With Team"],
		AJM.SettingsToggleMirrorMasterQuestSelectionAndDeclining
	)	
	AJM.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: All auto select quests.
	AJM.settingsControl.checkBoxAllAutoSelectQuests = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["All Auto Select Quests"],
		AJM.SettingsToggleAllAutoSelectQuests
	)	
	AJM.settingsControl.checkBoxAllAutoSelectQuests:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Check box: Accept quests.
	AJM.settingsControl.checkBoxAcceptQuests = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Accept Quests"],
		AJM.SettingsToggleAcceptQuests
	)	
	movingTop = movingTop - checkBoxHeight		
	-- Radio box: Slave accept quest with master.
	AJM.settingsControl.checkBoxSlaveMirrorMasterAccept = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Toon Accept Quest From Team"],
		AJM.SettingsToggleSlaveMirrorMasterAccept
	)	
	movingTop = movingTop - checkBoxHeight		
	-- Radio box: All auto accept any quest.
	AJM.settingsControl.checkBoxDoNotAutoAccept = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Do Not Auto Accept Quests"],
		AJM.SettingsToggleDoNotAutoAccept
	)	
	AJM.settingsControl.checkBoxDoNotAutoAccept:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight		
	-- Radio box: All auto accept any quest.
	AJM.settingsControl.checkBoxAllAcceptAnyQuest = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["All Auto Accept ANY Quest"],
		AJM.SettingsToggleAllAcceptAnyQuest
	)	
	AJM.settingsControl.checkBoxAllAcceptAnyQuest:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight		
	-- Radio box: Choose who to auto accept quests from.
	AJM.settingsControl.checkBoxOnlyAcceptQuestsFrom = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Only Auto Accept Quests From:"],
		AJM.SettingsToggleOnlyAcceptQuestsFrom
	)	
	AJM.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Check box: Team.
	AJM.settingsControl.checkBoxAcceptFromTeam = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["Team"],
		AJM.SettingsToggleAcceptFromTeam
	)	
	-- Check box: NPC.
	AJM.settingsControl.checkBoxAcceptFromNpc = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["NPC"],
		AJM.SettingsToggleAcceptFromNpc
	)	
	-- Check box: Friends.
	AJM.settingsControl.checkBoxAcceptFromFriends = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["Friends"],
		AJM.SettingsToggleAcceptFromFriends
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Party.
	AJM.settingsControl.checkBoxAcceptFromParty = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["Party"],
		AJM.SettingsToggleAcceptFromParty
	)	
	-- Check box: Raid.
	AJM.settingsControl.checkBoxAcceptFromRaid = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["Raid"],
		AJM.SettingsToggleAcceptFromRaid
	)	
	-- Check box: Guild.
	AJM.settingsControl.checkBoxAcceptFromGuild = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["Guild"],
		AJM.SettingsToggleAcceptFromGuild
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Master auto share quest on accept.
	AJM.settingsControl.checkBoxMasterAutoShareQuestOnAccept = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Master Auto Share Quests When Accepted"],
		AJM.SettingsToggleMasterAutoShareQuestOnAccept
	)	
	movingTop = movingTop - checkBoxHeight			
	-- Check box: Slave auto accept escort quest from master.
	AJM.settingsControl.checkBoxSlaveAutoAcceptEscortQuest = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Auto Accept Escort Quest From Team"],
		AJM.SettingsToggleSlaveAutoAcceptEscortQuest
	)	
	movingTop = movingTop - checkBoxHeight
	-- Create a heading for other options.
	JambaHelperSettings:CreateHeading( AJM.settingsControl, L["Other Options"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Check box: Override quest auto select and auto complete.
	AJM.settingsControl.checkBoxOverrideQuestAutoSelectAndComplete = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Hold Shift To Override Auto Select/Auto Complete"],
		AJM.SettingsToggleOverrideQuestAutoSelectAndComplete
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Show Jamba quest log with WoW quest log.
	AJM.settingsControl.checkBoxShowJambaQuestLogWithWoWQuestLog = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Show Jamba-Quest Log With WoW Quest Log"],
		AJM.SettingsToggleShowJambaQuestLogWithWoWQuestLog
	)	
	movingTop = movingTop - checkBoxHeight
	-- Message area.
	AJM.settingsControl.dropdownMessageArea = JambaHelperSettings:CreateDropdown( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["Send Message Area"] 
	)
	AJM.settingsControl.dropdownMessageArea:SetList( JambaApi.MessageAreaList() )
	AJM.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", AJM.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight
	-- Warning area.
	AJM.settingsControl.dropdownWarningArea = JambaHelperSettings:CreateDropdown( 
		AJM.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["Send Warning Area"] 
	)
	AJM.settingsControl.dropdownWarningArea:SetList( JambaApi.MessageAreaList() )
	AJM.settingsControl.dropdownWarningArea:SetCallback( "OnValueChanged", AJM.SettingsSetWarningArea )
	movingTop = movingTop - dropdownHeight
	return movingTop	
end

function AJM:SettingsCreateQuestCompletionControl( top )
	-- Get positions and dimensions.
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
	-- Create a heading for quest completion.
	JambaHelperSettings:CreateHeading( AJM.settingsControlCompletion, L["Quest Completion"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Check box: Enable auto quest completion.
	AJM.settingsControlCompletion.checkBoxEnableAutoQuestCompletion = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Enable Auto Quest Completion"],
		AJM.SettingsToggleEnableAutoQuestCompletion
	)	
	movingTop = movingTop - checkBoxHeight
	-- Label: Quest has no rewards or one reward.	
	AJM.settingsControlCompletion.labelQuestNoRewardsOrOneReward = JambaHelperSettings:CreateLabel( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Quest Has No Rewards Or One Reward:"]
	)	
	movingTop = movingTop - labelHeight
	-- Radio box: No choice, slave do nothing.
	AJM.settingsControlCompletion.checkBoxNoChoiceAllDoNothing = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Do Nothing"],
		AJM.SettingsToggleNoChoiceAllDoNothing
	)	
	AJM.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight	
	-- Radio box: No choice, slave complete quest with master.
	AJM.settingsControlCompletion.checkBoxNoChoiceSlaveCompleteQuestWithMaster = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Complete Quest With Team"],
		AJM.SettingsToggleNoChoiceSlaveCompleteQuestWithMaster
	)
	AJM.settingsControlCompletion.checkBoxNoChoiceSlaveCompleteQuestWithMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: No Choice, all automatically complete quest.
	AJM.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["All Automatically Complete Quest"],
		AJM.SettingsToggleNoChoiceAllAutoCompleteQuest
	)	
	AJM.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Label: Quest has more than one reward.
	AJM.settingsControlCompletion.labelQuestHasMoreThanOneReward = JambaHelperSettings:CreateLabel( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Quest Has More Than One Reward:"]
	)	
	movingTop = movingTop - labelHeight
	-- Radio box: Has choice, slave do nothing.
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveDoNothing = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Do Nothing"],
		AJM.SettingsToggleHasChoiceSlaveDoNothing
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveDoNothing:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, choose best reward.
	AJM.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Auto Chooses Best Reward"],
		AJM.SettingsToggleHasChoiceAquireBestQuestRewardForCharacter
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight		
	-- Radio box: Has choice, slave complete quest with master.
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveCompleteQuestWithMaster = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["Toon Complete Quest With Team"],
		AJM.SettingsToggleHasChoiceSlaveCompleteQuestWithMaster
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveCompleteQuestWithMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, slave must choose own reward.
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveMustChooseOwnReward = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Toon Must Choose Own Reward"],
		AJM.SettingsToggleHasChoiceSlaveMustChooseOwnReward
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveMustChooseOwnReward:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight	
	-- Radio box: Has choice, slave choose same reward as master.
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveChooseSameRewardAsMaster = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Toon Choose Same Reward As Team"],
		AJM.SettingsToggleHasChoiceSlaveChooseSameRewardAsMaster
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveChooseSameRewardAsMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, slave reward choice depends on modifier key pressed down.
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveRewardChoiceModifierConditional = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["If Modifier Keys Pressed, Toon Choose Same Reward"],
		AJM.SettingsToggleHasChoiceSlaveRewardChoiceModifierConditional
	)	
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveRewardChoiceModifierConditional:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Label continuing radio box above.
	AJM.settingsControlCompletion.labelHasChoiceSlaveRewardChoiceModifierConditional = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indentContinueLabel, 
		movingTop,
		L["As Team Otherwise Toon Must Choose Own Reward"]
	)	
	movingTop = movingTop - labelContinueHeight	
	-- Check box: Ctrl modifier key.
	AJM.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["Ctrl"],
		AJM.SettingsToggleHasChoiceCtrlKeyModifier
	)	
	-- Check box: Shift modifier key.
	AJM.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["Shift"],
		AJM.SettingsToggleHasChoiceShiftKeyModifier
	)	
	-- Check box: Alt modifier key.
	AJM.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["Alt"],
		AJM.SettingsToggleHasChoiceAltKeyModifier
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Has choice, override, if slave already has reward selected, choose that reward.
	AJM.settingsControlCompletion.checkBoxHasChoiceOverrideUseSlaveRewardSelected = JambaHelperSettings:CreateCheckBox( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["Override: If Toon Already Has Reward Selected,"],
		AJM.SettingsToggleHasChoiceOverrideUseSlaveRewardSelected
	)	
	movingTop = movingTop - checkBoxHeight
	-- Label continuing check box above.
	AJM.settingsControlCompletion.labelHasChoiceOverrideUseSlaveRewardSelected = JambaHelperSettings:CreateContinueLabel( 
		AJM.settingsControlCompletion, 
		headingWidth, 
		column1Left + indentSpecial, 
		movingTop,
		L["Choose That Reward"]
	)	
	movingTop = movingTop - labelContinueHeight	
	return movingTop	
end

-------------------------------------------------------------------------------------------------------------
-- Settings functionality.
-------------------------------------------------------------------------------------------------------------

-- Settings received.
function AJM:JambaOnSettingsReceived( characterName, settings )	
	if characterName ~= AJM.characterName then
		-- Update the settings.
		AJM.db.mirrorMasterQuestSelectionAndDeclining = settings.mirrorMasterQuestSelectionAndDeclining
		AJM.db.allAutoSelectQuests = settings.allAutoSelectQuests
		AJM.db.acceptQuests = settings.acceptQuests
		AJM.db.slaveMirrorMasterAccept = settings.slaveMirrorMasterAccept
		AJM.db.doNotAutoAccept = settings.doNotAutoAccept 
		AJM.db.allAcceptAnyQuest = settings.allAcceptAnyQuest
		AJM.db.onlyAcceptQuestsFrom = settings.onlyAcceptQuestsFrom
		AJM.db.acceptFromTeam = settings.acceptFromTeam
		AJM.db.acceptFromNpc = settings.acceptFromNpc
		AJM.db.acceptFromFriends = settings.acceptFromFriends
		AJM.db.acceptFromParty = settings.acceptFromParty
		AJM.db.acceptFromRaid = settings.acceptFromRaid
		AJM.db.acceptFromGuild = settings.acceptFromGuild
		AJM.db.masterAutoShareQuestOnAccept = settings.masterAutoShareQuestOnAccept
		AJM.db.slaveAutoAcceptEscortQuest = settings.slaveAutoAcceptEscortQuest
		AJM.db.showJambaQuestLogWithWoWQuestLog = settings.showJambaQuestLogWithWoWQuestLog
		AJM.db.enableAutoQuestCompletion = settings.enableAutoQuestCompletion
		AJM.db.noChoiceAllDoNothing = settings.noChoiceAllDoNothing
		AJM.db.noChoiceSlaveCompleteQuestWithMaster = settings.noChoiceSlaveCompleteQuestWithMaster
		AJM.db.noChoiceAllAutoCompleteQuest = settings.noChoiceAllAutoCompleteQuest
		AJM.db.hasChoiceSlaveDoNothing = settings.hasChoiceSlaveDoNothing
		AJM.db.hasChoiceSlaveCompleteQuestWithMaster = settings.hasChoiceSlaveCompleteQuestWithMaster
		AJM.db.hasChoiceSlaveChooseSameRewardAsMaster = settings.hasChoiceSlaveChooseSameRewardAsMaster
		AJM.db.hasChoiceSlaveMustChooseOwnReward = settings.hasChoiceSlaveMustChooseOwnReward
		AJM.db.hasChoiceSlaveRewardChoiceModifierConditional = settings.hasChoiceSlaveRewardChoiceModifierConditional
		AJM.db.hasChoiceCtrlKeyModifier = settings.hasChoiceCtrlKeyModifier
		AJM.db.hasChoiceShiftKeyModifier = settings.hasChoiceShiftKeyModifier
		AJM.db.hasChoiceAltKeyModifier = settings.hasChoiceAltKeyModifier
		AJM.db.hasChoiceOverrideUseSlaveRewardSelected = settings.hasChoiceOverrideUseSlaveRewardSelected
		AJM.db.hasChoiceAquireBestQuestRewardForCharacter = settings.hasChoiceAquireBestQuestRewardForCharacter
		AJM.db.messageArea = settings.messageArea
		AJM.db.warningArea = settings.warningArea
		AJM.db.overrideQuestAutoSelectAndComplete = settings.overrideQuestAutoSelectAndComplete
		-- Refresh the settings.
		AJM:SettingsRefresh()
		-- Tell the player.
		AJM:Print( L["Settings received from A."]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Settings Populate.
-------------------------------------------------------------------------------------------------------------

function AJM:BeforeJambaProfileChanged()	
end

function AJM:OnJambaProfileChanged()	
	AJM:SettingsRefresh()
end

function AJM:SettingsRefresh()
	-- Quest general and acceptance options.
	AJM.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining:SetValue( AJM.db.mirrorMasterQuestSelectionAndDeclining )
	AJM.settingsControl.checkBoxAllAutoSelectQuests:SetValue( AJM.db.allAutoSelectQuests )
	AJM.settingsControl.checkBoxAcceptQuests:SetValue( AJM.db.acceptQuests )
	AJM.settingsControl.checkBoxSlaveMirrorMasterAccept:SetValue( AJM.db.slaveMirrorMasterAccept )
	AJM.settingsControl.checkBoxDoNotAutoAccept:SetValue( AJM.db.doNotAutoAccept )
	AJM.settingsControl.checkBoxAllAcceptAnyQuest:SetValue( AJM.db.allAcceptAnyQuest )
	AJM.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetValue( AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromTeam:SetValue( AJM.db.acceptFromTeam )
	AJM.settingsControl.checkBoxAcceptFromNpc:SetValue( AJM.db.acceptFromNpc )
	AJM.settingsControl.checkBoxAcceptFromFriends:SetValue( AJM.db.acceptFromFriends )
	AJM.settingsControl.checkBoxAcceptFromParty:SetValue( AJM.db.acceptFromParty )
	AJM.settingsControl.checkBoxAcceptFromRaid:SetValue( AJM.db.acceptFromRaid )
	AJM.settingsControl.checkBoxAcceptFromGuild:SetValue( AJM.db.acceptFromGuild )
	AJM.settingsControl.checkBoxMasterAutoShareQuestOnAccept:SetValue( AJM.db.masterAutoShareQuestOnAccept )
	AJM.settingsControl.checkBoxSlaveAutoAcceptEscortQuest:SetValue( AJM.db.slaveAutoAcceptEscortQuest )
	AJM.settingsControl.checkBoxShowJambaQuestLogWithWoWQuestLog:SetValue( AJM.db.showJambaQuestLogWithWoWQuestLog )
	AJM.settingsControl.checkBoxOverrideQuestAutoSelectAndComplete:SetValue( AJM.db.overrideQuestAutoSelectAndComplete )
	AJM.settingsControl.dropdownMessageArea:SetValue( AJM.db.messageArea )
	AJM.settingsControl.dropdownWarningArea:SetValue( AJM.db.warningArea )
	-- Quest completion options.
	AJM.settingsControlCompletion.checkBoxEnableAutoQuestCompletion:SetValue( AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetValue( AJM.db.noChoiceAllDoNothing )
	AJM.settingsControlCompletion.checkBoxNoChoiceSlaveCompleteQuestWithMaster:SetValue( AJM.db.noChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetValue( AJM.db.noChoiceAllAutoCompleteQuest )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveDoNothing:SetValue( AJM.db.hasChoiceSlaveDoNothing )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveCompleteQuestWithMaster:SetValue( AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveChooseSameRewardAsMaster:SetValue( AJM.db.hasChoiceSlaveChooseSameRewardAsMaster )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveMustChooseOwnReward:SetValue( AJM.db.hasChoiceSlaveMustChooseOwnReward )
	AJM.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetValue( AJM.db.hasChoiceAquireBestQuestRewardForCharacter )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveRewardChoiceModifierConditional:SetValue( AJM.db.hasChoiceSlaveRewardChoiceModifierConditional )
	AJM.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier:SetValue( AJM.db.hasChoiceCtrlKeyModifier )
	AJM.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier:SetValue( AJM.db.hasChoiceShiftKeyModifier )
	AJM.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier:SetValue( AJM.db.hasChoiceAltKeyModifier )
	AJM.settingsControlCompletion.checkBoxHasChoiceOverrideUseSlaveRewardSelected:SetValue( AJM.db.hasChoiceOverrideUseSlaveRewardSelected )
	-- Ensure correct state (general and acceptance options).
	AJM.settingsControl.checkBoxSlaveMirrorMasterAccept:SetDisabled( not AJM.db.acceptQuests )
	AJM.settingsControl.checkBoxDoNotAutoAccept:SetDisabled( not AJM.db.acceptQuests )
	AJM.settingsControl.checkBoxAllAcceptAnyQuest:SetDisabled( not AJM.db.acceptQuests )
	AJM.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetDisabled( not AJM.db.acceptQuests )
	AJM.settingsControl.checkBoxAcceptFromTeam:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromNpc:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromFriends:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromParty:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromRaid:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	AJM.settingsControl.checkBoxAcceptFromGuild:SetDisabled( not AJM.db.acceptQuests or not AJM.db.onlyAcceptQuestsFrom )
	-- Ensure correct state (completion options). 
	AJM.settingsControlCompletion.labelQuestNoRewardsOrOneReward:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.labelQuestHasMoreThanOneReward:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxNoChoiceSlaveCompleteQuestWithMaster:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveDoNothing:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveCompleteQuestWithMaster:SetDisabled( not AJM.db.enableAutoQuestCompletion )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveChooseSameRewardAsMaster:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveMustChooseOwnReward:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.checkBoxHasChoiceSlaveRewardChoiceModifierConditional:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.labelHasChoiceSlaveRewardChoiceModifierConditional:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster or not AJM.db.hasChoiceSlaveRewardChoiceModifierConditional )
	AJM.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster or not AJM.db.hasChoiceSlaveRewardChoiceModifierConditional )
	AJM.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster or not AJM.db.hasChoiceSlaveRewardChoiceModifierConditional )
	AJM.settingsControlCompletion.checkBoxHasChoiceOverrideUseSlaveRewardSelected:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
	AJM.settingsControlCompletion.labelHasChoiceOverrideUseSlaveRewardSelected:SetDisabled( not AJM.db.enableAutoQuestCompletion or not AJM.db.hasChoiceSlaveCompleteQuestWithMaster )
end

function AJM:SettingsPushSettingsClick( event )
	AJM:JambaSendSettings()
end

function AJM:SettingsToggleMirrorMasterQuestSelectionAndDeclining( event, checked )
	AJM.db.mirrorMasterQuestSelectionAndDeclining = checked
	AJM.db.allAutoSelectQuests = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAllAutoSelectQuests( event, checked )
	AJM.db.allAutoSelectQuests = checked
	AJM.db.mirrorMasterQuestSelectionAndDeclining = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptQuests( event, checked )
	AJM.db.acceptQuests = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleSlaveMirrorMasterAccept( event, checked )
	AJM.db.slaveMirrorMasterAccept = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleOverrideQuestAutoSelectAndComplete( event, checked )
	AJM.db.overrideQuestAutoSelectAndComplete = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleDoNotAutoAccept( event, checked )
	AJM.db.doNotAutoAccept = checked
	AJM.db.allAcceptAnyQuest = not checked
	AJM.db.onlyAcceptQuestsFrom = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAllAcceptAnyQuest( event, checked )
	AJM.db.allAcceptAnyQuest = checked
	AJM.db.onlyAcceptQuestsFrom = not checked
	AJM.db.doNotAutoAccept = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleOnlyAcceptQuestsFrom( event, checked )
	AJM.db.onlyAcceptQuestsFrom = checked
	AJM.db.allAcceptAnyQuest = not checked
	AJM.db.doNotAutoAccept = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromTeam( event, checked )
	AJM.db.acceptFromTeam = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromNpc( event, checked )
	AJM.db.acceptFromNpc = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromFriends( event, checked )
	AJM.db.acceptFromFriends = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromParty( event, checked )
	AJM.db.acceptFromParty = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromRaid( event, checked )
	AJM.db.acceptFromRaid = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleAcceptFromGuild( event, checked )
	AJM.db.acceptFromGuild = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleMasterAutoShareQuestOnAccept( event, checked )
	AJM.db.masterAutoShareQuestOnAccept = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleSlaveAutoAcceptEscortQuest( event, checked )
	AJM.db.slaveAutoAcceptEscortQuest = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleShowJambaQuestLogWithWoWQuestLog( event, checked )
	AJM.db.showJambaQuestLogWithWoWQuestLog = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleEnableAutoQuestCompletion( event, checked )
	AJM.db.enableAutoQuestCompletion = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleNoChoiceAllDoNothing( event, checked )
	AJM.db.noChoiceAllDoNothing = checked
	AJM.db.noChoiceSlaveCompleteQuestWithMaster = not checked
	AJM.db.noChoiceAllAutoCompleteQuest = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleNoChoiceSlaveCompleteQuestWithMaster( event, checked )
	AJM.db.noChoiceSlaveCompleteQuestWithMaster = checked
	AJM.db.noChoiceAllDoNothing = not checked
	AJM.db.noChoiceAllAutoCompleteQuest = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleNoChoiceAllAutoCompleteQuest( event, checked )
	AJM.db.noChoiceAllAutoCompleteQuest = checked
	AJM.db.noChoiceAllDoNothing = not checked
	AJM.db.noChoiceSlaveCompleteQuestWithMaster = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceSlaveDoNothing( event, checked )
	AJM.db.hasChoiceSlaveDoNothing = checked
	AJM.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
	AJM.db.hasChoiceSlaveCompleteQuestWithMaster = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceSlaveCompleteQuestWithMaster( event, checked )
	AJM.db.hasChoiceSlaveCompleteQuestWithMaster = checked
	AJM.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
	AJM.db.hasChoiceSlaveDoNothing = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceAquireBestQuestRewardForCharacter( event, checked )
	AJM.db.hasChoiceAquireBestQuestRewardForCharacter = checked
	AJM.db.hasChoiceSlaveCompleteQuestWithMaster = not checked
	AJM.db.hasChoiceSlaveDoNothing = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceSlaveChooseSameRewardAsMaster( event, checked )
	AJM.db.hasChoiceSlaveChooseSameRewardAsMaster = checked
	AJM.db.hasChoiceSlaveMustChooseOwnReward = not checked
	AJM.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceSlaveMustChooseOwnReward( event, checked )
	AJM.db.hasChoiceSlaveMustChooseOwnReward = checked
	AJM.db.hasChoiceSlaveChooseSameRewardAsMaster = not checked
	AJM.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceSlaveRewardChoiceModifierConditional( event, checked )
	AJM.db.hasChoiceSlaveRewardChoiceModifierConditional = checked
	AJM.db.hasChoiceSlaveChooseSameRewardAsMaster = not checked
	AJM.db.hasChoiceSlaveMustChooseOwnReward = not checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceCtrlKeyModifier( event, checked )
	AJM.db.hasChoiceCtrlKeyModifier = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceShiftKeyModifier( event, checked )
	AJM.db.hasChoiceShiftKeyModifier = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceAltKeyModifier( event, checked )
	AJM.db.hasChoiceAltKeyModifier = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsToggleHasChoiceOverrideUseSlaveRewardSelected( event, checked )
	AJM.db.hasChoiceOverrideUseSlaveRewardSelected = checked
	AJM:SettingsRefresh()
end

function AJM:SettingsSetMessageArea( event, messageAreaValue )
	DebugMessage( event, messageAreaValue )
	AJM.db.messageArea = messageAreaValue
	AJM:SettingsRefresh()
end

function AJM:SettingsSetWarningArea( event, messageAreaValue )
	AJM.db.warningArea = messageAreaValue
	AJM:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - SELECTING AND DECLINING
-------------------------------------------------------------------------------------------------------------

function AJM:ChurnNpcGossip()
	-- GetGossipAvailableQuests and GetGossipActiveQuests are returning nil in some cases, so do this as well.
	--GetGossipAvailableQuests() now returns 5 elements per quest and GetGossipActiveQuests() returns 4. title, level, isTrivial, isDaily, ...
    local index
    for index = 0, GetNumAvailableQuests() do
		SelectAvailableQuest( index )
	end
    for index = 0, GetNumActiveQuests() do
		SelectActiveQuest( index )
	end
	JambaUtilities:ClearTable( AJM.gossipQuests )
	local availableQuestsData = { GetGossipAvailableQuests() }
	local iterateQuests = 1
	local questIndex = 1
	while( availableQuestsData[iterateQuests] ) do
		local questInformation = {}
		questInformation.type = "available"
		questInformation.index = questIndex
		questInformation.name = availableQuestsData[iterateQuests]
		questInformation.level = availableQuestsData[iterateQuests + 1]
		table.insert( AJM.gossipQuests, questInformation )
		iterateQuests = iterateQuests + 5
		questIndex = questIndex + 1
	end
	local activeQuestsData = { GetGossipActiveQuests() }
	iterateQuests = 1
	while( activeQuestsData[iterateQuests] ) do
		local questInformation = {}
		questInformation.type = "active"
		questInformation.index = questIndex
		questInformation.name = activeQuestsData[iterateQuests]
		questInformation.level = activeQuestsData[iterateQuests + 1]
		table.insert( AJM.gossipQuests, questInformation )
		iterateQuests = iterateQuests + 4
		questIndex = questIndex + 1
	end
	for index, questInformation in ipairs( AJM.gossipQuests ) do
		if questInformation.type == "available" then
			--AJM:JambaSendMessageToTeam( AJM.db.messageArea, "Auto Selecting Available Quest: "..questInformation.name.." of level "..questInformation.level )
			SelectGossipAvailableQuest( questInformation.index )
		end
		if questInformation.type == "active" then
			--AJM:JambaSendMessageToTeam( AJM.db.messageArea, "Auto Selecting Active Quest: "..questInformation.name.." of level "..questInformation.level )
			SelectGossipActiveQuest( questInformation.index )
		end			
	end

end

function AJM:CanAutomateAutoSelectAndComplete()
	if AJM.db.overrideQuestAutoSelectAndComplete == true then
		if IsShiftKeyDown() then
		   return false
		else
		   return true
		end
	end
	return true
 end

function AJM:GOSSIP_SHOW()
	if AJM.db.allAutoSelectQuests == true and AJM:CanAutomateAutoSelectAndComplete() == true then
        AJM:ChurnNpcGossip()
	end
end

function AJM:QUEST_GREETING()
	if AJM.db.allAutoSelectQuests == true and AJM:CanAutomateAutoSelectAndComplete() == true then
		AJM:ChurnNpcGossip()
	end
end

function AJM:QUEST_PROGRESS()
	if AJM.db.allAutoSelectQuests == true and AJM:CanAutomateAutoSelectAndComplete() == true then
		if IsQuestCompletable() then
			CompleteQuest()
		end
	end
end

function AJM:SelectGossipOption( gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "SelectGossipOption" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_GOSSIP_OPTION, gossipIndex )
		end
	end		
end

function AJM:DoSelectGossipOption( sender, gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoSelectGossipOption" )
		SelectGossipOption( gossipIndex )
		AJM.isInternalCommand = false
	end		
end

function AJM:SelectGossipActiveQuest( gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "SelectGossipActiveQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST, gossipIndex )		
		end
	end		
end

function AJM:DoSelectGossipActiveQuest( sender, gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoSelectGossipActiveQuest" )
		SelectGossipActiveQuest( gossipIndex )
		AJM.isInternalCommand = false
	end
end

function AJM:SelectGossipAvailableQuest( gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "SelectGossipAvailableQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST, gossipIndex )
		end
	end
end

function AJM:DoSelectGossipAvailableQuest( sender, gossipIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoSelectGossipAvailableQuest" )
		SelectGossipAvailableQuest( gossipIndex )
		AJM.isInternalCommand = false
	end
end

function AJM:SelectActiveQuest( questIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "SelectActiveQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_ACTIVE_QUEST, questIndex )
		end
	end		
end

function AJM:DoSelectActiveQuest( sender, questIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoSelectActiveQuest" )
		SelectActiveQuest( questIndex )
		AJM.isInternalCommand = false
	end
end

function AJM:SelectAvailableQuest( questIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then	
		if AJM.isInternalCommand == false then
			DebugMessage( "SelectAvailableQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_AVAILABLE_QUEST, questIndex )
		end
	end		
end

function AJM:DoSelectAvailableQuest( sender, questIndex )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoSelectAvailableQuest" )
		SelectAvailableQuest( questIndex )
		AJM.isInternalCommand = false
	end
end

function AJM:DeclineQuest()
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "DeclineQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_DECLINE_QUEST )
		end
	end		
end

function AJM:DoDeclineQuest( sender )
	if AJM.db.mirrorMasterQuestSelectionAndDeclining == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoDeclineQuest" )
		DeclineQuest()
		AJM.isInternalCommand = false
	end
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - COMPLETING
-------------------------------------------------------------------------------------------------------------

function AJM:CompleteQuest()  
	if AJM.db.enableAutoQuestCompletion == true then
		if AJM.isInternalCommand == false then
			DebugMessage( "CompleteQuest" )
			AJM:JambaSendCommandToTeam( AJM.COMMAND_COMPLETE_QUEST )
		end
	end
end

function AJM:DoCompleteQuest( sender )
	if AJM.db.enableAutoQuestCompletion == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoCompleteQuest" )	
		CompleteQuest()
		AJM.isInternalCommand = false
	end	
end

function AJM:QUEST_COMPLETE()
	DebugMessage( "QUEST_COMPLETE" )
	if AJM.db.enableAutoQuestCompletion == true then
		if AJM.db.hasChoiceAquireBestQuestRewardForCharacter == true then
			AJM:ChooseBestRewardForCharacter()
		elseif (AJM.db.noChoiceAllAutoCompleteQuest == true) and (GetNumQuestChoices() <= 1) then
			--AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Quest has X reward choices."]( GetNumQuestChoices() ) )
			AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Completed Quest: A"]( GetTitleText() ) )
			GetQuestReward( GetNumQuestChoices() )
		end		
	end
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - REWARDS
-------------------------------------------------------------------------------------------------------------

function AJM:CheckForOverrideAndChooseQuestReward( questIndex )
	-- Yes, override if slave has reward selected?
	if (AJM.db.hasChoiceOverrideUseSlaveRewardSelected == true) and (QuestInfoFrame.itemChoice > 0) then
		-- Yes, choose slaves reward.
		GetQuestReward( QuestInfoFrame.itemChoice )
	else
		-- No, choose masters reward.
		GetQuestReward( questIndex )
	end
end

function AJM:CheckForOverrideAndDoNotChooseQuestReward( questIndex )
	-- Yes, override if slave has reward selected?
	if QuestInfoFrame.itemChoice ~= nil then
		if (AJM.db.hasChoiceOverrideUseSlaveRewardSelected == true) and (QuestInfoFrame.itemChoice > 0) then
			-- Yes, choose slaves reward.
			GetQuestReward( QuestInfoFrame.itemChoice )
		end
	end
end

function AJM:AreCorrectConditionalKeysPressed()	
	local failTest = false
	if AJM.db.hasChoiceCtrlKeyModifier == true and IsControlKeyDown() == nil then
		failTest = true
	end
	if AJM.db.hasChoiceShiftKeyModifier == true and IsShiftKeyDown() == nil then
		failTest = true
	end
	if AJM.db.hasChoiceAltKeyModifier == true and IsAltKeyDown() == nil then
		failTest = true
	end
	return not failTest
end

function AJM:GetQuestReward( questIndex )
	if AJM.db.enableAutoQuestCompletion == true then
		if (AJM.db.noChoiceSlaveCompleteQuestWithMaster == true) or (AJM.db.hasChoiceSlaveCompleteQuestWithMaster == true) then 
			if AJM.isInternalCommand == false then
				DebugMessage( "GetQuestReward" )
				AJM:JambaSendCommandToTeam( AJM.COMMAND_CHOOSE_QUEST_REWARD, questIndex, AJM:AreCorrectConditionalKeysPressed() )
			end
		end
	end		
end

function AJM:DoChooseQuestReward( sender, questIndex, modifierKeysPressed )
	local numberOfQuestRewards = GetNumQuestChoices()
	if AJM.db.enableAutoQuestCompletion == true then
		if (AJM.db.noChoiceSlaveCompleteQuestWithMaster == true) or (AJM.db.hasChoiceSlaveCompleteQuestWithMaster == true) then 
			AJM.isInternalCommand = true
			DebugMessage( "DoChooseQuestReward" )
			--AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Quest has X reward choices."]( numberOfQuestRewards ) )
			DebugMessage( "Quest has ", numberOfQuestRewards, " reward choices." )
			-- How many reward choices does this quest have?
			if numberOfQuestRewards <= 1 then
				-- One or less.
				if AJM.db.noChoiceSlaveCompleteQuestWithMaster == true then
					GetQuestReward( questIndex )
				end
			else
				-- More than one.
				if AJM.db.hasChoiceSlaveCompleteQuestWithMaster == true then
					-- Choose same as master?
					if AJM.db.hasChoiceSlaveChooseSameRewardAsMaster == true then
						AJM:CheckForOverrideAndChooseQuestReward( questIndex )
					-- Choose same as master, conditional keys?
					elseif AJM.db.hasChoiceSlaveRewardChoiceModifierConditional == true then
						if modifierKeysPressed == true then
							AJM:CheckForOverrideAndChooseQuestReward( questIndex )
						else
							AJM:CheckForOverrideAndDoNotChooseQuestReward( questIndex )
						end
					end
				end
			end
			AJM.isInternalCommand = false
		end
	end
end

function AJM:ChooseBestRewardForCharacter()
	-- Provided by loop: http://www.dual-boxing.com/showpost.php?p=257610&postcount=1505
	-- Choose the best item for this character, otherwise choose the most valuable to vendor:
	local numberOfQuestRewards = GetNumQuestChoices()
	local mostValuableQuestItemIndex, mostValuableQuestItemValue, bestQuestItemIndex, bestQuestItemArmorWeight = 1, 0, -1, -1
	local armorWeights = { Plate = 4, Mail = 2, Leather = 1, Cloth = 0 }
                
	-- Yanked this from LibItemUtils; sucks that we need this lookup table, but GetItemInfo only 
	-- returns an equipment location, which must first be converted to a slot value that GetInventoryItemLink understands:
	local equipmentSlotLookup = {
		INVTYPE_HEAD = {"HeadSlot", nil},
		INVTYPE_NECK = {"NeckSlot", nil},
		INVTYPE_SHOULDER = {"ShoulderSlot", nil},
		INVTYPE_CLOAK = {"BackSlot", nil},
		INVTYPE_CHEST = {"ChestSlot", nil},
		INVTYPE_WRIST = {"WristSlot", nil},
		INVTYPE_HAND = {"HandsSlot", nil},
		INVTYPE_WAIST = {"WaistSlot", nil},
		INVTYPE_LEGS = {"LegsSlot", nil},
		INVTYPE_FEET = {"FeetSlot", nil},
		INVTYPE_SHIELD = {"SecondaryHandSlot", nil},
		INVTYPE_ROBE = {"ChestSlot", nil},
		INVTYPE_2HWEAPON = {"MainHandSlot", "SecondaryHandSlot"},
		INVTYPE_WEAPONMAINHAND = {"MainHandSlot", nil},
		INVTYPE_WEAPONOFFHAND = {"SecondaryHandSlot", "MainHandSlot"},
		INVTYPE_WEAPON = {"MainHandSlot","SecondaryHandSlot"},
		INVTYPE_THROWN = {"RangedSlot", nil},
		INVTYPE_RANGED = {"RangedSlot", nil},
		INVTYPE_RANGEDRIGHT = {"RangedSlot", nil},
		INVTYPE_FINGER = {"Finger0Slot", "Finger1Slot"},
		INVTYPE_HOLDABLE = {"SecondaryHandSlot", "MainHandSlot"},
		INVTYPE_TRINKET = {"Trinket0Slot", "Trinket1Slot"}
	} 
                        
	for questItemIndex = 1, numberOfQuestRewards do
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(GetQuestItemLink("choice", questItemIndex))
		-- If there is a rare item as a reward, bail and let the player choose.
		if itemRarity >= 3 then
			return
		end
		local itemId = itemLink:match("|Hitem:(%d+)")
		local isItemEquippable = IsEquippableItem(itemId)
		local _, _, _, _, isItemUsable = GetQuestItemInfo("choice", questItemIndex)
                
		if itemSellPrice > mostValuableQuestItemValue then
			-- Keep track of which item is most valuable:
			mostValuableQuestItemIndex = questItemIndex
			mostValuableQuestItemValue = itemSellPrice
		end
                            
		if isItemEquippable == 1 and isItemUsable ~= nil then
			-- NPC is offering us an item we can actually wear:
			local currentEquippedItemLinksInSlots = {}
			local currentWorstEquippedItemInSlot = nil
			
			-- Figure out what we already have equipped:
			for _, itemSlot in ipairs(equipmentSlotLookup[itemEquipLoc]) do
				if itemSlot ~= nil then
					local currentEquippedItemLinkInSlot = GetInventoryItemLink("player", GetInventorySlotInfo(itemSlot))
					
					if currentEquippedItemLinkInSlot == nil then
						-- Of the n item slots available, at least one of them has nothing equipped. Ergo, it is the worst:
						currentWorstEquippedItemInSlot = nil
						break
					else
						-- There's an item in this slot, get some details on it:
						local _, _, _, currentEquippedItemLevelInSlot, _, _, currentEquippedItemSubTypeInSlot = GetItemInfo(currentEquippedItemLinkInSlot)
						
						-- We haven't yet determined the worst item, or the item we see in this slot happens to be worse than the other item
						-- we saw in this partner slot (ie. a ring in one slot is worse than a ring in another slot):
						if currentWorstEquippedItemInSlot == nil or currentWorstEquippedItemInSlot.itemLevel > currentEquippedItemLevelInSlot then
							currentWorstEquippedItemInSlot = { 
								itemLink = currentEquippedItemLinkInSlot,
								itemLevel = currentEquippedItemLevelInSlot,
								itemSubType = currentEquippedItemSubTypeInSlot
							}
						end
					end
				end
			end

			if currentWorstEquippedItemInSlot == nil then
				-- We're not even wearing an item in this slot, and the vendor has something we can use, take it:
				bestQuestItemIndex = questItemIndex
			else
				if itemLevel > currentWorstEquippedItemInSlot.itemLevel then
					-- NPC is providing us with an better item than what we currently have in this slot:
					if armorWeights[itemSubType] ~= nil then
						-- Armor subtype is one which we care to select based on some priority order:
						if armorWeights[itemSubType] > bestQuestItemArmorWeight then
							-- If this piece of armor is a better subtype (ie. Plate is better than Cloth if we can wear it):
							bestQuestItemIndex = questItemIndex
							bestQuestItemArmorWeight = armorWeights[itemSubType]
						end
					elseif currentWorstEquippedItemInSlot.itemSubType == itemSubType then
						-- This isn't a piece of armor (ie. might be a weapon) - only take it if it's the same 
						-- subtype as the item we are already wearing (if we're wearing a staff, and NPC offers
						--  a staff and a dagger, we'll take the staff):
						bestQuestItemIndex = questItemIndex
						bestQuestItemArmorWeight = -1
					end
				end
			end
		end
	end
                        
	if bestQuestItemIndex < 0 then
		-- If we haven't determined an item upgrade by now, just choose the one that we can vendor for the most gold:
		bestQuestItemIndex = mostValuableQuestItemIndex
	end
	
	GetQuestReward(bestQuestItemIndex)

end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - ACCEPTING
-------------------------------------------------------------------------------------------------------------

function AJM:QUEST_ACCEPTED( ... )
	local event, questIndex =  ...
	if AJM.db.acceptQuests == true then
		if AJM.db.masterAutoShareQuestOnAccept == true then	
			if JambaApi.IsCharacterTheMaster( AJM.characterName ) == true then
				if AJM.isInternalCommand == false then
					AJM:JambaSendMessageToTeam( AJM.db.messageArea, "Attempting to auto share newly accepted quest." )
					SelectQuestLogEntry( questIndex )
					if AJM:IsCurrentlySelectedQuestValid() == true then
						if GetQuestLogPushable() == 1 and GetNumPartyMembers() > 0 then
							AJM:JambaSendMessageToTeam( AJM.db.messageArea, "Pushing newly accepted quest." )
							QuestLogPushQuest()
						end
					end
				end	
			end
		end
	end
end

function AJM:AcceptQuest()
	if AJM.db.acceptQuests == true then
		if AJM.db.slaveMirrorMasterAccept == true then	
			if AJM.isInternalCommand == false then
				DebugMessage( "AcceptQuest" )
				AJM:JambaSendCommandToTeam( AJM.COMMAND_ACCEPT_QUEST )
			end		
		end
	end
end

function AJM:DoAcceptQuest( sender )
	if AJM.db.acceptQuests == true and AJM.db.slaveMirrorMasterAccept == true then
		AJM.isInternalCommand = true
		DebugMessage( "DoAcceptQuest" )
		AcceptQuest()
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Accepted Quest: A"]( GetTitleText() ) )
		AJM.isInternalCommand = false	
	end
end

-------------------------------------------------------------------------------------------------------------
-- QUEST PROCESSING - AUTO ACCEPTING
-------------------------------------------------------------------------------------------------------------

function AJM:CanAutoAcceptSharedQuestFromPlayer()
	local canAccept = false
	if AJM.db.allAcceptAnyQuest == true then
		canAccept = true
	elseif AJM.db.onlyAcceptQuestsFrom == true then
		local questSourceName, questSourceRealm = UnitName( "npc" )
		if AJM.db.acceptFromTeam == true then	
			if JambaApi.IsCharacterInTeam( questSourceName ) == true then
				canAccept = true
			end
		end
		if AJM.db.acceptFromFriends == true then	
			for friendIndex = 1, GetNumFriends() do
				local friendName = GetFriendInfo( friendIndex )
				if questSourceName == friendName then
					canAccept = true
					break
				end
			end	
		end
		if AJM.db.acceptFromParty == true then	
			if UnitInParty( "npc" ) == 1 then
				canAccept = true
			end
		end
		if AJM.db.acceptFromRaid == true then	
			if UnitInRaid( "npc" ) ~= nil then
				canAccept = true
			end
		end
		if AJM.db.acceptFromGuild == true then
			if UnitIsInMyGuild( "npc" ) == 1 then
				canAccept = true
			end
		end			
	end
	return canAccept
end

function AJM:QUEST_DETAIL()
	DebugMessage( "QUEST_DETAIL" )
	if AJM.db.acceptQuests == true then
		-- Who is this quest from.
		local questSourceName, questSourceRealm = UnitName( "npc" )
		if UnitIsPlayer( "npc" ) == 1 then
			-- Quest is shared from a player.
			if AJM:CanAutoAcceptSharedQuestFromPlayer() == true then		
				AJM.isInternalCommand = true
				AcceptQuest()
				AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Automatically Accepted Quest: A"]( GetTitleText() ) )
				AJM.isInternalCommand = false
			end			
		else
			-- Quest is from an NPC.
			if (AJM.db.allAcceptAnyQuest == true) or ((AJM.db.onlyAcceptQuestsFrom == true) and (AJM.db.acceptFromNpc == true)) then		
				AJM.isInternalCommand = true
				AcceptQuest()
				AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Automatically Accepted Quest: A"]( GetTitleText() ) )
				AJM.isInternalCommand = false
			end
		end
	end	
end

-------------------------------------------------------------------------------------------------------------
-- ESCORT QUEST
-------------------------------------------------------------------------------------------------------------

function AJM:QUEST_ACCEPT_CONFIRM( event, senderName, questName )
	DebugMessage( "QUEST_ACCEPT_CONFIRM" )
	if AJM.db.acceptQuests == true then
		if AJM.db.slaveAutoAcceptEscortQuest == true then
			AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Automatically Accepted Escort Quest: A"]( questName ) )
			AJM.isInternalCommand = true
			ConfirmAcceptQuest()
			AJM.isInternalCommand = false
			StaticPopup_Hide( "QUEST_ACCEPT" )
		end
	end	
end

-------------------------------------------------------------------------------------------------------------
-- JAMBA QUEST LOG WINDOW
-------------------------------------------------------------------------------------------------------------

function AJM.JambaQuestSelectButtonClicked()
	if AJM:IsCurrentlySelectedQuestValid() == true then
		AJM:JambaSendCommandToTeam( AJM.COMMAND_SELECT_QUEST_LOG_ENTRY, AJM.currentlySelectedQuest, AJM.selectedTag )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["You must select a quest from the quest log in order to action it on your other characters."] )
	end
end

function AJM.JambaQuestShareButtonClicked()
	if AJM:IsCurrentlySelectedQuestValid() == true then
		if GetQuestLogPushable() == 1 and GetNumPartyMembers() > 0 then
			QuestLogPushQuest()
		end
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["You must select a quest from the quest log in order to action it on your other characters."] )
	end
end

function AJM.JambaQuestTrackButtonClicked()
	if AJM:IsCurrentlySelectedQuestValid() == true then
		local watch = 0
		local questIndex = AJM:GetQuestLogIndexByName( AJM.currentlySelectedQuest )
		if questIndex ~= 0 then
			if IsQuestWatched( questIndex ) == 1 then
				RemoveQuestWatch( questIndex )
				watch = 0
			else
				AddQuestWatch( questIndex )
				watch = 1
			end
		end	
		AJM:JambaSendCommandToTeam( AJM.COMMAND_QUEST_TRACK, AJM.currentlySelectedQuest, watch, AJM.selectedTag )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["You must select a quest from the quest log in order to action it on your other characters."] )
	end
end

function AJM.JambaQuestTrackAllButtonClicked()
	AJM.iterateQuests = 1
	if AJM.iterateQuests <= GetNumQuestLogEntries() then
		AJM:ScheduleTimer( "TrackNextQuest", 0.5 )
	end
end

function AJM.TrackNextQuest()
	local title, level, tag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle( AJM.iterateQuests )
	if isHeader == nil then
		if title ~= nil then
			SelectQuestLogEntry( AJM.iterateQuests )	
			if AJM:IsCurrentlySelectedQuestValid() == true then
				local watch = 0
				local questIndex = AJM:GetQuestLogIndexByName( AJM.currentlySelectedQuest )
				if questIndex ~= 0 then
					if IsQuestWatched( questIndex ) == 1 then
						RemoveQuestWatch( questIndex )
						watch = 0
					else
						AddQuestWatch( questIndex )
						watch = 1
					end
				end	
				AJM:JambaSendCommandToTeam( AJM.COMMAND_QUEST_TRACK, AJM.currentlySelectedQuest, watch, AJM.selectedTag )
			end	
		end
	end
	AJM.iterateQuests = AJM.iterateQuests + 1
	if AJM.iterateQuests <= GetNumQuestLogEntries() then
		AJM:ScheduleTimer( "TrackNextQuest", 0.5 )
	end
end

function AJM:JambaQuestAbandonQuest()
	if AJM:IsCurrentlySelectedQuestValid() == true then
		AJM:JambaSendCommandToTeam( AJM.COMMAND_ABANDON_QUEST, AJM.currentlySelectedQuest, AJM.selectedTag )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["You must select a quest from the quest log in order to action it on your other characters."] )
	end
end

function AJM.JambaQuestAbandonButtonClicked()
	if AJM:IsCurrentlySelectedQuestValid() == true then
		StaticPopup_Show( "JAMBAQUEST_CONFIRM_ABANDON_QUEST", AJM.currentlySelectedQuest )
	else
		AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["You must select a quest from the quest log in order to action it on your other characters."] )
	end
end

function AJM:JambaQuestAbandonAllQuests()
	AJM:JambaSendCommandToTeam( AJM.COMMAND_ABANDON_ALL_QUESTS, AJM.selectedTag )
end

function AJM.AbandonNextQuest()
	local title, level, tag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle( AJM.iterateQuests )
	if isHeader == nil then
		if title ~= nil then
			SelectQuestLogEntry( AJM.iterateQuests )
			SetAbandonQuest()
			AbandonQuest()
			AJM:UpdateQuestLog( nil )
			-- Start again at the top, as to not miss any quests.
			AJM.iterateQuests = 1
		end
	end
	AJM.iterateQuests = AJM.iterateQuests + 1
	if AJM.iterateQuests <= GetNumQuestLogEntries() then
		AJM:ScheduleTimer( "AbandonNextQuest", 0.5 )
	end
end

function AJM.JambaQuestAbandonAllButtonClicked()
	StaticPopup_Show( "JAMBAQUEST_CONFIRM_ABANDON_ALL_QUESTS" )
end

function AJM.JambaQuestShareAllButtonClicked()
	AJM.iterateQuests = 1
	if AJM.iterateQuests <= GetNumQuestLogEntries() then
		AJM:ScheduleTimer( "PushNextQuest", 1 )
	end
end

function AJM.PushNextQuest()
	local title, level, tag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle( AJM.iterateQuests )
	if isHeader == nil then
		if title ~= nil then
			SelectQuestLogEntry( AJM.iterateQuests )
			if GetQuestLogPushable() == 1 and GetNumPartyMembers() > 0 then
				AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["Sharing Quest: A"]( title ) )
				QuestLogPushQuest()
			end			
		end
	end
	AJM.iterateQuests = AJM.iterateQuests + 1
	if AJM.iterateQuests <= GetNumQuestLogEntries() then
		AJM:ScheduleTimer( "PushNextQuest", 1 )
	end
end

function AJM.JambaQuestCloseButtonClicked()
	AJM.jambaQuestLogFrame:Hide()
end

function AJM.JambaQuestTagDropDownOnClick()
	UIDropDownMenu_SetSelectedValue( this.owner, this.value )
	AJM.selectedTag = UIDropDownMenu_GetSelectedValue( AJM.jambaQuestLogFrameDropDownTag )
end

function AJM.JambaQuestTagDropDownInitialize()
	local level = 1
	local info = UIDropDownMenu_CreateInfo()	
	for index, tag in JambaApi.AllTagsList() do
		info.text = tag
		info.value = tag
		info.func = function() AJM.JambaQuestTagDropDownOnClick() end
		info.owner = this:GetParent()
		info.checked = nil
		info.icon = nil
		UIDropDownMenu_AddButton( info, level )
	end
end

function AJM:CreateJambaQuestLogFrame()
	local frameName = "JambaQuestLogWindowFrame"
	local frame = CreateFrame( "Frame", "JambaQuestLogWindowFrame", UIParent )
	frame:SetWidth( 670 )
	frame:SetHeight( 61 )
	frame:SetFrameStrata( "HIGH" )
	frame:SetToplevel( true )
	frame:SetClampedToScreen( true )
	frame:EnableMouse()
	frame:SetMovable( true )	
	frame:ClearAllPoints()
	frame:SetPoint( AJM.db.framePoint, UIParent, AJM.db.frameRelativePoint, AJM.db.frameXOffset, AJM.db.frameYOffset )
	frame:RegisterForDrag( "LeftButton" )
	frame:SetScript( "OnDragStart", 
		function( this ) 
			if IsAltKeyDown() == 1 then
				this:StartMoving() 
			end
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
	frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 15, edgeSize = 15, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	} )
	local buttonHeight = 22	
	local buttonTop = -7
	local buttonTopSecondRow = buttonTop - buttonHeight - 2
	local left = -10
	local spacing = 1
	-- Tags
	local dropDownTag = CreateFrame( "Frame", frameName.."DropDownTag", frame, "UIDropDownMenuTemplate" )
	dropDownTag:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, -4 )
	UIDropDownMenu_SetWidth( dropDownTag, 90 )
	UIDropDownMenu_Initialize( dropDownTag, AJM.JambaQuestTagDropDownInitialize )
	AJM.jambaQuestLogFrameDropDownTag = dropDownTag
	left = left + 125 + spacing
	-- Select.
	local selectButton = CreateFrame( "Button", frameName.."ButtonSelect", frame, "UIPanelButtonTemplate" )
	selectButton:SetScript( "OnClick", AJM.JambaQuestSelectButtonClicked )
	selectButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTop )
	selectButton:SetHeight( buttonHeight )
	selectButton:SetWidth( 100 )
	selectButton:SetText( L["Select"] )		
	left = left + 100 + spacing
	-- Share / Share All.
	local shareButton = CreateFrame( "Button", frameName.."ButtonShare", frame, "UIPanelButtonTemplate" )
	shareButton:SetScript( "OnClick", AJM.JambaQuestShareButtonClicked )
	shareButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTop )
	shareButton:SetHeight( buttonHeight )
	shareButton:SetWidth( 100 )
	shareButton:SetText( L["Share"] )		
	AJM.jambaQuestLogFrameShareButton = shareButton
	local shareAllButton = CreateFrame( "Button", frameName.."ButtonShareAll", frame, "UIPanelButtonTemplate" )
	shareAllButton:SetScript( "OnClick", AJM.JambaQuestShareAllButtonClicked )
	shareAllButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTopSecondRow )
	shareAllButton:SetHeight( buttonHeight )
	shareAllButton:SetWidth( 100 )
	shareAllButton:SetText( L["Share All"] )		
	left = left + 100 + spacing
	-- Track / Track All.
	local trackButton = CreateFrame( "Button", frameName.."ButtonTrack", frame, "UIPanelButtonTemplate" )
	trackButton:SetScript( "OnClick", AJM.JambaQuestTrackButtonClicked )
	trackButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTop )
	trackButton:SetHeight( buttonHeight )
	trackButton:SetWidth( 100 )
	trackButton:SetText( L["Track"] )
	local trackAllButton = CreateFrame( "Button", frameName.."ButtonTrackAll", frame, "UIPanelButtonTemplate" )
	trackAllButton:SetScript( "OnClick", AJM.JambaQuestTrackAllButtonClicked )
	trackAllButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTopSecondRow )
	trackAllButton:SetHeight( buttonHeight )
	trackAllButton:SetWidth( 100 )
	trackAllButton:SetText( L["Track All"] )	
	left = left + 100 + spacing
	-- Abandon / Abandon All.
	local abandonButton = CreateFrame( "Button", frameName.."ButtonAbandon", frame, "UIPanelButtonTemplate" )
	abandonButton:SetScript( "OnClick", AJM.JambaQuestAbandonButtonClicked )
	abandonButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTop )
	abandonButton:SetHeight( buttonHeight )
	abandonButton:SetWidth( 100 )
	abandonButton:SetText( L["Abandon"] )		
	local abandonAllButton = CreateFrame( "Button", frameName.."ButtonAbandonAll", frame, "UIPanelButtonTemplate" )
	abandonAllButton:SetScript( "OnClick", AJM.JambaQuestAbandonAllButtonClicked )
	abandonAllButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", left, buttonTopSecondRow )
	abandonAllButton:SetHeight( buttonHeight )
	abandonAllButton:SetWidth( 100 )
	abandonAllButton:SetText( L["Abandon All"] )		
	left = left + 100 + spacing
	-- Close.
	local closeButton = CreateFrame( "Button", frameName.."ButtonClose", frame, "UIPanelCloseButton" )
	closeButton:SetScript( "OnClick", AJM.JambaQuestCloseButtonClicked )
	closeButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -1, -2 )	
	AJM.jambaQuestLogFrame = frame
	table.insert( UISpecialFrames, "JambaQuestLogWindowFrame" )
	-- Populate tag dropdown.
	UIDropDownMenu_SetText( AJM.jambaQuestLogFrameDropDownTag, JambaApi.AllTag() )
	UIDropDownMenu_SetSelectedName( AJM.jambaQuestLogFrameDropDownTag, JambaApi.AllTag() )
	AJM.selectedTag = JambaApi.AllTag()
	-- Popups.
	StaticPopupDialogs["JAMBAQUEST_CONFIRM_ABANDON_QUEST"] = {
        text = L['Abandon "%s"?'],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function()
			AJM:JambaQuestAbandonQuest()
		end,
    }        
	StaticPopupDialogs["JAMBAQUEST_CONFIRM_ABANDON_ALL_QUESTS"] = {
        text = L["This will abandon ALL quests ON every toon!  Yes, this means you will end up with ZERO quests in your quest log!  Are you sure?"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function()
			AJM:JambaQuestAbandonAllQuests()
		end,
    }        
end

function AJM:ToggleFrame( frame )
	if frame == QuestLogFrame then
		if AJM.db.showJambaQuestLogWithWoWQuestLog == true then
			if QuestLogFrame:IsVisible() then
				AJM:ToggleShowQuestCommandWindow( true )		
			else
				AJM:ToggleShowQuestCommandWindow( false )
			end
		end
	end
end

function AJM:QuestLogFrameHide()
	if AJM.db.showJambaQuestLogWithWoWQuestLog == true then
		AJM:ToggleShowQuestCommandWindow( false )
	end
end

function AJM:ToggleShowQuestCommandWindow( show )
    if show == true then	
		AJM.jambaQuestLogFrame:Show()
    else
		AJM.jambaQuestLogFrame:Hide()
    end
end

function AJM:UpdateQuestLog( questIndex )		
	if QuestLogFrame:IsVisible() or QuestLogDetailScrollFrame:IsVisible() then
		if questIndex then
			QuestLog_SetSelection( questIndex )
		end
	end
	if QuestLogFrame:IsVisible() then		
		QuestLog_Update()
	end
	if QuestLogDetailScrollFrame:IsVisible() then		
		QuestLog_UpdateQuestDetails( false );
		QuestLog_UpdateMap();
 	end
	if WatchFrame:IsVisible() then		
		WatchFrame_Update()
 	end
end

function AJM:GetQuestLogIndexByName( questName )
	for iterateQuests = 1, GetNumQuestLogEntries() do
		local title, level, tag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle( iterateQuests )
		if isHeader == nil then
			if title == questName then
				return iterateQuests
			end
		end
	end
	return 0
end

function AJM:SelectQuestLogEntry( questIndex )
	AJM.currentlySelectedQuest =  L["(No Quest Selected)"]
	if questIndex ~= nil then
		local title, level, tag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle( questIndex )
		if isHeader == nil then
			if title ~= nil then
				AJM.currentlySelectedQuest = title
				if AJM.jambaQuestLogFrame:IsVisible() then
					if GetQuestLogPushable() == 1 and GetNumPartyMembers() > 0 then
						AJM.jambaQuestLogFrameShareButton:Enable()
					else
						AJM.jambaQuestLogFrameShareButton:Disable()
					end
				end
			end
		end
	end	
end

function AJM:IsCurrentlySelectedQuestValid()
	if AJM.currentlySelectedQuest:trim() ~= "" and AJM.currentlySelectedQuest ~= L["(No Quest Selected)"] then
		return true
	end
	return false	
end

function AJM:DoSelectQuestLogEntry( sender, questName, tag )
	if JambaApi.DoesCharacterHaveTag( AJM.characterName, tag ) == true then
		local questIndex = AJM:GetQuestLogIndexByName( questName )
		if questIndex ~= 0 then
			SelectQuestLogEntry( questIndex )
			AJM:UpdateQuestLog( questIndex )
		else
			AJM:JambaSendMessageToTeam( AJM.db.warningArea, L["I do not have the quest: A"]( questName ) )
		end		
	end
end

function AJM:DoQuestTrack( sender, questName, watch, tag )
	if JambaApi.DoesCharacterHaveTag( AJM.characterName, tag ) == true then
		local questIndex = AJM:GetQuestLogIndexByName( questName )
		if questIndex ~= 0 then
			if watch == 1 then
				AddQuestWatch( questIndex )
			else
				RemoveQuestWatch( questIndex )
			end
			AJM:UpdateQuestLog( questIndex )
		else
			AJM:JambaSendMessageToTeam( AJM.db.warningArea, L["I do not have the quest: A"]( questName ) )
		end		
	end
end

function AJM:DoAbandonQuest( sender, questName, tag )
	if JambaApi.DoesCharacterHaveTag( AJM.characterName, tag ) == true then
		local questIndex = AJM:GetQuestLogIndexByName( questName )
		if questIndex ~= 0 then
			SelectQuestLogEntry( questIndex )
			SetAbandonQuest()
			AbandonQuest()
			AJM:UpdateQuestLog( questIndex )
			AJM:JambaSendMessageToTeam( AJM.db.messageArea, L["I have abandoned the quest: A"]( questName ) )
		else
			AJM:JambaSendMessageToTeam( AJM.db.warningArea, L["I do not have the quest: A"]( questName ) )
		end		
	end
end

function AJM:DoAbandonAllQuests( sender, tag )
	if JambaApi.DoesCharacterHaveTag( AJM.characterName, tag ) == true then
		AJM.iterateQuests = 1
		if AJM.iterateQuests <= GetNumQuestLogEntries() then
			AJM:ScheduleTimer( "AbandonNextQuest", 1 )
		end
	end
end

function AJM:AutoSelectToggleCommand( info, parameters )
	local toggle, tag = strsplit( " ", parameters )
	if tag ~= nil and tag:trim() ~= "" then
		AJM:JambaSendCommandToTeam( AJM.COMMAND_TOGGLE_AUTO_SELECT, toggle, tag )
	else
		AJM:AutoSelectToggle( toggle )
	end	
end

function AJM:DoAutoSelectToggle( sender, toggle, tag )
	if JambaApi.DoesCharacterHaveTag( AJM.characterName, tag ) == true then
		AJM:AutoSelectToggle( toggle )
	end
end

function AJM:AutoSelectToggle( toggle )
	if toggle == L["toggle"] then
		if AJM.db.allAutoSelectQuests == true then
			toggle = L["off"]
		else
			toggle = L["on"]
		end
	end
	if toggle == L["on"] then
		AJM.db.mirrorMasterQuestSelectionAndDeclining = false
		AJM.db.allAutoSelectQuests = true
	elseif toggle == L["off"] then
		AJM.db.mirrorMasterQuestSelectionAndDeclining = true
		AJM.db.allAutoSelectQuests = false
	end
	AJM:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- COMMAND MANAGEMENT
-------------------------------------------------------------------------------------------------------------

-- A Jamba command has been recieved.
function AJM:JambaOnCommandReceived( characterName, commandName, ... )
	if commandName == AJM.COMMAND_TOGGLE_AUTO_SELECT then
		AJM:DoAutoSelectToggle( characterName, ... )
	end
	-- Want to action track and abandon command on the same character that sent the command.
	if commandName == AJM.COMMAND_QUEST_TRACK then
		AJM:DoQuestTrack( characterName, ... )
	end
	if commandName == AJM.COMMAND_ABANDON_QUEST then		
		AJM:DoAbandonQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_ABANDON_ALL_QUESTS then		
		AJM:DoAbandonAllQuests( characterName, ... )
	end
	-- If this character sent this command, don't action it.
	if characterName == AJM.characterName then
		return
	end
	if commandName == AJM.COMMAND_ACCEPT_QUEST then		
		AJM:DoAcceptQuest( characterName, ...  )
	end			
	if commandName == AJM.COMMAND_SELECT_GOSSIP_OPTION then		
		AJM:DoSelectGossipOption( characterName, ... )
	end
	if commandName == AJM.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST then		
		AJM:DoSelectGossipActiveQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST then		
		AJM:DoSelectGossipAvailableQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_SELECT_ACTIVE_QUEST then		
		AJM:DoSelectActiveQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_SELECT_AVAILABLE_QUEST then		
		AJM:DoSelectAvailableQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_DECLINE_QUEST then		
		AJM:DoDeclineQuest( characterName, ...  )
	end
	if commandName == AJM.COMMAND_COMPLETE_QUEST then		
		AJM:DoCompleteQuest( characterName, ... )
	end
	if commandName == AJM.COMMAND_CHOOSE_QUEST_REWARD then		
		AJM:DoChooseQuestReward( characterName, ... )
	end
	if commandName == AJM.COMMAND_SELECT_QUEST_LOG_ENTRY then
		AJM:DoSelectQuestLogEntry( characterName, ... )
	end
end
