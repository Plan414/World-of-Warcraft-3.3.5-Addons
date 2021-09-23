--[[
Abilities.lua
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

local MODNAME = "Abilities";
local Abilities = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 147 $"):match("%d+"));

local string_sub = string.sub;
local abilityUpdateInterval = 1;
local barShown = {m = false, o = false};

local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\AddOns\\DHUD3\\textures\\Blood",
	[RUNETYPE_UNHOLY] = "Interface\\AddOns\\DHUD3\\textures\\Unholy",
	[RUNETYPE_FROST] = "Interface\\AddOns\\DHUD3\\textures\\Frost",
	[RUNETYPE_DEATH] = "Interface\\AddOns\\DHUD3\\textures\\Death",
}

local runeMapping = {
	[1] = "BLOOD",
	[2] = "UNHOLY",
	[3] = "FROST",
	[4] = "DEATH",
}

FIRE_TOTEM_SLOT = 1;
EARTH_TOTEM_SLOT = 2;
WATER_TOTEM_SLOT = 3;
AIR_TOTEM_SLOT = 4;

MAX_TOTEMS = 4;

TOTEM_PRIORITIES = {
	AIR_TOTEM_SLOT,
	WATER_TOTEM_SLOT,
	EARTH_TOTEM_SLOT,
	FIRE_TOTEM_SLOT
};
--Fonts
local maxfont = 25
local minfont = 6  

--Local Defaults
local db
local defaults = {
	profile = {
        side = "r";
		scale = 1;
		fontSize = 10;
		tips = true;
		druidCombos = true;
		druidLacerates = true;
		druidLaceratesTimer  = true;
		druidLifebloom  = true;
		druidLifebloomTimer  = true;
		rogueCombos = true;
		dkRunes = true;
		dkRunesTimer = true;
		runeDisplay = "rr";
		runeHideOnCD = false;
		warSunders = true;
		warSundersTimer = true;
		shaTotems = true;
		shaTotemsTimer = true;
		vehiCombos = true;
        colors = {
            full = { 1, 1, 1 },
            med = { 255/255, 125/255, 125/255 },
            low = { 255/255, 65/255, 0 }
        },
    }
}

local OptGetter, OptSetter, colorGetter, colorSetter, runeDisplay, SelectGetter, SelectSetter;
do
	local module = Abilities
	function OptGetter(info)
		local key = info[#info];
		return db[key];
	end

	function OptSetter(info, value)
		local key = info[#info];
		db[key] = value;
		module:Refresh();
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
        module:Refresh();
    end

	function selfDisabled(info)
		
		local _, class = UnitClass("player");
		if ( info[#info] ~= "VEHICLE" ) then
			--DHUD3:Debug("selfDisabled", info[#info-1], class, string.find(info[#info-1], class));
			if ( string.find(info[#info], class) ) then
				return not (DHUD3:GetModuleEnabled(MODNAME));
			else
				return true;
			end
		else
			return not (DHUD3:GetModuleEnabled(MODNAME));
		end
	end
	
	function timerDisabled(info)
		
		local i = string.find(info[#info], "Timer");
		if i then
			local master = string_sub(info[#info], 1, i - 1);
			return not db[master];
		else
			return false;
		end
	end
	
	runeDisplay = { ["rr"] = L["Round Robin"], ["bu"] = L["Bottom Up"], ["ha"] = L["Half'n'Away"], ["c"] = L["Centered"]}
	
end

--Local Options
local options
local function getOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["Abilities"],
			arg = MODNAME,
			get = OptGetter,
			set = OptSetter,
    		args = {
                enabled = {
                    type = "toggle",
                    order = 1,
                    name = L["Enable Abilities"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				general = {
					type = 'group',
					name = L["General"],
					order = 3,
					inline = true,
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						desc = {
							order = 0,
							type = "description",
							name = L["Configure general functionality"],
						},
						side = {
							type = 'select',
							order = 1,
							name = L["Abilities Side"],
							desc = L["This setting will only be available if the Auras Module is disabled"],
							values = {["r"] = L["Right"], ["l"] = L["Left"]},
							disabled = function() return DHUD3:GetModuleEnabled("Auras"); end,
						},
						tips = {
							type = 'toggle',
							order = 2,
							name = L["Show Abilities tips"],
						},
						fontSize = {
							type = 'range',
							order = 3,
							name = L["Font size"],
							min = 6,
							max = 25,
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
									name = L["Unavailable"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Half Time"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Ready"],
									order = 3,
								},
							},
						},
						scale = {
							type = "range",
							order = 6,
							name = L["Set Abilities' scale"],
							min = 0.5,
							max = 1,
							step = 0.05,
						},
					},
				},
				DRUID = {
					type = 'group',
					name = L["Druid"],
					inline = true,
					hidden = selfDisabled,
					args = {
						druidCombos = {
							type = 'toggle',
							order = 1,
							name = L["Combos"],
							desc = L["Track druid combo points"],
							hidden = false,
						},
						druidLacerates = {
							type = 'toggle',
							order = 2,
							name = L["Lacerates"],
							desc = L["Track druid lacerates"],
							hidden = false,
						},
						druidLaceratesTimer = {
							type = 'toggle',
							order = 3,
							name = L["Lacerates Timer"],
							desc = L["Track Druid lacerates expiration"],
							disabled = timerDisabled,
							hidden = false,
						},
						druidLifebloom = {
							type = 'toggle',
							order = 2,
							name = L["Lifebloom"],
							desc = L["Track druid lifebloom"],
							hidden = false,
						},
						druidLifebloomTimer = {
							type = 'toggle',
							order = 3,
							name = L["Lifebloom Timer"],
							desc = L["Track Druid lifebloom expiration"],
							disabled = timerDisabled,
							hidden = false,
						},
					},
				},
				ROGUE = {
					type = 'group',
					name = L["Rogue"],
					inline = true,
					hidden = selfDisabled,
					args = {
						rogueCombos = {
							type = 'toggle',
							order = 1,
							name = L["Combos"],
							desc = L["Track rogue combo points"],
							hidden = false,
						},
					},
				},
				SHAMAN = {
					type = 'group',
					name = L["Shaman"],
					inline = true,
					hidden = selfDisabled,
					args = {
						shaTotems = {
							type = 'toggle',
							order = 1,
							name = L["Shaman Totems"],
							desc = L["Track Shaman Totems"],
							hidden = false,
						},
						shaTotemsTimer = {
							type = 'toggle',
							order = 3,
							name = L["Totem Timer"],
							desc = L["Track Shaman totems expiration"],
							disabled = timerDisabled,
							hidden = false,
						},
					},
				},
				DEATHKNIGHT = {
					type = 'group',
					name = L["Death Knight"],
					inline = true,
					hidden = selfDisabled,
					args = {
						dkRunes = {
							type = 'toggle',
							order = 1,
							name = L["Death Knight Runes"],
							desc = L["Track Death Knight Runes"],
							hidden = false,
						},
						dkRunesTimer = {
							type = 'toggle',
							order = 2,
							name = L["Rune Timer"],
							desc = L["Track Death Knight runes cool down"],
							disabled = timerDisabled,
							hidden = false,
						},
						runeHideOnCD = {
							type = 'toggle',
							order = 3,
							name = L["Hide on Cool down"],
							desc = L["Hide runes that are on cool down."],
							disabled = timerDisabled,
							hidden = false,
						},
						runeDisplay = {
							type = 'select',
							order = 4,
							name = L["Rune Layout"],
							desc = L["Set how to display the runes. Round Robin places them in a single vertical row, runes rotate moving used ones to the top of the line. Bottom up places them at the lower side of the bars, grouped in pairs. Half'n'Away places them at the center of the bar, in vertical pairs positioned away from the bar. Centered places the runes in the center of the HUD, above the target's name plate (in this mode side setting for abilities won't have any difference)."],
							values = runeDisplay,
							hidden = false,
						},
					},
				},
				WARRIOR = {
					type = 'group',
					name = L["Warrior"],
					inline = true,
					hidden = selfDisabled,
					args = {
						warSunders = {
							type = 'toggle',
							order = 2,
							name = L["Sunder Armor"],
							desc = L["Track Warrior sunder armors"],
							hidden = false,
						},
						warSundersTimer = {
							type = 'toggle',
							order = 3,
							name = L["Sunder Armor Timer"],
							desc = L["Track Warrior sunder armors expiration"],
							disabled = timerDisabled,
							hidden = false,
						},
					},
				},
				VEHICLE = {
					type = 'group',
					name = L["Vehicle"],
					inline = true,
					hidden = selfDisabled,
					args = {
						vehiCombos = {
							type = 'toggle',
							order = 1,
							name = L["Combos"],
							desc = L["Track vehicle combo points"],
							hidden = false,
						},
						
					},
				},
			},
		}
	end
	return options;
end

local HideAbilities, UpdateCombos, UpdateTargetAuras, OnUpdateAura, OnUpdateRune, OnUpdateFlash
do
	function HideAbilities()
		
		--DHUD3:Debug("Abilities:HideAbilities");
		for i = 1, 6 do
			_G["DHUD3_"..db.side.."b"..i]:Hide();
			_G["DHUD3_"..db.side.."b"..i.."_Text"]:Hide();
			_G["DHUD3_"..db.side.."b"..i]:SetScript("OnUpdate", nil);
		end
	end

	function UpdateCombos(who)
		
		--DHUD3:Debug("Abilities:UpdateCombos")
		local points = GetComboPoints(who, "target");
		for i = 1, 5 do
	        if i <= points then
				_G["DHUD3_"..db.side.."b"..i.."_Back"]:SetTexture("Interface\\AddOns\\DHUD3\\textures\\c"..i);
				_G["DHUD3_"..db.side.."b"..i.."_Border"]:SetVertexColor(1, 1, 1);
	            _G["DHUD3_"..db.side.."b"..i]:Show()
	        else
	            _G["DHUD3_"..db.side.."b"..i]:Hide()
	        end
		end
	end

	-- Update target auras
    function UpdateTargetAuras(filter, spell, trackTime)

		local name, texture, duration, expirationTime, caster, last;
		local r, g, b, hex, button, timeLeft;
		for i = 1, 40 do
			name, _, texture, count, _, duration, expirationTime, caster = UnitAura("target", i, filter);
			if ( name == spell and caster == "player") then
				for j = 1, 6 do
					if ( j <= count ) then
						button = _G["DHUD3_"..db.side.."b"..j];
						timeLeft = expirationTime - GetTime();
						if (timeLeft >= button.duration) then
							r, g, b, hex = DHUD3:Colorize(db.colors, 1);
							button.duration = timeLeft;
						else
							r, g, b, hex = DHUD3:Colorize(db.colors, timeLeft/button.duration);
						end
						button.hasAura = true;
						button.id = i;
						button.filter = filter;
						button.auraTimer = 0;
						button.left = timeLeft;
						button.last = false;
						_G["DHUD3_"..db.side.."b"..j.."_Back"]:SetTexture(texture);
						buffBorder = _G["DHUD3_"..db.side.."b"..j.."_Border"];
						buffBorder:SetVertexColor(r, g, b);
						buffBorder:Show();
						_G["DHUD3_"..db.side.."b"..j.."_Text"]:Hide();
						button:SetScript("OnUpdate", OnUpdateAura);
						if ( db.tips ) then
							button:SetScript("OnEnter", function(this)
					                if not this:IsVisible() or ( this:GetEffectiveAlpha() == 0 ) then
					                    return;
					                end
					                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
					                GameTooltip:SetUnitAura("target", this.id, this.filter);
					            end )
					        button:SetScript("OnLeave", function()
					                GameTooltip:Hide();
					            end )
						end
						button:Show();
					else
						_G["DHUD3_"..db.side.."b"..j]:Hide();
						--DHUD3:Debug("UpdateTargetAuras hide", j);
						_G["DHUD3_"..db.side.."b"..j].duration = 0;
					end
				end
				button = _G["DHUD3_"..db.side.."b"..count];
				button.last = true;
				if ( trackTime ) then
					button.trackTime = true;
					local buffText = _G["DHUD3_"..db.side.."b"..count.."_Text"];
					buffText:SetText("|cff"..hex..DHUD3:FormatTime(button.left));
					local w = buffText:GetStringWidth() + 10;
					buffText:SetWidth(w);
					buffText:Show();
				end
				break;
			end
		end
    end

	-- On update event for abilities
	function OnUpdateAura(event, elapsed)
	    this.auraTimer = this.auraTimer + elapsed
		if this.auraTimer >= abilityUpdateInterval then
			local timeLeft = 0;
			this.left = this.left - this.auraTimer;
			if this.left <= 0 then
				--DHUD3:Debug("OnUpdateAura hide", this:GetName());
				this.id = 0
				this.hasAura = false
				this:SetScript("OnUpdate", nil)
				return this:Hide()
			end
			this.auraTimer = 0
			local r, g, b, hex = DHUD3:Colorize(db.colors, this.left / this.duration);
			local buffBorder = _G[this:GetName().."_Border"];
			buffBorder:SetVertexColor(r, g, b);
			if ( this.last and this.trackTime) then
				local buffText = _G[this:GetName().."_Text"];
				buffText:SetText("|cff"..hex..DHUD3:FormatTime(this.left));
				local w = buffText:GetStringWidth() + 10;
				buffText:SetWidth(w);
			end
			if ( GameTooltip:IsOwned(this) ) then
				GameTooltip:SetUnitAura("target", this.id, this.filter);
			end
		end
	end

	function OnUpdateRune(event, elapsed)
		if this.flash then
			local fadeAlpha = _G[this:GetName().."_Flash"]:GetAlpha() + this.alphaStep;
			--DHUD3:Debug("Flash", fadeAlpha);
			if fadeAlpha > 1 then
			 this.alphaStep = -0.1;
	        elseif fadeAlpha > 0 then
	            _G[this:GetName().."_Flash"]:SetAlpha(fadeAlpha);
	        else
	            this.flash = false
				if this.ready then
					this:SetScript("OnUpdate", nil);
				end
				_G[this:GetName().."_Flash"]:Hide();
	        end
		end
		if ( this.ready ) then
			--DHUD3:Debug("Rune ready");
			local r, g, b = DHUD3:Colorize(db.colors, 0);
			_G[this:GetName().."_Border"]:SetVertexColor(r, g, b);
			_G[this:GetName().."_Text"]:Hide();
			if not this.flash then
				--Flash
				this.flash = true;
				this.alphaStep = 0.1;
				_G[this:GetName().."_Flash"]:SetAlpha(0);
		        _G[this:GetName().."_Flash"]:Show();
		       _G[this:GetName().."_Flash"].fadeAlpha = 0;
			end
		else
			this.auraTimer = this.auraTimer + elapsed
			if this.auraTimer >= abilityUpdateInterval then
				local timeLeft = 0;
				this.left = this.left - this.auraTimer
				if this.left <= 0 then
					this.ready = true;
				else
					this.auraTimer = 0
					local r, g, b, hex = DHUD3:Colorize(db.colors, this.left / this.duration);
					local buffBorder = _G[this:GetName().."_Border"];
					buffBorder:SetVertexColor(r, g, b);
					if ( db.dkRunesTimer ) then
						local buffText = _G[this:GetName().."_Text"];
						buffText:SetText("|cff"..hex..DHUD3:FormatTime(this.left));
						buffText:Show();
						local w = buffText:GetStringWidth() + 10;
						buffText:SetWidth(w);
					end
					if ( GameTooltip:IsOwned(this) ) then
						GameTooltip:SetUnitAura("target", this.id, this.filter);
					end
				end
		    end
		end
	end

	function OnUpdateTotem(event, elapsed)
	
	    this.totemTimer = this.totemTimer + elapsed;
		if this.totemTimer >= abilityUpdateInterval then
			--DHUD2:Debug("OnUpdateTotem")
			this.left = this.left - this.totemTimer;
			if this.left > 0 then
				this.totemTimer = 0;
				local timeLeft = GetTotemTimeLeft(this.slot);
				local r, g, b, hex = DHUD3:Colorize(db.colors, this.left / 20);
				_G[this:GetName().."_Border"]:SetVertexColor(r, g, b);
				_G[this:GetName().."_Text"]:SetText("|cff"..hex..DHUD3:FormatTime(this.left));
			else
				this:SetScript("OnUpdate", nil);
			end
			if ( GameTooltip:IsOwned(this) ) then
				GameTooltip:SetTotem(this.slot);
			end
		end
	end
	
end

function Abilities:OnInitialize()

    self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, getOptions, L["Abilities"]);

	local buttons = DHUD3.layout.buttons;
	-- Buttons for Combos/Totems/Sunders/Lacerates
    for k = 1, 6 do
        -- Left
		ref = CreateFrame("Button", "DHUD3_lb"..k, _G["DHUD3_leftAbility"]);
        ref:ClearAllPoints();
        ref:SetPoint("BOTTOM", _G["DHUD3_leftAbility"], "BOTTOM", 0, 0);
        ref:SetHeight(26);
        ref:SetWidth(26);
		bgt = ref:CreateTexture("DHUD3_lb"..k.."_Back", "BORDER");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\icon");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26);
        bgt:SetWidth(26);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_lb"..k.."_Border", "ARTWORK");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\serenity0");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.6);
        bgt:SetWidth(26*1.6);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_lb"..k.."_Flash", "OVERLAY");
		bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\runeFlash");
		bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.6);
        bgt:SetWidth(26*1.6);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("ADD");
		bgt:Hide();
        font = ref:CreateFontString("DHUD3_lb"..k.."_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint("CENTER", ref, "CENTER", 0, 0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(26*2);
		ref.duration = 0;
        ref:Hide();

		-- Right
		ref = CreateFrame("Button", "DHUD3_rb"..k, _G["DHUD3_rightAbility"]);
        ref:ClearAllPoints();
        ref:SetPoint("BOTTOM", _G["DHUD3_rightAbility"], "BOTTOM", 0, 0);
        ref:SetHeight(26);
        ref:SetWidth(26);
		bgt = ref:CreateTexture("DHUD3_rb"..k.."_Back", "BORDER");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\icon");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26);
        bgt:SetWidth(26);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_rb"..k.."_Border", "ARTWORK");
        bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\serenity0");
        bgt:SetVertexColor(1, 1, 1);
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.5);
        bgt:SetWidth(26*1.5);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("BLEND");
		bgt = ref:CreateTexture("DHUD3_rb"..k.."_Flash", "OVERLAY");
		bgt:SetTexture("Interface\\AddOns\\DHUD3\\textures\\runeFlash");
		bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(26*1.6);
        bgt:SetWidth(26*1.6);
        bgt:SetTexCoord(0, 1, 0, 1);
        bgt:SetBlendMode("ADD");
		bgt:Hide();
        font = ref:CreateFontString("DHUD3_rb"..k.."_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint("CENTER", ref, "CENTER", 0, 0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(26*2);
		ref.duration = 0;
        ref:Hide();
    end
end

function Abilities:OnEnable()

	--DHUD3:Debug("Abilities:OnEnable");
	self:Refresh();
	if not self:IsEnabled() then return; end

	--Listen for changes in the Auras configiration to change abilities side
	self:RegisterMessage("DHUD3_AURAS_REFRESH");
end

function Abilities:OnDisable()
	
	self:UnregisterAllEvents();
	self:UnregisterAllMessages();
	HideAbilities();
end

function Abilities:Refresh()

	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile;
	HideAbilities();
	if not self:IsEnabled() then return; end
	--DHUD3:Debug("Abilities:Refresh", abiliSideBlocked, db.side, side);
	DHUD3_leftAbility:SetScale(db.scale);
	DHUD3_rightAbility:SetScale(db.scale);
	
	--ASK IF OTHER BARS ARE SHOWED!
	abiliPosition = "i";
	local hide, parent, xDev;
	if ( db.side == "l" ) then
		parent = _G["DHUD3_leftAbility"];
		hide = "r";
		xDev = - ( 151 / db.scale) - 13 * db.scale;
	else
		parent = _G["DHUD3_rightAbility"];
		hide = "l";
		xDev = ( 151 / db.scale) + 13 * db.scale;
	end
	local x, y, yPos, step;
	local xCol = 0;
	local _, class = UnitClass("player");
	if ( class ~= "DEATHKNIGHT" ) then
		-- Listen to bar pops
		self:RegisterMessage("DHUD3_BAR_SHOW");
		self:RegisterMessage("DHUD3_BAR_HIDE");
		for i = 1, 6 do
			-- Show
			local name = "DHUD3_"..db.side.."b"..i;
			local button = _G[name];
			button:ClearAllPoints();
			step = ( 256 * db.scale)/8;
			y = (step * (i - 0.5));
			yPos = (32 * ( i - 0.5)) - 15;
			if ( db.side == "l" ) then
				x = (-17.899 - 0.351*y + 0.00137*y^2)/db.scale;
			else
				x = (17.899 + 0.351*y - 0.00137*y^2)/db.scale;
			end
	        button:SetPoint("BOTTOM", parent, "BOTTOM", x + xDev + xCol, yPos);
			button:SetScript("OnUpdate", nil);
			button:EnableMouse(db.tips);
			button:Hide();
			font = _G[name.."_Text"]
	        font:SetFont(DHUD3:GetFont(), db.fontSize);
	        local w = font:GetStringWidth() * 1.1;
	        font:SetWidth(w);

			--Hide
			local name = "DHUD3_"..hide.."b"..i;
			button = _G[name];
			button:SetScript("OnUpdate", nil);
			button:SetScript("OnEnter", nil);
			button:Hide();
	        font = _G[name.."_Text"];
	        font:SetFont(DHUD3:GetFont(), db.fontSize * db.scale)
	        w = font:GetStringWidth() * 1.1
	        font:SetWidth(w);
		end
		if ( class == "DRUID" ) then
			self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			if ( db.druidCombos ) then
				self:RegisterEvent("UNIT_COMBO_POINTS");
				self:PLAYER_TARGET_CHANGED();
			else
				self:UnregisterEvent("UNIT_COMBO_POINTS");
			end
			if ( db.druidLacerates ) then
				self:RegisterEvent("UNIT_AURA");
				self:PLAYER_TARGET_CHANGED();
			else
				self:UnregisterEvent("UNIT_AURA");
			end
			if ( db.druidLifebloom ) then
				self:RegisterEvent("UNIT_AURA");
				self:PLAYER_TARGET_CHANGED();
			else
				self:UnregisterEvent("UNIT_AURA");
			end
		elseif (class == "ROGUE") then
			if ( db.rogueCombos ) then
				self:RegisterEvent("UNIT_COMBO_POINTS");
				self:PLAYER_TARGET_CHANGED();
			else
				self:UnregisterEvent("UNIT_COMBO_POINTS");
			end
		elseif ( class == "WARRIOR" ) then
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			if ( db.warSunders ) then
				self:RegisterEvent("UNIT_AURA");
				self:PLAYER_TARGET_CHANGED();
			else
				self:UnregisterEvent("UNIT_AURA");
			end
		elseif ( class == "SHAMAN" ) then
			if ( db.shaTotems ) then
				self:RegisterEvent("PLAYER_TOTEM_UPDATE");
				-- Totems
				for i = 1, 4 do
					_G["DHUD3_"..db.side.."b"..i]:RegisterForClicks('LeftButtonUp');
					_G["DHUD3_"..db.side.."b"..i]:SetHeight(20);
				end
				self:PLAYER_TOTEM_UPDATE();
			else
				self:UnregisterEvent("PLAYER_TOTEM_UPDATE");
				for i = 1, 4 do
					_G["DHUD3_"..db.side.."b"..i]:RegisterForClicks();
				end
			end	
			
		end
	else	-- if ( class == "DEATHKNIGHT" ) then
		if ( db.dkRunes ) then
			local runeType, name, button, runeReady;
			for i = 1, 6 do
				-- Show
				--["rr"] = L["Round Robin"], ["bu"] = L["Bottom Up"], ["ha"] = L["Half'n'Away"], ["c"], L["Centered"]}
				local name = "DHUD3_"..db.side.."b"..i;
				local button = _G[name];
				button:ClearAllPoints();
				step = ( 256 * db.scale)/8;
				if ( db.runeDisplay == "rr" ) then
					if (i < 9 ) then
						y = (step * (i - 0.5));
						yPos = (32 * ( i - 0.5)) - 15;
					else
						y = (step * (i - 8.5));
						xCol = (db.side == "l") and -35 or 35;
						yPos = (32 * ( i - 8.5)) - 15;
					end
					if ( db.side == "l" ) then
						x = (-17.899 - 0.351*y + 0.00137*y^2)/db.scale;
					else
						x = (17.899 + 0.351*y - 0.00137*y^2)/db.scale;
					end
				elseif ( db.runeDisplay == "ha" ) then
					if ( i%2 == 0 ) then
						--y = ( step * 4.5 ) - 15;
						yPos = (113/db.scale) + 16;
						xCol = ( (i/2) - 1 ) * ( (db.side == "l") and -35 or 35 );
					else
						--y = (step * 3.5 ) - 15;
						yPos = (113/db.scale) - 16;
						xCol = math.floor(i/2) * ( (db.side == "l") and -35 or 35 );
					end
					if ( db.side == "l" ) then
						x = -38/db.scale;
					else
						x = 38/db.scale;
					end
				elseif ( db.runeDisplay == "bu" ) then
					if ( i%2 ~= 0 ) then
						y = (step * ( math.ceil(i/2) - 0.5 ) );
						yPos = (32 * ( math.ceil(i/2) - 0.5 ) ) - 15;
						xCol = 0;
					else
						y = (step * ( (i/2) - 0.5) );
						xCol = (db.side == "l") and -35 or 35;
						yPos = (32 * ( (i/2) - 0.5 ) ) - 15;
					end
					if ( db.side == "l" ) then
						x = (-17.899 - 0.351*y + 0.00137*y^2)/db.scale;
					else
						x = (17.899 + 0.351*y - 0.00137*y^2)/db.scale;
					end
				elseif ( db.runeDisplay == "c" ) then
					xDev = 0;
					yPos = 45/db.scale;
					parent = "DHUD3_mainFrame";
					if ( db.side == "l" ) then
						xCol = (33 * (i-1));
						x = -82;
					else
						xCol = (-33 * (i-1));
						x = 82;
					end
				end
				button:SetPoint("BOTTOM", parent, "BOTTOM", x + xDev + xCol, yPos);
				button:SetScript("OnUpdate", nil);
				font = _G[name.."_Text"]
				font:SetFont(DHUD3:GetFont(), db.fontSize);
				local w = font:GetStringWidth() * 1.1;
				font:SetWidth(w);
				runeType = GetRuneType(i);
				_, _, runeReady = GetRuneCooldown(i);
				name = "DHUD3_"..db.side.."b"..i;
				button.rune = i;
				button.runeType = runeType;
				button.ready = runeReady;
				_G[name.."_Back"]:SetTexture(runeTextures[runeType]);
				local r, g, b = DHUD3:Colorize(db.colors, 0);
				_G[name.."_Border"]:SetVertexColor(r, g, b);
				--DHUD3:Debug("Abilities Show", button:GetName());
				button:SetAlpha(1);
				button:Show();
				
				--Hide
				local name = "DHUD3_"..hide.."b"..i;
				button = _G[name];
				button:SetScript("OnUpdate", nil);
				button:SetScript("OnEnter", nil);
				button:Hide();
				font = _G[name.."_Text"];
				font:SetFont(DHUD3:GetFont(), db.fontSize * db.scale)
				w = font:GetStringWidth() * 1.1
				font:SetWidth(w);
			end
			if ( db.runeDisplay == "rr" ) then
				self:RegisterEvent("RUNE_POWER_UPDATE", self.RunePowerRR);
				self:RegisterEvent("RUNE_TYPE_UPDATE", self.RuneTypeRR);
			else
				self:RegisterEvent("RUNE_POWER_UPDATE");
				self:RegisterEvent("RUNE_TYPE_UPDATE");
			end
			if ( db.runeDisplay ~= "c" ) then
				-- Listen to bar pops
				self:RegisterMessage("DHUD3_BAR_SHOW");
				self:RegisterMessage("DHUD3_BAR_HIDE");
			end
		end
	end
	if ( db.vehiCombos ) then
		self:RegisterEvent("UNIT_COMBO_POINTS");
		if ( UnitInVehicle("player") ) then
			self:PLAYER_TARGET_CHANGED();
		end
	elseif ( not db.rogueCombos ) then
		self:UnregisterEvent("UNIT_COMBO_POINTS");
	end
end

function Abilities:UNIT_COMBO_POINTS(event, who)
	
	--DHUD3:Debug("Abilities UNIT_COMBO_POINTS");
	local _, class = UnitClass("player");
	if ( who == "player" and ( class == "ROGUE" ) and db.rogueCombos) then
		UpdateCombos("player");
	elseif ( who == "player" and ( class == "DRUID" ) and db.druidCombos) then
		UpdateCombos("player");
	elseif ( who == "vehicle" and db.vehiCombos and UnitInVehicle("player") ) then
		UpdateCombos("vehicle");
	end
end

function Abilities:UPDATE_SHAPESHIFT_FORM(event, who)
	
	--DHUD3:Debug("Abilities UPDATE_SHAPESHIFT_FORM");
	local powerType = UnitPowerType("player");
	HideAbilities();
	if ( db.druidLifebloom and ( powerType == 0 ) ) then
		-- Is Druid
		UpdateTargetAuras("HELPFUL", "Lifebloom", db.druidLifebloomTimer);
	elseif ( db.druidLacerates and ( powerType == 1 ) ) then
		-- Is Bear
		UpdateTargetAuras("HARMFUL", "Lacerate", db.druidLacerates);
	elseif ( db.druidCombos and ( powerType == 3) ) then
		-- Is Cat
		UpdateCombos("player");
	end
end

function Abilities:PLAYER_TARGET_CHANGED(event)
	
	--DHUD3:Debug("Abiities PLAYER_TARGET_CHANGED");
	HideAbilities();
	if ( UnitExists("target") ) then
		local _, class = UnitClass("player");
		if ( class == "DRUID" ) then
			self:UPDATE_SHAPESHIFT_FORM();
		elseif ( class == "WARRIOR" ) then
			if ( db.warSunders ) then
				UpdateTargetAuras("HARMFUL", "Sunder Armor", db.warSundersTimer);
			end
		elseif ( ( class == "ROGUE" and db.rogueCombos ) or ( UnitInVehicle("player") and db.vehiCombos ) ) then
			UpdateCombos("player");
		end
	end
end

function Abilities:UNIT_AURA(event, who)

	--DHUD3:Debug("Abiities UNIT_AURA");
    if ( who == "target" ) then
		local _, class = UnitClass("player");
		if ( class == "DRUID" ) then
			local powerType, typeName = UnitPowerType("player");
			if ( db.druidLifebloom and ( powerType == 0 ) ) then
				-- Is Druid
				UpdateTargetAuras("HELPFUL", "Lifebloom", db.druidLifebloomTimer);
			elseif ( db.druidLacerates and ( powerType == 1 ) ) then
				-- Is Bear
				UpdateTargetAuras("HARMFUL", "Lacerate", db.druidLaceratesTimer);
		    end
		elseif ( class == "WARRIOR" ) then
			if ( db.warSunders ) then
				UpdateTargetAuras("HARMFUL", "Sunder Armor", db.warSundersTimer);
			end
		end
    end
end

function Abilities:RunePowerRR(...)

	-- The rune is usable or unusable
	--DHUD3:Debug("Abiities RunePowerRR");
	local rune, usable = ...;
	--DHUD3:Debug("Abilities", rune, usable);
	local j;
	if ( not usable ) then
		--DHUD3:Debug("Move rune", rune);
		local k = 1;
		-- Search for the ready rune
		while _G["DHUD3_"..db.side.."b"..k].rune ~= rune do
			k = k + 1;
		end
		for i = k, 5 do
			origin = "DHUD3_"..db.side.."b"..(i+1);
			dest = "DHUD3_"..db.side.."b"..(i);
			_G[dest].runeType = _G[origin].runeType;
			_G[dest].ready = _G[origin].ready;
			_G[dest].rune = _G[origin].rune;
			_G[dest.."_Back"]:SetTexture(runeTextures[_G[origin].runeType]);
			if ( not _G[dest].ready ) then
				_G[dest].left = _G[origin].left;
				_G[dest].duration = _G[origin].duration;
				_G[dest].auraTimer = abilityUpdateInterval;
				_G[dest]:SetScript("OnUpdate", OnUpdateRune);
			end
		end
		local button = _G["DHUD3_"..db.side.."b6"];
		button.rune = rune;
		button.runeType = GetRuneType(rune);
		button.ready = false;
		_G["DHUD3_"..db.side.."b6".."_Back"]:SetTexture(runeTextures[button.runeType]);
		local _, duration = GetRuneCooldown(rune);
		button.left = duration;
		button.duration = duration;
		button.auraTimer = 0;
		button.flash = false;
		local r, g, b, hex = DHUD3:Colorize(db.colors, 1);
		buffBorder = _G["DHUD3_"..db.side.."b6_Border"];
		buffBorder:SetVertexColor(r, g, b);
		if ( db.dkRunesTimer ) then
			local buffText = _G["DHUD3_"..db.side.."b6_Text"];
			buffText:SetText("|cff"..hex..DHUD3:FormatTime(button.left));
			local w = buffText:GetStringWidth() + 10;
			buffText:SetWidth(w);
			buffText:Show();
		end
		button:SetScript("OnUpdate", OnUpdateRune);
	else
		for i = 1, 6 do
			if _G["DHUD3_"..db.side.."b"..(i)].rune == rune then
				_G["DHUD3_"..db.side.."b"..(i)].ready = true;
				break;
			end
		end
	end
end

function Abilities:RuneTypeRR(...)
	
	-- Rune type changed
	local rune = ...;
	--DHUD3:Debug("Abilities RuneTypeRR");
	for i = 1, 6 do
		runeType = GetRuneType(rune);
		if _G["DHUD3_"..db.side.."b"..i].rune == rune and _G["DHUD3_"..db.side.."b"..i].runeType ~= runeType then
			--DHUD3:Debug("RuneTypeRR", rune, i);
			_G["DHUD3_"..db.side.."b"..i.."_Back"]:SetTexture(runeTextures[runeType]);
			_G["DHUD3_"..db.side.."b"..i].runeType = runeType;
			--Flash
			_G["DHUD3_"..db.side.."b"..i].flash = true;
			_G["DHUD3_"..db.side.."b"..i].alphaStep = 0.1;
			local flash = _G["DHUD3_"..db.side.."b"..i.."_Flash"];
			flash:SetAlpha(0);
			flash:Show();
			flash.fadeAlpha = 0;
			_G["DHUD3_"..db.side.."b"..i]:SetScript("OnUpdate", OnUpdateRune);
			break;
		end
	end
	
end

function Abilities:RUNE_POWER_UPDATE(event, ...)
	
	-- The rune is usable or unusable
	--DHUD3:Debug("Abilities RUNE_POWER_UPDATE");
	local rune, usable = ...;
	local j;
	if ( not usable ) then
		--DHUD3:Debug("Move rune", rune, GetRuneType(rune));
		local k = 1;
		-- Search for the ready rune
		while _G["DHUD3_"..db.side.."b"..k].rune ~= rune do
			k = k + 1;
		end
		local button = _G["DHUD3_"..db.side.."b"..k];
		button.rune = rune;
		button.runeType = GetRuneType(rune);
		if ( db.runeHideOnCD ) then
			button:Hide();
		else
			_G["DHUD3_"..db.side.."b"..k.."_Back"]:SetTexture(runeTextures[button.runeType]);
			button.ready = false;
			local _, duration = GetRuneCooldown(rune)
			button.left = duration;
			button.duration = duration;
			button.auraTimer = 0;
			button.flash = false;
			local r, g, b, hex = DHUD3:Colorize(db.colors, 1);
			buffBorder = _G["DHUD3_"..db.side.."b"..k.."_Border"];
			buffBorder:SetVertexColor(r, g, b);
			local buffText = _G["DHUD3_"..db.side.."b"..k.."_Text"];
			buffText:SetText("|cff"..hex..DHUD3:FormatTime(button.left));
			local w = buffText:GetStringWidth() + 10;
			buffText:SetWidth(w);
			buffText:Show();
			button:SetScript("OnUpdate", OnUpdateRune);
		end
			
	else
		for i = 1, 6 do
			if _G["DHUD3_"..db.side.."b"..(i)].rune == rune then
				_G["DHUD3_"..db.side.."b"..(i)].ready = true;
				if ( db.runeHideOnCD ) then
					_G["DHUD3_"..db.side.."b"..(i)]:Show();
				end
				break;
			end
		end
	end

end

function Abilities:RUNE_TYPE_UPDATE(event, ...)
	
	-- Rune type changed
	--DHUD3:Debug("Abilities RUNE_TYPE_UPDATE");
	local rune = ...;
	runeType = GetRuneType(rune);
	_G["DHUD3_"..db.side.."b"..rune.."_Back"]:SetTexture(runeTextures[runeType]);
	if runeType == 4 then
		--Flash
		_G["DHUD3_"..db.side.."b"..rune].flash = true;
		_G["DHUD3_"..db.side.."b"..rune].alphaStep = 0.1;
		local flash = _G["DHUD3_"..db.side.."b"..rune.."_Flash"];
		flash:SetAlpha(0);
		flash:Show();
		flash.fadeAlpha = 0;
		_G["DHUD3_"..db.side.."b"..rune]:SetScript("OnUpdate", OnUpdateRune);
	end
end

function Abilities:DHUD3_BAR_SHOW(event, bar)
	
	--DHUD3:Debug("Abilities DHUD3_BAR_SHOW");
	local barSide = string_sub(bar, 1, 1);
	local position = string_sub(bar, 2);
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
			for i = 1, 6 do
				button = _G["DHUD3_rb"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
				button:SetPoint(point, relativeTo, relativePoint, xOfs + xDis, yOfs);
				button = _G["DHUD3_lb"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
				button:SetPoint(point, relativeTo, relativePoint, xOfs - xDis, yOfs);
			end
			--DHUD3:Debug("move", xDis);
		end
	end
end

function Abilities:DHUD3_BAR_HIDE(event, bar)

	local barSide = string_sub(bar, 1, 1);
	local position = string_sub(bar, 2);
	--DHUD3:Debug("Abilities, bar, position, barShown", event, bar, position, barShown.m, barShown.o);
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
			for i = 1, 6 do
				button = _G["DHUD3_rb"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs + xDis, yOfs);
				button = _G["DHUD3_lb"..i];
				point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1);
				button:ClearAllPoints();
		        button:SetPoint(point, relativeTo, relativePoint, xOfs - xDis, yOfs);
			end
			--DHUD3:Debug("move", xDis);
		end
	end
end	

function Abilities:DHUD3_AURAS_REFRESH(event, enabled, aurasSide)
	
	--DHUD3:Debug("DHUD3_AURAS_REFRESH", event, enabled, aurasSide);
	if ( enabled ) then
		if ( aurasSide == "l" ) then
			db.side = "r";
		else
			db.side = "l";
		end
	end
	self:Refresh();
end

function Abilities:PLAYER_TOTEM_UPDATE(event)

	-- Thanks to bliss totem frames
    --DHUD3:Debug("PLAYER_TOTEM_UPDATE");
    local haveTotem, name, icon, slot, button, r, g, b, hex, left, startTime, duration;
	local buttonIndex = 1;
	for i=1, MAX_TOTEMS do
		slot = TOTEM_PRIORITIES[i];
		haveTotem, name, startTime, duration, texture = GetTotemInfo(slot);
		if haveTotem then
			button = _G["DHUD3_"..db.side.."b"..buttonIndex];
			button.slot = slot;
            button.totemTimer = 0;
			left = duration - (GetTime() - startTime);
			if left > 0 then
				_G["DHUD3_"..db.side.."b"..buttonIndex.."_Back"]:SetTexture(texture);
				if db.shaTotemsTimer then
					r, g, b, hex = DHUD3:Colorize(db.colors, left / 20);
			        _G["DHUD3_"..db.side.."b"..buttonIndex.."_Border"]:SetVertexColor(r, g, b)
			        _G["DHUD3_"..db.side.."b"..buttonIndex.."_Border"]:Show()
			        _G["DHUD3_"..db.side.."b"..buttonIndex.."_Text"]:SetText("|cff"..hex..DHUD3:FormatTime(left))
			        _G["DHUD3_"..db.side.."b"..buttonIndex.."_Text"]:Show()
					button.duration = duration;
					button.left = left;
			        button:SetScript("OnUpdate", OnUpdateTotem);
					if ( db.tips ) then
						button:SetScript("OnEnter", function(this)
								if not this:IsVisible() or ( this:GetEffectiveAlpha() == 0 ) then
									return;
								end
								GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
								GameTooltip:SetTotem(this.slot);
							end )
						button:SetScript("OnLeave", function()
								GameTooltip:Hide();
							end )
					end
				else
					button.duration = 0;
					button.left = 0;
					butText:Hide()
				end
		        button:Show()
			else
				button:SetScript("OnUpdate", nil)
				button:Hide()
			end
			buttonIndex = buttonIndex + 1;
		else
			_G["DHUD3_"..db.side.."b"..(MAX_TOTEMS - i + buttonIndex)].slot = 0;
			_G["DHUD3_"..db.side.."b"..(MAX_TOTEMS - i + buttonIndex)]:Hide();
		end
	end
end
