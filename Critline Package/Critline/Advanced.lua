local addonName, core = ...
local L = core.L

local selectedValue = {}
local reverseList = {}

local module = core:NewModule("Advanced", core.config:AddSubCategory("Advanced"))

local editbox
do
	local function update(key, value, oldKey)
		local list = module:GetSelectedList()
		if selectedValue.isNumeric and value then
			reverseList[list[key]] = nil
			reverseList[value] = true
		end
		if oldKey then
			value = list[oldKey]
			list[oldKey] = nil
		end
		list[key] = value
		local onAccept = selectedValue.onAccept
		if onAccept then
			onAccept(key, value)
		end
		core:UpdateSpells()
		module:Update()
	end
	
	local function validateKey(self, id)
		local isValid, reason = true
		if id ~= self.data and module:GetSelectedList()[id] then
			isValid = false
			reason = L["This spell ID is already mapped."]
		end
		if reverseList[id] then
			-- the value of a mapping equals the specified ID, which we won't allow since it won't work very well
			isValid = false
			reason = L["Conflicting mapping."]
		end
		return isValid, reason
	end
	
	local function onTextChanged(self)
		if self.validate:IsShown() then
			local isValid, reason = self:Validate(self:GetValue())
			if isValid then
				if not GetSpellLink(self:GetValue()) then
					self.validate.tex:SetTexture([[Interface\RaidFrame\ReadyCheck-Waiting]])
					reason = L["Invalid spell ID."]
				else
					self.validate.tex:SetTexture([[Interface\RaidFrame\ReadyCheck-Ready]])
				end
			else
				self.validate.tex:SetTexture([[Interface\RaidFrame\ReadyCheck-NotReady]])
			end
			self.validate.reason = reason
		end
	end

	local function onShow(self)
		local isNumeric = self.type == "key" or selectedValue.isNumeric
		self:SetNumeric(isNumeric)
		self.GetValue = isNumeric and self.GetNumber or self.GetText
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", self.parent, 5, 0)
		if not isNumeric then
			-- non-spell ID exclusive editboxes will be wider
			self:SetPoint("TOPRIGHT", self.parent)
		end
		self.Validate = self.type == "key" and validateKey or selectedValue.validate
		self.validate:SetShown(self.Validate)
		self:SetText(self.data)
		onTextChanged(self)
		self:HighlightText()
		self:SetFocus()
	end
	
	local function onHide(self)
		self.parent:Show()
	end
	
	local function onEnterPressed(self)
		local text = self:GetValue()
		if self.Validate then
			local isValid, reason = self:Validate(text)
			if not isValid then
				core:Message(reason)
				return
			end
		end
		if self:GetText():trim() == "" then
			return
		end
		if text ~= self.data then
			if self.type == "key" then
				update(text, nil, self.data)
			else
				update(self.key, text)
			end
		end
		
		self:Hide()
	end
	
	editbox = core:CreateEditbox(module)
	editbox:Hide()
	-- editbox:SetFrameStrata("HIGH")
	editbox:SetWidth(56)
	editbox:SetFontObject("ChatFontNormal")
	editbox:SetScript("OnShow", onShow)
	editbox:SetScript("OnHide", onHide)
	editbox:SetScript("OnEscapePressed", editbox.Hide)
	editbox:SetScript("OnEditFocusLost", editbox.Hide)
	editbox:SetScript("OnEnterPressed", onEnterPressed)
	editbox:SetScript("OnTextChanged", onTextChanged)
	
	local validate = CreateFrame("Frame", nil, editbox)
	validate:SetSize(20, 20)
	validate:SetPoint("LEFT", editbox, "RIGHT")
	validate:SetScript("OnEnter", function(self)
		if self.reason then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText(self.reason)
		end
	end)
	validate:SetScript("OnLeave", GameTooltip_Hide)
	validate:Hide()
	editbox.validate = validate
	
	local validTex = validate:CreateTexture()
	validTex:SetAllPoints()
	validate.tex = validTex
end

local scrollFrame
do
	local deleteButton = CreateFrame("Button", nil, module, "UIPanelCloseButton")
	deleteButton:SetScript("OnLeave", deleteButton.Hide)
	deleteButton:SetScript("OnClick", function(self)
		module:GetSelectedList()[self.value] = nil
		if selectedValue.onDelete then
			selectedValue.onDelete(self.value)
		end
		core:UpdateSpells()
		module:Update()
		self:Hide()
	end)
	
	local function showDelete(anchor)
		deleteButton.value = anchor.key.data
		deleteButton:SetPoint("RIGHT", anchor, "LEFT")
		deleteButton:Show()
	end

	local function onEnter(self)
		if type(self.data) == "number" then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			if GetSpellLink(self.data) then
				GameTooltip:SetSpellByID(self.data)
			else
				GameTooltip:SetText(L["Invalid spell ID."])
			end
		end
		showDelete(self.parent)
	end
	
	local function onLeave(self)
		GameTooltip_Hide()
		if not deleteButton:IsMouseOver() then
			deleteButton:Hide()
		end
	end

	local function onClick(self)
		self:Hide()
		if editbox:IsShown() then
			editbox.parent:Show()
			editbox:Hide()
		end
		local parent = self.parent
		editbox.parent = self
		editbox.data = self.data
		editbox.type = self.type
		editbox.key = parent.key.data
		editbox.value = parent.value.data
		editbox:SetParent(self.parent)
		editbox:Show()
	end
	
	local function createCell(frame, valueType)
		local cell = CreateFrame("Button", nil, frame)
		cell:SetNormalFontObject("ChatFontNormal")
		cell:SetPushedTextOffset(0, 0)
		cell:SetScript("OnClick", onClick)
		cell:SetScript("OnEnter", onEnter)
		cell:SetScript("OnLeave", onLeave)
		cell.type = valueType
		frame[valueType] = cell
		local text = cell:CreateFontString()
		text:SetJustifyH("LEFT")
		text:SetPoint("TOPLEFT", 5, 0)
		text:SetPoint("BOTTOMRIGHT")
		cell:SetFontString(text)
		local spellName = cell:CreateFontString(nil, nil, "ChatFontNormal")
		spellName:SetJustifyH("LEFT")
		spellName:SetPoint("TOPLEFT", 64, 0)
		spellName:SetPoint("BOTTOMRIGHT")
		cell.name = spellName
		cell.parent = frame
		return cell
	end
	
	local function createButton()
		local frame = CreateFrame("Frame", nil, module)
		frame:SetScript("OnEnter", showDelete)
		frame:SetScript("OnLeave", onLeave)
		
		local key = createCell(frame, "key")
		key:SetPoint("TOPLEFT", 4, 0)
		key:SetPoint("BOTTOMLEFT")
		key:SetPoint("RIGHT", frame, "CENTER", -8, 0)
		
		local equals = frame:CreateFontString(nil, nil, "ChatFontNormal")
		equals:SetPoint("CENTER")
		equals:SetText("=")
		
		local value = createCell(frame, "value")
		value:SetPoint("LEFT", frame, "CENTER", 8, 0)
		value:SetPoint("TOPRIGHT", -4, 0)
		value:SetPoint("BOTTOMRIGHT")
		
		return frame
	end

	local sortedList = {}

	local function sortList(a, b)
		local nameA, nameB = core:GetSpellName(a, true), core:GetSpellName(b, true)
		if not (nameA and nameB) then
			return a < b
		else
			return nameA < nameB
		end
	end
	
	local function preUpdate(self)
		editbox:Hide()
		return module:GetSelectedList(), selectedValue.isNumeric
	end
	
	local function getList()
		wipe(sortedList)
		for k, v in pairs(module:GetSelectedList()) do
			tinsert(sortedList, k)
		end
		sort(sortedList)
		return sortedList
	end
	
	local function onButtonShow(self, frame, value, list, isNumeric)
		frame.key.data = value
		if GetSpellLink(value) then
			frame.key:SetText(value)
		else
			frame.key:SetFormattedText("|cffff0000%d", value)
		end
		frame.key.name:SetText(core:GetSpellName(value, true))
		local text = list[value]
		frame.value.data = text
		if not isNumeric or GetSpellLink(text) then
			frame.value:SetText(text)
		else
			frame.value:SetFormattedText("|cffff0000%s", text)
		end
		if isNumeric then
			frame.value.name:SetText(core:GetSpellName(text, true))
		else
			frame.value.name:SetText(nil)
		end
	end
	
	local NUM_BUTTONS = 20
	local BUTTON_HEIGHT = 20
	
	scrollFrame = core:CreateScrollframe(module, NUM_BUTTONS, BUTTON_HEIGHT, createButton, 0, -4)
	scrollFrame:SetSize(480, NUM_BUTTONS * BUTTON_HEIGHT + 8)
	scrollFrame:SetPoint("CENTER")
	scrollFrame.PreUpdate = preUpdate
	scrollFrame.GetList = getList
	scrollFrame.OnButtonShow = onButtonShow
end

local bg = module:CreateTexture(nil, "BORDER")
bg:SetTexture(0.3, 0.3, 0.3)
bg:SetBlendMode("MOD")
bg:SetAllPoints(scrollFrame)

local border = module:CreateTexture(nil, "BORDER", nil, -1)
border:SetTexture(0.5, 0.5, 0.5, 0.3)
border:SetPoint("TOPLEFT", bg, -1, 1)
border:SetPoint("BOTTOMRIGHT", bg, 1, -1)

local menu = {
	"spellMappings",
	"tooltipMappings",
	"spellNameOverrides",
	"spellIconOverrides",
	spellMappings = L["Spell mappings"],
	tooltipMappings = L["Tooltip mappings"],
	spellNameOverrides = L["Spell name overrides"],
	spellIconOverrides = L["Spell icon overrides"],
	isNumeric = {
		spellMappings = true,
		tooltipMappings = true,
	},
	onAccept = {
		spellMappings = function(key, value)
			for tree in pairs(core.trees) do
				local spells = core.percharDB.profile.spells[tree]
				local spell = spells[key]
				if spell then
					local map = spells[value] or spell
					for i = 1, 2 do
						map[i] = map[i] or spell[i]
					end
					spells[key] = nil
				end
				
				core:BuildSpellArray(tree)
				core:UpdateTopRecords(tree)
			end
		end,
		spellNameOverrides = function(key, value)
			for tree in pairs(core.trees) do
				for i, spell in ipairs(core:GetSpellArray(tree, false)) do
					if spell.id == key then
						spell.name = value
					end
				end
			end
		end,
	},
	onDelete = {
		spellNameOverrides = function(key)
			for tree in pairs(core.trees) do
				for i, spell in ipairs(core:GetSpellArray(tree, false)) do
					if spell.id == key then
						spell.name = core:GetSpellName(key)
					end
				end
			end
		end,
	},
	validate = {
		spellMappings = function(self, value)
			local isValid, reason = true
			if value ~= self.data and module:GetSelectedList()[value] then
				isValid = false
				reason = L["Conflicting mapping."]
			end
			if not GetSpellLink(value) then
				isValid = false
				reason = L["Invalid spell ID."]
			end
			return isValid, reason
		end,
	},
	getDefault = {
		spellMappings = function(id)
			return id
		end,
		tooltipMappings = function(id)
			return id
		end,
		spellNameOverrides = function(id)
			return core:GetSpellName(id, true)
		end,
		spellIconOverrides = function(id)
			return GetSpellTexture(id)
		end,
	},
	info = {
		spellMappings =
			L["Spell mappings causes the source spell to be registered as if it were the target spell. It will be stored with the ID, name and icon of"..
			" the target spell. Useful for merging different spell IDs of the same spell into a single record. Spells will immediately be converted"..
			" into their target ID after a mapping has been created."],
		tooltipMappings =
			L["Tooltip mappings causes the tooltip of the source spell to display the records of the target spell. "..
			"Useful for when several tooltips refer to the same spell, or you want to display some side effect of a spell. "..
			"Any tooltip can only display the records of one database entry at a time."],
		spellNameOverrides =
			L["Name overrides will cause the source spell to be listed as "..
			"the target name in tree tooltips, new record messages and the spell list."],
		spellIconOverrides =
			L["Icon overrides will cause the source spell to use the target texture in the spell list."],
	},
}

local function onClick(self, value)
	module:SelectList(value)
end

local selectedList

local dropdown = core:CreateDropdown("Frame", module)
dropdown:SetWidth(140)
dropdown:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", -16, 0)
dropdown:JustifyText("LEFT")
dropdown.initialize = function(self)
	for _, v in ipairs(menu) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = menu[v]
		info.func = onClick
		info.arg1 = v
		info.checked = (v == selectedList)
		self:AddButton(info)
	end
end

local add = core:CreateEditbox(module)
add:SetNumeric(true)
add:SetWidth(59)
add:SetFontObject("ChatFontNormal")
add:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 5, -16)
add:SetScript("OnEnterPressed", function(self)
	local list = module:GetSelectedList()
	local spellID = self:GetNumber()
	if list[spellID] then
		core:Message(L["This spell ID is already mapped."])
	elseif reverseList[spellID] then
		core:Message(L["Conflicting mapping."])
	else
		local default = selectedValue.getDefault(spellID)
		if default then
			list[spellID] = default
			self:SetText("")
			self:ClearFocus()
			module:Update()
		else
			core:Message(L["Invalid spell ID."])
		end
	end
end)
add:SetScript("OnEscapePressed", function(self)
	self:SetText("")
	self:ClearFocus()
end)
local label = add:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
label:SetPoint("BOTTOMLEFT", add, "TOPLEFT", -5, -2)
label:SetPoint("BOTTOMRIGHT", add, "TOPRIGHT", 0, -2)
label:SetJustifyH("LEFT")
label:SetHeight(18)
label:SetText("Add")

local info = module:CreateFontString(nil, nil, "GameFontNormalSmallLeft")
info:SetPoint("LEFT", add, "RIGHT", 16, 0)
info:SetPoint("TOPRIGHT", scrollFrame, "BOTTOMRIGHT", -4, -8)
info:SetPoint("BOTTOM")
info:SetJustifyV("TOP")

setmetatable(selectedValue, {
	__index = function(tbl, key)
		return menu[key][selectedList]
	end
})

function module:OnInitialize()
	self:SelectList(menu[1])
end

function module:Update()
	scrollFrame:Update()
end

function module:SelectList(value)
	selectedList = value
	dropdown:SetText(menu[value])
	module:BuildReverseList()
	module:Update()
	info:SetText(selectedValue.info)
end

function module:GetSelectedList()
	return core.db.global[selectedList]
end

function module:BuildReverseList()
	wipe(reverseList)
	-- reversed mappings are only interesting for lists where the values are spell IDs
	if selectedValue.isNumeric then
		for k, v in pairs(self:GetSelectedList()) do
			reverseList[v] = true
		end
	end
end
