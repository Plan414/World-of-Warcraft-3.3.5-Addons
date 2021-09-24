local Dungeons = LibStub("AceAddon-3.0"):GetAddon("BestInSlotRedux"):NewModule("BfaDungeons")
local dungeonTierId = 80000
local bonusIds = {
  bonusids = {
    [1] = {3524},
    [2] = {3524},
    [3] = {3524}
  },
  difficultyconversion = {
    [1] = 1, --Raid Normal
    [2] = 2, --Raid Heroic
    [3] = 23, --Raid Mythic
  }
}

function Dungeons:AtalDazar()
  local ataldazar = "ataldazar"
  local name = C_Map.GetMapInfo(934).name
  self:RegisterRaidInstance(dungeonTierId, ataldazar, name, bonusIds)
  --------------------------------------------------
  ----- Atal'Dazar
  --------------------------------------------------
  

  -----------------------------------
  ----- Priestess Alun'za
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2082)
  local lootTable = {
    158321, --Wand of Zealous Purification
    158322, --Aureus Vessel
    158309, --Wristlinks of Alchemical Transfusion
    158306, --Belt of Gleaming Determination
    158347, --Cincture of Glittering Gold
    158313, --Legplates of Beaten Gold
    155861, --Embellished Ritual Sabatons
    158319, --My'das Talisman
  }
  self:RegisterBossLoot(ataldazar, lootTable, bossName)
  

  -----------------------------------
  ----- Vol'kaal
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2036)
  local lootTable = {
    159632, --Adulation Enforcer
    158375, --Drape of the Loyal Vassal
    158348, --Wraps of Everliving Fealty
    158317, --Gauntlets of Eternal Service
    159445, --Grips of the Everlasting Guardian
    155869, --Shambling Berserker's Leggings
    158320, --Revitalizing Voodoo Totem
  }
  self:RegisterBossLoot(ataldazar, lootTable, bossName)
  

  -----------------------------------
  ----- Rezan
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2083)
  local lootTable = {
    160269, --Soulrending Claw
    158711, --Hallowed Ossein Longbow
    158713, --Disc of Indomitable Will
    160214, --Venerated Raptorhide Bindings
    155868, --Kilt of Fanatical Consumption
    158303, --Devilsaur Worshiper's Sandals
    159458, --Seal of the Regal Loa
    158712, --Rezan's Gleaming Eye
  }
  self:RegisterBossLoot(ataldazar, lootTable, bossName)
  

  -----------------------------------
  ----- Yazma
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2030)
  local lootTable = {
    158323, --Soulrender's Fang
    159358, --Coif of the Court Spider
    158315, --Secret Spinner's Miter
    155866, --Soulspun Casque
    158304, --Mantle of Fastidious Machinations
    159233, --Loa Betrayer's Vestments
    155860, --Spymaster's Wrap
    160212, --Shadowshroud Vambraces
    158308, --Souldrifting Sabatons
    159610, --Vessel of Skittering Shadows
  }
  self:RegisterBossLoot(ataldazar, lootTable, bossName)
   
end

function Dungeons:Freehold()
  local freehold = "freehold"
  local name = C_Map.GetMapInfo(936).name
  self:RegisterRaidInstance(dungeonTierId, freehold, name, bonusIds)
  --------------------------------------------------
  ----- Freehold
  --------------------------------------------------
  

  -----------------------------------
  ----- Skycap'n Kragg
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2102)
  local lootTable = {
    159633, --Sharkbait's Fishhook
    155884, --NO NAME?
    159227, --Silk Cuffs of the Skycap'n
    159353, --Chain-Linked Safety Cord
    158360, --Sharkbait Harness Girdle
    155862, --Kragg's Rigging Scalers
  }
  self:RegisterBossLoot(freehold, lootTable, bossName)
  

  -----------------------------------
  ----- Council o' Captains
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2093)
  local lootTable = {
    159132, --Jolly's Boot Dagger
    159130, --Captain's Diplomacy
    158311, --Concealed Fencing Plates
    159356, --Raoul's Barrelhook Bracers
    158346, --Sailcloth Waistband
    159297, --Silver-Trimmed Breeches
    158351, --Dashing Bilge Rat Shoes
    158314, --NO NAME?
  }
  self:RegisterBossLoot(freehold, lootTable, bossName)
  

  -----------------------------------
  ----- Ring of Booty
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2094)
  local lootTable = {
    159634, --Jeweled Sharksplitter
    158305, --Sea Dog's Cuffs
    155890, --Sharktooth-Knuckled Grips
    155892, --Bite-Resistant Chain Gloves
    155889, --Sharkhide Grips
    155891, --Greasy Bacon-Grabbers
    158302, --Chum-Coated Leggings
    158361, --Sharkwater Waders
    158356, --Shell-Kickers
  }
  self:RegisterBossLoot(freehold, lootTable, bossName)
  

  -----------------------------------
  ----- Harlan Sweete
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2095)
  local lootTable = {
    159635, --Bloody Tideturner
    155886, --Smartly Plumed Cap
    155887, --Sweete's Jeweled Headgear
    155888, --Irontide Captain's Hat
    155885, --Sea-Brawler's Greathelm
    159299, --Gold-Tasseled Epaulets
    159407, --Lockjaw Shoulderplate
    159352, --Gaping Maw Shoulderguard
    158301, --NO NAME?
    155881, --NO NAME?
  }
  self:RegisterBossLoot(freehold, lootTable, bossName)
    
end

function Dungeons:KingsRest()
  local kingsrest = "kingsrest"
  local name = C_Map.GetMapInfo(1004).name
  self:RegisterRaidInstance(dungeonTierId, kingsrest, name, bonusIds)
  --------------------------------------------------
  ----- Kings' Rest
  --------------------------------------------------
  

  -----------------------------------
  ----- The Golden Serpent
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2165)
  local lootTable = {
    159137, --Gilded Serpent's Tooth
    159413, --Gauntlets of the Avian Sentinel
    159369, --Belt of the Consecrated Tomb
    159313, --Breeches of the Sacred Hall
    159234, --Down-Lined Breeches
    159412, --Auric Puddle Stompers
    159304, --Goldfeather Boots
    159617, --Lustrous Golden Plumage
  }
  self:RegisterBossLoot(kingsrest, lootTable, bossName)
  

  -----------------------------------
  ----- Mchimba the Embalmer
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2171)
  local lootTable = {
    159642, --Royal Purifier's Spade
    159667, --Vessel of Last Rites
    159409, --Embalmer's Steadying Bracers
    159312, --Desiccator's Blessed Gloves
    160213, --Sepulchral Construct's Gloves
    159459, --Ritual Binder's Ring
    159618, --Mchimba's Ritual Bandages
  }
  self:RegisterBossLoot(kingsrest, lootTable, bossName)
  

  -----------------------------------
  ----- The Council of Tribes
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2170)
  local lootTable = {
    160216, --Crackling Jade Kilij
    159136, --Jeweled Dagger of Subjugation
    159643, --Crossbow of Forgotten Majesty
    159288, --Cloak of the Restless Tribes
    159300, --Kula's Butchering Wristwraps
    159418, --Girdle of Pestilent Purification
    159371, --Boots of the Headlong Conqueror
    159243, --Sandals of Wise Voodoo
  }
  self:RegisterBossLoot(kingsrest, lootTable, bossName)
  

  -----------------------------------
  ----- Dazar, The First King
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2172)
  local lootTable = {
    159921, --Mummified Raptor Skull
    159644, --Geti'ikku, Cut of Death
    159645, --Headcracker of Supplication
    159236, --Headdress of the First Empire
    159422, --Helm of the Raptor King
    158344, --Mantle of Ceremonial Ascension
    159423, --Pauldrons of the Great Unifier
    159368, --Spaulders of Prime Emperor
    158355, --Loa-Blessed Chestguard
    159303, --Vest of Reverent Adoration
    159301, --Primal Dinomancer's Belt
  }
  self:RegisterBossLoot(kingsrest, lootTable, bossName)
  
end

function Dungeons:ShrineOfTheStorm()
  local shrineofthestorm = "shrineofthestorm"
  local name = C_Map.GetMapInfo(1039).name
  self:RegisterRaidInstance(dungeonTierId, shrineofthestorm, name, bonusIds)
  --------------------------------------------------
  ----- Shrine of the Storm
  --------------------------------------------------
  

  -----------------------------------
  ----- Aqu'sirr
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2153)
  local lootTable = {
    159321, --Gloves of Corrupted Waters
    159366, --Water Shapers
    159239, --Aqu'sirr's Swirling Sash
    159420, --Stormsurger's Sabatons
    158318, --Murky Cerulean Signet
    159619, --Briny Barnacle
  }
  self:RegisterBossLoot(shrineofthestorm, lootTable, bossName)
  

  -----------------------------------
  ----- Tidesage Council
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2154)
  local lootTable = {
    158371, --Seabreeze
    159426, --Belt of the Unrelenting Gale
    159419, --Ironhull's Reinforced Legplates
    159359, --Sea Priest's Greaves
    159311, --Blessing Bearer's Waders
    159295, --Footpads of the Serene Wake
    159614, --Galecaller's Boon
  }
  self:RegisterBossLoot(shrineofthestorm, lootTable, bossName)
  

  -----------------------------------
  ----- Lord Stormsong
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2155)
  local lootTable = {
    159646, --Aq'mar, the Tidecaller
    159289, --Void-Drenched Cape
    159364, --Bindings of the Calling Depths
    159308, --Bracers of the Sacred Fleet
    159421, --Gauntlets of Total Subservience
    159242, --Leggings of the Drowned Lord
  }
  self:RegisterBossLoot(shrineofthestorm, lootTable, bossName)
  

  -----------------------------------
  ----- Vol'zith the Whisperer
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2156)
  local lootTable = {
    159135, --Deep Fathom's Bite
    159302, --Cowl of Fluid Machinations
    159430, --Helm of Abyssal Malevolence
    159244, --Stormlurker's Cowl
    159238, --Mantle of Void-Touched Waters
    159307, --Tentacle-Laced Spaulders
    159408, --Chestguard of the Deep Denizen
    159354, --Hauberk of Sunken Despair
    159377, --Chain of Consummate Power
    159620, --Conch of Dark Whispers
  }
  self:RegisterBossLoot(shrineofthestorm, lootTable, bossName)
end

function Dungeons:SiegeOfBoralus()
    local siegeofboralus = "siegeofboralus"
  local name = C_Map.GetMapInfo(1162).name
  self:RegisterRaidInstance(dungeonTierId, siegeofboralus, name, bonusIds)
  --------------------------------------------------
  ----- Siege of Boralus
  --------------------------------------------------
  if UnitFactionGroup("player") == "Alliance" then
    -----------------------------------
    ----- Chopper Redhook (Alliance)
    -----------------------------------
    local bossName = EJ_GetEncounterInfo(2132)
    local lootTable = {
    159972, --Mutineer's Fate 
    159973, --Boarder's Billy Club 
    159968, --Gloves of the Iron Reavers 
    159965, --Redhook's Cummerbund 
    159427, --Legplates of the Irontide Raider 
    159969, --Powdershot Leggings 
    159251, --Top-Sail Footwraps 
    162541, --Band of the Roving Scalawag
    }  
    self:RegisterBossLoot(siegeofboralus, lootTable, bossName)  
  else
    -----------------------------------
    ----- Sergeant Bainbridge
    -----------------------------------
    local bossName = EJ_GetEncounterInfo(2133)
    local lootTable = {
      159647, --Siegebreaker's Halberd
      159648, --Bainbridge's Blackjack
      159328, --Wharf Warden's Gloves
      159245, --Cord of the Pious Warder
      159411, --Legplates of the Maritime Guard
      159367, --Unstoppable Zealot's Legplates
      159278, --Slippers of Unwavering Faith
      162542, --Seal of the City Watch
    }
    self:RegisterBossLoot(siegeofboralus, lootTable, bossName)
  end
  

  -----------------------------------
  ----- Dread Captain Lockwood
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2173)
  local lootTable = {
    159649, --Saber of Dread Pirate Lockwood
    159372, --Dread Captain's Irons
    159237, --Captain's Dustfinders
    159429, --Rope-Scored Gauntlets
    159434, --Cannoneer's Toolbelt
    159309, --Port Pillager's Belt
    159250, --Powder Monkey's Leggings
    159320, --Besieger's Deckstalkers
    159379, --Sure-Foot Sabatons
    159623, --Dead-Eye Spyglass
  }
  self:RegisterBossLoot(siegeofboralus, lootTable, bossName)
  

  -----------------------------------
  ----- Hadal Darkfathom
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2134)
  local lootTable = {
    159650, --Dismembered Submersible Claw
    159386, --Anchor Chain Girdle
    159322, --Seawalker's Pantaloons
    159428, --Ballast Sinkers
    159461, --Band of the Ancient Dredger
    159622, --Hadal's Nautilus
  }
  self:RegisterBossLoot(siegeofboralus, lootTable, bossName)
  

  -----------------------------------
  ----- Viq'Goth
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2140)
  local lootTable = {
    159651, --Coral-Edged Crescent
    159310, --Circlet of the Enveloping Leviathan
    159252, --Grasping Crown of the Deep
    159376, --Hook-Barbed Spaulders
    159431, --Kraken Shell Pauldrons
    159314, --Cephalohide Jacket
    159416, --Harpooner's Plate Cuirass
    159362, --Tri-Heart Chestguard
    159256, --Iron-Kelp Wristwraps
  }
  self:RegisterBossLoot(siegeofboralus, lootTable, bossName)
  


end

function Dungeons:TempleOfSethraliss()
  local templeofsethraliss = "templeofsethraliss"
  local name = C_Map.GetMapInfo(1038).name
  self:RegisterRaidInstance(dungeonTierId, templeofsethraliss, name, bonusIds)
  --------------------------------------------------
  ----- Temple of Sethraliss
  --------------------------------------------------
  

  -----------------------------------
  ----- Adderis and Aspix
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2142)
  local lootTable = {
    159636, --Staff of the Lightning Serpent
    158370, --Twin-Strike Polearm
    159425, --Shard-Tipped Vambraces
    159380, --Arc-Glass Bindings
    159263, --Bindings of the Slithering Current
    159317, --Whirling Dervish Sash
    159435, --Legplates of Charged Duality
    159329, --Leggings of the Galeforce Viper
    159388, --Sabatons of Coruscating Energy
    159259, --Sandswept Sandals
  }
  self:RegisterBossLoot(templeofsethraliss, lootTable, bossName)
  

  -----------------------------------
  ----- Merektha
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2143)
  local lootTable = {
    158714, --Swarm's Edge
    159637, --Snakebite Recurve
    159437, --Fangproof Gauntlets
    159255, --Ouroborial Sash
    159375, --Legguards of the Awakening Brood
    159327, --Sand-Shined Snakeskin Sandals
    162544, --Jade Ophidian Band
    158367, --Merektha's Fang
  }
  self:RegisterBossLoot(templeofsethraliss, lootTable, bossName)
  

  -----------------------------------
  ----- Galvazzt
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2144)
  local lootTable = {
    158369, --Galvanized Stormcrusher
    159664, --Bulwark of Brimming Potential
    159247, --Handwraps of Oscillating Polarity
    159442, --Sand-Scoured Greatbelt
    158366, --Charged Sandstone Band
    158374, --Tiny Electromental in a Jar
  }
  self:RegisterBossLoot(templeofsethraliss, lootTable, bossName)
  

  -----------------------------------
  ----- Avatar of Sethraliss
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2145)
  local lootTable = {
    158373, --Resonating Crystal Scimitar
    159374, --Sethraliss' Fanged Helm
    159318, --Hood of the Slithering Loa
    159439, --C'thraxxi Binders Pauldrons
    159254, --Brood Cleanser's Amice
    159370, --Corrupted Hexxer's Vestments
    159257, --Robes of the Reborn Serpent
    159424, --Desert Guardian's Breastplate
    159337, --Grips of Electrified Defense
    158368, --Fangs of Intertwined Essence
  }
  self:RegisterBossLoot(templeofsethraliss, lootTable, bossName)
  


end

function Dungeons:Motherlode()
  local motherlode = "motherlode"
  local name = C_Map.GetMapInfo(1010).name
  self:RegisterRaidInstance(dungeonTierId, motherlode, name, bonusIds)
  --------------------------------------------------
  ----- The MOTHERLODE!!
  --------------------------------------------------
  

  -----------------------------------
  ----- Coin-Operated Crowd Pummeler
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2109)
  local lootTable = {
    159638, --Electro-Arm Bludgeoner
    159663, --G0-4W4Y Crowd Repeller
    158353, --Servo-Arm Bindings
    155864, --Power-Assisted Vicegrips
    159357, --Linked Pummeler Grips
    158350, --Rowdy Reveler's Legwraps
    159462, --NO NAME?
  }
  self:RegisterBossLoot(motherlode, lootTable, bossName)
  

  -----------------------------------
  ----- Azerokk
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2114)
  local lootTable = {
    158357, --Bindings of Enraged Earth
    158359, --Stonefury Vambraces
    159231, --Mine Rat's Handwarmers
    159361, --Shalebiter Interlinked Chain
    159226, --Excavator's Safety Belt
    159725, --Unscrupulous Geologist's Belt
    159679, --Sabatons of Rampaging Elements
    159336, --Mercenary Miner's Boots
    159612, --Azerokk's Resonating Heart
  }
  self:RegisterBossLoot(motherlode, lootTable, bossName)
  

  -----------------------------------
  ----- Rixxa Fluxflame
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2115)
  local lootTable = {
    159639, --P.A.C.I.F.I.S.T. Mk7
    159287, --Cloak of Questionable Intent
    159240, --Rixxa's Sweat-Wicking Cuffs
    159305, --Corrosive Handler's Gloves
    159451, --Leadplate Legguards
    158341, --Chemical Blaster's Legguards
    159235, --Deranged Alchemist's Slippers
  }
  self:RegisterBossLoot(motherlode, lootTable, bossName)
  

  -----------------------------------
  ----- Mogul Razdunk
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2116)
  local lootTable = {
    159641, --G3T-00t
    158364, --High Altitude Turban
    159232, --Exquisitely Aerodynamic Shoulderpads
    159360, --Crashguard Spaulders
    159415, --Skyscorcher Pauldrons
    159298, --Venture Co. Plenipotentiary Vest
    158349, --Petticoat of the Self-Stylized Azerite Baron
    158307, --Shrapnel-Dampening Chestguard
    159611, --Razdunk's Big Red Button
  }
  self:RegisterBossLoot(motherlode, lootTable, bossName)
  


end

function Dungeons:Underrot()
  local underrot = "underrot"
  local name = C_Map.GetMapInfo(1041).name
  self:RegisterRaidInstance(dungeonTierId, underrot, name, bonusIds)
  --------------------------------------------------
  ----- The Underrot
  --------------------------------------------------
  

  -----------------------------------
  ----- Elder Leaxa
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2157)
  local lootTable = {
    159652, --Leaxa's Thought-Piercer
    159324, --Blood Elder's Bindings
    159402, --Waistguard of Sanguine Fervor
    159443, --Legplates of Profane Sacrifice
    159463, --Loop of Pulsing Veins
    159624, --Rotcrusted Voodoo Doll
  }
  self:RegisterBossLoot(underrot, lootTable, bossName)
  

  -----------------------------------
  ----- Cragmaw the Infested
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2131)
  local lootTable = {
    159134, --Heart-Piercing Stalactite
    159653, --Bile-Stained Crawg Tusks
    159433, --Phosphorescent Armplates
    159275, --Wristwraps of Twined Morels
    159344, --Underrot Grotto Tenders
    159382, --Blood Tick Crushers
    159325, --Bloodfeaster Belt
    159269, --Darklight Legwarmers
    159436, --Fluorescent Flora Stompers
    159396, --Waders of the Infested
  }
  self:RegisterBossLoot(underrot, lootTable, bossName)
  

  -----------------------------------
  ----- Sporecaller Zancha
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2130)
  local lootTable = {
    159654, --Corruption Borne Headlopper
    159665, --Targe of the Ancient Warder
    159292, --NO NAME?
    159410, --Zancha's Venerated Greatbelt
    159384, --Corpuscular Greaves
    159338, --Pustule Bearer's Pants
    159270, --Blood Warder's Moccasins
    159626, --Lingering Sporepods
  }
  self:RegisterBossLoot(underrot, lootTable, bossName)
  

  -----------------------------------
  ----- Unbound Abomination
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2158)
  local lootTable = {
    159655, --Vile Exsanguinator
    159446, --Greathelm of the Putrid Path
    159381, --Visage of Bloody Horrors
    159385, --Amalgamated Abomination Spaulders
    159267, --Pauldrons of Vile Corruption
    159323, --Shoulders of the Sanguine Monstrosity
    159432, --Breastplate of Arterial Protection
    159330, --Gore-Splattered Vest
    159241, --Blood-Drenched Robes
    159253, --Gloves of Staunched Wounds
    159625, --Vial of Animated Blood
  }
  self:RegisterBossLoot(underrot, lootTable, bossName)
  


end

function Dungeons:TolDagor()
  local toldagor = "toldagor"
  local name = C_Map.GetMapInfo(974).name
  self:RegisterRaidInstance(dungeonTierId, toldagor, name, bonusIds)
  --------------------------------------------------
  ----- Tol Dagor
  --------------------------------------------------
  

  -----------------------------------
  ----- The Sand Queen
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2097)
  local lootTable = {
    159656, --Halberd of the Unwary Guard
    160110, --Warglaive of the Sand Queen
    159668, --Rattling Jar of Eyes
    159332, --Wristguards of the Sandswimmer
    160215, --Sewer Grate Girdle
    159392, --Gaoler's Chainmail Gaiters
    159460, --NO NAME?
  }
  self:RegisterBossLoot(toldagor, lootTable, bossName)
  

  -----------------------------------
  ----- Jes Howlis
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2098)
  local lootTable = {
    159131, --Howlis' Crystal Shiv
    159666, --Improvised Riot Shield
    159293, --NO NAME?
    159266, --Claw-Slit Brawler's Handwraps
    159306, --Singe-Blotched Britches
    159363, --Gnawed Iron Fetters
    159627, --Jes' Howler
  }
  self:RegisterBossLoot(toldagor, lootTable, bossName)
  

  -----------------------------------
  ----- Knight Captain Valyri
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2099)
  local lootTable = {
    159441, --Valyri's Fire-Proof Bracers
    159389, --Flint-Linked Wristguards
    159390, --Sure-Grip Munition Handlers
    159333, --Cincture of the Azerite Arsenal
    159274, --Knight Captain's Waistcord
    159277, --Wild Pyromancer's Trousers
    159343, --Spark Dampening Footpads
    159444, --Gunpowder-Scoured Sabatons
    159615, --Ignition Mage's Fuse
  }
  self:RegisterBossLoot(toldagor, lootTable, bossName)
  

  -----------------------------------
  ----- Overseer Korgus
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2096)
  local lootTable = {
    159129, --Flamecaster Botefeux
    159658, --Cudgel of Correctional Oversight
    159657, --Korgus' Blackpowder Rifle
    159414, --Overseer's Riot Helmet
    159334, --Flashpowder Hood
    159391, --Hood of the Dark Reaper
    159393, --Cannoneer's Mantle
    159331, --Pistoleer's Spaulders
    159440, --Ashvane Warden's Cuirass
    159268, --Inmate's Straight Robe
    159628, --Kul Tiran Cannonball Runner
  }
  self:RegisterBossLoot(toldagor, lootTable, bossName)
  
end

function Dungeons:WaycrestManor()
  local waycrestmanor = "waycrestmanor"
  local name = C_Map.GetMapInfo(1015).name
  self:RegisterRaidInstance(dungeonTierId, waycrestmanor, name, bonusIds)
  --------------------------------------------------
  ----- Waycrest Manor
  --------------------------------------------------
  

  -----------------------------------
  ----- Heartsbane Triad
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2125)
  local lootTable = {
    159133, --Jagged Iris Sica
    159669, --Solena's Watchful Collection
    159449, --Soulwarped Vambraces
    159340, --Bracers of Dreadful Maladies
    159272, --Twisted Sisters Handwraps
    159450, --Girdle of Burgeoning Apathy
    159400, --Nettle-Scarred Greaves
    159345, --Blight Toadskin Leggings
    159404, --Bramble Looped Boots
  }
  self:RegisterBossLoot(waycrestmanor, lootTable, bossName)
  

  -----------------------------------
  ----- Soulbound Goliath
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2126)
  local lootTable = {
    159659, --Sinister Wicker Talons
    159282, --Drust-Thatched Wristwraps
    159399, --Thornshaper Mitts
    159341, --Hound-Jowl Waistband
    159456, --Petrified Wickerplate Greaves
    162548, --Thornwoven Band
    159630, --Balefire Branch
  }
  self:RegisterBossLoot(waycrestmanor, lootTable, bossName)
  

  -----------------------------------
  ----- Raal the Gluttonous
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2127)
  local lootTable = {
    159660, --Servant Splitter
    159294, --NO NAME?
    159397, --Slaughterhouse-Chain Bracers
    159346, --Grubby Servant-Grabbers
    159285, --Bloodstained Sous Chef Pants
    159452, --Fatty Hooves of Gory Comfort
    159616, --Gore-Crusted Butcher's Block
  }
  self:RegisterBossLoot(waycrestmanor, lootTable, bossName)
  

  -----------------------------------
  ----- Lord and Lady Waycrest
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2128)
  local lootTable = {
    159661, --Soulcharmer's Bludgeon
    159457, --Risen Lord's Oversized Gauntlets
    159403, --Waistguard of Deteriorating Grace
    159262, --Belt of Undying Devotion
    159347, --Moss-Covered Wingtip Shoes
    158362, --Lord Waycrest's Signet
    159631, --Lady Waycrest's Music Box
  }
  self:RegisterBossLoot(waycrestmanor, lootTable, bossName)
  

  -----------------------------------
  ----- Gorak Tul
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2129)
  local lootTable = {
    159662, --Blightreaper
    159398, --Soulscarred Headgear
    159279, --Soulfuel Headdress
    159339, --Gorak Tul's Mantle
    159455, --Pauldrons of the Horned Horror
    159273, --Amice of the Returned
    159395, --Deathslaver's Hauberk
    159448, --Breastplate of the Vengeful
    159335, --Raiment of the Blighted Tribe
  }
  self:RegisterBossLoot(waycrestmanor, lootTable, bossName)
  
end

function Dungeons:InitializeZoneDetect(ZoneDetect)
  local ataldazar = "ataldazar"
  ZoneDetect:RegisterMapID(934, ataldazar)
  ZoneDetect:RegisterNPCID(122967, ataldazar, 1)
  ZoneDetect:RegisterNPCID(122965, ataldazar, 2)
  ZoneDetect:RegisterNPCID(122963, ataldazar, 3)
  ZoneDetect:RegisterNPCID(122968, ataldazar, 4)

  local freehold = "freehold"
  ZoneDetect:RegisterMapID(936, freehold)
  ZoneDetect:RegisterNPCID(126832, freehold, 1)
  ZoneDetect:RegisterNPCID(126845, freehold, 2)
  ZoneDetect:RegisterNPCID(126847, freehold, 2)
  ZoneDetect:RegisterNPCID(126848, freehold, 2)
  ZoneDetect:RegisterNPCID(126969, freehold, 3)
  ZoneDetect:RegisterNPCID(126983, freehold, 4)

  local kingsrest = "kingsrest"
  ZoneDetect:RegisterMapID(1004, kingsrest)
  ZoneDetect:RegisterNPCID(135322, kingsrest, 1)
  ZoneDetect:RegisterNPCID(134993, kingsrest, 2)
  ZoneDetect:RegisterNPCID(135475, kingsrest, 3)
  ZoneDetect:RegisterNPCID(135470, kingsrest, 3)
  ZoneDetect:RegisterNPCID(135472, kingsrest, 3)
  ZoneDetect:RegisterNPCID(136160, kingsrest, 4)

  local shrineofthestorm = "shrineofthestorm"
  ZoneDetect:RegisterMapID(1004, shrineofthestorm)
  ZoneDetect:RegisterNPCID(134056, shrineofthestorm, 1)
  ZoneDetect:RegisterNPCID(134063, shrineofthestorm, 2)
  ZoneDetect:RegisterNPCID(134058, shrineofthestorm, 2)
  ZoneDetect:RegisterNPCID(134060, shrineofthestorm, 3)
  ZoneDetect:RegisterNPCID(134069, shrineofthestorm, 4)

  local siegeofboralus = "siegeofboralus"
  ZoneDetect:RegisterNPCID(128650, siegeofboralus, 1)--Redhook - Alliance
  ZoneDetect:RegisterNPCID(130834, siegeofboralus, 1)--Bainbridge - Horde
  ZoneDetect:RegisterNPCID(129208, siegeofboralus, 2)
  ZoneDetect:RegisterNPCID(130836, siegeofboralus, 3)
  ZoneDetect:RegisterNPCID(120553, siegeofboralus, 4)

  local templeofsethraliss = "templeofsethraliss"
  ZoneDetect:RegisterMapID(1038, templeofsethraliss)
  ZoneDetect:RegisterNPCID(133379, templeofsethraliss, 1)
  ZoneDetect:RegisterNPCID(133944, templeofsethraliss, 1)
  ZoneDetect:RegisterNPCID(133384, templeofsethraliss, 2)
  ZoneDetect:RegisterNPCID(133389, templeofsethraliss, 3)
  ZoneDetect:RegisterNPCID(133392, templeofsethraliss, 4)

  local motherlode = "motherlode"
  ZoneDetect:RegisterMapID(1010, motherlode)
  ZoneDetect:RegisterNPCID(129214, motherlode, 1)
  ZoneDetect:RegisterNPCID(129227, motherlode, 2)
  ZoneDetect:RegisterNPCID(129231, motherlode, 3)
  ZoneDetect:RegisterNPCID(129232, motherlode, 4)

  local underrot = "underrot"
  ZoneDetect:RegisterMapID(1041, underrot)
  ZoneDetect:RegisterNPCID(131318, underrot, 1)
  ZoneDetect:RegisterNPCID(131817, underrot, 2)
  ZoneDetect:RegisterNPCID(131383, underrot, 3)
  ZoneDetect:RegisterNPCID(133007, underrot, 4)

  local toldagor = "toldagor"
  ZoneDetect:RegisterMapID(974, toldagor)
  ZoneDetect:RegisterNPCID(127479, toldagor, 1)
  ZoneDetect:RegisterNPCID(127484, toldagor, 2)
  ZoneDetect:RegisterNPCID(127490, toldagor, 3)
  ZoneDetect:RegisterNPCID(127503, toldagor, 4)

  local waycrestmanor = "waycrestmanor"
  ZoneDetect:RegisterMapID(1015, waycrestmanor)
  ZoneDetect:RegisterNPCID(135358, waycrestmanor, 1)
  ZoneDetect:RegisterNPCID(135359, waycrestmanor, 1)
  ZoneDetect:RegisterNPCID(135360, waycrestmanor, 1)
  ZoneDetect:RegisterNPCID(260551, waycrestmanor, 2)
  ZoneDetect:RegisterNPCID(131863, waycrestmanor, 3)
  ZoneDetect:RegisterNPCID(131527, waycrestmanor, 4)
  ZoneDetect:RegisterNPCID(131545, waycrestmanor, 4)
  ZoneDetect:RegisterNPCID(131864, waycrestmanor, 5)

end

function Dungeons:OnEnable()
  self:RegisterExpansion("Battle for Azeroth", EXPANSION_NAME7)
  self:RegisterRaidTier("Battle for Azeroth", dungeonTierId, ("%s %s"):format(EXPANSION_NAME7, TRACKER_HEADER_DUNGEON), PLAYER_DIFFICULTY1, PLAYER_DIFFICULTY2, PLAYER_DIFFICULTY6)
  
  self:AtalDazar()
  self:Freehold()
  self:KingsRest()
  self:ShrineOfTheStorm()
  self:SiegeOfBoralus()
  self:TempleOfSethraliss()
  self:Motherlode()
  self:Underrot()
  self:TolDagor()
  self:WaycrestManor()
end
