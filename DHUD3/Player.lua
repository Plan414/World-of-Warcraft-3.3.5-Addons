--[[
Player.lua
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
local DogTag = LibStub("LibDogTag-3.0");

local MODNAME = "Player";
local Player = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 165 $"):match("%d+"));

local unpack = unpack
local pairs = pairs
local type = type
local _G = _G
local string_find = string.find;
local string_len = string.len;
local string_sub = string.sub;
local string_match = string.match;

local playerLayout = {
        pHealth = "e",
        pPower = "e",
        pIcons = "e",
        tHealth = "e",
        tPower = "e",
        tIcons = "e",
    }
local auraUpdateInterval = 1;
	
--Fonts
local maxfont = 25
local minfont = 6    
--FIN

--Local Defaults
local db
local defaults = {
	profile = {
        blizPlayer = true,
		blizTarget = true,
		click = false,
        player = "c",
        combatIcon = true,
		pvpIcon = true,
        pvpIconTimer = true,
        swapPet = true, 
		restIcon= true,
		leaderIcon = true,
		lootIcon = true,
        pLayout = "HLPR",
        playerBarsText = {
			li = {},
			lm = {},
			ri = {},
			rm = {},
		},
        pBarHText = true,
		pBarPText = true,
		pHStyle = "[FractionalHP] ([PercentHP:Percent])",
		pCHStyle = "",
		pPStyle = "[FractionalMP] ([PercentMP:Percent])",
		pCPStyle = "",
		pBarTextSize = 10,
		pColors = {
	        ["0"] = {
	            full = { 0, 1, 1 },
	            med = { 0, 0, 1 },
	            low = { 1, 0, 1 }
	        },
	        ["1"] = {
	            full = { 1, 0, 0 },
	            med = { 1, 0.23, 0.23 },
	            low = { 1, 0.42, 0.42 }
	        },
	        ["3"] = { 
	            full = { 1, 1, 0 },
	            med = { 1, 1, 0.23 },
	            low = { 1, 1, 0.42 }
	        },
			["6"] = { 
	            full = { 0, 0.68, 0.87 },
	            med = { 0.23, 0.71, 0.84 },
	            low = { 0.47, 0.75, 0.81 }
	        },
			["7"] = {
	            full = { 0, 1, 0 },
	            med = { 1, 1, 0 },
	            low = { 1, 0, 0 }      
	        },
		},
		tBars = true,
		tNPC = true,
		tAuras = true,
		tTips = true,
		tSwap = true,
		tAurasCountColor = { 1, 144/255, 0 },
		tAurasTimerColor = {
			full = { 0, 1, 0 },
			med = { 1, 1, 0 },
			low = { 1, 0, 0 }      
		},
		tBuffs = true,
		tBuffsOwn = false,
		tBuffsCols = 3,
		tBuffsSize = 20,
		tBuffCount = 40,
		tBuffCountAlpha = 1;
		tBuffTimer = true,
		tBuffTimerAlpha = 1;
		tDebuffs = true,
		tDebuffsOwn = false,
		tDebuffsCols = 3,
		tDebuffsSize = 20,
		tDebuffCount = 40,
		tot = true,
		tName = true,
		tStyle = "[Level:DifficultyColor] [Classification] [Name:HostileColor] [isPet ? Creature:ClassColor:Bracket ! isPLayer ? Class:ClassColor:Bracket ! Faction:ClassColor:Bracket]",
		tCStyle = "",
		tNSize = 10,
		totName = true,
		totStyle = "[Level:DifficultyColor] [Classification] [Name:HostileColor] [isPet ? Creature:ClassColor:Bracket ! isPLayer ? Class:ClassColor:Bracket ! Faction:ClassColor:Bracket]",
		totCStyle = "",
		totNSize = 10,
		tPvpIcon = true,
		tRaidIcon = true,
		tEliteIcon = true,
		tBarHText = true,
		tBarPText = true,
		tHStyle = "[FractionalHP] ([PercentHP:Percent])",
		tCHStyle = "",
		tPStyle = "[FractionalMP] ([PercentMP:Percent])",
		tCPStyle = "",
		tBarTextSize = 10,
		tColors = {
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
	        ["8"] = {
	            full = { 0.8, 0.8, 0.8 },
	            med = { 0.73, 0.73, 0.73 },
	            low = { 0.67, 0.67, 0.67 }
	        },
		},
    }
}
--FIN

-- Functions required by the configuration options table
local OptGetter, OptSetter, ColorGetter, ColorSetter, SelectGetter, SelectSetter, TBarsHidden, TNameHidden, TotNameHidden, BarTextHidden, TAurasEnable;
local layoutType, healthTags, powerTags, nameTags
do
	local mod = Player
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
        return db[select];
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
	
	function ColorGetter2 (info)
        local key1, key2 = info[#info-1], info[#info];
		return db[key1][key2][1], db[key1][key2][2], db[key1][key2][3];
	end
    
    function ColorSetter2 (info, r, g, b) 
        local key1, key2 = info[#info-1], info[#info];
        db[key1][key2][1] = r;
        db[key1][key2][2] = g;
        db[key1][key2][3] = b;
        mod:Refresh();
    end
	
	function ColorGetter3 (info)
        local key1 = info[#info];
		return db[key1][1], db[key1][2], db[key1][3];
	end
    
    function ColorSetter3 (info, r, g, b) 
        local key1 = info[#info];
        db[key1][1] = r;
        db[key1][2] = g;
        db[key1][3] = b;
        mod:Refresh();
    end
	
    function TBarsHidden()
        return not db.tBars;
    end
    
    function TNameHidden()
        return not db.tName;
    end
    
    function TotNameHidden()
        return not db.totName;
    end
	
    function tDebuffsEnable()
        return not db.tDebuffs;
    end
    
    function BarTextHidden(info)
        
        local key = info[#info];
        local who = string_sub(key, 1, 1);
        if string_find(key, "HStyle") then
            return not db[who.."BarHText"];
        elseif string_find(key, "PStyle") then
            return not db[who.."BarPText"];
        else
            return not (db[who.."BarHText"] or db[who.."BarPText"]);
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
    nameTags = {
	    ["[Level:DifficultyColor] [Classification] [Name:HostileColor] [isPet ? Creature:ClassColor:Bracket ! isPLayer ? Class:ClassColor:Bracket ! Faction:ClassColor:Bracket]"] = "<level><elite> <name> [ <class> ]",
	    ["[Level:DifficultyColor] [Classification] [Name:HostileColor]"] = "<level><elite> <name>",
	    ["[Name:HostileColor] [isPet ? Creature:ClassColor:Bracket ! isPLayer ? Class:ClassColor:Bracket ! Faction:ClassColor:Bracket]"] = "<name> [ <class> ]",
	    ["[Level:DifficultyColor] [Name:HostileColor]"] = "<level> <name>",
    }
end

--Local Options
local options
local function GetOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["The player module manages the two main bars (player and target) functionality."],
			arg = MODNAME,
            order = 2,
			get = OptGetter,
			set = OptSetter,
            childGroups = "tab",
    		args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable Player Module"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				desc = {
					order = 2,
					type = "description",
					name = L["Show/Hide bliz frames"],
				},
				blizPlayer = {
					type ='toggle',
					order = 3,
					name = L["Player Frame"],
					desc = L["Show Blizzard's player frame"],
				},
				blizTarget = {
					type ='toggle',
					order = 4,
					name = L["Target Frame"],
					desc = L["Show Blizzard's target frame"],
				},
				click = {
					type ='toggle',
					order = 5,
					name = L["Click Trough Frames"],
					desc = L["Cheking this option will prevent tooltips, frame moving and menu popping for this module"],
				},
                player = {
                    type = "group",
                    order = 6,	
                    name = L["Player Options"],
                    desc = L["Configure the player's layout options"],
					disabled  = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
                    args = {
                        pLayout = {
                            type = 'group',
                            order = 1,
                            name = L["Layout"],
                            args = {
                                player = {
                                    type = 'select',
                                    order = 1,
                                    name = L["Player/Target Bars"],
                                    desc = L["Place the Player's bars. Target's bars will be set accordingly"],
                                    set = function (info, value) 
                                            db[info[#info]] = value
                                            if string_match(value, "c") then
                                                db.pLayout = "HLPR";
                                                db.tLayout = "HLPR";
                                            else
                                                db.pLayout = "HIPM";
                                                db.tLayout = "HIPM";
                                            end
                                            Player:Refresh();
                                        end,
                                    values = layoutType,
                                },
                                pLayout = {
                                    type = 'select',
                                    order = 2,
                                    name = L["Bar Layout"],
                                    values = function ()
                                            if string_match(db.player, "c") then
                                                return { ["HLPR"] = L["Health Left/Power Right"], ["HRPL"] = L["Health Right/Power Left"] }
                                            else
                                                return { ["HIPM"] = L["Health Inner/Power Outer"], ["HMPI"] = L["Health Outer/Power Inner"] }
                                            end
                                        end,
                                },
                                swapPet = {
                                    type = 'toggle',
                                    name = L["Bar Swap"],
                                    desc = L["Swap player's status for pet's when using vehicles"],
                                    order = 3,
                                },
                                icons = {
                                    type = 'header',
                                    name = L["Status Icons"],
                                    order = 4,
                                },
                                combatIcon = {
                                    type = 'toggle',
                                    order = 5,
                                    name = L["In Combat"],
                                    desc = L["Show/Hide"],
                                },
                                restIcon = {
                                    type = 'toggle',
                                    order = 6,
                                    name = L["Resting"],
                                    desc = L["Show/Hide"],
                                },
                                leaderIcon = {
                                    type = 'toggle',
                                    order = 7,
                                    name = L["Party Leader"],
                                    desc = L["Show/Hide"],
                                },
                                lootIcon = {
                                    type = 'toggle',
                                    order = 8,
                                    name = L["Master Looter"],
                                    desc = L["Show/Hide"],
                                },
                                pvpIcon = {
                                    type = 'toggle',
                                    order = 9,
                                    name = L["PVP Flag"],
                                    desc = L["Show/Hide"],
                                },
                                pvpTimer = {
                                    type = 'header',
                                    name = L["PvP Timer"],
                                    order = 10,
                                },
                                pvpIconTimer = {
                                    type = 'toggle',
                                    order = 11,
                                    name = L["PvP Timer"],
                                    desc = L["Show/Hide"],
                                    disabled  = function() return not db.pvpIcon; end,
                                },
                            },
                        },
                        barText = {
                            type = 'group',
                            order = 2,
                            name = L["Bar's Text"],
                            desc = L["Configure Health and Power (mana/rage/energy/runic) text options"],
                            args = {
                                pBarText = {
                                    type = 'multiselect',
                                    order = 1,
                                    name = L["Show Bar Values"],
                                    values = { ["pBarHText"] = L["Health"], ["pBarPText"] = L["Power"] },
                                    get = SelectGetter,
                                    set = SelectSetter,
                                },
                                pHStyle = {
                                    type = 'select',
                                    order = 2,
                                    name = L["Health Style"],
                                    hidden = BarTextHidden,
                                    values = healthTags
                                    },
                                pCHStyle = {
                                    type = 'input',
                                    order = 3,
                                    name = L["Custom Health Style"],
                                    desc = L["If set this style will override Health Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"],
                                    hidden = BarTextHidden,
                                    usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
                                },
                                pPStyle = {
                                    type = 'select',
                                    order = 4,
                                    name = L["Power Style"],
                                    hidden = BarTextHidden,
                                    values = powerTags
                                    },
                                pCPStyle = {
                                    type = 'input',
                                    order = 5,
                                    name = L["Custom Power Style"],
                                    desc = L["If set this style will override Power Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Power Style setting.)"],
                                    hidden = BarTextHidden,
                                    usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],								
                                },
                                pBarTextSize = {
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
                        pColors = {
                            type = 'group',
                            order = 3,
                            name = L["Colors"],
                            get = ColorGetter,
                            set = ColorSetter,
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
                            },
                        },
                    },
                },
                target = {
                    type = 'group',
    				order = 7,	
                    name = L["Target Options"],
                    desc = L["Configure the target's layout options"],
					disabled  = function() return not DHUD3:GetModuleEnabled(MODNAME); end,
                    args = {
                        tLayout = {
                            type = 'group',
                            order = 1,
                            name = L["Layout"],
                            args = {
                                tBars = {
                                    type = 'toggle',
                                    order = 1,
                                    name = L["Target Bars"],
                                    desc = L["Show/Hide"],
                                },
                                tNPC = {
                                    type = 'toggle',
                                    order = 2,
                                    name = L["When NPC"],
                                    desc = L["Show/Hide"],
                                    hidden = TBarsHidden,
                                },
                                tAuras = {
                                    type = 'toggle',
                                    order = 3,
                                    name = L["Auras"],
                                    desc = L["Show/Hide"],
                                    hidden = TBarsHidden,
                                },
								icons = {
                                    type = 'header',
                                    name = L["Status Icons"],
                                    order = 4,
                                    hidden = TBarsHidden,
                                },
                                tPvpIcon = {
                                    type = 'toggle',
                                    order = 5,
                                    name = L["PvP Flag"],
                                    desc = L["Show/Hide"],
                                    hidden = TNameHidden,
                                },
								tRaidIcon = {
                                    type = 'toggle',
                                    order = 6,
                                    name = L["Raid Icon"],
                                    desc = L["Show/Hide"],
                                    hidden = TNameHidden,
                                },
                                tEliteIcon = {
                                    type = 'toggle',
                                    order = 7,
                                    name = L["Elite Icon"],
                                    desc = L["Show/Hide"],
                                    hidden = TBarsHidden,
                                },
                                tName = {
                                    type = 'group',
            						order = 8,
                                    name = L["Target Name Plate"],
                                    args = {
            							tName = {
            								type = 'toggle',
            								order = 1,
            								name = L["Show"],
            								desc = L["Show target Name plate"],
            							},
            							tStyle = {
            								type = 'select',
            								order = 2,
            								name = L["Name Style"],
            								hidden = TNameHidden,
            								values = nameTags
            							},
            							tCStyle = {
            								type = 'input',
            								order = 3,
            								name = L["Custom Name Style"],
            								desc = L["If set this style will override Name Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"],
            								hidden = TNameHidden,
            								usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
            							},
                                        tNSize = {
                                            type = 'range',
            								order = 4,
                                            name = L["Text Size"],
            								hidden = TNameHidden,
                                            min = minfont,
                                            max = maxfont,
                                            step = 1,
                                        },
                                    },
                                },
                                totName = {
                                    type = 'group',
            						order = 9,
                                    name = L["Target Target Name Plate"],
                                    args = {
            							totName = {
            								type = 'toggle',
            								order = 1,
            								name = L["Show"],
            								desc = L["Show target of target Name plate"],
            							},
            							totStyle = {
            								type = 'select',
            								order = 2,
            								name = L["Name Style"],
            								hidden = TotNameHidden,
            								values = nameTags
            							},
            							totCStyle = {
            								type = 'input',
            								order = 3,
            								name = L["Custom Name Style"],
            								desc = L["If set this style will override Name Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"],
            								hidden = TotNameHidden,
            								usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],								
            							},
                                        totNSize = {
                                            type = 'range',
            								order = 4,
                                            name = L["Text Size"],
            								hidden = TotNameHidden,
                                            min = minfont,
                                            max = maxfont,
                                            step = 1,
                                        },
                                    },
                                },
                            },
                        },
						auras = {
							type = 'group',
							name = L["Auras"],
							order = 2,
							hidden = function ()
									return not db.tAuras;
								end,
							args = {
								tSwap = {
									type = 'toggle',
									order = 3,
									name = L["Swap Target Auras"],
									desc = L["Change Auras's side"],
									hidden = TNameHidden,
									disabled = TAurasEnable,
								},
								tTips = {
									type = 'toggle',
									order = 4,
									name = L["Show Aura Tips"],
									desc = L["Show/Hide"],
									hidden = TNameHidden,
									disabled = TAurasEnable,
								},
								tAurasCountColor = {
									order = 5,
									type =  'color',
									name = L["Counter Color"],
									get = ColorGetter3,
									set = ColorSetter3,
								},
								tAurasTimerColor = { 
									type = 'group',
									name = L["Timer Color"],
									order = 6,
									guiInline  = true,
									get = ColorGetter2,
									set = ColorSetter2,
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
								buffs = {
									type = "group",
									order = 7,
									name = L["Buffs"],
									args = {
										tBuffs = {
											type = 'toggle',
											order = 1,
											name = L["Show"],
											desc = L["Show/Hide"],
										},
										tBuffsOwn = {
											type = 'toggle',
											order = 2,
											name = L["Only mine"],
											desc = L["Only show buffs cast by me"],
										},
										tBuffTimer = {
											type = 'toggle',
											order = 2,
											name = L["Timer"],
											desc = L["Show/Hide Timer"],
										},
										tBuffCount = {
											type = 'range',
											order = 3,
											name = L["Number of Buffs"],
											min = 5,
											max = 40,
											step = 1,
										},
										tBuffsCols = {
											type = 'range',
											order = 4,
											name = L["Columns"],
											min = 3,
											max = 10,
											step = 1,
										},
										tBuffsSize = {
											type = 'range',
											order = 5,
											name = L["Size"],
											min = 20,
											max = 50,
											step = 2,
										},
									},
								},
								debuffs = {
									type = "group",
									order = 8,
									name = L["Debuffs"],
									args = {
										tDebuffs = {
											type = 'toggle',
											order = 1,
											name = L["Show"],
											desc = L["Show/Hide"],
										},
										tDebuffsOwn = {
											type = 'toggle',
											order = 2,
											name = L["Only mine"],
											desc = L["Only show debuffs applied by me"],
											hidden = TNameHidden,
										},
										tDebuffCount = {
											type = 'range',
											order = 3,
											name = L["Number of Debuffs"],
											min = 5,
											max = 40,
											step = 1,
										},
										tDebuffTimer = {
											type = 'toggle',
											order = 2,
											name = L["Timer"],
											desc = L["Show/Hide Timer"],
										},
										tDebuffsCols = {
											type = 'range',
											order = 4,
											name = L["Columns"],
											min = 3,
											max = 10,
											step = 1,
										},
										tDebuffsSize = {
											type = 'range',
											order = 5,
											name = L["Size"],
											min = 20,
											max = 50,
											step = 2,
										},
									},
								},
								
							},
						},
                        barText = {
    						type = 'group',
    						order = 3,
    						name = L["Bar's Text"],
                            desc = L["Configure Health and Power (mana/rage/energy/runic) text options"],
    						args = {
    							tBarText = {
    								type = 'multiselect',
    								order = 1,
    								name = L["Show Bar Values"],
    								values = { ["tBarHText"] = L["Health"], ["tBarPText"] = L["Power"] },
                                    get = SelectGetter,
                                    set = SelectSetter,
    							},
    							tHStyle = {
    								type = 'select',
    								order = 2,
    								name = L["Health Style"],
    								hidden = BarTextHidden,
    								values = healthTags
    								},
    							tCHStyle = {
    								type = 'input',
    								order = 3,
    								name = L["Custom Health Style"],
    								desc = L["If set this style will override Health Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"],
    								hidden = BarTextHidden,
    								usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
    							},
    							tPStyle = {
    								type = 'select',
    								order = 4,
    								name = L["Power Style"],
    								hidden = BarTextHidden,
    								values = powerTags
    								},
    							tCPStyle = {
    								type = 'input',
    								order = 5,
    								name = L["Custom Power Style"],
    								desc = L["If set this style will override Power Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Power Style setting.)"],
    								hidden = BarTextHidden,
    								usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],								
    							},
    							tBarTextSize = {
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
                        tColors = {
    						type = 'group',
    						order = 4,
    						name = L["Bar Colors"],
                            get = ColorGetter,
                            set = ColorSetter,
    						hidden = TBarsHidden,
    						args = {
    		                    ["7"] = {
    		                        type = 'group',
    								guiInline  = true,
    		                        name = L["Health"],
    								order = 1,
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
    								guiInline  = true,
    		                        name = L["Mana"],
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
    								guiInline  = true,
    		                        name = L["Rage"],
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
    								guiInline  = true,
    		                        name = L["Energy"],
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
    								guiInline  = true,
    		                        name = L["Runic Power"],
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
                                ["8"] = {
                                    type = 'group',
    								guiInline  = true,
                                    name = L["Tapped"],
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
    				},
                },
            }
        }
    end
    
    return options;
end

-- Local Functions
local blizzFrames, ConfigBars, PlaceBarTexts, UpdateTargetAuras, HideTargetAuras, UpdateTargetElite, TargetDropDownInit, PlayerDropDownInit, HideTargetAuras, SwapVehicle, UpdatePlayerPvP, OnBarShow, OnBarHide, UpdateTargetPvP
do
    -- Asing each bar the their respective tracking stat accordingly to the saved profile
    function ConfigBars()
        --DHUD3:Debug("ConfigBars");
        -- Player Bars
    	if string_match(db.player, "c") then
    		if string_match(db.pLayout, "HLPR") then
                playerLayout.pHealth = "li";
                playerLayout.pPower = "ri";
                Player.auraSide = "r";
                playerLayout.tHealth = "lm";
                playerLayout.tPower = "rm";
                playerLayout.pIcons = "l";
                playerLayout.tIcons = "r";
    		else
                playerLayout.pHealth = "ri";
                playerLayout.pPower = "li";
                Player.auraSide = "l";
                playerLayout.tHealth = "rm";
                playerLayout.tPower = "lm";
                playerLayout.pIcons = "r";
                playerLayout.tIcons = "l";
    		end
    	elseif string_match(db.player, "l") then
            playerLayout.pIcons = "l";
            Player.auraSide = "l";
            playerLayout.tIcons = "r";
    	    if string_match(db.pLayout, "HIPM") then
                playerLayout.pHealth = "li";
                playerLayout.pPower = "lm";
                playerLayout.tHealth = "ri";
                playerLayout.tPower = "rm";
    		else
                playerLayout.pHealth = "lm";
                playerLayout.pPower = "li";
                playerLayout.tHealth = "rm";
                playerLayout.tPower = "ri";
            end
    	else
    		playerLayout.pIcons = "r";
            Player.auraSide = "r";
            playerLayout.tIcons = "l";
    	    if string_match(db.pLayout, "HIPM") then
                playerLayout.pHealth = "ri";
                playerLayout.pPower = "rm";
                playerLayout.tHealth = "li";
                playerLayout.tPower = "lm";
    		else
                playerLayout.pHealth = "rm";
                playerLayout.pPower = "ri";
                playerLayout.tHealth = "lm";
                playerLayout.tPower = "li";
            end
        end
    	
    	--Bars Text Tag
    	if db.pBarHText then
            _G["DHUD3_"..playerLayout.pHealth.."_Text"]:Show();
    		local tagCode = (string_len(db.pCHStyle) > 0) and db.pCHStyle or db.pHStyle;
    		DogTag:AddFontString(_G["DHUD3_"..playerLayout.pHealth.."_Text_Text"], _G["DHUD3_"..playerLayout.pHealth.."_Text"], tagCode, "Unit", { unit = "player" } );
        else
            DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.pHealth.."_Text_Text"]);
            _G["DHUD3_"..playerLayout.pHealth.."_Text"]:Hide();
    	end
    	if db.pBarPText then
            _G["DHUD3_"..playerLayout.pPower.."_Text"]:Show();
    		local tagCode = (string_len(db.pCPStyle) > 0) and db.pCPStyle or db.pPStyle;
    		DogTag:AddFontString(_G["DHUD3_"..playerLayout.pPower.."_Text_Text"], _G["DHUD3_"..playerLayout.pPower.."_Text"], tagCode, "Unit", { unit = "player" });
        else
            DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.pPower.."_Text_Text"]);
            _G["DHUD3_"..playerLayout.pPower.."_Text"]:Hide();
    	end
        
        
    	if db.tBarHText then
            _G["DHUD3_"..playerLayout.tHealth.."_Text"]:Show();
    		local tagCode = (string_len(db.tCHStyle) > 0) and db.tCHStyle or db.tHStyle;
    		DogTag:AddFontString(_G["DHUD3_"..playerLayout.tHealth.."_Text_Text"], _G["DHUD3_"..playerLayout.tHealth.."_Text"], tagCode, "Unit", { unit = "target" } );
        else
            DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.tHealth.."_Text_Text"]);
            _G["DHUD3_"..playerLayout.tHealth.."_Text"]:Hide();
    	end
    	if db.tBarPText then
            _G["DHUD3_"..playerLayout.tPower.."_Text"]:Show();
    		local tagCode = (string_len(db.tCPStyle) > 0) and db.tCPStyle or db.tPStyle;
    		DogTag:AddFontString(_G["DHUD3_"..playerLayout.tPower.."_Text_Text"], _G["DHUD3_"..playerLayout.tPower.."_Text"], tagCode, "Unit", { unit = "target" });
        else
            DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.tPower.."_Text_Text"]);
            _G["DHUD3_"..playerLayout.tPower.."_Text"]:Hide();
    	end
    end
	
	--Config Auras
	function ConfigAuras(side, count, size, cols)
		
		--DHUD3:Debug("ConfigAuras", side, count, size, cols);
		local point, parent, relative, x, y;
		local frame = "DHUD3_T"..side.."A";
		local scale = DHUD3.GetScale();
		if side == "R" then
			relative = "RIGHT";
			point = "LEFT";
		else
			relative = "LEFT";
			point = "RIGHT";
		end
		for i = 1, count do
			if i == 1 then
				parent = "DHUD3_target_Text";
				x = 5;
				y = 0;
			else
				local j = (i-1) % cols;
				if j == 0 then
					-- New line
					parent = frame..tonumber((cols * (math.floor(i/cols) - 1))+1);
					x = size;
					y = -size;
				else
					parent = frame..tonumber(i-1);
					x = 1;
					y = 0;
				end
			end
			if side == "R" then
				x = x * -1;
			end
			--Borders
			_G[frame..i.."_Border"]:SetHeight(size);
			_G[frame..i.."_Border"]:SetWidth(size);
			--Texts
				--Count
			local font = _G[frame..i.."_CountText"];		
			font:ClearAllPoints();
			font:SetPoint("BOTTOMRIGHT", frame..i, "BOTTOMRIGHT", -size/10, size/10);
			font:SetFont(DHUD3:GetFont(), (size/2) * scale);
			font:SetWidth(size);
			font:SetJustifyH("RIGHT");
			font:SetAlpha(0.8);
			local r,g,b = unpack(db.tAurasCountColor);
			font:SetTextColor(r, g, b);
			font:SetText("");
				--Cooldown
			font = _G[frame..i.."_TimerText"];
			font:ClearAllPoints();
			font:SetPoint("CENTER", frame..i, "CENTER", 0, 0);
			font:SetFont(DHUD3:GetFont(), (size/1.3) * scale);
			font:SetWidth(size);
			font:SetJustifyH("CENTER");
			font:SetText("");
			--Frame
			_G[frame..i]:SetHeight(size);
			_G[frame..i]:SetWidth(size);
			_G[frame..i]:SetParent(parent);
			_G[frame..i]:ClearAllPoints();
			_G[frame..i]:SetPoint(point, parent, relative, x, y);
		end	
	end

    -- Update target auras
    function UpdateTargetAuras()
		
		--DHUD3:Debug("UpdateTargetAuras");
        local buffBorder, buffText, buffFrame;
        local debuffBorder, debuffText, debuffFrame;
        
    	if not db.tSwap then
    		buffFrame   = "DHUD3_TRA";
    		debuffFrame = "DHUD3_TLA";
    	else
    		buffFrame   = "DHUD3_TLA";    
    		debuffFrame = "DHUD3_TRA";
    	end
        local name, texture, count, duration, expirationTime, caster, button;
    	-- Buffs
		if db.tBuffs then
	    	for i = 1, db.tBuffCount do
	    		button = _G[buffFrame..i]
				name, _, texture, count, _, duration, expirationTime, caster = UnitBuff("target", i);
				if ( name and ( not (db.tBuffsOwn and (caster ~= "player")) ) ) then
	                button.id = i;
					button.aura = "HELPFUL";
	    			button:SetNormalTexture(texture);
	    			_G[buffFrame..i.."_Border"]:Hide();
	    			if ( count > 1 ) then
	    				_G[buffFrame..i.."_CountText"]:SetText(count);
						_G[buffFrame..i.."_CountText"]:Show();
	    			else
	    				_G[buffFrame..i.."_CountText"]:Hide();
	    			end
	    			button:Show();
					button:SetScript("OnUpdate", nil);
					_G[buffFrame..i.."_TimerText"]:SetText("");
					if ( duration > 0  and db.tBuffTimer) then
						local timeLeft = expirationTime - GetTime();
						if ( timeLeft > 0 ) then
							button.auraTimer = 0;
							button.left = timeLeft;
							button:SetScript("OnUpdate", OnUpdateAura);
							if ( timeLeft <= 30 ) then
								_G[buffFrame..i.."_TimerText"]:SetText(math.floor(timeLeft));
							end
						end
					end
	    		else    
	    			button:Hide();
	    		end
	    	end
		end
    	
    	-- DeBuffs
		if db.tDebuffs then
	    	for i = 1, db.tDebuffCount do
	    		local button = _G[debuffFrame..i];
				name, _, texture, count, _, duration, expirationTime, caster = UnitDebuff("target", i);
				if ( name and ( not (db.tDebuffsOwn and (caster ~= "player")) ) ) then
	                button.id = i;
					button.aura = "HARMFUL";
	    			button:SetNormalTexture(texture);
	    			_G[debuffFrame..i.."_Border"]:Show()
	    			if ( count > 1 ) then
	    				_G[debuffFrame..i.."_CountText"]:SetText(count)
						_G[debuffFrame..i.."_CountText"]:Show();
	                else
	    				_G[debuffFrame..i.."_CountText"]:Hide();
	    			end
	    			button:Show();
					button:SetScript("OnUpdate", nil);
					_G[debuffFrame..i.."_TimerText"]:SetText("");
					if ( duration > 0 and db.tDebuffTimer) then
						local timeLeft = expirationTime - GetTime();
						if ( timeLeft > 0 ) then
							button.auraTimer = 0;
							button.left = timeLeft;
							button:SetScript("OnUpdate", OnUpdateAura);
							if ( timeLeft <= 30 ) then
								_G[debuffFrame..i.."_TimerText"]:SetText(math.floor(timeLeft));
							end
						end
					end
	    		else
	    			button:Hide();
	    		end
	        end
		end
    end
	
	function OnUpdateAura(event, elapsed)
	
	    this.auraTimer = this.auraTimer + elapsed;          
		if this.auraTimer >= auraUpdateInterval then
			this.left = this.left - this.auraTimer;
			if this.left <= 0 then
				this.id = 0;
				this:SetScript("OnUpdate", nil);
				return this:Hide();
			end
			this.auraTimer = 0;
			if this.left <= 30 then
				local buffText = _G[this:GetName().."_TimerText"];
				local r, g, b, hex = DHUD3:Colorize(db.tAurasTimerColor, this.left / 30);
				buffText:SetText(math.floor(this.left));
				buffText:SetTextColor(r, g, b);			
			end
		end
	end
	
	-- Hide all target auras
	function HideTargetAuras()
		for i = 1, 40 do
			_G["DHUD3_TLA"..i]:Hide();
			_G["DHUD3_TRA"..i]:Hide();
		end		
	end

	-- Show targets Elite icon
    function UpdateTargetElite(show)
    	local elite = UnitClassification("target")
    	local texture = ""
        if elite and show then
            --local images = self.layout.icons
    		if elite == "worldboss" then
    			texture = "Interface\\AddOns\\DHUD3\\textures\\elite"
    		elseif elite == "rareelite" then
    			texture = "Interface\\AddOns\\DHUD3\\textures\\rareelite"
    		elseif elite == "rare" then
    			texture = "Interface\\AddOns\\DHUD3\\textures\\rare"
    		elseif elite == "elite" then
    			texture = "Interface\\AddOns\\DHUD3\\textures\\elite"
    		elseif elite == "normal" then
    			texture = ""
    		elseif elite == "trivial" then
    			texture = ""
    		else
    			texture = ""
    		end
    		_G["DHUD3_"..playerLayout.tIcons.."telite"]:SetNormalTexture(texture);
    		_G["DHUD3_"..playerLayout.tIcons.."telite"]:Show()
    	else
    		_G["DHUD3_"..playerLayout.tIcons.."telite"]:Hide()
    	end
    end
    
    --Initialize the target dropdown menu, taken from blizz code.
    function TargetDropDownInit(self)
	
        local menu;
    	local name;
    	local id = nil;
    	if ( UnitIsUnit("target", "player") ) then
    		menu = "SELF";
    	elseif ( UnitIsUnit("target", "vehicle") ) then
    		-- NOTE: vehicle check must come before pet check for accuracy's sake because
    		-- a vehicle may also be considered your pet
    		menu = "VEHICLE";
    	elseif ( UnitIsUnit("target", "pet") ) then
    		menu = "PET";
    	elseif ( UnitIsPlayer("target") ) then
    		id = UnitInRaid("target")
    		if ( id ) then
    			menu = "RAID_PLAYER";
    			name = GetRaidRosterInfo(id +1);
    		elseif ( UnitInParty("target") ) then
    			menu = "PARTY";
    		else
    			menu = "PLAYER";
    		end
    	else
    		menu = "RAID_TARGET_ICON";
    		name = RAID_TARGET_ICON;
    	end
    	if ( menu ) then
    		UnitPopup_ShowMenu(self, menu, "target", name, id);
    	end
    end

    -- Initialize the target dropdown menu, taken from blizz code.
    function PlayerDropDownInit(self)
		
		--DHUD3:Debug("PlayerDropDownInit");
        UnitPopup_ShowMenu(self, "SELF", "player");
    end
	
	function SwapVehicle(swap)
	
	    local maxVal, curFrac,needH, needP;
	    local color = {r=0,g=0,b=0,hex=""};
	    if swap then
	        who = "vehicle";
	    else
	        who = "player";
	    end
		--DHUD3:Debug("SwapVehicle", swap, who);
		
        --Health
        DHUD3:SetBarsStat(who, playerLayout.pHealth, "h", db.pColors);
        --Power
        DHUD3:SetBarsStat(who, playerLayout.pPower, "p", db.pColors);
		
		--Bars Text Tag
		if db.pBarHText then
			DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.pHealth.."_Text_Text"]);
			local tagCode = (string_len(db.pCHStyle) > 0) and db.pCHStyle or db.pHStyle;
			DogTag:AddFontString(_G["DHUD3_"..playerLayout.pHealth.."_Text_Text"], _G["DHUD3_"..playerLayout.pHealth.."_Text_Text"], tagCode, "Unit", { unit = who} );
		end
		if db.pBarPText then
			DogTag:RemoveFontString(_G["DHUD3_"..playerLayout.pPower.."_Text_Text"]);
			local tagCode = (string_len(db.pCPStyle) > 0) and db.pCPStyle or db.pPStyle;
			DogTag:AddFontString(_G["DHUD3_"..playerLayout.pPower.."_Text_Text"], _G["DHUD3_"..playerLayout.pPower.."_Text_Text"], tagCode, "Unit", { unit = who });
		end
	end
	
	function UpdatePlayerPvP()
		local texture = nil;
	    if ( db.pvpIcon ) then
			texture = GetPvPTexture("player");
			if ( texture ) then
				_G["DHUD3_"..playerLayout.pIcons.."pvp"]:SetNormalTexture(texture);
				_G["DHUD3_"..playerLayout.pIcons.."pvp"]:Show();
			else
				_G["DHUD3_"..playerLayout.pIcons.."pvp"]:Hide();
			end
	    end
	end
	
	function UpdateTargetPvP()
		--DHUD3:Debug("Player UpdateTargetPvP", db.tName, db.tPvpIcon); 
		local texture = nil;
	    if ( db.tName and db.tPvpIcon ) then
	        texture = GetPvPTexture("target");
			if ( texture ) then
		        DHUD3_targetPvP:SetNormalTexture(texture);
		        DHUD3_targetPvP:Show();
		    else
		        DHUD3_targetPvP:Hide();
		    end
		end
	end
	
	function GetPvPTexture(unit)
		if ( UnitIsPVPFreeForAll(unit) ) then
			return "Interface\\TargetingFrame\\UI-PVP-FFA";
		elseif ( UnitIsPVP(unit) ) then 
			local faction = UnitFactionGroup(unit);
			if ( faction == "Horde" ) then
				return "Interface\\TargetingFrame\\UI-PVP-Horde";
			else
				return "Interface\\TargetingFrame\\UI-PVP-Alliance";
			end
		end
	end

	function OnBarShow(this, event)
	
		--DHUD3:Debug("OnBarShow", this, event);
		DHUD3:SendMessage("DHUD3_BAR_SHOW", this.bar);
	end
	
	function OnBarHide(this, event)
	
		--DHUD3:Debug("OnBarHide", this, event);
		DHUD3:SendMessage("DHUD3_BAR_HIDE", this.bar);
	end
end

function Player:OnInitialize()
	self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, GetOptions, L["Player"]);
    
    
    local icons = DHUD3.layout.icons;
    local bars = DHUD3.layout.playerBars;
    local barText = DHUD3.layout.playerText;
    local texts = DHUD3.layout.texts;
    local tRA = DHUD3.layout.targetRightAuras;
    local tLA = DHUD3.layout.targetLeftAuras;
    local point, parent, relative, x, y, width, height, position, texture, border;
    
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
        ref:Hide();
		ref:SetScript("OnShow", OnBarShow);
		ref:SetScript("OnHide", OnBarHide);
		ref:EnableMouse(false);
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

    -- Text
    for k, v in pairs(texts) do
        point, parent, relative, x, y, width, height = unpack(v);
        ref = CreateFrame("Button", "DHUD3_"..k.."_Text", _G["DHUD3_"..parent], "SecureActionButtonTemplate");
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, x, y);
        local font = ref:CreateFontString("DHUD3_"..k.."_Text_Text", "OVERLAY");
        font:SetFontObject(GameFontHighlightSmall);
        font:ClearAllPoints();
        font:SetPoint("CENTER", ref, "CENTER", 0, 0);
        font:SetText(k);
        font:SetJustifyH("CENTER");
		font:SetJustifyV("BOTTOM");
        font:SetWidth(330);
        font:Show();
        ref:SetHeight(height);
        ref:SetWidth(350);
        ref:Hide();
    end
    
    -- Icons
    for k, v in pairs(icons) do
        point, parent, relative, x, y, width, height = unpack(v);
        ref = CreateFrame("Button", "DHUD3_"..k, _G["DHUD3_"..parent]);
        ref:ClearAllPoints();
        ref:SetPoint(point, _G["DHUD3_"..parent], relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        if k == "rpvp" or k == "lpvp" then
			ref:SetScript("OnEnter", function(this)
                if not ( this:IsVisible() )  or ( this:GetEffectiveAlpha() == 0 ) then
					return;
				end
				local left = GetPVPTimer();
                local text;
                if ( left == 301000 ) then
                    text = "PvP On";
                else
                    text = DHUD3:FormatTime(left/1000);
                end
                if playerLayout.pIcons == "r" then 
                    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                else
                    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT");
                end
                GameTooltip:SetText(text, 1, 0, 0);
            end )
			ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end )
		end
        ref:Hide();
    end
	
	--Target PvP
	ref = CreateFrame("Button", "DHUD3_targetPvP", DHUD3_target_Text);
	ref:ClearAllPoints();
	ref:SetPoint("CENTER", DHUD3_target_Text, "BOTTOM", 0, 20);
	ref:SetHeight(40);
	ref:SetWidth(40);
    
    -- Target Auras
    for i = 1, 40 do
        point, parent, relative, x, y, width, height = unpack(tRA["TRA"..i]);		
		ref = CreateFrame("Button", "DHUD3_TRA"..i, _G["DHUD3_"..parent]);
        ref:SetHeight(height);
        ref:SetWidth(width);
        local font = ref:CreateFontString("DHUD3_TRA"..i.."_CountText", "OVERLAY");
		font = ref:CreateFontString("DHUD3_TRA"..i.."_TimerText", "OVERLAY");
        bgt = ref:CreateTexture("DHUD3_TRA"..i.."_Border", "ARTWORK");
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("CENTER", ref, "CENTER", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0, 1, 0, 1);
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetScript("OnEnter", function(this)
                if not ( this:IsVisible() )  or ( this:GetEffectiveAlpha() == 0 ) then
					return;
				end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
				GameTooltip:SetUnitAura("target", this.id, this.aura);
            end )
        ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end )
        ref:Hide();
    end
    
    for i = 1, 40 do
        point, parent, relative, x, y, width, height = unpack(tLA["TLA"..i]);
        ref = CreateFrame("Button", "DHUD3_TLA"..i, _G["DHUD3_"..parent]);
        ref:SetHeight(height);
        ref:SetWidth(width);
        font = ref:CreateFontString("DHUD3_TLA"..i.."_CountText", "ARTWORK");
		font = ref:CreateFontString("DHUD3_TLA"..i.."_TimerText", "OVERLAY");
        bgt = ref:CreateTexture("DHUD3_TLA"..i.."_Border","OVERLAY");
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("BOTTOM", ref, "BOTTOM", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0, 1, 0, 1);
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetScript("OnEnter", function(this)
                if not ( this:IsVisible() )  or ( this:GetEffectiveAlpha() == 0 ) then
					return;
				end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
                GameTooltip:SetUnitAura("target", this.id, this.aura);
            end )
        ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end )        
        ref:Hide();
    end
    
    -- Player/Target Dropdown
    ref = CreateFrame("Button", "DHUD3_targetDropDown", _G[UIParent], "UIDropDownMenuTemplate");
    ref:ClearAllPoints();
    ref:SetPoint("TOP", _G[UIParent], "CENTER", 10, -60);
    ref:SetWidth(10);
    ref:SetHeight(10);    
    ref:Hide();
    
    ref = CreateFrame("Button", "DHUD3_playerDropDown", _G[UIParent], "UIDropDownMenuTemplate");
    ref:ClearAllPoints();
    ref:SetPoint("TOP", _G[UIParent], "CENTER", 10, -60);
    ref:SetWidth(10);
    ref:SetHeight(10);
    ref:Hide();
    
    -- Configure Right click funtionality
    --DHUD3_target_Text:RegisterForClicks('RightButtonUp');
    DHUD3_target_Text:SetAttribute("type2", "menu");
    local showmenu = function()
                ToggleDropDownMenu(1, nil, DHUD3_targetDropDown, "DHUD3_target_Text", 120, 10)
            end
    DHUD3_target_Text.menu = showmenu;
    
    -- Enable targettarget click to target
    DHUD3_targetTarget_Text:SetAttribute("unit", "targetTarget");
    DHUD3_targetTarget_Text:SetAttribute("type1", "target");
end

function Player:OnEnable()
    
	--DHUD3:Debug("Player:OnEnable");	
    self:Refresh();
	if not self:IsEnabled() then return end
    DHUD3_lrest:SetNormalTexture("Interface\\AddOns\\DHUD3\\textures\\rest");
    DHUD3_rrest:SetNormalTexture("Interface\\AddOns\\DHUD3\\textures\\rest");
    DHUD3_lleader:SetNormalTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
	DHUD3_rleader:SetNormalTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
	DHUD3_llooter:SetNormalTexture("Interface\\GroupFrame\\UI-Group-MasterLooter");
	DHUD3_rlooter:SetNormalTexture("Interface\\GroupFrame\\UI-Group-MasterLooter");
	DHUD3_lcombat:SetNormalTexture("Interface\\AddOns\\DHUD3\\textures\\combat");
	DHUD3_rcombat:SetNormalTexture("Interface\\AddOns\\DHUD3\\textures\\combat");
    
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", Player.PartyLeader);
    self:RegisterEvent("PARTY_LEADER_CHANGED", Player.PartyLeader);
    self:RegisterEvent("PLAYER_UPDATE_RESTING");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("RAID_TARGET_UPDATE");
    self:RegisterEvent("UNIT_FACTION");
    UIDropDownMenu_Initialize(DHUD3_targetDropDown, TargetDropDownInit, "MENU");
	UIDropDownMenu_Initialize(DHUD3_playerDropDown, PlayerDropDownInit, "MENU");
end

function Player:OnDisable()
    
	self:SendMessage("DHUD3_TARGETBARS_HIDE");
    self:UnregisterAllEvents();
    DHUD3_li:Hide();
    DHUD3_lm:Hide();
    DHUD3_ri:Hide();
    DHUD3_rm:Hide();
    DHUD3_li:SetScript("OnUpdate", nil);
    DHUD3_lm:SetScript("OnUpdate", nil);
    DHUD3_ri:SetScript("OnUpdate", nil);
    DHUD3_rm:SetScript("OnUpdate", nil);
    DHUD3_lpvp:Hide();
	DHUD3_rpvp:Hide();
    DHUD3_lleader:Hide();
	DHUD3_llooter:Hide();
	DHUD3_lcombat:Hide();
	DHUD3_ltelite:Hide();
	DHUD3_rleader:Hide();
	DHUD3_rlooter:Hide();
	DHUD3_rcombat:Hide();
	DHUD3_rtelite:Hide();
	DHUD3_lrest:Hide();
    DHUD3_rrest:Hide();
end

function Player:Refresh()
	
	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile
	if not self:IsEnabled() then return end
	
	--BlizzFrames
	if ( not db.blizPlayer and PlayerFrame:IsShown() ) then
		PlayerFrame:UnregisterAllEvents();
		ComboFrame:UnregisterAllEvents();
		ComboFrame:Hide();
	    PlayerFrame:Hide();
	end
	if ( not db.blizTarget ) then
		TargetFrame:UnregisterAllEvents();
		TargetofTargetFrame:UnregisterAllEvents();
	    TargetFrame:Hide();
	end
	
	DHUD3:PlaceBarTexts("playerText");
	local maxVal, curFrac,needH, needP;
    local color = {r=0,g=0,b=0,hex=""};
    DHUD3_li:SetScript("OnUpdate", nil);
    DHUD3_lm:SetScript("OnUpdate", nil);
    DHUD3_ri:SetScript("OnUpdate", nil);
    DHUD3_rm:SetScript("OnUpdate", nil);
	DHUD3_li:Hide();
    DHUD3_lm:Hide();
    DHUD3_ri:Hide();
    DHUD3_rm:Hide();
    
	ConfigBars();
    -- Fonts
    local font
    local w
    --Targer Text
    local scale = DHUD3.GetScale();
    DHUD3_target_Text_Text:SetFont(DHUD3:GetFont(), db.tNSize * scale)  
    --Targer Target Text
    DHUD3_targetTarget_Text_Text:SetFont(DHUD3:GetFont(), db.totNSize * scale)
    --Player Bar's Text
    font = _G["DHUD3_"..playerLayout.pHealth.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.pBarTextSize * scale)
    font:SetWidth(200)
    font = _G["DHUD3_"..playerLayout.pPower.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.pBarTextSize * scale)
    font:SetWidth(200)
    
    -- Target Bar's Text
    font = _G["DHUD3_"..playerLayout.tHealth.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.tBarTextSize * scale)
    font:SetWidth(200)
    font = _G["DHUD3_"..playerLayout.tPower.."_Text_Text"]
    font:SetFont(DHUD3:GetFont(), db.tBarTextSize * scale)
    font:SetWidth(200)
    
    -- Player
    Player:RegisterEvent("PLAYER_TARGET_CHANGED");
    -- Health
    DHUD3:SetBarsStat("player", playerLayout.pHealth, "h", db.pColors);
    -- Power
    DHUD3:SetBarsStat("player", playerLayout.pPower, "p", db.pColors);
    
    -- Status: Rest, PvP, Leader, Looter
    DHUD3_lrest:Hide();
    DHUD3_rrest:Hide();
	DHUD3_lpvp:Hide();
	DHUD3_rpvp:Hide();
    DHUD3_lleader:Hide();
	DHUD3_llooter:Hide();
	DHUD3_lcombat:Hide();
	DHUD3_ltelite:Hide();
	DHUD3_rleader:Hide();
	DHUD3_rlooter:Hide();
	DHUD3_rcombat:Hide();
	DHUD3_rtelite:Hide();
	
	if IsResting() and db.restIcon then
        _G["DHUD3_"..playerLayout.pIcons.."rest"]:Show();
    end
    UpdatePlayerPvP();
	if ( GetNumPartyMembers() > 0 and db.leaderIcon ) then
        if ( UnitIsPartyLeader("player") ) then
            _G["DHUD3_"..playerLayout.pIcons.."leader"]:Show();
            local lootmethod = GetLootMethod();
            if ( lootmethod == "master" ) then
                _G["DHUD3_"..playerLayout.pIcons.."looter"]:Show();
            end
        end
    end
    
    -- Target & Target of Target
		-- Target Auras Layout
	local buffFrame, debuffFrame;
	HideTargetAuras();
	if not db.tSwap then
		buffFrame = "DHUD3_TRA";
		ConfigAuras("R", db.tBuffCount, db.tBuffsSize, db.tBuffsCols);
		debuffFrame = "DHUD3_TLA";
		ConfigAuras("L", db.tDebuffCount, db.tDebuffsSize, db.tDebuffsCols);
	else
		buffFrame = "DHUD3_TLA";    
		ConfigAuras("L", db.tBuffCount, db.tBuffsSize, db.tBuffsCols);
		debuffFrame = "DHUD3_TRA";
		ConfigAuras("R", db.tDebuffCount, db.tDebuffsSize, db.tDebuffsCols);
	end
	
		-- Target and TargetofTarget Tags
	if ( db.tName ) then
		_G["DHUD3_target_Text"]:Show();
		_G["DHUD3_target_Text"]:SetAlpha(0);
		local tagCode = (string_len(db.tCStyle) > 0) and db.tCStyle or db.tStyle;
		DogTag:AddFontString(_G["DHUD3_target_Text_Text"], _G["DHUD3_target_Text"], tagCode, "Unit", { unit = "target" } );
	else
		DogTag:RemoveFontString(_G["DHUD3_target_Text_Text"]);
		_G["DHUD3_target_Text"]:Hide();
	end
	if ( db.totName ) then
		_G["DHUD3_targetTarget_Text"]:Show();
		_G["DHUD3_targetTarget_Text"]:SetAlpha(0);
		local tagCode = (string_len(db.totCStyle) > 0) and db.totCStyle or db.totStyle;
		DogTag:AddFontString(_G["DHUD3_targetTarget_Text_Text"], _G["DHUD3_targetTarget_Text"], tagCode, "Unit", { unit = "targettarget" } );
	else
		DogTag:RemoveFontString(_G["DHUD3_targetTarget_Text_Text"]);
		_G["DHUD3_targetTarget_Text"]:Hide();
	end
	
    if ( UnitExists("target") ) then
		--DHUD3:Debug("Player Refreshm target exists");
        self:PLAYER_TARGET_CHANGED();
    end
	
    -- Pet Swap
    if db.swapPet then
        self:RegisterEvent("UNIT_ENTERED_VEHICLE");
        self:RegisterEvent("UNIT_EXITED_VEHICLE");
        if ( UnitInVehicle("player") ) then
            SwapVehicle(true);
        end
    else
        self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
        self:UnregisterEvent("UNIT_EXITED_VEHICLE");
    end
	
	
	--Click Trough
	--DHUD3:Debug("Click Through", db.click);
	local barText = DHUD3.layout.playerText;
	local icons = DHUD3.layout.icons;
	local texts = DHUD3.layout.texts;
	-- Bars Text
	for k, v in pairs(barText) do
		_G["DHUD3_"..k.."_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..k.."_Text"]:SetMovable(not db.click);
	end
	-- Icons
	DHUD3_rpvp:EnableMouse(not db.click);
	DHUD3_lpvp:EnableMouse(not db.click);
	-- Target Auras
	for i = 1, 40 do
		_G["DHUD3_TRA"..i]:EnableMouse((not db.click) and db.tTips);
		_G["DHUD3_TLA"..i]:EnableMouse((not db.click) and db.tTips);
	end
	--Target Text
	DHUD3_target_Text:RegisterForClicks(db.click and "" or "RightButtonUp");
	DHUD3_targetTarget_Text:RegisterForClicks(db.click and "" or "LeftButtonUp");
end

function Player:PLAYER_TARGET_CHANGED()

    --DHUD3:Debug("PLAYER_TARGET_CHANGED")
    local maxVal, curFrac, typ;
    local color = {r=0,g=0,b=0,hex=""};
    
    if ( UnitExists("target") and db.tBars and not ( DHUD3:UnitIsNPC("target") and not db.tNPC ) ) then
        local healthTyp, powerTyp = 7, UnitPowerType("target");
        --Health
        DHUD3:SetBarsStat("target", playerLayout.tHealth, "h", db.tColors);
        --Power
        DHUD3:SetBarsStat("target", playerLayout.tPower, "p", db.tColors);
        if ( db.tName ) then
            _G["DHUD3_target_Text"]:SetAlpha(1);
			self:RegisterEvent("UNIT_TARGET");
            if ( UnitExists("targettarget") and db.totName ) then
                _G["DHUD3_targetTarget_Text"]:SetAlpha(1);
            else
                _G["DHUD3_targetTarget_Text"]:SetAlpha(0);
            end
        else
            _G["DHUD3_target_Text"]:SetAlpha(0);
        end
		if ( db.tAuras ) then 
			UpdateTargetAuras();
			self:RegisterEvent("UNIT_AURA");
		end
        UpdateTargetElite(db.tEliteIcon);
        DHUD3:UpdateAlpha(2, true);
    else		
		DHUD3:RemoveBarStat(playerLayout.tHealth);
        DHUD3:RemoveBarStat(playerLayout.tPower);
		_G["DHUD3_target_Text"]:SetAlpha(0);
		_G["DHUD3_targetTarget_Text"]:SetAlpha(0);
        UpdateTargetElite(false);
        self:UnregisterEvent("UNIT_AURA");
        HideTargetAuras();
        DHUD3:UpdateAlpha(2, false);
    end
	self:RAID_TARGET_UPDATE();
	if not DHUD3_raid:IsShown() then
		UpdateTargetPvP();
	end
    
end

function Player:UNIT_TARGET(event, who)
	
	--DHUD3:Debug("Player:UNIT_TARGET", who);
	if ( who == "target" ) then
		if ( UnitExists("targettarget") and db.totName ) then
			_G["DHUD3_targetTarget_Text"]:SetAlpha(1);
		else
			_G["DHUD3_targetTarget_Text"]:SetAlpha(0);
		end
	end
end

function Player:PartyLeader()

    --DHUD3:Debug("PLAYER_FLAGS_CHANGED", UnitIsPartyLeader("player"), GetPartyLeaderIndex()) 
    if ( IsPartyLeader() ) then
		 _G["DHUD3_"..playerLayout.pIcons.."leader"]:Show();
	else
		 _G["DHUD3_"..playerLayout.pIcons.."leader"]:Hide();
	end
	local lootMethod;
	local lootMaster;
	lootMethod, lootMaster = GetLootMethod();
	if ( lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
		_G["DHUD3_"..playerLayout.pIcons.."looter"]:Show();
	else
		_G["DHUD3_"..playerLayout.pIcons.."looter"]:Hide();
	end
end

function Player:RAID_TARGET_UPDATE()
    
    if ( db.tName and db.tRaidIcon ) then
		local index = GetRaidTargetIndex("target");
		if ( index ) then
			if ( index > 0 and index <= 8 ) then
				DHUD3_raid:SetNormalTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..index);
				DHUD3_raid:Show();
			else
				DHUD3_raid:Hide();
			end
		else
			DHUD3_raid:Hide();
		end
    else
        DHUD3_raid:Hide();
    end
end

function Player:PARTY_LOOT_METHOD_CHANGED()

    --DHUD3:Debug("PARTY_LOOT_METHOD_CHANGED")
    local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
			_G["DHUD3_"..playerLayout.pIcons.."looter"]:Show();
		else
			_G["DHUD3_"..playerLayout.pIcons.."looter"]:Hide();
		end
end

function Player:PLAYER_UPDATE_RESTING()

    ----self:Debug("PLAYER_UPDATE_RESTING")
    if ( IsResting() and db.restIcon ) then
        _G["DHUD3_"..playerLayout.pIcons.."rest"]:Show();
    else
        _G["DHUD3_"..playerLayout.pIcons.."rest"]:Hide();
    end
end

function Player:UNIT_AURA(event, who)

	----self:Debug("UNIT_AURA", who)
    if ( who == "target" ) then
	    UpdateTargetAuras();
    end
end

function Player:UNIT_FACTION(event, who)

    if ( who == "player" ) then
        UpdatePlayerPvP();
	elseif ( who == "target" ) then
		UpdateTargetPvP();
    end
end

function Player:UNIT_ENTERED_VEHICLE(event, who)
	
	--DHUD3:Debug("UNIT_ENTERED_VEHICLE");
    if who == "player" then
        if ( UnitInVehicle("player") ) then
            SwapVehicle(true);
        end
    end
end

function Player:UNIT_EXITED_VEHICLE(event, who)
	
	--DHUD3:Debug("UNIT_EXITED_VEHICLE");
    if ( who == "player" ) then
        SwapVehicle(false);
    end
end

function Player:PLAYER_REGEN_ENABLED()
    
	--DHUD3:Debug("PLAYER_REGEN_ENABLED")
    _G["DHUD3_"..playerLayout.pIcons.."combat"]:Hide();
end

function Player:PLAYER_REGEN_DISABLED()
    
	
    --DHUD3:Debug("PLAYER_REGEN_DISABLED", playerLayout.pIcons, _G["DHUD3_"..playerLayout.pIcons.."combat"]:GetNormalTexture())
    if ( db.combatIcon ) then
        _G["DHUD3_"..playerLayout.pIcons.."combat"]:Show();
    end
end  

function Player:PLAYER_ALIVE()
	
	--[[
	local color = {r=0,g=0,b=0,hex=""};
	--Health
	local maxVal, curFrac, needH = DHUD3:GetUnitHealth("player");
    local colors = db.pColors[tostring(7)];
    color.r, color.g, color.b, color.hex = DHUD3:Colorize(colors, curFrac);
    DHUD3:UpdateBar(playerLayout.pHealth, maxVal, curFrac, color);
	--Power
	local powerType = UnitPowerType("player");
	maxVal = UnitPowerMax("player", powerType);
	curFrac = UnitPower("player", powerType);
    colors = db.pColors[tostring(powerType)];
    color.r, color.g, color.b, color.hex = DHUD3:Colorize(colors, curFrac);
    DHUD3:UpdateBar(playerLayout.pPower, maxVal, curFrac, color);
	]]--
	--Target
	--Player:PLAYER_TARGET_CHANGED();
end
