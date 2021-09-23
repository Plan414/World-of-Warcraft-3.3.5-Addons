--[[
Auras.lua
Copyright (c) 2006 by Markus Inger, 2006 by Caeryn Dryad, 2007-2009 by Horacio Hoyos

This file is part of DHUD3.

    DHUD3 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DHUD3 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DHUD3.  If not, see <http://www.gnu.org/licenses/>.
]]

local DHUD3 = LibStub("AceAddon-3.0"):GetAddon("DHUD3");
local L = LibStub("AceLocale-3.0"):GetLocale("DHUD3");

local MODNAME = "Auras";
local Auras = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 147 $"):match("%d+"));

local math_ceil = math.ceil
local math_floor = math.floor
local string_match = string.match
local string_sub = string.sub
local pairs = pairs
local _G = _G
local auraUpdateInterval = 1;
local auraPosition = "i";
local auraOrigin;
Auras.isLoaded = true;
local barShown = {m = false, o = false};
--Fonts
local maxfont = 25
local minfont = 6  

--Local Defaults
local db
local defaults = {
	profile = {
        side = "l";
		scale = 1;
        onlyMine = false;
        filter = false;
        filterTime = 30;
		buffsTips = true;
		fontSize = 10;
        weapon = true;
        weaponForce = true; -- Alwyas save space for weapon buffs
		weaponOrder = "last";
        expMin = 0;
        expSec = 59;
        colors = {
            full = { 1, 1, 1 },
            med = { 255/255, 125/255, 125/255 },
            low = { 255/255, 65/255, 0 }      
        },
    }
}

local OptGetter, OptSetter, ColorGetter, ColorSetter, WeaponHidden, WeaponBuff
do
	local mod = Auras
	function OptGetter(info)
		local key = info[#info];
		return db[key];
	end

	function OptSetter(info, value)
		local key = info[#info];
		db[key] = value;
		mod:Refresh();
	end
    
    function ColorGetter (info)
        local key1, key2 = info[#info-1], info[#info];
		return db[key1][key2][1], db[key1][key2][2], db[key1][key2][3];
	end
    
    function ColorSetter (info, r, g, b) 
        local key1, key2 = info[#info-1], info[#info];
        db[key1][key2][1] = r;
        db[key1][key2][2] = g;
        db[key1][key2][3] = b;
        mod:Refresh();
    end
    
	function WeaponHidden()
		return not db.weapon;
	end
	
    WeaponBuff = {["first"] = L["First"], ["last"] = L["Last"], ["lower"] = L["Lower"], ["higer"] = L["Higher"]}
end

--Local Options
local options
local function getOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["Auras"],
			arg = MODNAME,
			get = OptGetter,
			set = OptSetter,
    		args = {
                enabled = {
                    type = "toggle",
                    order = 1,
                    name = L["Enable Auras Module"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				general = {
					type = 'group',
					name = L["General"],
					order = 3,
					inline = true,
					disabled  = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						desc = {
							order = 0,
							type = "description",
							name = L["Configure general functionality"],
						},
						side = {
							type = 'select',
							order = 1,
							name = L["Auras Side"],
							desc = L["This setting will override the side setting for the abilities module"],
							values = {["r"] = L["Right"], ["l"] = L["Left"]},
						},
						buffsTips = {
							type = 'toggle',
							order = 2,
							name = L["Show Aura tips"],
						},
						fontSize = {
							type = 'range',
							order = 3,
							name = L["Font size"],
							min = 6,
							max = 25,
							step = 1,
						},
						expMin = {
							type = 'range',
							order = 4,
							name = L["Expiration Minutes"],
							min = 0,
							max = 59,
							step = 1,
						},
				        expSec = {
							type = 'range',
							order = 5,
							name = L["Expiration Seconds"],
							min = 0,
							max = 59,
							step = 1,
						},
						colors = { 
							type = 'group',
							name = L["Border Color"],
							order = 7,
							guiInline  = true,
							get = ColorGetter,
		                    set = ColorSetter,
							args = {
								full = {
									type = 'color',
									name = L["Expiration Close"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Half Time"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Expired"],
									order = 3,
								},
							},
						},
						scale = {
							type = "range",
							order = 6,
							name = L["Set Auras' scale"],
							min = 0.5,
							max = 1,
							step = 0.05,
						},
					},
				},
				filters = {
					type = 'group',
					order = 4,
					name = L["Filters"],
					inline = true,
					disabled  = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args =  {
						desc = {
							order = 0,
							type = "description",
							name = L["Aura filter options"],
						},
						onlyMine = {
							type = 'toggle',
							order = 1,
							name = L["Only Mine"],
							desc = L["Only show own auras"],
						},
				        filter = {
							type = 'toggle',
							order = 2,
							name = L["Filter Auras"],
							desc = L["Filter long duration Auras"],
						},
						filterTime = {
							type = 'range',
							order = 3,
							name = L["Filter Auras duration"],
							desc = L["Filter Auras with a total duration higher than this value (minutes)"],
							min = 10,
							max = 59,
							step = 1,
							disabled = function() return not db.filter; end,
						},
					},
				},
				weapons = {
					type = 'group',
					order = 5,
					name = L["Weapons"],
					inline = true,
					disabled  = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						desc = {
							order = 0,
							type = "description",
							name = L["Weapon enchant display"],
						},
				        weapon = {
							type = 'toggle',
							order = 1,
							name = L["Weapon Enchants"],
							desc = L["Show/Hide Auras from weapon enchants"],
						},
				        weaponOrder = {
							type = 'select',
							order = 2,
							name = L["Weapon Auras order"],
							desc = L["Choose weapon Auras display order"],
							values = WeaponBuff,
							disabled = WeaponHidden,
						},
					},
				},
            },
        }
        
    end
    
    return options;
end

local UpdatePlayerAuras, HidePlayerBuffs, OnUpdateAura, OnUpdateTimer
do
	function UpdatePlayerAuras()
		--DHUD3:Debug("updatePlayerAuras");
		-- Auras can be buffs or Weapon Enchants
	    local weaponInsert = {};
		weaponInsert.mainHand = false;
		weaponInsert.offHand = false;
	    local timeToEvent = 0;
		local showTime = (db.expMin * 60) + db.expSec;
		local showFilter = db.filterTime * 60;
		local timeLeft, hasWeapon, id, name,texture, duration, expirationTime, caster;
		local auraInit = 1;
		local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo();
		local insertWeapon = true;
		if db.weapon then
			-- Weapons
			local mainHand, offHand;
			if ( db.weaponOrder == "first" ) then
				mainHand = 1;
				offHand = hasMainHandEnchant and 2 or 1;
			elseif ( db.weaponOrder == "last") then
				insertWeapon = false;
			elseif ( db.weaponOrder == "lower" ) then
				mainHand = 1;
				offHand = hasMainHandEnchant and 9 or 1;
			elseif ( db.weaponOrder == "higer" ) then
				mainHand = 8;
				offHand = hasMainHandEnchant and 16 or 8;
			end
			if ( hasMainHandEnchant ) then
				local texture = GetInventoryItemTexture("player", 16);
				weaponInsert.mainHand = { mainHand, mainHandExpiration/1000, texture, 16 };
			end
			if ( hasOffHandEnchant ) then
				local texture = GetInventoryItemTexture("player", 17);
				weaponInsert.offHand = { offHand, offHandExpiration/1000, texture, 17 };
			end
			--DHUD3:Debug("Abilities Weapons, mainHand, offHand, weaponInsert.mainHand, weaponInsert.offHand", mainHand, offHand, weaponInsert.mainHand, weaponInsert.offHand);
		end
		local moreAuras = true;
		for j = 1, 16 do
			local show = false;
			hasWeapon = false;
			if ( moreAuras ) then
				for i = auraInit, 40 do
					name, _, texture, _, _, duration, expirationTime, caster = UnitBuff("player", i);
					if ( name and ( duration > 0 ) ) then
						if ( not ( ( caster ~= "player" ) and db.onlyMine ) ) then
							if not ( db.filter and ( duration > showFilter ) ) then
								timeLeft = expirationTime - GetTime();
								if ( timeLeft > 0 and math_floor(timeLeft) <= showTime ) then
									id = i;
									auraInit = i + 1;
									show = true;
									break;
								elseif timeLeft > 0 then
									local newtimeToEvent = timeLeft - showTime
									if ( ( newtimeToEvent < timeToEvent ) or timeToEvent == 0 ) then
										timeToEvent = newtimeToEvent;
									end
								end
							end
						end
					end
				end	
				if ( not show ) and ( not insertWeapon ) then
					moreAuras = false;
					if ( hasMainHandEnchant ) then
						local texture = GetInventoryItemTexture("player", 16);
						weaponInsert.mainHand = { j, mainHandExpiration/1000, texture, 16 };
					end
					if ( hasOffHandEnchant ) then
						local texture = GetInventoryItemTexture("player", 17);
						weaponInsert.offHand = { hasMainHandEnchant and j + 1 or j, offHandExpiration/1000, texture, 17 };
					end
				end
			end
			if ( weaponInsert.mainHand ) then
				if ( weaponInsert.mainHand[1] == j ) then
					timeLeft = weaponInsert.mainHand[2];
					if ( timeLeft > 0 and math_floor(timeLeft) <= showTime ) then
						texture = weaponInsert.mainHand[3];
						id = weaponInsert.mainHand[4];
						if ( show ) then auraInit = auraInit - 1; end
						show = true;
						hasWeapon = true;
					elseif timeLeft > 0 then
						local newtimeToEvent = timeLeft - showTime
						if ( ( newtimeToEvent < timeToEvent ) or timeToEvent == 0 ) then
							--DHUD3:Debug("Main Hand, timeToEvent", newtimeToEvent);
							timeToEvent = newtimeToEvent;
						end
					end
				end
			elseif ( weaponInsert.offHand ) then
				if ( weaponInsert.offHand[1] == j ) then
					if ( timeLeft > 0 and math_floor(timeLeft) <= showTime ) then
						timeLeft = weaponInsert.offHand[2];
						texture = weaponInsert.offHand[3];
						id = weaponInsert.offHand[4];
						if ( show ) then auraInit = auraInit - 1; end
						show = true;
						hasWeapon = true;
					elseif timeLeft > 0 then
						local newtimeToEvent = timeLeft - showTime
						if ( ( newtimeToEvent < timeToEvent ) or timeToEvent == 0 ) then
							timeToEvent = newtimeToEvent;
						end
					end
				end
			end
			if ( show ) then
				local r, g, b, hex = DHUD3:Colorize(db.colors, timeLeft / 20);
				local button = _G["DHUD3_"..db.side.."buff"..j];
				button.id = id;
				button.hasweapon = hasWeapon;
				button.auraTimer = 0;
				button.left = timeLeft;
				_G["DHUD3_"..db.side.."buff"..j.."_Back"]:SetTexture(texture);
				local buffBorder = _G["DHUD3_"..db.side.."buff"..j.."_Border"];
				buffBorder:SetVertexColor(r, g, b);
				buffBorder:Show();
				local buffText = _G["DHUD3_"..db.side.."buff"..j.."_Text"];
				buffText:SetText("|cff"..hex..DHUD3:FormatTime(button.left));
				local w = buffText:GetStringWidth() + 10;
				buffText:SetWidth(w);
				button:SetScript("OnUpdate", OnUpdateAura);
				button:Show();
			else
				local button = _G["DHUD3_"..db.side.."buff"..j]
		        button.id = 0
		        button:SetScript("OnUpdate", nil)
		        button:Hide()
			end
		end
		local frame;
			if db.side == "l" then
				frame = _G["DHUD3_leftAura"];
			else
				frame = _G["DHUD3_rightAura"];
			end
	    if timeToEvent > 1 then
	        -- Trigger an event for the buff with closest time to playerBuffTimeFilter
	        frame.buffTimer = timeToEvent
			frame.crono = 0
	        frame.buffTimerOn = true
	        frame:SetScript("OnUpdate", OnUpdateTimer)
	    else
	        --DHUD3:Debug("No Timer")
	        frame.buffTimerOn = false
	        frame:SetScript("OnUpdate", nil)
	    end
	end

	function HidePlayerBuffs()
		for i = 1, 16 do
			 _G["DHUD3_lbuff"..i]:Hide()
			 _G["DHUD3_rbuff"..i]:Hide()
		end
	end

	function OnUpdateAura(event, elapsed)
	
	    this.auraTimer = this.auraTimer + elapsed;          
		if this.auraTimer >= auraUpdateInterval then
			if this.hasweapon then
				--DHUD3:Debug(event, "hasWeapon", this.id);
				local _, mainHandExpiration, _, _, offHandExpiration, _ = GetWeaponEnchantInfo();
				if this.id == 16 and mainHandExpiration then 
					this.left = mainHandExpiration/1000;
				elseif this.id == 17 and offHandExpiration then
					this.left = offHandExpiration/1000;
				end
			else
				this.left = this.left - this.auraTimer;
			end
			if this.left <= 0 then
				this.id = 0;
				this.hasbuff = false;
				this.hasweapon = false;
				this:SetScript("OnUpdate", nil);
				return this:Hide();
			end
			this.auraTimer = 0;
			local r, g, b, hex = DHUD3:Colorize(db.colors, this.left / 20);
			local buffBorder = _G[this:GetName().."_Border"];
			buffBorder:SetVertexColor(r, g, b);
			local buffText = _G[this:GetName().."_Text"];
			buffText:SetText("|cff"..hex..DHUD3:FormatTime(this.left));
			local w = buffText:GetStringWidth() + 10;
			buffText:SetWidth(w);
			if ( GameTooltip:IsOwned(this) ) then
				if ( not this.hasWeapon ) then
					GameTooltip:SetUnitBuff("player", this.id);
				else
					GameTooltip:SetInventoryItem("player", this.id);
				end
			end						
		end
	end
	
	function OnUpdateTimer(event, elapsed)
		this.crono = this.crono + elapsed
		if this.crono >= this.buffTimer then
			this:SetScript("OnUpdate", nil);
			this.buffTimerOn = false;
			UpdatePlayerAuras();
		elseif not this.buffTimerOn then
	        this:SetScript("OnUpdate", nil)
		end
	end

end

function Auras:OnInitialize()

    self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, getOptions, L["Auras"]);

    -- Player Buff
	for k = 1, 16 do
		-- Left
        ref = CreateFrame("Button", "DHUD3_lbuff"..k, _G["DHUD3_leftAura"]);
        ref:ClearAllPoints();
        ref:SetPoint("BOTTOM", _G["DHUD3_leftAura"], "BOTTOM", 0, 0);
        ref:SetHeight(26);
        ref:SetWidth(26);
		bgt = ref:CreateTexture("DHUD3_lbuff"..k.."_Back", "BORDER");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\icon");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26);
        bgt:SetWidth(26);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_lbuff"..k.."_Border", "ARTWORK");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\serenity0");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.6);
        bgt:SetWidth(26*1.6);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
        font = ref:CreateFontString("DHUD3_lbuff"..k.."_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint("CENTER", ref, "CENTER", 0, 0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(26*2);
		ref:Hide();
        
		-- Right
		ref = CreateFrame("Button", "DHUD3_rbuff"..k, _G["DHUD3_rightAura"]);
        ref:ClearAllPoints();
        ref:SetPoint("BOTTOM", _G["DHUD3_rightAura"], "BOTTOM", 0, 0);
        ref:SetHeight(26);
        ref:SetWidth(26);
		bgt = ref:CreateTexture("DHUD3_rbuff"..k.."_Back", "BORDER");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\icon");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26);
        bgt:SetWidth(26);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_rbuff"..k.."_Border", "ARTWORK");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\serenity0");
        bgt:SetVertexColor(1.0, 1.0, 1.0);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.6);
        bgt:SetWidth(26*1.6);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
        font = ref:CreateFontString("DHUD3_rbuff"..k.."_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint("CENTER", ref, "CENTER", 0,0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(26*2);
        ref:Hide();
    end
    
end

function Auras:OnEnable()
    
	--DHUD3:Debug("Auras:OnEnable");	
    self:Refresh();
	if not self:IsEnabled() then return; end
	self:RegisterEvent("UNIT_AURA");
	-- Listen to bar pops
	Auras:RegisterMessage("DHUD3_BAR_SHOW");
	Auras:RegisterMessage("DHUD3_BAR_HIDE");
end

function Auras:OnDisable()

    self:UnregisterAllEvents();
	self:UnregisterAllMessages();
	for i = 1, 16 do
		local button = _G["DHUD3_"..db.side.."buff"..i];
		button:SetScript("OnUpdate", nil);
		button:Hide();
	end
	self:SendMessage("DHUD3_AURAS_REFRESH", false);
end

function Auras:Refresh()
	
	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile;
	if not self:IsEnabled() then return; end
	
	DHUD3_leftAura:SetScale(db.scale);
	DHUD3_rightAura:SetScale(db.scale);
	auraPosition = "i";
	local hide, parent, xDev;
	if ( db.side == "l" ) then
		parent = _G["DHUD3_leftAura"];
		hide = "r";
		xDev = - ( 151 / db.scale) - 13 * db.scale;
	else
		parent = _G["DHUD3_rightAura"];
		hide = "l";
		xDev = ( 151 / db.scale) + 13 * db.scale;
	end
	local x, y;
	local xCol = 0;
	for i = 1, 16 do
		-- Show
		local name = "DHUD3_"..db.side.."buff"..i;
		local button = _G[name];
		local _, _, _, xOfs, yOfs = button:GetPoint(1);
		local xDif;
		button:ClearAllPoints();
		step = ( 256 * db.scale)/8;
		if (i < 9 ) then
			y = (step * (i - 0.5));
			yPos = (32 * ( i - 0.5)) - 15;
			xCol = 0;
		else
			y = (step * (i - 8.5));
			xCol = (db.side == "l") and -35 or 35;
			yPos = (32 * ( i - 8.5)) - 15;
			xDif = ( xOfs < x ) and ( x - xOfs ) or 0;
		end
		if ( db.side == "l" ) then
			x = (-17.899 - 0.351*y + 0.00137*y^2)/db.scale;
		else
			x = (17.899 + 0.351*y - 0.00137*y^2)/db.scale;
		end
        button:SetPoint("BOTTOM", parent, "BOTTOM", x + xDev + xCol, yPos);
		button:SetScript("OnUpdate", nil);
		button:Hide();
		font = _G[name.."_Text"]
        font:SetFont(DHUD3:GetFont(), db.fontSize);
        local w = font:GetStringWidth() * 1.1;
        font:SetWidth(w);
		if ( db.buffsTips ) then
			button:EnableMouse(true);
			button:SetScript("OnEnter", function(this) 
	                if not ( this:IsVisible() )  or ( this:GetEffectiveAlpha() == 0 ) then
	                    return;
	                end
	                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	                GameTooltip:SetUnitAura("player", this.id, "HELPFUL");
	            end )
	        button:SetScript("OnLeave", function() 
	                GameTooltip:Hide();
	            end )
		else
			button:EnableMouse(false);
		end
		
		--Hide
		local name = "DHUD3_"..hide.."buff"..i;
		button = _G[name];
		button:SetScript("OnUpdate", nil);
		button:SetScript("OnEnter", nil);
		button:Hide();
        font = _G[name.."_Text"];
        font:SetFont(DHUD3:GetFont(), db.fontSize * db.scale)
        w = font:GetStringWidth() * 1.1
        font:SetWidth(w);
	end		
	UpdatePlayerAuras();
	self:SendMessage("DHUD3_AURAS_REFRESH", true, db.side);
end

function Auras:UNIT_AURA(event, who)
	----self:Debug("UNIT_AURA", who)
	if who == "player" then
		UpdatePlayerAuras();
    end
end

function Auras:DHUD3_BAR_SHOW(event, bar)
	
	local barSide = string_sub(bar, 1, 1);
	local position = string_sub(bar, 2);
	--DHUD3:Debug("Auras, bar, position, barShown", bar, position, barShown.m, barShown.o);
	if ( barSide == db.side ) then	
		-- The bar popped in the same side the auras are and the auras need to be moved
		local xDis = 0;
		if ( position == "m" ) then
			if ( (not barShown.m) and (not barShown.o) ) then
				xDis = 15;
				barShown.m = true;
			end
		elseif ( position == "o" ) then
			if ( (not barShown.o) and (not barShown.m) ) then
				xDis = 30;
				barShown.o = true;
			elseif ( (not barShown.o) and barShown.m ) then
				xDis = 15;
				barShown.o = true;
			end
		end
		if (xDis ~= 0 ) then
			xDis = xDis/db.scale;
			local button, point, relativeTo, relativePoint, xOfs, yOfs;
			for i = 1, 16 do
				button = _G["DHUD3_rbuff"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs + xDis, yOfs);
				button = _G["DHUD3_lbuff"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs - xDis, yOfs);
			end
			--DHUD3:Debug("move", xDis);
		end
	end
end

function Auras:DHUD3_BAR_HIDE(event, bar)
	
	local barSide = string_sub(bar, 1, 1);
	local position = string_sub(bar, 2);
	--DHUD3:Debug("Auras, bar, position, barShown", bar, position, barShown.m, barShown.o);
	if ( barSide == db.side ) then
		-- The bar popped in the same side the auras are and the auras need to be moved
		local xDis = 0;
		if ( position == "o" ) then
			if ( barShown.o and (not barShown.m) ) then
				xDis = -30;
				barShown.o = false;
			elseif ( barShown.o and barShown.m ) then
				xDis = -15;
				barShown.o = false;
			end
		elseif ( position == "m" ) then
			if ( barShown.m and (not barShown.o) ) then
				xDis = -15;
				barShown.m = false;
			end
		end
		if (xDis ~= 0 ) then
			xDis = xDis/db.scale;
			local button, point, relativeTo, relativePoint, xOfs, yOfs;
			for i = 1, 16 do
				button = _G["DHUD3_rbuff"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs + xDis, yOfs);
				button = _G["DHUD3_lbuff"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs - xDis, yOfs);
			end
			--DHUD3:Debug("move", xDis);
		end	
	end
end
