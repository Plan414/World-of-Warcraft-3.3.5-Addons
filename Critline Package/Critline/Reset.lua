local addonName, addon = ...
local L = addon.L

assert(addon.spellList, "Reset module requires spellList module.")

-- history for undoing recent (last fight) records
local history = {
	dmg  = {},
	heal = {},
	pet  = {},
}

local module = addon:NewModule("Reset")

local resetButton = CreateFrame("Button", nil, addon.spellList, "UIPanelButtonTemplate")
resetButton:SetPoint("BOTTOMRIGHT", addon.spellList.scrollFrame, "TOPRIGHT", 0, 8)
resetButton:SetSize(100, 22)
resetButton:SetText(L["Reset all"])
resetButton:SetScript("OnClick", function(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	local tree = addon.spellList:GetSelectedTree()
	StaticPopup_Show("CRITLINE_RESET_ALL", addon.trees[tree].label, nil, tree)
end)

addon:CreatePopup("CRITLINE_RESET_ALL", {
	text = L["Are you sure you want to reset all %s records?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		module:ResetAll(data)
	end,
})

local revertButton = CreateFrame("Button", nil, addon.spellList, "UIPanelButtonTemplate")
revertButton:SetPoint("RIGHT", resetButton, "LEFT", -8, 0)
revertButton:SetSize(100, 22)
revertButton:SetText(L["Revert all"])
revertButton:SetScript("OnClick", function(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	module:RevertAll(addon.spellList:GetSelectedTree())
end)

local colorFormat = GREEN_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE

addon.spellList:SetSpellColorMod(function(data, tree, hitType)
	local prevRecord = addon:GetPreviousRecord(data, tree)
	if prevRecord and prevRecord[hitType] then
		return colorFormat
	end
end)

-- since dropdowns doesn't accept .disabled as a function, do some magics
local mt = {
	__index = function(tbl, key)
		if key == "disabled" then
			return not addon:GetPreviousRecord(tbl.value, tbl.arg1)
		end
	end
}

addon.spellList:AddSpellOption(setmetatable({
	text = L["Revert"],
	func = function(self, tree)
		local data = self.value
		local history = history[tree][data.id]
		local spell = addon:GetSpellInfo(tree, data.id, data.periodic)
		for k, v in pairs(history[data.periodic]) do
			local hitType = spell[k]
			local amount, target = hitType.amount, hitType.target
			for k, v in pairs(v) do
				hitType[k] = v
			end
			addon:Message(format("Reverted %s (%d, %s) record on %s.", data.name, amount, tree, target))
		end
		history[data.periodic] = nil
		addon:UpdateTopRecords(tree)
		addon:UpdateRecords(tree)
	end,
	notCheckable = true,
}, mt))

addon.spellList:AddSpellOption({
	text = L["Reset"],
	func = function(self, tree)
		local data = self.value
		addon:DeleteSpell(tree, data.id, data.periodic)
		local history = history[tree][data.id]
		if history then
			history[data.periodic] = nil
		end
		addon:UpdateSpells(tree)
	end,
	notCheckable = true,
})

function addon:GetPreviousRecord(data, tree)
	local prevRecord = history[tree][data.id]
	return prevRecord and prevRecord[data.periodic]
end

function module:ResetAll(tree)
	wipe(addon.percharDB.profile.spells[tree])
	wipe(addon:GetSpellArray(tree))
	addon:Message(format(L["Reset all %s records."], tree))
	addon:UpdateTopRecords(tree)
	addon:UpdateSpells(tree)
end

function module:RevertAll(tree)
	local history = history[tree]
	for spellID, v in pairs(history) do
		for periodic, v in ipairs(v) do
			local spell = addon:GetSpellInfo(tree, spellID, periodic)
			for k, v in pairs(v) do
				local hitType = spell[k]
				local amount, target = hitType.amount, hitType.target
				for k, v in pairs(v) do
					hitType[k] = v
				end
			end
		end
	end
	wipe(history)
	addon:Message(format(L["Reverted all recent %s records."], addon.trees[tree].label))
	addon:UpdateTopRecords(tree)
	addon:UpdateRecords(tree)
end

-- stores previous record for the undo feature
function module:NewRecord(event, tree, spellID, spellName, periodic, amount, crit, prevRecord)
	-- do not store previous record if it was 0
	if prevRecord.amount == 0 then
		return
	end
	
	history[tree][spellID] = history[tree][spellID] or {}
	local hitType = crit and "crit" or "normal"
	local spell = history[tree][spellID]
	spell[periodic] = spell[periodic] or {}
	-- do not store previous records gained in current fight
	if spell[periodic][hitType] then
		return
	else
		spell[periodic][hitType] = {}
	end
	for k, v in pairs(prevRecord) do
		spell[periodic][hitType][k] = v
	end
	addon:Debug(format("Storing previous %s %s record for %s (%d)", hitType, tree, addon:GetFullSpellName(spellName, periodic), prevRecord.amount))
end

addon.RegisterCallback(module, "NewRecord")

function module:ClearHistory()
	for k, tree in pairs(history) do
		wipe(tree)
	end
	addon.callbacks:Fire("HistoryCleared")
end

addon.RegisterCallback(module, "PerCharSettingsLoaded", "ClearHistory")
module:RegisterEvent("PLAYER_REGEN_DISABLED", "ClearHistory")
