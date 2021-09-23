--[[
DHUD3
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
--Addon Mix
--@non-debug@ 
DHUD3 = LibStub("AceAddon-3.0"):NewAddon("DHUD3", "AceEvent-3.0", "AceConsole-3.0");
--@end-non-debug@
--[===[@debug@
DHUD3 = LibStub("AceAddon-3.0"):NewAddon("DHUD3", "AceEvent-3.0", "AceConsole-3.0", "LibDebugLog-1.0");
--@end-debug@]===]


--ACE Version
local VERSION = tonumber(("$Rev: 151 $"):match("%d+"));
DHUD3.revision = "r" .. VERSION;
DHUD3.versionstring = "0.3";
DHUD3.version = DHUD3.versionstring:format(VERSION);
DHUD3.date = ("$Date: 2009-09-04 23:56:32 +0000 (Fri, 04 Sep 2009) $"):match("%d%d%d%d%-%d%d%-%d%d");
local L = LibStub("AceLocale-3.0"):GetLocale("DHUD3");
local LSM3 = LibStub("LibSharedMedia-3.0");

local unpack = unpack;
local pairs = pairs;
local type = type;
local _G = _G;
local string_format = string.format;
local string_len = string.len;
local string_find = string.find;
local string_sub = string.sub;

local isSetup = false;
local currentAlphaValue = { false, false, false, false, false };
local regenAlphaVotes = {false, false};

local OptGetter, OptSetter;
do
	--[[
	        OptGetter: Get the current option setting in the DB
	        arguments:
	            info: option to query
	        returns:
	            option setting in DB
	]]--
	function OptGetter(info)
		local key = info[#info];
		return DHUD3.db.profile[key];
	end
	
	--[[
		OptSetter: Set the option new value in the DB. The HUD is refreshed agter the setting is done
		arguments:
			info: option to cahgne value
			value: New value
	]]--
	function OptSetter(info, value)
		local key = info[#info];
		DHUD3.db.profile[key] = value;
		DHUD3:Refresh();
	end
end

--Local Defaults
local db;
local defaults = {
	profile = {
        blizCasting = false,
		blizPet = false,
		deadAlpha = 0,
        combatAlpha = 1,
		castAlpha = 0.8,
        selectAlpha = 0.6,
        regenAlpha = 0.4,
        oocAlpha = 0.1,
		useBorders = true,
		showEmpty = true,
		miniMap = true,
		minimapPos = 200,
		frameSpacing = 0,
		font = "Arial Narrow",
		scale = 1,
        modules = {
			['*'] = true,
		},
		barTextPos = {
			["*"] = { moved = false },
		},
    }
};

--Local Options
local options, moduleOptions = nil, {}
local function GetOptions()
	if not options then
        --Options table
    	options = {
    		type = 'group',
            name = 'DHUD3',
            order = 1,
    		args = {
                layout = {
                    type = 'group',
                    name = L["General Options"],
    				order = 1,
                    get = OptGetter,
                    set = OptSetter,
                    args = {
                        scale = {
                            order = 1,
                            type = 'range',
                            name = L["Set DHUD3's scale"],
                            min = 0.2,
                            max = 2,
                            step = 0.1,
                        },
						miniMap = {
							order = 2,
							type = 'toggle',
							name = L["Show Minimap Button"],
						},
                        frameSpacing = {
                            order = 3,
                            type = 'range',
                            name = L["Center Spacing"],
                            min = 0,
                            max = 500,
                            step = 10,
                        },
                        gral = {
                            type = 'group',
                            name = L["General"],
                            inline = true,
                            order = 3,
                            args = {
                                desc = {
            						order = 1,
                                    type = "description",
            						name = L["Configure bar's border functionality"],
                                },
                                useBorders = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Show Bar Borders"],
                                    desc = L["Show/hide borders"],
                                },
                                showEmpty = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Show Bars when empty"],
                                    desc = L["Show/hide empty (0 value) bars"],
                                    disabled = function()
                                            return not db.useBorders
                                        end,
                                },
								font = {
									order = 4,
							        type = 'select',
							        dialogControl = 'LSM30_Font',
							        name = L["Bar font"],
							        desc = L["The font used by all Modules."],
							        values = AceGUIWidgetLSMlists.font,
							    },
                            },
                        },
                        alphas = {
                            order = 4,
                            type = "group",
                            name = L["Alphas"],
                            inline = true,
                            args = {
                                desc = {
            						order = 1,
                                    type = "description",
            						name = L["Set the HUD's situation alpha. The order shown is the precedence order, i.e. Combat alpha will override Selection alpha."],
                                },
                                deadAlpha = {
                                    order = 2,
                                    type = "range",
                                    name = L["Death"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                                combatAlpha = {
                                    order = 3,
                                    type = "range",
                                    name = L["Combat"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                                castAlpha = {
                                    order = 4,
                                    type = "range",
                                    name = L["Casting"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                                selectAlpha = {
                                    order = 5,
                                    type = "range",
                                    name = L["Selection"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                                regenAlpha = {
                                    order = 6,
                                    type = "range",
                                    name = L["Regeneration"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                                oocAlpha = {
                                    order = 7,
                                    type = "range",
                                    name = L["Off Combat"],
                                    min = 0,
                                    max = 1,
                                    step = 0.05,
                                },
                            },
                        },
                    },
                }
            }
        }
        for k,v in pairs(moduleOptions) do
			options.args[k] = (type(v) == "function") and v() or v;
		end
    end
    return options;
end

--FIN
    
-- Local Functions
local MyAddons;
do
    function MyAddons()
	
        if (myAddOnsFrame_Register) then
            local DHUD3_mya = {
                ["name"]         = "DHUD3",
                ["version"]      = versionstring,
                ["author"]       = "Arcanefoam (Horacio Hoyos) -- Drathl/Silberklinge",
                ["category"]     = MYADDONS_CATEGORY_COMBAT,
                ["email"]        = "arcanefoam@gmail.com",
                ["website"]      = "http://www.wowace.com/projects/DHUD3/",
            };
            myAddOnsFrame_Register(DHUD3_mya);
        end
    end

end

--[[
        GetHealth: Get the health value for a unit. 
        arguments:
            unit: unit to query value
        returns:
            maximum, current and percent values. need: bollean idicating if the unit's health is below 100%
]]--
function DHUD3:GetUnitHealth(unit)

    local maxVal, curVal, curFrac, need, found;
    maxVal = UnitHealthMax(unit);
    curVal = UnitHealth(unit);
	if ( maxVal > 0 ) then
		curFrac = curVal / maxVal;
	else
		curFrac = 0;
	end
    if curFrac ~= 1 then 
        need = true;
    end
    return maxVal, curFrac, need;
end

--[[
        GetPower: Get the health value for a unit. 
        arguments:
            unit: unit to query value
            powerType: type of power for that unit
        returns:
            maximum, current and percent values. nedd: bollean idicating if the unit lackcs power (has power if power = rage)
]]--
function DHUD3:GetUnitPower(unit, powerType)

    local maxVal, curVal, curFrac, need;
    if ( powerType ) then
        curVal = UnitPower(unit, powerType);
		maxVal = UnitPowerMax(unit, powerType);
        if ( maxVal ~= 0 ) then
            curFrac = curVal / maxVal;
            if ( powerType == 1 ) then
                if ( curFrac ~= 0 ) then 
                    need = true;
                end
            else
                if ( curFrac ~= 1 ) then 
                    need = true;
                end
            end
        else
            curFrac = 0;
            need = false;
        end
        return maxVal, curFrac, need;
    else
        return false;
    end
end

--[[ 
	UpdateAlpha: Set the HUD's alpha acording to the state of the player. A module can set any of the levels to true or false. The highst level that has it's value in tru will be chosen.
	arguments:
		level: level to set the value
                                5 = dead
                                4 = comba
                                3 = cast
                                2 = select (targeting)
                                1 = regeneration
		state: state to put the level on (true = on, false = off)
]]--
function DHUD3:UpdateAlpha(level, state, vote)
	
	if level == 1 then
		regenAlphaVotes[vote] = state;
		if (regenAlphaVotes[1] or regenAlphaVotes[2]) then
			currentAlphaValue[1] = true;
		else
			currentAlphaValue[1] = false;
		end
	else
		currentAlphaValue[level] = state;
	end
	local alpha;
	if ( currentAlphaValue[5] ) then
		alpha = "deadAlpha";
	elseif ( currentAlphaValue[4] ) then
		alpha = "combatAlpha";
	elseif ( currentAlphaValue[3] ) then
		alpha = "castAlpha";
	elseif ( currentAlphaValue[2] ) then
		alpha = "selectAlpha";
	elseif ( currentAlphaValue[1] ) then
		alpha = "regenAlpha";
	else
		alpha = "oocAlpha";
	end
	DHUD3_mainFrame:SetAlpha(DHUD3.db.profile[alpha]);
end

--[[
            Rgb2hex: Transform a RGB color to a HEX color
            arguments:
                r, g, b: RGB values
            returns:
                Hex value for the RGB   
]]--
function DHUD3:Rgb2hex(r, g, b)

    local hexr, hexg, hexb;
    hexr = string_format("%x", r * 255);
    hexr = string_len(hexr) == 1 and "0"..hexr or hexr;
    hexg = string_format("%x", g * 255);
    hexg = string_len(hexg) == 1 and "0"..hexg or hexg;
    hexb = string_format("%x", b * 255);
    hexb = string_len(hexb) == 1 and "0"..hexb or hexb;
    return hexr..hexg..hexb;
end

--[[
        Colorize: Get the bar color according to the mana or power type and percent full. Used for bars and texts.
        arguments:
            who: Unit's property being colorized
            propoerty: Property being colorized
            percent: Current percent value for that property
        returns:
            r, g, b and hex values for the calculated color. 
]]--
function DHUD3:Colorize(colorTable, percent)

	local r, g, b, diff, r0, g0, b0, r1, g1, b1, r2, g2, b2;
    local threshold1, threshold2  = 0.6, 0.2;
    if ( colorTable ) then
        r0, g0, b0 = unpack(colorTable.full);
        r1, g1, b1 = unpack(colorTable.med);
        r2, g2, b2 = unpack(colorTable.low);
    end
    if ( percent <= threshold2 ) then
        r, g, b = r2, g2, b2;
    elseif ( percent <= threshold1) then
        diff = 1 - (percent - threshold2) / (threshold1 - threshold2);
        r = r1 - (r1 - r2) * diff;        
        g = g1 - (g1 - g2) * diff;        
        b = b1 - (b1 - b2) * diff;    
    elseif ( percent < 1) then        
        diff = 1 - (percent - threshold1) / (1 - threshold1);        
        r = r0 - (r0 - r1) * diff;        
        g = g0 - (g0 - g1) * diff;        
        b = b0 - (b0 - b1) * diff;    
    else
        r, g, b = r0, g0, b0;
    end
	----self:Debug("colorize", r, g, b)
    if (r < 0) then r = 0; end    
    if (r > 1) then r = 1; end    
    if (g < 0) then g = 0; end    
    if (g > 1) then g = 1; end    
    if (b < 0) then b = 0; end    
    if (b > 1) then b = 1; end
    hex = self:Rgb2hex(r, g, b);
    return r, g, b, hex;
end

 --[[
        UnitIsNPC: Check if the unit is a NPC
        arguments:
            unit: unit to check
        returns:
            true if the unit is a NPC
]]--
function DHUD3:UnitIsNPC(unit)

    return not (UnitIsPlayer(unit) or UnitPlayerControlled(unit) or UnitCanAttack("player", unit));
end

--[[
        UnitIsPet: Check if the unit is a pet
        arguments:
            unit: unit to check
        returns:
            true if the unit is a pet
]]--
function DHUD3:UnitIsPet(unit)

    return not self:UnitIsNPC(unit) and not UnitIsPlayer(unit) and UnitPlayerControlled(unit);
end   

--[[ 
        UpdateBar: Update a bars value, changing its height and color acording to the maximun and current value
        arguments:
            owner: unit tha bar displays info about
            bar:    bar to set value
            valueType: identify if it is health or power
]]--
function DHUD3:UpdateBar(bar, maxVal, fracVal, color)

    --DHUD3:Debug("updateBar", bar, maxVal, fracVal, color)
    local bgt = _G["DHUD3_"..bar.."_Texture"];
    if ( maxVal == 0 ) then
        _G["DHUD3_"..bar.."_Text_Text"]:Hide();
    else
        _G["DHUD3_"..bar.."_Text_Text"]:SetTextColor(color.r, color.g, color.b)
        _G["DHUD3_"..bar.."_Text_Text"]:Show();
    end
    
    -- Hide when Bar empty ?
    if ( fracVal == 0 ) then
        bgt:Hide()
        if ( not ( db.showEmpty and db.useBorders ) ) then
            _G["DHUD3_"..bar.."_Border"]:Hide();
        else
            _G["DHUD3_"..bar.."_Border"]:Show();
        end
    else
        local point, parent, relative, position, texture, border, gap;
        if DHUD3.layout.playerBars[bar] then
            point, parent, relative, position, texture, border, gap = unpack(DHUD3.layout.playerBars[bar]);
		elseif DHUD3.layout.petBars[bar] then
            point, parent, relative, position, texture, border, gap = unpack(DHUD3.layout.petBars[bar]);
		elseif DHUD3.layout.outerBars[bar] then
			point, parent, relative, position, texture, border, gap = unpack(DHUD3.layout.outerBars[bar]);
		elseif DHUD3.layout.castBars[bar] then
			point, parent, relative, position, texture, border, gap = unpack(DHUD3.layout.castBars[bar]);
        end
        local tex_gap_top, tex_gap_bottom = unpack(DHUD3.layout[gap]);
        local x0, x1, y0, y1 = unpack(DHUD3.layout[position]);
        local tex_gap_top_p    = tex_gap_top / 256
        local tex_gap_bottom_p = tex_gap_bottom / 256
        local h = (256 - tex_gap_top - tex_gap_bottom) * fracVal
        local top    = 1 - ( fracVal - (tex_gap_top_p) )
        local bottom = 1 - tex_gap_bottom_p
        top = top  - ( (tex_gap_top_p + tex_gap_bottom_p) * (1 - fracVal) )
        if ( top > 1 ) then top = 1; end
		if ( bottom < 0 ) then bottom = 0; end
        bgt:SetHeight(h)
        bgt:SetTexCoord(x0, x1, top, bottom )
        bgt:SetPoint(point, _G["DHUD3_"..bar], relative, 0, tex_gap_bottom)
        bgt:SetVertexColor(color.r, color.g, color.b)
        bgt:Show()
        if ( db.useBorders ) then
            _G["DHUD3_"..bar.."_Border"]:Show();
        else
            _G["DHUD3_"..bar.."_Border"]:Hide();
        end
    end
end

--[[
    FormatTime: Format a time in seconds to Hours, minutes, seconds
    arguments:
        secs: time in seconds to format
    returns:
        Formated time
]]--
function DHUD3:FormatTime(secs)

	if secs >= 86400 then
		return format('%dd', math.floor(secs/86400));
	elseif secs >= 3600 then
		return format('%dh', math.floor(secs/3600));
	elseif secs >= 60 then
		return format('%dm', math.floor(secs/60));
	else
		return format("%d", math.floor(secs));
	end
end

--[[
    OnInitialize: Function called when the addon is initialized
]]--
function DHUD3:OnInitialize()
    
	--[===[@debug@
	DHUD3:ToggleDebugLog(true);
	--@end-debug@]===]

	-- Register some SharedMedia goodies.
	LSM3:Register("font", "ABF", [[Interface\Addons\DHUD3\fonts\ABF.ttf]]);
	LSM3:Register("font", "Accidental Presidency", [[Interface\Addons\DHUD3\fonts\Accidental Presidency.ttf]]);
	LSM3:Register("font", "Adventure", [[Interface\Addons\DHUD3\fonts\Adventure.ttf]]);
	LSM3:Register("font", "Diablo",	[[Interface\Addons\DHUD3\fonts\Avqest.ttf]]);
	LSM3:Register("font", "Bazooka", [[Interface\Addons\DHUD3\fonts\	Bazooka.ttf]]);
	LSM3:Register("font", "Big Noodle Oblique", [[Interface\Addons\DHUD3\fonts\BigNoodleTitling-Oblique.ttf]]);
	LSM3:Register("font", "Big Noodle ", [[Interface\Addons\DHUD3\fonts\BigNoodleTitling.ttf]]);
	LSM3:Register("font", "Black Chancery",	 [[Interface\Addons\DHUD3\fonts\BlackChancery.ttf]]);
	LSM3:Register("font", "Emblem", [[Interface\Addons\DHUD3\fonts\Emblem.ttf]]);
	LSM3:Register("font", "Enigma 2", [[Interface\Addons\DHUD3\fonts\Enigma__2.ttf]]);
	LSM3:Register("font", "Movie Poster", [[Interface\Addons\DHUD3\fonts\Movie_Poster-Bold.ttf]]);
	LSM3:Register("font", "Porky", [[Interface\Addons\DHUD3\fonts\Porky.ttf]]);
	LSM3:Register("font", "Tangerin", [[Interface\Addons\DHUD3\fonts\Tangerin.ttf]]);
	LSM3:Register("font", "Twenty Century",	 [[Interface\Addons\DHUD3\fonts\Tw_Cen_MT_Bold.ttf]]);
	LSM3:Register("font", "Ultima Campagnoli", [[Interface\Addons\DHUD3\fonts\Ultima_Campagnoli.ttf]]);
	LSM3:Register("font", "Vera Serif", [[Interface\Addons\DHUD3\fonts\VeraSe.ttf]]);
    LSM3:Register("font", "Yellow Jacket", [[Interface\Addons\DHUD3\fonts\Yellowjacket.ttf]]);
	
	-- Main Frame
    local point, parent, relative, x, y, width, height = unpack(self.layout.mainFrame);
    ref = CreateFrame ("Frame", "DHUD3_mainFrame", _G[parent]);
    ref:ClearAllPoints();
    ref:SetPoint(point, parent, relative, x, y);
    ref:SetHeight(height);	
    ref:SetWidth(width);
    ref:EnableMouse(false);
    ref:Show();
    
    -- Left and right frames were the bars and texts are placed
    for k, v in pairs(self.layout.frames) do
        point, parent, relative, x, y, width, height = unpack(v);
        ref = CreateFrame("Frame", "DHUD3_"..k, _G["DHUD3_"..parent]);
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        ref:EnableMouse(false);
    end
	
    --Manage the Database
	self.db = LibStub("AceDB-3.0"):New("DHUD3DB", defaults, "Default");
	self.db.RegisterCallback( DHUD3, "OnProfileChanged", "Refresh" );
	self.db.RegisterCallback( DHUD3, "OnProfileCopied", "Refresh" );
	self.db.RegisterCallback( DHUD3, "OnProfileReset", "Refresh" );
    db = self.db.profile;
    self.optionsFrames = {};
	
    --Add the options table to the addon menu in blizz addon interface (thanks Nevcariel)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("DHUD3", GetOptions);
    self.optionsFrames.DHUD3 = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DHUD3", nil, nil, "layout");
    self:RegisterChatCommand("DHUD3", "ChatCommand");
    -- Add info to the Options array for the Profile Options
    self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), "Profiles");
    
    -- MyAddons Support
    MyAddons();
end

--[[
    ChatCommand: Called when the chat command is entered (thanks Nevcariel). The config menu is always called. NO current support for in line command configuration.
]]--
function DHUD3:ChatCommand(input)
	
	--DHUD3:Debug("ChatCommand", input);
	InterfaceOptionsFrame_OpenToCategory(DHUD3.optionsFrames.DHUD3);
end

--[[
    RegisterModuleOptions: Function to register other modules options with the core options table (thanks Nevcariel)
]]--
function DHUD3:RegisterModuleOptions(name, optionTbl, displayName)

	moduleOptions[name] = optionTbl;
	self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DHUD3", displayName, "DHUD3", name);
end

--[[
    OnEnable: Called whent the addon is Enabled (start up or reanable)
]]--    
function DHUD3:OnEnable()

	if ( not isSetup ) then
		self:Refresh();
		self:RegisterEvent("PLAYER_ALIVE");
		self:RegisterEvent("PLAYER_DEAD");
		self:RegisterEvent("PLAYER_UNGHOST");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		isSetup = true;
    end  
end

--[[
    OnDisable: Called when the addon gets disabled. Hide the Main Frame to hide all frames
]]--
function DHUD3:OnDisable()

    DHUD3_mainFrame:Hide();
end

--[[
    OnProfileChanged: Called when the user changes the profile
]]--
function DHUD3:OnProfileChanged()
 
	DHUD3:Debug("OnProfileChanged");
	DHUD3:Refresh();
end

--[[ 
    GetModuleEnabled: Get the current state of a module
    arguments:
        mocule: Name of the module who's state we want to query
    returns:
        true: Module is enabled
        false: Modile is not enabled
]]--
function DHUD3:GetModuleEnabled(module)

	return db.modules[module];
end

--[[
    SetModuleEnabled: Set the current module state
    arguments:
        module: Name of the module
        value: new enabled state. true = enabled, false = disabled
]]--
function DHUD3:SetModuleEnabled(module, value)

	local old = db.modules[module];
	db.modules[module] = value;
	if ( old ~= value ) then
		if value then
			self:EnableModule(module);
		else
			self:DisableModule(module);
		end
	end
end

--[[
    Refresh: Called everytime the configuration of the addon changes. Since this are global configuration values, all the enabled modules are refreshed as well
]]--
function DHUD3:Refresh()

	db = self.db.profile;
	DHUD3_mainFrame:SetAlpha(db["oocAlpha"]);
	DHUD3_mainFrame:SetScale(db.scale);
	DHUD3_mainFrame:Show();
    -- Center Spacing
    for k, v in pairs(self.layout.frames) do
        point, parent, relative, x, y, width, height = unpack(v);
        ref = _G["DHUD3_"..k];
        ref:ClearAllPoints();
        if ( string_find(k, "right") ) then
            ref:SetPoint(point, _G["DHUD3_"..parent], relative, db.frameSpacing, y);
        else
            ref:SetPoint(point, _G["DHUD3_"..parent], relative, - db.frameSpacing, y);
        end
    end
	if ( db.miniMap ) then
		DHUD3.Minimap:UpdatePosition();
		DHUD3.Minimap:Show();
	else
		DHUD3.Minimap:Hide();
	end
    -- Cicle all the modules and refresh the enabled ones.
	for k,v in self:IterateModules() do
		if self:GetModuleEnabled(k) and not v:IsEnabled() then
			self:EnableModule(k);
		elseif not self:GetModuleEnabled(k) and v:IsEnabled() then
			self:DisableModule(k);
		end
		if type(v.Refresh) == "function" then
			v:Refresh();
		end
	end
end

--[[
    GetScale: Get the current HUD's scale
    returns:
        Current scale value (db.scale)
]]--
function DHUD3:GetScale()
    
    return db.scale;
end

--[[
    GetFont: Get the current HUD's font
    returns:
        Name of the current font
]]--
function DHUD3:GetFont()

	return LSM3:Fetch('font', db.font);
end

--[[
    PLAYER_ALIVE: Event function. Set the HUD's alpha
]]--
function DHUD3:PLAYER_ALIVE()

    if ( UnitIsDeadOrGhost("player") ) then
        self:PLAYER_DEAD();
    else
		DHUD3:UpdateAlpha(5, false);
    end
end

--[[
    PLAYER_UNGHOST: Event function. Set the HUD's alpha
]]--
function DHUD3:PLAYER_UNGHOST()

    DHUD3:UpdateAlpha(5, false);
end

--[[
    PLAYER_DEAD: Event function. Set the HUD's alpha
]]--
function DHUD3:PLAYER_DEAD()

    DHUD3:UpdateAlpha(5, true);
end

--[[
    PLAYER_REGEN_ENABLED: Event function. Set the HUD's alpha
]]--
function DHUD3:PLAYER_REGEN_ENABLED()
    
    DHUD3:UpdateAlpha(4, false);
end

--[[
    PLAYER_REGEN_DISABLED: Event function. Set the HUD's alpha
]]--
function DHUD3:PLAYER_REGEN_DISABLED()
    
    DHUD3:UpdateAlpha(4, true);
end  

--[[
    MoveFrame: Funtcion called when the user drops the frame.
    Use :
        frame:SetScript("OnDragStart", DHUD3.MoveFrame);
]]--
function DHUD3:MoveFrame()

	if ( IsAltKeyDown() ) then
		this:StartMoving();
		this.isMoving = true;
	end
end

--[[
    DropFrame: Funtcion called when the user drops the frame.
    Use :
        frame:SetScript("OnDragStop", DHUD3.DropFrame);
]]--
function DHUD3:DropFrame()
	
	if ( this.isMoving ) then
		this.isMoving = false;
		this:StopMovingOrSizing();
		this:SetUserPlaced(false);
		local i = string_find(this:GetName(), "_");
		bar = string_sub(this:GetName(), i+1, -6);
		local point, parent, relative, justify;
		if DHUD3.layout.playerText[bar] then
            point, parent, relative, _, _, _, _, justify = unpack(DHUD3.layout.playerText[bar]);
		elseif DHUD3.layout.petText[bar] then
            point, parent, relative, _, _, _, _, justify = unpack(DHUD3.layout.petText[bar]);
		elseif DHUD3.layout.outerText[bar] then
			point, parent, relative, _, _, _, _, justify = unpack(DHUD3.layout.outerText[bar]);
		elseif DHUD3.layout.castText[bar] then
			point, parent, relative, _, _, _, _, justify = unpack(DHUD3.layout.castText[bar]);
        end
		local pointOfs, relativeTo, relativePoint, xOfs, yOfs = this:GetPoint(1);
		-- Save button position to profile
		db.barTextPos[bar].moved = true;
		db.barTextPos[bar].x = xOfs;
		db.barTextPos[bar].y = yOfs;
		db.barTextPos[bar].relative = relativePoint;
		db.barTextPos[bar].point = pointOfs;
	end
end

--[[
    PlaceBarTexts: Place the bar's text if player moved them
    arguments:
        bars: Name of the module's text frames (accordingly to Layout.lua)
]]--
function DHUD3:PlaceBarTexts(bars)
	
	local barText = DHUD3.layout[bars];
	local position
	for k, v in pairs(barText) do
		position = DHUD3.db.profile.barTextPos[k];
		if position.moved then
			ref = _G["DHUD3_"..k.."_Text"];
			ref:ClearAllPoints();
			ref:SetPoint(position.point, nil, position.relative, position.x, position.y);
		end
	end
end

--[[
    OnUpdateBarHealth: Update a bar's value when the unit's health changes
    Use:
        bar:RegisterEvent("UNIT_HEALTH");
        bar:RegisterEvent("UNIT_MAXHEALTH");
        bar:SetScript("OnEvent", DHUD3.OnUpdateBarHealth);
]]--
function DHUD3:OnUpdateBarHealth(event, elapsed)
	
    if ( UnitExists(this.who) ) then
    	local maxVal, curFrac, need
    	local color = {r=0,g=0,b=0,hex=""}
    	maxVal, curFrac, need = DHUD3:GetUnitHealth(this.who);
        if ( UnitIsTapped(this.who) and ( not UnitIsTappedByPlayer(this.who) ) ) then       
            this.display = 8;
		end
    	color.r, color.g, color.b, color.hex = DHUD3:Colorize(this.colors[tostring(this.display)], curFrac);
    	DHUD3:UpdateBar(this.bar, maxVal, curFrac, color);
    	if ( need and (this.who == "player") ) then 
    		DHUD3:UpdateAlpha(1, true, 1);
    	else
    		DHUD3:UpdateAlpha(1, false, 1);
    	end
    else
        this:SetScript("OnUpdate", nil);
        this:Hide();
    end    
end

--[[
    OnUnitPower: Update a bar's value when the unit's power changes
    Use:
       bar:SetScript("OnUpdate", DHUD3.OnUpdateBarPower);
]]--
function DHUD3:OnUnitPower(event, who)
		
	if ( event == "UNIT_DISPLAYPOWER" ) then
		if ( who == this.who ) then
			local powerType = UnitPowerType(who);
			this.display = powerType;
			this.maxVal = UnitPowerMax(this.who, powerType);
		end
	else
		if ( who == this.who ) then
			this.maxVal = UnitPowerMax(this.who, this.display);
		end
	end
end

--[[
    OnUpdateBarPower: Update a bar's max value when the unit's power type changes
    Use:
        if ( powerType == 0 ) then
            bar:RegisterEvent("UNIT_MAXMANA");
        elseif ( powerType == 1 ) then
            bar:RegisterEvent("UNIT_MAXRAGE");
        elseif ( powerType == 3 ) then
            bar:RegisterEvent("UNIT_MAXENERGY");
        elseif ( powerType == 6 ) then
            bar:RegisterEvent("UNIT_MAXRUNIC_POWER");
        end
        bar:RegisterEvent("UNIT_DISPLAYPOWER");
        bar:SetScript("OnEvent", DHUD3.OnUpdateBarPower);
]]--
function DHUD3:OnUpdateBarPower(event, elapsed)
	
    if ( UnitExists(this.who) ) then
    	local color = {r=0,g=0,b=0,hex=""};
    	local need;
    	local curFrac = UnitPower(this.who, this.display) / this.maxVal;
    	if ( this.display == 1 or this.display == 6 ) then
    		if curFrac ~= 0 then 
    			need = true;
    		end
    	else
    		if curFrac ~= 1 then 
    			need = true;
    		end
    	end
        if ( UnitIsTapped(this.who) and ( not UnitIsTappedByPlayer(this.who) ) ) then
            color.r, color.g, color.b, color.hex = DHUD3:Colorize(this.colors[tostring(8)], curFrac);
        else
            color.r, color.g, color.b, color.hex = DHUD3:Colorize(this.colors[tostring(this.display)], curFrac);
		end
    	DHUD3:UpdateBar(this.bar, this.maxVal, curFrac, color);
    	if ( need and (this.who == "player") ) then 
    		DHUD3:UpdateAlpha(1, true, 2);
    	else
    		DHUD3:UpdateAlpha(1, false, 2);
    	end
    else
        this:SetScript("OnEvent", nil);
        this:SetScript("OnUpdate", nil);
        this:Hide();
    end
end

--[[
    SetBarsStat: Set a bar to track a unit's stat (health or power)
    Use:
        DHUD3:SetBarsStat("pet", layout.health, "h", colors);
    arguments:
        who = unit to track
        bar = bar used to track
        stat = h = health, p = power
        colors = table with the colors desired (extracted from the options db)
]]--
function DHUD3:SetBarsStat(who, bar, stat, colors)
    
    --DHUD3:Debug("SetBarsStat", who, bar, stat, colors)
	local maxVal;
	local color = {r=0,g=0,b=0,hex=""};
	local barFrame = _G["DHUD3_"..bar];
    local healthTyp, powerTyp;
	barFrame:SetScript("OnUpdate", nil);
    barFrame:SetScript("OnEvent", nil);
	barFrame:UnregisterAllEvents();
	if ( stat == "h" ) then
		-- Health
		maxVal = DHUD3:GetUnitHealth(who);
		barFrame:RegisterEvent("UNIT_HEALTH");
		barFrame:RegisterEvent("UNIT_MAXHEALTH");
		barFrame:SetScript("OnUpdate", DHUD3.OnUpdateBarHealth);
        barFrame.display = 7;
	elseif ( stat == "p" ) then
		-- Power
        local powerType = UnitPowerType(who);
		if ( barFrame.current ) then
            powerType = 0;	
		end
		maxVal = UnitPowerMax(who, powerType);
		barFrame.display = powerType;
		if ( maxVal ~= 0 ) then 
			if ( powerType == 0 ) then
				barFrame:RegisterEvent("UNIT_MAXMANA");
			elseif ( powerType == 1 ) then
				barFrame:RegisterEvent("UNIT_MAXRAGE");
			elseif ( powerType == 3 ) then
				barFrame:RegisterEvent("UNIT_MAXENERGY");
			elseif ( powerType == 6 ) then
				barFrame:RegisterEvent("UNIT_MAXRUNIC_POWER");
			end
			barFrame:RegisterEvent("UNIT_DISPLAYPOWER");
			barFrame:SetScript("OnEvent", DHUD3.OnUnitPower);
			barFrame:SetScript("OnUpdate", DHUD3.OnUpdateBarPower);
		else
			DHUD3:UpdateBar(bar, maxVal, 0);
		end        
	end
	--same
	barFrame.who = who;
	barFrame.bar = bar;
	barFrame.maxVal = maxVal;
	barFrame.colors = colors;
	barFrame:Show();
end

function DHUD3:RemoveBarStat(bar)
    
    local barFrame = _G["DHUD3_"..bar];
    barFrame.current = nil;
	barFrame:SetScript("OnUpdate", nil);
    barFrame:SetScript("OnEvent", nil);
	barFrame:UnregisterAllEvents();
    barFrame:Hide();
end

function DHUD3:SetMinimapButtonPosition(angle)

	db.minimapPos = angle;
end

function DHUD3:GetMinimapButtonPosition(angle)

	return db.minimapPos;
end
