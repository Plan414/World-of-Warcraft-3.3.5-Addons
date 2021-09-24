-- Texture slicing code copied from Rabbit, who copied from !BeatyCase, who thanked Phanx.
-- Default texture from 
local frame = CreateFrame("Frame", "XLootFrame", UIParent)
local _G, opt = _G

-- Default options
local defaults = {
	frame_scale = 1.0,
	frame_alpha = 1.0,
	
	frame_color_background = { 0, 0, 0, .7 },
	frame_color_border =  { .7, .7, .7, 1 },
	
	frame_border_quality = false,
	frame_background_quality = false,
	
	loot_color_background = { 0, 0, 0, .9 },
	loot_color_border = { .5, .5, .5, 1 },
	
	loot_border_quality = true,
	loot_highlight_quality = true,
	loot_highlight_threshold = 2,
		
	loot_texts_info = true,
	loot_texts_bind  = true,
	loot_texts_quality = false,
	loot_texts_info_color = { .5, .5, .5, 1 },
	
	frame_snap = true,
	frame_snap_offset_x = 0,
	frame_snap_offset_y = 0,
	
	frame_draggable = true,
	
	linkall_visible = "always",
	linkall_threshold = 2,
	linkall_channel = "RAID",
	
	position = {
		x = UIParent:GetWidth()/2,
		y = UIParent:GetHeight()/2
	}
}

local default_texture = [[Interface\AddOns\XLoot1.0\textures\svelte_square]]


-- Custom skinning:
-- skin_texture should be the path to a square texture that is a square border, like a ButtonFacade skin
---- In order to use your own skin, XLoot must be set to Blizzard in ButtonFacade - if it is being used
-- [optional] skin_colors is a table of {r, g, b}
-- [optional] skin_border_size is the desired border thickness
-- [optional] skin_pad_item is the amount of inner padding item icons should have
-- [optional] skin_pad_row is the amount of inner padding rows should have
-- [optional] skin_spacing_row is the amount of space rows need between eachother (for large borders)
local skin_texture = nil
local skin_colors = nil
local skin_border_size = nil
local skin_pad_item = nil
local skin_pad_row = nil
local skin_spacing_row = nil


--------------------------------------------
-- Optionally supported libraries --
--------------------------------------------
local AC, LBF, LBF_hacks
local print = print
if LibStub then
	-- Ace Console (Debug print)
	AC = LibStub("AceConsole-2.0", true)
	if AC then print = function(...) AC:PrintLiteral(...) end end
	
	-- Button Facade (Extra skins)
	LBF = LibStub('LibButtonFacade', true)
	if LBF and not skin_texture then
		-- [skin name] = { border_size[, pad_item[, pad_row[, spacing_row]]] }
		local LBF_hacks = {
			['simpleSquare'] = { 12 }
		}
		local group
		LBF:RegisterSkinCallback('XLoot', function(_, skin, _, _, _, _, colors)
			if skin ~= 'Blizzard' then
				skin_texture = LBF:GetSkins()[skin].Normal.Texture
				skin_colors = colors.Normal
				if LBF_hacks[skin] then
					skin_border_size, skin_pad_item, skin_pad_row, skin_spacing_row = unpack(LBF_hacks[skin])
				end
			end
		end)
		group = LBF:Group('XLoot')
	end
	
	if not skin_texture then
		skin_texture = default_texture
		skin_colors = { .7, .7, .7 } 
	end
end

-----------------------------
-- Soulbind scanning --
-----------------------------
local function GetBindOn(item)
	if not XLootTooltip then CreateFrame('GameTooltip', 'XLootTooltip', UIParent, 'GameTooltipTemplate') end
	local tt = XLootTooltip
	tt:SetOwner(UIParent, 'ANCHOR_NONE')
	tt:SetHyperlink(item)
	if XLootTooltip:NumLines() > 1  and XLootTooltipTextLeft2:GetText() then
		local t = XLootTooltipTextLeft2:GetText()
		tt:Hide()
		if t == ITEM_BIND_ON_PICKUP then
			return 'pickup'
		elseif t == ITEM_BIND_ON_EQUIP then
			return 'equip'
		elseif t == ITEM_BIND_ON_USE then
			return 'use'
		end
	end
	tt:Hide()
	return nil
end

local bop, boe, bou
local function BindText(bind, text)
	if not bop then
		bop = ('|cffff4cff%s|r '):format('BoP')
		boe = ('|cff4cff4c%s|r '):format('BoE')
		bou = ('|cff4c7fff%s|r '):format('BoU')
	end
	local out = bind == 'pickup' and bop or bind == 'equip' and boe or bind == 'use' and bou or ''
	text:SetText(out)
	return out
end


-----------------
-- Skinning --
-----------------
-- Helpers
local backdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
}

local function createBorder(self, size)
	local border = self:CreateTexture(nil, "ARTWORK")
	border:SetTexture(skin_texture)
	border:SetWidth(size)
	border:SetHeight(size)
	if skin_colors then 
		border:SetVertexColor(unpack(skin_colors))
	else
		border:SetVertexColor(1, 1, 1)
	end
	return border
end

local function ApplyBorders(self, padding)
	local borders = {}
	local borderSize = skin_border_size or 16
	padding = padding or 2
	for i = 1, 8 do
		local border = createBorder(self, borderSize)
		borders[i] = border
		if i == 1 then
			border:SetTexCoord(0, 1/3, 0, 1/3) 
			border:SetPoint("TOPLEFT", -padding, padding)
		elseif i == 2 then
			border:SetTexCoord(2/3, 1, 0, 1/3)
			border:SetPoint("TOPRIGHT", padding, padding)
		elseif i == 3 then
			border:SetTexCoord(0, 1/3, 2/3, 1)
			border:SetPoint("BOTTOMLEFT", -padding, -padding)
		elseif i == 4 then
			border:SetTexCoord(2/3, 1, 2/3, 1)
			border:SetPoint("BOTTOMRIGHT", padding, -padding)
		elseif i == 5 then
			border:SetTexCoord(1/3, 2/3, 0, 1/3)
			border:SetPoint("TOPLEFT", borders[1], "TOPRIGHT")
			border:SetPoint("TOPRIGHT", borders[2], "TOPLEFT")
		elseif i == 6 then
			border:SetTexCoord(1/3, 2/3, 2/3, 1)
			border:SetPoint("BOTTOMLEFT", borders[3], "BOTTOMRIGHT")
			border:SetPoint("BOTTOMRIGHT", borders[4], "BOTTOMLEFT")
		elseif i == 7 then
			border:SetTexCoord(0, 1/3, 1/3, 2/3)
			border:SetPoint("TOPLEFT", borders[1], "BOTTOMLEFT")
			border:SetPoint("BOTTOMLEFT", borders[3], "TOPLEFT")
		elseif i == 8 then
			border:SetTexCoord(2/3, 1, 1/3, 2/3)
			border:SetPoint("TOPRIGHT", borders[2], "BOTTOMRIGHT")
			border:SetPoint("BOTTOMRIGHT", borders[4], "TOPRIGHT")
		end
	end
	frame.borders = borders
	frame.SetBackdropBorderColor = function(self, r, g, b)
		for _, b in pairs(self.borders) do
			b:SetVertexColor(r, g, b)
		end
	end
end

local function SetGradientColor(self, r, g, b)
	local f = self.overlay or self
	f.gradient:SetGradientAlpha('VERTICAL', .1, .1, .1, 0, r, g, b, 0.6)
end
local function SetHighlightColor(self, r, g, b)
	local f = self.overlay or self
	if r then
		f.highlight:SetGradientAlpha('VERTICAL', .1, .1, .1, 0, r, g, b, 0.3)
		f.highlight:Show()
	else
		f.highlight:Hide()
	end
end

local function skin(frame, gradient, highlight, overlay, padding)
	-- Overlay frame
	local skinned = frame
	if overlay then --overlay then
		local ov = CreateFrame('Frame', nil, frame)
		ov:SetPoint('TOPLEFT', -3, 3)
		ov:SetPoint('BOTTOMRIGHT', 3, -3)
		frame = ov
		skinned.overlay = ov
	end
	
	-- Set backdrop and border
	-- if not skin_texture and not backdrop.edgeFile then
		-- backdrop.edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]]
		-- backdrop.edgeSize = 12
	-- end
	frame:SetBackdrop(backdrop)
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	frame:SetBackdropColor(0, 0, 0, overlay and 0 or 0.9)
	
	-- Backdrop gradient
	if gradient then
		local g = frame:CreateTexture(nil, 'BORDER')
		frame.gradient = g
		g:SetTexture[[Interface\ChatFrame\ChatFrameBackground]]
		g:SetPoint('TOPLEFT', 2, -2)
		g:SetPoint('BOTTOMRIGHT', -2, 2)
		g:SetBlendMode'ADD'
		skinned.SetGradientColor = SetGradientColor
		skinned:SetGradientColor(.5, .5, .5)
		g:Show()
	end
	
	-- Frame highlight
	if highlight then
		local h = frame:CreateTexture(nil, 'BORDER')
		frame.highlight = h
		h:SetTexture[[Interface\ChatFrame\ChatFrameBackground]]
		h:SetPoint('TOPLEFT', 2, -2)
		h:SetPoint('BOTTOMRIGHT', -2, 2)
		h:SetBlendMode'ADD'
		skinned.SetHighlightColor = SetHighlightColor
		skinned:SetHighlightColor()
	end
	
	if skin_texture then
		ApplyBorders(frame, padding)
	end
end


-------------------------
-- Frame creation --
-------------------------
-- Fontstring shortcuts
local font = STANDARD_TEXT_FONT
local function smalltext(text, size, ext)
	text:SetFont(font, size or 10, ext or '')
	text:SetDrawLayer'OVERLAY'
	text:SetHeight(10)
	text:SetJustifyH'LEFT'
end

local function textpoints(text, item, row, x)
	text:SetPoint('LEFT', item, 'RIGHT', x, 0)
	text:SetPoint('RIGHT', row)
	text.offset_x = x
end

-- Row events
local function OnEnter(self)
	if LootSlotIsItem(self.slot) then
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:SetLootItem(self.slot)
	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem() end
		CursorUpdate()
	end
end

local function OnLeave(self)
	GameTooltip:Hide()
	ResetCursor()
end

local function OnUpdate(self)
	CursorUpdate(self)
end
local function SnapFrame()
	local x, y = GetCursorPosition()
	local f = XLootFrame
	local s = f:GetEffectiveScale()
	
	-- Horizontal position
	if opt.frame_snap and not f:IsShown() then
		x = (x / s) - 30
		local sWidth, fWidth, uWidth = GetScreenWidth(), f:GetWidth(), UIParent:GetWidth()
		if uWidth > sWidth then sWidth = uWidth end
		if x + fWidth > sWidth then x = sWidth - fWidth end
		if x < 0 then x = 0 end
		x = x + opt.frame_snap_offset_x
	else
		x = f:GetLeft() or x
	end
	
	-- Vertical position 
	if opt.frame_snap then
		y = (y / s) + 30
		local sHeight, fHeight, uHeight = GetScreenHeight(), f:GetHeight(), UIParent:GetHeight()
		if uHeight > sHeight then sHeight = uHeight end
		if y > sHeight then y = sHeight end
		if y - fHeight < 0 then y = fHeight end
		y = y + opt.frame_snap_offset_y
	else
		y = f:GetTop() or y
	end
	
	-- Apply
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local function OnDragStart() 
	if opt.frame_draggable then 
		XLootFrame:StartMoving() 
	end
end

local function OnDragStop()
	XLootFrame:StopMovingOrSizing()
	opt.position.x = XLootFrame:GetLeft()
	opt.position.y = XLootFrame:GetTop()
end 

local function ClickLinkLoot()
	LinkLoot(opt.linkall_channel)
end


-- Helpers
local function SetTexts(self, name, info, bind, quantity)
	self.text_name:SetText(name)
	self.text_info:SetText(info)
	self.text_bind:SetText(bind)
	self.text_quantity:SetText(quantity > 1 and quantity or nil)
end

local function SetTex(self, texture)
	self.texture_item:SetTexture(texture)
end

local function SetBorderColor(self, r, g, b, a)
	self:SetBackdropBorderColor(r, g, b, a or 1)
	self.frame_item:SetBackdropBorderColor(r, g, b, a or 1)
end

local function SetHighlights(self, r, g, b)
	self:SetHighlightColor(r, g, b)
	self.frame_item:SetHighlightColor(r, g, b)
end

local function OffsetText(self, text, y)
	text:SetPoint('TOP', self, 0, y)
end

-- Build individual loot row
local rows = { }
local row_height = nil
local function BuildRow(slot)
	-- Create frames
	local row = CreateFrame('Button', 'XLootButton'..slot, XLootFrame)
	local item = CreateFrame('Frame', nil, row)
	local tex = item:CreateTexture()

	-- Create fontstrings
	local name = row:CreateFontString('XLootButton'..slot..'Text') -- Stupid, stuuupid blizzard
	local info = row:CreateFontString()
	local bind = item:CreateFontString()
	local quantity = item:CreateFontString()

	-- Setup fontstrings
	smalltext(name, 12)
	smalltext(info)
	smalltext(bind, 9, 'outline')
	smalltext(quantity, 11, 'outline')
	textpoints(name, item, row, 4)
	textpoints(info, item, row, 10)
	bind:ClearAllPoints()
	--bind:SetPoint('CENTER', 0, 6)
	quantity:SetPoint('BOTTOMRIGHT', -3, 3)
	info:SetTextColor(unpack(opt.loot_texts_info_color))

	-- Align frames
	row:SetHeight(30)
	row:SetPoint('LEFT', 10, 0)
	row:SetPoint('RIGHT', -10, 0)
	
	item:SetPoint('LEFT', 3, 0)
	item:SetHeight(28)
	item:SetWidth(28)
	tex:SetAllPoints()
	tex:SetTexCoord(.07,.93,.07,.93)

	-- Skin row
	skin(row, true, true, nil, skin_pad_row)
	skin(item, true, true, true, skin_pad_item)
	row_height = row:GetHeight() + 2 + (skin_spacing_row or 0)

	-- Wire row
	row:RegisterForDrag('LeftButton')
	row:SetScript('OnDragStart', OnDragStart)
	row:SetScript('OnDragStop', OnDragStop)
	row:SetScript('OnEnter', OnEnter)
	row:SetScript('OnLeave', OnLeave)
	row:SetScript('OnUpdate', OnUpdate)
	row:SetScript('OnClick', function(self, button)
			if IsModifiedClick() then
				HandleModifiedItemClick(GetLootSlotLink(self.slot))
			else
				LootButton_OnClick(self, button)
			end
		end) -- Don't break other addons

	-- Set references
	row.text_name = name
	row.text_info = info
	row.text_bind = bind
	row.text_quantity = quantity
	row.frame_item = item
	row.texture_item = tex
	
	-- Helpers
	row.SetTexts = SetTexts
	row.SetTex = SetTex
	row.OffsetText = OffsetText
	row.SetBorderColor = SetBorderColor
	row.SetHighlights = SetHighlights

	return row
end

-- Build frame
local built = false
local function BottomButton(name, text, justify)
	local b = CreateFrame('Button', name, XLootFrame)
	b.text = b:CreateFontString(name..'Text', 'DIALOG', 'GameFontNormalSmall')
	b.text:SetText('|c22AAAAAA'..text)
	b.text:SetJustifyH(justify)
	b.text:SetAllPoints(b)
	b:SetFrameLevel(8)
	b:SetWidth(45)
	b:SetHeight(16)
	b:SetHighlightTexture[['Interface\Buttons\UI-Panel-MinimizeButton-Highlight']]
	b:ClearAllPoints()
	b:SetPoint('BOTTOM', 0, 2)
	b:SetHitRectInsets(-4, -4, 3, -2)
	b:Show()
	return b
end
local function BuildFrame()
	built = true
	-- Setup frame
	local f = frame
	f:SetFrameStrata'DIALOG'
	f:SetFrameLevel(5)
	f:SetMovable(1)
	f:EnableMouse(1)
	f:RegisterForDrag'LeftButton'

	-- Events
	f:SetScript('OnDragStart', OnDragStart)
	f:SetScript('OnDragStop', OnDragStop)

	-- Skin
	skin(f, true)

  	-- Options button
	-- local ob = CreateFrame('Button', nil, XLootFrame)
	-- ob:SetScript('OnClick', function() LibStub('AceConfigDialog-3.0'):Open('XLoot') end)
	-- ob:SetFrameLevel(8)
	-- ob:SetWidth(18)
	-- ob:SetHeight(18)
	-- ob:SetNormalTexture[['Interface\Addons\Recount\Textures\icon-config']]
	-- ob:SetHighlightTexture[['Interface\Buttons\UI-Panel-MinimizeButton-Highlight']]
	-- ob:ClearAllPoints()
	-- ob:SetPoint('BOTTOMRIGHT', -3, 3)
	-- ob:SetHitRectInsets(2, 2, 2, 2)
	-- ob:Show()

   	-- Link all button
	local lb = BottomButton('XLootLinkButton', 'Link', 'LEFT')
	lb:SetPoint('LEFT', 11, 0)
	lb:SetScript('OnClick', ClickLinkLoot)
	
	-- Close button
	local cb = BottomButton('XLootCloseButton', 'Close', 'RIGHT')
	cb:SetPoint('RIGHT', -11, 0)
	cb:SetScript('OnClick', function() CloseLoot() end)

	f.close = cb
	f.link = lb
	f:Hide()
end

-- Default display
local slots = {}
local function Update()
	local numloot = GetNumLootItems()

	-- Build frame if it doesn't exist
	if not built then
		BuildFrame()
	end

	-- Add any needed rows
	while #rows < numloot do
		local new = #rows + 1
		rows[new] = BuildRow(new)
	end

	-- Update individual loot frames
	local maxquality, maxwidth, shiftslot, item = 0, 0, 0
	for slot=1, numloot do
		if GetLootSlotInfo(slot) then
			shiftslot = shiftslot + 1
			-- Fetch item, row, and locals
			local texture, itemname, quantity, quality, link, r, g, b, h = GetLootSlotInfo(slot)
			local row = rows[shiftslot]
			local tname, tinfo = row.text_name, row.text_info
			local newinfo, newname, newbind = '', '', ''
			local isitem = LootSlotIsItem(slot)
			slots[shiftslot] = row
			
			-- Attach row
			if slot == 1 then
				row:SetPoint('TOP', 0, -10)
			else
				row:SetPoint('TOP', slots[shiftslot-1], 'BOTTOM', 0, -2)
			end

			-- Set row as occupied
			row.item = link
			row.quality = quality

			-- Let blizzard handle onclick - This is just a loot frame mod.
			row.slot = slot
			row:SetID(slot)
			
			-- Build item information
			if isitem then
				-- Update locals
				link = GetLootSlotLink(slot)
				r, g, b, h = GetItemQualityColor(quality)
				-- Item name
				newname = ('%s%s|r'):format(h, itemname)
				-- Item information text
				local _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(link)
				local equip = itemType == ENCHSLOT_WEAPON and ENCHSLOT_WEAPON or itemEquipLoc ~= '' and _G[itemEquipLoc] or ''
				local itemtype = (itemSubType == 'Junk' and quality > 0) and MISCELLANEOUS or itemSubType
				newinfo = ((type(equip) == 'string' and equip ~= '') and equip..', ' or '') .. itemtype
				
				-- Icon bind text
				newbind = BindText(GetBindOn(link), row.text_bind)
				
			-- It's money
			else
				r, g, b = .4, .4, .4
				newname = itemname:gsub('\n', ', ')
			end
			
			-- Update row
			row:SetTexts(newname, newinfo, newbind, quantity)
			row:SetTex(texture)

			-- Update maximums
			if opt.frame_border_quality and isitem then
				maxquality = math.max(maxquality, quality)
			end
			maxwidth = math.max(maxwidth, tinfo:GetStringWidth(), tname:GetStringWidth())

			-- Re-align fontstrings layout
			local layout = isitem and 'item' or 'coin'
			if row.layout ~= layout then
				row.layout = layout
				if layout == 'coin' then
					row:OffsetText(tname, -8)
				else
					row:OffsetText(tname, -4)
					row:OffsetText(tinfo, -15)
				end
			end

			-- Color borders
			if opt.loot_border_quality then
				row:SetBorderColor(r, g, b)
			else
				row:SetBorderColor(unpack(opt.loot_color_border))
			end

			-- Set highlights
			if isitem and quality >= opt.loot_highlight_threshold then
				if opt.loot_highlight_quality then
					row:SetHighlights(r, g, b)
				else row:SetHighlights() end
			else
				row:SetHighlights()
			end
			
			row:Show()
		end
	end

	-- Update frame width
	frame:SetWidth(maxwidth + 64)

	-- Update frame height and scale
	frame:SetHeight(24 + #slots*row_height)
	frame:SetScale(opt.frame_scale)
	
	-- Update frame alpha
	frame:SetAlpha(opt.frame_alpha)
	
	-- Color frame
	local r, g, b
	if opt.frame_border_quality or opt.frame_background_quality and not frame:IsVisible() then
		r, g, b = GetItemQualityColor(maxquality)
		-- Highest qualty border
		if opt.frame_border_quality then
			frame:SetBackdropBorderColor(r, g, b, 1)
		else
			frame:SetBackdropBorderColor(unpack(opt.frame_color_border))
		end
		-- Highest quality frame
		if opt.frame_background_quality then
			frame:SetBackdropColor(r, g, b, opt.frame_color_background[4])
		else
			frame:SetBackdropColor(unpack(opt.frame_color_background))
		end
	end

	-- Display Link All button
	local vis = opt.linkall_channel
	if vis == 'SAY' or (vis == 'GUILD' and IsInGuild()) or (vis == 'RAID' and GetNumRaidMembers() > 0) or (vis == 'PARTY' and GetNumPartyMembers() > 0) then
		XLootLinkButton:Show()
	else
		XLootLinkButton:Hide()
	end

	-- Position frame
	SnapFrame()

	-- Ta-DA
	frame:Show()
end

local function clear(slot)
	if not slot then return nil end
	slot.slot = nil
	slot.item = nil
	slot.quality = nil
	slot:Hide()
end

local function Closed()
	for _,slot in pairs(rows) do
		clear(slot)
	end
	for s in pairs(slots) do
		slots[s] = nil
	end
	frame:Hide()
	StaticPopup_Hide"LOOT_BIND"
end

local function Opened()
	if GetNumLootItems() > 0 then
			Update()
		if not XLootFrame:IsShown() and IsFishingLoot() then
			PlaySound("FISHING REEL IN")
		end
	else
		CloseLoot()
	end
end

local function Cleared(slot)
	-- Find the cleared slot
	for k, v in ipairs(slots) do if v.slot == slot then slot = k end end
	-- Get neighbors
	local prev, next = slots[slot-1], slots[slot+1]
	-- Reattach neighbors
	if prev and next then
		next:SetPoint('TOP', prev, 'BOTTOM', nil, skin_spacing_row)
	elseif next then
		next:SetPoint('TOP', 0, -10)
	end
	clear(slots[slot])
	table.remove(slots, slot)
	frame:SetHeight(24 + #slots*row_height)
end

local output = { }
local function LinkLoot(channel, isExtraChannel)
	local output, key, buffer = output, 1
	local sf = string.format
	
	if UnitExists"target" then
		output[1] = sf('%s:', UnitName"target")
	end
	
	local linkthreshold, thresholdreached = opt.linkall_threshold, false
	for i=1, GetNumLootItems() do
		if LootSlotIsItem(i) then
			local texture, item, quantity, rarity = GetLootSlotInfo(i)
			local link = GetLootSlotLink(i)
			if rarity >= linkthreshold then
				thresholdreached = true
				buffer = sf('%s%s%s', (output[key] and output[key].." " or ""), (quantity > 1 and quantity.."x" or ""), link)
				if strlen(buffer) > 255 then 
					key = key + 1
					output[key] = (quantity > 1 and quantity.."x" or "")..link
				else
					output[key] = buffer
				end
			end
		end
	end
	
	if not thresholdreached then
		return false
	end
	
	for k, v in pairs(output) do
		v  = string.gsub(v, "\n", " ", 1, true) -- DIE NEWLINES, DIE A HORRIBLE DEATH 
		SendChatMessage(v, channel)
		output[k] = nil
	end
	
	return true
end

-----------------------
-- Initialization --
-----------------------

frame:SetScript("OnEvent", function(self, event) if event == "VARIABLES_LOADED" then
	local defaults = defaults
	-- Options init
	if (not XLoot_Options) then
		XLoot_Options = {}
	end
	opt = setmetatable(XLoot_Options, { __index = defaults })
	
	-- Event handling
	local events = {
		LOOT_OPENED = Opened,
		LOOT_SLOT_CLEARED = Cleared,
		LOOT_CLOSED = Closed
	}
	for e in pairs(events) do
		frame:RegisterEvent(e)
	end
	frame:SetScript("OnEvent", function(_, e, ...) if events[e] then events[e](...) end end)
	
	-- Kill LootFrame's scripts
	LootFrame:UnregisterEvent("LOOT_OPENED")
	LootFrame:UnregisterEvent("LOOT_SLOT_CLEARED")
	LootFrame:UnregisterEvent("LOOT_CLOSED")
end end)
frame:RegisterEvent("VARIABLES_LOADED")