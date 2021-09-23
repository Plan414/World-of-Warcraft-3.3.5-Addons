local addonName, addon = ...
local L = addon.L

local NUM_BUTTONS = 12
local BUTTON_HEIGHT = 36

local selectedTree

local spellList = addon.config:AddSubCategory("Spells")
addon.spellList = spellList
spellList:SetDescription(L["Here you can review and manage all your registered spells. Click the button on the right hand side of a spell for options."])

-- this table gets populated with "Filter", "Reset", "Announce" etc
local spellOptions = {}

local dropdown = addon:CreateDropdown("Menu")
dropdown.initialize = function(self, level, menuList)
	for i, info in ipairs(menuList) do
		info.value = UIDROPDOWNMENU_MENU_VALUE
		info.arg1 = selectedTree
		self:AddButton(info, level)
	end
end

local spellListContainer = addon:CreateTabInterface(spellList)
spellListContainer:SetHeight(NUM_BUTTONS * BUTTON_HEIGHT + 4)
spellListContainer:SetPoint("TOP", spellList.title, "BOTTOM", 0, -68)
spellListContainer:SetPoint("LEFT", 32, 0)
spellListContainer:SetPoint("RIGHT", -32, 0)

for i, v in ipairs(addon.treeIndex) do
	local tab = spellListContainer:CreateTab()
	tab:SetLabel(addon.trees[v].title)
end

local function onEnter(self)
	GameTooltip.Critline = true
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetSpellByID(self.data.id)
	GameTooltip:AddLine(" ")
	addon:AddTooltipLine(self.data)
	if addon.GetPreviousRecord then
		local prevRecord = addon:GetPreviousRecord(self.data, selectedTree)
		if prevRecord then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Previous record:"])
			addon:AddTooltipLine(prevRecord)
		end
	end
	GameTooltip:Show()
end

local function onClick(self)
	if UIDROPDOWNMENU_MENU_VALUE ~= self.data then
		dropdown:CloseMenus()
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	dropdown:Toggle(self.data, self, 0, 0, spellOptions)
end

local function createButton()
	local item = CreateFrame("Frame", nil, spellListContainer)
	item:SetScript("OnEnter", onEnter)
	item:SetScript("OnLeave", GameTooltip_Hide)
	item.OnEnter = onEnter
	
	local icon = item:CreateTexture()
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT")
	item.icon = icon

	local spellName = item:CreateFontString(nil, nil, "GameFontNormal")
	spellName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, -4)
	spellName:SetJustifyH("LEFT")
	item.spellName = spellName

	local target = item:CreateFontString(nil, nil, "GameFontDisableSmall")
	target:SetPoint("TOPRIGHT", -80, 0)
	target:SetPoint("BOTTOMRIGHT", -80, 0)
	target:SetJustifyH("RIGHT")
	target:SetSpacing(2)
	item.target = target
	
	local button = CreateFrame("Button", nil, item)
	button:SetPoint("RIGHT", -2, 0)
	button:SetSize(32, 32)
	button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]])
	button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]])
	button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]])
	button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
	button:SetScript("OnClick", onClick)
	item.button = button
	
	-- font string for record amounts
	local record = item:CreateFontString(nil, nil, "GameFontHighlightSmall")
	record:SetPoint("TOPRIGHT", -36, 0)
	record:SetPoint("BOTTOMRIGHT", -36, 0)
	record:SetJustifyH("RIGHT")
	record:SetSpacing(2)
	item.record = record
	
	return item
end

local scrollFrame = addon:CreateScrollframe(spellList, NUM_BUTTONS, BUTTON_HEIGHT, createButton, 4, -2)
spellList.scrollFrame = scrollFrame
scrollFrame:SetAllPoints(spellListContainer)
scrollFrame.PostUpdate = function(self, event, tree)
	-- hide the menu since we can't tell if it's still referring to the same spell (no need if a different tree was updated)
	if tree == selectedTree then
		dropdown:CloseMenus()
	end
end
scrollFrame.GetList = function()
	return addon:GetSpellArray(selectedTree)
end
scrollFrame.OnButtonShow = function(self, item, data)
	item.data = data
	item.button.data = data
	local normal = data.normal
	local crit = data.crit
	item.icon:SetTexture(addon:GetSpellTexture(data.id))
	if addon.filters then
		item.icon:SetDesaturated(data.filtered)
		item.spellName:SetFontObject(data.filtered and "GameFontDisable" or "GameFontNormal")
	end
	item.spellName:SetText(addon:GetFullSpellName(data.name, data.periodic))
	item.target:SetFormattedText("%s\n%s",
		normal and normal.target or "-",
		crit and crit.target or "-")
	item.record:SetFormattedText("%s\n%s",
		spellList:GetTextColor(data, "normal"),
		spellList:GetTextColor(data, "crit"))
	if GameTooltip:IsOwned(item) then
		item:OnEnter()
	end
end

spellListContainer.OnTabSelected = function(self, tabIndex)
	selectedTree = addon.treeIndex[tabIndex]
	scrollFrame:Reset()
	dropdown:CloseMenus()
end

spellListContainer:SelectTab(1)

addon.RegisterCallback(scrollFrame, "PerCharSettingsLoaded", "Update")
addon.RegisterCallback(scrollFrame, "RecordsChanged", "Update")
addon.RegisterCallback(scrollFrame, "SpellsChanged", "Update")
addon.RegisterCallback(scrollFrame, "HistoryCleared", "Update")
addon.RegisterCallback(scrollFrame, "FormatChanged", "Update")

function spellList:AddSpellOption(info)
	tinsert(spellOptions, info)
end

function spellList:GetSelectedTree()
	return selectedTree
end

local textColorMod

-- color text yellow if the record can be reverted
function spellList:GetTextColor(data, hitType)
	local amount = data[hitType] and addon:ShortenNumber(data[hitType].amount)
	if not amount then
		return 0
	end
	local colorFormat = textColorMod and textColorMod(data, selectedTree, hitType)
	return colorFormat and format(colorFormat, amount) or amount
end

function spellList:SetSpellColorMod(func)
	textColorMod = func
end
