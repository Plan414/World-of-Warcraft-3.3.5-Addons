--[[
Outer.lua
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

local MODNAME = "Outer";
local Outer = DHUD3:NewModule(MODNAME, "AceEvent-3.0");
local VERSION = tonumber(("$Rev: 147 $"):match("%d+"));

local string_len = string.len;
local string_gsub = string.gsub;
local string_upper = string.upper;
local string_find = string.find;
--Fonts
local maxfont = 25
local minfont = 6

-- Local defaults
local totBar, focusBar;
local origColor = {r, g, b};
local db
local defaults = {
	profile = {
		click = false,
		ro = {
			--track = focusH, focusP, toTH, toTP, agro;
			track = "";
			barText = true;
			style = "[FractionalXP] ([PercentXP:Percent])",
			cStyle = "",
			onParty = false;
			aBarText = true;
			aStyle = "[PercentThreat] ([RawPercentThreat])",
			aCStyle = "",
			textSize = 12;
			status = true,
			threatpct = true,
			rawthreatpct = true,
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
				["8"] = {
		            full = { 0.8, 0.8, 0.8 },
		            med = { 0.73, 0.73, 0.73 },
		            low = { 0.67, 0.67, 0.67 }
		        },
				agro = {
		            full = { 0.67, 0, 0 },
		            med = { 0.67, 0.67, 0 },
		            low = { 0, 0.67, 0 },
		        },
			},
		},
		lo = {
			--track = focusH, focusP, toTH, toTP, agro;
			track = "";
			barText = true;
			style = "[FractionalXP] ([PercentXP:Percent])",
			cStyle = "",
			onParty = false;
			aBarText = true;
			aStyle = "[PercentThreat] ([RawPercentThreat])",
			aCStyle = "",
			textSize = 12;
			status = true,
			threatpct = true,
			rawthreatpct = true,
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
				["8"] = {
		            full = { 0.8, 0.8, 0.8 },
		            med = { 0.73, 0.73, 0.73 },
		            low = { 0.67, 0.67, 0.67 }
		        },
				agro = {
		            full = { 0.67, 0, 0 },
		            med = { 0.67, 0.67, 0 },
		            low = { 0, 0.67, 0 },
		        },
			},
		},
	}
}

-- Functions required by the configuration options table
local OptGetter, OptSetter, ColorGetter, ColorSetter, SelectGetter, SelectSetter, agroEnabled;
do
	local mod = Outer
	function OptGetter(info)
		local key1, key2 = info[#info-2], info[#info];
		return db[key1][key2];
	end

	function OptSetter(info, value)
		local key1, key2 = info[#info-2], info[#info];
		db[key1][key2] = value;
		mod:Refresh();
	end
	
	function OptGetter(info)
		local key1, key2 = info[#info-2], info[#info];
		return db[key1][key2];
	end

	function OptSetter(info, value)
		local key1, key2 = info[#info-2], info[#info];
		db[key1][key2] = value;
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
		--return db[key1][key2][key3][1], db[key1][key2][key3][2], db[key1][key2][key3][3]
		return db[key1][key2][key3][key4][1], db[key1][key2][key3][key4][2], db[key1][key2][key3][key4][3];
	end
    
    function ColorSetter (info, r, g, b) 
        local key1, key2, key3, key4 = info[#info-3], info[#info-2], info[#info-1], info[#info];
        db[key1][key2][key3][key4][1] = r;
        db[key1][key2][key3][key4][2] = g;
        db[key1][key2][key3][key4][3] = b;
        mod:Refresh();
    end
	
	function agroEnabled(info)
		
		local key1 = info[#info-2];
		if db[key1].track == "agro" then
			return false;
		else
			return true;
		end
	end
	
	function noneEnabled(info)
		
		local key1 = info[#info-2];
		if db[key1].track == "" then
			return true;
		else
			return false;
		end
	end
	
	trackValues = {[""] = L["None"], ["focusH"] = L["Focus Health"], ["focusP"] = L["Focus Power"], ["toTH"] = L["Target Of Target Health"], ["toTP"] = L["Target Of Target Power"], ["agro"] = L["Agro"]}
	
	tags = {
		["[FractionalXP] ([PercentXP:Percent])"] = L["Current/Max (Percent%)"],
		["[FractionalXP]"] = L["Current/Max"],
		["[XP] ([PercentXP:Percent])"] = L["Current (Percent%)"],
		["[PercentXP:Percent]"] = L["Percent%"],
		["[XP]"] = L["Current"] }
	threatTags = {
		["[IsTanking]"] = L["Is Tanking"],
		["[PercentThreat] ([RawPercentThreat])"] = L["Pull Agro Percent (Total Agro Percent"],
		["[RawPercentThreat]"] = L["Total Agro Percent"],
		["[RawPercentThreat] = [ThreatStatus]"] = L["Total Agro Percent = Threat Status"],
		["[ThreatStatus]"] = L["Threat Status"]}
end

--Local Options
local options
local function GetOptions()
	if not options then
        --Options table
    	options = {
    		type = "group",
			name = L["The outer module manages the outer bars functionality. Track focus, target of target or agro"],
			arg = MODNAME,
            order = 2,
			get = OptGetter,
			set = OptSetter,
			childGroups = "tab",
    		args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable Outer Module"],
                    get = function() return DHUD3:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) DHUD3:SetModuleEnabled(MODNAME, value) end,
                },
				click = {
					type ='toggle',
					order = 2,
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
				lo = {
					order = 3,
					type = 'group',
					name = L["Left Bar"],
					args = {
						gral = {
							order = 1,
							type = 'group',
							name = L["Bar Settings"],
							args = {
								track = {
									type = "select",
									order = 1,
									name = L["Bar tracks"],
									values = trackValues,
								},
								status = {
									type = "toggle",
									order = 2,
									name = L["Agro Status"],
									desc = L["Track your agro status by coloring the bar border"],
									disabled = noneEnabled,
								},
								barText = {
									type = 'toggle',
									order = 3,
									name = L["Show Bar Values"],
									disabled = (not agroEnabled) or noneEnabled,
								},
								style = {
									type = 'select',
									order = 4,
									name = L["Bar Text Style"],
									hidden = BarTextHidden,
									values = tags,
									disabled = (not agroEnabled) or noneEnabled,
								},
								cStyle = {
									type = 'input',
									order = 5,
									name = L["Custom Text Style"],
									desc = L["If set this style will override Bar Text Style value. Replace H (health) and M (mana/power) on your tags by X and DHUD3 will replace it appropriately depending on the status you are tracking. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Bar Text Style setting.)"],
									usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
									disabled = (not agroEnabled) or noneEnabled,
								},
								textSize = {
                                    type = 'range',
                                    order = 6,
                                    name = L["Font size"],
                                    min = minfont,
                                    max = maxfont,
									disabled = (not agroEnabled) or noneEnabled,
									hidden = BarTextHidden,
                                    step = 1,
                                },
							},
						},
						agro = {
							type = 'group',
							order = 2,
							name = L["Agro Tracking"],
							disabled = function (info)
									local key1 = info[#info-1];
									if db[key1].track == "agro" then
										return false;
									else
										return true;
									end
								end,
							args = {
								aBarText = {
									type = 'toggle',
									order = 1,
									name = L["Show Bar Values"],
									disabled = false,
								},
								aStyle = {
									type = 'select',
									order = 2,
									name = L["Agro Text Style"],
									values = threatTags,
									disabled = false,
								},
								cAStyle = {
									type = 'input',
									order = 3,
									name = L["Custom Agro Style"],
									desc = L["If set this style will override Agro Text Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Agro Text Style setting.)"],
									usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],
									disabled = false,
								},
								onParty = {
									type = 'toggle',
									order = 4,
									name = L["On Party"],
									desc = L["Only track Agro while on party/raid"],
									disabled = false,
								},
								threatpct = {
									type = 'toggle',
									order = 6,
									name = L["Threat Percent"],
									desc = L["Track your total threat as the percent required to pull agro"],
									disabled = false,
								},
								rawthreatpct = {
									type = 'toggle',
									order = 7,
									name = L["Raw Threat Percent"],
									desc = L["Track your raw threat as a percent of the tank's current threat"],
									disabled = false,
								},
							},						
						},
						colors = {
							type = 'group',
							order = 3,
							name = L["Bar Colors"],
							get = ColorGetter,
							set = ColorSetter,
							disabled = function (info)
									local key1 = info[#info-1];
									if db[key1].track == "" then
										return true;
									else
										return false;
									end
								end,
							args = {
								["7"] = {
									type = 'group',
									guiInline = true,
									name = L["Health"],
									order = 1,
									disabled = false,
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
									guiInline = true,
									name = L["Mana"],
									disabled = false,
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
									guiInline = true,
									name = L["Rage"],
									disabled = false,
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
									guiInline = true,
									name = L["Energy"],
									disabled = false,
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
									guiInline = true,
									name = L["Runic Power"],
									disabled = false,
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
									guiInline = true,
									name = L["Focus (Pet)"],
									disabled = false,
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
									disabled = false,
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
								agro = {
									type = 'group',
									guiInline = true,
									name = L["Agro"],
									disabled = false,
									args = {
										full = {
											type = 'color',
											name = L["High"],
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
				ro = {
					order = 4,
					type = 'group',
					name = L["Right Bar"],
					args = {
						gral = {
							order = 1,
							type = 'group',
							name = L["Bar Settings"],
							args = {
								track = {
									type = "select",
									order = 1,
									name = L["Bar tracks"],
									values = trackValues,
								},
								status = {
									type = "toggle",
									order = 2,
									name = L["Agro Status"],
									desc = L["Track your agro status by coloring the bar border"],
									disabled = noneEnabled,
								},
								barText = {
									type = 'toggle',
									order = 3,
									name = L["Show Bar Values"],
									disabled = (not agroEnabled) or noneEnabled,
								},
								style = {
									type = 'select',
									order = 4,
									name = L["Bar Text Style"],
									hidden = BarTextHidden,
									values = tags,
									disabled = (not agroEnabled) or noneEnabled,
								},
								cStyle = {
									type = 'input',
									order = 5,
									name = L["Custom Text Style"],
									desc = L["If set this style will override Bar Text Style value. Replace H (health) and M (mana/power) on your tags by X and DHUD3 will replace it appropriately depending on the status you are tracking. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Bar Text Style setting.)"],
									usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],							
									disabled = (not agroEnabled) or noneEnabled,
								},
								textSize = {
                                    type = 'range',
                                    order = 6,
                                    name = L["Font size"],
                                    min = minfont,
                                    max = maxfont,
									disabled = (not agroEnabled) or noneEnabled,
									hidden = BarTextHidden,
                                    step = 1,
                                },
							},
						},
						agro = {
							type = 'group',
							order = 2,
							name = L["Agro Tracking"],
							disabled = function (info)
									local key1 = info[#info-1];
									if db[key1].track == "agro" then
										return false;
									else
										return true;
									end
								end,
							args = {
								aBarText = {
									type = 'toggle',
									order = 1,
									name = L["Show Bar Values"],
									disabled = false,
								},
								aStyle = {
									type = 'select',
									order = 2,
									name = L["Agro Text Style"],
									values = threatTags,
									disabled = false,
								},
								cAStyle = {
									type = 'input',
									order = 3,
									name = L["Custom Agro Style"],
									desc = L["If set this style will override Agro Text Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Agro Text Style setting.)"],
									usage = L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."],
									disabled = false,
								},
								onParty = {
									type = 'toggle',
									order = 4,
									name = L["On Party"],
									desc = L["Only track Agro while on party/raid"],
									disabled = false,
								},
								threatpct = {
									type = 'toggle',
									order = 6,
									name = L["Threat Percent"],
									desc = L["Track your total threat as the percent required to pull agro"],
									disabled = false,
								},
								rawthreatpct = {
									type = 'toggle',
									order = 7,
									name = L["Raw Threat Percent"],
									desc = L["Track your raw threat as a percent of the tank's current threat"],
									disabled = false,
								},
							},						
						},
						colors = {
							type = 'group',
							order = 3,
							name = L["Bar Colors"],
							get = ColorGetter,
							set = ColorSetter,
							disabled = function (info)
									local key1 = info[#info-1];
									if db[key1].track == "" then
										return true;
									else
										return false;
									end
								end,
							args = {
								["7"] = {
									type = 'group',
									guiInline = true,
									name = L["Health"],
									order = 1,
									disabled = false,
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
									guiInline = true,
									name = L["Mana"],
									disabled = false,
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
									guiInline = true,
									name = L["Rage"],
									disabled = false,
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
									guiInline = true,
									name = L["Energy"],
									disabled = false,
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
									guiInline = true,
									name = L["Runic Power"],
									disabled = false,
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
									guiInline = true,
									name = L["Focus (Pet)"],
									disabled = false,
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
									disabled = false,
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
								agro = {
									type = 'group',
									guiInline = true,
									name = L["Agro"],
									disabled = false,
									args = {
										full = {
											type = 'color',
											name = L["High"],
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
			},
		}
	end
	
	return options;
end

-- Local functions
local PlaceBarTexts, OnBarShow, OnBarHide, SetBarText, SetBarAgro, OnPlayerFocus, OnUnitThreat
do
	function OnBarShow(this, event)
	
		--DHUD3:Debug("OnBarShow", this, event);
		if ( this.bar ) then
			DHUD3:SendMessage("DHUD3_BAR_SHOW", this.bar);
		end
	end
	
	function OnBarHide(this, event)
	
		--DHUD3:Debug("OnBarHide", this, event);
		DHUD3:SendMessage("DHUD3_BAR_HIDE", this.bar);
	end
	
	function SetBarText(who, bar, stat)
		
		-- Bar Text
		DogTag:RemoveFontString(_G["DHUD3_"..bar.."_Text_Text"]);
		local tagCode = (string_len(db[bar].cStyle) > 0) and db[bar].cStyle or db[bar].style;
		tagCode = string_gsub(tagCode, "X", ( ( stat == "p") and "M" or "H"));
		--DHUD3:Debug("Outer SetBarText tag", tagCode);
		DogTag:AddFontString(_G["DHUD3_"..bar.."_Text_Text"], _G["DHUD3_"..bar.."_Text"], tagCode, "Unit", { unit = who } );
	end
	
	function SetBarTracking(bar, who, what)
	
		if ( UnitExists(who) ) then
			DHUD3:SetBarsStat(who, bar, what, db[bar].colors);
			if db[bar].barText then
				SetBarText(who, bar, what);
			end
            _G["DHUD3_"..bar].track = what;
		else
            DHUD3:RemoveBarStat(bar);
			DogTag:RemoveFontString(_G["DHUD3_"..bar.."_Text_Text"]);
		end
	end
	
	function SetBarAgro(who, bar)
		
		_G["DHUD3_"..bar]:RegisterEvent("UNIT_TARGET");
		_G["DHUD3_"..bar]:SetScript("OnEvent", OnUnitThreat);
	end
	
	function OnUnitThreat(this, event, who)
		
		--DHUD3:Debug("Outer", event, who);
		if ( event == "UNIT_TARGET" and (who == "player") ) then
			if ( UnitExists("target") and UnitCanAttack("player", "target") ) then
				if not ( db[this.bar].onParty and (GetNumPartyMembers() == 0) ) then
					this:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
				end
			else
				this:UnregisterEvent("UNIT_THREAT_LIST_UPDATE");
				this:Hide();
			end
		elseif ( event == "UNIT_THREAT_LIST_UPDATE" and (who == "target") ) then
			local isTanking, status, threatpct, rawthreatpct = UnitDetailedThreatSituation("player", "target");
			--DHUD3:Debug(isTanking, status, threatpct, rawthreatpct);
			if ( threatpct ) then
				if ( db[this.bar].status ) then
					local r, g, b = GetThreatStatusColor(status);
					_G["DHUD3_"..this.bar.."_Border"]:SetVertexColor(r, g, b);
				end
				if ( db[this.bar].threatpct ) then
					local color = {r=0,g=0,b=0,hex=""};
					--DHUD3:Debug(db[this.bar].colors.agro);
					color.r, color.g, color.b, color.hex = DHUD3:Colorize(db[this.bar].colors.agro, threatpct/100);
					DHUD3:UpdateBar(this.bar, 100, threatpct/100, color);
				end
				if ( db[this.bar].rawthreatpct ) then
					-- Marker ??
				end
				this:Show();
			else
				this:Hide();
			end
		end
	end
end

function Outer:OnInitialize()
	self.db = DHUD3.db:RegisterNamespace(MODNAME, defaults);
	db = self.db.profile;
	self:SetEnabledState(DHUD3:GetModuleEnabled(MODNAME));
	DHUD3:RegisterModuleOptions(MODNAME, GetOptions, L["Outer"]);
	
	local bars = DHUD3.layout.outerBars;
    local barText = DHUD3.layout.outerText;
	
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
		ref:SetScript("OnShow", OnBarShow);
		ref:SetScript("OnHide", OnBarHide);
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
end

function Outer:OnEnable()
	
	self:Refresh();
end

function Outer:OnDisable()
	
	self:UnregisterAllEvents();
	DHUD3_ro:Hide();
	DHUD3_ro:UnregisterAllEvents();
	DHUD3_ro:SetScript("OnUpdate", nil);
	DogTag:RemoveFontString(_G["DHUD3_ro_Text_Text"]);
	DHUD3_lo:Hide();
	DHUD3_lo:UnregisterAllEvents();
	DHUD3_lo:SetScript("OnUpdate", nil);
	DogTag:RemoveFontString(_G["DHUD3_lo_Text_Text"]);
end

function Outer:Refresh()
	
	--DHUD3:Debug(MODNAME, "Refresh");
	db = self.db.profile
	if not self:IsEnabled() then return end
	DHUD3:PlaceBarTexts("outerText");
	local colors;
	-- Remove all registered events and text tags
	self:UnregisterEvent("UNIT_TARGET");
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE");
	DHUD3_ro:Hide();
	DHUD3_ro:UnregisterAllEvents();
	DHUD3_ro:SetScript("OnUpdate", nil);
	DogTag:RemoveFontString(_G["DHUD3_ro_Text_Text"]);
	DHUD3_lo:Hide();
	DHUD3_lo:UnregisterAllEvents();
	DHUD3_lo:SetScript("OnUpdate", nil);
	DogTag:RemoveFontString(_G["DHUD3_lo_Text_Text"]);
	focusBar = nil;
	totBar = nil;
	if origColor.r then
		local r, g, b = origColor.r, origColor.g, origColor.b;
		DHUD3_ro_Border:SetVertexColor(r, g, b);
		DHUD3_lo_Border:SetVertexColor(r, g, b);
	end
	
	local scale = DHUD3.GetScale();
	
	-- Right bar
	DHUD3_ro_Text:Hide();
    DHUD3_ro_Text_Text:SetFont(DHUD3:GetFont(), db.ro.textSize * scale);
    DHUD3_ro_Text_Text:SetWidth(200);
	--DHUD3:Debug("Right Bar", db.ro.track);
	if db.ro.track == "focusH" then
		SetBarTracking("ro", "focus", "h");
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
		focusBar = "ro";
		if db.ro.status then
			self:RegisterEvent("UNIT_TARGET");
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.ro.track == "focusP" then
        DHUD3_ro.bar = "ro";
		SetBarTracking("ro", "focus", "p");
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
		focusBar = "ro";
		if db.ro.status then
			self:RegisterEvent("UNIT_TARGET");
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.ro.track == "toTH" then
        DHUD3_ro.bar = "ro";
		SetBarTracking("ro", "targettarget", "h");
		self:RegisterEvent("UNIT_TARGET");
		totBar = "ro";
		if db.ro.status then
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.ro.track == "toTP" then
        DHUD3_ro.bar = "ro";
		SetBarTracking("ro", "targettarget", "p");
		self:RegisterEvent("UNIT_TARGET");
		totBar = "ro";
		if db.ro.status then
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.ro.track == "agro" then
		DHUD3_ro.bar = "ro";
		DHUD3_ro:RegisterEvent("UNIT_TARGET");
		DHUD3_ro:SetScript("OnEvent", OnUnitThreat);
		if ( UnitExists("target") and UnitCanAttack("player", "target") ) then
			DHUD3_ro:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
			local isTanking, status, threatpct, rawthreatpct = UnitDetailedThreatSituation("player", "target");
			if ( threatpct ) then
				if ( db.ro.status ) then
					local r, g, b = GetThreatStatusColor(status);
					DHUD3_ro_Border:SetVertexColor(r, g, b);
				end
				if ( db.ro.threatpct ) then
					local color = {r=0,g=0,b=0,hex=""};
					color.r, color.g, color.b, color.hex = DHUD3:Colorize(db.ro.colors.agro, threatpct/100);
					DHUD3:UpdateBar("ro", 100, threatpct/100, color);
				end
				if ( db.ro.rawthreatpct ) then
					-- Marker ??
				end
				DHUD3_ro:Show();
			else
				DHUD3_ro:Hide();
			end
		else
			DHUD3_ro:Hide();
		end
	end
	if db.ro.track == "agro" then
		if db.ro.aBarText then
			local tagCode = (string_len(db.ro.aCStyle) > 0) and db.ro.aCStyle or db.ro.aStyle;
			DogTag:AddFontString(DHUD3_ro_Text_Text, DHUD3_ro_Text, tagCode, "Unit", { unit = "player" });
			DHUD3_ro_Text:Show();
		end
	else
		if db.ro.barText then
			local tagCode = (string_len(db.lo.cStyle) > 0) and db.lo.cStyle or db.lo.style;
			DogTag:AddFontString(DHUD3_lo_Text_Text, DHUD3_lo_Text, tagCode, "Unit", { unit = "player" });
			DHUD3_ro_Text:Show();
		end
	end
	
	-- Left bar
	DHUD3_lo_Text:Hide();
    DHUD3_lo_Text_Text:SetFont(DHUD3:GetFont(), db.lo.textSize * scale)
    DHUD3_lo_Text_Text:SetWidth(200)
	--DHUD3:Debug("Left Bar", db.lo.track);
	if db.lo.track == "focusH" then
        DHUD3_lo.bar = "lo";
		SetBarTracking("lo", "focus", "h");
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
		focusBar = "lo";
		if db.lo.status then
			self:RegisterEvent("UNIT_TARGET");
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.lo.track == "focusP" then
        DHUD3_lo.bar = "lo";
		SetBarTracking("lo", "focus", "p");
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
		focusBar = "lo";
		if db.lo.status then
			self:RegisterEvent("UNIT_TARGET");
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.lo.track == "toTH" then
        DHUD3_lo.bar = "lo";
		SetBarTracking("lo", "targettarget", "h");
		self:RegisterEvent("UNIT_TARGET");
		totBar = "lo";
		if db.lo.status then
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.lo.track == "toTP" then
        DHUD3_lo.bar = "lo";
		SetBarTracking("lo", "targettarget", "p");
		self:RegisterEvent("UNIT_TARGET");
		totBar = "lo";
		if db.lo.status then
			origColor.r, origColor.g, origColor.b = DHUD3_ro_Border:GetVertexColor();
		end
	elseif db.lo.track == "agro" then
		DHUD3_lo:RegisterEvent("UNIT_TARGET");
		DHUD3_lo:SetScript("OnEvent", OnUnitThreat);
		DHUD3_lo.bar = "lo";
		if ( UnitExists("target") and UnitCanAttack("player", "target") ) then
			DHUD3_lo:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
			local isTanking, status, threatpct, rawthreatpct = UnitDetailedThreatSituation("player", "target");
			if ( threatpct ) then
				if ( db.lo.status ) then
					local r, g, b = GetThreatStatusColor(status);
					DHUD3_lo_Border:SetVertexColor(r, g, b);
				end
				if ( db.lo.threatpct ) then
					local color = {r=0,g=0,b=0,hex=""};
					color.r, color.g, color.b, color.hex = DHUD3:Colorize(db.lo.colors.agro, threatpct/100);
					DHUD3:UpdateBar("lo", 100, threatpct/100, color);
				end
				if ( db.lo.rawthreatpct ) then
					-- Marker ??
				end
				DHUD3_lo:Show();
			else
				DHUD3_lo:Hide();
			end
		else
			DHUD3_lo:Hide();
		end
	end
	if db.lo.track == "agro" then
		if db.lo.aBarText then
			local tagCode = (string_len(db.lo.aCStyle) > 0) and db.lo.aCStyle or db.lo.aStyle;
			DogTag:AddFontString(DHUD3_lo_Text_Text, DHUD3_lo_Text, tagCode, "Unit", { unit = "player" });
			DHUD3_lo_Text:Show();
		end
	else
		if db.lo.barText then
			local tagCode = (string_len(db.lo.cStyle) > 0) and db.lo.cStyle or db.lo.style;
			DogTag:AddFontString(DHUD3_lo_Text_Text, DHUD3_lo_Text, tagCode, "Unit", { unit = "player" });
			DHUD3_lo_Text:Show();
		end
	end
	-- Bars Text Click trough
	local barText = DHUD3.layout.outerText;
	for k, v in pairs(barText) do
		_G["DHUD3_"..k.."_Text"]:EnableMouse(not db.click);
		_G["DHUD3_"..k.."_Text"]:SetMovable(not db.click);
	end
end

function Outer:PLAYER_FOCUS_CHANGED(event)
		
	--DHUD3:Debug("Outer", event);
    if ( string_find(db[focusBar].track, "H") ) then
        SetBarTracking(totBar, "targettarget", "h", db[focusBar].colors);
    else
        SetBarTracking(totBar, "targettarget", "p", db[focusBar].colors);
    end
end

function Outer:UNIT_TARGET(event, who)
	
    
	if ( who == "target" ) then
		if (totBar) then
            if ( string_find(db[totBar].track, "H") ) then
                SetBarTracking(totBar, "targettarget", "h", db[totBar].colors);
            else
                SetBarTracking(totBar, "targettarget", "p", db[totBar].colors);
            end
		end
	elseif ( who == "player" ) then
        if ( totBar ) then
            if ( string_find(db[totBar].track, "H") ) then
                SetBarTracking(totBar, "targettarget", "h", db[totBar].colors);
            else
                SetBarTracking(totBar, "targettarget", "p", db[totBar].colors);
            end
			if db[totBar].status then
				if ( UnitExists("target") and UnitCanAttack("player", "target") ) then
					self:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
				else
					self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE");
					local r, g, b = origColor.r, origColor.g, origColor.b;
					_G["DHUD3_"..totBar.."_Border"]:SetVertexColor(r, g, b);
				end
			end
		end
		if ( focusBar ) then
			if db[focusBar].status then
				if ( UnitExists("target") and UnitCanAttack("player", "target") ) then
					self:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
				else
					self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE");
					local r, g, b = origColor.r, origColor.g, origColor.b;
					_G["DHUD3_"..focusBar.."_Border"]:SetVertexColor(r, g, b);
				end
			end
		end
	end
end

function Outer:UNIT_THREAT_LIST_UPDATE(event, who)
	
	local r, g, b = origColor.r, origColor.g, origColor.b;
	local _, status, threatpct = UnitDetailedThreatSituation("player", "target");
	if ( threatpct ) then
		r, g, b = GetThreatStatusColor(status);
	end
	if focusBar then
		if db[focusBar].status then
			_G["DHUD3_"..focusBar.."_Border"]:SetVertexColor(r, g, b);
		end
	elseif totBar then
		if db[totBar].status then
			_G["DHUD3_"..totBar.."_Border"]:SetVertexColor(r, g, b);
		end
	end	
end

