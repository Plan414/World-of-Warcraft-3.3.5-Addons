--[[
Cast.lua
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
--]]
local DHUD3 = LibStub("AceAddon-3.0"):GetAddon("DHUD3");
local L = LibStub("AceLocale-3.0"):GetLocale("DHUD3");
local DogTag = LibStub("LibDogTag-3.0");

local MODNAME = "Cast";
local Cast = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 62 $"):match("%d+"));

local math_min = math.min;
local string_format = string.format;
--Fonts
local maxfont = 25
local minfont = 6  

--Local Defaults
local db
local defaults = {
	profile = {
		click = false,
		blizCast = true,
        player = {
			cast = true,
			side = "r",
			reverse = false;
			barText = true;
			textSize = 12;
			colors = {
		        spell = { 179/255, 31/255, 234/255 },
		        delay = { 1, 0, 0 },
				cast = {
		            full = { 0, 1, 1 },
		            med = { 0, 0, 1 },
		            low = { 1, 0, 1 }
		        },
			},
		},
        target = {
			cast = true,
			side = "l",
			reverse = false;
			barText = true;
			textSize = 12;
			colors = {
		        spell = { 179/255, 31/255, 234/255 },
		        delay = { 1, 0, 0 },
				cast = {
		            full = { 0, 1, 1 },
		            med = { 0, 0, 1 },
		            low = { 1, 0, 1 }
		        },
			},
		},
	}
}

-- Functions required by the configuration options table
local OptGetter, OptSetter, ColorGetter, ColorSetter, SelectGetter, SelectSetter;
do
	local mod = Cast
	function OptGetter(info)
		local key1, key2 = info[#info-1], info[#info];
		return db[key1][key2];
	end

	function OptSetter(info, value)
		local key1, key2 = info[#info-1], info[#info];
		db[key1][key2] = value;
		if key2 == "side" then
			if (key1 == "player") and (value == "l") then
				db.target.side = "r";
			elseif (key1 == "player") and (value == "r") then
				db.player.side = "l";
			elseif (key1 == "target") and (value == "l") then
				db.player.side = "r";
			elseif (key1 == "target") and (value == "r") then
				db.player.side = "l";
			end
		end
		mod:Refresh();
	end
    
	function SelectGetter (info, select)
        return db[select];
    end
    
    function SelectSetter (info, select, value) 
       db[select] = value;
       mod:Refresh();
    end
	
    function ColorGetter (info)
        local key1, key2, key3, key4 = info[#info-3], info[#info-2], info[#info-1], info[#info];
		return db[key1][key2][key3][key4][1], db[key1][key2][key3][key4][2], db[key1][key2][key3][key4][3];
	end
    
    function ColorSetter (info, r, g, b) 
        local key1, key2, key3, key4 = info[#info-3], info[#info-2], info[#info-1], info[#info];
        db[key1][key2][key3][key4][1] = r;
        db[key1][key2][key3][key4][2] = g;
        db[key1][key2][key3][key4][3] = b;
        mod:Refresh();
    end
end

--Local Options
local options
local function GetOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["The cast module manages the cast bars functionality."],
			arg = MODNAME,
            order = 2,
			get = OptGetter,
			set = OptSetter,
			childGroups = "tab",
    		args = {
				enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable Cast Module"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				blizCast = {
					type ='toggle',
					order = 2,
					get = function() return db.blizCast; end,
					set = function(info, value) db.blizCast = value; end,
					name = L["Cast Bar"],
					desc = L["Show Blizzard's Cast Bar."],
				},
				click = {
					type ='toggle',
					order = 3,
					name = L["Click Trough Frames"],
					desc = L["Cheking this option will prevent tooltips, frame moving and menu popping for this module"],
					get = function (info)
							local key = info[#info];
							return db[key];
						end,
					set = function (info, value)
							local key = info[#info];
							db[key] = value;
							mod:Refresh();
						end,
				},
				player = {
					type = 'group',
					name = L["Player"],
					order = 4,
					args = {
						cast = {
							type = 'toggle',
							order = 1,
							name = L["Cast Bar"],
							desc = L["Show/Hide Player cast bar"],
						},
						side = {
							type = 'select',
							order = 2,
							name = L["Side"],
							desc = L["Side to show the cast bar, target bar will be shown at the opposite side"],
							values = {["l"] = L["Left"], ["r"] = L["Right"]},
							disabled = BarEnabled,
						},
						reverse = {
							type = 'toggle',
							order = 3,
							name = L["Reverse"],
							desc = L["Cast bars fills in reverse direction"],
							disabled = BarEnabled,
						},
						barText = {
							type = 'toggle',
							order = 4,
							name = L["Show Bar Values"],
							disabled = BarEnabled,
						},
						textSize = {
							type = 'range',
							order = 4,
							name = L["Font size"],
							min = minfont,
							max = maxfont,
							disabled = BarEnabled,
							hidden = BarTextHidden,
							step = 1,
						},
						colors = {
							type = 'group',
							order = 5,
							name = L["Colors"],
							disabled = BarEnabled,
							get = function (info)
									local key1, key2, key3 = info[#info-2], info[#info-1], info[#info];
									return db[key1][key2][key3][1], db[key1][key2][key3][2], db[key1][key2][key3][3];
								end,
							set = function (info, r, g, b) 
							        local key1, key2, key3 = info[#info-2], info[#info-1], info[#info];
							        db[key1][key2][key3][1] = r;
							        db[key1][key2][key3][2] = g;
							        db[key1][key2][key3][3] = b;
							        Cast:Refresh();
							    end,
							args = {
								spell = {
									type = 'color',
									name = L["Spell Name"],
									order = 1,
									disabled = false,
								},
								delay = {
									type = 'color',
									name = L["Delay Time"],
									order = 2,
									disabled = false,
								},
								cast = {
									type = 'group',
									guiInline = true,
									name = L["Cast"],
									order = 3,
									disabled = false,
									get = ColorGetter,
									set = ColorSetter,
									args = {
										full = {
											type = 'color',
											name = L["Complete"],
											order = 1,
										},
										med = {
											type = 'color',
											name = L["Half"],
											order = 2,
										},
										low = {
											type = 'color',
											name = L["Begin"],
											order = 3,
										},
									},
								},
							},
						},
					},
				},
				target = {
					type = 'group',
					name = L["Target"],
					order = 5,
					args = {
						cast = {
							type = 'toggle',
							order = 1,
							name = L["Cast Bar"],
							desc = L["Show/Hide Target cast bar"],
						},
						side = {
							type = 'select',
							order = 2,
							name = L["Side"],
							desc = L["Side to show the cast bar, target bar will be shown at the opposite side"],
							values = {["l"] = L["Left"], ["r"] = L["Right"]},
							disabled = BarEnabled,
						},
						reverse = {
							type = 'toggle',
							order = 3,
							name = L["Reverse"],
							desc = L["Cast bars fills in reverse direction"],
							disabled = BarEnabled,
						},
						barText = {
							type = 'toggle',
							order = 4,
							name = L["Show Bar Values"],
							disabled = BarEnabled,
						},
						textSize = {
							type = 'range',
							order = 4,
							name = L["Font size"],
							min = minfont,
							max = maxfont,
							disabled = BarEnabled,
							hidden = BarTextHidden,
							step = 1,
						},
						colors = {
							type = 'group',
							order = 5,
							name = L["Colors"],
							disabled = BarEnabled,
							get = function (info)
									local key1, key2, key3 = info[#info-2], info[#info-1], info[#info];
									return db[key1][key2][key3][1], db[key1][key2][key3][2], db[key1][key2][key3][3];
								end,
							set = function (info, r, g, b) 
							        local key1, key2, key3 = info[#info-2], info[#info-1], info[#info];
							        db[key1][key2][key3][1] = r;
							        db[key1][key2][key3][2] = g;
							        db[key1][key2][key3][3] = b;
							        Cast:Refresh();
							    end,
							args = {
								spell = {
									type = 'color',
									name = L["Spell Name"],
									order = 1,
									disabled = false,
								},
								delay = {
									type = 'color',
									name = L["Delay Time"],
									order = 2,
									disabled = false,
								},
								cast = {
									type = 'group',
									guiInline = true,
									name = L["Cast"],
									order = 3,
									disabled = false,
									get = ColorGetter,
									set = ColorSetter,
									args = {
										full = {
											type = 'color',
											name = L["Complete"],
											order = 1,
										},
										med = {
											type = 'color',
											name = L["Half"],
											order = 2,
										},
										low = {
											type = 'color',
											name = L["Begin"],
											order = 3,
										},
									},
								},
							},
						},
					},
				},
			},
		}
	end
	return options;
end

local PlaceBarTexts, OnCast, InitCast, StopCast, UpdateCastText, SetCastAlpha;
do
	
	function OnCast(this, event, who)
		
		--DHUD3:Debug("Cast", event, who);
		if ( event == "PLAYER_TARGET_CHANGED" ) then
			if ( UnitExists("target") ) then
				local spell, _, _, _, startTime, endTime = UnitCastingInfo("target");
				this.channel = false;
				if ( not spell ) then
					spell, _, _, _, startTime, endTime = UnitChannelInfo("target");
					this.channel = true;
				end
				if ( startTime ) then
					this.startTime = startTime / 1000;
					this.finishTime = endTime / 1000;
					this.delay = 0;
					this:SetAlpha(1);
					this.barFadeOut = false;
					this.cast = true;
					this:SetScript("OnUpdate", Cast.OnUpdateCast);
					this:Show();
					_G["DHUD3_"..this.bar.."f"]:Hide();
					_G["DHUD3_"..this.bar.."_Text"]:Hide();	
					_G["DHUD3_"..this.bar.."d_Text"]:Hide();
					if ( db[this.who].barText ) then
						_G["DHUD3_"..this.bar.."n_Text_Text"]:SetText(spell);
						local w = _G["DHUD3_"..this.bar.."n_Text_Text"]:GetStringWidth() * 1.1;
						_G["DHUD3_"..this.bar.."n_Text_Text"]:SetWidth(w);
						_G["DHUD3_"..this.bar.."n_Text"]:SetWidth(w);
						_G["DHUD3_"..this.bar.."n_Text"]:Show();
					end
					SetCastAlpha();
				end
			else
				this.cast = false;
			    this.channel = false;
				this:SetScript("OnUpdate", nil);
				this:Hide();
				SetCastAlpha();
			end
		elseif ( who == this.who ) then
			if ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		        local spell, _, _, _, startTime, endTime = UnitCastingInfo(who);
				this.channel = false;
				if ( not spell ) then
					spell, _, _, _, startTime, endTime = UnitChannelInfo(who);
					this.channel = true;
				end
				if ( startTime ) then
					this.startTime = startTime / 1000;
					this.finishTime = endTime / 1000;
					this.delay = 0;
					this:SetAlpha(1);
					this.barFadeOut = false;
					this.cast = true;
					this:SetScript("OnUpdate", Cast.OnUpdateCast);
					this:Show();
					_G["DHUD3_"..this.bar.."f"]:Hide();
					_G["DHUD3_"..this.bar.."_Text"]:Hide();	
					_G["DHUD3_"..this.bar.."d_Text"]:Hide();
					if ( db[this.who].barText ) then
						_G["DHUD3_"..this.bar.."n_Text_Text"]:SetText(spell);
						local w = _G["DHUD3_"..this.bar.."n_Text_Text"]:GetStringWidth() * 1.1;
						_G["DHUD3_"..this.bar.."n_Text_Text"]:SetWidth(w);
						_G["DHUD3_"..this.bar.."n_Text"]:SetWidth(w);
						_G["DHUD3_"..this.bar.."n_Text"]:Show();
					end
					SetCastAlpha();
				end
			elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
				--DHUD3:Debug("UNIT_SPELLCAST_STOP", this.cast);
				if ( this.cast ) then
			        this.cast = false;
			        this.channel = false;
			        this.barFadeOut = true;
					_G["DHUD3_"..this.bar.."f"]:SetAlpha(0);
			        _G["DHUD3_"..this.bar.."f"]:Show();
					_G["DHUD3_"..this.bar.."f"].barFlash = true;
			        _G["DHUD3_"..this.bar.."f"].fadeAlpha = 0;
			        _G["DHUD3_"..this.bar.."f"]:SetScript("OnUpdate", Cast.OnUpdateFlash);
			    end
			elseif ( event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
			    --DHUD3:Debug("UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_UPDATE")
				local _, _, _, _, startTime, endTime = UnitCastingInfo(this.who);
			    if ( startTime ) then
					local oldStart = this.startTime;
			        this.startTime = startTime / 1000;
			        this.finishTime = endTime / 1000;
			        this.delay = this.delay + (startTime/1000 - oldStart);
			    end
			end
		end
    end
	
	function UpdateCastText(text, value)
	    --DHUD3:Debug("updateCastText", text, value);
	    if value and (value > 0) then 
			--DHUD3:Debug("updateCastText", text, value);
	        local castText = string_format("%.1f", value);
	        _G["DHUD3_"..text.."_Text_Text"]:SetText(castText);
	        _G["DHUD3_"..text.."_Text"]:Show();
	    end
	end
	
	function SetCastAlpha()
		-- Check both bars cast status and set alpha accordignly
		if DHUD3_rc.cast or DHUD3_lc.cast or DHUD3_rcf.barFlash or DHUD3_lcf.barFlash then
			DHUD3:UpdateAlpha(3, true);
		else
			DHUD3:UpdateAlpha(3, false);
		end
	end
end

function Cast:OnInitialize()
	self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, GetOptions, L["Cast"]);
	
    local bars = DHUD3.layout.castBars;
    local barText = DHUD3.layout.castText;
    
    -- Bars
    for k, v in pairs(bars) do
        point, parent, relative, position, texture, border = unpack(v);
        x0, x1, y0, y1 = unpack(DHUD3.layout[position]);
        ref = CreateFrame("Button", "DHUD3_"..k, _G["DHUD3_"..parent]);
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, 0, 0);
        ref:SetHeight(256);
        ref:SetWidth(128);
        bgt = ref:CreateTexture("DHUD3_"..k.."_Texture", "OVERLAY");
        bgt:SetTexture(texture);
        bgt:SetPoint(point, ref, relative, 0, 0);
        bgt:SetHeight(256);
        bgt:SetWidth(128);
        bgt:SetTexCoord(x0, x1, y0, y1);
        bgt:SetBlendMode("BLEND");
        bgt = ref:CreateTexture("DHUD3_"..k.."_Border", "BACKGROUND");
        bgt:SetPoint(point, ref, relative, 0, 0);
        bgt:SetHeight(256);
        bgt:SetWidth(128);
        bgt:SetTexCoord(x0, x1, y0, y1);
        bgt:SetBlendMode("BLEND");
        ref:EnableMouse(false);
        ref:Hide();
    end
	
	-- Bar's Text
    for k, v in pairs(barText) do
        point, parent, relative, x, y, width, height, justify = unpack(v);
        ref = CreateFrame("Frame", "DHUD3_"..k.."_Text", _G["DHUD3_"..parent]);
        ref:SetWidth(width);
        ref:SetHeight(height);
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, x, y);
        local font = ref:CreateFontString("DHUD3_"..k.."_Text_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint(justify, ref, justify, 0, 0);
		font:SetText(k.."Cast");
        font:SetJustifyH(justify);
		font:SetWidth(30);
        font:Show();
        ref.isMoving = false;
		ref.dropTimer = 0;
		ref:RegisterForDrag("LeftButton");
		ref:SetMovable(true);
		ref:SetScript("OnDragStart", DHUD3.MoveFrame);
		ref:SetScript("OnDragStop", DHUD3.DropFrame);
        ref:EnableMouse(true);
        ref:Hide();
    end
end

function Cast:OnEnable()
	
	self:Refresh();
end

function Cast:OnDisable()
	
	self:UnregisterAllEvents();
	DHUD3_rc:UnregisterAllEvents();
	DHUD3_rc:Hide();
	DHUD3_lc:UnregisterAllEvents();
	DHUD3_lc:Hide();
	
end

function Cast:Refresh()
	
	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile
	if not self:IsEnabled() then return end
	--BlizzFrames
	if ( not db.blizCast ) then
		--DHUD3:Debug("Hide cast bar");
		CastingBarFrame:UnregisterAllEvents();
	    CastingBarFrame:Hide();
	end
	DHUD3:PlaceBarTexts("castText");
    DHUD3_lc:Hide();
    DHUD3_rc:Hide();
    DHUD3_lcf:Hide();
    DHUD3_rcf:Hide();
    if db.player.cast then
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_START");
		_G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_STOP");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_DELAYED");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_FAILED");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        _G["DHUD3_"..db.player.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		_G["DHUD3_"..db.player.side.."c"]:SetScript("OnEvent", OnCast);
		_G["DHUD3_"..db.player.side.."c"].bar = db.player.side.."c";
		_G["DHUD3_"..db.player.side.."c"].who = "player";
		_G["DHUD3_"..db.player.side.."c"].cast = false;
		_G["DHUD3_"..db.player.side.."c"].channel = false;
		-- Bar's Text
		_G["DHUD3_"..db.player.side.."cn_Text_Text"]:SetTextColor(unpack(db.player.colors.spell));
		_G["DHUD3_"..db.player.side.."cd_Text_Text"]:SetTextColor(unpack(db.player.colors.delay));
		local scale = DHUD3.GetScale();
	    _G["DHUD3_"..db.player.side.."cd_Text_Text"]:SetFont(DHUD3:GetFont(), db.player.textSize * scale);
	    _G["DHUD3_"..db.player.side.."cn_Text_Text"]:SetFont(DHUD3:GetFont(), db.player.textSize * scale);
		_G["DHUD3_"..db.player.side.."c_Text_Text"]:SetFont(DHUD3:GetFont(), db.player.textSize * scale);
		-- Bars Text Click trough
		_G["DHUD3_"..db.player.side.."cd_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.player.side.."cd_Text"]:SetMovable(not db.click);
		_G["DHUD3_"..db.player.side.."c_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.player.side.."c_Text"]:SetMovable(not db.click);
		_G["DHUD3_"..db.player.side.."cn_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.player.side.."cn_Text"]:SetMovable(not db.click);
    end
	if db.target.cast then
		_G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_START");
		_G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_STOP");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_DELAYED");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_FAILED");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        _G["DHUD3_"..db.target.side.."c"]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		_G["DHUD3_"..db.target.side.."c"]:RegisterEvent("PLAYER_TARGET_CHANGED");
		_G["DHUD3_"..db.target.side.."c"]:SetScript("OnEvent", OnCast);
		_G["DHUD3_"..db.target.side.."c"].bar = db.target.side.."c";
		_G["DHUD3_"..db.target.side.."c"].who = "target";
		_G["DHUD3_"..db.target.side.."c"].cast = false;
		_G["DHUD3_"..db.target.side.."c"].channel = false;
		-- Bar's Text
		_G["DHUD3_"..db.target.side.."cn_Text_Text"]:SetTextColor(unpack(db.player.colors.spell));
		_G["DHUD3_"..db.target.side.."cd_Text_Text"]:SetTextColor(unpack(db.player.colors.delay));
		local scale = DHUD3.GetScale();
	    _G["DHUD3_"..db.target.side.."cd_Text_Text"]:SetFont(DHUD3:GetFont(), db.target.textSize * scale);
	    _G["DHUD3_"..db.target.side.."cn_Text_Text"]:SetFont(DHUD3:GetFont(), db.target.textSize * scale);
		_G["DHUD3_"..db.target.side.."c_Text_Text"]:SetFont(DHUD3:GetFont(), db.target.textSize * scale);
		-- Bars Text Click trough
		_G["DHUD3_"..db.target.side.."cd_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.target.side.."cd_Text"]:SetMovable(not db.click);
		_G["DHUD3_"..db.target.side.."c_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.target.side.."c_Text"]:SetMovable(not db.click);
		_G["DHUD3_"..db.target.side.."cn_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..db.target.side.."cn_Text"]:SetMovable(not db.click);
	end
end

function Cast:OnUpdateCast(event, elapsed)

	local currentTime = GetTime();
	local startTime = this.startTime;
	local finishTime = this.finishTime;
	local delay = this.delay;
	local color = {r=0,g=0,b=0,hex=""}
	if this.channel and this.cast then
		if currentTime > finishTime then
			this.cast = false;
			this.channel = false;
			this.barFadeOut = true;
			_G["DHUD3_"..this.bar.."f"]:SetAlpha(0);
			_G["DHUD3_"..this.bar.."f"]:Show();
			_G["DHUD3_"..this.bar.."f"].barFlash = true;
			_G["DHUD3_"..this.bar.."f"].fadeAlpha = 0;
			_G["DHUD3_"..this.bar.."f"]:SetScript("OnUpdate", Cast.OnUpdateFlash);
		end
		local dueTime = finishTime - currentTime;
		local value = dueTime / (finishTime - startTime);
		--DHUD3:Debug("Cast", event, dueTime, value);
		if db[this.who].reverse then
			value = 1 - value;
		end
		color.r, color.g, color.b, color.hex = DHUD3:Colorize(db[this.who].colors.cast, value);
		DHUD3:UpdateBar(this.bar, 1, value, color);
		if ( db[this.who].barText ) then
			UpdateCastText(this.bar, dueTime);
			UpdateCastText(this.bar.."d", delay);
		end
	elseif this.cast then
		if currentTime > finishTime then
			this.cast = false;
			this.channel = false;
			this.barFadeOut = true;
			_G["DHUD3_"..this.bar.."f"]:SetAlpha(0);
			_G["DHUD3_"..this.bar.."f"]:Show();
			_G["DHUD3_"..this.bar.."f"].barFlash = true;
			_G["DHUD3_"..this.bar.."f"].fadeAlpha = 0;
			_G["DHUD3_"..this.bar.."f"]:SetScript("OnUpdate", Cast.OnUpdateFlash);
		end
		local showTime = math_min(currentTime, finishTime) - startTime;
		local value = (currentTime - startTime) / (finishTime - startTime);
		if db[this.who].reverse then
			value = 1 - value;
		end
		color.r, color.g, color.b, color.hex = DHUD3:Colorize(db[this.who].colors.cast, value);
		DHUD3:UpdateBar(this.bar, 1, value, color);
		if ( db[this.who].barText ) then
			UpdateCastText(this.bar, showTime);
			UpdateCastText(this.bar.."d", delay);
		end
	elseif this.barFadeOut then
		local fadeAlpha = this:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if fadeAlpha > 0 then
			this:SetAlpha(fadeAlpha);
		else
			this:SetScript("OnUpdate", nil);
			this:Hide();
		end 
	end
end

function Cast:OnUpdateFlash(elapsed)
    
	--DHUD3:Debug("Cast", event);
    if this.barFlash then
        local fadeAlpha = this:GetAlpha() + CASTING_BAR_FLASH_STEP
        if fadeAlpha < 1 then
            this:SetAlpha(fadeAlpha);
        else
            this.barFlash = false;
            this:SetScript("OnUpdate", nil);
            this:Hide();
			SetCastAlpha();
        end            
    else
        this:SetScript("OnUpdate", nil);
    end
end
