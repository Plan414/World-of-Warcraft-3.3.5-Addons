--[[
Layout.lua
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
-- Layout Settings
local VERSION = tonumber(("$Rev: 50 $"):match("%d+"));
DHUD3.layout = {
    mainFrame = {
        "CENTER",
        "UIParent",
        "CENTER",
        0,
        0,
        512,
        256
    },
    -- Frames: 2 main frames to contain the bars and text for each of the sides
    frames = {
        leftFrame = {
            "LEFT",
            "mainFrame",
            "LEFT",
            0,
            0,
            128,
            256,
        },
        rightFrame = {
            "RIGHT", 
            "mainFrame",
            "RIGHT",
            0,
            0,
            128,
            256,
        },
		leftAura = {
            "BOTTOM",
            "mainFrame",
            "BOTTOM",
            0,
            0,
            128,
            256,
        },
        rightAura = {
            "BOTTOM", 
            "mainFrame",
            "BOTTOM",
            0,
            0,
            128,
            256,
        },
		leftAbility = {
            "BOTTOM",
            "mainFrame",
            "BOTTOM",
            0,
            0,
            128,
            256,
        },
        rightAbility = {
            "BOTTOM", 
            "mainFrame",
            "BOTTOM",
            0,
            0,
            128,
            256,
        }
    },
    
    -- Bars: 2 sets of bars, one for each side. Each set contains 3 main bars, 2 pet bars, 1 casting and 1 flash, this allows the user to choose different layouts.
    leftPosition = {
        0,          -- x0
        1,          -- x1
        0,          -- y0
        1,          -- y1
    },
    rightPosition = {
        1,
        0,
        0,
        1,
    },
    iGap = {
        11,         -- texture gap top
        11          -- texture gap bottom
    },
    mGap = {
        5,
        5
    },
	eGap = {
		128,
		20
	},
    
	playerBars = {
        li = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\1",
            "Interface\\AddOns\\DHUD3\\textures\\1b",
            "iGap",
        },
        lm = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\2",
            "Interface\\AddOns\\DHUD3\\textures\\2b",
            "mGap",
        },
        ri = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\1",
            "Interface\\AddOns\\DHUD3\\textures\\1b",
            "iGap",
        },
        rm = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\2",
            "Interface\\AddOns\\DHUD3\\textures\\2b",
            "mGap",
        },
    },
    
    outerBars = {        
        lo = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\3",
            "Interface\\AddOns\\DHUD3\\textures\\3b",
            "mGap",
        },
        ro = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\3",
            "Interface\\AddOns\\DHUD3\\textures\\3b",
            "mGap",
        },
    },    
    
    petBars = {    
        lpo = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
			"leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\p1",
            "Interface\\AddOns\\DHUD3\\textures\\p1b",          
			"eGap",
        },
        lpi = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\p2",
            "Interface\\AddOns\\DHUD3\\textures\\p2b",
			"eGap",
        },
        rpo = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\p1",
            "Interface\\AddOns\\DHUD3\\textures\\p1b",
			"eGap",
        },
        rpi = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
			"rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\p2",
            "Interface\\AddOns\\DHUD3\\textures\\p2b",
			"eGap",
        },
    },
    
    castBars = {
        lc = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "iGap",
        },
        lcf = {
            "BOTTOM",
            "leftFrame",
            "BOTTOM",
            "leftPosition",
            "Interface\\AddOns\\DHUD3\\textures\\cbh",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "iGap",
        },
		
        rc = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "iGap",
        },
        rcf = {
            "BOTTOM",
            "rightFrame",
            "BOTTOM",
            "rightPosition",
            "Interface\\AddOns\\DHUD3\\textures\\cbh",
            "Interface\\AddOns\\DHUD3\\textures\\cb",
            "iGap",
        },
    },
    
    -- Texts: Each bar can have an asociated text to display it's value.
    playerText = {
        li = {
            "TOPLEFT",
            "li",
            "BOTTOMRIGHT",
            -25,
            10,
            200,
            14,
            "LEFT",
        },
        lm = {
            "TOPLEFT",
            "lm",
            "BOTTOMRIGHT",
            -40,
            -5,
            200,
            14,
            "LEFT",
        },
        ri = {
            "TOPRIGHT",
            "ri",
            "BOTTOMLEFT",
            25,
            10,
            200,
            14,
            "RIGHT",
        },
        rm = {
            "TOPRIGHT",
            "rm",
            "BOTTOMLEFT",
            40,
            -5,
            200,
            14,
            "RIGHT",
        },  
    },
    
	petText = {
		lpo = {
            "TOPLEFT",
            "lpo",
            "BOTTOMRIGHT",
            -10,
            25,
            200,
            14,
            "LEFT",
        },
        lpi = {
            "TOPLEFT",
            "lpi",
            "BOTTOMRIGHT",
            0,
            40,
            200,
            14,
            "LEFT",
        },
		rpo = {
            "TOPRIGHT",
            "rpo",
            "BOTTOMLEFT",
            10,
            25,
            200,
            14,
            "RIGHT",
        },
        rpi = {
            "TOPRIGHT",
            "rpi",
            "BOTTOMLEFT",
            0,
            40,
            200,
            14,
            "RIGHT",
        },
	},
	
	castText = {
		lcn = {
			"TOPLEFT",
            "lc",
            "TOPRIGHT",
            -20,
            -15,
            100,
            14,
            "LEFT",
		},
        lc = {
            "TOPLEFT",
            "lc",
            "TOPRIGHT",
            -20,
            0,
            100,
            14,
            "LEFT",
        },
        lcd = {
            "TOPLEFT",
            "lc",
            "TOPRIGHT",
            -20,
            15,
            100,
            14,
            "LEFT",
        },
		rcn = {
            "TOPRIGHT",
            "rc",
            "TOPLEFT",
            20,
            -15,
            100,
            14,
            "RIGHT",
        },
        rc = {
            "TOPRIGHT",
            "rc",
            "TOPLEFT",
            20,
            0,
            100,
            14,
            "RIGHT",
        },
        rcd = {
            "TOPRIGHT",
            "rc",
            "TOPLEFT",
            20,
            15,
            100,
            14,
            "RIGHT",
        },
	},
	
	outerText = {
		lo = {
            "TOPRIGHT",
            "lo",
            "BOTTOMRIGHT",
            -70,
            0,
            200,
            14,
            "RIGHT",
        },        
		ro = {
            "TOPLEFT",
            "ro",
            "BOTTOMLEFT",
            70,
            0,
            200,
            14,
            "LEFT",
        },
	},	
	
	texts = {
        target= {
            "CENTER",
            "mainFrame",
            "CENTER",
            0,
            -160,
            200,
            14,
        },
        targetTarget = {
            "CENTER",
            "mainFrame",
            "CENTER",
            0,
            -175,
            200,
            14,
        },
    },
    
    icons = {
        lrest = {
            "TOP",
            "leftFrame",
            "TOP", 
            42, 
            12,
            25,
            25,
            0.0625,
            0.4475,
            0.0625,
            0.4375,
            "Interface\\AddOns\\DHUD3\\textures\\rest",
        },
        lcombat = {
            "TOP",
            "leftFrame", 
            "TOP",
            42, 
            12, 
            25, 
            25,
            0.5625,
            0.9375,
            0.0625,
            0.4375,
            "Interface\\AddOns\\DHUD3\\textures\\combat",
        },
        lleader = {
            "TOP",
            "leftFrame",
            "TOP", 
            48, 
            -25, 
            20, 
            20,
            0,
            1,
            0,
            1,
            "Interface\\GroupFrame\\UI-Group-LeaderIcon"
        },
        llooter = {
            "TOP",
            "leftFrame",
            "TOP",
            43,
            -45,
            18,
            18,
             0,
            1,
            0,
            1,
            "Interface\\GroupFrame\\UI-Group-MasterLooter"
        },
        lpvp = {
            "TOP",
            "leftFrame",
            "TOP",
            60,
            -15,
            40,
            40,
            0,
            0.6,
            0,
            0.6,
            {
                "Interface\\TargetingFrame\\UI-PVP-Alliance",
                "Interface\\TargetingFrame\\UI-PVP-Horde",
                "Interface\\TargetingFrame\\UI-PVP-FFA",
            }
        },    
        ltelite = {
            "TOP",
            "leftFrame",
            "TOP",
            8,
            11,
            64,
            128,
            1,
            0,
            0,
            1,
            "Interface\\AddOns\\DHUD3\\textures\\elite"           
        },
		
		rrest = {
            "TOP",
            "rightFrame",
            "TOP", 
            -42, 
            12,
            25,
            25,
            0.0625,
            0.4475,
            0.0625,
            0.4375,
            "Interface\\AddOns\\DHUD3\\textures\\rest",
        },
        rcombat = {
            "TOP",
            "rightFrame", 
            "TOP",
            -42, 
            12, 
            25, 
            25,
            0.5625,
            0.9375,
            0.0625,
            0.4375,
            "Interface\\AddOns\\DHUD3\\textures\\combat",
        },
        rleader = {
            "TOP",
            "rightFrame",
            "TOP", 
            -48, 
            -20, 
            20, 
            20,
            0,
            1,
            0,
            1,
            "Interface\\GroupFrame\\UI-Group-LeaderIcon"
        },
        rlooter = {
            "TOP",
            "rightFrame",
            "TOP",
            -43,
            -40,
            18,
            18,
            0,
            1,
            0,
            1,
            "Interface\\GroupFrame\\UI-Group-MasterLooter"
        },
        rpvp = {
            "TOP",
            "rightFrame",
            "TOP",
            -60,
            -15,
            40,
            40,
            0,
            0.6,
            0,
            0.6,
            {
                "Interface\\TargetingFrame\\UI-PVP-Alliance",
                "Interface\\TargetingFrame\\UI-PVP-Horde",
                "Interface\\TargetingFrame\\UI-PVP-FFA",
            }
        },
        rtelite = {
            "TOP",
            "rightFrame",
            "TOP",
            -8,
            11,
            64,
            128,
            0,
            1,
            0,
            1,
            "Interface\\AddOns\\DHUD3\\textures\\elite"           
        },
		raid = {
            "CENTER",
            "target_Text",
            "TOP",
            0,
            10, 
            25, 
            25,
            0.6,
            0,
            0,
            0.6,
            {
                "Interface\\TargetingFrame\\UI-PVP-Alliance",
                "Interface\\TargetingFrame\\UI-PVP-Horde",
                "Interface\\TargetingFrame\\UI-PVP-FFA",                
			}
		},
	},
	
	petIcon = {
		lpet = {
            "leftFrame",
            36,
            -107,
        },
		rpet = {
            "rightFrame",
            -36,
            -107,
        },
	},
    
    targetLeftAuras = {
        TLA1 = {
            "RIGHT",
            "target_Text",
            "LEFT",
            -5,
            0,
            20, 
            20
        },
        TLA2 = {
            "RIGHT",
            "TLA1" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA3 = {
            "RIGHT",
            "TLA2" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA4 = {
            "RIGHT",
            "TLA3" ,
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA5 = {
            "RIGHT",
            "TLA4" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA6 = {
            "RIGHT",
            "TLA5" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA7 = {
            "RIGHT",
            "TLA6" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA8 = {
            "RIGHT",
            "TLA7" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA9 = {
            "RIGHT",
            "TLA1" ,
            "LEFT",
            20,
            -21,
            20,
            20 
        },
        TLA10 = {
            "RIGHT",
            "TLA9" ,
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA11 = {
            "RIGHT",
            "TLA10",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA12 = {
            "RIGHT",
            "TLA11",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA13 = {
            "RIGHT",
            "TLA12",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA14 = {
            "RIGHT",
            "TLA13",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA15 = {
            "RIGHT",
            "TLA14",
            "LEFT",
            -1,
            0,
            20,
            20,
        },
        TLA16 = {
            "RIGHT",
            "TLA15",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA17 = {
            "RIGHT",
            "TLA9" ,
            "LEFT",
            20,
            -21,
            20,
            20
        },
        TLA18 = {
            "RIGHT",
            "TLA17",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA19 = {
            "RIGHT",
            "TLA18",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA20 = {
            "RIGHT",
            "TLA19",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA21 = {
            "RIGHT",
            "TLA20",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA22 = {  
            "RIGHT",
            "TLA21",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA23 = {
            "RIGHT",
            "TLA22",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA24 = {
            "RIGHT",
            "TLA23",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA25 = {
            "RIGHT",
            "TLA17",
            "LEFT",
            20,
            -21,
            20,
            20
        },
        TLA26 = {  
            "RIGHT",
            "TLA25",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA27 = {
            "RIGHT",
            "TLA26",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA28 = {
            "RIGHT",
            "TLA27",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA29 = {
            "RIGHT",
            "TLA28",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA30 = {
            "RIGHT",
            "TLA29",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA31 = {
            "RIGHT",
            "TLA30",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA32 = {
            "RIGHT",
            "TLA31",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA33 = {
            "RIGHT",
            "TLA25",
            "LEFT",
            20,
            -21,
            20,
            20
        },
        TLA34 = {
            "RIGHT",
            "TLA33",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA35 = {
            "RIGHT",
            "TLA34",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA36 = {
            "RIGHT",
            "TLA35",
            "LEFT",
            -1,
            0,
            20,
            20
        },
        TLA37 = {
            "RIGHT",
            "TLA36",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA38 = {
            "RIGHT",
            "TLA37",
            "LEFT",
            -1,
            0,
            20,
            20 
        },
        TLA39 = {
            "RIGHT",
            "TLA38",
            "LEFT",
            -1,
            0,
            20,
            20,
        },
        TLA40 = {
            "RIGHT",
            "TLA39",
            "LEFT",
            -1,
            0,
            20,
            20
        },
    },
    
    targetRightAuras = {
        TRA1 = {
            "LEFT",
            "target_Text",
            "RIGHT" ,
            5,
            0,
            20,
            20
        },
        TRA2 = {
            "LEFT",
            "TRA1"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA3 = {
            "LEFT",
            "TRA2"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA4 = {
            "LEFT",
            "TRA3"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA5 = {
            "LEFT",
            "TRA4"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA6 = {
            "LEFT",
            "TRA5"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA7 = {
            "LEFT",
            "TRA6"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA8 = {
            "LEFT",
            "TRA7"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA9 = {
            "LEFT",
            "TRA1"  ,
            "RIGHT" ,
            -20,
            -21,
            20,
            20
        },
        TRA10 = {
            "LEFT",
            "TRA9"  ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA11 = {
            "LEFT",
            "TRA10" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA12 = {
            "LEFT",
            "TRA11" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA13 = {
            "LEFT",
            "TRA12" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA14 = {
            "LEFT",
            "TRA13" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA15 = {
            "LEFT",
            "TRA14" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA16 = {
            "LEFT",
            "TRA15" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA17 = {
            "LEFT",
            "TRA9"  ,
            "RIGHT" ,
            -20,
            -21,
            20,
            20
        },
        TRA18 = {
            "LEFT",
            "TRA17" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA19 = {
            "LEFT",
            "TRA18" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA20 = {
            "LEFT",
            "TRA19" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA21 = {
            "LEFT",
            "TRA20" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA22 = {
            "LEFT",
            "TRA21" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA23 = {
            "LEFT",
            "TRA22" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA24 = {
            "LEFT",
            "TRA23" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA25 = {
            "LEFT",
            "TRA17" ,
            "RIGHT" ,
            -20,
            -21,
            20,
            20
        },
        TRA26 = {
            "LEFT",
            "TRA25" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA27 = {
            "LEFT",
            "TRA26" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA28 = {
            "LEFT",
            "TRA27" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA29 = {
            "LEFT",
            "TRA28" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA30 = {
            "LEFT",
            "TRA29" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA31 = {
            "LEFT",
            "TRA30" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA32 = {
            "LEFT",
            "TRA31" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA33 = {
            "LEFT",
            "TRA25" ,
            "RIGHT" ,
            -20,
            -21,
            20,
            20
        },
        TRA34 = {
            "LEFT",
            "TRA33" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA35 = {
            "LEFT",
            "TRA34" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA36 = {
            "LEFT",
            "TRA35" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA37 = {
            "LEFT",
            "TRA36" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA38 = {
            "LEFT",
            "TRA37" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA39 = {
            "LEFT",
            "TRA38" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
        TRA40 = {
            "LEFT",
            "TRA39" ,
            "RIGHT" ,
            1,
            0,
            20,
            20
        },
    },
    
	petTexture = {
		{   
			--unHappy
			"Interface\\PetPaperDollFrame\\UI-PetHappiness",
			0.375,
			0.5625,
			0,
			0.359375
		},
		{ 
			--normal
			"Interface\\PetPaperDollFrame\\UI-PetHappiness",
			0.1875,
			0.375,
			0,
			0.359375
		},
		{
			--happy
			"Interface\\PetPaperDollFrame\\UI-PetHappiness",
			0,
			0.1875,
			0,
			0.359375               
		}            
	},
}
