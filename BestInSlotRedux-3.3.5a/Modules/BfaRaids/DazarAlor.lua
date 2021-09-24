local DazarAlor = LibStub("AceAddon-3.0"):GetAddon("BestInSlotRedux"):NewModule("DazarAlor")
local dazaralor = "dazaralor"
function DazarAlor:OnEnable()
  local L = LibStub("AceLocale-3.0"):GetLocale("BestInSlotRedux")

  local name = "Battle of Dazar'alor"
  if UnitFactionGroup("player") == "Alliance" then
    name = C_Map.GetMapInfo(1352).name
  else
    name = C_Map.GetMapInfo(1358).name
  end
  
  self:RegisterExpansion("Battle for Azeroth", EXPANSION_NAME7)
  self:RegisterRaidTier("Battle for Azeroth", 80102, name, PLAYER_DIFFICULTY1, PLAYER_DIFFICULTY2, PLAYER_DIFFICULTY6)
  self:RegisterRaidInstance(80102, dazaralor, name, {
    bonusids = {
      [1] = {3524},
      [2] = {3524},
      [3] = {3524}
    },
    difficultyconversion = {
      [1] = 3, --Raid Normal
      [2] = 5, --Raid Heroic
      [3] = 6, --Raid Mythic
    }
  })
  --------------------------------------------------
  ----- Battle of Dazar'alor
  --------------------------------------------------
  

  -----------------------------------
  ----- Champion of the Light
  -----------------------------------
  if UnitFactionGroup("player") == "Alliance" then
    local bossName = EJ_GetEncounterInfo(2344)
    local lootTable = {
      165586, --Dawnbreaker
      165919, --Desecrated Blade of the Disciples
      165584, --Sunburst Crest
      165519, --Cowl of Righteous Resolve
      165921, --Pauldrons of Ancestral Vengeance
      165550, --Breastplate of Divine Purification
      165834, --Divine Fury Raiment
      165517, --Bracers of Regal Devotion
      165501, --Bracers of Zealous Calling
      165549, --Crusade Pummelers
      165514, --Gloves of Spiritual Grace
      165533, --Lightgrace Sabatons
      165569, --Ward of Envelopment
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  else
    local bossName = EJ_GetEncounterInfo(2333)
    local lootTable = {
      165586, --Dawnbreaker
      165919, --Desecrated Blade of the Disciples
      165584, --Sunburst Crest
      165519, --Cowl of Righteous Resolve
      165921, --Pauldrons of Ancestral Vengeance
      165550, --Breastplate of Divine Purification
      165834, --Divine Fury Raiment
      165517, --Bracers of Regal Devotion
      165501, --Bracers of Zealous Calling
      165549, --Crusade Pummelers
      165514, --Gloves of Spiritual Grace
      165533, --Lightgrace Sabatons
      165569, --Ward of Envelopment
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  end
  
  if UnitFactionGroup("player") == "Alliance" then
    -----------------------------------
    ----- Grong, the Revenant
    -----------------------------------
    local bossName = EJ_GetEncounterInfo(2340)
    local lootTable = {
      165589, --Hornridged Crusher
      165920, --Apetagonizer's Claw
      165588, --Bonelash Paw
      165582, --Cursed Monkey Palm
      165535, --Simian Berserker's Helm
      165922, --Bristling Fur-Lined Amice
      165555, --Spaulders of the Gorilla King
      165513, --Silverback Cloak
      165515, --Grongpelt Vest
      165534, --Ape Wrangler's Wristguards
      165551, --Splinter-Bone Vambraces
      165525, --Stretched Sinew Waistcord
      165499, --Leggings of Dire Research
      165574, --Grong's Primal Rage
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  else
    -----------------------------------
    ----- Grong, the Jungle Lord
    -----------------------------------
    local bossName = EJ_GetEncounterInfo(2325)
    local lootTable = {
      165589, --Hornridged Crusher
      165920, --Apetagonizer's Claw
      165588, --Bonelash Paw
      165582, --Cursed Monkey Palm
      165535, --Simian Berserker's Helm
      165922, --Bristling Fur-Lined Amice
      165555, --Spaulders of the Gorilla King
      165513, --Silverback Cloak
      165515, --Grongpelt Vest
      165534, --Ape Wrangler's Wristguards
      165551, --Splinter-Bone Vambraces
      165525, --Stretched Sinew Waistcord
      165499, --Leggings of Dire Research
      165574, --Grong's Primal Rage
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  end

  -----------------------------------
  ----- Jadefire Masters
  -----------------------------------
  if UnitFactionGroup("player") == "Alliance" then
    local bossName = EJ_GetEncounterInfo(2323)
    local lootTable = {
      165587, --Phoenixfire Staff
      165500, --Blazewing Hood
      165548, --Helm of Tempered Jade
      165777, --Ma'ra's Boneblade Mantle
      165540, --Mistfire Raiment
      165764, --Firecaller's Handwraps
      165531, --Grips of Harmonious Spirits
      165552, --Embersear Waistguard
      165521, --Cranedancer Leggings
      165565, --Band of Multi-Sided Strikes
      165568, --Invocation of Yu'lon
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  else
    local bossName = EJ_GetEncounterInfo(2341)
    local lootTable = {
      165587, --Phoenixfire Staff
      165500, --Blazewing Hood
      165548, --Helm of Tempered Jade
      165516, --Mestrah's Singing Spaulders
      165540, --Mistfire Raiment
      165531, --Grips of Harmonious Spirits
      165503, --Manceroy's Flamefists
      165552, --Embersear Waistguard
      165521, --Cranedancer Leggings
      165565, --Band of Multi-Sided Strikes
      165568, --Invocation of Yu'lon
    }
    self:RegisterBossLoot(dazaralor, lootTable, bossName)
  end
  

  -----------------------------------
  ----- Opulence
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2342)
  local lootTable = {
    165591, --Bloodtooth, the Soulfeaster
    165592, --Goblet of Glittering Favor
    165593, --Greed's Folly
    165526, --Crown of A'akul's Dark Reign
    165821, --Crown of Bloody Succession
    165818, --Crown of the Seducer
    165820, --Electrified Crown of Rahu'ai
    165524, --Amethyst-Studded Bindings
    165538, --Goldenscale Girdle
    165504, --Waistcord of Flowing Silk
    165541, --Boots of the Gilded Path
    165561, --Coinage Stampers
    165573, --Diamond-Laced Refracting Prism
    165571, --Incandescent Sliver
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  

  -----------------------------------
  ----- Conclave of the Chosen
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2330)
  local lootTable = {
    165846, --Enchanted Talon of Pa'ku
    165847, --Thundering Scale of Akunda
    165848, --Spawn of Krag'wa
    165594, --Akunda's Shocksplitter
    165595, --Blade of Encroaching Death
    165599, --Pterrorwing Longbow
    165507, --Mantle of the Skyterror
    165562, --Ridgeplate Pauldrons
    165512, --Loa Exultant's Shroud
    165532, --Gonk's Scale Robes
    165833, --Vestments of Indomitable Will
    165560, --Arcing Thunderlizard Legplates
    165502, --Lightfeather Footpads
    166418, --Crest of Pa'ku
    165579, --Kimbul's Razor Claw
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  

  -----------------------------------
  ----- King Rastakhan
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2335)
  local lootTable = {
    165597, --Deathspeaker Spire
    165596, --Last Fang of Rezan
    165537, --Mantle of the Soulbinder's Caress
    165523, --Phantom Stalker Shoulders
    165832, --Breastplate of the Deathbound
    165498, --Vestments of the Afterlife
    165558, --Roka's Bonecrushing Manacles
    165536, --Deathhunter's Legguards
    165567, --Seal of the Zandalari Empire
    165577, --Bwonsamdi's Bargain
    165578, --Mirror of Entwined Fate
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  

  -----------------------------------
  ----- High Tinker Mekkatorque
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2334)
  local lootTable = {
    166518, --G.M.O.D.
    165598, --Servo-Claw Smasher
    165600, --Twin-Pipe Buster Cannon
    165543, --Target-Tracking Headgear
    165825, --Dyno-Sprocket Spaulders
    165497, --Giga-Charged Shoulderpads
    165924, --High Tinker's Cape
    165830, --Mekkatorque's Bomber Jacket
    165508, --Lever Stabilizing Wristwraps
    165522, --Mech-Jockey Grips
    165580, --Ramping Amplitude Gigavolt Engine
    165572, --Variable Intensity Gigavolt Oscillating Reactor
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  

  -----------------------------------
  ----- Stormwall Blockade
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2337)
  local lootTable = {
    165602, --Crash of Tides
    165590, --Docksplitter Siege Hook
    165601, --Storm-Toothed Kasuyu
    165603, --Siren's Song
    165585, --Blockade Bulwark
    165822, --Cowl of Tideborne Omens
    165819, --Tidemother's Cover
    165923, --Tidal Shroud Spaulders
    165557, --Sea Swell Chestplate
    165546, --Slimy Kelpweavers
    165556, --Stormwrought Gauntlets
    165528, --Kelp-Laced Greaves
    165506, --Wavecaller Leggings
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  

  -----------------------------------
  ----- Lady Jaina Proudmoore
  -----------------------------------
  local bossName = EJ_GetEncounterInfo(2343)
  local lootTable = {
    166705, --Glacial Tidestorm
    165604, --Daelin Proudmoore's Saber
    165583, --Fogbreaker, Light of the Sea
    165823, --Glaciercrest Helm
    165824, --Admiralty's Ceremonial Epaulets
    165831, --Flag Officer's Overcoat
    165505, --Robes of Biting Cold
    165542, --Icebinder's Bracers
    165559, --Hullplate Girdle
    165527, --Embossed Deckwalkers
    165566, --Lord Admiral's Signet
    165570, --Everchill Anchor
    165576, --Tidestorm Codex
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
  
  -----------------------------------
  ----- Trash loot
  -----------------------------------
  local bossName = L["Trash Loot"]
  local lootTable = {
    ----Cloth----
    -- 160612,--Spellbound Specimen Handlers
    -- 161071,--Bloody Experimenter's Wraps
    -- ----Leather----
    -- 161075,--Antiseptic Specimen Handlers
    -- 161072,--Splatterguards
    -- ----Mail----
    -- 161076,--Iron-Grip Specimen Handlers
    -- 161073,--Reinforced Test Subject Shackles
    -- ----Plate----
    -- 161077,--Fluid-Resistant Specimen Handlers
    -- 161074,--Crushproof Vambraces
  }
  self:RegisterBossLoot(dazaralor, lootTable, bossName)
end

function DazarAlor:InitializeZoneDetect(ZoneDetect)
  if UnitFactionGroup("player") == "Alliance" then
    ZoneDetect:RegisterMapID(1352, dazaralor)
  else
    ZoneDetect:RegisterMapID(1358, dazaralor)
  end
  ZoneDetect:RegisterNPCID(144683, dazaralor, 1) --Champion of the Light [H]  
  ZoneDetect:RegisterNPCID(144680, dazaralor, 1) --Champion of the Light [A]
  ZoneDetect:RegisterNPCID(144638, dazaralor, 3) --Grong, the Revenant [A]
  ZoneDetect:RegisterNPCID(148117, dazaralor, 2) --Grong, the Jungle Lord [H]
  ZoneDetect:RegisterNPCID(148238, dazaralor, 2) --Jadefire Masters [A]
  ZoneDetect:RegisterNPCID(146099, dazaralor, 3) --Jadefire Masters [H]
  ZoneDetect:RegisterNPCID(147564, dazaralor, 4) --Opulence
  ZoneDetect:RegisterNPCID(144747, dazaralor, 5) --Conclave of the Chosen
  ZoneDetect:RegisterNPCID(145616, dazaralor, 6) --King Rastakhan
  ZoneDetect:RegisterNPCID(144838, dazaralor, 7) --High Tinker Mekkatorque
  ZoneDetect:RegisterNPCID(146256, dazaralor, 8) --Stormwall Blockade
  ZoneDetect:RegisterNPCID(149684, dazaralor, 9) --Lady Jaina Proudmoore
end
