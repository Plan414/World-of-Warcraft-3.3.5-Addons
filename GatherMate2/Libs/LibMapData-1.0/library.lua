--[[
	Library contains a dataset for Map file names and floors giving the raw map data
	it also has a few functions to help determine distance and directions.
--]]
local MAJOR, MINOR = "LibMapData-1.0", tonumber("31") or 999
assert(LibStub, MAJOR.." requires LibStub")

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

local watchFrame = CreateFrame("Frame")
local lastMap, lastFloor = nil,0
local mapData = {}
local mapToLocal = {}
local idToMap = {}
local GetPlayerFacing, GetPlayerMapPosition,SetMapToCurrentZone = GetPlayerFacing, GetPlayerMapPosition, SetMapToCurrentZone
local atan2 = math.atan2
local PI2 = math.pi*2
local type,assert = type,assert
do
	-- Format: 
	-- floors = number of floors
	-- area_id = in game area id
	-- floor_index = width,height, ulX,ulY, lrXx,lrY, mapid
	local emptyMaps = { 
		['floors'] = 0,['area_id'] = -1, ['continent'] = -1,
		[1] = {0,0,0,0,0,0,0}
	}
	setmetatable(mapData, { __index = function(t, k) if k then DEFAULT_CHAT_FRAME:AddMessage("LibMapData-1.0 is missing data for "..k) end; return emptyMaps end })
	setmetatable(idToMap, { __index = function(t, k) if k then DEFAULT_CHAT_FRAME:AddMessage("LibMapData-1.0 is missing data for area id "..k) end; return k end})
	setmetatable(mapToLocal, { __index = function(t,k) if k then DEFAULT_CHAT_FRAME:AddMessage("LibMapData-1.0 is missing localized data for "..k) end; return k end})
    mapData['TheRubySanctum']={ ['floors'] = 0,['area_id'] = 610,
    [1] = { 752.083312988281, 502.083251953125, 3429.16650390625,902.083312988281, 2927.08325195312,150.0}}
	mapData['Naxxramas'] = {['floors'] = 6,['area_id']= 536,
	[1] = {1093.830078125,729.219970703125,2886.61010742188,-3734.10009765625,3615.830078125,-2640.27001953125},
	[2] = {1093.830078125,729.219970703125,2886.61010742188,-4234.10009765625,3615.830078125,-3140.27001953125},
	[3] = {1200.0,800.0,2336.0,-3787.0,3136.0,-2587.0},
	[4] = {1200.330078125,800.219970703125,2336.61010742188,-4287.35009765625,3136.830078125,-3087.02001953125},
	[5] = {2069.80981445312,1379.8798828125,2311.34008789062,-4400.08984375,3691.21997070312,-2330.28002929688},
	[6] = {655.93994140625,437.2900390625,3379.25,-5522.2900390625,3816.5400390625,-4866.35009765625},}
	mapData['PitofSaron'] = {['floors'] = 0,['area_id']= 603,
	[1] = {1533.33331298828,1022.91667175293,1256.25,839.583312988281,233.33332824707,-693.75},}
	mapData['TheForgeofSouls'] = {['floors'] = 1,['area_id']= 602,
	[1] = {1448.09985351562,965.400390625,4814.52978515625,1686.03002929688,5779.93017578125,3134.1298828125},}
	mapData['Ironforge'] = {['floors'] = 0,['area_id']= 342,
	[1] = {790.625061035156,527.6044921875,-4569.2412109375,-713.591369628906,-5096.845703125,-1504.21643066406},}
	mapData['ArathiBasin'] = {['floors'] = 0,['area_id']= 462,
	[1] = {1756.24992370605,1170.83325195312,1508.33325195312,1858.33325195312,337.5,102.08332824707},}
	mapData['HrothgarsLanding'] = {['floors'] = 0,['area_id']= 542,
	[1] = {3677.08312988281,2452.083984375,10781.25,2797.91650390625,8329.166015625,-879.166625976562},}
	mapData['AzjolNerub'] = {['floors'] = 3,['area_id']= 534,
	[1] = {752.973999023438,501.983001708984,292.141998291016,-30.0,794.125,722.973999023438},
	[2] = {292.973999023438,195.315979003906,450.473999023438,400.0,645.789978027344,692.973999023438},
	[3] = {367.5,245.0,395.0,462.125,640.0,829.625},}
	mapData['CrystalsongForest'] = {['floors'] = 0,['area_id']= 511,
	[1] = {2722.91662597656,1814.5830078125,6502.0830078125,1443.75,4687.5,-1279.16662597656},}
	mapData['GrizzlyHills'] = {['floors'] = 0,['area_id']= 491,
	[1] = {5249.99987792969,3499.99987792969,5516.66650390625,-1110.41662597656,2016.66662597656,-6360.41650390625},}
	mapData['EversongWoods'] = {['floors'] = 0,['area_id']= 463,
	[1] = {4925.0,3283.3330078125,11041.666015625,-4487.5,7758.3330078125,-9412.5},}
	mapData['AzuremystIsle'] = {['floors'] = 0,['area_id']= 465,
	[1] = {4070.8330078125,2714.5830078125,-2793.75,-10500.0,-5508.3330078125,-14570.8330078125},}
	mapData['Netherstorm'] = {['floors'] = 0,['area_id']= 480,
	[1] = {5574.99967193604,3716.66674804688,5456.25,5483.3330078125,1739.58325195312,-91.6666641235352},}
	mapData['Elwynn'] = {['floors'] = 0,['area_id']= 31,
	[1] = {3470.83325195312,2314.5830078125,-7939.5830078125,1535.41662597656,-10254.166015625,-1935.41662597656},}
	mapData['WarsongGulch'] = {['floors'] = 0,['area_id']= 444,
	[1] = {1145.83331298828,764.583312988281,1627.08325195312,2041.66662597656,862.499938964844,895.833312988281},}
	mapData['Undercity'] = {['floors'] = 0,['area_id']= 383,
	[1] = {959.375030517578,640.104125976562,1877.9453125,873.192626953125,1237.84118652344,-86.1824035644531},}
	mapData['Ogrimmar'] = {['floors'] = 0,['area_id']= 322,
	[1] = {1402.6044921875,935.416625976562,2273.87719726562,-3680.60107421875,1338.46057128906,-5083.20556640625},}
	mapData['Expansion01'] = {['floors'] = 0,['area_id']= 467,
	[1] = {17464.078125,11642.71875,5821.359375,12996.0390625,-5821.359375,-4468.0390625},}
	mapData['Sunwell'] = {['floors'] = 0,['area_id']= 500,
	[1] = {3327.0830078125,2218.7490234375,13568.7490234375,-5302.0830078125,11350.0,-8629.166015625},}
	mapData['TheStormPeaks'] = {['floors'] = 0,['area_id']= 496,
	[1] = {7112.49963378906,4741.666015625,10197.916015625,1841.66662597656,5456.25,-5270.8330078125},}
	mapData['Winterspring'] = {['floors'] = 0,['area_id']= 282,
	[1] = {7099.99984741211,4733.33325195312,8533.3330078125,-316.666656494141,3799.99975585938,-7416.66650390625},}
	mapData['Darnassis'] = {['floors'] = 0,['area_id']= 382,
	[1] = {1058.33325195312,705.7294921875,10238.31640625,2938.36279296875,9532.5869140625,1880.02954101562},}
	mapData['Arathi'] = {['floors'] = 0,['area_id']= 17,
	[1] = {3599.99987792969,2399.99992370605,-133.33332824707,-866.666625976562,-2533.33325195312,-4466.66650390625},}
	mapData['Silverpine'] = {['floors'] = 0,['area_id']= 22,
	[1] = {4199.99975585938,2799.99987792969,1666.66662597656,3449.99975585938,-1133.33325195312,-750.0},}
	mapData['Ashenvale'] = {['floors'] = 0,['area_id']= 44,
	[1] = {5766.66638183594,3843.74987792969,4672.91650390625,1699.99987792969,829.166625976562,-4066.66650390625},}
	mapData['StonetalonMountains'] = {['floors'] = 0,['area_id']= 82,
	[1] = {4883.33312988281,3256.24981689453,2916.66650390625,3245.83325195312,-339.583312988281,-1637.49987792969},}
	mapData['HallsofReflection'] = {['floors'] = 1,['area_id']= 604,
	[1] = {879.02001953125,586.01953125,5126.990234375,1469.98999023438,5713.009765625,2349.01000976562},}
	mapData['IsleofConquest'] = {['floors'] = 0,['area_id']= 541,
	[1] = {2650.0,1766.66658401489,1708.33325195312,525.0,-58.3333320617676,-2125.0},}
	mapData['Stormwind'] = {['floors'] = 0,['area_id']= 302,
	[1] = {1737.499958992,1158.3330078125,-7995.8330078125,1722.91662597656,-9154.166015625,-14.5833330154419},}
	mapData['TheExodar'] = {['floors'] = 0,['area_id']= 472,
	[1] = {1056.7705078125,704.687744140625,-3609.68334960938,-11066.3671875,-4314.37109375,-12123.1376953125},}
	mapData['IcecrownCitadel'] = {['floors'] = 8,['area_id']= 605,
	[1] = {1355.47009277344,903.647033691406,-764.840026855469,1384.32995605469,138.807006835938,2739.80004882812},
	[2] = {1067.0,711.333690643311,-754.6669921875,1631.0,-43.3333015441895,2698.0},
	[3] = {195.469970703125,130.315002441406,-580.31298828125,2116.330078125,-449.997985839844,2311.80004882812},
	[4] = {773.710083007812,515.810302734375,4012.40991210938,1993.56994628906,4528.22021484375,2767.28002929688},
	[5] = {1148.73999023438,765.820068359375,4002.40991210938,2216.06005859375,4768.22998046875,3364.80004882812},
	[6] = {373.7099609375,249.1298828125,4455.75,2586.57006835938,4704.8798828125,2960.28002929688},
	[7] = {293.260009765625,195.507019042969,410.2919921875,-2271.55004882812,605.799011230469,-1978.2900390625},
	[8] = {247.929931640625,165.287994384766,414.108001708984,-2648.26000976562,579.39599609375,-2400.330078125},}
	mapData['TheArgentColiseum'] = {['floors'] = 2,['area_id']= 544,
	[1] = {369.986186981201,246.657989501953,446.360992431641,-41.255199432373,693.018981933594,328.730987548828},
	[2] = {739.996017456055,493.330017089844,433.023986816406,-211.259994506836,926.35400390625,528.736022949219},}
	mapData['Ulduar77'] = {['floors'] = 1,['area_id']= 527,
	[1] = {920.196014404297,613.466064453125,762.443969726562,206.324005126953,1375.91003417969,1126.52001953125},}
	mapData['Dragonblight'] = {['floors'] = 0,['area_id']= 489,
	[1] = {5608.33312988281,3739.58337402344,5575.0,3627.08325195312,1835.41662597656,-1981.24987792969},}
	mapData['Hilsbrad'] = {['floors'] = 0,['area_id']= 25,
	[1] = {3199.99987792969,2133.33325195312,400.0,1066.66662597656,-1733.33325195312,-2133.33325195312},}
	mapData['Barrens'] = {['floors'] = 0,['area_id']= 12,
	[1] = {10133.3330078125,6756.24987792969,1612.49987792969,2622.91650390625,-5143.75,-7510.41650390625},}
	mapData['WesternPlaguelands'] = {['floors'] = 0,['area_id']= 23,
	[1] = {4299.99990844727,2866.66653442383,3366.66650390625,416.666656494141,499.999969482422,-3883.33325195312},}
	mapData['Darkshore'] = {['floors'] = 0,['area_id']= 43,
	[1] = {6549.99975585938,4366.66650390625,8333.3330078125,2941.66650390625,3966.66650390625,-3608.33325195312},}
	mapData['DrakTharonKeep'] = {['floors'] = 2,['area_id']= 535,
	[1] = {619.941009521484,413.293991088867,-595.859985351562,-927.010009765625,-182.565994262695,-307.069000244141},
	[2] = {619.941009521484,413.293991088867,-595.859985351562,-1002.01000976562,-182.565994262695,-382.069000244141},}
	mapData['HallsofLightning'] = {['floors'] = 2,['area_id']= 526,
	[1] = {566.235015869141,377.489990234375,1157.05004882812,-282.549011230469,1534.5400390625,283.686004638672},
	[2] = {708.237014770508,472.160034179688,959.719970703125,-538.549011230469,1431.88000488281,169.688003540039},}
	mapData['DeadwindPass'] = {['floors'] = 0,['area_id']= 33,
	[1] = {2499.99993896484,1666.6669921875,-9866.666015625,-833.333312988281,-11533.3330078125,-3333.33325195312},}
	mapData['Teldrassil'] = {['floors'] = 0,['area_id']= 42,
	[1] = {5091.66650390625,3393.75,11831.25,3814.58325195312,8437.5,-1277.08325195312},}
	mapData['Nagrand'] = {['floors'] = 0,['area_id']= 478,
	[1] = {5525.0,3683.33316802979,41.6666641235352,10295.8330078125,-3641.66650390625,4770.8330078125},}
	mapData['Badlands'] = {['floors'] = 0,['area_id']= 18,
	[1] = {2487.5,1658.33349609375,-5889.5830078125,-2079.16650390625,-7547.91650390625,-4566.66650390625},}
	mapData['Alterac'] = {['floors'] = 0,['area_id']= 16,
	[1] = {2799.99993896484,1866.66665649414,1500.0,783.333312988281,-366.666656494141,-2016.66662597656},}
	mapData['LochModan'] = {['floors'] = 0,['area_id']= 36,
	[1] = {2758.33312988281,1839.5830078125,-4487.5,-1993.74987792969,-6327.0830078125,-4752.0830078125},}
	mapData['StrandoftheAncients'] = {['floors'] = 0,['area_id']= 513,
	[1] = {1743.74993896484,1162.49993896484,1883.33325195312,787.5,720.833312988281,-956.249938964844},}
	mapData['Redridge'] = {['floors'] = 0,['area_id']= 37,
	[1] = {2170.83325195312,1447.916015625,-8575.0,-1570.83325195312,-10022.916015625,-3741.66650390625},}
	mapData['Moonglade'] = {['floors'] = 0,['area_id']= 242,
	[1] = {2308.33325195312,1539.5830078125,8491.666015625,-1381.25,6952.0830078125,-3689.58325195312},}
	mapData['Ghostlands'] = {['floors'] = 0,['area_id']= 464,
	[1] = {3300.0,2199.99951171875,8266.666015625,-5283.3330078125,6066.66650390625,-8583.3330078125},}
	mapData['TheObsidianSanctum'] = {['floors'] = 0,['area_id']= 532,
	[1] = {1162.49991798401,775.0,3616.66650390625,1133.33325195312,2841.66650390625,-29.1666660308838},}
	mapData['BlastedLands'] = {['floors'] = 0,['area_id']= 20,
	[1] = {3349.99987792969,2233.333984375,-10566.666015625,-1241.66662597656,-12800.0,-4591.66650390625},}
	mapData['Wetlands'] = {['floors'] = 0,['area_id']= 41,
	[1] = {4135.41668701172,2756.25,-2147.91650390625,-389.583312988281,-4904.16650390625,-4525.0},}
	mapData['VioletHold'] = {['floors'] = 1,['area_id']= 537,
	[1] = {256.22900390625,170.820068359375,1813.34997558594,665.346984863281,1984.17004394531,921.575988769531},}
	mapData['NetherstormArena'] = {['floors'] = 0,['area_id']= 483,
	[1] = {2270.83319091797,1514.58337402344,2918.75,2660.41650390625,1404.16662597656,389.583312988281},}
	mapData['ThousandNeedles'] = {['floors'] = 0,['area_id']= 62,
	[1] = {4399.99969482422,2933.3330078125,-3966.66650390625,-433.333312988281,-6899.99951171875,-4833.3330078125},}
	mapData['TerokkarForest'] = {['floors'] = 0,['area_id']= 479,
	[1] = {5399.99975585938,3600.00006103516,-999.999938964844,7083.3330078125,-4600.0,1683.33325195312},}
	mapData['ThunderBluff'] = {['floors'] = 0,['area_id']= 363,
	[1] = {1043.74993896484,695.833312988281,-849.999938964844,516.666625976562,-1545.83325195312,-527.083312988281},}
	mapData['CoTStratholme'] = {['floors'] = 2,['area_id']= 522,
	[1] = {1824.99993896484,1216.66650390625,2297.91650390625,2152.08325195312,1081.25,327.083312988281},
	[2] = {1125.29998779297,750.199951171875,1891.76000976562,731.059997558594,2641.9599609375,1856.35998535156},}
	mapData['HowlingFjord'] = {['floors'] = 0,['area_id']= 492,
	[1] = {6045.83288574219,4031.24981689453,3116.66650390625,-1397.91662597656,-914.583312988281,-7443.74951171875},}
	mapData['SwampOfSorrows'] = {['floors'] = 0,['area_id']= 39,
	[1] = {2293.75,1529.1669921875,-9620.8330078125,-2222.91650390625,-11150.0,-4516.66650390625},}
	mapData['BladesEdgeMountains'] = {['floors'] = 0,['area_id']= 476,
	[1] = {5424.99975585938,3616.66638183594,4408.3330078125,8845.8330078125,791.666625976562,3420.83325195312},}
	mapData['UngoroCrater'] = {['floors'] = 0,['area_id']= 202,
	[1] = {3699.99981689453,2466.66650390625,-5966.66650390625,533.333312988281,-8433.3330078125,-3166.66650390625},}
	mapData['BloodmystIsle'] = {['floors'] = 0,['area_id']= 477,
	[1] = {3262.4990234375,2174.99993896484,-758.333312988281,-10075.0,-2933.33325195312,-13337.4990234375},}
	mapData['TheNexus'] = {['floors'] = 1,['area_id']= 521,
	[1] = {1101.2809753418,734.1875,64.0755004882812,-708.068969726562,798.263000488281,393.212005615234},}
	mapData['IcecrownGlacier'] = {['floors'] = 0,['area_id']= 493,
	[1] = {6270.83331298828,4181.25,9427.0830078125,5443.75,5245.8330078125,-827.083312988281},}
	mapData['Dustwallow'] = {['floors'] = 0,['area_id']= 142,
	[1] = {5250.00006103516,3499.99975585938,-2033.33325195312,-974.999938964844,-5533.3330078125,-6225.0},}
	mapData['Hellfire'] = {['floors'] = 0,['area_id']= 466,
	[1] = {5164.5830078125,3443.74987792969,1481.25,5539.5830078125,-1962.49987792969,375.0},}
	mapData['SilvermoonCity'] = {['floors'] = 0,['area_id']= 481,
	[1] = {1211.45849609375,806.7705078125,10153.708984375,-6400.75,9346.9384765625,-7612.20849609375},}
	mapData['Stranglethorn'] = {['floors'] = 0,['area_id']= 38,
	[1] = {6381.24975585938,4254.166015625,-11168.75,2220.83325195312,-15422.916015625,-4160.41650390625},}
	mapData['ShadowmoonValley'] = {['floors'] = 0,['area_id']= 474,
	[1] = {5500.0,3666.66638183594,-1947.91662597656,4225.0,-5614.5830078125,-1275.0},}
	mapData['Mulgore'] = {['floors'] = 0,['area_id']= 10,
	[1] = {5137.49987792969,3424.99984741211,-272.916656494141,2047.91662597656,-3697.91650390625,-3089.58325195312},}
	mapData['Azeroth'] = {['floors'] = 0,['area_id']= 15,
	[1] = {40741.181640625,27149.6875,11176.34375,18171.970703125,-15973.34375,-22569.2109375},}
	mapData['Aszhara'] = {['floors'] = 0,['area_id']= 182,
	[1] = {5070.83276367188,3381.24987792969,5341.66650390625,-3277.08325195312,1960.41662597656,-8347.916015625},}
	mapData['ShattrathCity'] = {['floors'] = 0,['area_id']= 482,
	[1] = {1306.25,870.833374023438,-1473.95446777344,6135.2587890625,-2344.78784179688,4829.0087890625},}
	mapData['Westfall'] = {['floors'] = 0,['area_id']= 40,
	[1] = {3499.99981689453,2333.3330078125,-9400.0,3016.66650390625,-11733.3330078125,-483.333312988281},}
	mapData['VaultofArchavon'] = {['floors'] = 1,['area_id']= 533,
	[1] = {1398.25500488281,932.170013427734,-634.080017089844,-812.518981933594,298.089996337891,585.736022949219},}
	mapData['UtgardePinnacle'] = {['floors'] = 2,['area_id']= 525,
	[1] = {548.936019897461,365.957015991211,186.919998168945,-697.559020996094,552.877014160156,-148.623001098633},
	[2] = {756.179943084717,504.119003295898,157.839004516602,-747.557983398438,661.9580078125,8.6219596862793},}
	mapData['Dalaran'] = {['floors'] = 2,['area_id']= 505,
	[1] = {830.015014648438,553.33984375,5513.330078125,222.494995117188,6066.669921875,1052.51000976562},
	[2] = {563.223999023438,375.48974609375,5599.85009765625,352.64599609375,5975.33984375,915.869995117188},}
	mapData['Tirisfal'] = {['floors'] = 0,['area_id']= 21,
	[1] = {4518.74987792969,3012.49981689453,3837.49975585938,3033.33325195312,824.999938964844,-1485.41662597656},}
	mapData['Silithus'] = {['floors'] = 0,['area_id']= 262,
	[1] = {3483.333984375,2322.916015625,-5958.333984375,2537.5,-8281.25,-945.833984375},}
	mapData['Gundrak'] = {['floors'] = 1,['area_id']= 531,
	[1] = {905.033050537109,603.35009765625,1465.52001953125,259.886993408203,2068.8701171875,1164.92004394531},}
	mapData['TheEyeofEternity'] = {['floors'] = 1,['area_id']= 528,
	[1] = {430.070068359375,286.713012695312,611.127990722656,1036.7099609375,897.841003417969,1466.78002929688},}
	mapData['SholazarBasin'] = {['floors'] = 0,['area_id']= 494,
	[1] = {4356.25,2904.16650390625,7287.49951171875,6929.16650390625,4383.3330078125,2572.91650390625},}
	mapData['Tanaris'] = {['floors'] = 0,['area_id']= 162,
	[1] = {6899.99952697754,4600.0,-5875.0,-218.749984741211,-10475.0,-7118.74951171875},}
	mapData['Felwood'] = {['floors'] = 0,['area_id']= 183,
	[1] = {5749.99963378906,3833.33325195312,7133.3330078125,1641.66662597656,3299.99975585938,-4108.3330078125},}
	mapData['SearingGorge'] = {['floors'] = 0,['area_id']= 29,
	[1] = {2231.24984741211,1487.49951171875,-6100.0,-322.916656494141,-7587.49951171875,-2554.16650390625},}
	mapData['Duskwood'] = {['floors'] = 0,['area_id']= 35,
	[1] = {2699.99993896484,1800.0,-9716.666015625,833.333312988281,-11516.666015625,-1866.66662597656},}
	mapData['Nexus80'] = {['floors'] = 4,['area_id']= 529,
	[1] = {514.706970214844,343.138977050781,877.070983886719,787.252990722656,1220.2099609375,1301.9599609375},
	[2] = {664.706970214844,443.138977050781,927.070983886719,712.252990722656,1370.2099609375,1376.9599609375},
	[3] = {514.706970214844,343.138977050781,927.070983886719,787.252990722656,1270.2099609375,1301.9599609375},
	[4] = {294.700988769531,196.463989257812,990.406005859375,897.258972167969,1186.86999511719,1191.9599609375},}
	mapData['Ahnkahet'] = {['floors'] = 1,['area_id']= 523,
	[1] = {972.41796875,648.279022216797,200.404998779297,-1205.71997070312,848.684020996094,-233.302001953125},}
	mapData['Northrend'] = {['floors'] = 0,['area_id']= 486,
	[1] = {17751.3984375,11834.2650146484,10593.375,9217.15234375,-1240.89001464844,-8534.24609375},}
	mapData['Hinterlands'] = {['floors'] = 0,['area_id']= 27,
	[1] = {3850.0,2566.66662597656,1466.66662597656,-1575.0,-1100.0,-5425.0},}
	mapData['DunMorogh'] = {['floors'] = 0,['area_id']= 28,
	[1] = {4924.99975585938,3283.33325195312,-3877.08325195312,1802.08325195312,-7160.41650390625,-3122.91650390625},}
	mapData['Feralas'] = {['floors'] = 0,['area_id']= 122,
	[1] = {6949.99975585938,4633.3330078125,-2366.66650390625,5441.66650390625,-6999.99951171875,-1508.33325195312},}
	mapData['AlteracValley'] = {['floors'] = 0,['area_id']= 402,
	[1] = {4237.49987792969,2824.99987792969,1085.41662597656,1781.24987792969,-1739.58325195312,-2456.25},}
	mapData['Ulduar'] = {['floors'] = 6,['area_id']= 530,
	[1] = {3287.49987792969,2191.66662597656,1168.75,1583.33325195312,-1022.91662597656,-1704.16662597656},
	[2] = {669.450988769531,446.300048828125,1392.7099609375,-445.234985351562,1839.01000976562,224.216003417969},
	[3] = {1328.46099853516,885.639892578125,1679.0400390625,-674.739990234375,2564.67993164062,653.721008300781},
	[4] = {910.5,607.0,1612.0,-315.75,2219.0,594.75},
	[5] = {1569.4599609375,1046.30004882812,2122.53002929688,1684.98999023438,3168.830078125,3254.44995117188},
	[6] = {619.468994140625,412.97998046875,1834.77001953125,-310.014007568359,2247.75,309.454986572266},}
	mapData['UtgardeKeep'] = {['floors'] = 3,['area_id']= 524,
	[1] = {734.580993652344,489.721500396729,25.6665000915527,-310.406005859375,515.388000488281,424.174987792969},
	[2] = {481.081008911133,320.720293045044,-16.3332996368408,-238.156005859375,304.386993408203,242.925003051758},
	[3] = {736.581008911133,491.054512023926,-75.3335037231445,-510.906005859375,415.721008300781,225.675003051758},}
	mapData['ScarletEnclave'] = {['floors'] = 0,['area_id']= 503,
	[1] = {3162.5,2108.33337402344,3087.5,-4047.91650390625,979.166625976562,-7210.41650390625},}
	mapData['LakeWintergrasp'] = {['floors'] = 0,['area_id']= 502,
	[1] = {2974.99987792969,1983.33325195312,5716.66650390625,4329.16650390625,3733.33325195312,1354.16662597656},}
	mapData['ZulDrak'] = {['floors'] = 0,['area_id']= 497,
	[1] = {4993.75,3329.16650390625,7668.74951171875,-600.0,4339.5830078125,-5593.75},}
	mapData['BoreanTundra'] = {['floors'] = 0,['area_id']= 487,
	[1] = {5764.5830078125,3843.74987792969,4897.91650390625,8570.8330078125,1054.16662597656,2806.25},}
	mapData['EasternPlaguelands'] = {['floors'] = 0,['area_id']= 24,
	[1] = {4031.25,2687.49987792969,3704.16650390625,-2287.5,1016.66662597656,-6318.75},}
	mapData['Desolace'] = {['floors'] = 0,['area_id']= 102,
	[1] = {4495.8330078125,2997.91656494141,452.083312988281,4233.3330078125,-2545.83325195312,-262.5},}
	mapData['Zangarmarsh'] = {['floors'] = 0,['area_id']= 468,
	[1] = {5027.08349609375,3352.08325195312,1935.41662597656,9475.0,-1416.66662597656,4447.91650390625},}
	mapData['Durotar'] = {['floors'] = 0,['area_id']= 5,
	[1] = {5287.49963378906,3524.99987792969,1808.33325195312,-1962.49987792969,-1716.66662597656,-7249.99951171875},}
	mapData['Kalimdor'] = {['floors'] = 0,['area_id']= 14,
	[1] = {36799.810546875,24533.2001953125,12799.900390625,17066.599609375,-11733.2998046875,-19733.2109375},}
	mapData['BurningSteppes'] = {['floors'] = 0,['area_id']= 30,
	[1] = {2929.16659545898,1952.08349609375,-7031.24951171875,-266.666656494141,-8983.3330078125,-3195.83325195312},}
	mapData['WorldMap'] = { ['floors'] = 0, ['area_id'] = 0,
	[1] = {47714.278579261,31809.64857610083,0,0,0,0},}
	-- Create Reverse map
	for k,v in pairs(mapData) do
		idToMap[v['area_id']] = k
	end
	
	-- Build the localized name list
	local continentList = {GetMapContinents()}
	for cID = 1, #continentList do
		for zID, zname in ipairs({GetMapZones(cID)}) do
			SetMapZoom(cID, zID)
			local mapfile = GetMapInfo()
			mapToLocal[mapfile] = zname
		end
	end
end

--[[
	The upper lft, lower right coords are the position within the continent map
	so to figure out location on a given continent, we need to upscale the x,y to the continent
--]]

--- API to get distance and direction to a target in the same map
-- @param mapfile to use
-- @param targetX coords
-- @param targetY coords
-- @return distance,angle where distance is yards and angle is radians

function lib:DistanceAndDirection(mapfile,floor,targetX, targetY)
	local srcX,srcY = GetPlayerMapPosition("player")
	local distance,xd,yd = self:Distance(mapfile,floor,srcX,srcY,targetX,targetY)
	local radians =  atan2(xd,-yd)
	if radians > 0 then
		radians = PI2 - radians
	else
		radians = -radians
	end
	return distance,radians
end

--- API to calc the distance between 2 locations within the same mapfile
-- @param mapfile or area_id
-- @param floor to use
-- @param srcX starting x
-- @param srcY starting y
-- @param dstX destination x
-- @param dstY destination y
-- @return distance, xdelta, ydelta where distance is the total distance, xdelta is the delta of the x values and ydelta is the detla of y values all in yards
function lib:Distance(mapfile,floor, srcX,srcY,dstX,dstY)
	assert(floor == nil or (type(floor) == "number" and floor))
	local width = 0
	local height = 0
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	if floor and floor <= mapData[mapfile]['floors'] and floor > 0 then
		width, height  = mapData[mapfile][floor][1],mapData[mapfile][floor][2] 
	else
		width,height = mapData[mapfile][1][1], mapData[mapfile][1][2]
	end
	local x = (dstX - srcX) * width
	local y = (dstY - srcY) * height
	return (x*x + y*y)^0.5,x,y
end

--- API to convert coords to yards
-- @param mapfile or area_id
-- @param floor
-- @param x coord
-- @param y coord
-- @return x,y as yards
function lib:PointToYards(mapfile,floor, x, y)
	assert(floor == nil or (type(floor) == "number" and floor))
	local width = 0
	local height = 0
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	if floor and floor <= mapData[mapfile]['floors'] and floor > 0 then
		width, height  = mapData[mapfile][floor][1],mapData[mapfile][floor][2] 
	else
		width,height = mapData[mapfile][1][1], mapData[mapfile][1][2]
	end
	return x * width, y * height
end

--- API to get the number of floors of a given map
-- @param mapfile the mapfile you wish to check or area id from GetCurrentMapAreaID()
-- @return number of floors or 0 if no floors exist
-- @usage floors = lib:MapFloors(GetMapInfo())
function lib:MapFloors(mapfile)
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	return mapData[mapfile]['floors']
end

--- API to get area id for a given map file
-- @param mapfile to check
-- @return area_id or 0 if the map doesnt exist
-- @usage aid = lib:MapAreaId(GetMapInfo())
function lib:MapAreaId(mapfile)
	return mapData[mapfile]['area_id']
end

--- API to get localized name of a given map file
-- @param mapfile or area id to check
-- @return the localized map name or nil
-- @usage lname = lib:MapLocalized(GetMapInfo())
function lib:MapLocalize(mapfile)
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	return mapToLocal[mapfile]
end

--- API to get the width,height of a given map
-- @param mapfile you wish to interrogate or area id from GetCurrentMapAreaID()
-- @param floor optional floor you wish to examine
-- @return width,height in yards or 0,0 if no data exists. Will add a message to the DEFAULT_CHAT_FRAME
-- @usage local w,h = lib:MapArea(GetMapInfo(),GetCurrentMapDungeonLevel())
function lib:MapArea(mapfile,floor)
	assert(floor == nil or (type(floor) == "number" and floor))
	if type(mapfile) == "number" then
		-- Hook for Toc
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	if floor and floor <= mapData[mapfile]['floors'] and floor > 0 then
		return mapData[mapfile][floor][1],mapData[mapfile][floor][2] 
	else
		if floor and floor > 0 then
			return 0,0
		end
		return mapData[mapfile][1][1], mapData[mapfile][1][2]
	end
end


--- API to get the upper left x,y of a given map
-- @param mapfile you wish to interrogate or area id from GetCurrentMapAreaID()
-- @param floor optional floor you wish to examine
-- @return x,y or the upper left corner or 0,0 if no data exists. Will add a message to the DEFAULT_CHAT_FRAME
-- @usage local x,y = lib:MapUpperLeft(GetMapInfo(),GetCurrentMapDungeonLevel())
function lib:MapUpperLeft(mapfile, floor)
	assert(floor == nil or (floor and floor > 0))
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	if floor and floor <= mapData[mapfile]['floors'] then
		return mapData[mapfile][floor + 1][3],mapData[mapfile][floor + 1][4]
	else
		if floor and floor > 0 then
			return 0,0
		end
		return mapData[mapfile][1][3],mapData[mapfile][1][4]
	end
end

--- API to get the lower right x,y of a given map
-- @param mapfile you wish to interrogate or area id from GetCurrentMapAreaID()
-- @param floor optional floor you wish to examine
-- @return x,y or the lower right corner or 0,0 if no data exists. Will add a message to the DEFAULT_CHAT_FRAME
-- @usage local x,y = lib:MapLowerRight(GetMapInfo(),GetCurrentMapDungeonLevel())
function lib:MapLowerRight(mapfile, floor)
	assert(floor == nil or (floor and floor > 0))
	if type(mapfile) == "number" then
		if mapfile == 543 then mapfile = 544 end
		mapfile = idToMap[mapfile]
	end
	if floor and floor <= mapData[mapfile]['floors'] then
		return mapData[mapfile][floor + 1][5],mapData[mapfile][floor + 1][6]
	else
		if floor and floor > 0 then
			return 0,0
		end
		return mapData[mapfile][1][5],mapData[mapfile][1][6]
	end
end

--- API to force a zone change check
-- calling this method will fire a callback
-- @param force, optional if you want to force a check even if data hasnt changed
-- @return void
function lib:ZoneChanged(force)
	if WorldMapFrame:IsVisible() then return end
	SetMapToCurrentZone()
	local x,y = GetPlayerMapPosition("player")
	-- if the player is in an instance without a map then dont fire anything
	if x == 0 and y == 0 then
		return
	end
	local map = GetMapInfo()
	local floor = GetCurrentMapDungeonLevel()
	if map ~= lastMap or floor ~= lastFloor or force then
		local w,h = self:MapArea(map,floor)
		self.callbacks:Fire("MapChanged",map,floor,w,h)
		lastMap = map
		lastFloor = floor
	end
end

-- Turn on events on someone registers for them
function lib.callbacks:OnUsed()
	watchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	watchFrame:RegisterEvent("ZONE_CHANGED")
	watchFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	watchFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	lib:ZoneChanged(true)
end

-- turn off events once we no longer have listeners
function lib.callbacks:OnUnused()
	watchFrame:UnregisterAllEvents()	
end
watchFrame:SetScript("OnEvent", function(frame,event,...) 
	lib:ZoneChanged(false) 
end)

--@alpha@
function lib:Test()
-- Validate map files are all present.
for continent in pairs({GetMapContinents()}) do
	local zones = { GetMapZones(continent) }
	print("Continent "..continent)
	for zone, name in pairs(zones) do
		SetMapZoom(continent, zone)
		local mapFile = GetMapInfo()
		local area_id = GetCurrentMapAreaID()
		local w,h = self:MapArea(mapFile)
		local aid = self:MapAreaId(mapFile)
		if w == 0 and h == 0 then
			error("Failed to find map "..mapFile)
		end
		if area_id ~= aid then
			error(mapFile.." area id mismatch")
		end
	end
end
print("All Tests passed")
end
--@end-alpha@