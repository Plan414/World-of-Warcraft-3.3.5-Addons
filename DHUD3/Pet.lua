--[[
Pet.lua
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

local MODNAME = "Pet";
local Pet = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 147 $"):match("%d+"));

local string_match = string.match;
local string_find = string.find;
local string_len = string.len;
local string_sub = string.sub;
local string_upper = string.upper;
local layout = {
        health = "e",
        power = "e",
        icons = "e",
    }
--Fonts
local maxfont = 25
local minfont = 6

	--Local Defaults
local db
local defaults = {
	profile = {
		click = false,
        blizPet = true,
        pet = "c",
		icon = true,
		layout = "HLPR",
		barHText = true,
		barPText = true,
		hStyle = "[FractionalHP] ([PercentHP:Percent])",
		cHStyle = "",
		pStyle = "[FractionalMP] ([PercentMP:Percent])",
		cPStyle = "",
		vehicle = true,
		vehBars =  "player",
		druidMana = false,
		druidBar = "r",
		druidText = true,
		dStyle = "[FractionalDruidMP] ([PercentDruidMP:Percent])",
		dCStyle = "",
		petBarsText = {
			lpo = {},
			lpi = {},
			rpo = {},
			rpi = {},
		},
		textSize = 10,
		colors = {
			["0"] = {
	            full = { 0, 0.67, 0.67 },
	            med = { 0, 0, 0.67 },
	            low = { 0.67, 0, 0.67 }
	        },
			["1"] = { 
	            full = { 0.67, 0, 0 },
	            med = { 0.67, 0.15, 0.15 },
	            low = { 0.67, 0.28, 0.28 }
	        },
			["2"] = {
	            full = { 0.67, 0.27, 0 },
	            med = { 0.67, 0.27, 0 },
	            low = { 0.67, 0.27, 0 }
	        },
	        ["3"] = { 
	            full = { 0.67, 0.67, 0 },
	            med = { 0.67, 0.67, 0.15 },
	            low = { 0.67, 0.67, 0.28 }
	        },
			["6"] = { 
	            full = { 0, 0.43, 0.58 },
	            med = { 0.15, 0.48, 0.56 },
	            low = { 0.21, 0.50, 0.54 }
	        },
	        ["7"] = {
	            full = { 0, 0.67, 0 },
	            med = { 0.67, 0.67, 0 },
	            low = { 0.67, 0, 0 },
	        },
		},
	}
}

-- Functions required by the configuration options table
local OptGetter, OptSetter, ColorGetter, ColorSetter, SelectGetter, SelectSetter, layoutType, healthTags, powerTags, druidTags, BarTextHidden, druidManaDisabled;
do
	local mod = Pet
	function OptGetter(info)
		local key = info[#info];
		return db[key];
	end

	function OptSetter(info, value)
		local key = info[#info];
		db[key] = value;
		mod:Refresh();
	end
    
	function SelectGetter (info, select)
        return db[select]
    end
    
    function SelectSetter (info, select, value) 
       db[select] = value
       mod:Refresh();
    end
	
    function ColorGetter (info)
        local key1, key2, key3 = info[#info-2], info[#info-1], info[#info]
		return db[key1][key2][key3][1], db[key1][key2][key3][2], db[key1][key2][key3][3]
	end
    
    function ColorSetter (info, r, g, b) 
        local key1, key2, key3 = info[#info-2], info[#info-1], info[#info]
        db[key1][key2][key3][1] = r
        db[key1][key2][key3][2] = g
        db[key1][key2][key3][3] = b
        mod:Refresh();
    end
	
	function druidManaDisabled ()
		return not db.druidMana;
	end
	
	function BarTextHidden(info)
        
        local key = info[#info];
        if string_find(key, "HStyle") then
            return not db.barHText;
        elseif string_find(key, "PStyle") then
            return not db.barPText;
        else
            return not (db.barHText or db.barPText);
        end
    end
	
	layoutType = {["c"] = L["Centered"], ["r"] = L["Right"], ["l"] = L["Left"]}
    healthTags = {
		["[FractionalHP] ([PercentHP:Percent])"] = L["Current/Max (Percent%)"],
		["[FractionalHP]"] = L["Current/Max"],
		["[HP] ([PercentHP:Percent])"] = L["Current (Percent%)"],
		["[PercentHP:Percent]"] = L["Percent%"],
		["[HP]"] = L["Current"]
	}
	powerTags = {
		["[FractionalMP] ([PercentMP:Percent])"] = L["Current/Max (Percent%)"],
		["[FractionalMP]"] = L["Current/Max"],
		["[MP] ([PercentMP:Percent])"] = L["Current (Percent%)"],
		["[PercentMP:Percent]"] = L["Percent%"], 
		["[MP]"] = L["Current"]
	}
	druidTags = {
		["[FractionalDruidMP] ([PercentDruidMP:Percent])"] = L["Current/Max (Percent%)"],
		["[FractionalDruidMP]"] = L["Current/Max"],
		["[DruidMP] ([PercentMP:Percent])"] = L["Current (Percent%)"],
		["[PercentDruidMP:Percent]"] = L["Percent%"], 
		["[DruidMP]"] = L["Current"]
	}
	vehicleDisplay = {["player"] = L["Player"], ["vehicle"] = L["Vehicle"]}
end


--Local Options
local options
local function GetOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["The pet module manages the pet bars functionality. Track pet, vehicle or druid mana"],
			arg = MODNAME,
            order = 2,
			get = OptGetter,
			set = OptSetter,
    		args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable Pet Module"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				blizPet = {
					type ='toggle',
					order = 2,
					name = L["Pet Frame"],
					desc = L["Show Blizzard's pet frame. If you hide the Player's frame no matter your choice here the Pet Frame will be hidden."],
				},
				click = {
					type ='toggle',
					order = 3,
					name = L["Click Trough Frames"],
					desc = L["Cheking this option will prevent tooltips, frame moving and menu popping for this module"],
				},
				general = {
					type = 'group',
					order = 4,
					name = L["Layout"],
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						pet = {
							type = 'select',
							order = 1,
							name = L["PetBars"],
							desc = L["Place the Pet's bars."],
							set = function (info, value) 
									db[info[#info]] = value
									if string_match(value, "c") then
										db.layout = "HLPR";
									else
										db.layout = "HIPO";
									end
									Pet:Refresh();
								end,
							values = layoutType,
						},
						layout = {
							type = 'select',
							order = 2,
							name = L["Bar Layout"],
							values = function ()
									if string_match(db.pet, "c") then
										return { ["HLPR"] = L["Health Left/Power Right"], ["HRPL"] = L["Health Right/Power Left"] }
									else
										return { ["HIPO"] = L["Health Inner/Power Outer"], ["HOPI"] = L["Health Outer/Power Inner"] }
									end
								end,
						},
						icon = {
							type = 'toggle',
							order = 3,
							name = L["Pet Happiness Icon"],
							desc = L["Show/Hide"],
						},
					},
				},
				barText = {
					type = 'group',
					order = 5,
					name = L["Bar's Text"],
					desc = L["Configure Health and Power (mana/rage/energy/runic) text options"],
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						pBarText = {
							type = 'multiselect',
							order = 1,
							name = L["Show Bar Values"],
							values = { ["barHText"] = L["Health"], ["barPText"] = L["Power"] },
							get = SelectGetter,
							set = SelectSetter,
						},
						hStyle = {
							type = 'select',
							order = 2,
							name = L["Health Style"],
							hidden = BarTextHidden,
							values = healthTags
							},
						cHStyle = {
							type = 'input',
							order = 3,
							name = L["Custom Health Style"],
							desc = L["If set this style will override Health Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"],
							hidden = BarTextHidden,
							usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
						},
						pStyle = {
							type = 'select',
							order = 4,
							name = L["Power Style"],
							hidden = BarTextHidden,
							values = powerTags
							},
						cPStyle = {
							type = 'input',
							order = 5,
							name = L["Custom Power Style"],
							desc = L["If set this style will override Power Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Power Style setting.)"],
							hidden = BarTextHidden,
							usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],								
						},
						textSize = {
							type = 'range',
							order = 6,
							name = L["Font size"],
							hidden = BarTextHidden,
							min = minfont,
							max = maxfont,
							step = 1,
						},
					},
				},	
				colors = {
					type = 'group',
					order = 6,
					name = L["Colors"],
					get = ColorGetter,
					set = ColorSetter,
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						["7"] = {
							type = 'group',
							name = L["Health"],
							order = 1,
							guiInline  = true,
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
						["0"] = {
							type = 'group',
							name = L["Mana"],
							guiInline  = true,
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
						["1"] = {
							type = 'group',
							name = L["Rage"],
							guiInline  = true,
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
						["3"] = { 
							type = 'group',
							name = L["Energy"],
							guiInline  = true,
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
						["6"] = { 
							type = 'group',
							name = L["Runic Power"],
							guiInline  = true,
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
						["2"] = {
							type = 'group',
							guiInline  = true,
							name = L["Focus (Pet)"],
							args = {
								full = {
									type = 'color',
									name = L["Full"],
									order = 1,
								},
								med = {
									type = 'color',
									name = L["Med"],
									order = 2,
								},
								low = {
									type = 'color',
									name = L["Low"],
									order = 3,
								},
							},
						},
					},
				},
				vehicle = {
					type = 'group',
					order = 7,
					name = L["Vehicle Tracking"],
					desc = L["Configure Vehicle/Player options when in vehicle"],
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					args = {
						vehicle = {
							type = 'toggle',
							order = 1,
							name = L["In Vehicle"],
							desc = L["Use pet bars to track vehicle/player stats"],
						},
						vehBars = {
							type = 'select',
							order = 1,
							name = L["Unit"],
							desc = L["Unit Pet bars track."],
							values = vehicleDisplay,
						},
					},
				},
				druid = {
					type = 'group',
					order = 8,
					name = L["Druid"],
					desc = L["Configure Druid mana tracking when shape shifted"],
					disabled = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
					hidden = function()
							_, class = UnitClass("player")
							if ( class ~= "DRUID" ) then
								return true
							else
								return false
							end
						end,
					args = {
						druidMana = {
							type = 'toggle',
							name = L["Druid Mana"],
							desc = L["Track druid's mana when shape shifted"],
							order = 1,
						},
						druidBar = {
							type = 'select',
							order = 2,
							name = L["Side"],
							desc = L["Bar Side to track mana"],
							values = {["r"] = L["Right"], ["l"] = L["Left"]},
							disabled = druidManaDisabled,
						},
						druidText = {
							type = 'toggle',
							order = 3,
							name = L["Druid Bar Values"],
							desc = L["Show/Hide"],
							disabled = druidManaDisabled,
						},
						dStyle = {
							type = 'select',
							order = 4,
							name = L["Mana Style"],
							values = druidTags,
							disabled = druidManaDisabled,
						},
						dCHStyle = {
							type = 'input',
							order = 5,
							name = L["Custom Mana Style"],
							desc = L["If set this style will override Mana Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Mana Style setting.)"],
							usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],
							disabled = druidManaDisabled,
						},
					},
				},
			},
		}
	end
	return options;
end

-- Local functions
local PlaceBarTexts, ConfigBars, UpdatePetIcon;
do
	-- Asing each bar the their respective tracking stat accordingly to the saved profile
    function ConfigBars()
	
        --DHUD3:Debug("ConfigBars");
        -- Pet
    	if string_match(db.pet, "c") then
    		if string_match(db.layout, "HLPR") then
                layout.health = "lpo";
                layout.power = "rpo";
                layout.icons = "l";
    		else
                layout.health = "rpo";
                layout.power = "lpo";
                layout.icons = "r";
    		end
    	elseif string_match(db.pet, "l") then
            layout.icons = "l";
            if string_match(db.layout, "HIPO") then
                layout.health = "lpi";
                layout.power = "lpo";
    		else
                layout.health = "lpo";
                layout.power = "lpi";
            end
    	else
    		layout.icons = "r";
            if string_match(db.layout, "HIPO") then
                layout.health = "rpi";
                layout.power = "rpo";
    		else
                layout.health = "rpo";
                layout.power = "rpi";
            end
        end
    	
    	--Bars Text Tag
		DHUD3_rpo_Text:Hide();
		DHUD3_lpo_Text:Hide();
		DHUD3_rpi_Text:Hide();
		DHUD3_lpi_Text:Hide();
		if db.druidMana then
			_G["DHUD3_"..db.druidBar.."po_Text"]:Show();
		end
    	if db.barHText then
            _G["DHUD3_"..layout.health.."_Text"]:Show();
    	end
    	if db.barPText then
            _G["DHUD3_"..layout.power.."_Text"]:Show();
    	end
    end
	
	function UpdatePetIcon()
	
		local happ = GetPetHappiness();
        local health = UnitHealth("pet");
	    --DHUD3:Debug("UpdatePetIcon", health, happ);
	    if health > 0 and happiness then
	        local texture, x0, x1, y0, y1 = unpack( DHUD3.layout.petTextures[happ] );
	        if ( texture ) then
				_G["DHUD3_"..layout.icons.."pet_Texture"]:SetTexture(texture);
	            _G["DHUD3_"..layout.icons.."pet_Texture"]:SetTexCoord(x0, x1, y0, y1);
	            _G["DHUD3_"..layout.icons.."pet"]:Show();
	        else
	            _G["DHUD3_"..layout.icons.."pet"]:Hide();
	        end
	    else
	        _G["DHUD3_"..layout.icons.."pet"]:Hide();
	    end
	end

end

function Pet:OnInitialize()
	self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, GetOptions, L["Pet"]);
	
    local bars = DHUD3.layout.petBars;
    local barText = DHUD3.layout.petText;
    local point, parent, relative, x, y, width, height;
	local icons = DHUD3.layout.petIcon;
	
	-- Bars
    for k, v in pairs(bars) do
        point, parent, relative, position, texture, border = unpack(v);
        x0, x1, y0, y1 = unpack(DHUD3.layout[position]);
        ref = CreateFrame("Button", "DHUD3_"..k, _G["DHUD3_"..parent]);
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, 0, 0);
        ref:SetHeight(256);
        ref:SetWidth(128);
        bgt = ref:CreateTexture("DHUD3_"..k.."_Texture", "ARTWORK");
        bgt:SetTexture(texture);
        bgt:SetPoint(point, ref, relative, 0, 0);
        bgt:SetHeight(256);
        bgt:SetWidth(128);
        bgt:SetTexCoord(x0, x1, y0, y1);
        bgt:SetBlendMode("BLEND");
        bgt = ref:CreateTexture("DHUD3_"..k.."_Border", "BACKGROUND");
        bgt:SetTexture(border);
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
		font:SetText(k.."2.5 Lets try the aligment");
        font:SetWidth(font:GetStringWidth() * 1.1);
        font:SetJustifyH(justify);
        font:Show();
        ref.isMoving = false;
		ref.dropTimer = 0;
		ref:RegisterForDrag("LeftButton");
		ref:SetScript("OnDragStart", DHUD3.MoveFrame);
		ref:SetScript("OnDragStop", DHUD3.DropFrame);
        ref:Hide();
    end
	
	-- Icons
    for k, v in pairs(icons) do
        parent, x, y = unpack(v);
        ref = CreateFrame("Button", "DHUD3_"..k, _G["DHUD3_"..parent]);
        ref:ClearAllPoints();
        ref:SetPoint("TOP", _G["DHUD3_"..parent], "TOP", x, y);
        ref:SetHeight(20);
        ref:SetWidth(20);
		local bgt = ref:CreateTexture("DHUD3_"..k.."_Texture","BACKGROUND")
        bgt:ClearAllPoints()
        bgt:SetPoint("TOPLEFT", ref , "TOPLEFT", 0, 0)
        bgt:SetPoint("BOTTOMRIGHT", ref , "BOTTOMRIGHT", 0, 0)
        ref:Hide();
    end
end

function Pet:OnEnable()
	
	--DHUD3:Debug("Pet:OnEnable");
    self:Refresh();
	if not self:IsEnabled() then return end
	
end

function Pet:OnDisable()
	
	self:UnregisterAllEvents();
    DHUD3_lpi:Hide();
    DHUD3_lpo:Hide();
    DHUD3_rpi:Hide();
    DHUD3_rpo:Hide();
    DHUD3_lpi:SetScript("OnUpdate", nil);
    DHUD3_lpo:SetScript("OnUpdate", nil);
    DHUD3_rpi:SetScript("OnUpdate", nil);
    DHUD3_rpo:SetScript("OnUpdate", nil);
end

function Pet:Refresh()
	
	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile
	if not self:IsEnabled() then return end
    
    --BlizzFrames
	if ( not db.blizPet and PetFrame:IsShown() ) then
		PetFrame:UnregisterAllEvents();
	    PetFrame:Hide();
	end
    DHUD3:PlaceBarTexts("petText");
	
	DHUD3_lpi:Hide();
    DHUD3_lpo:Hide();
    DHUD3_rpi:Hide();
    DHUD3_rpo:Hide();
    ConfigBars();
    DHUD3_lpi:SetScript("OnUpdate", nil);
    DHUD3_lpo:SetScript("OnUpdate", nil);
    DHUD3_rpi:SetScript("OnUpdate", nil);
    DHUD3_rpo:SetScript("OnUpdate", nil);
    
    -- Fonts
    local font
    local w
    --Targer Text
    local scale = DHUD3.GetScale();
    -- Pet Bar's Text
    font = _G["DHUD3_"..layout.health.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.textSize * scale)
    font:SetWidth(200)
    font = _G["DHUD3_"..layout.power.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.textSize * scale)
    font:SetWidth(200)
    
    -- Pet
	    -- Pet Status
    DHUD3_lpet:Hide();
    DHUD3_rpet:Hide();
	_G["DHUD3_"..layout.health]:Hide();
	_G["DHUD3_"..layout.power]:Hide();
	if db.barHText then
		local tagCode = (string_len(db.cHStyle) > 0) and db.cHStyle or db.hStyle;
		DogTag:AddFontString(_G["DHUD3_"..layout.health.."_Text_Text"], _G["DHUD3_"..layout.health.."_Text"], tagCode, "Unit", { unit = "pet" });
		_G["DHUD3_"..layout.health.."_Text"]:Show();
	else
		DogTag:RemoveFontString(_G["DHUD3_"..layout.health.."_Text_Text"]);
		_G["DHUD3_"..layout.health.."_Text"]:Hide();
	end
	if db.barPText then
		local tagCode = (string_len(db.cPStyle) > 0) and db.cPStyle or db.pStyle;
		DogTag:AddFontString(_G["DHUD3_"..layout.power.."_Text_Text"], _G["DHUD3_"..layout.power.."_Text"], tagCode, "Unit", { unit = "pet" });
		_G["DHUD3_"..layout.power.."_Text"]:Show();
	else
		DogTag:RemoveFontString(_G["DHUD3_"..layout.power.."_Text_Text"]);
		_G["DHUD3_"..layout.power.."_Text"]:Hide();
	end
	if ( UnitExists("pet") and not UnitInVehicle("player") ) then
		DHUD3:SetBarsStat("pet", layout.health, "h", db.colors);
		DHUD3:SetBarsStat("pet", layout.power, "p", db.colors);
		UpdatePetIcon();
    end
	self:RegisterEvent("UNIT_PET");
	
    -- Vehicle Swap
    if db.vehicle then
        self:RegisterEvent("UNIT_ENTERED_VEHICLE");
        self:RegisterEvent("UNIT_EXITED_VEHICLE");
        if ( UnitInVehicle("player") ) then
			local colors = db.colors;
			DHUD3:SetBarsStat(db.vehBars, layout.health, "h", db.colors);
			DHUD3:SetBarsStat(db.vehBars, layout.power, "p", db.colors);
        end
    else
        self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
        self:UnregisterEvent("UNIT_EXITED_VEHICLE");
    end
	
	--Druid
	local _, class = UnitClass("player");
	if ( db.druidMana and ( class == "DRUID" ) ) then
		_G["DHUD3_"..db.druidBar.."po"].current = 0;
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		--DHUD3:Debug("Druid mana bar");
		-- Mostrarlas de una?
		local powerType = UnitPowerType("player");
		if ( powerType ~= 0 ) then
			self:UPDATE_SHAPESHIFT_FORM();
		end
	end
	-- Bars Text Click trough
	local barText = DHUD3.layout.petText;
	for k, v in pairs(barText) do
		_G["DHUD3_"..k.."_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..k.."_Text"]:SetMovable(not db.click);
	end
end

function Pet:UNIT_PET(event, who)
	
	--DHUD3:Debug("Pet", event, who);
	--if ( ( nil ~= UnitInVehicle("player") ) and ( not UnitInVehicle("player") ) ) then
	if ((who == "player") and (not UnitInVehicle("player")) ) then
		if ( UnitExists("pet") ) then
			DHUD3:SetBarsStat("pet", layout.health, "h", db.colors);
			DHUD3:SetBarsStat("pet", layout.power, "p", db.colors);
			UpdatePetIcon();
		else
			_G["DHUD3_"..layout.health]:UnregisterAllEvents();
			_G["DHUD3_"..layout.health]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.health]:Hide();
			_G["DHUD3_"..layout.power]:UnregisterAllEvents();
			_G["DHUD3_"..layout.power]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.power]:Hide();
	    end	
	end
end

function Pet:UNIT_HAPPINESS(event, who)
	
    if ( who == "pet" ) then
        UpdatePetIcon();
    end
end

function Pet:UNIT_ENTERED_VEHICLE(event, who)
	
	--DHUD3:Debug("Pet", event, who);
    if who == "player" then
        if ( UnitInVehicle("player") ) then
			--DHUD3:Debug("Pet, PlayerInVehicle");
			self:UnregisterEvent("UNIT_PET");
			self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
			DHUD3:SetBarsStat(db.vehBars, layout.health, "h", db.colors);
			DHUD3:SetBarsStat(db.vehBars, layout.power, "p", db.colors);
			if db.barHText then
				local tagCode = (string_len(db.cHStyle) > 0) and db.cHStyle or db.hStyle;
				DogTag:AddFontString(_G["DHUD3_"..layout.health.."_Text_Text"], _G["DHUD3_"..layout.health.."_Text"], tagCode, "Unit", { unit = db.vehBars });
				_G["DHUD3_"..layout.health.."_Text"]:Show();
			end
			if db.barPText then
				local tagCode = (string_len(db.cPStyle) > 0) and db.cPStyle or db.pStyle;
				DogTag:AddFontString(_G["DHUD3_"..layout.power.."_Text_Text"], _G["DHUD3_"..layout.power.."_Text"], tagCode, "Unit", { unit = db.vehBars });
				_G["DHUD3_"..layout.power.."_Text"]:Show();
			end
        end
    end
end

function Pet:UNIT_EXITED_VEHICLE(event, who)
	
	--DHUD3:Debug("Pet", event, who);
    if ( who == "player" ) then
		self:RegisterEvent("UNIT_PET");
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		if db.barHText then
			local tagCode = (string_len(db.cHStyle) > 0) and db.cHStyle or db.hStyle;
			DogTag:AddFontString(_G["DHUD3_"..layout.health.."_Text_Text"], _G["DHUD3_"..layout.health.."_Text"], tagCode, "Unit", { unit = "pet" });
			_G["DHUD3_"..layout.health.."_Text"]:Show();
		end
		if db.barPText then
			local tagCode = (string_len(db.cPStyle) > 0) and db.cPStyle or db.pStyle;
			DogTag:AddFontString(_G["DHUD3_"..layout.power.."_Text_Text"], _G["DHUD3_"..layout.power.."_Text"], tagCode, "Unit", { unit = "pet" });
			_G["DHUD3_"..layout.power.."_Text"]:Show();
		end
        if ( UnitExists("pet") ) then
            DHUD3:SetBarsStat("pet", layout.health, "h", db.colors);
			DHUD3:SetBarsStat("pet", layout.power, "p", db.colors);
		else
			_G["DHUD3_"..layout.health]:UnregisterAllEvents();
			_G["DHUD3_"..layout.health]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.health]:Hide();
			_G["DHUD3_"..layout.power]:UnregisterAllEvents();
			_G["DHUD3_"..layout.power]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.power]:Hide();
		end
    end
end

function Pet:UPDATE_SHAPESHIFT_FORM(event, who)
	
	local maxVal, curFrac,needH, needP;
	local color = {r=0,g=0,b=0,hex=""};
	local powerType = UnitPowerType("player");
	--DHUD3:Debug("Pet", event, who);
	bar = _G["DHUD3_"..db.druidBar.."po"];
	if ( not UnitInVehicle("player") ) then
		if ( powerType ~= 0 and powerType ~= bar.current ) then
			--DHUD3:Debug("Pet:UPDATE_SHAPESHIFT_FORM show", powerType, bar:IsVisible());
			-- Is Animal, track mana
			-- Check if the druid bar is the same as on eof the pet bars
			_G["DHUD3_"..layout.health]:UnregisterAllEvents();
			_G["DHUD3_"..layout.health]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.health]:Hide();
			_G["DHUD3_"..layout.power]:UnregisterAllEvents();
			_G["DHUD3_"..layout.power]:SetScript("OnUpdate", nil);
			_G["DHUD3_"..layout.power]:Hide();	
			self:UnregisterEvent("UNIT_PET");
			
			--Power
			bar.current = powerType;
            DHUD3:SetBarsStat("player", db.druidBar.."po", "p", db.colors);
			if db.druidText then
		    	local tagCode = (string_len(db.dCStyle) > 0) and db.dCStyle or db.dStyle;
		    	DogTag:AddFontString(_G["DHUD3_"..db.druidBar.."po_Text_Text"], _G["DHUD3_"..db.druidBar.."po_Text"], tagCode, "Unit", { unit = "player" });
				_G["DHUD3_"..db.druidBar.."po_Text"]:Show();
			end
			bar:Show();
		elseif ( powerType == 0 ) then
			--DHUD3:Debug("Pet:UPDATE_SHAPESHIFT_FORM hide", powerType);
            DHUD3:RemoveBarStat(db.druidBar.."po");
            bar.current = 0;
            DogTag:RemoveFontString(_G["DHUD3_"..db.druidBar.."po_Text_Text"]);
			if db.barHText then
				local tagCode = (string_len(db.cHStyle) > 0) and db.cHStyle or db.hStyle;
				DogTag:AddFontString(_G["DHUD3_"..layout.health.."_Text_Text"], _G["DHUD3_"..layout.health.."_Text"], tagCode, "Unit", { unit = "pet" });
				_G["DHUD3_"..layout.health.."_Text"]:Show();
			end
			if db.barPText then
				local tagCode = (string_len(db.cPStyle) > 0) and db.cPStyle or db.pStyle;
				DogTag:AddFontString(_G["DHUD3_"..layout.power.."_Text_Text"], _G["DHUD3_"..layout.power.."_Text"], tagCode, "Unit", { unit = "pet" });
				_G["DHUD3_"..layout.power.."_Text"]:Show();
			end
			if ( UnitExists("pet") ) then
				DHUD3:SetBarsStat("pet", layout.health, "h", db.colors);
				DHUD3:SetBarsStat("pet", layout.power, "p", db.colors);
			end
			self:RegisterEvent("UNIT_PET");
		end
	end
end
