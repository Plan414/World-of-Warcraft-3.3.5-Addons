local BfaWorld = LibStub("AceAddon-3.0"):GetAddon("BestInSlotRedux"):NewModule("BfaWorld")
local bfaworld = "bfaworld"
function BfaWorld:OnEnable()
  local L = LibStub("AceLocale-3.0"):GetLocale("BestInSlotRedux")

  local azeroth = "azeroth"
  local dungeonTierId = 80001
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
  self:RegisterExpansion("Battle for Azeroth", EXPANSION_NAME7)
  self:RegisterRaidTier("Battle for Azeroth", dungeonTierId, ("%s %s"):format(EXPANSION_NAME7, 'World'), PLAYER_DIFFICULTY1, PLAYER_DIFFICULTY2, PLAYER_DIFFICULTY6)
  self:RegisterRaidInstance(dungeonTierId, azeroth, 'World', bonusIds)  
  --------------------------------------------------
  ----- World Boss
  --------------------------------------------------

  local worldDropDifficulty = {1,2,3}
  local misc_a = {
    -----------------------------------
    ----- T'zane
    -----------------------------------
    [EJ_GetEncounterInfo(2139)] = {
    161396, --Petrified Mask of the Afterlife 
    161391, --Deathshambler's Shoulderpads 
    161392, --Bindings of Eternal Fears 
    161397, --Soulplank Vambraces 
    161389, --Cinch of All-Consuming Death 
    164383, --Death Devouring Girdle 
    161393, --Legguards of the Barkbound Dead 
    161387, --Wailing Terror Leggings 
    161395, --Swampwalker's Soul-Treads 
    161412, --Spiritbound Voodoo Burl 
    161411, --T'zane's Barkspines
    difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Ji'arak
    -----------------------------------
    [EJ_GetEncounterInfo(2141)] = {
    161401, --Matriarch's Shadowveil 
    164384, --Windswept Dinorider's Cape 
    161409, --Stormcrash Chestguard 
    161388, --Gloves of Enveloping Winds 
    161403, --Avian Clutch Belt 
    161394, --Hurricane Cinch 
    161390, --Savage Terrorwing Leggings 
    161407, --Windshear Leggings 
    161371, --Galebreaker's Sabatons
    difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Hailstone Construct
    -----------------------------------
    [EJ_GetEncounterInfo(2197)] = {
    161372, --Ice-Carved Shoulderplates 
    161367, --Hailstone Hauberk 
    161364, --Chill's End Wristguards 
    161370, --Glacial Spike Gauntlets 
    161368, --Freezing Tempest Waistguard 
    164386, --Girdle of Biting Winds 
    161362, --Frostbreath Leggings 
    161366, --Ice Stalker Boots 
    161361, --Ice-Rimed Slippers 
    161380, --Drust-Runed Icicle 
    161381, --Permafrost-Encrusted Heart
  difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Azurethos, The Winged Typhoon
    -----------------------------------
    [EJ_GetEncounterInfo(2199)] = {
    161356, --Feathered Galeforce Crest 
    161352, --Chestguard of Dire Winds 
    161369, --Bindings of the Winged Typhoon 
    161398, --Talonscored Azure Vambraces 
    161350, --Windcaller's Down Handwraps 
    161360, --Roost-Defender's Legguards 
    161365, --Footpads of the Encircling Storm 
    161363, --Sandals of Rustling Rage 
    161377, --Azurethos' Singed Plumage 
    161379, --Galecaller's Beak 
    161378, --Plume of the Seaborne Avian
  difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Doom's Howl (Alliance)
    -----------------------------------
    [EJ_GetEncounterInfo(2213)] = {
    161464, --Alliance Bowman's Coif 
    161466, --Battlemage's Collar 
    161468, --Gilded-Wing Shoulderguards 
    161471, --Lion's Roar Pauldrons 
    161465, --Warcaster's Arcane Mantle 
    161470, --Polished Shieldbearer's Breastplate 
    161469, --Sharpshooter's Chainmail Hauberk 
    161467, --Vest of the Veiled Gryphon 
    161472, --Lion's Grace 
    161473, --Lion's Guile 
    161474, --Lion's Strength
  difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Warbringer Yenajz
    -----------------------------------
    [EJ_GetEncounterInfo(2198)] = {
    161349, --Amice of the Rending Abyss 
    161357, --Spaulders of the Enveloping Maw 
    161351, --Wristwraps of Warped Reality 
    161358, --Existence-Shattering Gauntlets 
    161353, --Shadow-Wreathed Gloves 
    161354, --Leggings of the Endless Void 
    161355, --Yenajz's Chitinous Stompers 
    161359, --Band of Intense Gravitation 
    161376, --Prism of Dark Intensity
    difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Dunegorger Kraulok
    -----------------------------------
    [EJ_GetEncounterInfo(2210)] = {
    161404, --Hood of the Sinuous Devilsaur 
    164385, --Desert Nomad's Wrap 
    161400, --Raider's Shrouding Thobe 
    161406, --Shrouded Sandscale Bracers 
    161405, --Dunegorger's Grips 
    161402, --Gloves of the Desert Assassin 
    161399, --Cord of Flowing Sands 
    161408, --Sandswept Legionnaire's Legplates 
    161419, --Kraulok's Claw
    difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Ivus the Decayed
    -----------------------------------
    [EJ_GetEncounterInfo(2345)] = {
      166695, --Petrified Ironbark Crown
      166687, --Warring Ancient's Mask
      166691, --Forest Protector's Shoulderguards
      166683, --Garments of the Forest Lord
      166694, --Gnarled Bough Gauntlets
      166686, --Ivus' Tanglemoss Waistcord
      166690, --Protector's Tangleroot Belt
      166698, --Stoneroot Stompers
      161417, --Ancient Knot of Wisdom
      161415, --Forest Lord's Razorleaf
      161413, --Knot of Ancient Fury
    },
  } 
------------------------Horde------------------------------------------------  
  local misc_h = {
    -----------------------------------
    ----- T'zane
    -----------------------------------
    [EJ_GetEncounterInfo(2139)] = {
    161396, --Petrified Mask of the Afterlife 
    161391, --Deathshambler's Shoulderpads 
    161392, --Bindings of Eternal Fears 
    161397, --Soulplank Vambraces 
    161389, --Cinch of All-Consuming Death 
    164383, --Death Devouring Girdle 
    161393, --Legguards of the Barkbound Dead 
    161387, --Wailing Terror Leggings 
    161395, --Swampwalker's Soul-Treads 
    161412, --Spiritbound Voodoo Burl 
    161411, --T'zane's Barkspines
  difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Ji'arak
    -----------------------------------
    [EJ_GetEncounterInfo(2141)] = {
      161401, --Matriarch's Shadowveil 
      164384, --Windswept Dinorider's Cape 
      161409, --Stormcrash Chestguard 
      161388, --Gloves of Enveloping Winds 
      161403, --Avian Clutch Belt 
      161394, --Hurricane Cinch 
      161390, --Savage Terrorwing Leggings 
      161407, --Windshear Leggings 
      161371, --Galebreaker's Sabatons
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Hailstone Construct
    -----------------------------------
    [EJ_GetEncounterInfo(2197)] = {
      161372, --Ice-Carved Shoulderplates 
      161367, --Hailstone Hauberk 
      161364, --Chill's End Wristguards 
      161370, --Glacial Spike Gauntlets 
      161368, --Freezing Tempest Waistguard 
      164386, --Girdle of Biting Winds 
      161362, --Frostbreath Leggings 
      161366, --Ice Stalker Boots 
      161361, --Ice-Rimed Slippers 
      161380, --Drust-Runed Icicle 
      161381, --Permafrost-Encrusted Heart
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Azurethos, The Winged Typhoon
    -----------------------------------
    [EJ_GetEncounterInfo(2199)] = {
      161356, --Feathered Galeforce Crest 
      161352, --Chestguard of Dire Winds 
      161369, --Bindings of the Winged Typhoon 
      161398, --Talonscored Azure Vambraces 
      161350, --Windcaller's Down Handwraps 
      161360, --Roost-Defender's Legguards 
      161365, --Footpads of the Encircling Storm 
      161363, --Sandals of Rustling Rage 
      161377, --Azurethos' Singed Plumage 
      161379, --Galecaller's Beak 
      161378, --Plume of the Seaborne Avian
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- The Lion's Roar (Horde)
    -----------------------------------
    [EJ_GetEncounterInfo(2212)] = {
      161455, --Battlemage's Collar 
      161453, --Warscout's Horned Helm 
      161457, --Dire-Tooth Spaulders 
      161460, --Spiked Dreadshield Pauldrons 
      161454, --Warcaster's Doom Mantle 
      161456, --Doom's Howl Vest 
      161459, --Molded War Machine Grill 
      161458, --Scalemail Battle Harness 
      161463, --Doom's Fury 
      161461, --Doom's Hatred 
      161462, --Doom's Wake
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Warbringer Yenajz
    -----------------------------------
    [EJ_GetEncounterInfo(2198)] = {
      161349, --Amice of the Rending Abyss 
      161357, --Spaulders of the Enveloping Maw 
      161351, --Wristwraps of Warped Reality 
      161358, --Existence-Shattering Gauntlets 
      161353, --Shadow-Wreathed Gloves 
      161354, --Leggings of the Endless Void 
      161355, --Yenajz's Chitinous Stompers 
      161359, --Band of Intense Gravitation 
      161376, --Prism of Dark Intensity
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Dunegorger Kraulok
    -----------------------------------
    [EJ_GetEncounterInfo(2210)] = {
      161404, --Hood of the Sinuous Devilsaur 
      164385, --Desert Nomad's Wrap 
      161400, --Raider's Shrouding Thobe 
      161406, --Shrouded Sandscale Bracers 
      161405, --Dunegorger's Grips 
      161402, --Gloves of the Desert Assassin 
      161399, --Cord of Flowing Sands 
      161408, --Sandswept Legionnaire's Legplates 
      161419, --Kraulok's Claw
      difficulty = worldDropDifficulty
    },
    -----------------------------------
    ----- Ivus the Forest Lord
    -----------------------------------
    [EJ_GetEncounterInfo(2329)] = {
      166696, --Petrified Ironbark Crown
      166688, --Warring Ancient's Crown
      166692, --Forest Protector's Shoulderguards
      166684, --Garments of the Forest Lord
      166693, --Gnarled Bough Gauntlets
      166685, --Ivus' Tanglemoss Waistcord
      166689, --Protector's Tangleroot Belt
      166697, --Stoneroot Stompers
      166793, --Ancient Knot of Wisdom
      166794, --Forest Lord's Razorleaf
      166795, --Knot of Ancient Fury
      difficulty = worldDropDifficulty
    },
  } 
    
  if UnitFactionGroup("player") == "Alliance" then
    self:RegisterMiscItems(azeroth, misc_a)
  else
    self:RegisterMiscItems(azeroth, misc_h)
  end
end
