local addonName, addon = ...
local Libra = LibStub("Libra")

do	-- faux scroll frame
	local function dummy() end
	
	local function onShow(self)
		if self.doUpdate then
			self:Update()
		end
	end
	
	local function onParentShow(self)
		onShow(self.scrollFrame)
	end

	local function onVerticalScroll(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, self.buttonHeight, self.Update)
	end
	
	local scrollPrototype = {}

	function scrollPrototype:Reset()
		self:SetOffset(0)
		self.ScrollBar:SetValue(0)
		self:Update()
	end
	
	function scrollPrototype:Update(...)
		if not self.parent:IsVisible() then
			self.doUpdate = true
			return
		end
		
		self:SetupButtons(self:PreUpdate())
		
		self:PostUpdate(...)
	end

	function scrollPrototype:SetupButtons(...)
		local list = self:GetList()
		if not list then return end
		
		local length = #list
		local buttons = self.buttons
		FauxScrollFrame_Update(self, length, #buttons, self.buttonHeight)
		local offset = self:GetOffset()
		for line = 1, #buttons do
			local lineplusoffset = line + offset
			local button = buttons[line]
			local show = lineplusoffset <= length
			if show then
				self:OnButtonShow(button, list[lineplusoffset], ...)
			end
			button:SetShown(show)
		end
		self.doUpdate = nil
	end

	function addon:CreateScrollframe(parent, numButtons, buttonHeight, buttonFactory, initialXOffset, initialYOffset)
		local scrollFrame = CreateFrame("ScrollFrame", Libra:GetWidgetName("Critline"), parent, "FauxScrollFrameTemplate")
		scrollFrame:SetScript("OnShow", onShow)
		scrollFrame:SetScript("OnVerticalScroll", onVerticalScroll)
		scrollFrame.GetOffset = FauxScrollFrame_GetOffset
		scrollFrame.SetOffset = FauxScrollFrame_SetOffset
		scrollFrame.Reset = scrollPrototype.Reset
		scrollFrame.PreUpdate = dummy
		scrollFrame.PostUpdate = dummy
		scrollFrame.Update = scrollPrototype.Update
		scrollFrame.SetupButtons = scrollPrototype.SetupButtons
		scrollFrame.buttonHeight = buttonHeight
		scrollFrame.buttons = {}
		for i = 1, numButtons do
			local button = buttonFactory(parent)
			if i == 1 then
				button:SetPoint("TOPLEFT", scrollFrame, initialXOffset, initialYOffset)
			else
				button:SetPoint("TOPLEFT", scrollFrame.buttons[i - 1], "BOTTOMLEFT")
			end
			button:SetPoint("RIGHT", scrollFrame.buttons[i - 1] or scrollFrame)
			button:SetHeight(buttonHeight)
			button:SetID(i)
			scrollFrame.buttons[i] = button
		end
		scrollFrame.parent = parent
		parent:HookScript("OnShow", onParentShow)
		parent.scrollFrame = scrollFrame
		return scrollFrame
	end
end

do	-- tab interface
	local function setLabel(self, text)
		self:SetText(text)
		self:SetWidth(self:GetTextWidth() + 16)
	end
	
	local function selectTab(frame, tabIndex)
		frame.selectedTab = tabIndex
		for i, tab in ipairs(frame.tabs) do
			local active = i == tabIndex
			tab:SetEnabled(not active)
			if tab.frame then
				tab.frame:SetShown(active)
			end
		end
		if frame.OnTabSelected then
			frame:OnTabSelected(tabIndex)
		end
	end
	
	local function onClick(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		selectTab(self.container, self:GetID())
	end
	
	local function onEnable(self)
		self:SetHeight(16)
		self.bg:SetColorTexture(0.7, 0.7, 0.7)
	end
	
	local function onDisable(self)
		self:SetHeight(20)
		self.bg:SetColorTexture(0.3, 0.3, 0.3)
	end
	
	local function createTab(frame)
		local tab = CreateFrame("Button", nil, frame)
		tab:SetSize(64, 16)
		tab:SetNormalFontObject(GameFontNormalSmall)
		tab:SetHighlightFontObject(GameFontHighlightSmall)
		tab:SetDisabledFontObject(GameFontHighlightSmall)
		tab:SetScript("OnClick", onClick)
		tab:SetScript("OnEnable", onEnable)
		tab:SetScript("OnDisable", onDisable)
		tab.SetLabel = setLabel
		tab.container = frame
		local highlight = tab:CreateTexture()
		highlight:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight]])
		highlight:SetPoint("BOTTOMLEFT", -2, -6)
		highlight:SetPoint("TOPRIGHT", 2, 6)
		tab:SetHighlightTexture(highlight)

		local index = #frame.tabs + 1
		if index == 1 then
			tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 6, 1)
		else
			tab:SetPoint("BOTTOMLEFT", frame.tabs[index - 1], "BOTTOMRIGHT", 6, 0)
		end
		tab:SetID(index)
		frame.tabs[index] = tab
		
		local bg = tab:CreateTexture(nil, "BORDER")
		bg:SetColorTexture(0.7, 0.7, 0.7)
		bg:SetBlendMode("MOD")
		bg:SetAllPoints()
		tab.bg = bg

		local border = tab:CreateTexture(nil, "BORDER", nil, -1)
		border:SetColorTexture(0.5, 0.5, 0.5, 0.3)
		border:SetPoint("TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", 1, 0)
		
		return tab
	end
	
	local function getSelectedTab(frame)
		return frame.selectedTab
	end
	
	function addon:CreateTabInterface(parent)
		local frame = CreateFrame("Frame", nil, parent)
		
		local bg = frame:CreateTexture(nil, "BORDER")
		bg:SetColorTexture(0.3, 0.3, 0.3)
		bg:SetBlendMode("MOD")
		bg:SetAllPoints()

		local border = frame:CreateTexture(nil, "BORDER", nil, -1)
		border:SetColorTexture(0.5, 0.5, 0.5, 0.3)
		border:SetPoint("TOPLEFT", bg, -1, 1)
		border:SetPoint("BOTTOMRIGHT", bg, 1, -1)

		frame.tabs = {}
		frame.CreateTab = createTab
		frame.SelectTab = selectTab
		frame.GetSelectedTab = getSelectedTab
		
		return frame
	end
end

do	-- popup
	local function onShow(self)
		self.button1:Disable()
	end
	
	local function editBoxOnEnterPressed(self, data)
		local parent = self:GetParent()
		if parent.button1:IsEnabled() then
			StaticPopupDialogs[parent.which].OnAccept(parent, data)
			parent:Hide()
		end
	end
	
	local function editBoxOnEscapePressed(self)
		self:GetParent():Hide()
	end
	
	local function editBoxOnTextChanged(self)
		local parent = self:GetParent()
		parent.button1:SetEnabled(parent.editBox:GetText():trim() ~= "")
	end
	
	function addon:CreatePopup(which, info, editBox)
		StaticPopupDialogs[which] = info
		info.hideOnEscape = true
		info.whileDead = true
		if editBox then
			info.button1 = ACCEPT
			info.button2 = CANCEL
			info.hasEditBox = true
			info.OnShow = onShow
			info.EditBoxOnEnterPressed = editBoxOnEnterPressed
			info.EditBoxOnEscapePressed = editBoxOnEscapePressed
			info.EditBoxOnTextChanged = editBoxOnTextChanged
		end
	end
end
