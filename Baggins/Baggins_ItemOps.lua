--
-- This file contains operations on bags/items that are not really part of 
-- Baggins core functionality, such as compressing your inventory, splitting
-- items, etc.
--

local Baggins = Baggins

local L = AceLibrary("AceLocale-2.2"):new("Baggins")
local dewdrop = AceLibrary("Dewdrop-2.0")
local LBU = LibStub("LibBagUtils-1.0")



local bankBags = { BANK_CONTAINER }
for i=NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
	tinsert(bankBags, i);
end

local charBags = {}
for i=0, NUM_BAG_SLOTS do
	tinsert(charBags, i);
end
tinsert(charBags, KEYRING_CONTAINER)



------------------------------------------------------
-- Compress stacks and move stuff to specialty bags --
------------------------------------------------------


local incompleteSlots = {}	-- pairs of itemlink = bag*1000+slot, e.g. "foo" = 207 (bag 2 slot 7)
local compressLoopProtect = 0

function Baggins:CompressBags(bank,testonly)
	local bags = bank and bankBags or charBags;
	
	if not testonly and CursorHasItem() then 
		if not self.compress_target_bag then
			return; -- oookay, i'm not touching that item, it wasn't i that picked it up
		end
		PickupContainerItem(self.compress_target_bag, self.compress_target_slot);
		self:ScheduleEvent("Baggins_CompressBags", self.CompressBags, 0.1, self, bank);
		return;
	end
	self.compress_target_bag = nil;
	
	for k,v in pairs(incompleteSlots) do
		incompleteSlots[k] = nil;
	end
	
	for _,bag in ipairs(bags) do
		for slot=1,(GetContainerNumSlots(bag) or 0) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot);
			local link = GetContainerItemLink(bag, slot)
			if link and not locked then
				local _, _, _, _, _, _, _, iMaxStack = GetItemInfo(link);
				if iMaxStack and itemCount < iMaxStack then
					local itemid = link:match("item:(-?[%d]+):");
					if(incompleteSlots[itemid]) then	-- see if we have an incomplete stack of this sitting around
						if testonly then return true; end	-- Yup, we've got something that needs compressing!
						compressLoopProtect = compressLoopProtect + 1;
						if compressLoopProtect > 100 then compressLoopProtect=0; return; end
						
						PickupContainerItem(floor(incompleteSlots[itemid]/1000), incompleteSlots[itemid]%1000);
						self.compress_target_bag = bag
						self.compress_target_slot = slot
						self:ScheduleEvent("Baggins_CompressBags", self.CompressBags, 0.3, self, bank);
						return;
					else
						incompleteSlots[itemid] = bag*1000 + slot;	-- remember that there's an incomplete stack of this item sitting around
					end
				end
			end
		end
	end
	
	return Baggins:MoveToSpecialtyBags(bank,testonly);
end


local specialtyTargetBags = {} -- [family] = bag*1000 + slot

function Baggins:MoveToSpecialtyBags(bank,testonly)
	if not testonly and CursorHasItem() then 
		if not self.compress_target_bag then
			return; -- oookay, i'm not touching that item, it wasn't i that picked it up
		end
		PickupContainerItem(self.compress_target_bag, self.compress_target_slot);
		self:ScheduleEvent("Baggins_CompressBags", self.MoveToSpecialtyBags, 0.1, self, bank);
		return;
	end
	self.compress_target_bag = nil;

	
	for k,v in pairs(specialtyTargetBags) do
		specialtyTargetBags[k] = nil;
	end
	for _,bag in ipairs(bank and bankBags or charBags) do
		local free,bagFamily = LBU:GetContainerNumFreeSlots(bag)
		if free>0 and bagFamily~=0 then
			for slot=1, (GetContainerNumSlots(bag) or 0) do
				if not GetContainerItemLink(bag, slot) then
					specialtyTargetBags[bagFamily] =	bag*1000 + slot
					break	-- only interested in the first empty slot, we're only moving one item
				end
			end
		end
	end	
	
	-- Find stuff that can go in specialty bags
	if next(specialtyTargetBags) then
		for _,bag in ipairs(bank and bankBags or charBags) do
			local bagFamily = LBU:GetContainerFamily(bag)
			if bagFamily==0 then	-- only examine stuff in normal bags
				for slot=1, (GetContainerNumSlots(bag) or 0) do
					local link = GetContainerItemLink(bag, slot)
					if link then
						local itemFamily = GetItemFamily(link)
						if itemFamily~=0 then
							if select(9, GetItemInfo(link))=="INVTYPE_BAG" then
								-- specialty bags dont go in specialty bags
							else
								for bagFamily,dest in pairs(specialtyTargetBags) do
									if bit.band(itemFamily,bagFamily)~=0 then
										if testonly then return true; end
										compressLoopProtect = compressLoopProtect + 1;
										if compressLoopProtect > 100 then compressLoopProtect=0; return; end
										
										PickupContainerItem(bag,slot);
										self.compress_target_bag = floor(dest/1000);
										self.compress_target_slot = dest%1000;
										self:ScheduleEvent("Baggins_CompressBags", self.MoveToSpecialtyBags, 0.3, self, bank);
										return;
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if not testonly then
		compressLoopProtect = 0;
	end
	
end



Baggins:RegisterSignal("Baggins_AllBagsClosed", 
	function(self)
		self:CancelScheduledEvent("Baggins_CompressBags");
		compressLoopProtect = 0
	end,
	Baggins
);
	

local lastCanCompressBags = "maybe";
local lastCanCompressBank = "maybe";

function Baggins:RecheckCompress(delay)
	if delay then
		self:ScheduleEvent("Baggins_RecheckCompress", self.RecheckCompress, delay, self, nil);
		return;
	end
	local b
	b = self:CompressBags(false, true);	-- false=bags, true=testonly
	if b ~= lastCanCompressBags then
		lastCanCompressBags = b;
		self:FireSignal("Baggins_CanCompress", false, b);		-- false=bags
	end
	b = self:CompressBags(true, true);	-- true=bank, true=testonly
	if b ~= lastCanCompressBank then
		lastCanCompressBank = b;
		self:FireSignal("Baggins_CanCompress", true, b);  -- true=bank
	end
end

Baggins:RegisterSignal("Baggins_BagsUpdatedWhileOpen",
	function(self)
		self:RecheckCompress(compressLoopProtect>0 and 1.0 or 0.2);
	end,
	Baggins
);

Baggins:RegisterSignal("Baggins_BagOpened",
	function(self)
		self:RecheckCompress(0.1)
	end,
	Baggins
);



---------------------
-- Splitting items --
---------------------

local function BagginsItemButton_Split(bag,slot,amount)
	-- Pick up the new stack
	local link = GetContainerItemLink(bag,slot)
	SplitContainerItem(bag, slot, amount or 1)

	if(IsShiftKeyDown()) then
		return;	-- Just split off if shift was held down, keep new stack in cursor
	end
	
	-- First, try to put in specialty bags
	local itemFamily = GetItemFamily(link)
	if itemFamily~=0 then
		for _,destbag in ipairs(charBags) do
			local free,bagFamily = LBU:GetContainerNumFreeSlots(destbag)
			if free>0 and bit.band(bagFamily,itemFamily)~=0 then
				for destslot=1, GetContainerNumSlots(destbag) do
					if not GetContainerItemLink(destbag, destslot) then	
						PickupContainerItem(destbag, destslot) 
						return
					end
				end
			end
		end
	end
	
	-- Mkay, shove it in any bag with free slots
	for _,destbag in ipairs(charBags) do
		local free,bagFamily = GetContainerNumFreeSlots(destbag)
		if free>0 and bagFamily==0 then
			for destslot=1, GetContainerNumSlots(destbag) do
				if not GetContainerItemLink(destbag, destslot) then	
					PickupContainerItem(destbag, destslot) 
					return
				end
			end
		end
	end

	-- Ends up with the item in the cursor if there's no room. Indication enough?
end



---------------------
-- ItemButton menu --
---------------------

local lastSplitSliderValue = 1

local function splitSliderFunc(value)
	lastSplitSliderValue = value;
end

Baggins:RegisterSignal("Baggins_ItemButtonMenu", 

	function(self, button, dewdrop, level, value)
		local bag = button:GetParent():GetID();
		local slot = button:GetID();
		local link = GetContainerItemLink(bag,slot)
		if not link then return; end
		local _, itemCount = GetContainerItemInfo(bag, slot);
		local itemstring = link:match("(item:[-%d:]+)");
	
		if level==1 then
			local b;
			
			-- "Use"
			if not LBU:IsBank(bag) then
				dewdrop:AddLine("text",L["Use"], "secure", { type="item", item=itemstring },
					"closeWhenClicked",true, "tooltipText", L["Use/equip the item rather than bank/sell it"]);
				b=true;
			end
			
			-- "Split"
			if itemCount>1 then
				dewdrop:AddLine("text",format(L["Split %d"],lastSplitSliderValue),
					"func", BagginsItemButton_Split,
					"arg1",bag, "arg2",slot, "arg3", lastSplitSliderValue,
					"tooltipText", L["Split_tooltip"], 
					"mouseoverUnderline", true,
					"hasArrow",true, "hasSlider", true,
					"sliderMin", 1, "sliderMax", itemCount-1,
					"sliderStep", 1,
					"sliderValue", lastSplitSliderValue,
					"sliderFunc", splitSliderFunc,
					"textR", 1,
					"textG", lastSplitSliderValue>=itemCount and 0.5 or 1,
					"textB", lastSplitSliderValue>=itemCount and 0.5 or 1
				);
				b=true;
			end
			
			-- separator
			if b then
				dewdrop:AddLine("text","","disabled",1);
			end
		
		end
		
	end,
	Baggins
);

Baggins:RegisterSignal("Baggins_BagsUpdatedWhileOpen",
	function(self)
		if dewdrop:GetOpenedParent() then
			dewdrop:Refresh(1);
		end
	end,
	Baggins
);
