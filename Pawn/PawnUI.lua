-- Pawn by Vger-Azjol-Nerub
-- See Readme.htm or Pawn.lua for more information.

------------------------------------------------------------


------------------------------------------------------------
-- Globals
------------------------------------------------------------

PawnUICurrentScale = nil
PawnUICurrentListIndex = 0
PawnUICurrentStatIndex = 0

-- An array with indices 1 and 2 for the left and right compare items, respectively; each one is of the type returned by GetItemData.
local PawnUIComparisonItems = {}
-- An array with indices 1 and 2 for the first and second left side shortcut items.
local PawnUIShortcutItems = {}

local PawnUITotalComparisonLines = 0

------------------------------------------------------------
-- "Constants"
------------------------------------------------------------

local PawnUIStatsListHeight = 12 -- the stats list contains 12 items
local PawnUIStatsListItemHeight = 16 -- each item is 16 pixels tall

local PawnUIComparisonLineHeight = 20 -- each comparison line is 20 pixels tall
local PawnUIComparisonAreaPaddingBottom = 10 -- add 10 pixels of padding to the bottom of the scrolling area

local PawnScaleColorDarkFactor = 0.75 -- the unenchanted color is 75% of the enchanted color


-- Returns true if the user is playing WoW 3.0 (Wrath of the Lich King).
function PawnIsWoW3()
	return (CLASS_BUTTONS["DEATHKNIGHT"] ~= nil)
end


------------------------------------------------------------
-- Inventory button
------------------------------------------------------------

-- Moves the Pawn inventory sheet button and inspect button to the location specified by the user's current preferences.
function PawnUI_InventoryPawnButton_Move()
	if PawnOptions.ButtonPosition == PawnButtonPositionRight then
		PawnUI_InventoryPawnButton:ClearAllPoints()
		PawnUI_InventoryPawnButton:SetPoint("TOPRIGHT", "CharacterTrinket1Slot", "BOTTOMRIGHT", -1, -8)
		PawnUI_InventoryPawnButton:Show()
		if PawnUI_InspectPawnButton then
			PawnUI_InspectPawnButton:ClearAllPoints()
			PawnUI_InspectPawnButton:SetPoint("TOPRIGHT", "InspectTrinket1Slot", "BOTTOMRIGHT", -1, -8)
			PawnUI_InspectPawnButton:Show()
		end
	elseif PawnOptions.ButtonPosition == PawnButtonPositionLeft then
		PawnUI_InventoryPawnButton:ClearAllPoints()
		PawnUI_InventoryPawnButton:SetPoint("TOPLEFT", "CharacterWristSlot", "BOTTOMLEFT", 1, -8)
		PawnUI_InventoryPawnButton:Show()
		if PawnUI_InspectPawnButton then
			PawnUI_InspectPawnButton:ClearAllPoints()
			PawnUI_InspectPawnButton:SetPoint("TOPLEFT", "InspectWristSlot", "BOTTOMLEFT", 1, -8)
			PawnUI_InspectPawnButton:Show()
		end
	else
		PawnUI_InventoryPawnButton:Hide()
		if PawnUI_InspectPawnButton then
			PawnUI_InspectPawnButton:Hide()
		end
	end
end

function PawnUI_InventoryPawnButton_OnEnter(this)
	-- Even if there are no scales, we'll at least display this much.
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine("Pawn", 1, 1, 1, 1)
	GameTooltip:AddLine(PawnUI_InventoryPawnButton_Tooltip, nil, nil, nil, 1)

	-- If the user has at least one scale and at least one type of value is enabled, calculate a total of all equipped items' values.
	PawnUI_AddInventoryTotalsToTooltip(GameTooltip, "player")
	
	-- Finally, display the tooltip.
	GameTooltip:Show()
end

function PawnUI_InspectPawnButton_OnEnter(this)
	-- Even if there are no scales, we'll at least display this much.
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine("Pawn", 1, 1, 1, 1)

	-- If the user has at least one scale and at least one type of value is enabled, calculate a total of all equipped items' values.
	PawnUI_AddInventoryTotalsToTooltip(GameTooltip, "playertarget")
	
	-- Finally, display the tooltip.
	GameTooltip:Show()
end

function PawnUI_AddInventoryTotalsToTooltip(Tooltip, Unit)
	if PawnOptions.ShowUnenchanted or PawnOptions.ShowEnchanted then
		-- Get the total stats for all items.
		local ItemValues, Count = PawnGetInventoryItemValues(Unit)
		if Count > 0 then
			Tooltip:AddLine(" ")
			Tooltip:AddLine(PawnUI_InventoryPawnButton_Subheader, 1, 1, 1, 1)
			PawnAddValuesToTooltip(Tooltip, ItemValues, true)
		end
	end
end

function PawnUI_InspectPawnButton_Attach()
	VgerCore.Assert(InspectPaperDollFrame ~= nil, "InspectPaperDollFrame should be loaded by now!")
	CreateFrame("Button", "PawnUI_InspectPawnButton", InspectPaperDollFrame, "PawnUI_InspectPawnButtonTemplate")
	PawnUI_InspectPawnButton:SetParent(InspectPaperDollFrame)
	PawnUI_InventoryPawnButton_Move()
end

------------------------------------------------------------
-- Scales tab events
------------------------------------------------------------

-- When CurrentScaleDropDown is first shown, it needs to be initialized.
local PawnUIFrame_CurrentScaleDropDown_IsInitialized = false
function PawnUIFrame_CurrentScaleDropDown_OnShow()
	if PawnUIFrame_CurrentScaleDropDown_IsInitialized then return end
	PawnUIFrame_CurrentScaleDropDown_IsInitialized = true
	
	if PawnIsWoW3() then
		-- *** WoW 3.0 version
		UIDropDownMenu_SetWidth(PawnUIFrame_CurrentScaleDropDown, 130)
		UIDropDownMenu_SetWidth(PawnUIFrame_CurrentCompareScaleDropDown, 130)
	else
		-- *** WoW 2.4 version
		UIDropDownMenu_SetWidth(130, PawnUIFrame_CurrentScaleDropDown)
		UIDropDownMenu_SetWidth(130, PawnUIFrame_CurrentCompareScaleDropDown)
	end
	PawnUIFrame_CurrentScaleDropDown_Reset()
end

-- Resets CurrentScaleDropDown.
function PawnUIFrame_CurrentScaleDropDown_Reset()
	PawnUICurrentScale = nil
	UIDropDownMenu_Initialize(PawnUIFrame_CurrentScaleDropDown, PawnUIFrame_CurrentScaleDropDown_Initialize)
	UIDropDownMenu_Initialize(PawnUIFrame_CurrentCompareScaleDropDown, PawnUIFrame_CurrentScaleDropDown_Initialize)
end

-- Selects a scale in CurrentScaleDropDown.
function PawnUIFrame_CurrentScaleDropDown_SelectScale(ScaleName)
	-- Close popup UI as necessary.
	PawnUIStringDialog:Hide()
	ColorPickerFrame:Hide()
	-- Select the scale.
	PawnUICurrentScale = ScaleName
	UIDropDownMenu_SetSelectedName(PawnUIFrame_CurrentScaleDropDown, ScaleName)
	UIDropDownMenu_SetSelectedName(PawnUIFrame_CurrentCompareScaleDropDown, ScaleName)
	-- After selecting a new scale, update the rest of the UI.
	PawnUIFrame_StatsList_Update()
	PawnUIFrame_StatsList_SelectStat(PawnUICurrentStatIndex)
	PawnUIFrame_ScaleColorSwatch_Update()
	PawnUIFrame_ShowScaleCheck_Update()
	PawnUI_CompareItems()
end

-- Function used by the UIDropDownMenu code to initialize CurrentScaleDropDown.
function PawnUIFrame_CurrentScaleDropDown_Initialize()
	local Item = {}
	Item.func = PawnUIFrame_CurrentScaleDropDown_ItemClicked
	
	-- Add each scale to the dropdown.
	local FirstScale = nil
	local NewSelectedScale = nil
	for _, ScaleName in pairs(PawnGetAllScales()) do
		if ScaleName == PawnUICurrentScale then NewSelectedScale = ScaleName end
		if not FirstScale then FirstScale = ScaleName end
		Item.text = ScaleName
		UIDropDownMenu_AddButton(Item)
	end
	if not FirstScale then
		FirstScale = PawnUINoScale
		Item.text = PawnUINoScale
		UIDropDownMenu_AddButton(Item)
		PawnUIFrame_CopyScaleButton:Disable()
		PawnUIFrame_RenameScaleButton:Disable()
		PawnUIFrame_DeleteScaleButton:Disable()
		PawnUIFrame_ExportScaleButton:Disable()
	else
		PawnUIFrame_CopyScaleButton:Enable()
		PawnUIFrame_RenameScaleButton:Enable()
		PawnUIFrame_DeleteScaleButton:Enable()
		PawnUIFrame_ExportScaleButton:Enable()
	end

	if NewSelectedScale then	
		PawnUICurrentScale = NewSelectedScale
	else
		-- If the scale that they previously selected isn't in the list, or they didn't have a previously-selected
		-- scale, just select the first one.
		PawnUICurrentScale = FirstScale
	end
	PawnUIFrame_CurrentScaleDropDown_SelectScale(PawnUICurrentScale)
end

function PawnUIFrame_CurrentScaleDropDown_ItemClicked(self)
	if self then
		-- *** WoW 3.0 version
	else
		-- *** WoW 2.x version
		self = this
	end
	PawnUIGetStringCancel()
	PawnUIFrame_CurrentScaleDropDown_SelectScale(self:GetText())
end

function PawnUIFrame_ImportScaleButton_OnClick()
	PawnUIImportScale()
end

function PawnUIFrame_NewScaleButton_OnClick()
	PawnUIGetString(PawnLocal.NewScaleEnterName, "", PawnUIFrame_NewScale_OnOK)
end

function PawnUIFrame_NewScale_OnOK(NewScaleName)
	-- Does this scale already exist?
	if NewScaleName == PawnUINoScale then
		PawnUIGetString(PawnLocal.NewScaleEnterName, "", PawnUIFrame_NewScale_OnOK)
		return
	elseif string.find(NewScaleName, "\"") then
		PawnUIGetString(PawnLocal.NewScaleNoQuotes, NewScaleName, PawnUIFrame_NewScale_OnOK)
	elseif PawnDoesScaleExist(NewScaleName) then
		PawnUIGetString(PawnLocal.NewScaleDuplicateName, NewScaleName, PawnUIFrame_NewScale_OnOK)
		return
	end
	
	-- Add and select the scale.
	PawnAddEmptyScale(NewScaleName)
	PawnUIFrame_CurrentScaleDropDown_Reset()
	PawnUIFrame_CurrentScaleDropDown_SelectScale(NewScaleName)
end

function PawnUIFrame_NewScaleFromDefaultsButton_OnClick()
	PawnUIGetString(PawnLocal.NewScaleEnterName, "", PawnUIFrame_NewScaleFromDefaults_OnOK)
end

function PawnUIFrame_NewScaleFromDefaults_OnOK(NewScaleName)
	-- Does this scale already exist?
	if NewScaleName == PawnUINoScale then
		PawnUIGetString(PawnLocal.NewScaleEnterName, "", PawnUIFrame_NewScaleFromDefaults_OnOK)
		return
	elseif string.find(NewScaleName, "\"") then
		PawnUIGetString(PawnLocal.NewScaleNoQuotes, NewScaleName, PawnUIFrame_NewScaleFromDefaults_OnOK)
	elseif PawnDoesScaleExist(NewScaleName) then
		PawnUIGetString(PawnLocal.NewScaleDuplicateName, NewScaleName, PawnUIFrame_NewScaleFromDefaults_OnOK)
		return
	end
	
	-- Add and select the scale.
	PawnAddDefaultScale(NewScaleName)
	PawnUIFrame_CurrentScaleDropDown_Reset()
	PawnUIFrame_CurrentScaleDropDown_SelectScale(NewScaleName)
end

function PawnUIFrame_ExportScaleButton_OnClick()
	PawnUIExportScale(PawnUICurrentScale)
end

function PawnUIFrame_RenameScaleButton_OnClick()
	PawnUIGetString(string.format(PawnLocal.RenameScaleEnterName, PawnUICurrentScale), PawnUICurrentScale, PawnUIFrame_RenameScale_OnOK)
end

function PawnUIFrame_CopyScaleButton_OnClick()
	PawnUIGetString(string.format(PawnLocal.CopyScaleEnterName, PawnUICurrentScale), "", PawnUIFrame_CopyScale_OnOK)
end

-- Shows a dialog where the user can copy a scale tag for a given scale to the clipboard.
-- Immediately returns true if successful, or false if not.
function PawnUIExportScale(ScaleName)
	local ScaleTag = PawnGetScaleTag(ScaleName)
	if ScaleTag then
		PawnUIShowCopyableString(string.format(PawnLocal.ExportScaleMessage, ScaleName), ScaleTag)
		return true
	else
		return false
	end
end

-- Shows a dialog where the user can paste a scale tag from the clipboard.
-- Immediately returns.
function PawnUIImportScale()
	PawnUIGetString(PawnLocal.ImportScaleMessage, "", PawnUIImportScaleCallback)
end

-- Callback function for PawnUIImportScale.
function PawnUIImportScaleCallback(ScaleTag)
	-- Try to import the scale.  If successful, we don't need to do anything else.
	local Status, ScaleName = PawnImportScale(ScaleTag, true) -- allow overwriting a scale with the same name
	if Status == PawnImportScaleResultSuccess then
		if PawnUIFrame_CurrentScaleDropDown_Reset then
			-- Select the new scale if the UI is up.
			PawnUIFrame_CurrentScaleDropDown_Reset()
			PawnUIFrame_CurrentScaleDropDown_SelectScale(ScaleName)
		end
		return
	end
	
	-- If there was a problem, show an error message or reshow the dialog as appropriate.
	if Status == PawnImportScaleResultAlreadyExists then
		VgerCore.Message(VgerCore.Color.Salmon .. string.format(PawnLocal.ImportScaleAlreadyExistsMessage, ScaleName))
		return
	end
	if Status == PawnImportScaleResultTagError then
		-- Don't use the tag that was pasted as the default value; it makes it harder to paste.
		PawnUIGetString(PawnLocal.ImportScaleTagErrorMessage, "", PawnUIImportScaleCallback)
		return
	end
	
	VgerCore.Fail("Unexpected PawnImportScaleResult value: " .. tostring(Status))
end

function PawnUIFrame_RenameScale_OnOK(NewScaleName)
	-- Did they change anything?
	if NewScaleName == PawnUICurrentScale then return end
	
	-- Does this scale already exist?
	if NewScaleName == PawnUINoScale then
		PawnUIGetString(string.format(PawnLocal.RenameScaleEnterName, PawnUICurrentScale), PawnUICurrentScale, PawnUIFrame_RenameScale_OnOK)
		return
	elseif string.find(NewScaleName, "\"") then
		PawnUIGetString(PawnLocal.NewScaleNoQuotes, NewScaleName, PawnUIFrame_RenameScale_OnOK)
	elseif PawnDoesScaleExist(NewScaleName) then
		PawnUIGetString(PawnLocal.NewScaleDuplicateName, PawnUICurrentScale, PawnUIFrame_RenameScale_OnOK)
		return
	end
	
	-- Rename and select the scale.
	PawnRenameScale(PawnUICurrentScale, NewScaleName)
	PawnUIFrame_CurrentScaleDropDown_Reset()
	PawnUIFrame_CurrentScaleDropDown_SelectScale(NewScaleName)
end

function PawnUIFrame_CopyScale_OnOK(NewScaleName)
	-- Does this scale already exist?
	if NewScaleName == PawnUINoScale then
		PawnUIGetString(PawnLocal.CopyScaleEnterName, "", PawnUIFrame_CopyScale_OnOK)
		return
	elseif string.find(NewScaleName, "\"") then
		PawnUIGetString(PawnLocal.NewScaleNoQuotes, NewScaleName, PawnUIFrame_CopyScale_OnOK)
	elseif PawnDoesScaleExist(NewScaleName) then
		PawnUIGetString(PawnLocal.NewScaleDuplicateName, NewScaleName, PawnUIFrame_CopyScale_OnOK)
		return
	end
	
	-- Create the new scale.
	PawnDuplicateScale(PawnUICurrentScale, NewScaleName)
	PawnUIFrame_CurrentScaleDropDown_Reset()
	PawnUIFrame_CurrentScaleDropDown_SelectScale(NewScaleName)
end

function PawnUIFrame_DeleteScaleButton_OnClick()
	PawnUIGetString(string.format(PawnLocal.DeleteScaleConfirmation, PawnUICurrentScale, DELETE_ITEM_CONFIRM_STRING), "", PawnUIFrame_DeleteScaleButton_OnOK)
end

function PawnUIFrame_DeleteScaleButton_OnOK(ConfirmationText)
	-- If they didn't type "DELETE" (ignoring case), just exit.
	if string.lower(ConfirmationText) ~= string.lower(DELETE_ITEM_CONFIRM_STRING) then return end
	
	PawnDeleteScale(PawnUICurrentScale)
	PawnUICurrentScale = nil
	PawnUIFrame_CurrentScaleDropDown_Reset()
end

function PawnUIFrame_StatsList_Update()
	if not PawnStats then return end
	
	-- First, update the control and get our new offset.
	FauxScrollFrame_Update(PawnUIFrame_StatsList, #PawnStats, PawnUIStatsListHeight, PawnUIStatsListItemHeight) -- list, number of items, number of items visible per page, item height
	local Offset = FauxScrollFrame_GetOffset(PawnUIFrame_StatsList)
	
	-- Then, update the list items as necessary.
	local ThisScale
	if PawnUICurrentScale ~= PawnUINoScale then ThisScale = PawnGetAllStatValues(PawnUICurrentScale) end
	local i
	for i = 1, PawnUIStatsListHeight do
		local Index = i + Offset
		PawnUIFrame_StatsList_UpdateStatItem(i, Index, ThisScale)
	end
	
	-- After the user scrolled, we need to adjust their selection.
	PawnUIFrame_StatsList_MoveHighlight()
	
end

-- Updates a single stat in the list based on its index into the PawnStats table.
function PawnUIFrame_StatsList_UpdateStat(Index)
	local Offset = FauxScrollFrame_GetOffset(PawnUIFrame_StatsList)
	local i = Index - Offset
	if i <= 0 or i > PawnUIStatsListHeight then return end
	
	PawnUIFrame_StatsList_UpdateStatItem(i, Index, PawnGetAllStatValues(PawnUICurrentScale))	
end

-- Updates a single stat in the list.
function PawnUIFrame_StatsList_UpdateStatItem(i, Index, ThisScale)
	local Title = PawnStats[Index][1]
	local ThisStat = PawnStats[Index][2]
	local Line = getglobal("PawnUIFrame_StatsList_Item" .. i)
	
	if Index <= #PawnStats then
		if not ThisStat then
			-- This is a header row.
			Line:SetText(Title)
			if Line.SetTextFontObject then
				-- *** WoW 2.4 version
				Line:SetTextFontObject("PawnFontBlue")
				Line:SetHighlightFontObject("PawnFontBlue")
			else
				-- *** WoW 3.0 version
				Line:SetNormalFontObject("PawnFontBlue")
				Line:SetHighlightFontObject("PawnFontBlue")
			end
			Line:Disable()
		elseif ThisScale and ThisScale[ThisStat] then
			-- This is a stat that's in the current scale.
			Line:SetText("  " .. Title .. " = " .. string.format("%g", ThisScale[ThisStat]))
			if Line.SetTextFontObject then
				-- *** WoW 2.4 version
				Line:SetTextFontObject("GameFontHighlight")
				Line:SetHighlightFontObject("GameFontHighlight")
			else
				-- *** WoW 3.0 version
				Line:SetNormalFontObject("GameFontHighlight")
				Line:SetHighlightFontObject("GameFontHighlight")
			end
			Line:Enable()
		else
			-- This is a stat that's not in the current scale.
			Line:SetText("  " .. Title)
			if Line.SetTextFontObject then
				-- *** WoW 2.4 version
				Line:SetTextFontObject("PawnFontSilver")
				Line:SetHighlightFontObject("GameFontHighlight")
			else
				-- *** WoW 3.0 version
				Line:SetNormalFontObject("PawnFontSilver")
				Line:SetHighlightFontObject("GameFontHighlight")
			end
			Line:Enable()
		end
		Line:Show()
	else
		Line:Hide()
	end
end

-- Adjusts PawnUICurrentListIndex and the position of the highlight based on PawnUICurrentStatIndex.
function PawnUIFrame_StatsList_MoveHighlight()
	-- If no stat is selected, just hide the highlight.
	if not PawnUICurrentStatIndex or PawnUICurrentStatIndex == 0 then
		PawnUICurrentListIndex = 0
		PawnUIFrame_StatsList_HighlightFrame:Hide()
		return
	end
	
	-- Otherwise, see if we need to draw a highlight.  If the selected stat isn't visible, we shouldn't draw anything.
	local Offset = FauxScrollFrame_GetOffset(PawnUIFrame_StatsList)
	local i = PawnUICurrentStatIndex - Offset
	if i <= 0 or i > PawnUIStatsListHeight then
		PawnUICurrentListIndex = 0
		PawnUIFrame_StatsList_HighlightFrame:Hide()
		return
	end
	
	-- If we made it this far, then we need to draw a highlight.
	PawnUICurrentListIndex = i
	PawnUIFrame_StatsList_HighlightFrame:ClearAllPoints()
	PawnUIFrame_StatsList_HighlightFrame:SetPoint("TOPLEFT", "PawnUIFrame_StatsList_Item" .. i, "TOPLEFT", 0, 0)
	PawnUIFrame_StatsList_HighlightFrame:Show()
end

-- This is the click handler for list item #i.
function PawnUIFrame_StatsList_OnClick(i)
	if not i or i <= 0 or i > PawnUIStatsListHeight then return end
	
	local Offset = FauxScrollFrame_GetOffset(PawnUIFrame_StatsList)
	local Index = i + Offset
	
	PawnUIFrame_StatsList_SelectStat(Index)
end

function PawnUIFrame_StatsList_SelectStat(Index)
	-- First, make sure that the stat is in the correct range.
	if not Index or Index < 0 or Index > #PawnStats then
		Index = 0
	end
	
	-- Then, find out what they've clicked on.
	local Title, ThisStat, ThisDescription, ThisPrompt
	if Index > 0 then
		Title = PawnStats[Index][1]
		ThisStat = PawnStats[Index][2]
		if ThisStat then
			-- This is a stat, not a header row.
		else
			-- This is a header row, or empty space.
			Index = 0
		end
	end
	PawnUICurrentStatIndex = Index
		
	-- Show, move, or hide the highlight as appropriate.
	PawnUIFrame_StatsList_MoveHighlight()
	
	-- Finally, change the UI to the right.
	local ThisScale
	if PawnUICurrentScale ~= PawnUINoScale then ThisScale = PawnGetAllStatValues(PawnUICurrentScale) end
	if Index > 0 and ThisScale then
		-- They've selected a stat.
		ThisDescription = PawnStats[Index][3]
		PawnUIFrame_DescriptionLabel:SetText(ThisDescription)
		ThisPrompt = PawnStats[Index][4]
		if ThisPrompt then
			PawnUIFrame_StatNameLabel:SetText(ThisPrompt)
		else
			PawnUIFrame_StatNameLabel:SetText(string.format(PawnLocal.StatNameText, Title))
		end
		PawnUIFrame_StatNameLabel:Show()
		local ThisScaleValue = ThisScale[ThisStat]
		if not ThisScaleValue or ThisScaleValue == 0 then ThisScaleValue = "" else ThisScaleValue = tostring(ThisScaleValue) end
		PawnUIFrame_StatValueBox.SettingValue = (PawnUIFrame_StatValueBox:GetText() ~= ThisScaleValue)
		PawnUIFrame_StatValueBox:SetText(ThisScaleValue)
		PawnUIFrame_StatValueBox:Show()
		PawnUIFrame_ClearValueButton:Show()
		if ThisStat == "RedSocket" or ThisStat == "YellowSocket" or ThisStat == "BlueSocket" then
			PawnUIFrame_ScaleSocketOptionsList_UpdateSelection()
			PawnUIFrame_ScaleSocketOptionsList:Show()
		else
			PawnUIFrame_ScaleSocketOptionsList:Hide()
		end
	elseif PawnUICurrentScale == PawnUINoScale then
		-- They don't have any scales.
		PawnUIFrame_DescriptionLabel:SetText(PawnLocal.NoScalesDescription)
		PawnUIFrame_StatNameLabel:Hide()
		PawnUIFrame_StatValueBox:Hide()
		PawnUIFrame_ClearValueButton:Hide()
		PawnUIFrame_ScaleSocketOptionsList:Hide()
	else
		-- They haven't selected a stat.
		PawnUIFrame_DescriptionLabel:SetText(PawnLocal.NoStatDescription)
		PawnUIFrame_StatNameLabel:Hide()
		PawnUIFrame_StatValueBox:Hide()
		PawnUIFrame_ClearValueButton:Hide()
		PawnUIFrame_ScaleSocketOptionsList:Hide()
	end

end

function PawnUIFrame_StatValueBox_OnTextChanged()
	local NewString = string.gsub(PawnUIFrame_StatValueBox:GetText(), ",", ".")
	local NewValue = tonumber(NewString)
	if NewValue == 0 then NewValue = nil end
	
	if NewValue then
		PawnUIFrame_ClearValueButton:Enable()
	else
		PawnUIFrame_ClearValueButton:Disable()
	end
	
	-- If other code is setting this value, we should ignore this event and not set any values.
	if PawnUIFrame_StatValueBox.SettingValue then
		PawnUIFrame_StatValueBox.SettingValue = false
		return
	end
	PawnSetStatValue(PawnUICurrentScale, PawnStats[PawnUICurrentStatIndex][2], NewValue)
	PawnUIFrame_StatsList_UpdateStat(PawnUICurrentStatIndex)
end

function PawnUIFrame_ClearValueButton_OnClick()
	PawnUIFrame_StatValueBox:SetText("")
end

function PawnUIFrame_GetCurrentScaleColor()
	local r, g, b
	if PawnUICurrentScale and PawnUICurrentScale ~= PawnUINoScale then r, g, b = VgerCore.HexToRGB(PawnOptions.Scales[PawnUICurrentScale].Color) end
	if not r then
		r, g, b = VgerCore.Color.BlueR, VgerCore.Color.BlueG, VgerCore.Color.BlueB
	end
	return r, g, b
end

function PawnUIFrame_ScaleColorSwatch_OnClick()
	-- Get the color of the current scale.
	local r, g, b = PawnUIFrame_GetCurrentScaleColor()
	ColorPickerFrame.func = PawnUIFrame_ScaleColorSwatch_OnChange
	ColorPickerFrame.cancelFunc = PawnUIFrame_ScaleColorSwatch_OnCancel
	ColorPickerFrame.previousValues = { r, g, b }
	ColorPickerFrame.hasOpacity = false
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame:SetFrameStrata("HIGH")
	ColorPickerFrame:Show()
end

function PawnUIFrame_ScaleColorSwatch_OnChange()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	PawnUIFrame_ScaleColorSwatch_SetColor(r, g, b)
end

function PawnUIFrame_ScaleColorSwatch_OnCancel(rgb)
	local r, g, b = unpack(rgb)
	PawnUIFrame_ScaleColorSwatch_SetColor(r, g, b)
end

function PawnUIFrame_ScaleColorSwatch_SetColor(r, g, b)
	PawnOptions.Scales[PawnUICurrentScale].Color = VgerCore.RGBToHex(r, g, b)
	PawnOptions.Scales[PawnUICurrentScale].UnenchantedColor = VgerCore.RGBToHex(r * PawnScaleColorDarkFactor, g * PawnScaleColorDarkFactor, b * PawnScaleColorDarkFactor)
	PawnUIFrame_ScaleColorSwatch_Update()
	PawnResetTooltips()
end

function PawnUIFrame_ScaleColorSwatch_Update()
	if PawnUICurrentScale ~= PawnUINoScale then
		local r, g, b = PawnUIFrame_GetCurrentScaleColor()
		PawnUIFrame_ScaleColorSwatch_Color:SetTexture(r, g, b)
		PawnUIFrame_ScaleColorSwatch_Label:Show()
		PawnUIFrame_ScaleColorSwatch:Show()
	else
		PawnUIFrame_ScaleColorSwatch_Label:Hide()
		PawnUIFrame_ScaleColorSwatch:Hide()
	end
end

function PawnUIFrame_ShowScaleCheck_Update()
	if PawnUICurrentScale ~= PawnUINoScale then
		PawnUIFrame_ShowScaleCheck:SetChecked(PawnIsScaleVisible(PawnUICurrentScale))
		PawnUIFrame_ShowScaleCheck:Show()
	else
		PawnUIFrame_ShowScaleCheck:Hide()
	end
end

function PawnUIFrame_ShowScaleCheck_OnClick()
	PawnSetScaleVisible(PawnUICurrentScale, PawnUIFrame_ShowScaleCheck:GetChecked())
end

function PawnUIFrame_ScaleSocketOptionsList_SetSelection(Value)
	if PawnUICurrentScale == PawnUINoScale then return end
	if not PawnOptions.Scales[PawnUICurrentScale] then return end
	PawnOptions.Scales[PawnUICurrentScale].SmartGemSocketing = Value
	PawnUIFrame_ScaleSocketOptionsList_UpdateSelection()
	PawnResetTooltips()
end

function PawnUIFrame_ScaleSocketOptionsList_UpdateSelection()
	if PawnUICurrentScale == PawnUINoScale then return end
	if not PawnOptions.Scales[PawnUICurrentScale] then return end
	
	local SmartGemSocketing = PawnOptions.Scales[PawnUICurrentScale].SmartGemSocketing
	PawnUIFrame_ScaleSocketBestRadio:SetChecked(SmartGemSocketing)
	PawnUIFrame_ScaleSocketCorrectRadio:SetChecked(not SmartGemSocketing)
end

------------------------------------------------------------
-- Compare tab
------------------------------------------------------------

-- Initializes the Compare tab if it hasn't already been initialized.
local PawnUI_CompareTabInitialized
function PawnUI_InitCompareTab()
	-- This only needs to be run once.
	if PawnUI_CompareTabInitialized then return end
	PawnUI_CompareTabInitialized = true
	
	-- All the Compare tab needs to do here is clear out the comparison items.  Initializing the dropdown
	-- is actually covered by existing code.
	PawnUI_ClearCompareItems()
end

-- Sets either the left (index 1) or right (index 2) comparison item, using an item link.  If the passed item
-- link is nil, that comparison item is instead cleared out.  Returns true if an item was actually placed in the
-- slot or cleared from the slot.
function PawnUI_SetCompareItem(Index, ItemLink)
	PawnUI_InitCompareTab()
	if Index ~= 1 and Index ~= 2 then
		VgerCore.Fail("Index must be 1 or 2.")
		return
	end
	
	-- Get the item data for this item link; we can't do a comparison without it.
	local Item
	if ItemLink then
		-- If they passed item data instead of an item link, just use that.  Otherwise, get item data from the link.
		if type(ItemLink) == "table" then
			Item = ItemLink
			ItemLink = Item.Link
			if not ItemLink then
				VgerCore.Fail("Second parameter must be an item link or item data from PawnGetItemData.")
				return
			end
		else
			-- Unenchant the item link.
			local UnenchantedLink = PawnUnenchantItemLink(ItemLink)
			if UnenchantedLink then ItemLink = UnenchantedLink end
			Item = PawnGetItemData(ItemLink)
			VgerCore.Assert(Item, "Failed to get item data while setting an comparison item!")
		end
	end
	local ItemName, ItemRarity, ItemEquipLoc, ItemTexture
	local SlotID1, SlotID2
	if ItemLink then
		ItemName, _, ItemRarity, _, _, _, _, _, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
		SlotID1, SlotID2 = PawnGetSlotsForItemType(ItemEquipLoc)
	else
		ItemName = PawnUIFrame_VersusHeader_NoItem
		ItemRarity = 0
	end
	
	-- Items that are not equippable cannot be placed in the Compare slots.
	if ItemLink and SlotID1 == nil and SlotID2 == nil then return end
	
	-- Save the item data locally, in case the item is later removed from the main Pawn item cache.
	PawnUIComparisonItems[Index] = Item
	
	-- Now, update the item name and icon.
	local Label = getglobal("PawnUICompareItemName" .. Index)
	local Texture = getglobal("PawnUICompareItemIconTexture" .. Index)
	Label:SetText(ItemName)
	local Color = ITEM_QUALITY_COLORS[ItemRarity]
	if (not Color) and ItemRarity == 7 then
		-- *** Workaround: ITEM_QUALITY_COLORS does not have a [7] in the current Wrath build.
		Color = { r = .9, g = .8, b = .5 }
	end
	if Color then Label:SetVertexColor(Color.r, Color.g, Color.b) end
	Texture:SetTexture(ItemTexture)
	
	-- If this item is a different type than the existing item, clear out the existing item.
	if ItemLink then
		local OtherIndex
		if Index == 1 then OtherIndex = 2 else OtherIndex = 1 end
		if PawnUIComparisonItems[OtherIndex] then
			_, _, _, _, _, _, _, _, OtherItemEquipLoc = GetItemInfo(PawnUIComparisonItems[OtherIndex].Link)
			local OtherSlotID1, OtherSlotID2 = PawnGetSlotsForItemType(OtherItemEquipLoc)
			if not (
				(SlotID1 == nil and SlotID2 == nil and OtherSlotID1 == nil and OtherSlotID2 == nil) or
				(SlotID1 and (SlotID1 == OtherSlotID1 or SlotID1 == OtherSlotID2)) or
				(SlotID2 and (SlotID2 == OtherSlotID1 or SlotID2 == OtherSlotID2))
			) then
				PawnUI_SetCompareItem(OtherIndex, nil)
			end
		end	
	end
	
	-- Update the item shortcuts.  The item shortcuts appear on the left side, but they're based on what's equipped on
	-- the right side.
	if Index == 2 then
		PawnUI_SetShortcutItemForSlot(1, SlotID1)
		PawnUI_SetShortcutItemForSlot(2, SlotID2)
	end
	
	-- Finally, either compare the two items, or remove the current comparison, whichever is appropriate.
	PawnUI_CompareItems()
	
	-- Return true to indicate success to the caller.
	return true
end

-- Same as PawnUI_SetCompareItem, but shows the Pawn Compare UI if not already visible.
function PawnUI_SetCompareItemAndShow(Index, ItemLink)
	if Index ~= 1 and Index ~= 2 then
		VgerCore.Fail("Index must be 1 or 2.")
		return
	end
	if not ItemLink or PawnGetHyperlinkType(ItemLink) ~= "item" then return end
	
	-- Set this as a compare item.
	local Success = PawnUI_SetCompareItem(Index, ItemLink)
	if Success then
		-- Automatically pick a comparison item when possible.
		PawnUI_AutoCompare()
		
		-- If the Pawn Compare UI is not visible, show it.
		if not PawnUIFrame:IsShown() then
			PawnUIShow()
			PawnUISwitchToTab(2)
		elseif not PawnUICompareTabPage:IsShown() then
			PlaySound("igCharacterInfoTab")
			PawnUISwitchToTab(2)
		else
			PlaySound("igMainMenuOptionCheckBoxOn")
		end
	end
	
	return Success
end

-- If there is an item in slot 2 and nothing in slot 1, and the player has an item equipped in the proper slot, automatically
-- compare the slot 2 item with the equipped item.
function PawnUI_AutoCompare()
	if PawnUIComparisonItems[2] and not PawnUIComparisonItems[1] and (PawnUIShortcutItems[1] or PawnUIShortcutItems[2]) then
		-- Normally, use the first shortcut.  But, if the first shortcut is missing or matches the item just compared, use the second
		-- shortcut item instead.
		local ShortcutToUse = PawnUIShortcutItems[1]
		if (not PawnUIShortcutItems[1]) or (PawnUIShortcutItems[2] and (PawnUIShortcutItems[1].Link == PawnUIComparisonItems[2].Link)) then
			ShortcutToUse = PawnUIShortcutItems[2]
		end
		-- Don't bother with an auto-comparison at all if the best item we found was the same item.
		if ShortcutToUse.Link ~= PawnUIComparisonItems[2].Link then
			PawnUI_SetCompareItem(1, ShortcutToUse)
		end
	end
end

-- Tries to set one of the compare items based on what the user is currently hovering over.  Meant for keybindings.
function PawnUI_SetCompareFromHover(Index)
	PawnUI_SetCompareItemAndShow(Index, PawnLastHoveredItem)
end

-- Enables or disables one of the "currently equipped" shortcut buttons based on an inventory slot ID.  If there is an item in that
-- slot, that item will appear in the shortcut button.  If not, or if Slot is nil, that shortcut button will be hidden.
function PawnUI_SetShortcutItemForSlot(ShortcutIndex, Slot)
	if ShortcutIndex ~= 1 and ShortcutIndex ~= 2 then
		VgerCore.Fail("ShortcutIndex must be 1 or 2.")
		return
	end

	-- Find the currently equipped inventory item, and save it for later.
	local ButtonName = "PawnUICompareItemShortcut" .. ShortcutIndex
	local ShortcutButton = getglobal(ButtonName)
	local CurrentlyEquippedItem
	if Slot then CurrentlyEquippedItem = PawnGetItemDataForInventorySlot(Slot, true) end
	PawnUIShortcutItems[ShortcutIndex] = CurrentlyEquippedItem
	
	-- Now, update the button.
	if CurrentlyEquippedItem then
		-- There is a currently equipped item to put in this slot; get information about it.
		local Texture = getglobal(ButtonName .. "Texture")
		local _, _, _, _, _, _, _, _, _, ItemTexture = GetItemInfo(CurrentlyEquippedItem.Link)
		Texture:SetTexture(ItemTexture)
		ShortcutButton:Show()
	else
		ShortcutButton:Hide()
	end
end

-- Clears both comparison items and all comparison data.
function PawnUI_ClearCompareItems()
	PawnUI_SetCompareItem(1, nil)
	PawnUI_SetCompareItem(2, nil)
end

-- Swaps the left and right comparison items.
function PawnUI_SwapCompareItems()
	local Item1, Item2 = PawnUIComparisonItems[1], PawnUIComparisonItems[2]
	PlaySound("igMainMenuOptionCheckBoxOn")
	-- Set the right item to nil first so that unnecessary comparisons aren't performed.
	PawnUI_SetCompareItem(2, nil)
	PawnUI_SetCompareItem(1, Item2)
	PawnUI_SetCompareItem(2, Item1)
end

-- Performs an item comparison.  If the item in either index 1 or index 2 is currently empty, no
-- item comparison is made and the function silently exits.
function PawnUI_CompareItems()
	-- Before doing anything else, clear out the existing comparison data.
	PawnUICompareItemScore1:SetText("")
	PawnUICompareItemScore2:SetText("")
	PawnUICompareItemScoreDifference1:SetText("")
	PawnUICompareItemScoreDifference2:SetText("")
	PawnUICompareItemScoreHighlight1:Hide()
	PawnUICompareItemScoreHighlight2:Hide()
	PawnUIFrame_CompareSwapButton:Hide()
	PawnUI_DeleteComparisonLines()
	
	-- There must be a scale selected to perform a comparison.
	if (not PawnUICurrentScale) or (PawnUICurrentScale == PawnUINoScale) then return end

	-- There must be two valid comparison items set to perform a comparison.
	local Item1, Item2 = PawnUIComparisonItems[1], PawnUIComparisonItems[2]
	if Item1 or Item2 then PawnUIFrame_CompareSwapButton:Show() end
	if (not Item1) or (not Item2) then return end

	-- We have two comparison items set.  Do the compare!
	local ItemStats1 = Item1.UnenchantedStats
	local ItemSocketBonusStats1 = Item1.UnenchantedSocketBonusStats
	local ItemStats2 = Item2.UnenchantedStats
	local ItemSocketBonusStats2 = Item2.UnenchantedSocketBonusStats
	local ThisScale = PawnOptions.Scales[PawnUICurrentScale]
	local ThisScaleValues = ThisScale.Values
	
	-- For items that have socket bonuses, we actually go through the list twice -- the first loop goes until we get to
	-- the place in the list where the socket bonus should be displayed, and then we pause the first loop and go into
	-- the second loop.  Once the second loop completes, we return to the first loop and finish it.
	local CurrentItemStats1, CurrentItemStats2 = ItemStats1, ItemStats2
	local InSocketBonusLoop
	local FinishedSocketBonusLoop
	
	local StatCount = #PawnStats
	local LastFoundHeader
	local i = 1
	while true do
		if i == PawnUIStats_SocketBonusBefore and not FinishedSocketBonusLoop and not InSocketBonusLoop then
			-- If we're still in the outer loop, and we've reached the point in the stat list where socket bonuses should be inserted, enter
			-- the inner loop.
			InSocketBonusLoop = true
			i = 1
			CurrentItemStats1, CurrentItemStats2 = ItemSocketBonusStats1, ItemSocketBonusStats2
			LastFoundHeader = PawnUIFrame_CompareSocketBonusHeader_Text
		elseif i > StatCount then
			if FinishedSocketBonusLoop then
				-- We've finished the outer loop, so exit.
				break
			else
				-- We've finished the inner loop, so return to the outer loop.
				InSocketBonusLoop = nil
				FinishedSocketBonusLoop = true
				i = PawnUIStats_SocketBonusBefore
				if i > StatCount then break end
				CurrentItemStats1, CurrentItemStats2 = ItemStats1, ItemStats2
				LastFoundHeader = nil
			end
		end
		
		local ThisStatInfo = PawnStats[i]
		VgerCore.Assert(ThisStatInfo, "Failed to find stat info at PawnStats[" .. i .. "]")
		local Title, StatName = ThisStatInfo[1], ThisStatInfo[2]
		
		-- Is this a stat header, or an actual stat?
		if StatName then
			-- This is a stat name.  Is this stat present in the scale AND one of the items?
			local StatValue = ThisScaleValues[StatName]
			local Stats1, Stats2 = CurrentItemStats1[StatName], CurrentItemStats2[StatName]
			if StatValue and (Stats1 or Stats2) then
				-- We should show this stat.  Do we need to add a header first?
				if LastFoundHeader then
					PawnUI_AddComparisonHeaderLine(LastFoundHeader)
					LastFoundHeader = nil
				end
				-- Now, add the stat line.
				local StatNameAndValue = Title .. " @ " .. string.format("%g", StatValue)
				PawnUI_AddComparisonStatLineNumbers(StatNameAndValue, Stats1, Stats2)
			end
		else
			-- This is a header; remember it.  (But, for socket bonuses, ignore all headers.)
			if not InSocketBonusLoop then LastFoundHeader = Title end
		end
		
		-- Increment the counter and continue.
		i = i + 1
		if i > 1000 then
			VgerCore.Fail("Failed to break out of item comparison loop!")
			break
		end
	end
	LastFoundHeader = PawnUIFrame_CompareOtherInfoHeader_Text
	
	-- Add item level information if requested.
	local Level1, Level2 = Item1.Level, Item2.Level
	if not Level1 or Level1 <= 1 then Level1 = nil end
	if not Level2 or Level2 <= 1 then Level2 = nil end
	if PawnOptions.ShowItemLevel and (Level1 > 0 or Level2 > 0) then
		if LastFoundHeader then
			PawnUI_AddComparisonHeaderLine(LastFoundHeader)
			LastFoundHeader = nil
		end
		PawnUI_AddComparisonStatLineNumbers(PawnLocal.ItemLevelTooltipLine, Level1, Level2)
	end
	
	-- Add asterisk indicator.
	if PawnOptions.ShowAsterisks ~= PawnShowAsterisksNever then
		local Asterisk1, Asterisk2
		if Item1.UnknownLines then Asterisk1 = PawnUIFrame_CompareAsterisk_Yes end
		if Item2.UnknownLines then Asterisk2 = PawnUIFrame_CompareAsterisk_Yes end
		if Asterisk1 or Asterisk2 then
			if LastFoundHeader then
				PawnUI_AddComparisonHeaderLine(LastFoundHeader)
				LastFoundHeader = nil
			end
			PawnUI_AddComparisonStatLineStrings(PawnUIFrame_CompareAsterisk, Asterisk1, Asterisk2)
		end
	end
	
	-- Update the scrolling stat area's height.
	PawnUI_RefreshCompareScrollFrame()
	
	-- Update the total item score row.
	local ValueFormat = "%." .. PawnOptions.Digits .. "f"
	local r, g, b = VgerCore.HexToRGB(PawnOptions.Scales[PawnUICurrentScale].Color)
	if not r then r, g, b = VgerCore.Color.BlueR, VgerCore.Color.BlueG, VgerCore.Color.BlueB end
	local _, Value1 = PawnGetSingleValueFromItem(Item1, PawnUICurrentScale)
	local _, Value2 = PawnGetSingleValueFromItem(Item2, PawnUICurrentScale)
	local Value1String, Value2String
	if Value1 then Value1String = string.format(ValueFormat, Value1) else Value1 = 0 end
	if Value2 then Value2String = string.format(ValueFormat, Value2) else Value2 = 0 end
	if Value1 > 0 then
		PawnUICompareItemScore1:SetText(Value1String)
		PawnUICompareItemScore1:SetVertexColor(r, g, b)
		if Value1 > Value2 then
			PawnUICompareItemScoreDifference1:SetText("(+" .. string.format(ValueFormat, Value1 - Value2) .. ")")
			PawnUICompareItemScoreHighlight1:Show()
		end
	end
	if Value2 > 0 then
		PawnUICompareItemScore2:SetText(Value2String)
		PawnUICompareItemScore2:SetVertexColor(r, g, b)
		if Value2 > Value1 then
			PawnUICompareItemScoreDifference2:SetText("(+" .. string.format(ValueFormat, Value2 - Value1) .. ")")
			PawnUICompareItemScoreHighlight2:Show()
		end
	end
end

-- Deletes all comparison stat and header lines.
function PawnUI_DeleteComparisonLines()
	for i = 1, PawnUITotalComparisonLines do
		local LineName = "PawnUICompareStatLine" .. i
		local Line = getglobal(LineName)
		if Line then Line:Hide() end
		setglobal(LineName, nil)
		setglobal(LineName .. "Name", nil)
		setglobal(LineName .. "Quantity1", nil)
		setglobal(LineName .. "Quantity2", nil)
		setglobal(LineName .. "Difference1", nil)
		setglobal(LineName .. "Difference2", nil)
	end
	PawnUITotalComparisonLines = 0
	PawnUI_RefreshCompareScrollFrame()
end

-- Adds a stat line to the comparison stat area, passing in the strings to use.
function PawnUI_AddComparisonStatLineStrings(StatNameAndValue, Quantity1, Quantity2, Difference1, Difference2)
	local Line, LineName = PawnUI_AddComparisonLineCore("PawnUICompareStatLineTemplate")
	getglobal(LineName .. "Name"):SetText(StatNameAndValue)	
	getglobal(LineName .. "Quantity1"):SetText(Quantity1)	
	getglobal(LineName .. "Quantity2"):SetText(Quantity2)	
	getglobal(LineName .. "Difference1"):SetText(Difference1)	
	getglobal(LineName .. "Difference2"):SetText(Difference2)	
	Line:Show()
end

-- Adds a stat line to the comparison stat area, passing in the numbers to use.  It is acceptable to use nil for either or both
-- of the numbers.  Differences are calculated automatically.
function PawnUI_AddComparisonStatLineNumbers(StatNameAndValue, Quantity1, Quantity2)
	local QuantityString1 = PawnFormatShortDecimal(Quantity1)
	local QuantityString2 = PawnFormatShortDecimal(Quantity2)
	local Difference1, Difference2
	if not Quantity1 then Quantity1 = 0 end
	if not Quantity2 then Quantity2 = 0 end
	if Quantity1 > Quantity2 then
		Difference1 = "(+" .. PawnFormatShortDecimal(Quantity1 - Quantity2) .. ")"
	elseif Quantity2 > Quantity1 then
		Difference2 = "(+" .. PawnFormatShortDecimal(Quantity2 - Quantity1) .. ")"
	end
	
	PawnUI_AddComparisonStatLineStrings(StatNameAndValue, QuantityString1, QuantityString2, Difference1, Difference2)
end

-- Adds a header line to the comparison stat area.
function PawnUI_AddComparisonHeaderLine(HeaderText)
	local Line, LineName = PawnUI_AddComparisonLineCore("PawnUICompareStatLineHeaderTemplate")
	local HeaderLabel = getglobal(LineName .. "Name")
	HeaderLabel:SetText(HeaderText)
	Line:Show()
end

-- Adds a line to the comparison stat area.
-- Arguments: Template
--	Template: The XML UI template to use when creating the new line.
-- Returns: Line, LineName
--	Line: A reference to the newly added line.
--	LineName: The string name of the newly added line.
function PawnUI_AddComparisonLineCore(Template)
	PawnUITotalComparisonLines = PawnUITotalComparisonLines + 1
	local LineName = "PawnUICompareStatLine" .. PawnUITotalComparisonLines
	local Line = CreateFrame("Frame", LineName, PawnUICompareScrollContent, Template)
	Line:SetPoint("TOPLEFT", PawnUICompareScrollContent, "TOPLEFT", 0, -PawnUIComparisonLineHeight * (PawnUITotalComparisonLines - 1))
	return Line, LineName
end

-- Updates the height of the comparison stat list scroll area's inner frame.  Call this after adding or removing a block of
-- comparison lines to ensure that the scroll area is correct.
function PawnUI_RefreshCompareScrollFrame()
	PawnUICompareScrollContent:SetHeight(PawnUIComparisonLineHeight * PawnUITotalComparisonLines + PawnUIComparisonAreaPaddingBottom)
	if PawnUITotalComparisonLines > 0 then
		PawnUICompareMissingItemInfoFrame:Hide()
		PawnUICompareScrollFrame:Show()
	else
		PawnUICompareScrollFrame:Hide()
		PawnUICompareMissingItemInfoFrame:Show()
	end
end

-- Links an item in chat.
function PawnUILinkItemInChat(Item)
	if not Item then return end
	if ChatFrameEditBox then
		if not ChatFrameEditBox:IsShown() then
			ChatFrameEditBox:SetText("")
			ChatFrameEditBox:Show()
		end
		ChatFrameEditBox:Insert(Item.Link)
	else
		VgerCore.Fail("Can't insert item link into chat because ChatFrameEditBox was not found.")
	end
end

-- Called when one of the two upper item slots are clicked.
function PawnUICompareItemIcon_OnClick(Index)
	PlaySound("igMainMenuOptionCheckBoxOn")
	
	-- Are they shift-clicking it to insert the item into chat?
	if IsModifiedClick("CHATLINK") then
		PawnUILinkItemInChat(PawnUIComparisonItems[Index])
		return
	end
	
	-- Are they dropping an item from their inventory?
	local InfoType, Info1, Info2 = GetCursorInfo()
	if InfoType == "item" then
		ClearCursor()
		PawnUI_SetCompareItem(Index, Info2)
		if Index == 2 then PawnUI_AutoCompare() end
		return
	end
	
	-- Are they dropping an item from a merchant's inventory?
	if InfoType == "merchant" then
		ClearCursor()
		local ItemLink = GetMerchantItemLink(Info1)
		if not ItemLink then return end
		PawnUI_SetCompareItem(Index, ItemLink)
		if Index == 2 then PawnUI_AutoCompare() end
		return
	end
end

-- Shows the tooltip for an item comparison slot.
function PawnUICompareItemIcon_TooltipOn(Index)
	-- Is there an item set for this slot?
	local Item = PawnUIComparisonItems[Index]
	if Item then
		if Index == 1 then
			GameTooltip:SetOwner(PawnUICompareItemIcon1, "ANCHOR_BOTTOMLEFT")
		elseif Index == 2 then
			GameTooltip:SetOwner(PawnUICompareItemIcon2, "ANCHOR_BOTTOMRIGHT")
		end
		GameTooltip:SetHyperlink(Item.Link)
	end
end

-- Hides the tooltip for an item comparison slot.
function PawnUICompareItemIcon_TooltipOff()
	GameTooltip:Hide()
end

-- Sets the left item to the item depicted in the "currently equipped" shortcut button.
function PawnUICompareItemShortcut_OnClick(ShortcutIndex, Button)
	PlaySound("igMainMenuOptionCheckBoxOn")

	-- Are they shift-clicking it to insert the item into chat?
	if IsModifiedClick("CHATLINK") then
		PawnUILinkItemInChat(PawnUIShortcutItems[ShortcutIndex])
		return
	end
	
	-- Nope; they want to set the compare item.
	local Index = 1
	if Button == "RightButton" then Index = 2 end
	PawnUI_SetCompareItem(Index, PawnUIShortcutItems[ShortcutIndex])
end

-- Shows the tooltip for the shortcut button.
function PawnUICompareItemShortcut_TooltipOn(ShortcutIndex)
	local Item = PawnUIShortcutItems[ShortcutIndex]
	if Item then
		GameTooltip:SetOwner(getglobal("PawnUICompareItemShortcut" .. ShortcutIndex), "ANCHOR_TOPLEFT")
		local UnenchantedLink = PawnUnenchantItemLink(Item.Link)
		if not UnenchantedLink then UnenchantedLink = Item.Link end
		GameTooltip:SetHyperlink(UnenchantedLink)
	end
end

-- Hides the tooltip for the shortcut button.
function PawnUICompareItemShortcut_TooltipOff()
	GameTooltip:Hide()
end

------------------------------------------------------------
-- Options tab
------------------------------------------------------------

-- When the Options tab is first shown, set the values of all of the controls based on the user's settings.
function PawnUIOptionsTabPage_OnShow()
	-- Tooltip options
	PawnUIFrame_ShowItemLevelsCheck:SetChecked(PawnOptions.ShowItemLevel)
	PawnUIFrame_ShowItemIDsCheck:SetChecked(PawnOptions.ShowItemID)
	PawnUIFrame_ShowIconsCheck:SetChecked(PawnOptions.ShowTooltipIcons)
	PawnUIFrame_ShowExtraSpaceCheck:SetChecked(PawnOptions.ShowSpace)
	PawnUIFrame_AlignRightCheck:SetChecked(PawnOptions.AlignNumbersRight)
	PawnUIFrame_AsterisksList_UpdateSelection()
	
	-- Calculation options
	PawnUIFrame_DigitsBox:SetText(PawnOptions.Digits)
	PawnUIFrame_UnenchantedValuesCheck:SetChecked(PawnOptions.ShowUnenchanted)
	PawnUIFrame_EnchantedValuesCheck:SetChecked(PawnOptions.ShowEnchanted)
	PawnUIFrame_NormalizeValuesCheck:SetChecked(PawnOptions.NormalizationFactor and PawnOptions.NormalizationFactor > 0)
	PawnUIFrame_DebugCheck:SetChecked(PawnOptions.Debug)
	
	-- Other options
	PawnUIFrame_ButtonPositionList_UpdateSelection()
end

function PawnUIFrame_ShowItemLevelsCheck_OnClick()
	PawnOptions.ShowItemLevel = PawnUIFrame_ShowItemLevelsCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_ShowItemIDsCheck_OnClick()
	PawnOptions.ShowItemID = PawnUIFrame_ShowItemIDsCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_ShowIconsCheck_OnClick()
	PawnOptions.ShowTooltipIcons = PawnUIFrame_ShowIconsCheck:GetChecked() ~= nil
	PawnToggleTooltipIcons()
end

function PawnUIFrame_ShowExtraSpaceCheck_OnClick()
	PawnOptions.ShowSpace = PawnUIFrame_ShowExtraSpaceCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_AlignRightCheck_OnClick()
	PawnOptions.AlignNumbersRight = PawnUIFrame_AlignRightCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_AsterisksList_SetSelection(Value)
	PawnOptions.ShowAsterisks = Value
	PawnUIFrame_AsterisksList_UpdateSelection()
	PawnResetTooltips()
end

function PawnUIFrame_AsterisksList_UpdateSelection()
	PawnUIFrame_AsterisksAutoRadio:SetChecked(PawnOptions.ShowAsterisks == PawnShowAsterisksNonzero)
	PawnUIFrame_AsterisksAutoNoTextRadio:SetChecked(PawnOptions.ShowAsterisks == PawnShowAsterisksNonzeroNoText)
	PawnUIFrame_AsterisksOnRadio:SetChecked(PawnOptions.ShowAsterisks == PawnShowAsterisksAlways)
	PawnUIFrame_AsterisksOffRadio:SetChecked(PawnOptions.ShowAsterisks == PawnShowAsterisksNever)
end

function PawnUIFrame_DigitsBox_OnTextChanged()
	local Digits = tonumber(PawnUIFrame_DigitsBox:GetText())
	if not Digits then Digits = 0 end
	PawnOptions.Digits = Digits
	PawnRecreateAnnotationFormats()
	PawnResetTooltips()
end

function PawnUIFrame_UnenchantedValuesCheck_OnClick()
	PawnOptions.ShowUnenchanted = PawnUIFrame_UnenchantedValuesCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_EnchantedValuesCheck_OnClick()
	PawnOptions.ShowEnchanted = PawnUIFrame_EnchantedValuesCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_NormalizeValuesCheck_OnClick()
	if PawnUIFrame_NormalizeValuesCheck:GetChecked() then
		PawnOptions.NormalizationFactor = 1
	else
		PawnOptions.NormalizationFactor = nil
	end
	PawnResetTooltips()
end

function PawnUIFrame_DebugCheck_OnClick()
	PawnOptions.Debug = PawnUIFrame_DebugCheck:GetChecked() ~= nil
	PawnResetTooltips()
end

function PawnUIFrame_ButtonPositionList_SetSelection(Value)
	PawnOptions.ButtonPosition = Value
	PawnUIFrame_ButtonPositionList_UpdateSelection()
	PawnUI_InventoryPawnButton_Move()
end

function PawnUIFrame_ButtonPositionList_UpdateSelection()
	PawnUIFrame_ButtonRightRadio:SetChecked(PawnOptions.ButtonPosition == PawnButtonPositionRight)
	PawnUIFrame_ButtonLeftRadio:SetChecked(PawnOptions.ButtonPosition == PawnButtonPositionLeft)
	PawnUIFrame_ButtonOffRadio:SetChecked(PawnOptions.ButtonPosition == PawnButtonPositionHidden)
end

------------------------------------------------------------
-- About tab methods
------------------------------------------------------------

function PawnUIAboutTabPage_OnShow()
	local Version = GetAddOnMetadata("Pawn", "Version")
	if Version then 
		PawnUIFrame_AboutVersionLabel:SetText(string.format(PawnUIFrame_AboutVersionLabel_Text, Version))
	end
end

------------------------------------------------------------
-- Interface Options
------------------------------------------------------------

function PawnInterfaceOptionsFrame_OnLoad()
	-- Register the Interface Options page.
	PawnInterfaceOptionsFrame.name = "Pawn"
	InterfaceOptions_AddCategory(PawnInterfaceOptionsFrame)
	-- Update the version display.
	local Version = GetAddOnMetadata("Pawn", "Version")
	if Version then 
		PawnInterfaceOptionsFrame_AboutVersionLabel:SetText(string.format(PawnUIFrame_AboutVersionLabel_Text, Version))
	end
end

------------------------------------------------------------
-- Other Pawn UI methods
------------------------------------------------------------

-- Switches to a tab by its number.
function PawnUISwitchToTab(TabNumber)
	local TabCount = #PawnUITabList
	if TabNumber < 1 or TabNumber > TabCount then
		VgerCore.Fail("TabNumber was not within the proper range: 1 to " .. TabCount .. ".")
		return
	end
	
	-- Loop through all tab frames, showing all but the current one.
	for i = 1, TabCount do
		if i == TabNumber then
			PawnUITabList[i]:Show()
		else
			PawnUITabList[i]:Hide()
		end
	end
	
	-- Then, update the tabstrip itself.
	PanelTemplates_SetTab(PawnUIFrame, TabNumber)	
end

-- Shows a tooltip for a given control if available.
-- The tooltip used will be the string with the name of the control plus "_Tooltip" on the end.
-- The title of the tooltip will be the text on a control with the same name plus "_Label" on the
-- end if available, or otherwise the actual text on the control if there is any.  If the tooltip text
-- OR title is missing, no tooltip is displayed.
function PawnUIFrame_TooltipOn(self)
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

-- Hides the game tooltip.
function PawnUIFrame_TooltipOff()
	GameTooltip:Hide()
end


------------------------------------------------------------
-- PawnUIStringDialog methods
------------------------------------------------------------

-- Shows a dialog containing given prompt text, asking the user for a string.
-- Calls OKCallbackFunction with the typed string as the only input if the user clicked OK.
-- Calls CancelCallbackFunction if the user clicked Cancel.
function PawnUIGetString(Prompt, DefaultValue, OKCallbackFunction, CancelCallbackFunction)
	PawnUIGetStringCore(Prompt, DefaultValue, true, OKCallbackFunction, CancelCallbackFunction)
end

-- Shows a dialog with a copyable string.
-- Calls CallbackFunction when the user closes the dialog.
-- Note: Successfully tested with strings of about 900 characters.
function PawnUIShowCopyableString(Prompt, Value, CallbackFunction)
	PawnUIGetStringCore(Prompt, Value, false, CallbackFunction, nil)
end

-- Core function called by PawnUIGetString.
function PawnUIGetStringCore(Prompt, DefaultValue, Cancelable, OKCallbackFunction, CancelCallbackFunction)
	PawnUIStringDialog_PromptText:SetText(Prompt)
	PawnUIStringDialog_TextBox:SetText("") -- Causes the insertion point to move to the end on the next SetText
	PawnUIStringDialog_TextBox:SetText(DefaultValue)
	if Cancelable then
		PawnUIStringDialog_OKButton:Show()
		PawnUIStringDialog_OKButton:SetText(PawnLocal.OKButton)
		PawnUIStringDialog_CancelButton:SetText(PawnLocal.CancelButton)
	else
		PawnUIStringDialog_OKButton:Hide()
		PawnUIStringDialog_CancelButton:SetText(PawnLocal.CloseButton)
	end
	PawnUIStringDialog.OKCallbackFunction = OKCallbackFunction
	PawnUIStringDialog.CancelCallbackFunction = CancelCallbackFunction
	PawnUIStringDialog:Show()
	PawnUIStringDialog_TextBox:SetFocus()
end

-- Cancels the string dialog if it's open.
function PawnUIGetStringCancel()
	if not PawnUIStringDialog:IsVisible() then return end
	PawnUIStringDialog_CancelButton_OnClick()
end

function PawnUIStringDialog_OKButton_OnClick()
	PawnUIStringDialog:Hide()
	if PawnUIStringDialog.OKCallbackFunction then PawnUIStringDialog.OKCallbackFunction(PawnUIStringDialog_TextBox:GetText()) end
end

function PawnUIStringDialog_CancelButton_OnClick()
	PawnUIStringDialog:Hide()
	if PawnUIStringDialog.CancelCallbackFunction then PawnUIStringDialog.CancelCallbackFunction() end
end

function PawnUIStringDialog_TextBox_OnTextChanged()
	if PawnUIStringDialog_TextBox:GetText() ~= "" then
		PawnUIStringDialog_OKButton:Enable()
	else
		PawnUIStringDialog_OKButton:Disable()
	end
end