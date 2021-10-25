local band = bit.band;
local CreateFrame = CreateFrame;
local GetActionInfo = GetActionInfo;
local lshift = bit.lshift;
local next = next;
local OVERLAY_GLOW_SPELL_MAP = CHEESE_OVERLAY_GLOW_SPELL_MAP;
local OVERLAY_GLOW_SPELL_TABLE = CHEESE_OVERLAY_GLOW_SPELL_TABLE;
local OVERLAY_MAP = CHEESE_OVERLAY_MAP;
local OVERLAY_TABLE = CHEESE_OVERLAY_TABLE;
local OVERLAYS_UPPER_BOUND = CHEESE_OVERLAYS_UPPER_BOUND;
local pairs = pairs;
local PlayerFrame = PlayerFrame;
local rshift = bit.rshift;
local UnitBuff = UnitBuff;
local NUM_ACTION_BUTTONS = 12 * 12;
local actionButtons = {
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
	nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
};
local buffGlowSpells = {};
local buffs = {};
local spellsOverlayed = {};
local eventOverlayShowListeners = {};
local eventOverlayHideListeners = {};
local eventOverlayGlowShowListeners = {};
local eventOverlayGlowHideListeners = {};
local eventListeners = {
	["CHEESE_SPELL_ACTIVATION_OVERLAY_SHOW"] = eventOverlayShowListeners,
	["CHEESE_SPELL_ACTIVATION_OVERLAY_HIDE"] = eventOverlayHideListeners,
	["CHEESE_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"] = eventOverlayGlowShowListeners,
	["CHEESE_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE"] = eventOverlayGlowHideListeners,
};
local eventFrame1 = CreateFrame("Frame");
local eventFrame2 = CreateFrame("Frame");

local function AddOverlayGlow(globalID)
	local overlayedCount = spellsOverlayed[globalID];
	if ( not overlayedCount ) then
		spellsOverlayed[globalID] = 1;
		for frame, func in pairs(eventOverlayGlowShowListeners) do
			func(frame, globalID);
		end
	else
		spellsOverlayed[globalID] = overlayedCount + 1;
	end
end

local function RemoveOverlayGlow(globalID)
	local overlayedCount = spellsOverlayed[globalID];
	if ( overlayedCount == 1 ) then
		spellsOverlayed[globalID] = nil;
		for frame, func in pairs(eventOverlayGlowHideListeners) do
			func(frame, globalID);
		end
	else
		spellsOverlayed[globalID] = overlayedCount - 1;
	end
end

local function SetAction(action, globalID)
	actionButtons[action] = globalID;
	if ( globalID ) then
		local glowSpellK = OVERLAY_GLOW_SPELL_MAP()[globalID];
		if ( glowSpellK ) then
			local overlayGlowSpellTable = OVERLAY_GLOW_SPELL_TABLE();
			local spellID = overlayGlowSpellTable[glowSpellK];
			repeat
				local glowSpells = buffGlowSpells[spellID];
				if ( not glowSpells ) then
					buffGlowSpells[spellID] = {
						[globalID] = 1;
					};
					if ( buffs[spellID] ) then
						AddOverlayGlow(globalID);
					end
				else
					local refCount = glowSpells[globalID];
					if ( not refCount ) then
						glowSpells[globalID] = 1;
						if ( buffs[spellID] ) then
							AddOverlayGlow(globalID);
						end
					else
						glowSpells[globalID] = refCount + 1;
					end
				end
				glowSpellK = glowSpellK + 1;
				spellID = overlayGlowSpellTable[glowSpellK];
			until not spellID
		end
	end
end

local function ChangeAction(action, newGlobalID)
	local globalID = actionButtons[action];
	if ( globalID ) then
		local glowSpellK = OVERLAY_GLOW_SPELL_MAP()[globalID];
		if ( glowSpellK ) then
			local overlayGlowSpellTable = OVERLAY_GLOW_SPELL_TABLE();
			local spellID = overlayGlowSpellTable[glowSpellK];
			repeat
				local glowSpells = buffGlowSpells[spellID];
				local refCount = glowSpells[globalID];
				if ( refCount == 1 ) then
					glowSpells[globalID] = nil;
					if ( next(glowSpells) == nil ) then
						glowSpells = nil;
						buffGlowSpells[spellID] = nil;
					end
					if ( buffs[spellID] ) then
						RemoveOverlayGlow(globalID);
					end
				else
					glowSpells[globalID] = refCount - 1;
				end
				glowSpellK = glowSpellK + 1;
				spellID = overlayGlowSpellTable[glowSpellK];
			until not spellID
		end
	end
	SetAction(action, newGlobalID);
end

local function BuffGained(spellID, k, overlayTable)
	if ( k < OVERLAYS_UPPER_BOUND ) then
		local texture = "INTERFACE\\ADDONS\\CHEESE\\TEXTURES\\SPELLACTIVATIONOVERLAYS\\"..overlayTable[k + 1];
		local positions = overlayTable[k + 2];
		local scale = overlayTable[k + 3];
		local vertexColor = overlayTable[k + 4];
		local r = rshift(lshift(vertexColor, 8), 24);
		local g = rshift(lshift(vertexColor, 16), 24);
		local b = band(vertexColor, 0xff);
		for frame, func in pairs(eventOverlayShowListeners) do
			func(frame, spellID, texture, positions, scale, r, g, b);
		end
	end
	local glowSpells = buffGlowSpells[spellID];
	if ( glowSpells ) then
		for globalID in pairs(glowSpells) do
			AddOverlayGlow(globalID);
		end
	end
end

local function BuffLost(spellID)
	for frame, func in pairs(eventOverlayHideListeners) do
		func(frame, spellID);
	end
	local glowSpells = buffGlowSpells[spellID];
	if ( glowSpells ) then
		for globalID in pairs(glowSpells) do
			RemoveOverlayGlow(globalID);
		end
	end
end

local function eventFrame1_OnEventActionbarSlotChanged(self, event, action)
	if ( action ~= 0 ) then
		local actionType, id, subType, globalID = GetActionInfo(action);
		if ( actionType == "spell" ) then
			if ( actionButtons[action] ~= globalID ) then
				ChangeAction(action, globalID);
			end
		else
			if ( actionButtons[action] ) then
				ChangeAction(action, nil);
			end
		end
	else
		for action=1, NUM_ACTION_BUTTONS do
			local actionType, id, subType, globalID = GetActionInfo(action);
			if ( actionType == "spell" ) then
				if ( actionButtons[action] ~= globalID ) then
					ChangeAction(action, globalID);
				end
			else
				if ( actionButtons[action] ) then
					ChangeAction(action, nil);
				end
			end
		end
	end
end

local function eventFrame2_OnEventUnitAura(self, event, unitID)
	local unit = PlayerFrame.unit;
	if ( unitID == unit ) then
		do
			local name, _, _, count, _, _, _, _, _, _, spellID = UnitBuff(unit, 1);
			if ( name ) then
				local overlayMap = OVERLAY_MAP();
				local overlayTable;
				local j = 1;
				repeat
					local k = overlayMap[spellID];
					if ( k ) then
						if ( not overlayTable ) then
							overlayTable = OVERLAY_TABLE();
						end
						if ( not (count < overlayTable[k]) ) then
							local hasBuff = buffs[spellID];
							buffs[spellID] = false;
							if ( hasBuff == nil ) then
								BuffGained(spellID, k, overlayTable);
							end
						end
					end
					j=j+1;
					name, _, _, count, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
				until not name
			end
		end
		for spellID, hasBuff in pairs(buffs) do
			if ( not hasBuff ) then
				buffs[spellID] = true;
			else
				buffs[spellID] = nil;
				BuffLost(spellID);
			end
		end
	end
end

local function eventFrame1_OnEventPlayerLogin(self)
	eventFrame1:UnregisterEvent("PLAYER_LOGIN");
	do
		for action=1, NUM_ACTION_BUTTONS do
			local actionType, id, subType, globalID = GetActionInfo(action);
			if ( actionType == "spell" ) then
				SetAction(action, globalID);
			end
		end
	end
	eventFrame1:SetScript("OnEvent", eventFrame1_OnEventActionbarSlotChanged);
	eventFrame1:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	do
		local unit = PlayerFrame.unit;
		local name, _, _, count, _, _, _, _, _, _, spellID = UnitBuff(unit, 1);
		if ( name ) then
			local overlayMap = OVERLAY_MAP();
			local overlayTable;
			local j = 1;
			repeat
				local k = overlayMap[spellID];
				if ( k ) then
					if ( not overlayTable ) then
						overlayTable = OVERLAY_TABLE();
					end
					if ( not (count < overlayTable[k]) ) then
						buffs[spellID] = true;
						BuffGained(spellID, k, overlayTable);
					end
				end
				j=j+1;
				name, _, _, count, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
			until not name
		end
	end
	eventFrame2:SetScript("OnEvent", eventFrame2_OnEventUnitAura);
	eventFrame2:RegisterEvent("UNIT_AURA");
end

eventFrame1:SetScript("OnEvent", eventFrame1_OnEventPlayerLogin);
eventFrame1:RegisterEvent("PLAYER_LOGIN");

function Cheese_IsSpellOverlayed(spellID)
	return spellsOverlayed[spellID] and true or false;
end

function Cheese_RegisterEvent(event, frame, func)
	local listeners = eventListeners[event];
	if ( listeners ) then
		listeners[frame] = func;
	end
end

function Cheese_UnregisterEvent(event, frame)
	local listeners = eventListeners[event];
	if ( listeners ) then
		listeners[frame] = nil;
	end
end

if ( GetCVarBool("scriptProfile") ) then
	function Cheese_GetAPISpellActivationOverlayFuncs()
		return eventFrame1_OnEventPlayerLogin, eventFrame1_OnEventActionbarSlotChanged, eventFrame2_OnEventUnitAura, BuffGained, BuffLost, SetAction, ChangeAction, AddOverlayGlow, RemoveOverlayGlow;
	end
end
