local E, L, V, P, G = unpack(ElvUI)
local FC = E:NewModule("Enhanced_FogClear", "AceHook-3.0")

local _G = _G
local pairs = pairs
local ceil, fmod, floor = math.ceil, math.fmod, math.floor
local format, len, lower, sub = string.format, string.len, string.lower, string.sub
local tinsert, twipe = table.insert, table.wipe

local GetMapInfo = GetMapInfo
local GetMapOverlayInfo = GetMapOverlayInfo
local GetNumMapOverlays = GetNumMapOverlays

local worldMapCache = {}
local discoveredOverlays = {}

local errata = {
	-- Eastern Kingdoms
	["Alterac"] = {
		["CHILLWINDPOINT"] = 272313469278,
		["CORRAHNSDAGGER"] = 408440570051,
		["CRUSHRIDGEHOLD"] = 174296645912,
		["DALARAN"] = 281347928364,
		["DANDREDSFOLD"] = 289642781,
		["GALLOWSCORNER"] = 299999895752,
		["GAVINSNAZE"] = 513484700832,
		["GROWLESSCAVE"] = 399764531390,
		["LORDAMEREINTERNMENTCAMP"] = 432764364106,
		["MISTYSHORE"] = 140865986780,
		["RUINSOFALTERAC"] = 211810516223,
		["SOFERASNAZE"] = 330123510015,
		["STRAHNBRAD"] = 113318867314,
		["THEHEADLAND"] = 506061853861,
		["THEUPLANDS"] = 83162767595,
	},
--[[
	["AlteracValley"] = {
		["DUNBALDAR"] = 14323794190,
		["FROSTWOLFKEEP"] = 403071863019,
		["ICEBLOODGARRISON"] = 185035174188,
	},
]]
	["Arathi"] = {
		["BOULDERFISTHALL"] = 389147765975,
		["BOULDERGOR"] = 155936085237,
		["CIRCLEOFEASTBINDING"] = 120844425376,
		["CIRCLEOFINNERBINDING"] = 333160047826,
		["CIRCLEOFOUTERBINDING"] = 315045866666,
		["CIRCLEOFWESTBINDING"] = 58126977214,
		["DABYRIESFARMSTEAD"] = 177662544052,
		["FALDIRSCOVE"] = 455446060288,
		["GOSHEKFARM"] = 296909737190,
		["HAMMERFALL"] = 129536092365,
		["NORTHFOLDMANOR"] = 96838336742,
		["REFUGEPOINT"] = 200104182959,
		["STROMGARDEKEEP"] = 308277385456,
		["THANDOLSPAN"] = 442754101448,
		["THORADINSWALL"] = 148267843774,
		["WITHERBARKVILLAGE"] = 358142396631,
	},
	["Badlands"] = {
		["AGMONDSEND"] = 418047605001,
		["ANGORFORTRESS"] = 159254782147,
		["APOCRYPHANSREST"] = 332878053632,
		["CAMPBOFF"] = 366671585535,
		["CAMPCAGG"] = 459574345984,
		["CAMPKOSH"] = 52117598428,
		["DUSTWINDGULCH"] = 224934442229,
		["HAMMERTOESDIGSITE"] = 129315835080,
		["KARGATH"] = 158914052352,
		["LETHLORRAVINE"] = 118752746866,
		["MIRAGEFLATS"] = 412472312064,
		["THEDUSTBOWL"] = 213841628430,
		["THEMAKERSTERRACE"] = 7924298997,
		["VALLEYOFFANGS"] = 275244095718,
	},
	["BlastedLands"] = {
		["ALTAROFSTORMS"] = 143132880057,
		["DARKPORTAL"] = 278574362889,
		["DREADMAULHOLD"] = 16484847811,
		["DREADMAULPOST"] = 209758391541,
		["GARRISONARMORY"] = 10158809258,
		["NETHERGARDEKEEP"] = 32798603449,
		["RISEOFTHEDEFILER"] = 132495066282,
		["SERPENTSCOIL"] = 150849366241,
		["THETAINTEDSCAR"] = 191348803968,
	},
	["BurningSteppes"] = {
		["ALTAROFSTORMS"] = 117075833057,
		["BLACKROCKMOUNTAIN"] = 108629614848,
		["BLACKROCKPASS"] = 300191897870,
		["BLACKROCKSTRONGHOLD"] = 122757063925,
		["DRACODAR"] = 277084433823,
		["DREADMAULROCK"] = 181130200284,
		["MORGANSVIGIL"] = 334676375846,
		["PILLAROFASH"] = 306412009792,
		["RUINSOFTHAURISSAN"] = 106838652174,
		["TERRORWINGPATH"] = 50149559576,
	},
	["DeadwindPass"] = {
		["DEADMANSCROSSING"] = 81865848188,
		["KARAZHAN"] = 362133312812,
		["THEVICE"] = 321495775502,
	},
	["DunMorogh"] = {
		["AMBERSTILLRANCH"] = 301248675968,
		["ANVILMAR"] = 432880674032,
		["BREWNALLVILLAGE"] = 267626073203,
		["CHILLBREEZEVALLEY"] = 318115020980,
		["COLDRIDGEPASS"] = 413700063382,
		["FROSTMANEHOLD"] = 308391572605,
		["GNOMERAGON"] = 197742728372,
		["GOLBOLARQUARRY"] = 313096574117,
		["HELMSBEDLAKE"] = 293859403931,
		["ICEFLOWLAKE"] = 179609718912,
		["IRONFORGE"] = 175436407099,
		["KHARANOS"] = 316085051592,
		["MISTYPINEREFUGE"] = 237823497344,
		["NORTHERNGATEOUTPOST"] = 186553373824,
		["SHIMMERRIDGE"] = 175383967872,
		["SOUTHERNGATEOUTPOST"] = 300404564096,
		["THEGRIZZLEDDEN"] = 334263149768,
		["THETUNDRIDHILLS"] = 346292355227,
	},
	["Duskwood"] = {
		["ADDLESSTEAD"] = 367277631763,
		["BRIGHTWOODGROVE"] = 126156624092,
		["DARKSHIRE"] = 174608113979,
		["MANORMISTMANTLE"] = 129533918408,
		["RAVENHILL"] = 324377134275,
		["RAVENHILLCEMETARY"] = 160076968286,
		["THEDARKENEDBANK"] = 33379535758,
		["THEHUSHEDBANK"] = 141754181792,
		["THEROTTINGORCHARD"] = 396776151290,
		["THEYORGENFARMSTEAD"] = 410578577643,
		["TRANQUILGARDENSCEMETARY"] = 379754606812,
		["TWILIGHTGROVE"] = 85138510184,
		["VULGOLOGREMOUND"] = 373917250815,
	},
	["EasternPlaguelands"] = {
		["BLACKWOODLAKE"] = 190484578560,
		["CORINSCROSSING"] = 370935070976,
		["CROWNGUARDTOWER"] = 407222092032,
		["DARROWSHIRE"] = 501730168064,
		["EASTWALLTOWER"] = 235739021568,
		["LAKEMERELDAR"] = 442878866688,
		["LIGHTSHOPECHAPEL"] = 298114613504,
		["NORTHDALE"] = 114435555584,
		["NORTHPASSTOWER"] = 93863543040,
		["PLAGUEWOOD"] = 65644298624,
		["PestilentScar"] = 289455505664,
		["QUELLITHIENLODGE"] = 15443689728,
		["STRATHOLME"] = 172215552,
		["ScarletEnclave"] = 234829056284,
		["TERRORDALE"] = 81656021248,
		["THEFUNGALVALE"] = 256877265152,
		["THEMARRISSTEAD"] = 363057119488,
		["THENOXIOUSGLADE"] = 155344699648,
		["THEUNDERCROFT"] = 488701623552,
		["THONDRORILRIVER"] = 224412434688,
		["TYRSHAND"] = 482830652672,
		["TheInfectisScar"] = 347216281856,
		["ZULMASHAR"] = 9202565376,
	},
	["Elwynn"] = {
		["BRACKWELLPUMPKINPATCH"] = 450503107840,
		["CRYSTALLAKE"] = 356925010145,
		["EASTVALELOGGINGCAMP"] = 355073214720,
		["FARGODEEPMINE"] = 459811307776,
		["FORESTSEDGE"] = 351243949312,
		["GOLDSHIRE"] = 290172662000,
		["JERODSLANDING"] = 463228613888,
		["NORTHSHIREVALLEY"] = 158239817984,
		["RIDGEPOINTTOWER"] = 467807741234,
		["STONECAIRNLAKE"] = 204626723126,
		["STORMWIND"] = 415205,
		["TOWEROFAZORA"] = 314110634239,
	},
	["EversongWoods"] = {
		["AzurebreezeCoast"] = 245514895616,
		["DuskwitherGrounds"] = 272291332352,
		["EastSanctum"] = 400988307712,
		["ElrendarFalls"] = 429031424128,
		["FairbreezeVilliage"] = 414869356800,
		["FarstriderRetreat"] = 386022899968,
		["GoldenboughPass"] = 503839850752,
		["LakeElrendar"] = 506344969344,
		["NorthSanctum"] = 320353861888,
		["RuinsofSilvermoon"] = 146351063296,
		["RunestoneFalithas"] = 532972482816,
		["RunestoneShandor"] = 530915178752,
		["SatherilsHaven"] = 412656861440,
		["SilvermoonCity"] = 93877436928,
		["StillwhisperPond"] = 337652220160,
		["SunsailAnchorage"] = 434034049280,
		["SunstriderIsle"] = 5573706240,
		["TheGoldenStrand"] = 445795005568,
		["TheLivingWood"] = 451507642496,
		["TheScortchedGrove"] = 544654622976,
		["ThuronsLivery"] = 328056570112,
		["TorWatha"] = 338908513536,
		["TranquilShore"] = 320200769792,
		["WestSanctum"] = 342830088320,
		["Zebwatha"] = 510608475264,
	},
	["Ghostlands"] = {
		["AmaniPass"] = 249735598484,
		["BleedingZiggurat"] = 255743754496,
		["DawnstarSpire"] = 603193771,
		["Deatholme"] = 402753099264,
		["ElrendarCrossing"] = 342098432,
		["FarstriderEnclave"] = 146629984685,
		["GoldenmistVillage"] = 46662144,
		["HowlingZiggurat"] = 235506435328,
		["IsleofTribulations"] = 613679360,
		["SanctumoftheMoon"] = 135511933184,
		["SanctumoftheSun"] = 161531560192,
		["SuncrownVillage"] = 482607616,
		["ThalassiaPass"] = 436321130752,
		["Tranquillien"] = 2530738432,
		["WindrunnerSpire"] = 308206108928,
		["WindrunnerVillage"] = 125691232512,
		["ZebNowa"] = 254965890560,
	},
	["Hilsbrad"] = {
		["AZURELOADMINE"] = 295462707365,
		["DARROWHILL"] = 165790510285,
		["DUNGAROK"] = 316348321008,
		["DURNHOLDEKEEP"] = 81165399424,
		["EASTERNSTRAND"] = 364548260070,
		["HILLSBRADFIELDS"] = 166637882673,
		["NETHANDERSTEAD"] = 253970596055,
		["PURGATIONISLE"] = 517657956477,
		["SOUTHPOINTTOWER"] = 206160758048,
		["SOUTHSHORE"] = 216260688107,
		["TARRENMILL"] = 534042844,
		["WESTERNSTRAND"] = 395355254045,
	},
	["Hinterlands"] = {
		["AERIEPEAK"] = 263080588543,
		["AGOLWATHA"] = 176486026445,
		["HIRIWATHA"] = 328744509665,
		["JINTHAALOR"] = 358085850347,
		["PLAGUEMISTRAVINE"] = 160153432209,
		["QUELDANILLODGE"] = 198890949817,
		["SERADANE"] = 20935101715,
		["SHADRAALOR"] = 415789933763,
		["SHAOLWATHA"] = 257223243032,
		["SKULKROCK"] = 249645122720,
		["THEALTAROFZUL"] = 392307053768,
		["THECREEPINGRUIN"] = 279600867508,
		["THEOVERLOOKCLIFFS"] = 326070753450,
		["VALORWINDLAKE"] = 324604700842,
	},
	["LochModan"] = {
		["GRIZZLEPAWRIDGE"] = 333184342311,
		["IRONBANDSEXCAVATIONSITE"] = 345176801625,
		["MOGROSHSTRONGHOLD"] = 52108176699,
		["NORTHGATEPASS"] = 13016281318,
		["SILVERSTREAMMINE"] = 12051560683,
		["STONESPLINTERVALLEY"] = 373887890687,
		["STONEWROUGHTDAM"] = 12166806818,
		["THEFARSTRIDERLODGE"] = 214247447922,
		["THELOCH"] = 93785057600,
		["THELSAMAR"] = 218197367040,
		["VALLEYOFKINGS"] = 397399025859,
	},
	["Redridge"] = {
		["ALTHERSMILL"] = 138931353835,
		["GALARDELLVALLEY"] = 173558458618,
		["LAKEEVERSTILL"] = 257837780503,
		["LAKERIDGEHIGHWAY"] = 357752408494,
		["LAKESHIRE"] = 211614371156,
		["REDRIDGECANYONS"] = 77436540269,
		["RENDERSCAMP"] = 290717971,
		["RENDERSVALLEY"] = 388128570833,
		["STONEWATCH"] = 231379087615,
		["STONEWATCHFALLS"] = 344221501760,
		["THREECORNERS"] = 304943036781,
	},
	["SearingGorge"] = {
		["BLACKCHARCAVE"] = 393070488851,
		["DUSTFIREVALLEY"] = 9032807884,
		["FIREWATCHRIDGE"] = 32301824405,
		["GRIMSILTDIGSITE"] = 322640769329,
		["TANNERCAMP"] = 437584632113,
		["THECAULDRON"] = 182798587305,
		["THESEAOFCINDERS"] = 416871113064,
	},
	["Silverpine"] = {
		["AMBERMILL"] = 281838600432,
		["BERENSPERIL"] = 446117892336, -- 448265375984
		["DEEPELEMMINE"] = 280739621024,
		["FENRISISLE"] = 80078920954,
		["MALDENSORCHARD"] = 487751936,
		["NORTHTIDESHOLLOW"] = 137777774772,
		["OLSENSFARTHING"] = 270983685285,
		["PYREWOODVILLAGE"] = 479298974860,
		["SHADOWFANGKEEP"] = 385855160540,
		["THEDEADFIELD"] = 70214915247,
		["THEDECREPITFERRY"] = 155098211508,
		["THEGREYMANEWALL"] = 480360226002,
		["THESEPULCHER"] = 180757889234,
		["THESHININGSTRAND"] = 14440165632,
		["THESKITTERINGDARK"] = 40028509369,
	},
	["Stranglethorn"] = {
		["BALALRUINS"] = 99037036634,
		["BALIAMAHRUINS"] = 138901860462,
		["BLOODSAILCOMPOUND"] = 305146281125,
		["BOOTYBAY"] = 465143201937,
		["CRYSTALVEINMINE"] = 296714625144,
		["GROMGOLBASECAMP"] = 142006658158,
		["JAGUEROISLE"] = 529684095101,
		["KALAIRUINS"] = 94802902111,
		["KURZENSCOMPOUND"] = 407001243,
		["LAKENAZFERITI"] = 63697974400,
		["MISTVALEVALLEY"] = 395430720637,
		["MIZJAHRUINS"] = 140986398825,
		["MOSHOGGOGREMOUND"] = 101384895616,
		["NEKMANIWELLSPRING"] = 385694682202,
		["NESINGWARYSEXPEDITION"] = 28199467148,
		["REBELCAMP"] = 297887914,
		["RUINSOFABORAZ"] = 360070610015,
		["RUINSOFJUBUWAL"] = 323517266030,
		["RUINSOFZULKUNDA"] = 3426889853,
		["RUINSOFZULMAMWE"] = 228046533802,
		["THEARENA"] = 203183809736,
		["THEVILEREEF"] = 96796327102,
		["VENTURECOBASECAMP"] = 69125403753,
		["WILDSHORE"] = 453359368357,
		["ZIATAJAIRUINS"] = 248416171136,
		["ZULGURUB"] = 9096622325,
		["ZUULDAIARUINS"] = 45260852339,
	},
	["Sunwell"] = {
		["SunsReachHarbor"] = 270847607296,
		["SunsReachSanctum"] = 4558684672,
	},
	["SwampOfSorrows"] = {
		["FALLOWSANCTUARY"] = 516212077,
		["ITHARIUSSCAVE"] = 281320609008,
		["MISTYREEDSTRAND"] = 782921984,
		["MISTYVALLEY"] = 150324167925,
		["POOLOFTEARS"] = 234668444972,
		["SORROWMURK"] = 129608561879,
		["SPLINTERSPEARJUNCTION"] = 253538582803,
		["STAGALBOG"] = 406453479769,
		["STONARD"] = 254769687912,
		["THEHARBORAGE"] = 155872081131,
		["THESHIFTINGMIRE"] = 118411734331,
	},
	["Tirisfal"] = {
		["AGAMANDMILLS"] = 149601601792,
		["BALNIRFARMSTEAD"] = 350700621016,
		["BRIGHTWATERLAKE"] = 149862777033, -- 149865922761
		["BRILL"] = 321612152960,
		["BULWARK"] = 389426656486,
		["COLDHEARTHMANOR"] = 351610732694,
		["CRUSADEROUTPOST"] = 311039230125,
		["DEATHKNELL"] = 352425555189,
		["GARRENSHAUNT"] = 156213932206,
		["MONASTARY"] = 135000159443,
		["NIGHTMAREVALE"] = 375116733683,
		["RUINSOFLORDAERON"] = 388106530107,
		["SCARLETWATCHPOST"] = 112391871663,
		["SOLLIDENFARMSTEAD"] = 268686225664,
		["STILLWATERPOND"] = 297840804026,
		["VENOMWEBVALE"] = 220911065325,
	},
	["WesternPlaguelands"] = {
		["CAERDARROW"] = 443010946218,
		["DALSONSTEARS"] = 284941244636,
		["DARROWMERELAKE"] = 368822204786,
		["FELSTONEFIELD"] = 334248408224,
		["GAHRRONSWITHERING"] = 268980925620,
		["HEARTHGLEN"] = 17502077268,
		["NORTHRIDGELUMBERCAMP"] = 176494399708,
		["RUINSOFANDORHOL"] = 381451213085,
		["SORROWHILL"] = 496441178412,
		["THEBULWARK"] = 314750199009,
		["THEWEEPINGCAVE"] = 213194580128,
		["THEWRITHINGHAUNT"] = 347291711658,
		["THONDRORILRIVER"] = 92960805069,
	},
	["Westfall"] = {
		["ALEXSTONFARMSTEAD"] = 279386999089,
		["DEMONTSPLACE"] = 402871477448,
		["FURLBROWSPUMPKINFARM"] = 12217179346,
		["GOLDCOASTQUARRY"] = 109752615137,
		["JANGOLODEMINE"] = 31460646103,
		["MOONBROOK"] = 355741147356,
		["SALDEANSFARM"] = 113224403169,
		["SENTINELHILL"] = 259235496131,
		["THEDAGGERHILLS"] = 449179729152,
		["THEDEADACRE"] = 271132639432,
		["THEDUSTPLAINS"] = 405349313824,
		["THEJANSENSTEAD"] = 511910053,
		["THEMOLSENFARM"] = 159257933025,
		["WESTFALLLIGHTHOUSE"] = 501652584728,
	},
	["Wetlands"] = {
		["ANGERFANGENCAMPMENT"] = 234439763169,
		["BLACKCHANNELMARSH"] = 263147666672,
		["BLUEGILLMARSH"] = 152564857057,
		["DIREFORGEHILL"] = 124012194048,
		["DUNMODR"] = 22969241805,
		["GRIMBATOL"] = 247601668446,
		["IRONBEARDSTOMB"] = 123846452424,
		["MENETHILHARBOR"] = 337168695471,
		["MOSSHIDEFEN"] = 284020692173,
		["RAPTORRIDGE"] = 189637230782,
		["SALTSPRAYGLEN"] = 44272173256,
		["SUNDOWNMARSH"] = 88143544620,
		["THEGREENBELT"] = 134696124601,
		["THELGANROCK"] = 398851242214,
		["WHELGARSEXCAVATIONSITE"] = 220376261827,
	},

	-- Kalimdor
	["Ashenvale"] = {
		["ASTRANAAR"] = 269794600141,
		["BOUGHSHADOW"] = 163032801426,
		["FALLENSKYLAKE"] = 457987798251,
		["FELFIREHILL"] = 370115083509,
		["FIRESCARSHRINE"] = 348090711205,
		["IRISLAKE"] = 234486969544,
		["LAKEFALATHIM"] = 147240193152,
		["MAESTRASPOST"] = 41017459927,
		["MYSTRALLAKE"] = 372961952019,
		["NIGHTRUN"] = 277651651809,
		["RAYNEWOODRETREAT"] = 256096064692,
		["SATYRNAAR"] = 242319811869,
		["THEHOWLINGVALE"] = 151883277522,
		["THERUINSOFSTARDUST"] = 400778483867,
		["THESHRINEOFAESSINA"] = 278208384220,
		["THEZORAMSTRAND"] = 30084945141,
		["THISTLEFURVILLAGE"] = 169864269055,
		["WARSONGLUMBERCAMP"] = 334768537800,
	},
	["Aszhara"] = {
		["BAYOFSTORMS"] = 216324681998,
		["BITTERREACHES"] = 43625145589,
		["FORLORNRIDGE"] = 396411272412,
		["HALDARRENCAMPMENT"] = 355489437896,
		["JAGGEDREEF"] = 383953466,
		["LAKEMENNAR"] = 460945826107,
		["LEGASHENCAMPMENT"] = 47746003179,
		["RAVENCRESTMONUMENT"] = 536376112368,
		["RUINSOFELDARATH"] = 237546791177,
		["SHADOWSONGSHRINE"] = 453155934433,
		["SOUTHRIDGEBEACH"] = 379438985586,
		["TEMPLEOFARKKORAN"] = 164996784318,
		["THALASSIANBASECAMP"] = 128298675440,
		["THERUINEDREACHES"] = 580235952523,
		["THESHATTEREDSTRAND"] = 208729753760,
		["TIMBERMAWHOLD"] = 114079054059,
		["TOWEROFELDARA"] = 115748269176,
		["URSOLAN"] = 102448192657,
		["VALORMOK"] = 245975137495,
	},
	["AzuremystIsle"] = {
		["AmmenFord"] = 300114247936,
		["AmmenVale"] = 112222274011,
		["AzureWatch"] = 267763581184,
		["BristlelimbVillage"] = 389950996736,
		["Emberglade"] = 26281771264,
		["FairbridgeStrand"] = 373424384,
		["GreezlesCamp"] = 376341528832,
		["MoongrazeWoods"] = 196965826816,
		["OdesyusLanding"] = 406243770624,
		["PodCluster"] = 327786168576,
		["PodWreckage"] = 375220600960,
		["SiltingShore"] = 3526623488,
		["SilvermystIsle"] = 478913198336,
		["StillpineHold"] = 52996342016,
		["TheExodar"] = 91346174464,
		["ValaarsBerth"] = 325528584448,
		["WrathscalePoint"] = 452276247808,
	},
	["Barrens"] = {
		["AGAMAGOR"] = 251612292296,
		["BAELMODAN"] = 514774401152,
		["BLACKTHORNRIDGE"] = 496420126875,
		["BOULDERLODEMINE"] = 582072440,
		["BRAMBLESCAR"] = 320438703229,
		["CAMPTAURAJO"] = 376192496785,
		["DREADMISTPEAK"] = 68085195904,
		["FARWATCHPOST"] = 56426140772,
		["FIELDOFGIANTS"] = 432016611538,
		["GROLDOMFARM"] = 68161752189,
		["HONORSSTAND"] = 139907432576,
		["LUSHWATEROASIS"] = 190435222703,
		["NORTHWATCHFOLD"] = 330191462550,
		["RAPTORGROUNDS"] = 316211837043,
		["RATCHET"] = 203520341117,
		["RAZORFENDOWNS"] = 594206117019,
		["RAZORFENKRAUL"] = 576957055104,
		["THECROSSROADS"] = 127153630363,
		["THEDRYHILLS"] = 31471060168,
		["THEFORGOTTENPOOLS"] = 123883091064,
		["THEMERCHANTCOAST"] = 265823555679,
		["THEMORSHANRAMPART"] = 432115840,
		["THESLUDGEFEN"] = 478273706,
		["THESTAGNANTOASIS"] = 227064021147,
		["THORNHILL"] = 128297599116,
	},
	["BloodmystIsle"] = {
		["AmberwebPass"] = 66618654976,
		["Axxarien"] = 146340577536,
		["BlacksiltShore"] = 457599863296,
		["Bladewood"] = 224797131008,
		["BloodWatch"] = 277483880704,
		["BloodscaleIsle"] = 275678232815,
		["BristlelimbEnclave"] = 440806932736,
		["KesselsCrossing"] = 566404199909,
		["Middenvale"] = 436373553408,
		["Mystwood"] = 518941500672,
		["Nazzivian"] = 434054103296,
		["RagefeatherRidge"] = 126132420864,
		["RuinsofLorethAran"] = 232511504640,
		["TalonStand"] = 84441039104,
		["TelathionsCamp"] = 232117108864,
		["TheBloodcursedReef"] = 58746732800,
		["TheBloodwash"] = 29307961600,
		["TheCrimsonReach"] = 93997760768,
		["TheCryoCore"] = 306323915008,
		["TheFoulPool"] = 146260885760,
		["TheHiddenReef"] = 42091151616,
		["TheLostFold"] = 505186294016,
		["TheVectorCoil"] = 255596083712,
		["TheWarpPiston"] = 31611683072,
		["VeridianPoint"] = 668205312,
		["VindicatorsRest"] = 260089053440,
		["WrathscaleLair"] = 363552047360,
		["WyrmscarIsland"] = 88689869056,
	},
	["Darkshore"] = {
		["AMETHARAN"] = 328904946878,
		["AUBERDINE"] = 174279842966,
		["BASHALARAN"] = 194730200244,
		["CLIFFSPRINGRIVER"] = 101325142246,
		["GROVEOFTHEANCIENTS"] = 442701621448,
		["REMTRAVELSEXCAVATION"] = 521005096111,
		["RUINSOFMATHYSTRA"] = 534994115,
		["THEMASTERSGLAIVE"] = 547953473711,
		["TOWEROFALTHALAXX"] = 91758988458,
	},
	["Desolace"] = {
		["ETHELRETHOR"] = 65824614605,
		["GELKISVILLAGE"] = 457721497795,
		["KODOGRAVEYARD"] = 262399060243,
		["KOLKARVILLAGE"] = 231491203292,
		["KORMEKSHUT"] = 194929393834,
		["MAGRAMVILLAGE"] = 392534717645,
		["MANNOROCCOVEN"] = 408440561949,
		["NIJELSPOINT"] = 581167304,
		["RANAZJARISLE"] = 6695260260,
		["SARGERON"] = 36089091357,
		["SHADOWBREAKRAVINE"] = 477465087181,
		["SHADOWPREYVILLAGE"] = 417860917478,
		["TETHRISARAN"] = 452084941,
		["THUNDERAXEFORTRESS"] = 109990604990,
		["VALLEYOFSPEARS"] = 231077082357,
	},
	["Durotar"] = {
		["DRYGULCHRAVINE"] = 84199768274,
		["ECHOISLES"] = 459063673032,
		["KOLKARCRAG"] = 511534293152,
		["ORGRIMMAR"] = 256016829,
		["RAZORHILL"] = 182989330652,
		["RAZORMANEGROUNDS"] = 203253061862,
		["SENJINVILLAGE"] = 412814080160,
		["SKULLROCK"] = 35920132224,
		["THUNDERRIDGE"] = 64767598782,
		["TIRAGARDEKEEP"] = 307574788286,
		["VALLEYOFTRIALS"] = 343969848535,
	},
	["Dustwallow"] = {
		["ALCAZISLAND"] = 23240838344,
		["BACKBAYWETLANDS"] = 203188075920,
		["BRACKENWALLVILLAGE"] = 241449240,
		["THEDENOFFLAME"] = 336350931199,
		["THERAMOREISLE"] = 241078318310,
		["THEWYRMBOG"] = 409480708381,
		["WITCHHILL"] = 442821882,
	},
	["Felwood"] = {
		["BLOODVENOMFALLS"] = 282700432619,
		["DEADWOODVILLAGE"] = 572732349615,
		["EMERALDSANCTUARY"] = 461060079801,
		["FELPAWVILLAGE"] = 506610928,
		["IRONTREEWOODS"] = 58422680791,
		["JADEFIREGLEN"] = 499638234277,
		["JADEFIRERUN"] = 31484717251,
		["JAEDENAR"] = 355692839157,
		["MORLOSARAN"] = 547054845073,
		["RUINSOFCONSTELLAS"] = 409407220971,
		["SHATTERSCARVALE"] = 132392362219,
		["TALONBRANCHGLADE"] = 97211532448,
	},
	["Feralas"] = {
		["CAMPMOJACHE"] = 250904477851,
		["DIREMAUL"] = 216298360038,
		["DREAMBOUGH"] = 476181654,
		["FERALSCARVALE"] = 353770785907,
		["FRAYFEATHERHIGHLANDS"] = 414965737582,
		["GORDUNNIOUTPOST"] = 152121283724,
		["GRIMTOTEMCOMPOUND"] = 179968347256,
		["ISLEOFDREAD"] = 402854810839,
		["LOWERWILDS"] = 213388546273,
		["ONEIROS"] = 75678988398,
		["RUINSOFISILDIEN"] = 344163870910,
		["RUINSOFRAVENWIND"] = 319974590,
		["SARDORISLE"] = 251473875124,
		["THEFORGOTTENCOAST"] = 275301859473,
		["THETWINCOLOSSALS"] = 80865383709,
		["THEWRITHINGDEEP"] = 320623309040,
	},
	["Moonglade"] = {
		["LAKEELUNEARA"] = 95819397675,
	},
	["Mulgore"] = {
		["BAELDUNDIGSITE"] = 230048321746,
		["BLOODHOOFVILLAGE"] = 325728805120,
		["PALEMANEROCK"] = 329956668544,
		["RAVAGEDCARAVAN"] = 279668973696,
		["REDCLOUDMESA"] = 456623640022,
		["REDROCKS"] = 17706490061,
		["THEGOLDENPLAINS"] = 86348382423,
		["THEROLLINGPLAINS"] = 382800689408,
		["THEVENTURECOMINE"] = 256108637409,
		["THUNDERBLUFF"] = 63612109080,
		["THUNDERHORNWATERWELL"] = 260243090560,
		["WILDMANEWATERWELL"] = 305266873,
		["WINDFURYRIDGE"] = 414318797,
		["WINTERHOOFWATERWELL"] = 396691112106,
	},
	["Silithus"] = {
		["HIVEASHI"] = 13163102720,
		["HIVEREGAL"] = 306273714688,
		["HIVEZORA"] = 154721059200,
		["SOUTHWINDVILLAGE"] = 70317900160,
		["THECRYSTALVALE"] = 25879151936,
		["THESCARABWALL"] = 443577270560,
		["TWILIGHTBASECAMP"] = 211888111936,
	},
	["StonetalonMountains"] = {
		["BOULDERSLIDERAVINE"] = 602969058449,
		["CAMPAPARAJE"] = 613859558590,
		["GRIMTOTEMPOST"] = 553677611233,
		["MALAKAJIN"] = 625613035645,
		["MIRKFALLONLAKE"] = 156101729480,
		["SISHIRCANYON"] = 465428411517,
		["STONETALONPEAK"] = 259208462,
		["SUNROCKRETREAT"] = 344005433494,
		["THECHARREDVALE"] = 251476151526,
		["WEBWINDERPATH"] = 303274757408,
		["WINDSHEARCRAG"] = 212107283776,
	},
	["Tanaris"] = {
		["ABYSSALSANDS"] = 208686731479,
		["BROKENPILLAR"] = 251751747694,
		["CAVERNSOFTIME"] = 275466311835,
		["DUNEMAULCOMPOUND"] = 310652323021,
		["EASTMOONRUINS"] = 371929012384,
		["GADGETZAN"] = 98152125615,
		["LANDSENDBEACH"] = 549148849357,
		["LOSTRIGGERCOVE"] = 236882950304,
		["NOONSHADERUINS"] = 112228179064,
		["SANDSORROWWATCH"] = 107687886019,
		["SOUTHBREAKSHORE"] = 315129773271,
		["SOUTHMOONRUINS"] = 385812220099,
		["STEAMWHEEDLEPORT"] = 81151547547,
		["THEGAPINGCHASM"] = 399902984412,
		["THENOXIOUSLAIR"] = 213939069108,
		["THISTLESHRUBVALLEY"] = 307303278777,
		["VALLEYOFTHEWATCHERS"] = 466309251222,
		["WATERSPRINGFIELD"] = 180922536101,
		["ZALASHJISDEN"] = 158480871534,
		["ZULFARRAK"] = 266517714,
	},
	["Teldrassil"] = {
		["BANETHILHOLLOW"] = 302122223776,
		["DARNASSUS"] = 265320399163,
		["DOLANAAR"] = 347303182526,
		["GNARLPINEHOLD"] = 476053635257,
		["LAKEALAMETH"] = 408479261952,
		["POOLSOFARLITHRIEN"] = 336432658560,
		["RUTTHERANVILLAGE"] = 588928618624,
		["SHADOWGLEN"] = 164797580513,
		["STARBREEZEVILLAGE"] = 314121068744,
		["THEORACLEGLADE"] = 136650670250,
		["WELLSPRINGLAKE"] = 100253565108,
	},
	["ThousandNeedles"] = {
		["CAMPETHOK"] = 317745,
		["DARKCLOUDPINNACLE"] = 140931960013,
		["FREEWINDPOST"] = 283842377938,
		["HIGHPERCH"] = 166462683326,
		["SPLITHOOFCRAG"] = 206568623314,
		["THEGREATLIFT"] = 75377070290,
		["THESCREECHINGCANYON"] = 214936305914,
		["THESHIMMERINGFLATS"] = 322762552640,
		["WINDBREAKCANYON"] = 268951580912,
	},
	["UngoroCrater"] = {
		["FIREPLUMERIDGE"] = 191511148839,
		["GOLAKKAHOTSPRINGS"] = 162262246715,
		["IRONSTONEPLATEAU"] = 72551265565,
		["LAKKARITARPITS"] = 6610495034,
		["TERRORRUN"] = 395302958425,
		["THEMARSHLANDS"] = 258285604150,
		["THESLITHERINGSCAR"] = 408407012697,
	},
	["Winterspring"] = {
		["DARKWHISPERGORGE"] = 473989068031,
		["EVERLOOK"] = 115424305317,
		["FROSTFIREHOTSPRINGS"] = 184916521200,
		["FROSTSABERROCK"] = 7902253306,
		["FROSTWHISPERGORGE"] = 404275495112,
		["ICETHISTLEHILLS"] = 260486370429,
		["LAKEKELTHERIL"] = 213021549783,
		["MAZTHORIL"] = 277542523065,
		["OWLWINGTHICKET"] = 365694169253,
		["STARFALLVILLAGE"] = 147513835705,
		["THEHIDDENGROVE"] = 29573178543,
		["TIMBERMAWPOST"] = 261159510246,
		["WINTERFALLVILLAGE"] = 170298307729,
	},

	-- Outland
	["BladesEdgeMountains"] = {
		["BashirLanding"] = 442761472,
		["BladedGulch"] = 158493573376,
		["BladesipreHold"] = 173202205952,
		["BloodmaulCamp"] = 102437748992,
		["BloodmaulOutpost"] = 398717134080,
		["BrokenWilds"] = 117806727424,
		["CircleofWrath"] = 225946370304,
		["DeathsDoor"] = 267899014400,
		["ForgeCampAnger"] = 158454776224,
		["ForgeCampTerror"] = 446827852288,
		["ForgeCampWrath"] = 189245161728,
		["Grishnath"] = 30364926208,
		["GruulsLayer"] = 87525949696,
		["JaggedRidge"] = 444997040384,
		["MokNathalVillage"] = 319591547136,
		["RavensWood"] = 59280458240,
		["RazorRidge"] = 357041520896,
		["RidgeofMadness"] = 277606721792,
		["RuuanWeald"] = 105729491200,
		["Skald"] = 76941623552,
		["Sylvanaar"] = 376113002752,
		["TheCrystalpine"] = 613679360,
		["ThunderlordStronghold"] = 292482855168,
		["VeilLashh"] = 459845910784,
		["VeilRuuan"] = 162725495040,
		["VekhaarStand"] = 436598997248,
		["VortexPinnacle"] = 221365352704,
	},
	["Hellfire"] = {
		["DenofHaalesh"] = 442572734720,
		["ExpeditionArmory"] = 443729313280,
		["FalconWatch"] = 350232074752,
		["FallenSkyRidge"] = 152507252992,
		["ForgeCampRage"] = 27345289728,
		["HellfireCitadel"] = 225840670976,
		["HonorHold"] = 320467108096,
		["MagharPost"] = 118327869696,
		["PoolsofAggonar"] = 48660742400,
		["RuinsofShanaar"] = 311411730688,
		["TempleofTelhamat"] = 163249127936,
		["TheLegionFront"] = 138046603520,
		["TheStairofDestiny"] = 168277049600,
		["Thrallmar"] = 165846188288,
		["ThroneofKiljaeden"] = 6942884352,
		["VoidRidge"] = 395876499712,
		["WarpFields"] = 438409892096,
		["ZethGor"] = 462317402534,
	},
	["Nagrand"] = {
		["BurningBladeRUins"] = 359322171648,
		["ClanWatch"] = 390326386944,
		["ForgeCampFear"] = 266326151680,
		["ForgeCampHate"] = 165526372608,
		["Garadar"] = 153997279488,
		["Halaa"] = 207583707392,
		["KilsorrowFortress"] = 459073111296,
		["LaughingSkullRuins"] = 56202887424,
		["OshuGun"] = 358806272512,
		["RingofTrials"] = 287248220416,
		["SouthwindCleft"] = 277435646208,
		["SunspringPost"] = 213904523520,
		["Telaar"] = 419165372672,
		["ThroneoftheElements"] = 57437061376,
		["TwilightRidge"] = 114901385472,
		["WarmaulHill"] = 34524627200,
		["WindyreedPass"] = 85452914944,
		["WindyreedVillage"] = 250880459008,
		["ZangarRidge"] = 58272776448,
	},
	["Netherstorm"] = {
		["Area52"] = 416864665856,
		["ArklonRuins"] = 426619699456,
		["CelestialRidge"] = 186432880896,
		["EcoDomeFarfield"] = 11152916736,
		["EtheriumStagingGrounds"] = 223842926848,
		["ForgeBaseOG"] = 23871095040,
		["KirinVarVillage"] = 562080924928,
		["ManaforgeBanar"] = 301875989760,
		["ManaforgeCoruu"] = 525434277120,
		["ManaforgeDuro"] = 361265103104,
		["ManafrogeAra"] = 166609551616,
		["Netherstone"] = 21906063616,
		["NetherstormBridge"] = 315818770688,
		["RuinedManaforge"] = 148714553600,
		["RuinsofEnkaat"] = 323461841152,
		["RuinsofFarahlon"] = 52984807936,
		["SocretharsSeat"] = 41042575616,
		["SunfuryHold"] = 484733838592,
		["TempestKeep"] = 305564877209,
		["TheHeap"] = 488803357952,
		["TheScrapField"] = 280620171520,
		["TheStormspire"] = 144194142464,
	},
	["ShadowmoonValley"] = {
		["AltarofShatar"] = 100403511552,
		["CoilskarPoint"] = 8955363840,
		["EclipsePoint"] = 333219994112,
		["IlladarPoint"] = 275028115712,
		["LegionHold"] = 166539559424,
		["NetherwingCliffs"] = 331293655296,
		["NetherwingLedge"] = 478350114284,
		["ShadowmoonVilliage"] = 37703123456,
		["TheBlackTemple"] = 135927431564,
		["TheDeathForge"] = 138817306880,
		["TheHandofGuldan"] = 97050427904,
		["TheWardensCage"] = 277517593088,
		["WildhammerStronghold"] = 246063488512,
	},
	["TerokkarForest"] = {
		["AllerianStronghold"] = 297930064128,
		["AuchenaiGrounds"] = 466263189760,
		["BleedingHollowClanRuins"] = 323304668416,
		["BonechewerRuins"] = 295825572096,
		["CarrionHill"] = 292453351680,
		["CenarionThicket"] = 329515264,
		["FirewingPoint"] = 160635027841,
		["GrangolvarVilliage"] = 183760060928,
		["RaastokGlade"] = 165886034176,
		["RazorthornShelf"] = 20902576384,
		["RefugeCaravan"] = 288094421120,
		["RingofObservance"] = 370766250240,
		["SethekkTomb"] = 310568550656,
		["ShattrathCity"] = 4404544000,
		["SkethylMountains"] = 374133293568,
		["SmolderingCaravan"] = 494258045184,
		["StonebreakerHold"] = 177583948032,
		["TheBarrierHills"] = 4416864512,
		["Tuurem"] = 36984848640,
		["VeilRhaze"] = 388927586560,
		["WrithingMound"] = 351551095040,
	},
	["Zangarmarsh"] = {
		["AngoroshGrounds"] = 53779628288,
		["AngoroshStronghold"] = 130154752,
		["BloodscaleEnclave"] = 443006845184,
		["CenarionRefuge"] = 345399099700,
		["CoilfangReservoir"] = 97121730816,
		["FeralfenVillage"] = 356811883008,
		["MarshlightLake"] = 163293954304,
		["OreborHarborage"] = 27189051648,
		["QuaggRidge"] = 349114293504,
		["Sporeggar"] = 216917082624,
		["Telredor"] = 120856248576,
		["TheDeadMire"] = 138190258462,
		["TheHewnBog"] = 54990995712,
		["TheLagoon"] = 325880905984,
		["TheSpawningGlen"] = 364031246592,
		["TwinspireRuins"] = 267720589568,
		["UmbrafenVillage"] = 495750167808,
		["ZabraJin"] = 249291866368,
	},

	-- Northrend
	["BoreanTundra"] = {
		["AmberLedge"] = 150664861940,
		["BorGorokOutpost"] = 329461132,
		["Coldarra"] = 52819404,
		["DeathsStand"] = 195088899361,
		["GarroshsLanding"] = 255711373579,
		["Kaskala"] = 230314799489,
		["RiplashStrand"] = 411550615934,
		["SteeljawsCaravan"] = 71283571956,
		["TempleCityOfEnKilah"] = 16853012770,
		["TheDensOfDying"] = 12505531595,
		["TheGeyserFields"] = 503667063,
		["TorpsFarm"] = 254762307770,
		["ValianceKeep"] = 283947350275,
		["WarsongStronghold"] = 254822078724,
	},
	["CrystalsongForest"] = {
		["ForlornWoods"] = 135950880,
		["SunreaversCommand"] = 43512087998,
		["TheAzureFront"] = 261993439648,
		["TheDecrepitFlow"] = 227616,
		["TheGreatTree"] = 97710772476,
		["TheUnboundThicket"] = 113267668470,
		["VioletStand"] = 188978871560,
		["WindrunnersOverlook"] = 411708978734,
	},
	["Dragonblight"] = {
		["AgmarsHammer"] = 218240346348,
		["Angrathar"] = 220449074,
		["ColdwindHeights"] = 422800597,
		["EmeraldDragonshrine"] = 389264140484,
		["GalakrondsRest"] = 127155799298,
		["IcemistVillage"] = 177308255467,
		["LakeIndule"] = 336309039460,
		["LightsRest"] = 8253626667,
		["Naxxramas"] = 172523536695,
		["NewHearthglen"] = 385043666134,
		["ObsidianDragonshrine"] = 111937793328,
		["RubyDragonshrine"] = 223730683068,
		["ScarletPoint"] = 8113195243,
		["TheCrystalVice"] = 510921957,
		["TheForgottenShore"] = 357214484781,
		["VenomSpite"] = 284161167586,
		["WestwindRefugeeCamp"] = 200834067685,
		["WyrmrestTemple"] = 235624826173,
	},
	["GrizzlyHills"] = {
		["AmberpineLodge"] = 262220843286,
		["BlueSkyLoggingGrounds"] = 138756205817,
		["CampOneqwah"] = 147677521220,
		["ConquestHold"] = 329656867148,
		["DrakTheronKeep"] = 49392416126,
		["DrakilJinRuins"] = 44660191583,
		["DunArgol"] = 276525629895,
		["GraniteSprings"] = 222272127332,
		["GrizzleMaw"] = 201165344038,
		["RageFangShrine"] = 316007623131,
		["ThorModan"] = 533977417,
		["UrsocsDen"] = 34707083592,
		["VentureBay"] = 495014067474,
		["Voldrune"] = 452230110491,
	},
	["HowlingFjord"] = {
		["AncientLift"] = 377242188977,
		["ApothecaryCamp"] = 39832528135,
		["BaelgunsExcavationSite"] = 351765054708,
		["Baleheim"] = 183140267182,
		["CampWinterHoof"] = 371410143,
		["CauldrosIsle"] = 173386418357,
		["EmberClutch"] = 218266599637,
		["ExplorersLeagueOutpost"] = 361390891240,
		["FortWildervar"] = 513999099,
		["GiantsRun"] = 600099114,
		["Gjalerbron"] = 236123378,
		["Halgrind"] = 223754853563,
		["IvaldsRuin"] = 240145081537,
		["Kamagua"] = 298604307789,
		["NewAgamand"] = 386982531356,
		["Nifflevar"] = 258322153650,
		["ScalawagPoint"] = 440410573150,
		["Skorn"] = 116324016366,
		["SteelGate"] = 107607138526,
		["TheTwistedGlade"] = 61643901194,
		["UtgardeKeep"] = 232428796152,
		["VengeanceLanding"] = 27540146399,
		["WestguardKeep"] = 193368125787,
	},
	["IcecrownGlacier"] = {
		["Aldurthar"] = 40101076341,
		["ArgentTournamentGround"] = 32858407226,
		["Corprethar"] = 421265625396,
		["IcecrownCitadel"] = 500774938932,
		["Jotunheim"] = 131020056969,
		["OnslaughtHarbor"] = 179315159244,
		["Scourgeholme"] = 287412829429,
		["SindragosasFall"] = 33942756652,
		["TheBombardment"] = 194911653112,
		["TheBrokenFront"] = 353846402331,
		["TheConflagration"] = 327834355939,
		["TheFleshwerks"] = 312687750363,
		["TheShadowVault"] = 16443129055,
		["Valhalas"] = 53914878190,
		["ValleyofEchoes"] = 419509265677,
		["Ymirheim"] = 296818523359,
	},
	["SholazarBasin"] = {
		["KartaksHold"] = 402733176137,
		["RainspeakerCanopy"] = 262440987855,
		["RiversHeart"] = 364375254484,
		["TheAvalanche"] = 99409470786,
		["TheGlimmeringPillar"] = 36830518566,
		["TheLifebloodPillar"] = 144407119160,
		["TheMakersOverlook"] = 254142609641,
		["TheMakersPerch"] = 145135755513,
		["TheMosslightPillar"] = 381456540911,
		["TheSavageThicket"] = 55176303909,
		["TheStormwrightsShelf"] = 62422024460,
		["TheSuntouchedPillar"] = 199802286535,
	},
	["TheStormPeaks"] = {
		["BorsBreath"] = 402767678786,
		["BrunnhildarVillage"] = 397640247601,
		["DunNiffelem"] = 306521177397,
		["EngineoftheMakers"] = 318159113426,
		["Frosthold"] = 460775977204,
		["GarmsBane"] = 505073040568,
		["NarvirsCradle"] = 154843462836,
		["Nidavelir"] = 221304266973,
		["SnowdriftPlains"] = 153715187917,
		["SparksocketMinefield"] = 502765134075,
		["TempleofLife"] = 121930791094,
		["TempleofStorms"] = 323447066793,
		["TerraceoftheMakers"] = 131303036267,
		["Thunderfall"] = 192857739570,
		["Ulduar"] = 228861297,
		["Valkyrion"] = 341552822500,
	},
	["ZulDrak"] = {
		["AltarOfHarKoa"] = 371000083721,
		["AltarOfMamToth"] = 95092536631,
		["AltarOfQuetzLun"] = 270145978629,
		["AltarOfRhunok"] = 136817459447,
		["AltarOfSseratus"] = 180690870509,
		["AmphitheaterOfAnguish"] = 308467202314,
		["DrakSotraFields"] = 384741680414,
		["GunDrak"] = 659858768,
		["Kolramas"] = 469623872814,
		["LightsBreach"] = 389958387009,
		["ThrymsEnd"] = 265214505232,
		["Voltarus"] = 205267438810,
		["Zeramas"] = 442389233971,
		["ZimTorga"] = 259274311929,
	},

	["*"] = {},
}

local function UpdateOverlayTextures(frame, frameName, textureCache, scale, r, g, b, alpha)
	local mapFileName = GetMapInfo()

	if not mapFileName then
		for i = 1, #textureCache do
			textureCache[i]:Hide()
		end

		return
	end

	local pathPrefix = "Interface\\WorldMap\\"..mapFileName.."\\"
	local overlayMap = errata[mapFileName]
	local numOverlays = GetNumMapOverlays()
	local pathLen = len(pathPrefix) + 1

	if not overlayMap then
		overlayMap = {}
	end

	for i = 1, numOverlays do
		local texName, texWidth, texHeight, offsetX, offsetY = GetMapOverlayInfo(i)

		if texName then
			texName = sub(texName, pathLen)

			if lower(texName) ~= "pixelfix" then
				discoveredOverlays[texName] = true

				if not overlayMap[texName] then
					local texID = texWidth + texHeight * 2^10 + offsetX * 2^20 + offsetY * 2^30

					if texID ~= 0 and texID ~= 131200 then
						overlayMap[texName] = texID
					end
				end
			end
		end
	end

	local textureCount = 0
	local numTextures = #textureCache

	for texName, texID in pairs(overlayMap) do
		local textureName = pathPrefix .. texName
		local textureWidth, textureHeight, offsetX, offsetY = fmod(texID, 2^10), fmod(floor(texID / 2^10), 2^10), fmod(floor(texID / 2^20), 2^10), floor(texID / 2^30)

		local numTexturesWide = ceil(textureWidth / 256)
		local numTexturesTall = ceil(textureHeight / 256)

		local neededTextures = textureCount + (numTexturesWide * numTexturesTall)

		if neededTextures > numTextures then
			for j = numTextures + 1, neededTextures do
				tinsert(textureCache, (frame:CreateTexture(format(frameName, j), "ARTWORK")))
			end

			numTextures = neededTextures
			FC.NUM_WORLDMAP_OVERLAYS = numTextures
			NUM_WORLDMAP_OVERLAYS = numTextures
		end

		local texture, texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

		for j = 1, numTexturesTall do
			if j < numTexturesTall then
				texturePixelHeight = 256
				textureFileHeight = 256
			else
				texturePixelHeight = fmod(textureHeight, 256)
				textureFileHeight = 16

				if texturePixelHeight == 0 then
					texturePixelHeight = 256
				end

				while textureFileHeight < texturePixelHeight do
					textureFileHeight = textureFileHeight * 2
				end
			end

			for k = 1, numTexturesWide do
				textureCount = textureCount + 1
				texture = textureCache[textureCount]

				if k < numTexturesWide then
					texturePixelWidth = 256
					textureFileWidth = 256
				else
					texturePixelWidth = fmod(textureWidth, 256)
					textureFileWidth = 16

					if texturePixelWidth == 0 then
						texturePixelWidth = 256
					end

					while textureFileWidth < texturePixelWidth do
						textureFileWidth = textureFileWidth * 2
					end
				end

				texture:Size(texturePixelWidth * scale, texturePixelHeight * scale)
				texture:Point("TOPLEFT", (offsetX + (256 * (k - 1))) * scale, -(offsetY + (256 * (j - 1))) * scale)
				texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
				texture:SetTexture(format("%s%d", textureName, ((j - 1) * numTexturesWide) + k))

				if discoveredOverlays[texName] then
					texture:SetDrawLayer("ARTWORK")
					texture:SetVertexColor(1, 1, 1)
					texture:SetAlpha(1)
				else
					texture:SetDrawLayer("BORDER")
					texture:SetVertexColor(r, g, b)
					texture:SetAlpha(alpha * 1)
				end

				texture:Show()
			end
		end
	end

	for i = textureCount + 1, numTextures do
		textureCache[i]:Hide()
	end

	twipe(discoveredOverlays)
end

function FC:UpdateWorldMapOverlays()
	if not WorldMapFrame:IsShown() then return end

	if NUM_WORLDMAP_OVERLAYS > self.NUM_WORLDMAP_OVERLAYS then
		for i = self.NUM_WORLDMAP_OVERLAYS + 1, NUM_WORLDMAP_OVERLAYS do
			tinsert(worldMapCache, i, _G[format("WorldMapOverlay%d", i)])
		end

		self.NUM_WORLDMAP_OVERLAYS = NUM_WORLDMAP_OVERLAYS
	end

	local color = E.db.enhanced.map.fogClear.color
	UpdateOverlayTextures(WorldMapDetailFrame, "WorldMapOverlay%d", worldMapCache, 1, color.r, color.g, color.b, color.a)
end

function FC:UpdateFog()
	if E.db.enhanced.map.fogClear.enable then
		self:SecureHook("WorldMapFrame_Update", "UpdateWorldMapOverlays")

		twipe(worldMapCache)
		self.NUM_WORLDMAP_OVERLAYS = 0

		if WorldMapFrame:IsShown() then
			self:UpdateWorldMapOverlays()
		end
	else
		self:UnhookAll()

		for i = 1, NUM_WORLDMAP_OVERLAYS do
			local tex = _G[format("WorldMapOverlay%d", i)]
			tex:SetDrawLayer("ARTWORK")
			tex:SetVertexColor(1, 1, 1)
			tex:SetAlpha(1)
		end

		for i = 1, #worldMapCache do
			worldMapCache[i]:Hide()
		end

		if WorldMapFrame:IsShown() then
			WorldMapFrame_Update()
		end
	end
end

function FC:Initialize()
	local _, _, _, enabled, _, reason = GetAddOnInfo("Mapster")
	if reason ~= "MISSED" and enabled then return end

	if not E.db.enhanced.map.fogClear.enable then return end

	self:UpdateFog()
end

local function InitializeCallback()
	FC:Initialize()
end

E:RegisterModule(FC:GetName(), InitializeCallback)