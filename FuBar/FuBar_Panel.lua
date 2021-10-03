FUBAR_VERSION = 90000 + tonumber(("$Revision: 3 $"):match("%d+"))

local Jostle = Rock("LibJostle-3.0", false, true)

local SPACING_FROM_SIDES = 5

local bgFile = [[Interface\AddOns\FuBar\background]]
local bgR, bgG, bgB

local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar")

local _G = getfenv(0)

FuBar_Panel = {}
local FuBar_Panel = FuBar_Panel
local FuBar_Panel_id = 0
local FuBar_Panel_instances = {}
FuBar_Panel.instances = FuBar_Panel_instances

function FuBar_Panel:OnJostleLoad(instance)
	Jostle = instance
	for i,v in ipairs(FuBar_Panel_instances) do
		if v.data.attachPoint == 'TOP' then
			Jostle:RegisterTop(v.frame)
		elseif self.data.attachPoint == 'BOTTOM' then
			Jostle:RegisterBottom(v.frame)
		end
	end
	Jostle:Refresh()
end

local FuBar_Panel_mt = {__index=FuBar_Panel}
function FuBar_Panel:new(...)
	local t = setmetatable({}, FuBar_Panel_mt)
	t:init(...)
	return t
end

function FuBar_Panel:SetBackground(bg)
	if bgFile ~= bg then
		bgFile = bg
		bgR, bgG, bgB = nil, nil, nil
		for _,v in ipairs(FuBar_Panel_instances) do
			v:UpdateTexture()
		end
	end
end

function FuBar_Panel:SetBackgroundColor(r,g,b)
	if bgR ~= r or bgG ~= g or bgB ~= b then
		bgFile = nil
		bgR, bgG, bgB = r, g, b
		for _,v in ipairs(FuBar_Panel_instances) do
			v:UpdateTexture()
		end
	end
end

function FuBar_Panel:IsBackground(bg)
	return bgFile == bg
end

function FuBar_Panel:GetBackgroundColor()
	return bgR, bgG, bgB
end

local frame_OnMouseUp = function(this, arg1)
	if arg1 == "RightButton" then
		this.panel:OpenMenu()
	elseif arg1 == "LeftButton" then
		this.panel:StopDrag()
		HideDropDownMenu(1)
	end
end
local frame_OnMouseDown = function(this, arg1)
	if arg1 == "LeftButton" then
		this.panel:StartDrag()
	end
end
local frame_OnDragStart = function(this)
	this.panel:StartDrag()
end
local frame_OnDragStop = function(this)
	this.panel:StopDrag()
end
local frame_OnEnter = function(this)
	FuBar:Panel_OnEnter(this.panel:GetAttachPoint())
end
local frame_OnLeave = function(this)
	FuBar:Panel_OnLeave(this.panel:GetAttachPoint())
end
local frame_OnSizeChanged = function(this)
	local panel = this.panel
	if this.lastWidth == GetScreenWidth() then
		panel.data.widthPercent = panel.frame:GetWidth() / GetScreenWidth()
	else
		this.lastWidth = GetScreenWidth()
	end
	panel:UpdateCenteredPosition()
	panel:UpdateTexture()
end
local left_OnEnter = function(this)
	if not this.panel:IsLocked() then
		SetCursor("ATTACK_ERROR_CURSOR")
	end
end
local left_OnLeave = ResetCursor
local right_OnEnter = left_OnEnter
local right_OnLeave = left_OnLeave
local left_OnMouseDown = function(this, arg1)
	if arg1 == "LeftButton" then
		this.panel:StartSizing('LEFT')
	end
end
local left_OnMouseUp = function(this, arg1)
	if arg1 == "RightButton" then
		this.panel:OpenMenu()
	elseif arg1 == "LeftButton" then
		this.panel:StopDrag()
	end
end
local right_OnMouseDown = function(this, arg1)
	if arg1 == "LeftButton" then
		this.panel:StartSizing('RIGHT')
	end
end
local right_OnMouseUp = left_OnMouseUp

local backdropsPerPanel = ceil(GetScreenWidth() / 256)

local topTexture
local bottomTexture

function FuBar_Panel:init(attachPoint)
	FuBar_Panel_id = FuBar_Panel_id + 1
	
	if type(FuBar.db.profile.panels) ~= "table" then
		FuBar.db.profile.panels = {}
	end
	if type(FuBar.db.profile.panels[FuBar_Panel_id]) ~= "table" then
		table.insert(FuBar.db.profile.panels, {})
	end
	if type(FuBar.db.profile.detached) ~= "table" then
		FuBar.db.profile.detached = {}
	end
	
	self.data = FuBar.db.profile.panels[FuBar_Panel_id]
	if not self.data then
		FuBar.db.profile.panels[FuBar_Panel_id] = {}
		self.data = FuBar.db.profile.panels[FuBar_Panel_id]
	end
	self.id = FuBar_Panel_id
	self.plugins = {
		left = {},
		center = {},
		right = {},
	}
	
	self.frame = _G["FuBarFrame" .. self.id]
	if not self.frame then
		local frame = CreateFrame("Frame", "FuBarFrame" .. self.id, UIParent)
		self.frame = frame
		
		if not topTexture then
			topTexture = frame:CreateTexture("FuBarFrameTopTexture", "ARTWORK")
			bottomTexture = frame:CreateTexture("FuBarFrameBottomTexture", "ARTWORK")
			topTexture:SetTexture(1, 1, 1)
			topTexture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0, 1, 1, 1, 0.5 * FuBar:GetTransparency())
			bottomTexture:SetTexture(1, 1, 1)
			bottomTexture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0.5 * FuBar:GetTransparency(), 1, 1, 1, 0)
			topTexture:Hide()
			bottomTexture:Hide()
		end
		
		frame:SetFrameStrata("HIGH")
		frame:SetFrameLevel(6)
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetWidth(500)
		frame:SetHeight(24)
		frame:SetPoint('TOP', UIParent, 'TOP')
		local left = CreateFrame("Frame", frame:GetName() .. 'LEFT', frame)
		left:SetPoint('TOPLEFT', frame, 'TOPLEFT')
		left:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', 5, 0)
		left:EnableMouse(true)
		left:Show()
		local right = CreateFrame("Frame", frame:GetName() .. 'RIGHT', frame)
		right:SetPoint('TOPRIGHT', frame, 'TOPRIGHT')
		right:SetPoint('BOTTOMLEFT', frame, 'BOTTOMRIGHT', -5, 0)
		right:EnableMouse(true)
		right:Show()
		frame.left = left
		frame.right = right
		frame.lastWidth = GetScreenWidth()
		frame:SetScript("OnMouseUp", frame_OnMouseUp)
		frame:SetScript("OnMouseDown", frame_OnMouseDown)
		frame:SetScript("OnDragStart", frame_OnDragStart)
		frame:SetScript("OnDragStop", frame_OnDragStop)
		frame:SetScript("OnEnter", frame_OnEnter)
		frame:SetScript("OnLeave", frame_OnLeave)
		frame:SetScript("OnSizeChanged", frame_OnSizeChanged)
		left:SetScript("OnEnter", left_OnEnter)
		left:SetScript("OnLeave", left_OnLeave)
		right:SetScript("OnEnter", right_OnEnter)
		right:SetScript("OnLeave", right_OnLeave)
		left:SetScript("OnMouseDown", left_OnMouseDown)
		left:SetScript("OnMouseUp", left_OnMouseUp)
		right:SetScript("OnMouseDown", right_OnMouseDown)
		right:SetScript("OnMouseUp", right_OnMouseUp)
		
		frame.bgTextures = {}
		local lastTexture
		for i = 1, backdropsPerPanel do
			local texture = frame:CreateTexture(frame:GetName() .. "Texture" .. i, "BACKGROUND")
			texture:SetWidth(256)
			texture:SetHeight(256)
			if not lastTexture then
				texture:SetPoint('TOPLEFT', frame, 'TOPLEFT')
			else
				texture:SetPoint('LEFT', lastTexture, 'RIGHT')
			end
			if bgFile then
				texture:SetTexture(bgFile)
			else
				texture:SetTexture(bgR, bgG, bgB)
			end
			table.insert(frame.bgTextures, texture)
			lastTexture = texture
		end
	end
	
	self.bgTextures = self.frame.bgTextures
	self.frame.panel = self
	self.frame.left.panel = self
	self.frame.right.panel = self
	
	if not FuBar_Panel_instances[self.id] then
		table.insert(FuBar_Panel_instances, self)
	else
		FuBar_Panel_instances[self.id] = self
	end
	
	if not self.data.attachPoint then
		self.data.attachPoint = attachPoint or 'TOP'
	end
	
	if not self.data.plugins then
		self.data.plugins = {
			left = {},
			right = {},
			center = {},
		}
	end
	
	if not self.frame:IsShown() then
		self.frame:Show()
	end
	
	self.stopUpdates = nil
	
	for _,v in ipairs(FuBar_Panel_instances) do
		v:Update()
		v:UpdateTexture()
	end
	if self.data.attachPoint == 'TOP' then
		if Jostle then
			Jostle:RegisterTop(self.frame)
		end
		self.frame:SetFrameStrata("HIGH")
		self.frame:SetFrameLevel(6)
	elseif self.data.attachPoint == 'BOTTOM' then
		if Jostle then
			Jostle:RegisterBottom(self.frame)
		end
		self.frame:SetFrameStrata("HIGH")
		self.frame:SetFrameLevel(6)
	else
		self.frame:SetFrameStrata("MEDIUM")
		self.frame:SetFrameLevel(1)
	end
	FuBar:DispatchEvent("ChangedPanels")
	local AceEvent = Rock("AceEvent-2.0", true, true)
	if AceEvent then
		AceEvent:TriggerEvent("FuBar_ChangedPanels")
	end
	if Jostle then
		Jostle:Refresh()
	end
end

function FuBar_Panel:del(force)
	assert(force or FuBar_Panel_id > 1, "Cannot destroy only panel.")
	
	if topTexture.attachedTo == self then
		topTexture:ClearAllPoints()
		topTexture:Hide()
		topTexture.attachedTo = nil
	end
	if bottomTexture.attachedTo == self then
		bottomTexture:ClearAllPoints()
		bottomTexture:Hide()
		bottomTexture.attachedTo = nil
	end
	
	for h = 1, 3 do
		local t, position
		if h == 1 then
			t = self.plugins.left
			position = 'LEFT'
		elseif h == 2 then
			t = self.plugins.center
			position = 'CENTER'
		else
			t = self.plugins.right
			position = 'RIGHT'
		end
		for i = #t, 1, -1 do
			local plugin = t[i]
			self:RemovePlugin(i, position)
			plugin:Hide()
		end
	end
	
	for i = self.id + 1, FuBar_Panel_id do
		if FuBar_Panel_instances[i]:GetAttachPoint() == self.data.attachPoint then
			self:SwitchWithPanel(i)
		end
	end
	
	if Jostle then
		Jostle:Unregister(self.frame)
	end
	if not force then
		self:SetAttachPoint('NONE')
	end
	self.frame:Hide()
	
	if not force then
		table.remove(FuBar.db.profile.panels, self.id)
	end
	self.data = nil
	self.plugins = nil
	table.remove(FuBar_Panel_instances, self.id)
	
	FuBar_Panel_id = FuBar_Panel_id - 1
	FuBar:DispatchEvent("ChangedPanels")
	local AceEvent = Rock("AceEvent-2.0", true, true)
	if AceEvent then
		AceEvent:TriggerEvent("FuBar_ChangedPanels")
	end
	for i = 1, FuBar_Panel_id do
		local panel = FuBar_Panel_instances[i]
		panel.id = i
		panel:UpdateTexture()
		panel:Update()
	end
	
	if Jostle then
		Jostle:Refresh()
	end
end

function FuBar_Panel:WarnDestroy()
	if self:GetNumPlugins('LEFT') + self:GetNumPlugins('CENTER') + self:GetNumPlugins('RIGHT') == 0 then
		self:del()
	else
		if not StaticPopupDialogs["FUBAR_DESTROY_PANEL"] then
			StaticPopupDialogs["FUBAR_DESTROY_PANEL"] = {
				text = L["Are you sure you want to remove this panel?"],
				button1 = L["Remove panel"],
				button2 = CANCEL,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 1,
			}
		end
		StaticPopupDialogs["FUBAR_DESTROY_PANEL"].OnAccept = function()
			self:del()
		end
		StaticPopup_Show("FUBAR_DESTROY_PANEL")
	end
end

function FuBar_Panel:SwitchWithPanel(id, preventUpdate)
	local other = FuBar_Panel_instances[id]
	if not other or self.data.attachPoint ~= other.data.attachPoint then
		return
	end
	other.id, self.id = self.id, other.id
	other.frame, self.frame = self.frame, other.frame
	self.frame.panel = self
	other.frame.panel = other
	self.frame.left.panel = self
	other.frame.right.panel = other
	FuBar_Panel_instances[other.id] = other
	FuBar_Panel_instances[self.id] = self
	FuBar.db.profile.panels[other.id], FuBar.db.profile.panels[self.id] = FuBar.db.profile.panels[self.id], FuBar.db.profile.panels[other.id]
	self.bgTextures, other.bgTextures = other.bgTextures, self.bgTextures
	if not preventUpdate then
		other:Update()
		self:Update()
	end
	for i = 1, FuBar_Panel_id do
		FuBar_Panel_instances[i]:UpdateTexture()
	end
	FuBar:DispatchEvent("ChangedPanels")
	local AceEvent = Rock("AceEvent-2.0", true, true)
	if AceEvent then
		AceEvent:TriggerEvent("FuBar_ChangedPanels")
	end
	if Jostle then
		Jostle:Refresh()
	end
end

function FuBar_Panel:GetAttachPoint()
	if not self.data then
		ReloadUI()
		return
	end
	return self.data.attachPoint
end

function FuBar_Panel:SetAttachPoint(point)
	if self.data.attachPoint == point then
		return
	end
	if Jostle then
		Jostle:Unregister(self.frame)
	end
	if point == 'NONE' then
		self.data.yPercent = 0.5 - (FuBarFrame1:GetHeight()/2 / GetScreenHeight())
		self.frame:SetFrameStrata("MEDIUM")
		self.frame:SetFrameLevel(1)
	elseif point == 'TOP' or point == 'BOTTOM' then
		self.data.yPercent = nil
		self.frame:SetFrameStrata("HIGH")
		self.frame:SetFrameLevel(6)
	else
		assert(false, "Improper attach point given: " .. point)
	end
	
	local previous = self.data.attachPoint
	self.data.attachPoint = point
	for i = self.id, FuBar_Panel_id do
		local panel = FuBar_Panel_instances[i]
		if previous == panel:GetAttachPoint() or point == panel:GetAttachPoint() then
			panel:Update()
		end
	end
	self:Update()
	
	if Jostle then
		Jostle:Refresh()
	end
	
	if self:IsLocked() then
		self:ToggleLocked()
	end
	
	if Jostle then
		if self.data.attachPoint == 'TOP' then
			Jostle:RegisterTop(self.frame)
		elseif self.data.attachPoint == 'BOTTOM' then
			Jostle:RegisterBottom(self.frame)
		end
	end
	
	for i = 1, FuBar_Panel_id do
		FuBar_Panel_instances[i]:UpdateTexture()
	end
	
	FuBar:DispatchEvent("ChangedPanels")
	local AceEvent = Rock("AceEvent-2.0", true, true)
	if AceEvent then
		AceEvent:TriggerEvent("FuBar_ChangedPanels")
	end
	if Jostle then
		Jostle:Refresh()
	end
	
	if FuBar:IsAutoHidingTop() then
		FuBar:ToggleAutoHidingTop()
		FuBar:ToggleAutoHidingTop()
	end
	if FuBar:IsAutoHidingBottom() then
		FuBar:ToggleAutoHidingBottom()
		FuBar:ToggleAutoHidingBottom()
	end
end

function FuBar_Panel:IsLocked()
	return self.data and self.data.lock
end

function FuBar_Panel:ToggleLocked()
	if self.data then
		self.data.lock = not self.data.lock
		return self.data.lock
	end
end

function FuBar_Panel:GetPositionFromEdge()
	local num = 1
	local set = 0
	if self.data.attachPoint == 'TOP' then
		for i = 1, FuBar_Panel_id do
			local panel = FuBar_Panel_instances[i]
			if panel == self then
				set = num
				num = num + 1
			elseif panel and panel:GetAttachPoint() == 'TOP' then
				num = num + 1
			end
		end
	elseif self.data.attachPoint == 'BOTTOM' then
		for i = 1, FuBar_Panel_id do
			local panel = FuBar_Panel_instances[i]
			if panel == self then
				set = num
				num = num + 1
			elseif panel and panel:GetAttachPoint() == 'BOTTOM' then
				num = num + 1
			end
		end
	else
		return
	end
	return num - set
end

function FuBar_Panel:UpdateTexture()
	if topTexture.attachedTo == self then
		topTexture:ClearAllPoints()
		topTexture:Hide()
		topTexture.attachedTo = nil
	end
	if bottomTexture.attachedTo == self then
		bottomTexture:ClearAllPoints()
		bottomTexture:Hide()
		bottomTexture.attachedTo = nil
	end
	local point = self:GetAttachPoint()
	local height = FuBar:GetFontSize() + FuBar:GetThickness()
	self.frame:SetHeight(height)
	
	local uiscale = 768 / GetScreenHeight()
	local texsize = 256 / uiscale
	local realLeft = self.frame:GetLeft() or 0
	local left = mod(self.frame:GetLeft() or 0, texsize)
	local width = self.frame:GetWidth() or 0
	local fromEdge = self:GetPositionFromEdge()
	if fromEdge and self.bgTextures then
		local y1, y2
		if self.data.attachPoint == 'TOP' then
			y1, y2 = 1-((height) / texsize) * fromEdge, 1-(height / 256) * (fromEdge - 1)
		else
			y1, y2 = ((height + 2) / texsize) * (fromEdge - 1), ((height+2) / 256) * fromEdge
		end
		for i,texture in ipairs(self.bgTextures) do
			if bgFile then
				texture:SetTexture(bgFile)
			else
				texture:SetTexture(bgR, bgG, bgB)
			end
			local x = (i - 1) * texsize
			local xr = i * texsize
			texture:Show()
			texture:SetHeight(height)
			local x1, x2 = 0, 1
			local changed = false
			if i == 1 then
				x1 = left / texsize
				texture:SetWidth(texsize - left)
				changed = true
			end
			if width + left < xr then
				if i == 1 then
					texture:SetWidth(width)
					x2 = mod(width + left - x, texsize) / texsize
				else
					texture:SetWidth(mod(width + left - x, texsize))
					x2 = mod(width + left - x, texsize) / texsize
				end
			elseif not changed then
				texture:SetWidth(texsize)
			end
			texture:SetPoint('TOPLEFT', self.frame, 'TOPLEFT', x + x1*texsize - left, 0)
			texture:SetTexCoord(x1, x2, y1, y2)
			texture:SetVertexColor(1, 1, 1, FuBar:GetTransparency())
		end
	elseif self.bgTextures then
		local y1, y2 = 0.5 - height / texsize / 2, 0.5 + height / texsize / 2
		for i,texture in ipairs(self.bgTextures) do
			if bgFile then
				texture:SetTexture(bgFile)
			else
				texture:SetTexture(bgR, bgG, bgB)
			end
			local x = (i - 1) * texsize
			local xr = i * texsize
			texture:Show()
			texture:SetHeight(height)
			local changed = false
			local x1, x2 = 0, 1
			if width < xr then
				texture:SetWidth(mod(width - x, texsize))
				x2 = mod(width - x, texsize) / texsize
			else
				texture:SetWidth(texsize)
			end
			texture:SetTexCoord(x1, x2, y1, y2)
			texture:SetVertexColor(1, 1, 1, FuBar:GetTransparency())
		end
	end
end

function FuBar_Panel:AddPlugin(plugin, index, side, isDefaultSide)
	if FuBar:IsChangingProfile() then
		return
	end
	if side == "MINIMAP" then
		side = "LEFT"
	end
	if plugin:GetPanel() then
		plugin:GetPanel():RemovePlugin(plugin)
	end
	plugin:SetPanel(self)
	if FuBar.db.profile.detached then
		FuBar.db.profile.detached[plugin:GetTitle()] = nil
	end
	plugin:GetFrame():SetParent(self.frame)
	
	if not FuBar.db.profile.places then
		FuBar.db.profile.places = {}
	end
	if FuBar.db.profile.places.left and FuBar.db.profile.places.left[plugin:GetTitle()] then
		FuBar.db.profile.places.left[plugin:GetTitle()] = nil
		if not side or isDefaultSide then
			side = 'LEFT'
		end
	end
	if FuBar.db.profile.places.center and FuBar.db.profile.places.center[plugin:GetTitle()] then
		FuBar.db.profile.places.center[plugin:GetTitle()] = nil
		if not side or isDefaultSide then
			side = 'CENTER'
		end
	end
	if FuBar.db.profile.places.right and FuBar.db.profile.places.right[plugin:GetTitle()] then
		FuBar.db.profile.places.right[plugin:GetTitle()] = nil
		if not side or isDefaultSide then
			side = 'RIGHT'
		end
	end
	if not side then
		side = 'LEFT'
	end
	local positioned = false
	for h = 1, 3 do
		local t, dt
		if h == 1 then
			t = self.plugins.left
			dt = self.data.plugins.left
		elseif h == 2 then
			t = self.plugins.center
			dt = self.data.plugins.center
		else
			t = self.plugins.right
			dt = self.data.plugins.right
		end
		for i, value in ipairs(dt) do
			if value == plugin:GetTitle() then
				for j = i - 1, 1, -1 do
					local otherName = dt[j]
					for k, p in ipairs(t) do
						if p:GetTitle() == otherName then
							table.insert(t, k + 1, plugin)
							positioned = true
							break
						end
					end
					if positioned then
						break
					end
				end
				if not positioned then
					table.insert(t, 1, plugin)
					positioned = true
				end
				break
			end
		end
		if positioned then
			break
		end
	end
	
	if not positioned then
		local title = plugin:GetTitle()
		local t, dt
		if side == 'RIGHT' then
			t, dt = self.plugins.right, self.data.plugins.right
		elseif side == 'CENTER' then
			t, dt = self.plugins.center, self.data.plugins.center
		else
			t, dt = self.plugins.left, self.data.plugins.left
		end
		if not index then
			table.insert(t, plugin)
			table.insert(dt, title)
		else
			if index == 1 then
				table.insert(t, index, plugin)
				table.insert(dt, 1, title)
			else
				table.insert(t, index, plugin)
				local name = t[index - 1]:GetTitle()
				local done = false
				for k, v in ipairs(dt) do
					if name == v then
						table.insert(dt, k + 1, title)
						done = true
						break
					end
				end
				if not done then
					table.insert(dt, title)
				end
			end
		end
	end
	plugin:GetFrame():Show()
	if plugin.minimapFrame then
		plugin.minimapFrame:Hide()
	end
	if not positioned then
		assert(self:GetPluginSide(plugin) == side, ("Assertion failed: %q == %q"):format(self:GetPluginSide(plugin), side))
	end
	self:Update()
	Rock("LibRockConfig-1.0"):RefreshConfigMenu(FuBar)
	return true
end

function FuBar_Panel:RemovePlugin(index, side)
	if FuBar:IsChangingProfile() then
		return
	end
	if type(index) == "table" then
		index, side = self:IndexOfPlugin(index)
		if not index then
			return
		end
	end
	
	local t, dt
	if not FuBar.db.profile.places then
		FuBar.db.profile.places = {}
	end
	if side == 'RIGHT' then
		if not FuBar.db.profile.places.right then
			FuBar.db.profile.places.right = {}
		end
		t, dt = self.plugins.right, self.data.plugins.right
		FuBar.db.profile.places.right[t[index]:GetTitle()] = true
	elseif side == 'CENTER' then
		if not FuBar.db.profile.places.center then
			FuBar.db.profile.places.center = {}
		end
		t, dt = self.plugins.center, self.data.plugins.center
		FuBar.db.profile.places.center[t[index]:GetTitle()] = true
	else
		if not FuBar.db.profile.places.left then
			FuBar.db.profile.places.left = {}
		end
		t, dt = self.plugins.left, self.data.plugins.left
		FuBar.db.profile.places.left[t[index]:GetTitle()] = true
	end
	
	local plugin = t[index]
	assert(plugin:GetPanel() == self, "Plugin has improper panel field")
	plugin:SetPanel(nil)
	if not self.stopUpdates then
		plugin:GetFrame():Hide()
		if plugin.minimapFrame then
			plugin.minimapFrame:Hide()
		end
	end
	for i = 1, #dt do
		if dt[i] == plugin:GetTitle() then
			table.remove(dt, i)
		end
	end
	table.remove(t, index)
	FuBar.db.profile.detached[plugin:GetTitle()] = true
	self:Update()
	Rock("LibRockConfig-1.0"):RefreshConfigMenu(FuBar)
end

function FuBar_Panel:GetPlugin(index, side)
	if not self.plugins then
		ReloadUI()
		return
	end
	if side == 'RIGHT' then
		return self.plugins.right[index]
	elseif side == 'CENTER' then
		return self.plugins.center[index]
	else
		return self.plugins.left[index]
	end
end

function FuBar_Panel:GetNumPlugins(side)
	if side == 'RIGHT' then
		return #self.plugins.right
	elseif side == 'CENTER' then
		return #self.plugins.center
	else
		return #self.plugins.left
	end
end

function FuBar_Panel:IndexOfPlugin(plugin)
	for i = 1, self:GetNumPlugins('LEFT') do
		if self.plugins.left[i] == plugin then
			return i, 'LEFT'
		end
	end
	for i = 1, self:GetNumPlugins('CENTER') do
		if self.plugins.center[i] == plugin then
			return i, 'CENTER'
		end
	end
	for i = 1, self:GetNumPlugins('RIGHT') do
		if self.plugins.right[i] == plugin then
			return i, 'RIGHT'
		end
	end
end

function FuBar_Panel:HasPlugin(plugin)
	return self:IndexOfPlugin(plugin) ~= nil
end

function FuBar_Panel:GetPluginSide(plugin)
	local index, side = self:IndexOfPlugin(plugin)
	assert(index, "Plugin not in panel")
	return side
end

function FuBar_Panel:SetPluginSide(plugin, side)
	local oldSide = self:GetPluginSide(plugin)
	if oldSide ~= side then
		self:RemovePlugin(plugin)
		self:AddPlugin(plugin, nil, side)
		self:Update()
	end
end

function FuBar_Panel:PreventUpdate()
	self.stopUpdates = true
end

function FuBar_Panel:StopPreventUpdate(code)
	self.stopUpdates = false
end

function FuBar_Panel:Update()
	if self.stopUpdates then
		return
	end
	if not self.data.widthPercent or self.data.widthPercent > 1 then
		self.data.widthPercent = 1
	end
	local width = self.data.widthPercent * GetScreenWidth()
	self.frame:SetWidth(width)
	
	if not self.data.xPercent or not self.data.yPercent then
		self.data.xPercent = 0.5 - self.data.widthPercent / 2
		self.data.yPercent = 0.5
	end
	if self:GetAttachPoint() == 'TOP' then
		self.frame:ClearAllPoints()
		local hasTop = nil
		for i = self.id - 1, 1, -1 do
			if FuBar_Panel_instances[i] and FuBar_Panel_instances[i]:GetAttachPoint() == 'TOP' then
				hasTop = FuBar_Panel_instances[i]
				break
			end
		end
		
		if not hasTop then
			self.frame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', self.data.xPercent * GetScreenWidth(), 1)
		else
			self.frame:SetPoint('TOPLEFT', hasTop.frame, 'BOTTOMLEFT', self.data.xPercent * GetScreenWidth() - (hasTop.frame:GetLeft() or 0), 0)
		end
	elseif self:GetAttachPoint(panelId) == 'BOTTOM' then
		self.frame:ClearAllPoints()
		local hasBottom = nil
		for i = self.id - 1, 1, -1 do
			if FuBar_Panel_instances[i] and FuBar_Panel_instances[i]:GetAttachPoint() == 'BOTTOM' then
				hasBottom = FuBar_Panel_instances[i]
				break
			end
		end
		if not hasBottom then
			self.frame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', self.data.xPercent * GetScreenWidth(), -1)
		else
			self.frame:SetPoint('BOTTOMLEFT', hasBottom.frame, 'TOPLEFT', self.data.xPercent * GetScreenWidth() - hasBottom.frame:GetLeft(), 0)
		end
	else
		self.frame:ClearAllPoints()
		self.frame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', self.data.xPercent * GetScreenWidth(), self.data.yPercent * GetScreenHeight())
	end
	
	local num = 0
	
	for h = 1, 3 do
		local t, side
		if h == 1 then
			t = self.plugins.left
			side = 'LEFT'
		elseif h == 2 then
			t = self.plugins.center
			side = 'CENTER'
		else
			t = self.plugins.right
			side = 'RIGHT'
		end
		local i = 1
		while i <= self:GetNumPlugins(side) do
			assert(t[i], "nil plugin spot")
			if type(t[i].IsDisabled) == "function" and t[i]:IsDisabled() then
				self:RemovePlugin(i, side)
				i = i - 1
			end
			i = i + 1
		end
	end
	
	for h = 1, 3 do
		local t, side
		if h == 1 then
			t = self.plugins.left
			side = 'LEFT'
		elseif h == 2 then
			t = self.plugins.center
			side = 'CENTER'
		else
			t = self.plugins.right
			side = 'RIGHT'
		end
		for i = 1, self:GetNumPlugins(side) do
			t[i]:CheckWidth()
			t[i]:GetFrame():SetParent(self.frame)
			t[i]:GetFrame():ClearAllPoints()
		end
	end
	
	for h = 1, 3 do
		local t, side, alpha, bravo, sideSpacing, spacing
		if h == 1 then
			t = self.plugins.left
			side = 'LEFT'
			alpha, bravo = 'LEFT', 'RIGHT'
			sideSpacing = SPACING_FROM_SIDES
			spacing = FuBar:GetLeftSpacing()
		elseif h == 2 then
			t = self.plugins.center
			side = 'CENTER'
			alpha, bravo = 'LEFT', 'RIGHT'
			sideSpacing = SPACING_FROM_SIDES
			spacing = FuBar:GetCenterSpacing()
		else
			t = self.plugins.right
			side = 'RIGHT'
			alpha, bravo = 'RIGHT', 'LEFT'
			sideSpacing = -SPACING_FROM_SIDES
			spacing = -FuBar:GetRightSpacing()
		end
		for i = 1, self:GetNumPlugins(side) do
			t[i]:GetFrame():Show()
			if i == 1 then
				t[i]:GetFrame():SetPoint(alpha, self.frame, alpha, sideSpacing, 0)
			else
				if t[i]:GetFrame() == t[i-1]:GetFrame() then
					t[i]:GetFrame():SetPoint(alpha, self.frame, bravo, spacing, 0)
				else
					t[i]:GetFrame():SetPoint(alpha, t[i-1]:GetFrame(), bravo, spacing, 0)
				end
			end
		end
	end
	
	self:UpdateCenteredPosition()
	self:CheckForOverlap()
end

function FuBar_Panel:UpdateCenteredPosition()
	if self:GetPlugin(1, 'CENTER') then
		local num = self:GetNumPlugins('CENTER')
		local width = num * FuBar:GetCenterSpacing()
		for i = 1, num do
			width = width + self.plugins.center[i]:GetFrame():GetWidth()
		end
		
		local frame = self:GetPlugin(1, 'CENTER'):GetFrame()
		frame:ClearAllPoints()
		frame:SetPoint('LEFT', self.frame, 'LEFT', (self.data.widthPercent * GetScreenWidth() - width) / 2, 0)
	end
end

function FuBar_Panel:GetSavedOrder(side)
	local key
	if side == 'RIGHT' then
		key = "right"
	elseif side == 'CENTER' then
		key = "center"
	else
		key = "left"
	end
	if not self.data.plugins[key] then
		self.data.plugins[key] = {}
	end
	return self.data.plugins[key]
end

function FuBar_Panel:ResetSavedOrder(side)
	local t
	if side == 'RIGHT' then
		t = self.data.plugins.right
	elseif side == 'CENTER' then
		t = self.data.plugins.center
	else
		t = self.data.plugins.left
	end
	for key in pairs(t) do
		t[key] = nil
	end
end

function FuBar_Panel:OpenMenu()
	FuBar:OpenConfigMenu("bar" .. self.id)
end

local closePanel
function FuBar_Panel:StartSizing(direction)
	DropDownList1:Hide()
	if not self:IsLocked() then
		local x, y = FuBar:GetScaledCursorPosition()
		local left, right = self.frame:GetLeft(), self.frame:GetRight()
		if self:GetAttachPoint() ~= 'NONE' then
			self.lastWidth = self.frame:GetWidth()
		end
		self.frame:StartSizing(direction)
		self.sizeFrom = direction
		closePanel = nil
		for i = self.id + 1, FuBar_Panel_id do
			local panel = FuBar_Panel_instances[i]
			if panel:GetAttachPoint() == self:GetAttachPoint() then
				closePanel = panel
				local x, y = closePanel.frame:GetLeft(), closePanel.frame:GetBottom()
				closePanel.frame:ClearAllPoints()
				closePanel.frame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', x, y)
				break
			end
		end
	end
end

local lastX, lastY

function FuBar_Panel:StartDrag()
	if not self:IsLocked() and self:GetAttachPoint() == 'NONE' then
		self.frame:StartMoving()
	elseif not self:IsLocked() then
		self.frame:StartMoving()
		closePanel = nil
		for i = self.id + 1, FuBar_Panel_id do
			local panel = FuBar_Panel_instances[i]
			if panel and panel:GetAttachPoint() == self:GetAttachPoint() then
				closePanel = panel
				local x, y = closePanel.frame:GetLeft(), closePanel.frame:GetBottom()
				closePanel.frame:ClearAllPoints()
				closePanel.frame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', x, y)
				break
			end
		end
		lastX, lastY = self.frame:GetCenter()
	end
end

function FuBar_Panel:StopDrag()
	self.frame:StopMovingOrSizing()
	local x, y = self.frame:GetCenter()
	local offsetX = 0
	if self.frame:GetWidth() < 50 then
		if self.sizeFrom == 'LEFT' then
			offsetX = self.frame:GetWidth() - 50
		end
		self.frame:SetWidth(50)
	elseif self.frame:GetWidth() > GetScreenWidth() then
		if self.sizeFrom == 'RIGHT' then
			offsetX = self.frame:GetWidth() - self.frame:GetRight()
		else
			offsetX = -self.frame:GetLeft()
		end
		self.frame:SetWidth(GetScreenWidth())
	end
	self.sizeFrom = nil
	self.data.xPercent = (self.frame:GetLeft() + offsetX) / GetScreenWidth()
	self.data.yPercent = self.frame:GetBottom() / GetScreenHeight()
	self.data.widthPercent = self.frame:GetWidth() / GetScreenWidth()
	if self.data.xPercent < 0 then
		self.data.xPercent = 0
	elseif self.data.xPercent + self.data.widthPercent > 1 then
		self.data.xPercent = 1 - self.data.widthPercent
	end
	self:Update()
	if closePanel then
		closePanel:Update()
		closePanel = nil
	end
	if lastY then
		if self:GetAttachPoint() == 'TOP' then
			if y < GetScreenHeight() / 2 then
				self:SetAttachPoint('BOTTOM')
			end
		else
			if y > GetScreenHeight() /2 then
				self:SetAttachPoint('TOP')
			end
		end
		if self:GetAttachPoint() == 'TOP' then
			local position = 0
			for i = 1, FuBar_Panel_id do
				if i ~= self.id then
					local other = FuBar_Panel_instances[i]
					if other:GetAttachPoint() == 'TOP' then
						if y <= select(2, other.frame:GetCenter()) then
							position = i
						end
					end
				else
					if y <= lastY then
						position = i
					end
				end
			end
			lastY = nil
			if position < self.id then
				position = position + 1
			end
			local shift = position - self.id
			local num = 0
			if shift < 0 then
				for i = 1, -shift do
					num = num + 1
					if FuBar_Panel_instances[self.id - num]:GetAttachPoint() == 'TOP' then
						self:SwitchWithPanel(self.id - num)
						num = 0
					end
				end
			elseif shift > 0 then
				for i = 1, shift do
					num = num + 1
					if FuBar_Panel_instances[self.id + num]:GetAttachPoint() == 'TOP' then
						self:SwitchWithPanel(self.id + num)
						num = 0
					end
				end
			end
		elseif self:GetAttachPoint() == 'BOTTOM' then
			local position = 0
			for i = 1, FuBar_Panel_id do
				if i ~= self.id then
					local other = FuBar_Panel_instances[i]
					if other:GetAttachPoint() == 'BOTTOM' then
						if y >= select(2, other.frame:GetCenter()) then
							position = i
						end
					end
				else
					if y >= lastY then
						position = i
					end
				end
			end
			lastY = nil
			if position < self.id then
				position = position + 1
			end
			local shift = position - self.id
			local num = 0
			if shift < 0 then
				for i = 1, -shift do
					num = num + 1
					if FuBar_Panel_instances[self.id - num]:GetAttachPoint() == 'BOTTOM' then
						self:SwitchWithPanel(self.id - num)
						num = 0
					end
				end
			elseif shift > 0 then
				for i = 1, shift do
					num = num + 1
					if FuBar_Panel_instances[self.id + num]:GetAttachPoint() == 'BOTTOM' then
						self:SwitchWithPanel(self.id + num)
						num = 0
					end
				end
			end
		end
	end
	self:UpdateTexture()
end

function FuBar_Panel:HasOverlap()
	local leftNum, centerNum, rightNum = self:GetNumPlugins('LEFT'), self:GetNumPlugins('CENTER'), self:GetNumPlugins('RIGHT')
	local left = self:GetPlugin(leftNum, 'LEFT')
	local right = self:GetPlugin(rightNum, 'RIGHT')
	local centerLeft = self:GetPlugin(1, 'CENTER')
	local centerRight = self:GetPlugin(centerNum, 'CENTER')
	
	if centerLeft then
		if left and left.frame:GetRight() and centerLeft.frame:GetLeft() then
			if left and left.frame:GetRight() >= centerLeft.frame:GetLeft() - 5 then
				return true
			end
		end
		return right and right.frame:GetLeft() and centerRight.frame:GetRight() and right.frame:GetLeft() <= centerRight.frame:GetRight() + 5
	elseif left and right then
		if left.frame:GetRight() and right.frame:GetLeft() then
			return left.frame:GetRight() >= right.frame:GetLeft() - 5
		end
	elseif left then
		if left.frame:GetRight() and self.frame:GetRight() then
			return left.frame:GetRight() > self.frame:GetRight() - 5
		end
	elseif right then
		if right.frame:GetLeft() and self.frame:GetLeft() then
			return right.frame:GetLeft() < self.frame:GetLeft() + 5
		end
	end
	
	return false
end

local loadTime = GetTime() + 8
function FuBar_Panel:CheckForOverlap()
	if loadTime > GetTime() then
		if not self.overlapTimer then
			self.overlapTimer = true
			FuBar:AddTimer("FuBar_Panel:CheckForOverlap", loadTime - GetTime(), self.CheckForOverlap, self)
		end
		return
	end
	self.overlapTimer = nil
	if FuBar:IsOverflowing() and self:HasOverlap() then
		local side = 'CENTER'
		local plugin = self:GetPlugin(self:GetNumPlugins(side), side)
		if not plugin then
			side = 'LEFT'
			plugin = self:GetPlugin(self:GetNumPlugins(side), side)
			if not plugin then
				side = 'RIGHT'
				plugin = self:GetPlugin(self:GetNumPlugins(side), side)
			end
		end
		local panel
		for i = self.id + 1, FuBar_Panel_id do
			if FuBar_Panel_instances[i]:GetAttachPoint() == self:GetAttachPoint() then
				panel = FuBar_Panel_instances[i]
			end
		end
		if not panel then
			panel = FuBar_Panel:new(self:GetAttachPoint())
		end
		FuBar_Panel:PreventUpdate()
		self:RemovePlugin(plugin)
		panel:AddPlugin(plugin, 1, side)
		FuBar_Panel:StopPreventUpdate()
		panel:Update()
		self:Update()
	end
end
