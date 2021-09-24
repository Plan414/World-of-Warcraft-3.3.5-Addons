local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule("Bags")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["bags"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["BagButtons"] and true or false

--Cache global variables
local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local GetNumBankSlots = GetNumBankSlots
local ToggleFrame = ToggleFrame
local IsShiftKeyDown = IsShiftKeyDown

---
-- GLOBALS: BagItemAutoSortButton, BankFrame
---

P["CustomTweaks"]["BagButtons"] = {
	["stackButton"] = false,
	["style"] = "ICON",
	["buttonColor"] = {r = 0.3, g = 0.3, b = 0.3}
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Bags.args.options.args.BagButtons = {
		type = "group",
		name = "BagButtons",
		get = function(info) return E.db.CustomTweaks["BagButtons"][info[#info]] end,
		set = function(info, value) E.db.CustomTweaks["BagButtons"][info[#info]] = value; CT:SetBagButtonStylePosition(); CT:SetBagButtonStylePosition(true); end,
		args = {
			stackButton = {
				order = 1,
				type = "toggle",
				name = L["Add 'Stack' Button"],
				disabled = function() return not isEnabled end
			},
			style = {
				order = 2,
				type = "select",
				name = L["Button Style"],
				disabled = function() return not isEnabled end,
				values = {
					["ICON"] = L["Icons"],
					["TEXTURE"] = L["Textures"]
				}
			},
			buttonColor = {
				order = 3,
				type = "color",
				name = L["Button Color"],
				disabled = function() return not isEnabled or E.db.CustomTweaks.BagButtons.style == "ICON" end,
				hasAlpha = false,
				get = function(info)
					local t = E.db.CustomTweaks.BagButtons[info[#info]]
					local d = P.CustomTweaks.BagButtons[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					E.db.CustomTweaks.BagButtons[info[#info]] = {}
					local t = E.db.CustomTweaks.BagButtons[info[#info]]
					t.r, t.g, t.b = r, g, b
					CT:SetButtonColors()
					CT:SetButtonColors(true)
				end
			}
		}
	}
end
CT.Configs["BagButtons"] = ConfigTable
if not isEnabled then return; end

local function CreateContainerButtons(self, name, isBank)
	local f = _G[name]
	local buttonColor = E:GetColorTable(E.db.CustomTweaks.BagButtons.buttonColor)

	if (isBank) then
		--Sort/Clean Up Button
		f.sortButtonOld = CreateFrame("Button", name..'SortButtonOld', f);
		f.sortButtonOld:Point('TOP', f, 'TOP', 29, -4)
		f.sortButtonOld:Size(55, 10)
		f.sortButtonOld:SetTemplate('Default', true)
		f.sortButtonOld:SetBackdropColor(unpack(buttonColor))
		f.sortButtonOld.ttText = L['Sort Bags']
		f.sortButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.sortButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.sortButtonOld:SetScript('OnClick', function() B:CommandDecorator(B.SortBags, 'bank')(); end)

		--Purchase Bags Button
		f.purchaseBagButtonOld = CreateFrame('Button', name..'PurchaseButtonOld', f.holderFrame)
		f.purchaseBagButtonOld:Point('RIGHT', f.sortButtonOld, 'LEFT', -3, 0)
		f.purchaseBagButtonOld:Size(55, 10)
		f.purchaseBagButtonOld:SetTemplate('Default', true)
		f.purchaseBagButtonOld:SetBackdropColor(unpack(buttonColor))
		f.purchaseBagButtonOld.ttText = L['Purchase Bags']
		f.purchaseBagButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.purchaseBagButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.purchaseBagButtonOld:SetScript("OnClick", function()
			local _, full = GetNumBankSlots()
			if not full then
				E:StaticPopup_Show("BUY_BANK_SLOT")
			else
				E:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
			end
		end)

		--Toggle Bags Button
		f.bagsButtonOld = CreateFrame("Button", name..'BagsButtonOld', f.holderFrame);
		f.bagsButtonOld:Point('RIGHT', f.purchaseBagButtonOld, 'LEFT', -3, 0)
		f.bagsButtonOld:Size(55, 10)
		f.bagsButtonOld:SetTemplate('Default', true)
		f.bagsButtonOld:SetBackdropColor(unpack(buttonColor))
		f.bagsButtonOld.ttText = L['Toggle Bags'];
		f.bagsButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.bagsButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.bagsButtonOld:SetScript('OnClick', function()
		local numSlots, full = GetNumBankSlots()
			if numSlots >= 1 then
				ToggleFrame(f.ContainerHolder)
			else
				E:StaticPopup_Show("NO_BANK_BAGS")
			end
		end)

		--Stack/Transfer Button Icon
		f.stackButton = CreateFrame("Button", name..'StackButton', f.holderFrame);
		f.stackButton:SetSize(16 + E.Border, 16 + E.Border)
		f.stackButton:SetTemplate()
		f.stackButton:SetPoint("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
		f.stackButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_RatCage")
		f.stackButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.stackButton:GetNormalTexture():SetInside()
		f.stackButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_RatCage")
		f.stackButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.stackButton:GetPushedTexture():SetInside()
		f.stackButton:StyleButton(nil, true)
		f.stackButton.ttText = L['Stack Items In Bank']
		f.stackButton.ttText2 = L['Hold Shift:']
		f.stackButton.ttText2desc = L['Stack Items To Bags']
		f.stackButton:SetScript("OnEnter", self.Tooltip_Show)
		f.stackButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.stackButton:SetScript('OnClick', function()
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bank bags')();
			else
				B:CommandDecorator(B.Compress, 'bank')();
			end
		end)

		--Stack/Transfer Button
		f.stackButtonOld = CreateFrame('Button', name..'StackButtonOld', f.holderFrame)
		f.stackButtonOld:Point('LEFT', f.sortButtonOld, 'RIGHT', 3, 0)
		f.stackButtonOld:Size(55, 10)
		f.stackButtonOld:SetTemplate('Default', true)
		f.stackButtonOld:SetBackdropColor(unpack(buttonColor))
		f.stackButtonOld.ttText = L['Stack Items In Bank']
		f.stackButtonOld.ttText2 = L['Hold Shift:']
		f.stackButtonOld.ttText2desc = L['Stack Items To Bags']
		f.stackButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.stackButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.stackButtonOld:SetScript('OnClick', function()
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bank bags')();
			else
				B:CommandDecorator(B.Compress, 'bank')();
			end
		end)
	else
		--Vendor Button
		f.vendorGraysButtonOld = CreateFrame('Button', nil, f)
		f.vendorGraysButtonOld:Point('TOP', f, 'TOP', 0, -4)
		f.vendorGraysButtonOld:Size(55, 10)
		f.vendorGraysButtonOld:SetTemplate('Default', true)
		f.vendorGraysButtonOld:SetBackdropColor(unpack(buttonColor))
		f.vendorGraysButtonOld.ttText = L['Vendor Grays']
		f.vendorGraysButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.vendorGraysButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.vendorGraysButtonOld:SetScript('OnClick', function() B:VendorGrayCheck(); end)

		--Sort Button
		f.sortButtonOld = CreateFrame('Button', nil, f)
		f.sortButtonOld:Point('LEFT', f.vendorGraysButtonOld, 'RIGHT', 3, 0)
		f.sortButtonOld:Size(55, 10)
		f.sortButtonOld:SetTemplate('Default', true)
		f.sortButtonOld:SetBackdropColor(unpack(buttonColor))
		f.sortButtonOld.ttText = L['Sort Bags']
		f.sortButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.sortButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.sortButtonOld:SetScript('OnClick', function() B:CommandDecorator(B.SortBags, 'bags')(); end)

		--Stack/Transfer Button Icon
		f.stackButton = CreateFrame("Button", name..'StackButton', f.holderFrame);
		f.stackButton:SetSize(16 + E.Border, 16 + E.Border)
		f.stackButton:SetTemplate()
		f.stackButton:SetPoint("RIGHT", f.goldText, "LEFT", -5, E.Border * 2)
		f.stackButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_RatCage")
		f.stackButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.stackButton:GetNormalTexture():SetInside()
		f.stackButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_RatCage")
		f.stackButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.stackButton:GetPushedTexture():SetInside()
		f.stackButton:StyleButton(nil, true)
		f.stackButton.ttText = L['Stack Items In Bags']
		f.stackButton.ttText2 = L['Hold Shift:']
		f.stackButton.ttText2desc = L['Stack Items To Bank']
		f.stackButton:SetScript("OnEnter", self.Tooltip_Show)
		f.stackButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.stackButton:SetScript('OnClick', function()
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bags bank')();
			else
				B:CommandDecorator(B.Compress, 'bags')();
			end
		end)

		--Stack/Transfer Button
		f.stackButtonOld = CreateFrame('Button', nil, f)
		f.stackButtonOld:Point('LEFT', f.sortButtonOld, 'RIGHT', 3, 0)
		f.stackButtonOld:Size(55, 10)
		f.stackButtonOld:SetTemplate('Default', true)
		f.stackButtonOld:SetBackdropColor(unpack(buttonColor))
		f.stackButtonOld.ttText = L['Stack Items In Bags']
		f.stackButtonOld.ttText2 = L['Hold Shift:']
		f.stackButtonOld.ttText2desc = L['Stack Items To Bank']
		f.stackButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.stackButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.stackButtonOld:SetScript('OnClick', function()
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bags bank')();
			else
				B:CommandDecorator(B.Compress, 'bags')();
			end
		end)

		--Bags Button
		f.bagsButtonOld = CreateFrame('Button', nil, f)
		f.bagsButtonOld:Point('RIGHT', f.vendorGraysButtonOld, 'LEFT', -3, 0)
		f.bagsButtonOld:Size(55, 10)
		f.bagsButtonOld:SetTemplate('Default', true)
		f.bagsButtonOld:SetBackdropColor(unpack(buttonColor))
		f.bagsButtonOld.ttText = L['Toggle Bags']
		f.bagsButtonOld:SetScript("OnEnter", B.Tooltip_Show)
		f.bagsButtonOld:SetScript("OnLeave", B.Tooltip_Hide)
		f.bagsButtonOld:SetScript('OnClick', function() ToggleFrame(f.ContainerHolder) end)
	end

	CT:SetBagButtonStylePosition(isBank)
	CT:SetButtonColors(isBank)
end
hooksecurefunc(B, "ContructContainerFrame", CreateContainerButtons)

function CT:SetBagButtonStylePosition(isBank)
	local f
	if isBank then
		f = _G["ElvUI_BankContainerFrame"]
	else
		f = _G["ElvUI_ContainerFrame"]
	end
	if not f then return; end

	if E.db.CustomTweaks.BagButtons.stackButton and E.db.CustomTweaks.BagButtons.style == "ICON" then
		f.stackButton:Show()
		f.stackButtonOld:Hide()
	elseif E.db.CustomTweaks.BagButtons.stackButton then
		f.stackButton:Hide()
		f.stackButtonOld:Show()
	else
		f.stackButton:Hide()
		f.stackButtonOld:Hide()
	end

	if E.db.CustomTweaks.BagButtons.style == "ICON" then
		f.sortButton:Show()
		f.bagsButton:Show()
		f.sortButtonOld:Hide()
		f.bagsButtonOld:Hide()
	else
		f.sortButton:Hide()
		f.bagsButton:Hide()
		f.sortButtonOld:Show()
		f.bagsButtonOld:Show()
	end

	if (isBank) then
		if E.db.CustomTweaks.BagButtons.style == "ICON" then
			f.purchaseBagButton:Show()
			f.purchaseBagButtonOld:Hide()
			if E.db.CustomTweaks.BagButtons.stackButton then
				f.sortButton:Point('RIGHT', f.stackButton, 'LEFT', -5, 0)
			else
				f.sortButton:Point("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
			end
			f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0);
		else
			f.purchaseBagButton:Hide()
			f.purchaseBagButtonOld:Show()
			if E.db.CustomTweaks.BagButtons.stackButton then
				f.sortButtonOld:Point('TOP', f, 'TOP', 0, -4)
			else
				if f.holderFrame:IsShown() then
					f.sortButtonOld:Point('TOP', f, 'TOP', 29, -4)
				end
			end
			f.editBox:Point('RIGHT', f.bagText, 'LEFT', -5, 0);
		end
	else
		if E.db.CustomTweaks.BagButtons.style == "ICON" then
			f.vendorGraysButton:Show()
			f.vendorGraysButtonOld:Hide()
			if E.db.CustomTweaks.BagButtons.stackButton then
				f.sortButton:Point('RIGHT', f.stackButton, 'LEFT', -5, 0)
			else
				f.sortButton:Point("RIGHT", f.goldText, "LEFT", -5, E.Border * 2)
			end
			f.editBox:Point('RIGHT', f.vendorGraysButton, 'LEFT', -5, 0);
		else
			f.vendorGraysButton:Hide()
			f.vendorGraysButtonOld:Show()
			if E.db.CustomTweaks.BagButtons.stackButton then
				f.vendorGraysButtonOld:Point('TOP', f, 'TOP', -29, -4)
			else
				f.vendorGraysButtonOld:Point('TOP', f, 'TOP', 0, -4)
			end
			f.editBox:Point('RIGHT', f.goldText, 'LEFT', -5, 0);
		end
	end
end

function CT:SetButtonColors(isBank)
	local buttonColor = E:GetColorTable(E.db.CustomTweaks.BagButtons.buttonColor)
	local f
	if isBank then
		f = _G["ElvUI_BankContainerFrame"]
	else
		f = _G["ElvUI_ContainerFrame"]
	end
	if not f then return; end

	f.sortButtonOld.SetBackdropColor = nil
	f.sortButtonOld:SetBackdropColor(unpack(buttonColor))
	f.sortButtonOld.SetBackdropColor = E.noop

	f.stackButtonOld.SetBackdropColor = nil
	f.stackButtonOld:SetBackdropColor(unpack(buttonColor))
	f.stackButtonOld.SetBackdropColor = E.noop

	f.bagsButtonOld.SetBackdropColor = nil
	f.bagsButtonOld:SetBackdropColor(unpack(buttonColor))
	f.bagsButtonOld.SetBackdropColor = E.noop
	
	if isBank then
		f.purchaseBagButtonOld.SetBackdropColor = nil
		f.purchaseBagButtonOld:SetBackdropColor(unpack(buttonColor))
		f.purchaseBagButtonOld.SetBackdropColor = E.noop
	else
		f.vendorGraysButtonOld.SetBackdropColor = nil
		f.vendorGraysButtonOld:SetBackdropColor(unpack(buttonColor))
		f.vendorGraysButtonOld.SetBackdropColor = E.noop
	end
end