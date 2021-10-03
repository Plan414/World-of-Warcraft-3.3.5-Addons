Baggins = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0", "AceDebug-2.0", "FuBarPlugin-2.0", "AceHook-2.1")

local Baggins = Baggins
local pt = LibStub("LibPeriodicTable-3.1", true)
local L = AceLibrary("AceLocale-2.2"):new("Baggins")
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local LBU = LibStub("LibBagUtils-1.0")


Baggins.hasIcon = "Interface\\Icons\\INV_Jewelry_Ring_03"
Baggins.cannotDetachTooltip = true
Baggins.clickableTooltip = true
Baggins.independentProfile = true
Baggins.hideWithoutStandby = true

BINDING_HEADER_BAGGINS = L["Baggins"]
BINDING_NAME_BAGGINS_TOGGLEALL = L["Toggle All Bags"]

local equiplocs = {
	INVTYPE_AMMO = 0, 
	INVTYPE_HEAD = 1, 
	INVTYPE_NECK = 2, 
	INVTYPE_SHOULDER = 3, 
	INVTYPE_BODY = 4, 
	INVTYPE_CHEST = 5, 
	INVTYPE_ROBE = 5, 
	INVTYPE_WAIST = 6, 
	INVTYPE_LEGS = 7, 
	INVTYPE_FEET = 8, 
	INVTYPE_WRIST = 9, 
	INVTYPE_HAND = 10, 
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 13, 
	INVTYPE_CLOAK = 15, 
	INVTYPE_WEAPON = 16,
	INVTYPE_SHIELD = 17, 
	INVTYPE_2HWEAPON = 16, 
	INVTYPE_WEAPONMAINHAND = 16, 
	INVTYPE_WEAPONOFFHAND = 17, 
	INVTYPE_HOLDABLE = 17, 
	INVTYPE_RANGED = 18, 
	INVTYPE_THROWN = 18, 
	INVTYPE_RANGEDRIGHT = 18, 
	INVTYPE_RELIC = 18, 
	INVTYPE_TABARD = 19, 
	INVTYPE_BAG = 20,
}
local currentbag
local currentsection
local currentcategory

local catsorttable = {}
Baggins.itemcounts = {}

local tconcat = table.concat
local format = string.format
local band = bit.band
local wipe=wipe
local type = type
local function new() return {} end
local function del(t) wipe(t) end
local rdel = del



-- internal signalling minilibrary

local signals = {}

function Baggins:RegisterSignal(name, handler, arg1)		-- Example: RegisterSignal("MySignal", self.SomeHandler, self)
	assert(arg1);
	if not signals[name] then
		signals[name] = {}
	end
	signals[name][handler]=arg1;
end

function Baggins:FireSignal(name, ...)		-- Example: FireSignal("MySignal", 1, 2, 3);
	if signals[name] then
		for handler,arg1 in pairs(signals[name]) do
			handler(arg1, ...);
		end
	end
end

local function PT3ModuleSet(name, value)
	Baggins.db.account.pt3mods[name] = value
	if value then
		LoadAddOn(name)
	end
end

local function PT3ModuleGet(name)
	return Baggins.db.account.pt3mods[name]
end

function Baggins:OnInitialize()
	self.bagframes = {}
	self.colors = {
		black = {r=0,g=0,b=0,hex="|cff000000"},
		white = {r=1,g=1,b=1,hex="|cffffffff"},
		blue = {r=0,g=0.5,b=1,hex="|cff007fff"},
		purple = {r=1,g=0.4,b=1,hex="|cffff66ff"},
	}
	
	self:InitOptions()
	
	self.OnMenuRequest = self.opts

	--self:RegisterEditTablets()
	
	self.dewdropparent = CreateFrame("frame",nil,UIParent)
	self.dewdropparent:SetHeight(1)
	self.dewdropparent:SetWidth(1)
	self.dewdropparent:SetPoint("CENTER",UIParent,"CENTER",0,0)

	self:RegisterWaterfall()
	self:BuildWaterfallTree()

	
	self.ptsetsdirty = true
	
	local PT3Modules
	if pt then
		for i = 1, GetNumAddOns() do
			local metadata = GetAddOnMetadata(i, "X-PeriodicTable-3.1-Module")
			if metadata then
				local name, _, _, enabled = GetAddOnInfo(i)
				if enabled then
					PT3Modules = PT3Modules or {}
				  PT3Modules[name] = true
				end
		  end
		end
	end
	
	if PT3Modules then
		self.opts.args.PT3LOD = {
				name = L["PT3 LoD Modules"],
				type = "group",
				desc = L["Choose PT3 LoD Modules to load at startup, Will load immediately when checked"],
				order = 135,
				args = {	
					
				},
			}
		local order = 1
		for name in pairs(PT3Modules) do
			self.opts.args.PT3LOD.args[name] = {
				name = name,
				type = "toggle",
				order = order,
				desc = L["Load %s at Startup"]:format(name),
				passValue = name,
				get = PT3ModuleGet,
				set = PT3ModuleSet,
			}
			order = order + 1
		end
	end
	
	self:RegisterChatCommand({ "/baggins" }, self.opts, "BAGGINS")
	
end

function Baggins:OnEnable(firstload)
	--self:SetBagUpdateSpeed();
	self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", "UpdateItemButtonCooldowns")
	self:RegisterEvent("ITEM_LOCK_CHANGED", "UpdateItemButtonLocks")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "OnBankChanged")
	self:RegisterEvent("BANKFRAME_CLOSED", "OnBankClosed")
	self:RegisterEvent("BANKFRAME_OPENED", "OnBankOpened")
	self:RegisterEvent("PLAYER_MONEY", "UpdateMoneyFrame")
	self:RegisterEvent('AUCTION_HOUSE_SHOW', "AuctionHouse")
	self:RegisterEvent('AUCTION_HOUSE_CLOSED', "CloseAllBags")
	--self:RegisterEvent("PLAYER_REGEN_ENABLED");
	--self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent('Baggins_RefreshBags')
	self:RegisterEvent('Baggins_CategoriesChanged')
	self:RegisterBucketEvent('ADDON_LOADED', 5,'OnAddonLoaded')
	
	self:RegisterSignal('CategoryMatchAdded', self.CategoryMatchAdded, self)
	self:RegisterSignal('CategoryMatchRemoved', self.CategoryMatchRemoved, self)
	self:RegisterSignal('SlotMoved', self.SlotMoved, self)
	
	self:ScheduleRepeatingEvent(self.RunBagUpdates,20,self)
	
	self:Hook("OpenBackpack", true)
	self:Hook("CloseBackpack", true)
	self:UpdateBagHooks()
	self:Hook("CloseSpecialWindows", true)
	self:HookScript(BankFrame,"OnEvent","BankFrame_OnEvent")
	--force an update of all bags on first opening
	self.doInitialUpdate = true
	self.doInitialBankUpdate = true
	self:ResortSections()
	--self:SetDebugging(true)
	
	if firstload then
		if pt then
			for name, load in pairs(self.db.account.pt3mods) do
				if GetAddOnMetadata(name, "X-PeriodicTable-3.1-Module") then
					if load then
						LoadAddOn(name)
					end
				else
					self.db.account.pt3mods[name] = nil
				end
			end
		end
		
		if self.db.profile.hideduplicates == true then
			self.db.profile.hideduplicates = "global"
	    end
			self:CreateMoneyFrame()
	end
	self:UpdateMoneyFrame()
	self:EnableSkin(self.db.profile.skin)

	self:OnProfileEnable()
end

function Baggins:Baggins_CategoriesChanged()
	self:UpdateBags()
	self.doInitialBankUpdate = true
end

function Baggins:BankFrame_OnEvent(...)
	if not self:IsActive() or not self.db.profile.hidedefaultbank then
		self.hooks[BankFrame].OnEvent(...)
	end
end

function Baggins:UpdateBagHooks()
	if self.db.profile.overridedefaultbags then
		self:Hook("OpenAllBags", "ToggleAllBags", true)
		self:Hook("CloseAllBags", true)
		self:Hook("ToggleBackpack", true)
	else
		if self:IsHooked("OpenAllBags") then
			self:Unhook("OpenAllBags")
		end
		if self:IsHooked("CloseAllBags") then
			self:Unhook("CloseAllBags")
		end
		if self:IsHooked("ToggleBackpack") then
			self:Unhook("ToggleBackpack")
		end
	end
end

function Baggins:OnDisable()
	self:CloseAllBags()
end

function Baggins:SaveItemCounts()
	local itemcounts = self.itemcounts
	wipe(itemcounts)
	for bag,slot,link in LBU:Iterate("BAGS") do	-- includes keyring
		if link then
			local id = tonumber(link:match("item:(%d+)"))
			if id and not itemcounts[id] then
				itemcounts[id] = GetItemCount(id)
			end
		end
	end
	for slot = 0, INVSLOT_LAST_EQUIPPED do	-- 0--19
		local link = GetInventoryItemLink("player",slot)
		if link then
			local id = tonumber(link:match("item:(%d+)"))
			if id and not itemcounts[id] then
				itemcounts[id] = GetItemCount(id)
			end
		end
	end
	for slot = 1+CONTAINER_BAG_OFFSET, NUM_BAG_SLOTS+CONTAINER_BAG_OFFSET do  -- 20--23
		local link = GetInventoryItemLink("player",slot)
		if link then
			local id = tonumber(link:match("item:(%d+)"))
			if id and not itemcounts[id] then
				itemcounts[id] = GetItemCount(id)
			end
		end
	end
end

function Baggins:IsCompressed(itemID)
	local p = self.db.profile
	if self.tempcompressnone then
		return false
	end
	--slot sorting will break compression horribly
	if p.sort == "slot" then
		return false
	end
	if p.compressall then
		return true
	end
	--string id's here are empty slots
	if type(itemID) == "string" and p.compressempty then
		return true
	end

	if type(itemID) == "number" then
		local itemFamily = GetItemFamily(itemID)
		local _, _, _, _, _, _, _, itemStackCount, itemEquipLoc = GetItemInfo(itemID)
		if itemFamily then	-- likes to be nil during login
			if p.compressshards and band(itemFamily,4)~=0 and itemEquipLoc~="INVTYPE_BAG" then
				return true
			end
			if p.compressammo and band(itemFamily,3)~=0 and itemEquipLoc~="INVTYPE_BAG" then
				return true
			end
		end
		if p.compressstackable and itemStackCount and itemStackCount>1 then
			return true
		end
	end
end

function Baggins:OnAddonLoaded(name)
	if not pt and name then return end
	local module
	if type(name) == "string" then
		module = GetAddOnMetadata(name, "X-PeriodicTable-3.1-Module")
	else
		for k in pairs(name) do
			module = module or GetAddOnMetadata(k, "X-PeriodicTable-3.1-Module")
		end
	end
	if module then
		self.ptsetsdirty = true
	end
end

function Baggins:OnBankClosed()
	-- don't remove the test, it prevents infinite recursion loop on CloseBankFrame()
	if self.bankIsOpen then
		self.bankIsOpen = nil
		self:CloseAllBags()
	end
end

function Baggins:OnBankOpened()
	if self.doInitialBankUpdate then
		self.doInitialBankUpdate = nil
		Baggins:ForceFullBankUpdate()
	end
	self.bankIsOpen = true
	self:OpenAllBags()
end

function Baggins:OnBankChanged()
	self:OnBagUpdate(-1)
end

-------------------------
-- Update Bag Contents --
-------------------------
local scheduled_refresh = false

function Baggins:ScheduleRefresh()
	if not scheduled_refresh then
		--self:Debug('Scheduling refresh')
		scheduled_refresh = self:ScheduleEvent('Baggins_RefreshBags', 0)
	end
end

function Baggins:Baggins_RefreshBags()
	if self.dirtyBags then
		--self:Debug('Updating bags')
		self:ReallyUpdateBags()
	end
	for bagid,bagframe in pairs(self.bagframes) do
		for secid,sectionframe in pairs(bagframe.sections) do
			if sectionframe.used and sectionframe.dirty then
				--self:Debug('Updating section #%d-%d', bagid, secid)
				self:ReallyLayoutSection(sectionframe)
			end
		end

		if bagframe.dirty then
			self:ReallyUpdateBagFrameSize(bagid)
		end
	end
	if self.dirtyBagLayout then
		--self:Debug('Updating bag layout')
		self:ReallyLayoutBagFrames()
	end

	--self:Debug('Refresh done')
	scheduled_refresh = nil
end

function Baggins:UpdateBags()
	--tablet:Refresh("BagginsEditCategories")
	--self:RefreshEditWaterfall() 
	self.dirtyBags = true
	self:ScheduleRefresh()
end

local othersections = {}

local function CheckSection(bagframe, secid)
	for i = 1,secid do
		if not bagframe.sections[i] then
			bagframe.sections[i] = Baggins:CreateSectionFrame(bagframe,i)
			if i == 1 then
				bagframe.sections[i]:SetPoint("TOPLEFT",bagframe,"TOPLEFT",10,-36)
			else
				bagframe.sections[i]:SetPoint("TOPLEFT",bagframe.sections[i-1],"BOTTOMLEFT",0,1)
			end
		end
	end
end

local function GetSlotInfo(item)
	local bag, slot = item:match("^(-?%d+):(%d+)$")
	local bagType = Baggins:IsSpecialBag(bag)
	local itemID
	local cacheditem = Baggins:GetCachedItem(item)
	if cacheditem then
		itemID = tonumber(cacheditem:match("^(%d+)"))
	end
	return bag, slot, itemID, bagType
end

function Baggins:CategoryMatchAdded(category, slot, isbank)
	local p = self.db.profile
	for bagid, bag in pairs(p.bags) do
		local bagframe = self.bagframes[bagid]
		if bagframe then
			for sectionid, section in pairs(bag.sections) do
				for catid, catname in pairs(section.cats) do
					if catname == category and (not bag.isBank == not isbank) then
						CheckSection(bagframe, sectionid)
						local secframe = bagframe.sections[sectionid]
						secframe.slots[slot] = ( secframe.slots[slot] or 0 ) + 1
						local layout = secframe.layout
						local bagnum, slotnum, itemid, bagtype = GetSlotInfo(slot)
						if not itemid then
							itemid = (bagtype or "")
						end
						local found
					
						--check for an existing stack to add the slot to
						for k, entry in ipairs(layout) do
							if type(entry) == "table" then
								if entry.itemid == itemid and entry.slots[slot] then
									found = true
								elseif entry.itemid == itemid then
									if self:IsCompressed(itemid) then
										if not entry.slots[slot] then
											entry.slots[slot] = true
											entry.slotcount = entry.slotcount + 1
										end
										found = true
									end
								else
									if entry.slots[slot] then
										entry.slots[slot] = nil
										entry.slotcount = entry.slotcount - 1
										if entry.slotcount == 0 then
											del(entry.slots)
											del(entry)
											layout[k] = slot
										end
									end
								end
							end
						end
						if not found then
							local newentry = new()
							newentry.slots = new()
							newentry.slots[slot] = true
							newentry.slotcount = 1
							newentry.itemid = itemid
							tinsert(layout, newentry)
							secframe.needssorting = true
						end
					end
				end
			end
		end
	end
end

function Baggins:CategoryMatchRemoved(category, slot, isbank)
	local p = self.db.profile
	for bagid, bag in pairs(p.bags) do
	local bagframe = self.bagframes[bagid]
		if bagframe then
			for sectionid, section in pairs(bag.sections) do
				for catid, catname in pairs(section.cats) do
					if catname == category and (not bag.isBank == not isbank) then
						CheckSection(bagframe, sectionid)
						local secframe = bagframe.sections[sectionid]
						secframe.slots[slot] = ( secframe.slots[slot] or 1 ) - 1
						if secframe.slots[slot] == 0 then
							secframe.slots[slot] = false
						end
						
						local layout = secframe.layout

						--remove the slot from any stacks that contain it
						for k, entry in ipairs(layout) do
							if type(entry) == "table" then
								if entry.slots[slot] then
									entry.slots[slot] = nil
									entry.slotcount = entry.slotcount - 1
								end
								if entry.slotcount == 0 then
									del(entry.slots)
									del(entry)
									layout[k] = slot
								end
							end
						end
						
					end
				end
			end
		end
	end
end

function Baggins:SlotMoved(category, slot, isbank)
	local p = self.db.profile
	for bagid, bag in pairs(p.bags) do
		local bagframe = self.bagframes[bagid]
		if bagframe then
			for sectionid, section in pairs(bag.sections) do
				for catid, catname in pairs(section.cats) do
					if catname == category and (not bag.isBank == not isbank) then
						CheckSection(bagframe, sectionid)
						local secframe = bagframe.sections[sectionid]
						secframe.needssorting = true
						local layout = secframe.layout
						local bagnum, slotnum, itemid, bagtype = GetSlotInfo(slot)
						if not itemid then
							itemid = (bagtype or "")
						end
						
						--remove the slot from any stacks that contain it
						for k, entry in ipairs(layout) do
							if type(entry) == "table" then
								if entry.slots[slot] then
									entry.slots[slot] = nil
									entry.slotcount = entry.slotcount - 1
								end
								if entry.slotcount == 0 then
									del(entry.slots)
									del(entry)
									layout[k] = slot
								end
							end
						end
						local found
						--check for an existing stack to add the slot to
						for k, entry in ipairs(layout) do
							if type(entry) == "table" then
								if entry.itemid == itemid then
									if self:IsCompressed(itemid) then
										if not entry.slots[slot] then
											entry.slots[slot] = true
											entry.slotcount = entry.slotcount + 1
										end
										found = true
									end
								else
									if entry.slots[slot] then
										entry.slots[slot] = nil
										entry.slotcount = entry.slotcount - 1
										if entry.slotcount == 0 then
											del(entry.slots)
											del(entry)
											layout[k] = slot
										end
									end
								end
							end
						end
						if not found then
							local newentry = new()
							newentry.slots = new()
							newentry.slots[slot] = true
							newentry.slotcount = 1
							newentry.itemid = itemid
							tinsert(layout, newentry)
							secframe.needssorting = true
						end
						
					end
				end
			end
		end
	end
end

function Baggins:ForceSectionReLayout(bagid)
	local bagframe = self.bagframes[bagid]
	if bagframe then
		for secid, secframe in pairs(bagframe.sections) do
			if secframe then
				for k, v in pairs(secframe.slots) do
					if v == false then
						secframe.slots[k] = nil
					end
				end
				secframe.needssorting = true
			end
		end
	end
end

function Baggins:ClearSectionCaches()
	for bagid, bag in ipairs(self.db.profile.bags) do
		local bagframe = self.bagframes[bagid]
		if bagframe then
			for secid, secframe in pairs(bagframe.sections) do
				if secframe then
					local layout = secframe.layout
					for k, v in pairs(layout) do
						if type(v) == "table" then
							del(v.slots)
							del(v)
						end
						layout[k] = nil
					end
					for k, v in pairs(secframe.slots) do
						secframe.slots[k] = nil
					end
				end
			end
		end
	end
end			

function Baggins:RebuildSectionLayouts()
	for bagid, bag in ipairs(self.db.profile.bags) do
		local bagframe = self.bagframes[bagid]
		if bagframe then
			for secid, secframe in pairs(bagframe.sections) do
				if secframe then
					local layout = secframe.layout
					for k, v in pairs(layout) do
						if type(v) == "table" then
							del(v.slots)
							del(v)
						end
						layout[k] = nil
					end
					for slot, refcount in pairs(secframe.slots) do
						local bagnum, slotnum, itemid, bagtype = GetSlotInfo(slot)
						if not itemid then
							itemid = (bagtype or "")
						end
						local found
						--check for an existing stack to add the slot to
						for k, entry in ipairs(layout) do
							if entry then
								if entry.itemid == itemid then
									if self:IsCompressed(itemid) then
										if not entry.slots[slot] then
											entry.slots[slot] = true
											entry.slotcount = entry.slotcount + 1
										end
										found = true
									end
								else
									if entry.slots[slot] then
										entry.slots[slot] = nil
										entry.slotcount = entry.slotcount - 1
										if entry.slotcount == 0 then
											del(entry.slots)
											del(entry)
											layout[k] = slot
										end
									end
								end
							end
						end
						if not found then
							local newentry = new()
							newentry.slots = new()
							newentry.slots[slot] = true
							newentry.slotcount = 1
							newentry.itemid = itemid
							tinsert(layout, newentry)
							secframe.needssorting = true
						end
					end
					secframe.needssorting = true
				end
			end
		end
	end
end


function Baggins:ReallyUpdateBags()
	local p = self.db.profile
	local isVisible = false
	BagginsMoneyFrame:Hide()
	for bagid, bag in pairs(p.bags) do
		if self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() then
			isVisible = true
		end
	end
	if not isVisible then return end
	for bagid, bag in pairs(p.bags) do
		if ( not bag.isBank ) or self.bankIsOpen then
			if self.bagframes[bagid] then
				self:SetBagTitle(bagid,bag.name)
				self.currentSkin:SetBankVisual(self.bagframes[bagid], bag.isBank)
				for k, v in pairs(self.bagframes[bagid].sections) do
					v.used = nil
					v:Hide()
					for i, itemframe in pairs(v.items) do
						itemframe:Hide()
					end
				end
				for sectionid, section in pairs(bag.sections) do
					if self.bagframes[bagid]:IsVisible() then
						self:UpdateSection(bagid,sectionid,section.name) --,Baggins:FinishSection())
					end
				end
				self:UpdateBagFrameSize(bagid)
			end
		end
	end

	self:UpdateLayout()
	self.dirtyBags = nil
end

function Baggins:UpdateSection(bagid, secid,title) --, contents)
	local bagframe = self.bagframes[bagid]
	if not bagframe then return end
	local i
	for i = 1,secid do
		if not bagframe.sections[i] then
			bagframe.sections[i] = self:CreateSectionFrame(bagframe,i)
			if i == 1 then
				bagframe.sections[i]:SetPoint("TOPLEFT",bagframe,"TOPLEFT",10,-36)
			else
				bagframe.sections[i]:SetPoint("TOPLEFT",bagframe.sections[i-1],"BOTTOMLEFT",0,1)
			end
		end
	end
	self:UpdateSectionContents(bagframe.sections[secid],title) --,contents)
	self:UpdateBagFrameSize(bagid)
end

-----------------
-- Bag Updates --
-----------------

local firstbagupdate = true

local bagupdatebucket = {}
local lastbag,lastbagfree=-1,-1

function Baggins:OnBagUpdate(bagid)
	--ignore bags -4 ( currency ) and -3 (unknown)
	if bagid <= -3 then return end
	bagupdatebucket[bagid] = true
	if self:IsWhateverOpen() then
		self:ScheduleEvent("Baggins_RunBagUpdates",self.RunBagUpdates,0.1,self)
		lastbagfree=-1
	else
		-- Update panel text.
		-- Optimization mostly for hunters - their bags change for every damn arrow they fire:
		local free=GetContainerNumFreeSlots(bagid)
		if lastbag==bagid and lastbagfree==free then
			-- nada!
		else
			lastbag=bagid
			lastbagfree=free
			self:UpdateText()
		end
	end
end

function Baggins:RunBagUpdates()
	if firstbagupdate then
		firstbagupdate = false
		self:SaveItemCounts()
		self:ForceFullUpdate()
	end
	if not next(bagupdatebucket) then
		return
	end
	self:UpdateText()
	
	local itemschanged
	for bag in pairs(bagupdatebucket) do
		itemschanged = Baggins:CheckSlotsChanged(bag) or itemschanged
		bagupdatebucket[bag] = nil
	end

	if itemschanged then
		self:UpdateBags()
	else
		self:UpdateItemButtons()
	end
	
	if(self:IsWhateverOpen()) then
		Baggins:FireSignal("Baggins_BagsUpdatedWhileOpen");
	end
end

-----------------------------
-- Update Section Contents --
-----------------------------
function Baggins:UpdateSectionContents(sectionframe,title)
	local p = self.db.profile
	
	sectionframe.used = true
	if sectionframe.needssorting or self.db.profile.alwaysresort then
		local layout = sectionframe.layout
		local size = #layout
		if size > 0 then
			for i = size, 1, -1 do
				if type(layout[i]) == "string" then
					tremove(layout, i)
				end
			end
		end
		
		self:SortItemList(layout, p.sort)
		sectionframe.needssorting = false
	end
	sectionframe:Show()

	self:LayoutSection(sectionframe, title)
end


local function baseComp(a, b)
	local p = Baggins.db.profile
	if type(a) == "table" then
		for k, v in pairs(a.slots) do
			if v then
				a = k
				break
			end
		end
	end
	if type(b) == "table" then
		for k, v in pairs(b.slots) do
			if v then
				b = k
				break
			end
		end
	end
	-- getting a or b as nil here shouldn't happen. but it happens.
	local baga, slota = strmatch(a or "", "^(-?%d+):(%d+)$")
	local bagb, slotb = strmatch(b or "", "^(-?%d+):(%d+)$")
	baga=tonumber(baga)
	slota=tonumber(slota)
	bagb=tonumber(bagb)
	slotb=tonumber(slotb)
	local linka = baga and slota and GetContainerItemLink(baga, slota)
	local linkb = bagb and slotb and GetContainerItemLink(bagb, slotb)
	--if both are empty slots compare based on bag type
	if not linka and not linkb then
		local bagtypea = Baggins:IsSpecialBag(baga)
		local bagtypeb = Baggins:IsSpecialBag(bagb)
		if not bagtypea then
			return false
		end
		if not bagtypeb then
			return true
		end
		return bagtypea < bagtypeb
	end
	if not linka then
		return false
	end
	if not linkb then
		return true
	end
	
	if p.sortnewfirst and baga>=0 and baga<=NUM_BAG_SLOTS then
		local newa, newb = Baggins:IsNew(linka), Baggins:IsNew(linkb)
		if newa and not newb then
			return true
		end
		if newb and not newa then
			return false
		end
	end

	return nil,linka,linkb,baga,slota,bagb,slotb
end

local function NameComp(a, b)
	local res,linka,linkb,baga,slota,bagb,slotb=baseComp(a,b)
	if res~=nil then return res end
	
	local namea = GetItemInfo(linka)
	local nameb = GetItemInfo(linkb)

	if namea ~= nameb then
		return namea < nameb
	end

	local counta = select(2, GetContainerItemInfo(baga, slota))
	local countb = select(2, GetContainerItemInfo(bagb, slotb))
	return counta > countb
end
local function QualityComp(a, b)
	local res,linka,linkb,baga,slota,bagb,slotb=baseComp(a,b)
	if res~=nil then return res end
	
	local namea, _, quala = GetItemInfo(linka)
	local nameb, _, qualb = GetItemInfo(linkb)
	
	if quala~=qualb then
		return quala > qualb
	end
	
	if namea ~= nameb then
		return namea < nameb
	end

	local counta = select(2, GetContainerItemInfo(baga, slota))
	local countb = select(2, GetContainerItemInfo(bagb, slotb))
	return counta > countb
end
local function TypeComp(a, b)
	local res,linka,linkb,baga,slota,bagb,slotb=baseComp(a,b)
	if res~=nil then return res end

	local namea, _, quala, _, _, typea, subtypea, _, equiploca = GetItemInfo(linka)
	local nameb, _, qualb, _, _, typeb, subtypeb, _, equiplocb = GetItemInfo(linkb)
	if typea ~= typeb then
		return typea < typeb
	end
	
	if (equiploca and equiplocs[equiploca]) and (equiplocb and equiplocs[equiplocb]) then
		if equiplocs[equiploca] ~= equiplocs[equiplocb] then
			return equiplocs[equiploca] < equiplocs[equiplocb]
		end
	end

	if quala~=qualb then
		return quala > qualb
	end
	
	if namea ~= nameb then
		return namea < nameb
	end

	local counta = select(2, GetContainerItemInfo(baga, slota))
	local countb = select(2, GetContainerItemInfo(bagb, slotb))
	return counta > countb
end
local function SlotComp(a, b)
	local p = Baggins.db.profile
	if type(a) == "table" then
		a, b = (next(a.slots)), (next(b.slots))
	end
	local baga, slota = a:match("^(-?%d+):(%d+)$")
	local bagb, slotb = b:match("^(-?%d+):(%d+)$")
	if baga == bagb then
		slota = tonumber(slota)
		slotb = tonumber(slotb)
		return slota < slotb
	else
		return baga < bagb
	end
end
local function IlvlComp(a, b)
	local res,linka,linkb,baga,slota,bagb,slotb=baseComp(a,b)
	if res~=nil then return res end

	local namea, _, quala, ilvla = GetItemInfo(linka)
	local nameb, _, qualb, ilvlb = GetItemInfo(linkb)
	if ilvla~=ilvlb then
		return ilvla>ilvlb
	end

	if quala~=qualb then
		return quala > qualb
	end
	
	if namea ~= nameb then
		return namea < nameb
	end

	local counta = select(2, GetContainerItemInfo(baga, slota))
	local countb = select(2, GetContainerItemInfo(bagb, slotb))
	return counta > countb
end

function Baggins:SortItemList(itemlist, sorttype)
	local func
	if sorttype == "name" then
		func = NameComp
	elseif sorttype == "quality" then
		func = QualityComp
	elseif sorttype == "type" then
		func = TypeComp
	elseif sorttype == "slot" then
		func = SlotComp
	elseif sorttype == "ilvl" then
		func = IlvlComp
	else
		return
	end
	table.sort(itemlist, func)
end

------------------------
-- Section/Bag Layout --
------------------------
function Baggins:GetSectionSize(sectionframe, maxcols)
	local count
	local bagconf = self.db.profile.bags[sectionframe.bagid]
	if not bagconf then return 0,0 end
	local sectionconf = bagconf.sections[sectionframe.secid]
	if not sectionconf then return 0,0 end
	if sectionconf.hidden then
			count = 0
		else
			count = sectionframe.itemcount
		end
	maxcols = maxcols or count
	local width = math.min(count, maxcols) * 39 - 2
	local height = maxcols > 0 and (math.ceil(count / maxcols) * 39 - 2) or 0

	if self.db.profile.showsectiontitle then
		width = math.max(width, sectionframe.title:GetWidth())
		height = height + sectionframe.title:GetHeight()
	end

	return width, height
end

local areas = {}

function Baggins:OptimizeSectionLayout(bagid)
	local bagframe = self.bagframes[bagid]
	if not bagframe then
		return
	end
	local p = self.db.profile
	local s = self.currentSkin
	local titlefactor = p.showsectiontitle and 1 or 0
	local totalwidth, totalheight = 0, 0

	for k in pairs(areas) do areas[k] = nil end

	table.insert(areas, string.format('0:0:%d:3000', self.db.profile.columns * 39))

	--self:Debug("**** Laying out bag #%d ***", bagid)

	for secid,sectionframe in ipairs(bagframe.sections) do
		local count = sectionframe.itemcount
		if sectionframe.used and (count > 0 or not p.hideemptysections) then
			local minwidth = self:GetSectionSize(sectionframe, 1)
			local minheight = select(2, self:GetSectionSize(sectionframe))

			--[[
			self:Debug("Section #%d, %d item(s), title width: %q, min width: %q, min height: %q",
				secid,	sectionframe.itemcount, sectionframe.title:GetWidth(), minwidth,
				minheight)
			--]]

			sectionframe.layout_waste = nil
			sectionframe.layout_columns = nil
			sectionframe.layout_area_index = nil

			for areaid,area in pairs(areas) do
				--self:Debug("  Area #%d: %s", areaid, area)

				local area_w,area_h = area:match('^%d+:%d+:(%d+):(%d+)$')
				area_w = tonumber(area_w)
				area_h = tonumber(area_h)

				if area_w >= minwidth and area_h >= minheight then
					local cols = math.floor(area_w / 39)
					local width, height = self:GetSectionSize(sectionframe, cols)
					--self:Debug("    %d columns", cols)

					if area_h >= height then
						local waste = (area_w * area_h) - (width * height)
						--self:Debug("    area waste: %d", waste)

						if not sectionframe.layout_waste or waste < sectionframe.layout_waste then
							sectionframe.layout_waste = waste
							sectionframe.layout_columns = cols
							sectionframe.layout_areaid = areaid
							--self:Debug("    -> best fit")
						else
							--self:Debug("    -> do not fit")
						end

					else
						--self:Debug("  -> too short")
					end
				else
					--self:Debug("  -> too small")
				end
			end
			local areaid = sectionframe.layout_areaid
			local area_x, area_y, area_w, area_h = table.remove(areas, areaid):match('^(%d+):(%d+):(%d+):(%d+)$')
			area_x = tonumber(area_x)
			area_y = tonumber(area_y)
			area_w = tonumber(area_w)
			area_h = tonumber(area_h)
			local cols = sectionframe.layout_columns
			local width, height = self:GetSectionSize(sectionframe, cols)
			sectionframe:SetPoint('TOPLEFT', bagframe, 'TOPLEFT', s.BagLeftPadding + area_x, - (s.BagTopPadding + area_y) )
			sectionframe:SetWidth(width)
			sectionframe:SetHeight(height)

			totalwidth = math.max(totalwidth, area_x + width)
			totalheight = math.max(totalheight,area_y + height)
			--self:ReallyLayoutSection(sectionframe, cols)

			width = width + 10
			height = height + 10
			if area_w - width >= 39 then
				local area = string.format('%d:%d:%d:%d', area_x + width, area_y, area_w - width, height)
				--self:Debug("Created new area: %s", area)
				table.insert(areas, area)
			end
			if area_h - height >= 39 then
				local area = string.format('%d:%d:%d:%d', area_x, area_y + height, area_w, area_h - height)
				--self:Debug("Created new area: %s", area)
				table.insert(areas, area)
			end
		end
	end
	
	return s.BagLeftPadding + s.BagRightPadding + totalwidth, s.BagTopPadding + s.BagBottomPadding + totalheight
end

function Baggins:UpdateBagFrameSize(bagid)
	local bagframe = self.bagframes[bagid]
	if not bagframe then return end
	bagframe.dirty = true
	self:ScheduleRefresh()
end

function Baggins:ReallyUpdateBagFrameSize(bagid)
	local bagframe = self.bagframes[bagid]
	if not bagframe then return end
	local p = self.db.profile
	local s = self.currentSkin

	--self:Debug('Updating bag #%d', bagid)
	
	local hpadding = s.BagLeftPadding + s.BagRightPadding
	local width = s.BagLeftPadding + s.TitlePadding
	local height = s.BagTopPadding + s.BagBottomPadding

	if not p.shrinkbagtitle then
		width = width + bagframe.title:GetWidth()
 	end

	if self.db.profile.optimizesectionlayout then
		local swidth, sheight = Baggins:OptimizeSectionLayout(bagid)
		width = math.max(width, swidth)
		height = math.max(height, sheight)
	else
		local lastsection
		for id,section in ipairs(bagframe.sections) do			
			if section.used and (not p.hideemptysections or section.itemcount > 0) then
				if not lastsection then
					section:SetPoint("TOPLEFT",bagframe,"TOPLEFT",s.BagLeftPadding,-s.BagTopPadding)
				else
					section:SetPoint("TOPLEFT",lastsection,"BOTTOMLEFT",0,-5)
					height = height + 5
				end
				lastsection = section
				--self:ReallyLayoutSection(section)
				width = math.max(width,section:GetWidth()+hpadding)
				height = height + section:GetHeight()
			end
		end
	end
	
	if p.moneybag == bagid then
		BagginsMoneyFrame:SetParent(bagframe)
		BagginsMoneyFrame:ClearAllPoints()
		BagginsMoneyFrame:SetPoint("BOTTOMLEFT",bagframe,"BOTTOMLEFT",8,6)
		BagginsMoneyFrame:Show()
		width = max(BagginsMoneyFrame:GetWidth() + 16, width)
		height = height + 30
	end
	
	if not p.shrinkwidth then
		width = math.max(p.columns*39 + hpadding, width)
	end
	
	if bagframe:GetWidth() ~= width or bagframe:GetHeight() ~= height then
		bagframe:SetWidth(width)
		bagframe:SetHeight(height)
		self.dirtyBagLayout = true
	end
	
	bagframe.dirty = nil
end

local sectionSortTab = {}
local function sectionComp(a, b)
    local bags = Baggins.db.profile.bags
    
    local bagA, secA = math.floor(a/1000), mod(a,1000)
    local bagB, secB = math.floor(b/1000), mod(b,1000)
     
    local PriA = (bags[bagA].priority or 1) + (bags[bagA].sections[secA].priority or 1)
    local PriB = (bags[bagB].priority or 1) + (bags[bagB].sections[secB].priority or 1)
    
    if PriA == PriB then
        return a < b
    else
        return PriA > PriB
    end
end

function Baggins:ResortSections()
    self.sectionOrderDirty = true
end

function Baggins:IsSlotMine(mybagid, mysecid, slot, wasMine)
	local p = self.db.profile
	if not p.hideduplicates or p.hideduplicates == "disabled" then
		return true
	end
	
	local bag = p.bags[mybagid]
	if not bag then return false end
	local section = bag.sections[mysecid]
	if not section then return false end
	
    if section.allowdupes then
        return true
    end
	
	if type(slot) == 'table' then
		for k, v in pairs(slot) do
			if v then
				slot = k
				break
			end
		end
	end
	
	--if self.sectionOrderDirty then
        local i = 1
        
        local numbags = #p.bags
        
    	if p.hideduplicates == true or p.hideduplicates == "global" then
            for bagid = 1, numbags do
                local numsections = #p.bags[bagid].sections
                local bag = p.bags[bagid]
                if bag then
                    for secid = 1, numsections do
                        local section = bag.sections[secid]
                        if not section.allowdupes then
                            sectionSortTab[i] = bagid*1000 + secid
                            i = i + 1
                        end
                    end
                end
            end
    	elseif p.hideduplicates == "bag" then
    	    local numsections = #p.bags[mybagid].sections
    	    local bag = p.bags[mybagid]
    	    if bag then
                for secid = 1, numsections do
                    local section = bag.sections[secid]
                    if not section.allowdupes then
                        sectionSortTab[i] = mybagid*1000 + secid
                        i = i + 1
                    end
                end
            end
    	end
    
        while sectionSortTab[i] do
            sectionSortTab[i] = nil
            i = i + 1
        end
        self.sectionOrderDirty = nil
    --end
    
    table.sort(sectionSortTab, sectionComp)
    
	for i, v in ipairs(sectionSortTab) do
	    local bagid, secid = math.floor(v/1000), mod(v,1000)
	    local section = self.bagframes[bagid].sections[secid]
		if section and ((not wasMine and section.slots[slot]) or (wasMine and section.slots[slot] == false)) then
			if mybagid == bagid and mysecid == secid then
				return true
			else
				return false
			end
		end
	end
end

function Baggins:LayoutSection(sectionframe, title, cols)
	sectionframe.dirty = true
	sectionframe.set_title = title
	sectionframe.set_columns = cols
	self:ScheduleRefresh()
end

function Baggins:ReallyLayoutSection(sectionframe, cols)
	local bagid, secid = sectionframe.bagid, sectionframe.secid
	local p = self.db.profile
	local bagconf = p.bags[sectionframe.bagid]
	if not bagconf then return end
	local sectionconf = bagconf.sections[sectionframe.secid]
	if not sectionconf then return end
	local totalwidth, totalheight = 1,1
	local s = self.currentSkin
	cols = cols or sectionframe.set_columns or p.columns
	
	if p.showsectiontitle then
		totalheight = totalheight + s.SectionTitleHeight
	end
	sectionframe.itemcount = 0
	if sectionconf.hidden then
		for itemnum, itemframe in ipairs(sectionframe.items) do
			itemframe:Hide()
		end
		for k, v in ipairs(sectionframe.layout) do
			sectionframe.itemcount = sectionframe.itemcount + 1	
		end
	else
		local itemnum = 1
		local itemframeno = 1
		local BaseTop 
		if p.showsectiontitle then
			BaseTop = (sectionframe.title:GetHeight() + 1)
		else
			BaseTop = 0
		end
		for k, v in pairs(sectionframe.items) do
			v:Hide()
		end
		for k, v in ipairs(sectionframe.layout) do
			if (type(v) == "string" and self:IsSlotMine(bagid, secid, v, true)) or (type(v) == "table" and self:IsSlotMine(bagid, secid, v.slots)) then
				if type(v) == "table" then
					sectionframe.items[itemframeno] = sectionframe.items[itemframeno] or self:CreateItemButton(sectionframe,itemframeno)
					local itemframe = sectionframe.items[itemframeno]
					itemframeno = itemframeno + 1
					itemframe:SetPoint("TOPLEFT",sectionframe,"TOPLEFT",((itemnum-1)%cols)*39,-(BaseTop+(math.floor((itemnum-1)/cols)*39)))
					local bag, slot, itemid = GetSlotInfo(next(v.slots))
					if v.slotcount > 1 or ((p.compressall or p.compressempty) and not itemid) then
						itemframe.countoverride = true
					else
						itemframe.countoverride = nil
					end
					if not itemframe.slots then
						itemframe.slots = {}
					else
						wipe(itemframe.slots)
					end
					for slot in pairs(v.slots) do
						tinsert(itemframe.slots, slot)
					end
					self:UpdateItemButton(sectionframe:GetParent(),itemframe,tonumber(bag),tonumber(slot))

					itemframe:Show()
				end
				sectionframe.itemcount = sectionframe.itemcount + 1	
				if itemnum == 1 then
					totalwidth = 39
					totalheight = totalheight+39
				elseif itemnum%cols == 1 then
					totalheight = totalheight+39
				else
					if itemnum <= cols then
						totalwidth = totalwidth+39
					end
				end
				itemnum = itemnum + 1	
			end	
		end
	end
	
	if p.showsectiontitle then
		local title = sectionframe.set_title
		if sectionconf.hidden then
			title = ("+ %s (%d)"):format(title, sectionframe.itemcount)
		else
			title = ("- %s"):format(title)
		end
		sectionframe.title:SetText(title)
		totalwidth = max(totalwidth,sectionframe.title:GetWidth())
	else
		sectionframe.title:SetText("")
	end
	
	if sectionframe.itemcount == 0 and p.hideemptysections then
		totalheight = 1
		sectionframe:Hide()
	end

	if sectionframe:GetWidth() ~= totalwidth or sectionframe:GetHeight() ~= totalheight then
		sectionframe:SetWidth(totalwidth)	
		sectionframe:SetHeight(totalheight)	
		self.bagframes[sectionframe.bagid].dirty = true
	end
	
	sectionframe.dirty = nil
end

---------------------
-- Frame Creation  --
---------------------
function Baggins:CreateBagPlacementFrame()
local f = CreateFrame("frame","BagginsBagPlacement",UIParent)

	f:SetWidth(130)
	f:SetHeight(300)
	f:SetPoint("CENTER",UIParent,"CENTER",0,0)
	f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	                                            edgeFile = false, 
	                                            edgeSize = 0, 
	                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	f:SetBackdropColor(0.2,0.5,1,0.5)
		
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetResizable(true)
	f:SetClampedToScreen(true)
	f:SetScript("OnMouseDown",function(this, button) if button == "RightButton" then this:Hide() else this:StartMoving() end end)
	f:SetScript("OnMouseUp", function() this:StopMovingOrSizing() self:SaveBagPlacement() end)

	f.t = CreateFrame("frame","BagginsBagPlacementTopMover",f)
	f.t:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
	f.t:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
	f.t:SetHeight(20)
	f.t:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	                                            edgeFile = false, 
	                                            edgeSize = 0, 
	                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	f.t:SetBackdropColor(0,0,1,1)
	f.t:EnableMouse(true)
	f.t:SetScript("OnMouseDown",function() this:GetParent():StartSizing("TOP") end)
	f.t:SetScript("OnMouseUp", function() this:GetParent():StopMovingOrSizing() self:SaveBagPlacement() end)
	
	f.b = CreateFrame("frame","BagginsBagPlacementTopMover",f)
	f.b:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
	f.b:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0)
	f.b:SetHeight(20)
	f.b:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	                                            edgeFile = false, 
	                                            edgeSize = 0, 
	                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	f.b:SetBackdropColor(0,0,1,1)
	f.b:EnableMouse(true)
	f.b:SetScript("OnMouseDown",function() this:GetParent():StartSizing("BOTTOM") end)
	f.b:SetScript("OnMouseUp", function() this:GetParent():StopMovingOrSizing() self:SaveBagPlacement() end)
	
	f.midtext = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	f.midtext:SetText(L["Drag to Move\nRight-Click to Close"])
	f.midtext:SetPoint("LEFT",f,"LEFT",0,0)
	f.midtext:SetPoint("RIGHT",f,"RIGHT",0,0)
	f.midtext:SetHeight(45)
	f.midtext:SetVertexColor(1, 1, 1)
	
	f.toptext = f.t:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	f.toptext:SetText(L["Drag to Size"])
	f.toptext:SetPoint("TOPLEFT",f,"TOPLEFT",0,-2)
	f.toptext:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,-2)
	f.toptext:SetHeight(15)
	f.toptext:SetVertexColor(1, 1, 1)

	f.bottext = f.b:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	f.bottext:SetText(L["Drag to Size"])
	f.bottext:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,2)
	f.bottext:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,2)
	f.bottext:SetHeight(15)
	f.bottext:SetVertexColor(1, 1, 1)	
end

local function BagginsItemButton_OnEnter(button)
	if ( not button ) then
		button = this
	end

	local x
	x = button:GetRight()
	if ( x >= ( GetScreenWidth() / 2 ) ) then
		GameTooltip:SetOwner(button, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	end

	-- Keyring specific code
	button:UpdateTooltip()
		
end

local function BagginsItemButton_UpdateTooltip(button)
if ( button:GetParent():GetID() == KEYRING_CONTAINER ) then
		GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(button:GetID(),button.isBag))
		CursorUpdate()
		return
	end
	local hasItem, hasCooldown, repairCost
	if button:GetParent():GetID() == -1 then
		if ( not GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(button:GetID(),button.isBag)) ) then
			if ( button.isBag ) then
				GameTooltip:SetText(button.tooltipText);
			end
		end
		CursorUpdate();
		return
	end

	local showSell = nil;
	local hasCooldown, repairCost = GameTooltip:SetBagItem(button:GetParent():GetID(), button:GetID());
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 and not button.locked ) then
		showSell = 1;
	end

	if ( IsModifiedClick("DRESSUP") and button.hasItem ) then
		ShowInspectCursor();
	elseif ( showSell ) then
		ShowContainerSellCursor(button:GetParent():GetID(),button:GetID());
	elseif ( button.readable ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end	

local function BagginsItemButton_PreClick(button)
	for i, v in ipairs(button.slots) do
		local bag, slot = GetSlotInfo(v)
		local locked =select(3, GetContainerItemInfo(bag, slot))
		if not locked then
			button:SetID(slot)
			local bagframe = button:GetParent():GetParent()
			if not bagframe.bagparents[bag] then 
				bagframe.bagparents[bag] = CreateFrame("Frame",nil,bagframe)
				bagframe.bagparents[bag]:SetID(bag)
			end
			button:SetParent(bagframe.bagparents[bag])
			break
		end
	end
	if IsAltKeyDown() and GetMouseButtonClicked() == "RightButton" then
		local bag = button:GetParent():GetID();
		local slot = button:GetID();
		local link = GetContainerItemLink(bag,slot)
		
		if link then
			local itemid = tonumber(link:match("item:(%d+)"))
			if itemid then
				dewdrop:Open( button,
					"children",function(level, value, ...)
						Baggins:FireSignal("Baggins_ItemButtonMenu", button, dewdrop, level, value, ...);
						if level == 1 then
							dewdrop:AddLine("text",L["Add To Category"], "hasArrow", true, "value", "AddToCat")
							dewdrop:AddLine("text",L["Exclude From Category"], "hasArrow", true, "value", "ExcludeFromCat")
							dewdrop:AddLine("text",L["Item Info"], "hasArrow", true, "value", "Info")
						
						elseif level == 2 and (value=="AddToCat" or value=="ExcludeFromCat") then
							
							local categories = Baggins.db.profile.categories
							while #catsorttable > 0 do
								table.remove(catsorttable,#catsorttable)
							end
							for catid in pairs(categories) do
								table.insert(catsorttable,catid)
							end
							table.sort(catsorttable)
							
							if value == "AddToCat" then
								for i, name in ipairs(catsorttable) do
									dewdrop:AddLine("text",name, "func", function(cat, item) Baggins:IncludeItemInCategory(cat, item) end, "arg1", name,"arg2", itemid)
								end
							elseif value == "ExcludeFromCat" then
								for i, name in ipairs(catsorttable) do
									dewdrop:AddLine("text",name, "func", function(cat, item) Baggins:ExcludeItemFromCategory(cat, item) end, "arg1", name,"arg2", itemid)
								end
							end
						
						elseif level == 2 and (value=="Info") then
							
							local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemid)
							dewdrop:AddLine("text",L["ItemID: "]..itemid)
							dewdrop:AddLine("text",L["Item Type: "]..itemType)
							dewdrop:AddLine("text",L["Item Subtype: "]..itemSubType)
							dewdrop:AddLine("text",L["Quality: "]..itemRarity)
							dewdrop:AddLine("text",L["Level: "]..itemLevel)
							dewdrop:AddLine("text",L["MinLevel: "]..itemMinLevel)
							dewdrop:AddLine("text",L["Stack Size: "]..itemCount)
							dewdrop:AddLine("text",L["Equip Location: "]..itemEquipLoc)
							if pt then
								dewdrop:AddLine("text",L["Periodic Table Sets"], "hasArrow", true, "value", "PTSets")
							end
							
						elseif level == 3 then
						
							if pt and value == "PTSets" then
								local matches = pt:ItemSearch(itemid)
								if matches then
									for i,v in ipairs(matches) do
										dewdrop:AddLine('text',v)
									end
								end
							end
						end
					end)
			end
		end
	end
end
--[[
local function BagginsItemButton_OnUpdate(button,elapsed)
	if ( this.updateTooltip ) then
		this.updateTooltip = button.updateTooltip - elapsed;
		if ( button.updateTooltip > 0 ) then
			return;
		end
	else
		return
	end
	
	if ( GameTooltip:IsOwned(this) ) then
		BagginsItemButton_OnEnter(this);
	end
end]]

function Baggins:CreateItemButton(sectionframe,item)
	local frame = CreateFrame("Button",sectionframe:GetName().."Item"..item,nil,"ContainerFrameItemButtonTemplate")
	frame.glow = frame:CreateTexture(nil,"OVERLAY")
	frame.glow:SetTexture("Interface\\Addons\\Baggins\\Textures\\Glow")
	frame.glow:SetAlpha(0.3)
	frame.glow:SetAllPoints(frame)
	
	frame.newtext = frame:CreateFontString(frame:GetName().."NewText","OVERLAY","GameFontNormal")
	frame.newtext:SetPoint("TOP",frame,"TOP",0,0)
	frame.newtext:SetHeight(13)
	frame.newtext:SetTextColor(0,1,0,1)
	frame.newtext:SetShadowColor(0,0,0,1)
	frame.newtext:SetShadowOffset(1,-1)
	frame.newtext:SetText("*New*")
	frame.newtext:Hide()
	
	frame:ClearAllPoints()
	local cooldown = getglobal(frame:GetName().."Cooldown")
	cooldown:SetAllPoints(frame)
	cooldown:SetFrameLevel(10)
	frame:SetFrameStrata("HIGH")
	frame:SetScript("OnEnter",BagginsItemButton_OnEnter)
	frame:SetScript("PreClick",BagginsItemButton_PreClick)
	frame.UpdateTooltip = BagginsItemButton_UpdateTooltip
	--frame:SetScript("OnUpdate",BagginsItemButton_OnUpdate)
	frame:Show()
	return frame
end

function Baggins:CreateSectionFrame(bagframe,secid)
	local frame = CreateFrame("Frame",bagframe:GetName().."Section"..secid,bagframe)
	
	frame.title = frame:CreateFontString(bagframe:GetName().."SectionTitle","OVERLAY","GameFontNormalSmall")
	frame.titleframe = CreateFrame("button",bagframe:GetName().."SectionTitleFrame",frame)
	frame.titleframe:SetAllPoints(frame.title)
	frame.titleframe:SetScript("OnClick", function(this) self:ToggleSection(this:GetParent()) end)
	--[[
	frame.titleframe:SetScript("OnEnter", function(this) self:ShowSectionTooltip(this:GetParent()) end)
	frame.titleframe:SetScript("OnLeave", function(this) self:HideSectionTooltip(this:GetParent()) end)
	--]]
	frame:SetFrameStrata("HIGH")
	frame:Show()
	frame.items = {}
	frame.slots = {}
	frame.layout = {}
	frame.secid = secid
	frame.bagid = bagframe.bagid
	frame.itemcount = 0
	self.currentSkin:SkinSection(frame)
	
	return frame
end

function Baggins:ToggleSection(sectionframe)
	local p = self.db.profile
	
	local bag = p.bags[sectionframe.bagid]
	if bag then
		local section = bag.sections[sectionframe.secid]
		if section then
			section.hidden = not section.hidden
			self:LayoutSection(sectionframe, section.name, p.columns)
			self:UpdateBagFrameSize(sectionframe.bagid)
		end
	end
end

--[[
function Baggins:ShowSectionTooltip(sectionframe)
	local p = self.db.profile
	
	local bag = p.bags[sectionframe.bagid]
	if bag then
		local section = bag.sections[sectionframe.secid]
		if section then
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(sectionframe, 'ANCHOR_DEFAULT')
			GameTooltip:AddLine(section.name)
			GameTooltip:AddLine("Categories: "..table.concat(section.cats, ', ') , 1, 1, 1) -- TODO: Locale
			GameTooltip:AddLine("Hint: click to collapse/expand.", 0, 1, 0) -- TODO: Locale
			GameTooltip:Show()
		end
	end
end

function Baggins:HideSectionTooltip(sectionframe)
	local p = self.db.profile
	if GameTooltip:IsOwned(sectionframe) then
		GameTooltip:Hide()
	end
end
--]]


function Baggins:CreateAllBags()
	for k, v in ipairs(self.db.profile.bags) do
		if not self.bagframes[k] then
			self:CreateBagFrame(k)
		end
	end
end

function Baggins:CreateBagFrame(bagid)
	if not bagid then return end
	local bagname = "BagginsBag"..bagid
	
	local frame = CreateFrame("Frame",bagname,UIParent)
	self.bagframes[bagid] = frame
	frame.bagid = bagid
	frame:SetToplevel(true)
	frame:SetWidth(100)
	frame:SetHeight(100)
	frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown",function(this,arg1) 
		if arg1=="LeftButton" and not self:AreBagsLocked() then 
			this:StartMoving() 
		end 
	end)
	frame:SetScript("OnMouseUp",function(this,arg1)
		if arg1=="LeftButton" then
			this:StopMovingOrSizing() self:SaveBagPosition(this.bagid) 
		elseif arg1=="RightButton" then
			Baggins:DoBagMenu(frame);
		end
	end)
	frame:SetScript("OnShow",function() self:FireSignal("Baggins_BagOpened", frame); end)
	
	
	frame.closebutton = CreateFrame("Button",bagname.."CloseButton",frame,"UIPanelCloseButton")
	frame.closebutton:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:CloseAllBags()
		else
			self:CloseBag(this:GetParent().bagid) 
		end
	end)
	
	frame.compressbutton = CreateFrame("Button",bagname.."CompressButton",frame,nil);
	frame.compressbutton:Hide();
	frame.compressbutton:SetScript("OnClick", function()
		self:CompressBags(Baggins.db.profile.bags[frame.bagid].isBank);
	end)
	frame.compressbutton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, 'ANCHOR_DEFAULT')
		GameTooltip:SetText(L["Compress bag contents"]);
		GameTooltip:Show();
	end)
	frame.compressbutton:SetScript("OnLeave", function()
		if(GameTooltip:IsOwned(this)) then
			GameTooltip:Hide();
		end
	end)
	frame.compressbutton:SetHeight(32);
	frame.compressbutton:SetWidth(32);
	frame.compressbutton:SetNormalTexture("Interface\\AddOns\\Baggins\\Textures\\compressbutton.tga");
	self:RegisterSignal("Baggins_CanCompress", function(self, bank, compressable) 
			if Baggins.db.profile.bags[self.bagid] then
				if (not Baggins.db.profile.bags[self.bagid].isBank) == (not bank) then 
					(compressable and self.compressbutton.Show or self.compressbutton.Hide)(self.compressbutton);
				end 
			end
		end,
		frame
	);
	
	frame.title = frame:CreateFontString(bagname.."Title","OVERLAY","GameFontNormalLarge")
	frame.title:SetText("Baggins")
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true) 
	frame:SetScale(self.db.profile.scale)
	frame.sections = {}
	frame.bagparents = {}
	
	self.currentSkin:SkinBag(frame)

	self:UpdateBagFrameSize(bagid)
	frame:Hide()
end

local function getsecond(_, value)
	return value
end

local function MoneyFrame_OnClick(button)
	local money = GetMoney()
	local multiplier
	if money < 100 then
		multiplier = 1
	elseif money < 10000 then
		multiplier = 100
	else
		multiplier = 10000
	end
	button.moneyType = "PLAYER"
	CoinPickupFrame:ClearAllPoints()
	OpenCoinPickupFrame(multiplier, money, button)
	button.hasPickup = 1

	CoinPickupFrame:ClearAllPoints()
	local frame = button

	if frame:GetCenter() < GetScreenWidth()/2 then
		if getsecond(frame:GetCenter()) < GetScreenHeight()/2 then
			CoinPickupFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
		else
			CoinPickupFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
		end
	else
		if getsecond(frame:GetCenter()) < GetScreenHeight()/2 then
			CoinPickupFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
		else
			CoinPickupFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
		end
	end
end

function Baggins:CreateMoneyFrame()
	local frame = CreateFrame("Button","BagginsMoneyFrame",UIParent)
	frame:SetPoint("CENTER")
	frame:SetWidth(100)
	frame:SetHeight(18)
	frame:EnableMouse(true)
	frame:SetScript("OnClick",MoneyFrame_OnClick)
	local goldIcon = frame:CreateTexture("BagginsGoldIcon", "ARTWORK")
	goldIcon:SetWidth(16)
	goldIcon:SetHeight(16)
	goldIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	goldIcon:SetTexCoord(0, 0.25, 0, 1)

	local silverIcon = frame:CreateTexture("BagginsSilverIcon", "ARTWORK")
	silverIcon:SetWidth(16)
	silverIcon:SetHeight(16)
	silverIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	silverIcon:SetTexCoord(0.25, 0.5, 0, 1)

	local copperIcon = frame:CreateTexture("BagginsCopperIcon", "ARTWORK")
	copperIcon:SetWidth(16)
	copperIcon:SetHeight(16)
	copperIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	copperIcon:SetTexCoord(0.5, 0.75, 0, 1)

	local goldText = frame:CreateFontString("BagginsGoldText", "OVERLAY")
	goldText:SetJustifyH("RIGHT")
	goldText:SetPoint("RIGHT", goldIcon, "LEFT", 0, 1)
	goldText:SetFontObject(GameFontNormal)

	local silverText = frame:CreateFontString("BagginsSilverText", "OVERLAY")
	silverText:SetJustifyH("RIGHT")
	silverText:SetPoint("RIGHT", silverIcon, "LEFT", 0, 1)
	silverText:SetFontObject(GameFontNormal)

	local copperText = frame:CreateFontString("BagginsCopperText", "OVERLAY")
	copperText:SetJustifyH("RIGHT")
	copperText:SetPoint("RIGHT", copperIcon, "LEFT", 0, 1)
	copperText:SetFontObject(GameFontNormal)

	copperIcon:SetPoint("RIGHT", frame, "RIGHT")
	silverIcon:SetPoint("RIGHT", copperText, "LEFT")
	goldIcon:SetPoint("RIGHT", silverText, "LEFT")
	frame:Hide()
end

function Baggins:UpdateMoneyFrame()

	local copper = GetMoney()
	local gold = floor(copper / 10000)
	local silver = mod(floor(copper / 100), 100)
	copper = mod(copper, 100)
		
	local width = 0
	
	if gold == 0 then
		BagginsGoldIcon:Hide()
		BagginsGoldText:Hide()
	else
		BagginsGoldIcon:Show()
		BagginsGoldText:Show()
		BagginsGoldText:SetWidth(0)
		BagginsGoldText:SetText(gold)
		width = width + BagginsGoldIcon:GetWidth() + BagginsGoldText:GetWidth()
	end
	if gold == 0 and silver == 0 then
		BagginsSilverIcon:Hide()
		BagginsSilverText:Hide()
	else
		BagginsSilverIcon:Show()
		BagginsSilverText:Show()
		BagginsSilverText:SetWidth(0)
		BagginsSilverText:SetText(silver)
		width = width + BagginsSilverIcon:GetWidth() + BagginsSilverText:GetWidth()
	end
	BagginsCopperIcon:Show()
	BagginsCopperText:Show()
	BagginsCopperText:SetWidth(0)
	BagginsCopperText:SetText(copper)
	width = width + BagginsCopperIcon:GetWidth() + BagginsCopperText:GetWidth()
	BagginsMoneyFrame:SetWidth(width)
end

function Baggins:SetBagTitle(bagid,title)
	if self.bagframes[bagid] then
		self.bagframes[bagid].title:SetText(title)
		self:UpdateBagFrameSize(bagid)
	end
end

function Baggins:AreBagsLocked()
	return self.db.profile.lock or self.db.profile.layout == "auto"
end

function Baggins:UpdateLayout()
	if self.db.profile.layout == "auto" then
		self:LayoutBagFrames()
	else
		self:LoadBagPositions()
	end
end

----------------------
-- ItemButton Funcs --
----------------------
function Baggins:UpdateItemButtons()
	for bagid, bag in ipairs(self.bagframes) do
		for sectionid, section in ipairs(bag.sections) do
			for buttonid, button in ipairs(section.items) do
				if button:IsVisible() then
					self:UpdateItemButton(bag,button,button:GetParent():GetID(),button:GetID())
				end
			end
		end
	end
end

function Baggins:UpdateItemButtonLocks()
	for bagid, bag in ipairs(self.bagframes) do
		for sectionid, section in ipairs(bag.sections) do
			for buttonid, button in ipairs(section.items) do
				if button:IsVisible() then
					local locked = select(3, GetContainerItemInfo(button:GetParent():GetID(), button:GetID()))
					SetItemButtonDesaturated(button, locked, 0.5, 0.5, 0.5)
				end
			end
		end
	end
end

function Baggins:UpdateItemButtonCooldowns()
	for bagid, bag in ipairs(self.bagframes) do
		for sectionid, section in ipairs(bag.sections) do
			for buttonid, button in ipairs(section.items) do
				if button:IsVisible() then
					local container = button:GetParent():GetID()
					local slot = button:GetID()
					local texture = GetContainerItemInfo(container, slot)
					if ( texture ) then
						self:UpdateItemButtonCooldown(container, button)
						button.hasItem = 1
					else
						getglobal(button:GetName().."Cooldown"):Hide()
						button.hasItem = nil
					end
				end
			end
		end
	end
end

function Baggins:SetItemButtonCount(button, count, realcount)
	if not button then
		return
	end
	if not count then
		count = 0
	end
	local counttext = getglobal(button:GetName().."Count")
	if button.countoverride then
		button.count = realcount
	else
		button.count = count
	end
	if type(count) == "string" then
		counttext:ClearAllPoints()
		counttext:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-5,2)
		counttext:SetText(count)
		counttext:Show()
	elseif ( count > 1 or (button.isBag and count > 0) ) then
		if ( count > 999 ) then
			count = (math.floor(count/100)/10).."k"
			counttext:ClearAllPoints()
			counttext:SetPoint("BOTTOM",button,"BOTTOM",0,2)
		else
			counttext:ClearAllPoints()
			counttext:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-5,2)
		end
		counttext:SetText(count)
		counttext:Show()
	else
		counttext:Hide()
	end
end

function Baggins:IsNew(itemid)
	local itemcounts = self.itemcounts
	itemid = tonumber(itemid) or tonumber(itemid:match("item:(%d+)"))
	if not itemid then
		return nil
	end
	local savedcount = itemcounts[itemid] 
	if not savedcount then
		return 1	-- completely new
	else
		local count = GetItemCount(itemid)
		if count > savedcount then
			return 2	-- more of an existing
		else
			return nil	-- not new
		end
	end
end

function Baggins:UpdateItemButton(bagframe,button,bag,slot)
	local p = self.db.profile
	local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
	local link = GetContainerItemLink(bag, slot)
	local itemid
	if link then
		local qual = select(3, GetItemInfo(link))
		quality = qual or quality
		itemid = tonumber(link:match("item:(%d+)"))
	end
	button:SetID(slot)
	if p.qualitycolor and texture and quality >= p.qualitycolormin then
		local r, g, b = GetItemQualityColor(quality)
		button.glow:SetVertexColor(r,g,b)
		button.glow:SetAlpha(p.qualitycolorintensity)
		button.glow:Show()
	else
		button.glow:Hide()
	end
	local text = button.newtext
	if p.highlightnew and itemid and bag >= 0 and bag <= NUM_BAG_SLOTS then
		local isNew = self:IsNew(itemid)
		if isNew == 1 then
			text:SetText(L["*New*"])
			text:Show()
		elseif isNew == 2 then
			text:SetText("*+++*")
			text:Show()
		else
			text:Hide()
		end
	else
		text:Hide()
	end
	
	if not bagframe.bagparents[bag] then 
		bagframe.bagparents[bag] = CreateFrame("Frame",nil,bagframe)
		bagframe.bagparents[bag]:SetID(bag)
	end
	button:SetParent(bagframe.bagparents[bag])
	if texture then
		SetItemButtonTexture(button, texture)
	elseif self.currentSkin.EmptySlotTexture then
		SetItemButtonTexture(button, self.currentSkin.EmptySlotTexture)
	else
		SetItemButtonTexture(button, nil)
	end
	if button.countoverride then
		local count
		if not itemid then
			local bagtype, itemFamily = Baggins:IsSpecialBag(bag)
			bagtype = bagtype or ""
			count = bagtype..LBU:CountSlots(LBU:IsBank(bag) and "BANK" or "BAGS", itemFamily)
		else
			count = GetItemCount(itemid)
			if LBU:IsBank(bag) then
				count = GetItemCount(itemid,true) - count
			end
			if IsEquippedItem(itemid) then
				count = count - 1
			end
		end
		self:SetItemButtonCount(button, count, itemCount)
	else
		self:SetItemButtonCount(button, itemCount)
	end
	SetItemButtonDesaturated(button, locked, 0.5, 0.5, 0.5)
	
	if ( texture ) then
		self:UpdateItemButtonCooldown(bag, button)
		button.hasItem = 1
	else
		getglobal(button:GetName().."Cooldown"):Hide()
		button.hasItem = nil
	end

	button.readable = readable
	--local normalTexture = getglobal(name.."Item"..j.."NormalTexture")
	--if ( quality and quality ~= -1) then
	--	local color = getglobal("ITEM_QUALITY".. quality .."_COLOR")
	--	normalTexture:SetVertexColor(color.r, color.g, color.b)
	--else
	--	normalTexture:SetVertexColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	--end
	--[[
	if button:GetParent():GetID() == -1 then
		if ( not GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(button:GetID(),button.isBag)) ) then
			if ( self.isBag ) then
				GameTooltip:SetText(self.tooltipText);
			end
		end
		CursorUpdate();
		return
	end
	
	local showSell = nil;
	local hasCooldown, repairCost = GameTooltip:SetBagItem(button:GetParent():GetID(), button:GetID());
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 and not button.locked ) then
		showSell = 1;
	end

	if ( IsModifiedClick("DRESSUP") and button.hasItem ) then
		ShowInspectCursor();
	elseif ( showSell ) then
		ShowContainerSellCursor(button:GetParent():GetID(),button:GetID());
	elseif ( button.readable ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end]]
end

function Baggins:UpdateItemButtonCooldown(container, button)
	local cooldown = getglobal(button:GetName().."Cooldown")
	local start, duration, enable = GetContainerItemCooldown(container, button:GetID())
	CooldownFrame_SetTimer(cooldown, start, duration, enable)
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4)
	end
end


---------------------
-- Frame Placement --
---------------------
-- manual
function Baggins:SaveBagPosition(bagid)
	local frame = self.bagframes[bagid]
	if not frame then return end
	local s = frame:GetEffectiveScale()
	self.db.profile.bags[bagid].x = frame:GetLeft() * s
	self.db.profile.bags[bagid].y = frame:GetTop() * s
end

function Baggins:LoadBagPositions()
	for i = 1, #self.db.profile.bags do
		self:LoadBagPosition(i)
	end
end

function Baggins:LoadBagPosition(bagid)
	local bag = self.db.profile.bags[bagid]
	local frame = self.bagframes[bagid]
	if not frame then return end
	local s = frame:GetEffectiveScale()
	frame:ClearAllPoints()
	if bag.x and bag.y then
		frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT", bag.x / s, bag.y / s)
	else
		frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
	end
end
-- auto
function Baggins:SaveBagPlacement()
	local p = self.db.profile
	local frame = BagginsBagPlacement
	if not frame then return end
	local s = frame:GetEffectiveScale()
	p.rightoffset = (GetScreenWidth() - frame:GetRight() )
	p.bottomoffset = frame:GetBottom()
	p.topoffset = (GetScreenHeight() - frame:GetTop() )
	p.leftoffset = frame:GetLeft()
end

function Baggins:LoadBagPlacement()
	local p = self.db.profile
	local frame = BagginsBagPlacement
	if not frame then return end
	local s = frame:GetEffectiveScale()
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT", - p.rightoffset, p.bottomoffset)
	frame:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT", - p.rightoffset, - p.topoffset)
end

function Baggins:ShowPlacementFrame()
	if not BagginsBagPlacement then
		self:CreateBagPlacementFrame()
	end
	Baggins:LoadBagPlacement()
	BagginsBagPlacement:Show()
end

function Baggins:LayoutBagFrames()
	self.dirtyBagLayout = true
	self:ScheduleRefresh()
end

function Baggins:ReallyLayoutBagFrames()
	local p = self.db.profile
	if p.layout ~= "auto" then return end
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, column, maxwidth
	local screenWidth = GetScreenWidth()

	screenHeight = GetScreenHeight()
	
	local initialcorner = p.layoutanchor
	local nextcorner, vdir, hdir
	local availableScreenHeight 
	if initialcorner == "BOTTOMRIGHT" then
		hdir = -1
		vdir = 1
		nextcorner = "TOPRIGHT"
		xOffset = p.rightoffset
		yOffset = p.bottomoffset
		availableScreenHeight = screenHeight - yOffset - p.topoffset
	elseif initialcorner == "BOTTOMLEFT" then
		hdir = 1
		vdir = 1
		nextcorner = "TOPLEFT"
		xOffset = p.leftoffset
		yOffset = p.bottomoffset
		availableScreenHeight = screenHeight - yOffset - p.topoffset
	elseif initialcorner == "TOPRIGHT" then
		hdir = -1
		vdir = -1
		nextcorner = "BOTTOMRIGHT"
		xOffset = p.rightoffset
		yOffset = p.topoffset
		availableScreenHeight = screenHeight - yOffset - p.bottomoffset
	elseif initialcorner == "TOPLEFT" then
		hdir = 1
		vdir = -1
		nextcorner = "BOTTOMLEFT"
		xOffset = p.leftoffset
		yOffset = p.topoffset
		availableScreenHeight = screenHeight - yOffset - p.bottomoffset
	end
	-- Adjust the start anchor for bags depending on the multibars
	
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = availableScreenHeight
	maxwidth = 1
	column = 0
	local index = 1
	local columnoffset = 0
	local prevframe
	for id, frame in ipairs(self.bagframes) do
		if frame:IsVisible() then
			--self:ReallyUpdateBagFrameSize(id)
			frame:ClearAllPoints()
			local s = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
			if ( index == 1 ) then
				-- First bag
				frame:SetPoint(initialcorner, frame:GetParent(), initialcorner,  hdir * xOffset/s, vdir * yOffset/s )
				index = index + 1
				prevframe = frame
			elseif ( freeScreenHeight < frame:GetHeight()*s ) then
				-- Start a new column
				column = column + 1
				columnoffset = columnoffset + maxwidth
				maxwidth = 1
				freeScreenHeight = availableScreenHeight
				frame:SetPoint(initialcorner, frame:GetParent(), initialcorner, hdir * ( columnoffset + xOffset/s), vdir * yOffset/s )
				index = index + 1
				prevframe = frame
			else
				-- Anchor to the previous bag
				frame:SetPoint(initialcorner, prevframe, nextcorner, 0, vdir * CONTAINER_SPACING)
				index = index + 1
				prevframe = frame
			end
			maxwidth = math.max(maxwidth, frame:GetWidth())
			self:SaveBagPosition(id)
			freeScreenHeight = freeScreenHeight - frame:GetHeight()*s - VISIBLE_CONTAINER_SPACING
		end
	end
	self.dirtyBagLayout = nil
end

function Baggins:UpdateBagScale()
	for i, frame in ipairs(self.bagframes) do
		frame:SetScale(self.db.profile.scale)
	end
end

---------------------
-- Fubar Plugin    --
---------------------
function Baggins:OnClick()
	if IsShiftKeyDown() then
		self:SaveItemCounts() 
		self:ForceFullUpdate()
	elseif IsControlKeyDown() and self.db.profile.layout == 'manual' then
		self.db.profile.lock = not self.db.profile.lock
	else
		self:ToggleAllBags()
	end
end

function Baggins:OnTooltipUpdate()
	local cat = tablet:AddCategory() 
	
	for bagid, bag in ipairs(self.db.profile.bags) do
		if not bag.isBank or (bag.isBank and self.bankIsOpen) then
			local color
			if bag.isBank then
				color = self.colors.blue
			else
				color = self.colors.white
			end
			local name = bag.name
			if self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() then
				name = "* "..name
			end
			cat:AddLine("text",name,"func", function(self, bagid) 
													if IsShiftKeyDown() then
														self:MoveBag(bagid)
													elseif IsAltKeyDown() then
														self:MoveBag(bagid, true)
													else
														self:ToggleBag(bagid)
													end
												end ,"arg1",self,"arg2",bagid,
												"textR",color.r,"textG",color.g,"textB",color.b)
		end
	end
	tablet:SetHint(L["Click a bag to toggle it. Shift-click to move it up. Alt-click to move it down"])
end



function Baggins:BuildCountString(empty, total, color)
	local p = self.db.profile
	color = color or ""
	local div 
	if self:IsTextColored() then
		div = "|r/"
	else
		div = "/"
	end
	if p.showtotal then
		if p.showused and p.showempty then
			return format("%s%i%s%s%i%s%s%i", color, total-empty, div, color, empty, div, color, total)
		elseif p.showused then
			return format("%s%i%s%s%i", color, total-empty, div, color, total)
		elseif p.showempty then
			return format("%s%i%s%s%i", color, empty, div, color, total)
		end
		return format("%s%i", color, total)
	end
	
	if p.showused and p.showempty then
		return format("%s%i%s%s%i", color, total-empty, div, color, empty)
	elseif p.showused then
		return format("%s%i", color, total-empty)
	elseif p.showempty then
		return format("%s%i", color, empty)
	end
	return ""
end


local texts={}
function Baggins:OnTextUpdate()
	local p = self.db.profile
	local color
	
	if p.combinecounts then
		local normalempty,normaltotal = LBU:CountSlots("BAGS", 0)
		local itemFamilies 
		if p.showspecialcount then
			itemFamilies = 2047-256-4-2-1   -- all except keyring, ammo, quiver, soul
		else
			itemFamilies = 0
		end
		if p.showammocount then
			itemFamilies = itemFamilies +1 +2
		end
		if p.showsoulcount then
			itemFamilies = itemFamilies +4
		end
		
		local empty, total = LBU:CountSlots("BAGS", itemFamilies)
		empty=empty+normalempty
		total=total+normaltotal

		if self:IsTextColored() then
			local fullness = 1 - (empty/total)
			local r, g
			r = math.min(1,fullness * 2)
			g = math.min(1,(1-fullness) *2)
			color = ("|cFF%2X%2X00"):format(r*255,g*255)
		else
			color = ""
		end
		
		self:SetText(self:BuildCountString(empty,total,color))
		return
	end

	-- separate normal/ammo/soul/special counts
	
	local n=0	-- count of strings in texts{}

	local normalempty, normaltotal = LBU:CountSlots("BAGS", 0)
	
	if self:IsTextColored() then
		local fullness = 1 - (normalempty/normaltotal)
		local r, g
		r = math.min(1,fullness * 2)
		g = math.min(1,(1-fullness) *2)
		color = ("|cFF%2X%2X00"):format(r*255,g*255)
	else
		color = ""
	end
	
	n=n+1
	texts[n] = self:BuildCountString(normalempty,normaltotal,color)
	
	if self.db.profile.showsoulcount then
		local soulempty, soultotal = LBU:CountSlots("BAGS", 4)
		if soultotal>0 then
			if self:IsTextColored() then
				color = self.colors.purple.hex
			end
			n=n+1
			texts[n] = self:BuildCountString(soulempty,soultotal,color)
		end
	end
	
	if self.db.profile.showammocount then
		local ammoempty, ammototal = LBU:CountSlots("BAGS", 1+2)
		if ammototal>0 then
			if self:IsTextColored() then
				color = self.colors.white.hex
			end
			n=n+1
			texts[n] = self:BuildCountString(ammoempty,ammototal,color)
		end
	end
	
	if self.db.profile.showspecialcount then
		local specialempty, specialtotal = LBU:CountSlots("BAGS", 2047-256-4-2-1)
		if specialtotal>0 then
			if self:IsTextColored() then
				color = self.colors.blue.hex
			end
			n=n+1
			texts[n] = self:BuildCountString(specialempty,specialtotal,color)
		end
	end

	if n==1 then 
		self:SetText(texts[1])
	else
		self:SetText(tconcat(texts, " ", 1, n))
	end
end

---------------------
-- Add/Remove/Move --
---------------------
function Baggins:NewBag(bagname)
	local bags = self.db.profile.bags
	table.insert(bags, { name=bagname, openWithAll=true, sections={}})
	if not self.bagframes[#bags] then
		self:CreateBagFrame(#bags)
	end
	currentbag = #bags
	self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:UpdateBags()
	self:UpdateLayout()
	self:BuildMoneyBagOptions()
end

function Baggins:MoveBag(bagid, down)
	local bags = self.db.profile.bags
	local other
	if down then
		other = bagid + 1
	else
		other = bagid - 1
	end
	
	if bags[bagid] and bags[other] then
		bags[bagid], bags[other] = bags[other], bags[bagid]
	end
	self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:BuildMoneyBagOptions()
end

function Baggins:MoveSection(bagid, sectionid, down)
	local other
	if down then
		other = sectionid + 1
	else
		other = sectionid - 1
	end
	if self.db.profile.bags[bagid] then
		local sections = self.db.profile.bags[bagid].sections
		if sections[sectionid] and sections[other] then
			sections[sectionid], sections[other] = sections[other], sections[sectionid]
		end
	end
    self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
end

function Baggins:MoveRule(categoryid, ruleid, down)
	local other
	if down then
		other = ruleid + 1
	else
		other = ruleid - 1
	end
	local rules = self.db.profile.categories[categoryid]
	if rules then
		if rules[ruleid] and rules[other] then
			rules[ruleid], rules[other] = rules[other], rules[ruleid]
		end
	end
end

function Baggins:RemoveBag(bagid)
	self:CloseBag(bagid)
	table.remove(self.db.profile.bags, bagid)
	self:ResetCatInUse()
	self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:UpdateBags()
	self:UpdateLayout()
	local numbags, numbagframes = #self.db.profile.bags, #self.bagframes
	for i = numbags+1, numbagframes do
		if self.bagframes[i] then
			self.bagframes[i]:Hide()
		end
	end
	self:BuildMoneyBagOptions()
end

function Baggins:NewSection(bagid,sectionname)
	table.insert(self.db.profile.bags[bagid].sections, { name=sectionname, cats = {} })
	currentsection = #self.db.profile.bags[bagid].sections
	self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:UpdateBags()
	self:UpdateLayout()
end

function Baggins:NewCategory(catname)
	if not self.db.profile.categories[catname] then
		self.db.profile.categories[catname] = { name=catname } 
		currentcategory = catname
		self:BuildWaterfallTree()
		--tablet:Refresh("BagginsEditCategories")
		self:RefreshEditWaterfall() 
	end
end

function Baggins:RemoveSection(bagid, sectionid)
	table.remove(self.db.profile.bags[bagid].sections, sectionid)
	self:ResetCatInUse()
	self:ResortSections()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:UpdateBags()
	self:UpdateLayout()
end

function Baggins:RemoveRule(catid, ruleid)
	table.remove(self.db.profile.categories[catid], ruleid)
	--tablet:Refresh("BagginsEditCategories") 
	Baggins:OnRuleChanged()
end

function Baggins:AddCategory(bagid,sectionid,category)
	table.insert(self.db.profile.bags[bagid].sections[sectionid].cats,category)
	self:ResetCatInUse(category)
	self:ForceFullRefresh()
	self:UpdateBags()
	self:UpdateLayout()
end

do
	local catinuse = { [true] = {}, [false] = {}}
	function Baggins:ResetCatInUse(catname)
		if catname then
			catinuse[true][catname] = nil
			catinuse[false][catname] = nil
		else
			for k in pairs(catinuse[true]) do
				catinuse[true][k] = nil
			end
			for k in pairs(catinuse[false]) do
				catinuse[false][k] = nil
			end
		end
	end
	
	function Baggins:CategoryInUse(catname, isbank)
		if not catname then return end
		if isbank == nil or catinuse[isbank][catname] == nil then
			for bid, bag in ipairs(self.db.profile.bags) do
				if isbank==nil or (not bag.isBank == not isbank) then
					for sid, section in ipairs(bag.sections) do
						for cid, cat in ipairs(section.cats) do
							if cat == catname then
								if isbank ~= nil then
									catinuse[isbank][catname] = true
								end
								return true
							end
						end
					end
				end
			end
			if isbank ~= nil then 
				catinuse[isbank][catname] = false
			end
			return false
		else
			return catinuse[isbank][catname]
		end
	end
end

function Baggins:RemoveCategory(bagid,sectionid,catid)
	local p = self.db.profile
	if type(bagid) == "string" then
		--removing a category completely
		
		if not self:CategoryInUse(bagid) then
			p.categories[bagid] = nil
			self:BuildWaterfallTree()
			--tablet:Refresh("BagginsEditCategories") 
		end
		self:BuildWaterfallTree()
		self:RefreshEditWaterfall() 
	else
		--removing a category from a bag
		table.remove(p.bags[bagid].sections[sectionid].cats,catid)
		self:ResetCatInUse()
		self:ForceFullRefresh()
		self:UpdateBags()
		self:UpdateLayout()
	end
end

---------------------
-- Bag Open/Close  --
---------------------
function Baggins:CloseBag(bagid)
	if self.bagframes[bagid] then
		self.bagframes[bagid]:Hide()
		if self.db.profile.hidedefaultbank and self.db.profile.bags[bagid].isBank then
			if self.bankIsOpen and not self:IsAnyBankOpen() then
				CloseBankFrame()
			end
		end
		self:UpdateLayout()
	end
	self:UpdateTooltip()
	
	if(not Baggins:IsWhateverOpen()) then
		--self:SetBagUpdateSpeed(false);	-- indicate bags closed
		self:FireSignal("Baggins_AllBagsClosed");
		-- reset temp no item compression
		if self.tempcompressnone then
			self.tempcompressnone = nil
			self:RebuildSectionLayouts()
		end		
	end
end

function Baggins:CloseAllBags()
	for bagid, bag in ipairs(self.db.profile.bags) do
		Baggins:CloseBag(bagid)
	end
end

function Baggins:ToggleBag(bagid)
	if not self.bagframes[bagid] then
		self:CreateBagFrame(bagid)
		self:OpenBag(bagid)
	elseif self.bagframes[bagid]:IsVisible() then
		self:CloseBag(bagid)
	else
		self:OpenBag(bagid)
	end
end

function Baggins:OpenBag(bagid,noupdate)
	--self:SetBagUpdateSpeed(true);	-- indicate bags open
	local p = self.db.profile
	if not self:IsActive() then
		return
	end
	if self.doInitialUpdate then
		Baggins:ForceFullUpdate()
		self.doInitialUpdate = nil
	end
	
	if p.bags[bagid].isBank and not self.bankIsOpen then
		return
	end
	self:ForceSectionReLayout(bagid)
	if not self.bagframes[bagid] then
		self:CreateBagFrame(bagid)
	end
	self.bagframes[bagid]:Show()
	if not noupdate then
		
		self:RunBagUpdates()
		self:UpdateBags()
	end
	self:UpdateLayout()
	self:UpdateTooltip()
end

-- "All Bags" in these 3 functions refers to bags that are set to openWithAll
function Baggins:OpenAllBags()
	local p = self.db.profile
	if not self:IsActive() then
		return
	end
	for bagid, bag in ipairs(p.bags) do
		if bag.openWithAll then
			Baggins:OpenBag(bagid,true)
		end
	end
	self:RunBagUpdates()
	self:UpdateBags()
	self:UpdateLayout()
end

function Baggins:AuctionHouse()
 	if self.db.profile.openatauction then
 		self:OpenAllBags()
 	end
end

function Baggins:ToggleAllBags(forceopen)
	if self:IsAllOpen() and not forceopen then
		self:CloseAllBags()
	else
		self:OpenAllBags()
	end
end

function Baggins:IsAllOpen()
	for bagid, bag in ipairs(self.db.profile.bags) do
		if bag.openWithAll and (not bag.isBank or self.bankIsOpen) then
			if not ( self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() ) then
				return false
			end
		end
	end
	return true
end

function Baggins:IsAnyOpen()
	for bagid, bag in ipairs(self.db.profile.bags) do
		if bag.openWithAll and (not bag.isBank or self.bankIsOpen) then
			if self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() then
				return true
			end
		end
	end
end

function Baggins:IsWhateverOpen()
	for bagid, bag in ipairs(self.db.profile.bags) do
		if self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() then
			return true
		end
	end
end

function Baggins:IsAnyBankOpen()
	for bagid, bag in ipairs(self.db.profile.bags) do
		if bag.isBank and self.bagframes[bagid] and self.bagframes[bagid]:IsVisible() then
			return true
		end
	end
end

function Baggins:IsEmpty(bagid)
	local count = 0
	if self.bagframes[bagid] then
		for i, v in ipairs(self.bagframes[bagid].sections) do
			count = count + v.itemcount or 0
		end
	end
	return count == 0
end

function Baggins:OpenBackpack()
	self:OpenAllBags()
end

function Baggins:CloseBackpack()
	self:CloseAllBags()
end

function Baggins:ToggleBackpack()
	if self:IsAnyOpen() then
		self:CloseAllBags()
	else
		self:OpenAllBags()
	end
end

function Baggins:CloseSpecialWindows()
    if self:IsAnyOpen() then
		self:CloseAllBags()
		return true
	end
	return self.hooks.CloseSpecialWindows()
end
