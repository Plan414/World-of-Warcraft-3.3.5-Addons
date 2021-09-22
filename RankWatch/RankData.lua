--
-- RankWatch_RankData
-- For each trainable spell which has more than one rank, there is an entry in this table for each rank.
--
-- key: ID of the spell.
--   level: the level at which this rank is trained
--   rank: the rank trained at this level
--   next: the ID of the next higher rank (nil if this is the highest rank)

RankWatch_RankData = {
[10] = { level=20, rank=1, next=6141, class="MAGE" }, -- Blizzard
[17] = { level=6, rank=1, next=592, class="PRIEST" }, -- Power Word: Shield
[53] = { level=4, rank=1, next=2589, class="ROGUE" }, -- Backstab
[66] = { level=68, class="MAGE" }, -- Invisibility
[71] = { level=10, class="WARRIOR" }, -- Defensive Stance
[72] = { level=12, class="WARRIOR" }, -- Shield Bash
[1126] = { level=1, rank=1, next=5232, class="DRUID" }, -- Mark of the Wild
[99] = { level=10, rank=1, next=1735, class="DRUID" }, -- Demoralizing Roar
[100] = { level=4, rank=1, next=6178, class="WARRIOR" }, -- Charge
[116] = { level=4, rank=1, next=205, class="MAGE" }, -- Frostbolt
[118] = { level=8, rank=1, next=12824, class="MAGE" }, -- Polymorph
[120] = { level=26, rank=1, next=8492, class="MAGE" }, -- Cone of Cold
[122] = { level=10, rank=1, next=865, class="MAGE" }, -- Frost Nova
[126] = { level=22, class="WARLOCK" }, -- Eye of Kilrogg
[130] = { level=12, class="MAGE" }, -- Slow Fall
[131] = { level=22, class="SHAMAN" }, -- Water Breathing
[132] = { level=26, class="WARLOCK" }, -- Detect Invisibility
[5176] = { level=1, rank=1, next=5177, class="DRUID" }, -- Wrath
[136] = { level=12, rank=1, next=3111, class="HUNTER" }, -- Mend Pet
[139] = { level=8, rank=1, next=6074, class="PRIEST" }, -- Renew
[143] = { level=6, rank=2, next=145, class="MAGE" }, -- Fireball
[145] = { level=12, rank=3, next=3140, class="MAGE" }, -- Fireball
[5185] = { level=1, rank=1, next=5186, class="DRUID" }, -- Healing Touch
[172] = { level=4, rank=1, next=6222, class="WARLOCK" }, -- Corruption
[205] = { level=8, rank=2, next=837, class="MAGE" }, -- Frostbolt
[284] = { level=8, rank=2, next=285, class="WARRIOR" }, -- Heroic Strike
[285] = { level=16, rank=3, next=1608, class="WARRIOR" }, -- Heroic Strike
[324] = { level=8, rank=1, next=325, class="SHAMAN" }, -- Lightning Shield
[325] = { level=16, rank=2, next=905, class="SHAMAN" }, -- Lightning Shield
[2973] = { level=1, rank=1, next=14260, class="HUNTER" }, -- Raptor Strike
[332] = { level=6, rank=2, next=547, class="SHAMAN" }, -- Healing Wave
[339] = { level=8, rank=1, next=1062, class="DRUID" }, -- Entangling Roots
[133] = { level=1, rank=1, next=143, class="MAGE" }, -- Fireball
[355] = { level=10, class="WARRIOR" }, -- Taunt
[370] = { level=12, rank=1, next=8012, class="SHAMAN" }, -- Purge
[168] = { level=1, rank=1, next=7300, class="MAGE" }, -- Frost Armor
[408] = { level=30, rank=1, next=8643, class="ROGUE" }, -- Kidney Shot
[421] = { level=32, rank=1, next=930, class="SHAMAN" }, -- Chain Lightning
[453] = { level=20, class="PRIEST" }, -- Mind Soothe
[1459] = { level=1, rank=1, next=1460, class="MAGE" }, -- Arcane Intellect
[467] = { level=6, rank=1, next=782, class="DRUID" }, -- Thorns
[469] = { level=68, rank=1, next=47439, class="WARRIOR" }, -- Commanding Shout
[475] = { level=18, class="MAGE" }, -- Remove Curse
[498] = { level=6, class="PALADIN" }, -- Divine Protection
[526] = { level=16, class="SHAMAN" }, -- Cure Toxins
[527] = { level=18, rank=1, next=988, class="PRIEST" }, -- Dispel Magic
[528] = { level=14, class="PRIEST" }, -- Cure Disease
[529] = { level=8, rank=2, next=548, class="SHAMAN" }, -- Lightning Bolt
[543] = { level=20, rank=1, next=8457, class="MAGE" }, -- Fire Ward
[546] = { level=28, class="SHAMAN" }, -- Water Walking
[547] = { level=12, rank=3, next=913, class="SHAMAN" }, -- Healing Wave
[548] = { level=14, rank=3, next=915, class="SHAMAN" }, -- Lightning Bolt
[552] = { level=32, class="PRIEST" }, -- Abolish Disease
[556] = { level=30, class="SHAMAN" }, -- Astral Recall
[465] = { level=1, rank=1, next=10290, class="PALADIN" }, -- Devotion Aura
[586] = { level=8, class="PRIEST" }, -- Fade
[587] = { level=6, rank=1, next=597, class="MAGE" }, -- Conjure Food
[588] = { level=12, rank=1, next=7128, class="PRIEST" }, -- Inner Fire
[589] = { level=4, rank=1, next=594, class="PRIEST" }, -- Shadow Word: Pain
[591] = { level=6, rank=2, next=598, class="PRIEST" }, -- Smite
[592] = { level=12, rank=2, next=600, class="PRIEST" }, -- Power Word: Shield
[594] = { level=10, rank=2, next=970, class="PRIEST" }, -- Shadow Word: Pain
[596] = { level=30, rank=1, next=996, class="PRIEST" }, -- Prayer of Healing
[597] = { level=12, rank=2, next=990, class="MAGE" }, -- Conjure Food
[598] = { level=14, rank=3, next=984, class="PRIEST" }, -- Smite
[600] = { level=18, rank=3, next=3747, class="PRIEST" }, -- Power Word: Shield
[602] = { level=30, rank=3, next=1006, class="PRIEST" }, -- Inner Fire
[603] = { level=60, rank=1, next=30910, class="WARLOCK" }, -- Curse of Doom
[604] = { level=12, rank=1, next=8450, class="MAGE" }, -- Dampen Magic
[605] = { level=30, class="PRIEST" }, -- Mind Control
[31935] = { level=50, rank=1, next=32699, class="PALADIN" }, -- Avenger's Shield
[19742] = { level=14, rank=1, next=19850, class="PALADIN" }, -- Blessing of Wisdom
[19850] = { level=24, rank=2, next=19852, class="PALADIN" }, -- Blessing of Wisdom
[642] = { level=34, class="PALADIN" }, -- Divine Shield
[643] = { level=20, rank=3, next=10291, class="PALADIN" }, -- Devotion Aura
[19852] = { level=34, rank=3, next=19853, class="PALADIN" }, -- Blessing of Wisdom
[676] = { level=18, class="WARRIOR" }, -- Disarm
[635] = { level=1, rank=1, next=639, class="PALADIN" }, -- Holy Light
[585] = { level=1, rank=1, next=591, class="PRIEST" }, -- Smite
[689] = { level=14, rank=1, next=699, class="WARLOCK" }, -- Drain Life
[691] = { level=30, class="WARLOCK" }, -- Summon Felhunter
[693] = { level=18, rank=1, next=20752, class="WARLOCK" }, -- Create Soulstone
[694] = { level=16, class="WARRIOR" }, -- Mocking Blow
[695] = { level=6, rank=2, next=705, class="WARLOCK" }, -- Shadow Bolt
[696] = { level=10, rank=2, next=706, class="WARLOCK" }, -- Demon Skin
[697] = { level=10, class="WARLOCK" }, -- Summon Voidwalker
[698] = { level=20, class="WARLOCK" }, -- Ritual of Summoning
[699] = { level=22, rank=2, next=709, class="WARLOCK" }, -- Drain Life
[702] = { level=4, rank=1, next=1108, class="WARLOCK" }, -- Curse of Weakness
[703] = { level=14, rank=1, next=8631, class="ROGUE" }, -- Garrote
[705] = { level=12, rank=3, next=1088, class="WARLOCK" }, -- Shadow Bolt
[706] = { level=20, rank=1, next=1086, class="WARLOCK" }, -- Demon Armor
[707] = { level=10, rank=2, next=1094, class="WARLOCK" }, -- Immolate
[709] = { level=30, rank=3, next=7651, class="WARLOCK" }, -- Drain Life
[710] = { level=28, rank=1, next=18647, class="WARLOCK" }, -- Banish
[712] = { level=20, class="WARLOCK" }, -- Summon Succubus
[724] = { level=40, rank=1, next=27870, class="PRIEST" }, -- Lightwell
[740] = { level=30, rank=1, next=8918, class="DRUID" }, -- Tranquility
[755] = { level=12, rank=1, next=3698, class="WARLOCK" }, -- Health Funnel
[759] = { level=28, rank=1, next=3552, class="MAGE" }, -- Conjure Mana Gem
[768] = { level=20, class="DRUID" }, -- Cat Form
[769] = { level=34, rank=3, next=9754, class="DRUID" }, -- Swipe (Bear)
[770] = { level=18, class="DRUID" }, -- Faerie Fire
[772] = { level=4, rank=1, next=6546, class="WARRIOR" }, -- Rend
[774] = { level=4, rank=1, next=1058, class="DRUID" }, -- Rejuvenation
[779] = { level=16, rank=1, next=780, class="DRUID" }, -- Swipe (Bear)
[780] = { level=24, rank=2, next=769, class="DRUID" }, -- Swipe (Bear)
[781] = { level=20, class="HUNTER" }, -- Disengage
[782] = { level=14, rank=2, next=1075, class="DRUID" }, -- Thorns
[783] = { level=16, class="DRUID" }, -- Travel Form
[837] = { level=14, rank=3, next=7322, class="MAGE" }, -- Frostbolt
[845] = { level=20, rank=1, next=7369, class="WARRIOR" }, -- Cleave
[853] = { level=8, rank=1, next=5588, class="PALADIN" }, -- Hammer of Justice
[865] = { level=26, rank=2, next=6131, class="MAGE" }, -- Frost Nova
[871] = { level=28, class="WARRIOR" }, -- Shield Wall
[19853] = { level=44, rank=4, next=19854, class="PALADIN" }, -- Blessing of Wisdom
[883] = { level=10, class="HUNTER" }, -- Call Pet
[905] = { level=24, rank=3, next=945, class="SHAMAN" }, -- Lightning Shield
[913] = { level=18, rank=4, next=939, class="SHAMAN" }, -- Healing Wave
[915] = { level=20, rank=4, next=943, class="SHAMAN" }, -- Lightning Bolt
[921] = { level=4, class="ROGUE" }, -- Pick Pocket
[930] = { level=40, rank=2, next=2860, class="SHAMAN" }, -- Chain Lightning
[939] = { level=24, rank=5, next=959, class="SHAMAN" }, -- Healing Wave
[943] = { level=26, rank=5, next=6041, class="SHAMAN" }, -- Lightning Bolt
[945] = { level=32, rank=4, next=8134, class="SHAMAN" }, -- Lightning Shield
[959] = { level=32, rank=6, next=8005, class="SHAMAN" }, -- Healing Wave
[970] = { level=18, rank=3, next=992, class="PRIEST" }, -- Shadow Word: Pain
[974] = { level=50, rank=1, next=32593, class="SHAMAN" }, -- Earth Shield
[976] = { level=30, rank=1, next=10957, class="PRIEST" }, -- Shadow Protection
[980] = { level=8, rank=1, next=1014, class="WARLOCK" }, -- Curse of Agony
[982] = { level=10, class="HUNTER" }, -- Revive Pet
[984] = { level=22, rank=4, next=1004, class="PRIEST" }, -- Smite
[988] = { level=36, rank=2, class="PRIEST" }, -- Dispel Magic
[990] = { level=22, rank=3, next=6129, class="MAGE" }, -- Conjure Food
[992] = { level=26, rank=4, next=2767, class="PRIEST" }, -- Shadow Word: Pain
[996] = { level=40, rank=2, next=10960, class="PRIEST" }, -- Prayer of Healing
[1002] = { level=14, class="HUNTER" }, -- Eyes of the Beast
[1004] = { level=30, rank=5, next=6060, class="PRIEST" }, -- Smite
[1006] = { level=40, rank=4, next=10951, class="PRIEST" }, -- Inner Fire
[1008] = { level=18, rank=1, next=8455, class="MAGE" }, -- Amplify Magic
[1014] = { level=18, rank=2, next=6217, class="WARLOCK" }, -- Curse of Agony
[1022] = { level=10, rank=1, next=5599, class="PALADIN" }, -- Hand of Protection
[19854] = { level=54, rank=5, next=25290, class="PALADIN" }, -- Blessing of Wisdom
[1032] = { level=40, rank=5, next=10292, class="PALADIN" }, -- Devotion Aura
[1038] = { level=26, class="PALADIN" }, -- Hand of Salvation
[25290] = { level=60, rank=6, next=27142, class="PALADIN" }, -- Blessing of Wisdom
[1044] = { level=18, class="PALADIN" }, -- Hand of Freedom
[1058] = { level=10, rank=2, next=1430, class="DRUID" }, -- Rejuvenation
[1062] = { level=18, rank=2, next=5195, class="DRUID" }, -- Entangling Roots
[1064] = { level=40, rank=1, next=10622, class="SHAMAN" }, -- Chain Heal
[1066] = { level=16, class="DRUID" }, -- Aquatic Form
[1075] = { level=24, rank=3, next=8914, class="DRUID" }, -- Thorns
[1079] = { level=20, rank=1, next=9492, class="DRUID" }, -- Rip
[1082] = { level=20, rank=1, next=3029, class="DRUID" }, -- Claw
[1086] = { level=30, rank=2, next=11733, class="WARLOCK" }, -- Demon Armor
[1088] = { level=20, rank=4, next=1106, class="WARLOCK" }, -- Shadow Bolt
[1094] = { level=20, rank=3, next=2941, class="WARLOCK" }, -- Immolate
[1098] = { level=30, rank=1, next=11725, class="WARLOCK" }, -- Enslave Demon
[1106] = { level=28, rank=5, next=7641, class="WARLOCK" }, -- Shadow Bolt
[1108] = { level=12, rank=2, next=6205, class="WARLOCK" }, -- Curse of Weakness
[1120] = { level=10, rank=1, next=8288, class="WARLOCK" }, -- Drain Soul
[1122] = { level=50, class="WARLOCK" }, -- Inferno
[1243] = { level=1, rank=1, next=1244, class="PRIEST" }, -- Power Word: Fortitude
[1130] = { level=6, rank=1, next=14323, class="HUNTER" }, -- Hunter's Mark
[27142] = { level=65, rank=7, next=48935, class="PALADIN" }, -- Blessing of Wisdom
[1160] = { level=14, rank=1, next=6190, class="WARRIOR" }, -- Demoralizing Shout
[1161] = { level=26, class="WARRIOR" }, -- Challenging Shout
[2050] = { level=1, rank=1, next=2052, class="PRIEST" }, -- Lesser Heal
[1244] = { level=12, rank=2, next=1245, class="PRIEST" }, -- Power Word: Fortitude
[1245] = { level=24, rank=3, next=2791, class="PRIEST" }, -- Power Word: Fortitude
[1329] = { level=50, rank=1, next=34411, class="ROGUE" }, -- Mutilate
[1430] = { level=16, rank=3, next=2090, class="DRUID" }, -- Rejuvenation
[1449] = { level=14, rank=1, next=8437, class="MAGE" }, -- Arcane Explosion
[1454] = { level=6, rank=1, next=1455, class="WARLOCK" }, -- Life Tap
[1455] = { level=16, rank=2, next=1456, class="WARLOCK" }, -- Life Tap
[1456] = { level=26, rank=3, next=11687, class="WARLOCK" }, -- Life Tap
[1752] = { level=1, rank=1, next=1757, class="ROGUE" }, -- Sinister Strike
[1460] = { level=14, rank=2, next=1461, class="MAGE" }, -- Arcane Intellect
[1461] = { level=28, rank=3, next=10156, class="MAGE" }, -- Arcane Intellect
[1462] = { level=24, class="HUNTER" }, -- Beast Lore
[1463] = { level=20, rank=1, next=8494, class="MAGE" }, -- Mana Shield
[1464] = { level=30, rank=1, next=8820, class="WARRIOR" }, -- Slam
[1490] = { level=32, rank=1, next=11721, class="WARLOCK" }, -- Curse of the Elements
[1495] = { level=16, rank=1, next=14269, class="HUNTER" }, -- Mongoose Bite
[1499] = { level=20, rank=1, next=14310, class="HUNTER" }, -- Freezing Trap
[1510] = { level=40, rank=1, next=14294, class="HUNTER" }, -- Volley
[1513] = { level=14, rank=1, next=14326, class="HUNTER" }, -- Scare Beast
[1515] = { level=10, class="HUNTER" }, -- Tame Beast
[1535] = { level=12, rank=1, next=8498, class="SHAMAN" }, -- Fire Nova
[1543] = { level=32, class="HUNTER" }, -- Flare
[1608] = { level=24, rank=4, next=11564, class="WARRIOR" }, -- Heroic Strike
[1680] = { level=36, class="WARRIOR" }, -- Whirlwind
[1706] = { level=34, class="PRIEST" }, -- Levitate
[1714] = { level=26, rank=1, next=11719, class="WARLOCK" }, -- Curse of Tongues
[1715] = { level=8, class="WARRIOR" }, -- Hamstring
[1719] = { level=50, class="WARRIOR" }, -- Recklessness
[1725] = { level=22, class="ROGUE" }, -- Distract
[1735] = { level=20, rank=2, next=9490, class="DRUID" }, -- Demoralizing Roar
[1784] = { level=1, rank=1, class="ROGUE" }, -- Stealth
[1757] = { level=6, rank=2, next=1758, class="ROGUE" }, -- Sinister Strike
[1758] = { level=14, rank=3, next=1759, class="ROGUE" }, -- Sinister Strike
[1759] = { level=22, rank=4, next=1760, class="ROGUE" }, -- Sinister Strike
[1760] = { level=30, rank=5, next=8621, class="ROGUE" }, -- Sinister Strike
[1766] = { level=12, class="ROGUE" }, -- Kick
[1776] = { level=6, class="ROGUE" }, -- Gouge
[2098] = { level=1, rank=1, next=6760, class="ROGUE" }, -- Eviscerate
[1804] = { level=16, class="ROGUE" }, -- Pick Lock
[1822] = { level=24, rank=1, next=1823, class="DRUID" }, -- Rake
[1823] = { level=34, rank=2, next=1824, class="DRUID" }, -- Rake
[1824] = { level=44, rank=3, next=9904, class="DRUID" }, -- Rake
[1833] = { level=26, class="ROGUE" }, -- Cheap Shot
[1842] = { level=30, class="ROGUE" }, -- Disarm Trap
[1850] = { level=26, rank=1, next=9821, class="DRUID" }, -- Dash
[1856] = { level=22, rank=1, next=1857, class="ROGUE" }, -- Vanish
[1857] = { level=42, rank=2, next=26889, class="ROGUE" }, -- Vanish
[1860] = { level=40, class="ROGUE" }, -- Safe Fall
[1943] = { level=20, rank=1, next=8639, class="ROGUE" }, -- Rupture
[1949] = { level=30, rank=1, next=11683, class="WARLOCK" }, -- Hellfire
[1953] = { level=20, class="MAGE" }, -- Blink
[1966] = { level=16, rank=1, next=6768, class="ROGUE" }, -- Feint
[1978] = { level=4, rank=1, next=13549, class="HUNTER" }, -- Serpent Sting
[2006] = { level=10, rank=1, next=2010, class="PRIEST" }, -- Resurrection
[2008] = { level=12, rank=1, next=20609, class="SHAMAN" }, -- Ancestral Spirit
[2010] = { level=22, rank=2, next=10880, class="PRIEST" }, -- Resurrection
[2048] = { level=69, rank=8, next=47436, class="WARRIOR" }, -- Battle Shout
[331] = { level=1, rank=1, next=332, class="SHAMAN" }, -- Healing Wave
[2052] = { level=4, rank=2, next=2053, class="PRIEST" }, -- Lesser Heal
[2053] = { level=10, rank=3, next=2054, class="PRIEST" }, -- Lesser Heal
[2054] = { level=16, rank=1, next=2055, class="PRIEST" }, -- Heal
[2055] = { level=22, rank=2, next=6063, class="PRIEST" }, -- Heal
[2060] = { level=40, rank=1, next=10963, class="PRIEST" }, -- Greater Heal
[2061] = { level=20, rank=1, next=9472, class="PRIEST" }, -- Flash Heal
[2062] = { level=66, class="SHAMAN" }, -- Earth Elemental Totem
[2070] = { level=28, rank=2, next=11297, class="ROGUE" }, -- Sap
[2090] = { level=22, rank=4, next=2091, class="DRUID" }, -- Rejuvenation
[2091] = { level=28, rank=5, next=3627, class="DRUID" }, -- Rejuvenation
[2094] = { level=34, class="ROGUE" }, -- Blind
[2096] = { level=22, rank=1, next=10909, class="PRIEST" }, -- Mind Vision
[403] = { level=1, rank=1, next=529, class="SHAMAN" }, -- Lightning Bolt
[2120] = { level=16, rank=1, next=2121, class="MAGE" }, -- Flamestrike
[2121] = { level=24, rank=2, next=8422, class="MAGE" }, -- Flamestrike
[2136] = { level=6, rank=1, next=2137, class="MAGE" }, -- Fire Blast
[2137] = { level=14, rank=2, next=2138, class="MAGE" }, -- Fire Blast
[2138] = { level=22, rank=3, next=8412, class="MAGE" }, -- Fire Blast
[2139] = { level=24, class="MAGE" }, -- Counterspell
[2362] = { level=36, rank=1, next=17727, class="WARLOCK" }, -- Create Spellstone
[2458] = { level=30, class="WARRIOR" }, -- Berserker Stance
[2484] = { level=6, class="SHAMAN" }, -- Earthbind Totem
[2565] = { level=16, class="WARRIOR" }, -- Shield Block
[2589] = { level=12, rank=2, next=2590, class="ROGUE" }, -- Backstab
[2590] = { level=20, rank=3, next=2591, class="ROGUE" }, -- Backstab
[2591] = { level=28, rank=4, next=8721, class="ROGUE" }, -- Backstab
[2637] = { level=18, rank=1, next=18657, class="DRUID" }, -- Hibernate
[2641] = { level=10, class="HUNTER" }, -- Dismiss Pet
[2643] = { level=18, rank=1, next=14288, class="HUNTER" }, -- Multi-Shot
[2645] = { level=16, class="SHAMAN" }, -- Ghost Wolf
[2687] = { level=10, class="WARRIOR" }, -- Bloodrage
[2767] = { level=34, rank=5, next=10892, class="PRIEST" }, -- Shadow Word: Pain
[2782] = { level=24, class="DRUID" }, -- Remove Curse
[2791] = { level=36, rank=4, next=10937, class="PRIEST" }, -- Power Word: Fortitude
[48935] = { level=71, rank=8, next=48936, class="PALADIN" }, -- Blessing of Wisdom
[48936] = { level=77, rank=9, class="PALADIN" }, -- Blessing of Wisdom
[2818] = { level=30, rank=1, next=2819, class="ROGUE" }, -- Deadly Poison
[2819] = { level=38, rank=2, next=11353, class="ROGUE" }, -- Deadly Poison II
[2823] = { level=30, rank=1, next=2824, class="ROGUE" }, -- Deadly Poison
[2824] = { level=38, rank=2, next=11355, class="ROGUE" }, -- Deadly Poison II
[2825] = { level=70, class="SHAMAN", faction="Horde" }, -- Bloodlust
[2836] = { level=24, class="ROGUE" }, -- Detect Traps
[2860] = { level=48, rank=3, next=10605, class="SHAMAN" }, -- Chain Lightning
[2893] = { level=26, rank=1, class="DRUID" }, -- Abolish Poison
[2894] = { level=68, class="SHAMAN" }, -- Fire Elemental Totem
[2908] = { level=22, rank=1, next=8955, class="DRUID" }, -- Soothe Animal
[2912] = { level=20, rank=1, next=8949, class="DRUID" }, -- Starfire
[2941] = { level=30, rank=4, next=11665, class="WARLOCK" }, -- Immolate
[2944] = { level=20, rank=1, next=19276, class="PRIEST" }, -- Devouring Plague
[2948] = { level=22, rank=1, next=8444, class="MAGE" }, -- Scorch
[8017] = { level=1, rank=1, next=8018, class="SHAMAN" }, -- Rockbiter Weapon
[2974] = { level=12, class="HUNTER" }, -- Wing Clip
[2983] = { level=10, rank=1, next=8696, class="ROGUE" }, -- Sprint
[3029] = { level=28, rank=2, next=5201, class="DRUID" }, -- Claw
[3034] = { level=36, class="HUNTER" }, -- Viper Sting
[3043] = { level=22, class="HUNTER" }, -- Scorpid Sting
[3044] = { level=6, rank=1, next=14281, class="HUNTER" }, -- Arcane Shot
[3045] = { level=26, class="HUNTER" }, -- Rapid Fire
[3111] = { level=20, rank=2, next=3661, class="HUNTER" }, -- Mend Pet
[3140] = { level=18, rank=4, next=8400, class="MAGE" }, -- Fireball
[3411] = { level=70, class="WARRIOR" }, -- Intervene
[4987] = { level=42, class="PALADIN" }, -- Cleanse
[3552] = { level=38, rank=2, next=10053, class="MAGE" }, -- Conjure Mana Gem
[3561] = { level=20, class="MAGE", faction="Alliance" }, -- Teleport: Stormwind
[3562] = { level=20, class="MAGE", faction="Alliance" }, -- Teleport: Ironforge
[3563] = { level=20, class="MAGE", faction="Horde" }, -- Teleport: Undercity
[3565] = { level=30, class="MAGE", faction="Alliance" }, -- Teleport: Darnassus
[3566] = { level=30, class="MAGE", faction="Horde" }, -- Teleport: Thunder Bluff
[3567] = { level=20, class="MAGE", faction="Horde" }, -- Teleport: Orgrimmar
[3599] = { level=10, rank=1, next=6363, class="SHAMAN" }, -- Searing Totem
[3627] = { level=34, rank=6, next=8910, class="DRUID" }, -- Rejuvenation
[3661] = { level=28, rank=3, next=3662, class="HUNTER" }, -- Mend Pet
[3662] = { level=36, rank=4, next=13542, class="HUNTER" }, -- Mend Pet
[3674] = { level=50, rank=1, next=63668, class="HUNTER" }, -- Black Arrow
[3698] = { level=20, rank=2, next=3699, class="WARLOCK" }, -- Health Funnel
[3699] = { level=28, rank=3, next=3700, class="WARLOCK" }, -- Health Funnel
[3700] = { level=36, rank=4, next=11693, class="WARLOCK" }, -- Health Funnel
[3714] = { level=61, class="DEATHKNIGHT" }, -- Path of Frost
[3738] = { level=64, class="SHAMAN" }, -- Wrath of Air Totem
[3747] = { level=24, rank=4, next=6065, class="PRIEST" }, -- Power Word: Shield
[19746] = { level=22, class="PALADIN" }, -- Concentration Aura
[5116] = { level=8, class="HUNTER" }, -- Concussive Shot
[5118] = { level=16, class="HUNTER" }, -- Aspect of the Cheetah
[5138] = { level=24, class="WARLOCK" }, -- Drain Mana
[5143] = { level=8, rank=1, next=5144, class="MAGE" }, -- Arcane Missiles
[5144] = { level=16, rank=2, next=5145, class="MAGE" }, -- Arcane Missiles
[5145] = { level=24, rank=3, next=8416, class="MAGE" }, -- Arcane Missiles
[5171] = { level=10, rank=1, next=6774, class="ROGUE" }, -- Slice and Dice
[348] = { level=1, rank=1, next=707, class="WARLOCK" }, -- Immolate
[5177] = { level=6, rank=2, next=5178, class="DRUID" }, -- Wrath
[5178] = { level=14, rank=3, next=5179, class="DRUID" }, -- Wrath
[5179] = { level=22, rank=4, next=5180, class="DRUID" }, -- Wrath
[5180] = { level=30, rank=5, next=6780, class="DRUID" }, -- Wrath
[686] = { level=1, rank=1, next=695, class="WARLOCK" }, -- Shadow Bolt
[5186] = { level=8, rank=2, next=5187, class="DRUID" }, -- Healing Touch
[5187] = { level=14, rank=3, next=5188, class="DRUID" }, -- Healing Touch
[5188] = { level=20, rank=4, next=5189, class="DRUID" }, -- Healing Touch
[5189] = { level=26, rank=5, next=6778, class="DRUID" }, -- Healing Touch
[5195] = { level=28, rank=3, next=5196, class="DRUID" }, -- Entangling Roots
[5196] = { level=38, rank=4, next=9852, class="DRUID" }, -- Entangling Roots
[5201] = { level=38, rank=3, next=9849, class="DRUID" }, -- Claw
[5209] = { level=28, class="DRUID" }, -- Challenging Roar
[5211] = { level=14, rank=1, next=6798, class="DRUID" }, -- Bash
[5215] = { level=20, rank=1, class="DRUID" }, -- Prowl
[5217] = { level=24, rank=1, next=6793, class="DRUID" }, -- Tiger's Fury
[5221] = { level=22, rank=1, next=6800, class="DRUID" }, -- Shred
[5225] = { level=32, class="DRUID" }, -- Track Humanoids
[5229] = { level=12, class="DRUID" }, -- Enrage
[5232] = { level=10, rank=2, next=6756, class="DRUID" }, -- Mark of the Wild
[5234] = { level=30, rank=4, next=8907, class="DRUID" }, -- Mark of the Wild
[5242] = { level=12, rank=2, next=6192, class="WARRIOR" }, -- Battle Shout
[5246] = { level=22, class="WARRIOR" }, -- Intimidating Shout
[5277] = { level=8, rank=1, next=26669, class="ROGUE" }, -- Evasion
[5308] = { level=24, rank=1, next=20658, class="WARRIOR" }, -- Execute
[5384] = { level=30, class="HUNTER" }, -- Feign Death
[5394] = { level=20, rank=1, next=6375, class="SHAMAN" }, -- Healing Stream Totem
[5484] = { level=40, rank=1, next=17928, class="WARLOCK" }, -- Howl of Terror
[5487] = { level=10, class="DRUID" }, -- Bear Form
[5500] = { level=24, class="WARLOCK" }, -- Sense Demons
[20116] = { level=30, rank=2, next=20922, class="PALADIN" }, -- Consecration
[5504] = { level=4, rank=1, next=5505, class="MAGE" }, -- Conjure Water
[5505] = { level=10, rank=2, next=5506, class="MAGE" }, -- Conjure Water
[5506] = { level=20, rank=3, next=6127, class="MAGE" }, -- Conjure Water
[5570] = { level=30, rank=1, next=24974, class="DRUID" }, -- Insect Swarm
[5588] = { level=24, rank=2, next=5589, class="PALADIN" }, -- Hammer of Justice
[5589] = { level=40, rank=3, next=10308, class="PALADIN" }, -- Hammer of Justice
[5599] = { level=24, rank=2, next=10278, class="PALADIN" }, -- Hand of Protection
[20922] = { level=40, rank=3, next=20923, class="PALADIN" }, -- Consecration
[20923] = { level=50, rank=4, next=20924, class="PALADIN" }, -- Consecration
[5675] = { level=26, rank=1, next=10495, class="SHAMAN" }, -- Mana Spring Totem
[5676] = { level=18, rank=1, next=17919, class="WARLOCK" }, -- Searing Pain
[5697] = { level=16, class="WARLOCK" }, -- Unending Breath
[5699] = { level=34, rank=3, next=11729, class="WARLOCK" }, -- Create Healthstone
[5730] = { level=8, rank=1, next=6390, class="SHAMAN" }, -- Stoneclaw Totem
[5740] = { level=20, rank=1, next=6219, class="WARLOCK" }, -- Rain of Fire
[5782] = { level=8, rank=1, next=6213, class="WARLOCK" }, -- Fear
[5938] = { level=70, class="ROGUE" }, -- Shiv
[6041] = { level=32, rank=6, next=10391, class="SHAMAN" }, -- Lightning Bolt
[6060] = { level=38, rank=6, next=10933, class="PRIEST" }, -- Smite
[6063] = { level=28, rank=3, next=6064, class="PRIEST" }, -- Heal
[6064] = { level=34, rank=4, next=2060, class="PRIEST" }, -- Heal
[6065] = { level=30, rank=5, next=6066, class="PRIEST" }, -- Power Word: Shield
[6066] = { level=36, rank=6, next=10898, class="PRIEST" }, -- Power Word: Shield
[6074] = { level=14, rank=2, next=6075, class="PRIEST" }, -- Renew
[6075] = { level=20, rank=3, next=6076, class="PRIEST" }, -- Renew
[6076] = { level=26, rank=4, next=6077, class="PRIEST" }, -- Renew
[6077] = { level=32, rank=5, next=6078, class="PRIEST" }, -- Renew
[6078] = { level=38, rank=6, next=10927, class="PRIEST" }, -- Renew
[6117] = { level=34, rank=1, next=22782, class="MAGE" }, -- Mage Armor
[6127] = { level=30, rank=4, next=10138, class="MAGE" }, -- Conjure Water
[6129] = { level=32, rank=4, next=10144, class="MAGE" }, -- Conjure Food
[6131] = { level=40, rank=3, next=10230, class="MAGE" }, -- Frost Nova
[6141] = { level=28, rank=2, next=8427, class="MAGE" }, -- Blizzard
[6143] = { level=22, rank=1, next=8461, class="MAGE" }, -- Frost Ward
[6178] = { level=26, rank=2, next=11578, class="WARRIOR" }, -- Charge
[6190] = { level=24, rank=2, next=11554, class="WARRIOR" }, -- Demoralizing Shout
[6192] = { level=22, rank=3, next=11549, class="WARRIOR" }, -- Battle Shout
[6196] = { level=26, class="SHAMAN" }, -- Far Sight
[6197] = { level=14, class="HUNTER" }, -- Eagle Eye
[6201] = { level=10, rank=1, next=6202, class="WARLOCK" }, -- Create Healthstone
[6202] = { level=22, rank=2, next=5699, class="WARLOCK" }, -- Create Healthstone
[6205] = { level=22, rank=3, next=7646, class="WARLOCK" }, -- Curse of Weakness
[6213] = { level=32, rank=2, next=6215, class="WARLOCK" }, -- Fear
[6215] = { level=56, rank=3, class="WARLOCK" }, -- Fear
[6217] = { level=28, rank=3, next=11711, class="WARLOCK" }, -- Curse of Agony
[6219] = { level=34, rank=2, next=11677, class="WARLOCK" }, -- Rain of Fire
[6222] = { level=14, rank=2, next=6223, class="WARLOCK" }, -- Corruption
[6223] = { level=24, rank=3, next=7648, class="WARLOCK" }, -- Corruption
[6229] = { level=32, rank=1, next=11739, class="WARLOCK" }, -- Shadow Ward
[6343] = { level=6, rank=1, next=8198, class="WARRIOR" }, -- Thunder Clap
[6346] = { level=20, class="PRIEST" }, -- Fear Ward
[6353] = { level=48, rank=1, next=17924, class="WARLOCK" }, -- Soul Fire
[6363] = { level=20, rank=2, next=6364, class="SHAMAN" }, -- Searing Totem
[6364] = { level=30, rank=3, next=6365, class="SHAMAN" }, -- Searing Totem
[6365] = { level=40, rank=4, next=10437, class="SHAMAN" }, -- Searing Totem
[6366] = { level=28, rank=1, next=17951, class="WARLOCK" }, -- Create Firestone
[6375] = { level=30, rank=2, next=6377, class="SHAMAN" }, -- Healing Stream Totem
[6377] = { level=40, rank=3, next=10462, class="SHAMAN" }, -- Healing Stream Totem
[6390] = { level=18, rank=2, next=6391, class="SHAMAN" }, -- Stoneclaw Totem
[6391] = { level=28, rank=3, next=6392, class="SHAMAN" }, -- Stoneclaw Totem
[6392] = { level=38, rank=4, next=10427, class="SHAMAN" }, -- Stoneclaw Totem
[6495] = { level=34, class="SHAMAN" }, -- Sentry Totem
[6546] = { level=10, rank=2, next=6547, class="WARRIOR" }, -- Rend
[6547] = { level=20, rank=3, next=6548, class="WARRIOR" }, -- Rend
[6548] = { level=30, rank=4, next=11572, class="WARRIOR" }, -- Rend
[6552] = { level=38, class="WARRIOR" }, -- Pummel
[6572] = { level=14, rank=1, next=6574, class="WARRIOR" }, -- Revenge
[6574] = { level=24, rank=2, next=7379, class="WARRIOR" }, -- Revenge
[687] = { level=1, rank=1, next=696, class="WARLOCK" }, -- Demon Skin
[6756] = { level=20, rank=3, next=5234, class="DRUID" }, -- Mark of the Wild
[6760] = { level=8, rank=2, next=6761, class="ROGUE" }, -- Eviscerate
[6761] = { level=16, rank=3, next=6762, class="ROGUE" }, -- Eviscerate
[6762] = { level=24, rank=4, next=8623, class="ROGUE" }, -- Eviscerate
[6768] = { level=28, rank=2, next=8637, class="ROGUE" }, -- Feint
[6770] = { level=10, rank=1, next=2070, class="ROGUE" }, -- Sap
[6774] = { level=42, rank=2, class="ROGUE" }, -- Slice and Dice
[6778] = { level=32, rank=6, next=8903, class="DRUID" }, -- Healing Touch
[6780] = { level=38, rank=6, next=8905, class="DRUID" }, -- Wrath
[6785] = { level=32, rank=1, next=6787, class="DRUID" }, -- Ravage
[6787] = { level=42, rank=2, next=9866, class="DRUID" }, -- Ravage
[6789] = { level=42, rank=1, next=17925, class="WARLOCK" }, -- Death Coil
[6793] = { level=36, rank=2, next=9845, class="DRUID" }, -- Tiger's Fury
[6795] = { level=10, class="DRUID" }, -- Growl
[6798] = { level=30, rank=2, next=8983, class="DRUID" }, -- Bash
[6800] = { level=30, rank=2, next=8992, class="DRUID" }, -- Shred
[6807] = { level=10, rank=1, next=6808, class="DRUID" }, -- Maul
[6808] = { level=18, rank=2, next=6809, class="DRUID" }, -- Maul
[6809] = { level=26, rank=3, next=8972, class="DRUID" }, -- Maul
[6940] = { level=46, class="PALADIN" }, -- Hand of Sacrifice
[6991] = { level=10, class="HUNTER" }, -- Feed Pet
[7128] = { level=20, rank=2, next=602, class="PRIEST" }, -- Inner Fire
[7294] = { level=16, rank=1, next=10298, class="PALADIN" }, -- Retribution Aura
[7300] = { level=10, rank=2, next=7301, class="MAGE" }, -- Frost Armor
[7301] = { level=20, rank=3, next=7302, class="MAGE" }, -- Frost Armor
[7302] = { level=30, rank=1, next=7320, class="MAGE" }, -- Ice Armor
[7320] = { level=40, rank=2, next=10219, class="MAGE" }, -- Ice Armor
[7322] = { level=20, rank=4, next=8406, class="MAGE" }, -- Frostbolt
[20924] = { level=60, rank=5, next=27173, class="PALADIN" }, -- Consecration
[7369] = { level=30, rank=2, next=11608, class="WARRIOR" }, -- Cleave
[7379] = { level=34, rank=3, next=11600, class="WARRIOR" }, -- Revenge
[7384] = { level=12, class="WARRIOR" }, -- Overpower
[7386] = { level=10, class="WARRIOR" }, -- Sunder Armor
[7641] = { level=36, rank=6, next=11659, class="WARLOCK" }, -- Shadow Bolt
[7646] = { level=32, rank=4, next=11707, class="WARLOCK" }, -- Curse of Weakness
[7648] = { level=34, rank=4, next=11671, class="WARLOCK" }, -- Corruption
[7651] = { level=38, rank=4, next=11699, class="WARLOCK" }, -- Drain Life
[8004] = { level=20, rank=1, next=8008, class="SHAMAN" }, -- Lesser Healing Wave
[8005] = { level=40, rank=7, next=10395, class="SHAMAN" }, -- Healing Wave
[8008] = { level=28, rank=2, next=8010, class="SHAMAN" }, -- Lesser Healing Wave
[8010] = { level=36, rank=3, next=10466, class="SHAMAN" }, -- Lesser Healing Wave
[8012] = { level=32, rank=2, class="SHAMAN" }, -- Purge
[78] = { level=1, rank=1, next=284, class="WARRIOR" }, -- Heroic Strike
[8018] = { level=8, rank=2, next=8019, class="SHAMAN" }, -- Rockbiter Weapon
[8019] = { level=16, rank=3, next=10399, class="SHAMAN" }, -- Rockbiter Weapon
[8024] = { level=10, rank=1, next=8027, class="SHAMAN" }, -- Flametongue Weapon
[8027] = { level=18, rank=2, next=8030, class="SHAMAN" }, -- Flametongue Weapon
[8030] = { level=26, rank=3, next=16339, class="SHAMAN" }, -- Flametongue Weapon
[8033] = { level=20, rank=1, next=8038, class="SHAMAN" }, -- Frostbrand Weapon
[8038] = { level=28, rank=2, next=10456, class="SHAMAN" }, -- Frostbrand Weapon
[8042] = { level=4, rank=1, next=8044, class="SHAMAN" }, -- Earth Shock
[8044] = { level=8, rank=2, next=8045, class="SHAMAN" }, -- Earth Shock
[8045] = { level=14, rank=3, next=8046, class="SHAMAN" }, -- Earth Shock
[8046] = { level=24, rank=4, next=10412, class="SHAMAN" }, -- Earth Shock
[8050] = { level=10, rank=1, next=8052, class="SHAMAN" }, -- Flame Shock
[8052] = { level=18, rank=2, next=8053, class="SHAMAN" }, -- Flame Shock
[8053] = { level=28, rank=3, next=10447, class="SHAMAN" }, -- Flame Shock
[8056] = { level=20, rank=1, next=8058, class="SHAMAN" }, -- Frost Shock
[8058] = { level=34, rank=2, next=10472, class="SHAMAN" }, -- Frost Shock
[8071] = { level=4, rank=1, next=8154, class="SHAMAN" }, -- Stoneskin Totem
[8075] = { level=10, rank=1, next=8160, class="SHAMAN" }, -- Strength of Earth Totem
[8092] = { level=10, rank=1, next=8102, class="PRIEST" }, -- Mind Blast
[8102] = { level=16, rank=2, next=8103, class="PRIEST" }, -- Mind Blast
[8103] = { level=22, rank=3, next=8104, class="PRIEST" }, -- Mind Blast
[8104] = { level=28, rank=4, next=8105, class="PRIEST" }, -- Mind Blast
[8105] = { level=34, rank=5, next=8106, class="PRIEST" }, -- Mind Blast
[8106] = { level=40, rank=6, next=10945, class="PRIEST" }, -- Mind Blast
[8122] = { level=14, rank=1, next=8124, class="PRIEST" }, -- Psychic Scream
[8124] = { level=28, rank=2, next=10888, class="PRIEST" }, -- Psychic Scream
[8129] = { level=24, class="PRIEST" }, -- Mana Burn
[8134] = { level=40, rank=5, next=10431, class="SHAMAN" }, -- Lightning Shield
[8143] = { level=18, class="SHAMAN" }, -- Tremor Totem
[8154] = { level=14, rank=2, next=8155, class="SHAMAN" }, -- Stoneskin Totem
[8155] = { level=24, rank=3, next=10406, class="SHAMAN" }, -- Stoneskin Totem
[8160] = { level=24, rank=2, next=8161, class="SHAMAN" }, -- Strength of Earth Totem
[8161] = { level=38, rank=3, next=10442, class="SHAMAN" }, -- Strength of Earth Totem
[8170] = { level=38, class="SHAMAN" }, -- Cleansing Totem
[8177] = { level=30, class="SHAMAN" }, -- Grounding Totem
[8181] = { level=24, rank=1, next=10478, class="SHAMAN" }, -- Frost Resistance Totem
[8184] = { level=28, rank=1, next=10537, class="SHAMAN" }, -- Fire Resistance Totem
[8190] = { level=26, rank=1, next=10585, class="SHAMAN" }, -- Magma Totem
[8198] = { level=18, rank=2, next=8204, class="WARRIOR" }, -- Thunder Clap
[8204] = { level=28, rank=3, next=8205, class="WARRIOR" }, -- Thunder Clap
[8205] = { level=38, rank=4, next=11580, class="WARRIOR" }, -- Thunder Clap
[8227] = { level=28, rank=1, next=8249, class="SHAMAN" }, -- Flametongue Totem
[8232] = { level=30, rank=1, next=8235, class="SHAMAN" }, -- Windfury Weapon
[8235] = { level=40, rank=2, next=10486, class="SHAMAN" }, -- Windfury Weapon
[8249] = { level=38, rank=2, next=10526, class="SHAMAN" }, -- Flametongue Totem
[8288] = { level=24, rank=2, next=8289, class="WARLOCK" }, -- Drain Soul
[8289] = { level=38, rank=3, next=11675, class="WARLOCK" }, -- Drain Soul
[8400] = { level=24, rank=5, next=8401, class="MAGE" }, -- Fireball
[8401] = { level=30, rank=6, next=8402, class="MAGE" }, -- Fireball
[8402] = { level=36, rank=7, next=10148, class="MAGE" }, -- Fireball
[8406] = { level=26, rank=5, next=8407, class="MAGE" }, -- Frostbolt
[8407] = { level=32, rank=6, next=8408, class="MAGE" }, -- Frostbolt
[8408] = { level=38, rank=7, next=10179, class="MAGE" }, -- Frostbolt
[8412] = { level=30, rank=4, next=8413, class="MAGE" }, -- Fire Blast
[8413] = { level=38, rank=5, next=10197, class="MAGE" }, -- Fire Blast
[8416] = { level=32, rank=4, next=8417, class="MAGE" }, -- Arcane Missiles
[8417] = { level=40, rank=5, next=10211, class="MAGE" }, -- Arcane Missiles
[8422] = { level=32, rank=3, next=8423, class="MAGE" }, -- Flamestrike
[8423] = { level=40, rank=4, next=10215, class="MAGE" }, -- Flamestrike
[8427] = { level=36, rank=3, next=10185, class="MAGE" }, -- Blizzard
[8437] = { level=22, rank=2, next=8438, class="MAGE" }, -- Arcane Explosion
[8438] = { level=30, rank=3, next=8439, class="MAGE" }, -- Arcane Explosion
[8439] = { level=38, rank=4, next=10201, class="MAGE" }, -- Arcane Explosion
[8444] = { level=28, rank=2, next=8445, class="MAGE" }, -- Scorch
[8445] = { level=34, rank=3, next=8446, class="MAGE" }, -- Scorch
[8446] = { level=40, rank=4, next=10205, class="MAGE" }, -- Scorch
[8450] = { level=24, rank=2, next=8451, class="MAGE" }, -- Dampen Magic
[8451] = { level=36, rank=3, next=10173, class="MAGE" }, -- Dampen Magic
[8455] = { level=30, rank=2, next=10169, class="MAGE" }, -- Amplify Magic
[8457] = { level=30, rank=2, next=8458, class="MAGE" }, -- Fire Ward
[8458] = { level=40, rank=3, next=10223, class="MAGE" }, -- Fire Ward
[8461] = { level=32, rank=2, next=8462, class="MAGE" }, -- Frost Ward
[8462] = { level=42, rank=3, next=10177, class="MAGE" }, -- Frost Ward
[8492] = { level=34, rank=2, next=10159, class="MAGE" }, -- Cone of Cold
[8494] = { level=28, rank=2, next=8495, class="MAGE" }, -- Mana Shield
[8495] = { level=36, rank=3, next=10191, class="MAGE" }, -- Mana Shield
[8498] = { level=22, rank=2, next=8499, class="SHAMAN" }, -- Fire Nova
[8499] = { level=32, rank=3, next=11314, class="SHAMAN" }, -- Fire Nova
[8512] = { level=32, class="SHAMAN" }, -- Windfury Totem
[8621] = { level=38, rank=6, next=11293, class="ROGUE" }, -- Sinister Strike
[8623] = { level=32, rank=5, next=8624, class="ROGUE" }, -- Eviscerate
[8624] = { level=40, rank=6, next=11299, class="ROGUE" }, -- Eviscerate
[8631] = { level=22, rank=2, next=8632, class="ROGUE" }, -- Garrote
[8632] = { level=30, rank=3, next=8633, class="ROGUE" }, -- Garrote
[8633] = { level=38, rank=4, next=11289, class="ROGUE" }, -- Garrote
[8637] = { level=40, rank=3, next=11303, class="ROGUE" }, -- Feint
[8639] = { level=28, rank=2, next=8640, class="ROGUE" }, -- Rupture
[8640] = { level=36, rank=3, next=11273, class="ROGUE" }, -- Rupture
[8643] = { level=50, rank=2, class="ROGUE" }, -- Kidney Shot
[8647] = { level=14, class="ROGUE" }, -- Expose Armor
[8676] = { level=18, rank=1, next=8724, class="ROGUE" }, -- Ambush
[8679] = { level=20, rank=1, next=8685, class="ROGUE" }, -- Instant Poison
[8680] = { level=20, rank=1, next=8686, class="ROGUE" }, -- Instant Poison
[8685] = { level=28, rank=2, next=8688, class="ROGUE" }, -- Instant Poison II
[8686] = { level=28, rank=2, next=8689, class="ROGUE" }, -- Instant Poison II
[8688] = { level=36, rank=3, next=11335, class="ROGUE" }, -- Instant Poison III
[8689] = { level=36, rank=3, next=11338, class="ROGUE" }, -- Instant Poison III
[8696] = { level=34, rank=2, next=11305, class="ROGUE" }, -- Sprint
[8721] = { level=36, rank=5, next=11279, class="ROGUE" }, -- Backstab
[8724] = { level=26, rank=2, next=8725, class="ROGUE" }, -- Ambush
[8725] = { level=34, rank=3, next=11267, class="ROGUE" }, -- Ambush
[8820] = { level=38, rank=2, next=11604, class="WARRIOR" }, -- Slam
[8903] = { level=38, rank=7, next=9758, class="DRUID" }, -- Healing Touch
[8905] = { level=46, rank=7, next=9912, class="DRUID" }, -- Wrath
[8907] = { level=40, rank=5, next=9884, class="DRUID" }, -- Mark of the Wild
[8910] = { level=40, rank=7, next=9839, class="DRUID" }, -- Rejuvenation
[8914] = { level=34, rank=4, next=9756, class="DRUID" }, -- Thorns
[8918] = { level=40, rank=2, next=9862, class="DRUID" }, -- Tranquility
[8921] = { level=4, rank=1, next=8924, class="DRUID" }, -- Moonfire
[8924] = { level=10, rank=2, next=8925, class="DRUID" }, -- Moonfire
[8925] = { level=16, rank=3, next=8926, class="DRUID" }, -- Moonfire
[8926] = { level=22, rank=4, next=8927, class="DRUID" }, -- Moonfire
[8927] = { level=28, rank=5, next=8928, class="DRUID" }, -- Moonfire
[8928] = { level=34, rank=6, next=8929, class="DRUID" }, -- Moonfire
[8929] = { level=40, rank=7, next=9833, class="DRUID" }, -- Moonfire
[8936] = { level=12, rank=1, next=8938, class="DRUID" }, -- Regrowth
[8938] = { level=18, rank=2, next=8939, class="DRUID" }, -- Regrowth
[8939] = { level=24, rank=3, next=8940, class="DRUID" }, -- Regrowth
[8940] = { level=30, rank=4, next=8941, class="DRUID" }, -- Regrowth
[8941] = { level=36, rank=5, next=9750, class="DRUID" }, -- Regrowth
[8946] = { level=14, rank=1, class="DRUID" }, -- Cure Poison
[8949] = { level=26, rank=2, next=8950, class="DRUID" }, -- Starfire
[8950] = { level=34, rank=3, next=8951, class="DRUID" }, -- Starfire
[8951] = { level=42, rank=4, next=9875, class="DRUID" }, -- Starfire
[8955] = { level=38, rank=2, next=9901, class="DRUID" }, -- Soothe Animal
[8972] = { level=34, rank=4, next=9745, class="DRUID" }, -- Maul
[8983] = { level=46, rank=3, class="DRUID" }, -- Bash
[8992] = { level=38, rank=3, next=9829, class="DRUID" }, -- Shred
[8998] = { level=28, rank=1, next=9000, class="DRUID" }, -- Cower
[9000] = { level=40, rank=2, next=9892, class="DRUID" }, -- Cower
[9005] = { level=36, rank=1, next=9823, class="DRUID" }, -- Pounce
[9472] = { level=26, rank=2, next=9473, class="PRIEST" }, -- Flash Heal
[9473] = { level=32, rank=3, next=9474, class="PRIEST" }, -- Flash Heal
[9474] = { level=38, rank=4, next=10915, class="PRIEST" }, -- Flash Heal
[9484] = { level=20, rank=1, next=9485, class="PRIEST" }, -- Shackle Undead
[9485] = { level=40, rank=2, next=10955, class="PRIEST" }, -- Shackle Undead
[9490] = { level=32, rank=3, next=9747, class="DRUID" }, -- Demoralizing Roar
[9492] = { level=28, rank=2, next=9493, class="DRUID" }, -- Rip
[9493] = { level=36, rank=3, next=9752, class="DRUID" }, -- Rip
[9634] = { level=40, class="DRUID" }, -- Dire Bear Form
[9745] = { level=42, rank=5, next=9880, class="DRUID" }, -- Maul
[9747] = { level=42, rank=4, next=9898, class="DRUID" }, -- Demoralizing Roar
[9750] = { level=42, rank=6, next=9856, class="DRUID" }, -- Regrowth
[9752] = { level=44, rank=4, next=9894, class="DRUID" }, -- Rip
[9754] = { level=44, rank=4, next=9908, class="DRUID" }, -- Swipe (Bear)
[9756] = { level=44, rank=5, next=9910, class="DRUID" }, -- Thorns
[9758] = { level=44, rank=8, next=9888, class="DRUID" }, -- Healing Touch
[9821] = { level=46, rank=2, next=33357, class="DRUID" }, -- Dash
[9823] = { level=46, rank=2, next=9827, class="DRUID" }, -- Pounce
[9827] = { level=56, rank=3, next=27006, class="DRUID" }, -- Pounce
[9829] = { level=46, rank=4, next=9830, class="DRUID" }, -- Shred
[9830] = { level=54, rank=5, next=27001, class="DRUID" }, -- Shred
[9833] = { level=46, rank=8, next=9834, class="DRUID" }, -- Moonfire
[9834] = { level=52, rank=9, next=9835, class="DRUID" }, -- Moonfire
[9835] = { level=58, rank=10, next=26987, class="DRUID" }, -- Moonfire
[9839] = { level=46, rank=8, next=9840, class="DRUID" }, -- Rejuvenation
[9840] = { level=52, rank=9, next=9841, class="DRUID" }, -- Rejuvenation
[9841] = { level=58, rank=10, next=25299, class="DRUID" }, -- Rejuvenation
[9845] = { level=48, rank=3, next=9846, class="DRUID" }, -- Tiger's Fury
[9846] = { level=60, rank=4, next=50212, class="DRUID" }, -- Tiger's Fury
[9849] = { level=48, rank=4, next=9850, class="DRUID" }, -- Claw
[9850] = { level=58, rank=5, next=27000, class="DRUID" }, -- Claw
[9852] = { level=48, rank=5, next=9853, class="DRUID" }, -- Entangling Roots
[9853] = { level=58, rank=6, next=26989, class="DRUID" }, -- Entangling Roots
[9856] = { level=48, rank=7, next=9857, class="DRUID" }, -- Regrowth
[9857] = { level=54, rank=8, next=9858, class="DRUID" }, -- Regrowth
[9858] = { level=60, rank=9, next=26980, class="DRUID" }, -- Regrowth
[9862] = { level=50, rank=3, next=9863, class="DRUID" }, -- Tranquility
[9863] = { level=60, rank=4, next=26983, class="DRUID" }, -- Tranquility
[9866] = { level=50, rank=3, next=9867, class="DRUID" }, -- Ravage
[9867] = { level=58, rank=4, next=27005, class="DRUID" }, -- Ravage
[9875] = { level=50, rank=5, next=9876, class="DRUID" }, -- Starfire
[9876] = { level=58, rank=6, next=25298, class="DRUID" }, -- Starfire
[9880] = { level=50, rank=6, next=9881, class="DRUID" }, -- Maul
[9881] = { level=58, rank=7, next=26996, class="DRUID" }, -- Maul
[9884] = { level=50, rank=6, next=9885, class="DRUID" }, -- Mark of the Wild
[9885] = { level=60, rank=7, next=26990, class="DRUID" }, -- Mark of the Wild
[9888] = { level=50, rank=9, next=9889, class="DRUID" }, -- Healing Touch
[9889] = { level=56, rank=10, next=25297, class="DRUID" }, -- Healing Touch
[9892] = { level=52, rank=3, next=31709, class="DRUID" }, -- Cower
[9894] = { level=52, rank=5, next=9896, class="DRUID" }, -- Rip
[9896] = { level=60, rank=6, next=27008, class="DRUID" }, -- Rip
[9898] = { level=52, rank=5, next=26998, class="DRUID" }, -- Demoralizing Roar
[9901] = { level=54, rank=3, next=26995, class="DRUID" }, -- Soothe Animal
[9904] = { level=54, rank=4, next=27003, class="DRUID" }, -- Rake
[9908] = { level=54, rank=5, next=26997, class="DRUID" }, -- Swipe (Bear)
[9910] = { level=54, rank=6, next=26992, class="DRUID" }, -- Thorns
[9912] = { level=54, rank=8, next=26984, class="DRUID" }, -- Wrath
[10053] = { level=48, rank=3, next=10054, class="MAGE" }, -- Conjure Mana Gem
[10054] = { level=58, rank=4, next=27101, class="MAGE" }, -- Conjure Mana Gem
[10059] = { level=40, class="MAGE", faction="Alliance" }, -- Portal: Stormwind
[10138] = { level=40, rank=5, next=10139, class="MAGE" }, -- Conjure Water
[10139] = { level=50, rank=6, next=10140, class="MAGE" }, -- Conjure Water
[10140] = { level=60, rank=7, next=37420, class="MAGE" }, -- Conjure Water
[10144] = { level=42, rank=5, next=10145, class="MAGE" }, -- Conjure Food
[10145] = { level=52, rank=6, next=28612, class="MAGE" }, -- Conjure Food
[10148] = { level=42, rank=8, next=10149, class="MAGE" }, -- Fireball
[10149] = { level=48, rank=9, next=10150, class="MAGE" }, -- Fireball
[10150] = { level=54, rank=10, next=10151, class="MAGE" }, -- Fireball
[10151] = { level=60, rank=11, next=25306, class="MAGE" }, -- Fireball
[10156] = { level=42, rank=4, next=10157, class="MAGE" }, -- Arcane Intellect
[10157] = { level=56, rank=5, next=27126, class="MAGE" }, -- Arcane Intellect
[10159] = { level=42, rank=3, next=10160, class="MAGE" }, -- Cone of Cold
[10160] = { level=50, rank=4, next=10161, class="MAGE" }, -- Cone of Cold
[10161] = { level=58, rank=5, next=27087, class="MAGE" }, -- Cone of Cold
[10169] = { level=42, rank=3, next=10170, class="MAGE" }, -- Amplify Magic
[10170] = { level=54, rank=4, next=27130, class="MAGE" }, -- Amplify Magic
[10173] = { level=48, rank=4, next=10174, class="MAGE" }, -- Dampen Magic
[10174] = { level=60, rank=5, next=33944, class="MAGE" }, -- Dampen Magic
[10177] = { level=52, rank=4, next=28609, class="MAGE" }, -- Frost Ward
[10179] = { level=44, rank=8, next=10180, class="MAGE" }, -- Frostbolt
[10180] = { level=50, rank=9, next=10181, class="MAGE" }, -- Frostbolt
[10181] = { level=56, rank=10, next=25304, class="MAGE" }, -- Frostbolt
[10185] = { level=44, rank=4, next=10186, class="MAGE" }, -- Blizzard
[10186] = { level=52, rank=5, next=10187, class="MAGE" }, -- Blizzard
[10187] = { level=60, rank=6, next=27085, class="MAGE" }, -- Blizzard
[10191] = { level=44, rank=4, next=10192, class="MAGE" }, -- Mana Shield
[10192] = { level=52, rank=5, next=10193, class="MAGE" }, -- Mana Shield
[10193] = { level=60, rank=6, next=27131, class="MAGE" }, -- Mana Shield
[10197] = { level=46, rank=6, next=10199, class="MAGE" }, -- Fire Blast
[10199] = { level=54, rank=7, next=27078, class="MAGE" }, -- Fire Blast
[10201] = { level=46, rank=5, next=10202, class="MAGE" }, -- Arcane Explosion
[10202] = { level=54, rank=6, next=27080, class="MAGE" }, -- Arcane Explosion
[10205] = { level=46, rank=5, next=10206, class="MAGE" }, -- Scorch
[10206] = { level=52, rank=6, next=10207, class="MAGE" }, -- Scorch
[10207] = { level=58, rank=7, next=27073, class="MAGE" }, -- Scorch
[10211] = { level=48, rank=6, next=10212, class="MAGE" }, -- Arcane Missiles
[10212] = { level=56, rank=7, next=25345, class="MAGE" }, -- Arcane Missiles
[10215] = { level=48, rank=5, next=10216, class="MAGE" }, -- Flamestrike
[10216] = { level=56, rank=6, next=27086, class="MAGE" }, -- Flamestrike
[10219] = { level=50, rank=3, next=10220, class="MAGE" }, -- Ice Armor
[10220] = { level=60, rank=4, next=27124, class="MAGE" }, -- Ice Armor
[10223] = { level=50, rank=4, next=10225, class="MAGE" }, -- Fire Ward
[10225] = { level=60, rank=5, next=27128, class="MAGE" }, -- Fire Ward
[10230] = { level=54, rank=4, next=27088, class="MAGE" }, -- Frost Nova
[10278] = { level=38, rank=3, class="PALADIN" }, -- Hand of Protection
[10290] = { level=10, rank=2, next=643, class="PALADIN" }, -- Devotion Aura
[10291] = { level=30, rank=4, next=1032, class="PALADIN" }, -- Devotion Aura
[10292] = { level=50, rank=6, next=10293, class="PALADIN" }, -- Devotion Aura
[10293] = { level=60, rank=7, next=27149, class="PALADIN" }, -- Devotion Aura
[10298] = { level=26, rank=2, next=10299, class="PALADIN" }, -- Retribution Aura
[10299] = { level=36, rank=3, next=10300, class="PALADIN" }, -- Retribution Aura
[10300] = { level=46, rank=4, next=10301, class="PALADIN" }, -- Retribution Aura
[10301] = { level=56, rank=5, next=27150, class="PALADIN" }, -- Retribution Aura
[10308] = { level=54, rank=4, class="PALADIN" }, -- Hammer of Justice
[26573] = { level=20, rank=1, next=20116, class="PALADIN" }, -- Consecration
[27173] = { level=70, rank=6, next=48818, class="PALADIN" }, -- Consecration
[48818] = { level=75, rank=7, next=48819, class="PALADIN" }, -- Consecration
[48819] = { level=80, rank=8, class="PALADIN" }, -- Consecration
[54428] = { level=71, class="PALADIN" }, -- Divine Plea
[879] = { level=20, rank=1, next=5614, class="PALADIN" }, -- Exorcism
[5614] = { level=28, rank=2, next=5615, class="PALADIN" }, -- Exorcism
[5615] = { level=36, rank=3, next=10312, class="PALADIN" }, -- Exorcism
[10312] = { level=44, rank=4, next=10313, class="PALADIN" }, -- Exorcism
[10313] = { level=52, rank=5, next=10314, class="PALADIN" }, -- Exorcism
[10391] = { level=38, rank=7, next=10392, class="SHAMAN" }, -- Lightning Bolt
[10392] = { level=44, rank=8, next=15207, class="SHAMAN" }, -- Lightning Bolt
[10395] = { level=48, rank=8, next=10396, class="SHAMAN" }, -- Healing Wave
[10396] = { level=56, rank=9, next=25357, class="SHAMAN" }, -- Healing Wave
[10399] = { level=24, rank=4, next=8232, class="SHAMAN" }, -- Rockbiter Weapon
[10406] = { level=34, rank=4, next=10407, class="SHAMAN" }, -- Stoneskin Totem
[10407] = { level=44, rank=5, next=10408, class="SHAMAN" }, -- Stoneskin Totem
[10408] = { level=54, rank=6, next=25508, class="SHAMAN" }, -- Stoneskin Totem
[10412] = { level=36, rank=5, next=10413, class="SHAMAN" }, -- Earth Shock
[10413] = { level=48, rank=6, next=10414, class="SHAMAN" }, -- Earth Shock
[10414] = { level=60, rank=7, next=25454, class="SHAMAN" }, -- Earth Shock
[10427] = { level=48, rank=5, next=10428, class="SHAMAN" }, -- Stoneclaw Totem
[10428] = { level=58, rank=6, next=25525, class="SHAMAN" }, -- Stoneclaw Totem
[10431] = { level=48, rank=6, next=10432, class="SHAMAN" }, -- Lightning Shield
[10432] = { level=56, rank=7, next=25469, class="SHAMAN" }, -- Lightning Shield
[10437] = { level=50, rank=5, next=10438, class="SHAMAN" }, -- Searing Totem
[10438] = { level=60, rank=6, next=25533, class="SHAMAN" }, -- Searing Totem
[10442] = { level=52, rank=4, next=25361, class="SHAMAN" }, -- Strength of Earth Totem
[10447] = { level=40, rank=4, next=10448, class="SHAMAN" }, -- Flame Shock
[10448] = { level=52, rank=5, next=29228, class="SHAMAN" }, -- Flame Shock
[10456] = { level=38, rank=3, next=16355, class="SHAMAN" }, -- Frostbrand Weapon
[10462] = { level=50, rank=4, next=10463, class="SHAMAN" }, -- Healing Stream Totem
[10463] = { level=60, rank=5, next=25567, class="SHAMAN" }, -- Healing Stream Totem
[10466] = { level=44, rank=4, next=10467, class="SHAMAN" }, -- Lesser Healing Wave
[10467] = { level=52, rank=5, next=10468, class="SHAMAN" }, -- Lesser Healing Wave
[10468] = { level=60, rank=6, next=25420, class="SHAMAN" }, -- Lesser Healing Wave
[10472] = { level=46, rank=3, next=10473, class="SHAMAN" }, -- Frost Shock
[10473] = { level=58, rank=4, next=25464, class="SHAMAN" }, -- Frost Shock
[10478] = { level=38, rank=2, next=10479, class="SHAMAN" }, -- Frost Resistance Totem
[10479] = { level=54, rank=3, next=25560, class="SHAMAN" }, -- Frost Resistance Totem
[10486] = { level=50, rank=3, next=16362, class="SHAMAN" }, -- Windfury Weapon
[10495] = { level=36, rank=2, next=10496, class="SHAMAN" }, -- Mana Spring Totem
[10496] = { level=46, rank=3, next=10497, class="SHAMAN" }, -- Mana Spring Totem
[10497] = { level=56, rank=4, next=25570, class="SHAMAN" }, -- Mana Spring Totem
[10526] = { level=48, rank=3, next=16387, class="SHAMAN" }, -- Flametongue Totem
[10537] = { level=42, rank=2, next=10538, class="SHAMAN" }, -- Fire Resistance Totem
[10538] = { level=58, rank=3, next=25563, class="SHAMAN" }, -- Fire Resistance Totem
[10585] = { level=36, rank=2, next=10586, class="SHAMAN" }, -- Magma Totem
[10586] = { level=46, rank=3, next=10587, class="SHAMAN" }, -- Magma Totem
[10587] = { level=56, rank=4, next=25552, class="SHAMAN" }, -- Magma Totem
[10595] = { level=30, rank=1, next=10600, class="SHAMAN" }, -- Nature Resistance Totem
[10600] = { level=44, rank=2, next=10601, class="SHAMAN" }, -- Nature Resistance Totem
[10601] = { level=60, rank=3, next=25574, class="SHAMAN" }, -- Nature Resistance Totem
[10605] = { level=56, rank=4, next=25439, class="SHAMAN" }, -- Chain Lightning
[10622] = { level=46, rank=2, next=10623, class="SHAMAN" }, -- Chain Heal
[10623] = { level=54, rank=3, next=25422, class="SHAMAN" }, -- Chain Heal
[10880] = { level=34, rank=3, next=10881, class="PRIEST" }, -- Resurrection
[10881] = { level=46, rank=4, next=20770, class="PRIEST" }, -- Resurrection
[10888] = { level=42, rank=3, next=10890, class="PRIEST" }, -- Psychic Scream
[10890] = { level=56, rank=4, class="PRIEST" }, -- Psychic Scream
[10892] = { level=42, rank=6, next=10893, class="PRIEST" }, -- Shadow Word: Pain
[10893] = { level=50, rank=7, next=10894, class="PRIEST" }, -- Shadow Word: Pain
[10894] = { level=58, rank=8, next=25367, class="PRIEST" }, -- Shadow Word: Pain
[10898] = { level=42, rank=7, next=10899, class="PRIEST" }, -- Power Word: Shield
[10899] = { level=48, rank=8, next=10900, class="PRIEST" }, -- Power Word: Shield
[10900] = { level=54, rank=9, next=10901, class="PRIEST" }, -- Power Word: Shield
[10901] = { level=60, rank=10, next=25217, class="PRIEST" }, -- Power Word: Shield
[10909] = { level=44, rank=2, class="PRIEST" }, -- Mind Vision
[10915] = { level=44, rank=5, next=10916, class="PRIEST" }, -- Flash Heal
[10916] = { level=50, rank=6, next=10917, class="PRIEST" }, -- Flash Heal
[10917] = { level=56, rank=7, next=25233, class="PRIEST" }, -- Flash Heal
[10927] = { level=44, rank=7, next=10928, class="PRIEST" }, -- Renew
[10928] = { level=50, rank=8, next=10929, class="PRIEST" }, -- Renew
[10929] = { level=56, rank=9, next=25315, class="PRIEST" }, -- Renew
[10933] = { level=46, rank=7, next=10934, class="PRIEST" }, -- Smite
[10934] = { level=54, rank=8, next=25363, class="PRIEST" }, -- Smite
[10937] = { level=48, rank=5, next=10938, class="PRIEST" }, -- Power Word: Fortitude
[10938] = { level=60, rank=6, next=25389, class="PRIEST" }, -- Power Word: Fortitude
[10945] = { level=46, rank=7, next=10946, class="PRIEST" }, -- Mind Blast
[10946] = { level=52, rank=8, next=10947, class="PRIEST" }, -- Mind Blast
[10947] = { level=58, rank=9, next=25372, class="PRIEST" }, -- Mind Blast
[10951] = { level=50, rank=5, next=10952, class="PRIEST" }, -- Inner Fire
[10952] = { level=60, rank=6, next=25431, class="PRIEST" }, -- Inner Fire
[10955] = { level=60, rank=3, class="PRIEST" }, -- Shackle Undead
[10957] = { level=42, rank=2, next=10958, class="PRIEST" }, -- Shadow Protection
[10958] = { level=56, rank=3, next=25433, class="PRIEST" }, -- Shadow Protection
[10960] = { level=50, rank=3, next=10961, class="PRIEST" }, -- Prayer of Healing
[10961] = { level=60, rank=4, next=25316, class="PRIEST" }, -- Prayer of Healing
[10963] = { level=46, rank=2, next=10964, class="PRIEST" }, -- Greater Heal
[10964] = { level=52, rank=3, next=10965, class="PRIEST" }, -- Greater Heal
[10965] = { level=58, rank=4, next=25314, class="PRIEST" }, -- Greater Heal
[11113] = { level=30, rank=1, next=13018, class="MAGE" }, -- Blast Wave
[11267] = { level=42, rank=4, next=11268, class="ROGUE" }, -- Ambush
[11268] = { level=50, rank=5, next=11269, class="ROGUE" }, -- Ambush
[11269] = { level=58, rank=6, next=27441, class="ROGUE" }, -- Ambush
[11273] = { level=44, rank=4, next=11274, class="ROGUE" }, -- Rupture
[11274] = { level=52, rank=5, next=11275, class="ROGUE" }, -- Rupture
[11275] = { level=60, rank=6, next=26867, class="ROGUE" }, -- Rupture
[11279] = { level=44, rank=6, next=11280, class="ROGUE" }, -- Backstab
[11280] = { level=52, rank=7, next=11281, class="ROGUE" }, -- Backstab
[11281] = { level=60, rank=8, next=25300, class="ROGUE" }, -- Backstab
[11289] = { level=46, rank=5, next=11290, class="ROGUE" }, -- Garrote
[11290] = { level=54, rank=6, next=26839, class="ROGUE" }, -- Garrote
[11293] = { level=46, rank=7, next=11294, class="ROGUE" }, -- Sinister Strike
[11294] = { level=54, rank=8, next=26861, class="ROGUE" }, -- Sinister Strike
[11297] = { level=48, rank=3, next=51724, class="ROGUE" }, -- Sap
[11299] = { level=48, rank=7, next=11300, class="ROGUE" }, -- Eviscerate
[11300] = { level=56, rank=8, next=31016, class="ROGUE" }, -- Eviscerate
[11303] = { level=52, rank=4, next=25302, class="ROGUE" }, -- Feint
[11305] = { level=58, rank=3, class="ROGUE" }, -- Sprint
[11314] = { level=42, rank=4, next=11315, class="SHAMAN" }, -- Fire Nova
[11315] = { level=52, rank=5, next=25546, class="SHAMAN" }, -- Fire Nova
[11335] = { level=44, rank=4, next=11336, class="ROGUE" }, -- Instant Poison IV
[11336] = { level=52, rank=5, next=11337, class="ROGUE" }, -- Instant Poison V
[11337] = { level=60, rank=6, next=26890, class="ROGUE" }, -- Instant Poison VI
[11338] = { level=44, rank=4, next=11339, class="ROGUE" }, -- Instant Poison IV
[11339] = { level=52, rank=5, next=11340, class="ROGUE" }, -- Instant Poison V
[11340] = { level=60, rank=6, next=26891, class="ROGUE" }, -- Instant Poison VI
[11353] = { level=46, rank=3, next=11354, class="ROGUE" }, -- Deadly Poison III
[11354] = { level=54, rank=4, next=25349, class="ROGUE" }, -- Deadly Poison IV
[11355] = { level=46, rank=3, next=11356, class="ROGUE" }, -- Deadly Poison III
[11356] = { level=54, rank=4, next=25351, class="ROGUE" }, -- Deadly Poison IV
[11366] = { level=20, rank=1, next=12505, class="MAGE" }, -- Pyroblast
[11416] = { level=40, class="MAGE", faction="Alliance" }, -- Portal: Ironforge
[11417] = { level=40, class="MAGE", faction="Horde" }, -- Portal: Orgrimmar
[11418] = { level=40, class="MAGE", faction="Horde" }, -- Portal: Undercity
[11419] = { level=50, class="MAGE", faction="Alliance" }, -- Portal: Darnassus
[11420] = { level=50, class="MAGE", faction="Horde" }, -- Portal: Thunder Bluff
[11426] = { level=40, rank=1, next=13031, class="MAGE" }, -- Ice Barrier
[11549] = { level=32, rank=4, next=11550, class="WARRIOR" }, -- Battle Shout
[11550] = { level=42, rank=5, next=11551, class="WARRIOR" }, -- Battle Shout
[11551] = { level=52, rank=6, next=25289, class="WARRIOR" }, -- Battle Shout
[11554] = { level=34, rank=3, next=11555, class="WARRIOR" }, -- Demoralizing Shout
[11555] = { level=44, rank=4, next=11556, class="WARRIOR" }, -- Demoralizing Shout
[11556] = { level=54, rank=5, next=25202, class="WARRIOR" }, -- Demoralizing Shout
[11564] = { level=32, rank=5, next=11565, class="WARRIOR" }, -- Heroic Strike
[11565] = { level=40, rank=6, next=11566, class="WARRIOR" }, -- Heroic Strike
[11566] = { level=48, rank=7, next=11567, class="WARRIOR" }, -- Heroic Strike
[11567] = { level=56, rank=8, next=25286, class="WARRIOR" }, -- Heroic Strike
[11572] = { level=40, rank=5, next=11573, class="WARRIOR" }, -- Rend
[11573] = { level=50, rank=6, next=11574, class="WARRIOR" }, -- Rend
[11574] = { level=60, rank=7, next=25208, class="WARRIOR" }, -- Rend
[11578] = { level=46, rank=3, class="WARRIOR" }, -- Charge
[11580] = { level=48, rank=5, next=11581, class="WARRIOR" }, -- Thunder Clap
[11581] = { level=58, rank=6, next=25264, class="WARRIOR" }, -- Thunder Clap
[11600] = { level=44, rank=4, next=11601, class="WARRIOR" }, -- Revenge
[11601] = { level=54, rank=5, next=25288, class="WARRIOR" }, -- Revenge
[11604] = { level=46, rank=3, next=11605, class="WARRIOR" }, -- Slam
[11605] = { level=54, rank=4, next=25241, class="WARRIOR" }, -- Slam
[11608] = { level=40, rank=3, next=11609, class="WARRIOR" }, -- Cleave
[11609] = { level=50, rank=4, next=20569, class="WARRIOR" }, -- Cleave
[11659] = { level=44, rank=7, next=11660, class="WARLOCK" }, -- Shadow Bolt
[11660] = { level=52, rank=8, next=11661, class="WARLOCK" }, -- Shadow Bolt
[11661] = { level=60, rank=9, next=25307, class="WARLOCK" }, -- Shadow Bolt
[11665] = { level=40, rank=5, next=11667, class="WARLOCK" }, -- Immolate
[11667] = { level=50, rank=6, next=11668, class="WARLOCK" }, -- Immolate
[11668] = { level=60, rank=7, next=25309, class="WARLOCK" }, -- Immolate
[11671] = { level=44, rank=5, next=11672, class="WARLOCK" }, -- Corruption
[11672] = { level=54, rank=6, next=25311, class="WARLOCK" }, -- Corruption
[11675] = { level=52, rank=4, next=27217, class="WARLOCK" }, -- Drain Soul
[11677] = { level=46, rank=3, next=11678, class="WARLOCK" }, -- Rain of Fire
[11678] = { level=58, rank=4, next=27212, class="WARLOCK" }, -- Rain of Fire
[11683] = { level=42, rank=2, next=11684, class="WARLOCK" }, -- Hellfire
[11684] = { level=54, rank=3, next=27213, class="WARLOCK" }, -- Hellfire
[11687] = { level=36, rank=4, next=11688, class="WARLOCK" }, -- Life Tap
[11688] = { level=46, rank=5, next=11689, class="WARLOCK" }, -- Life Tap
[11689] = { level=56, rank=6, next=27222, class="WARLOCK" }, -- Life Tap
[11693] = { level=44, rank=5, next=11694, class="WARLOCK" }, -- Health Funnel
[11694] = { level=52, rank=6, next=11695, class="WARLOCK" }, -- Health Funnel
[11695] = { level=60, rank=7, next=27259, class="WARLOCK" }, -- Health Funnel
[11699] = { level=46, rank=5, next=11700, class="WARLOCK" }, -- Drain Life
[11700] = { level=54, rank=6, next=27219, class="WARLOCK" }, -- Drain Life
[11707] = { level=42, rank=5, next=11708, class="WARLOCK" }, -- Curse of Weakness
[11708] = { level=52, rank=6, next=27224, class="WARLOCK" }, -- Curse of Weakness
[11711] = { level=38, rank=4, next=11712, class="WARLOCK" }, -- Curse of Agony
[11712] = { level=48, rank=5, next=11713, class="WARLOCK" }, -- Curse of Agony
[11713] = { level=58, rank=6, next=27218, class="WARLOCK" }, -- Curse of Agony
[11719] = { level=50, rank=2, class="WARLOCK" }, -- Curse of Tongues
[11721] = { level=46, rank=2, next=11722, class="WARLOCK" }, -- Curse of the Elements
[11722] = { level=60, rank=3, next=27228, class="WARLOCK" }, -- Curse of the Elements
[11725] = { level=44, rank=2, next=11726, class="WARLOCK" }, -- Enslave Demon
[11726] = { level=58, rank=3, next=61191, class="WARLOCK" }, -- Enslave Demon
[11729] = { level=46, rank=4, next=11730, class="WARLOCK" }, -- Create Healthstone
[11730] = { level=58, rank=5, next=27230, class="WARLOCK" }, -- Create Healthstone
[11733] = { level=40, rank=3, next=11734, class="WARLOCK" }, -- Demon Armor
[11734] = { level=50, rank=4, next=11735, class="WARLOCK" }, -- Demon Armor
[11735] = { level=60, rank=5, next=27260, class="WARLOCK" }, -- Demon Armor
[11739] = { level=42, rank=2, next=11740, class="WARLOCK" }, -- Shadow Ward
[11740] = { level=52, rank=3, next=28610, class="WARLOCK" }, -- Shadow Ward
[12051] = { level=20, class="MAGE" }, -- Evocation
[12294] = { level=40, rank=1, next=21551, class="WARRIOR" }, -- Mortal Strike
[12505] = { level=24, rank=2, next=12522, class="MAGE" }, -- Pyroblast
[12522] = { level=30, rank=3, next=12523, class="MAGE" }, -- Pyroblast
[12523] = { level=36, rank=4, next=12524, class="MAGE" }, -- Pyroblast
[12524] = { level=42, rank=5, next=12525, class="MAGE" }, -- Pyroblast
[12525] = { level=48, rank=6, next=12526, class="MAGE" }, -- Pyroblast
[12526] = { level=54, rank=7, next=18809, class="MAGE" }, -- Pyroblast
[12678] = { level=20, class="WARRIOR" }, -- Stance Mastery
[12824] = { level=20, rank=2, next=12825, class="MAGE" }, -- Polymorph
[12825] = { level=40, rank=3, next=12826, class="MAGE" }, -- Polymorph
[12826] = { level=60, rank=4, class="MAGE" }, -- Polymorph
[13018] = { level=36, rank=2, next=13019, class="MAGE" }, -- Blast Wave
[13019] = { level=44, rank=3, next=13020, class="MAGE" }, -- Blast Wave
[13020] = { level=52, rank=4, next=13021, class="MAGE" }, -- Blast Wave
[13021] = { level=60, rank=5, next=27133, class="MAGE" }, -- Blast Wave
[13031] = { level=46, rank=2, next=13032, class="MAGE" }, -- Ice Barrier
[13032] = { level=52, rank=3, next=13033, class="MAGE" }, -- Ice Barrier
[13033] = { level=58, rank=4, next=27134, class="MAGE" }, -- Ice Barrier
[13159] = { level=40, class="HUNTER" }, -- Aspect of the Pack
[13161] = { level=30, class="HUNTER" }, -- Aspect of the Beast
[13163] = { level=4, rank=1, next=61846, class="HUNTER" }, -- Aspect of the Monkey
[13165] = { level=10, rank=1, next=14318, class="HUNTER" }, -- Aspect of the Hawk
[13218] = { level=32, rank=1, next=13222, class="ROGUE" }, -- Wound Poison
[13219] = { level=32, rank=1, next=13225, class="ROGUE" }, -- Wound Poison
[13222] = { level=40, rank=2, next=13223, class="ROGUE" }, -- Wound Poison II
[13223] = { level=48, rank=3, next=13224, class="ROGUE" }, -- Wound Poison III
[13224] = { level=56, rank=4, next=27188, class="ROGUE" }, -- Wound Poison IV
[13225] = { level=40, rank=2, next=13226, class="ROGUE" }, -- Wound Poison II
[13226] = { level=48, rank=3, next=13227, class="ROGUE" }, -- Wound Poison III
[13227] = { level=56, rank=4, next=27189, class="ROGUE" }, -- Wound Poison IV
[13542] = { level=44, rank=5, next=13543, class="HUNTER" }, -- Mend Pet
[13543] = { level=52, rank=6, next=13544, class="HUNTER" }, -- Mend Pet
[13544] = { level=60, rank=7, next=27046, class="HUNTER" }, -- Mend Pet
[13549] = { level=10, rank=2, next=13550, class="HUNTER" }, -- Serpent Sting
[13550] = { level=18, rank=3, next=13551, class="HUNTER" }, -- Serpent Sting
[13551] = { level=26, rank=4, next=13552, class="HUNTER" }, -- Serpent Sting
[13552] = { level=34, rank=5, next=13553, class="HUNTER" }, -- Serpent Sting
[13553] = { level=42, rank=6, next=13554, class="HUNTER" }, -- Serpent Sting
[13554] = { level=50, rank=7, next=13555, class="HUNTER" }, -- Serpent Sting
[13555] = { level=58, rank=8, next=25295, class="HUNTER" }, -- Serpent Sting
[13795] = { level=16, rank=1, next=14302, class="HUNTER" }, -- Immolation Trap
[13809] = { level=28, class="HUNTER" }, -- Frost Trap
[13813] = { level=34, rank=1, next=14316, class="HUNTER" }, -- Explosive Trap
[14260] = { level=8, rank=2, next=14261, class="HUNTER" }, -- Raptor Strike
[14261] = { level=16, rank=3, next=14262, class="HUNTER" }, -- Raptor Strike
[14262] = { level=24, rank=4, next=14263, class="HUNTER" }, -- Raptor Strike
[14263] = { level=32, rank=5, next=14264, class="HUNTER" }, -- Raptor Strike
[14264] = { level=40, rank=6, next=14265, class="HUNTER" }, -- Raptor Strike
[14265] = { level=48, rank=7, next=14266, class="HUNTER" }, -- Raptor Strike
[14266] = { level=56, rank=8, next=27014, class="HUNTER" }, -- Raptor Strike
[14269] = { level=30, rank=2, next=14270, class="HUNTER" }, -- Mongoose Bite
[14270] = { level=44, rank=3, next=14271, class="HUNTER" }, -- Mongoose Bite
[14271] = { level=58, rank=4, next=36916, class="HUNTER" }, -- Mongoose Bite
[14281] = { level=12, rank=2, next=14282, class="HUNTER" }, -- Arcane Shot
[14282] = { level=20, rank=3, next=14283, class="HUNTER" }, -- Arcane Shot
[14283] = { level=28, rank=4, next=14284, class="HUNTER" }, -- Arcane Shot
[14284] = { level=36, rank=5, next=14285, class="HUNTER" }, -- Arcane Shot
[14285] = { level=44, rank=6, next=14286, class="HUNTER" }, -- Arcane Shot
[14286] = { level=52, rank=7, next=14287, class="HUNTER" }, -- Arcane Shot
[14287] = { level=60, rank=8, next=27019, class="HUNTER" }, -- Arcane Shot
[14288] = { level=30, rank=2, next=14289, class="HUNTER" }, -- Multi-Shot
[14289] = { level=42, rank=3, next=14290, class="HUNTER" }, -- Multi-Shot
[14290] = { level=54, rank=4, next=25294, class="HUNTER" }, -- Multi-Shot
[14294] = { level=50, rank=2, next=14295, class="HUNTER" }, -- Volley
[14295] = { level=58, rank=3, next=27022, class="HUNTER" }, -- Volley
[14302] = { level=26, rank=2, next=14303, class="HUNTER" }, -- Immolation Trap
[14303] = { level=36, rank=3, next=14304, class="HUNTER" }, -- Immolation Trap
[14304] = { level=46, rank=4, next=14305, class="HUNTER" }, -- Immolation Trap
[14305] = { level=56, rank=5, next=27023, class="HUNTER" }, -- Immolation Trap
[14310] = { level=40, rank=2, next=14311, class="HUNTER" }, -- Freezing Trap
[14311] = { level=60, rank=3, class="HUNTER" }, -- Freezing Trap
[14316] = { level=44, rank=2, next=14317, class="HUNTER" }, -- Explosive Trap
[14317] = { level=54, rank=3, next=27025, class="HUNTER" }, -- Explosive Trap
[14318] = { level=18, rank=2, next=14319, class="HUNTER" }, -- Aspect of the Hawk
[14319] = { level=28, rank=3, next=14320, class="HUNTER" }, -- Aspect of the Hawk
[14320] = { level=38, rank=4, next=14321, class="HUNTER" }, -- Aspect of the Hawk
[14321] = { level=48, rank=5, next=14322, class="HUNTER" }, -- Aspect of the Hawk
[14322] = { level=58, rank=6, next=25296, class="HUNTER" }, -- Aspect of the Hawk
[14323] = { level=22, rank=2, next=14324, class="HUNTER" }, -- Hunter's Mark
[14324] = { level=40, rank=3, next=14325, class="HUNTER" }, -- Hunter's Mark
[14325] = { level=58, rank=4, next=53338, class="HUNTER" }, -- Hunter's Mark
[14326] = { level=30, rank=2, next=14327, class="HUNTER" }, -- Scare Beast
[14327] = { level=46, rank=3, class="HUNTER" }, -- Scare Beast
[14752] = { level=30, rank=1, next=14818, class="PRIEST" }, -- Divine Spirit
[14818] = { level=40, rank=2, next=14819, class="PRIEST" }, -- Divine Spirit
[14819] = { level=50, rank=3, next=27841, class="PRIEST" }, -- Divine Spirit
[14914] = { level=20, rank=1, next=15262, class="PRIEST" }, -- Holy Fire
[15207] = { level=50, rank=9, next=15208, class="SHAMAN" }, -- Lightning Bolt
[15208] = { level=56, rank=10, next=25448, class="SHAMAN" }, -- Lightning Bolt
[15237] = { level=20, rank=1, next=15430, class="PRIEST" }, -- Holy Nova
[15261] = { level=60, rank=8, next=25384, class="PRIEST" }, -- Holy Fire
[15262] = { level=24, rank=2, next=15263, class="PRIEST" }, -- Holy Fire
[15263] = { level=30, rank=3, next=15264, class="PRIEST" }, -- Holy Fire
[15264] = { level=36, rank=4, next=15265, class="PRIEST" }, -- Holy Fire
[15265] = { level=42, rank=5, next=15266, class="PRIEST" }, -- Holy Fire
[15266] = { level=48, rank=6, next=15267, class="PRIEST" }, -- Holy Fire
[15267] = { level=54, rank=7, next=15261, class="PRIEST" }, -- Holy Fire
[15407] = { level=20, rank=1, next=17311, class="PRIEST" }, -- Mind Flay
[15430] = { level=28, rank=2, next=15431, class="PRIEST" }, -- Holy Nova
[15431] = { level=36, rank=3, next=27799, class="PRIEST" }, -- Holy Nova
[16339] = { level=36, rank=4, next=16341, class="SHAMAN" }, -- Flametongue Weapon
[16341] = { level=46, rank=5, next=16342, class="SHAMAN" }, -- Flametongue Weapon
[16342] = { level=56, rank=6, next=25489, class="SHAMAN" }, -- Flametongue Weapon
[16355] = { level=48, rank=4, next=16356, class="SHAMAN" }, -- Frostbrand Weapon
[16356] = { level=58, rank=5, next=25500, class="SHAMAN" }, -- Frostbrand Weapon
[16362] = { level=60, rank=4, next=25505, class="SHAMAN" }, -- Windfury Weapon
[16387] = { level=58, rank=4, next=25557, class="SHAMAN" }, -- Flametongue Totem
[16511] = { level=30, rank=1, next=17347, class="ROGUE" }, -- Hemorrhage
[16689] = { level=10, rank=1, next=16810, class="DRUID" }, -- Nature's Grasp
[16810] = { level=18, rank=2, next=16811, class="DRUID" }, -- Nature's Grasp
[16811] = { level=28, rank=3, next=16812, class="DRUID" }, -- Nature's Grasp
[16812] = { level=38, rank=4, next=16813, class="DRUID" }, -- Nature's Grasp
[16813] = { level=48, rank=5, next=17329, class="DRUID" }, -- Nature's Grasp
[16857] = { level=18, class="DRUID" }, -- Faerie Fire (Feral)
[16914] = { level=40, rank=1, next=17401, class="DRUID" }, -- Hurricane
[16979] = { level=20, class="DRUID" }, -- Feral Charge - Bear
[17311] = { level=28, rank=2, next=17312, class="PRIEST" }, -- Mind Flay
[17312] = { level=36, rank=3, next=17313, class="PRIEST" }, -- Mind Flay
[17313] = { level=44, rank=4, next=17314, class="PRIEST" }, -- Mind Flay
[17314] = { level=52, rank=5, next=18807, class="PRIEST" }, -- Mind Flay
[17329] = { level=58, rank=6, next=27009, class="DRUID" }, -- Nature's Grasp
[17347] = { level=46, rank=2, next=17348, class="ROGUE" }, -- Hemorrhage
[17348] = { level=58, rank=3, next=26864, class="ROGUE" }, -- Hemorrhage
[17401] = { level=50, rank=2, next=17402, class="DRUID" }, -- Hurricane
[17402] = { level=60, rank=3, next=27012, class="DRUID" }, -- Hurricane
[17727] = { level=48, rank=2, next=17728, class="WARLOCK" }, -- Create Spellstone
[17728] = { level=60, rank=3, next=28172, class="WARLOCK" }, -- Create Spellstone
[17877] = { level=20, rank=1, next=18867, class="WARLOCK" }, -- Shadowburn
[17919] = { level=26, rank=2, next=17920, class="WARLOCK" }, -- Searing Pain
[17920] = { level=34, rank=3, next=17921, class="WARLOCK" }, -- Searing Pain
[17921] = { level=42, rank=4, next=17922, class="WARLOCK" }, -- Searing Pain
[17922] = { level=50, rank=5, next=17923, class="WARLOCK" }, -- Searing Pain
[17923] = { level=58, rank=6, next=27210, class="WARLOCK" }, -- Searing Pain
[17924] = { level=56, rank=2, next=27211, class="WARLOCK" }, -- Soul Fire
[17925] = { level=50, rank=2, next=17926, class="WARLOCK" }, -- Death Coil
[17926] = { level=58, rank=3, next=27223, class="WARLOCK" }, -- Death Coil
[17928] = { level=54, rank=2, class="WARLOCK" }, -- Howl of Terror
[17951] = { level=36, rank=2, next=17952, class="WARLOCK" }, -- Create Firestone
[17952] = { level=46, rank=3, next=17953, class="WARLOCK" }, -- Create Firestone
[17953] = { level=56, rank=4, next=27250, class="WARLOCK" }, -- Create Firestone
[18220] = { level=40, rank=1, next=18937, class="WARLOCK" }, -- Dark Pact
[18499] = { level=32, class="WARRIOR" }, -- Berserker Rage
[18540] = { level=60, class="WARLOCK" }, -- Ritual of Doom
[18647] = { level=48, rank=2, class="WARLOCK" }, -- Banish
[18657] = { level=38, rank=2, next=18658, class="DRUID" }, -- Hibernate
[18658] = { level=58, rank=3, class="DRUID" }, -- Hibernate
[18807] = { level=60, rank=6, next=25387, class="PRIEST" }, -- Mind Flay
[18809] = { level=60, rank=8, next=27132, class="MAGE" }, -- Pyroblast
[18867] = { level=24, rank=2, next=18868, class="WARLOCK" }, -- Shadowburn
[18868] = { level=32, rank=3, next=18869, class="WARLOCK" }, -- Shadowburn
[18869] = { level=40, rank=4, next=18870, class="WARLOCK" }, -- Shadowburn
[18870] = { level=48, rank=5, next=18871, class="WARLOCK" }, -- Shadowburn
[18871] = { level=56, rank=6, next=27263, class="WARLOCK" }, -- Shadowburn
[18937] = { level=50, rank=2, next=18938, class="WARLOCK" }, -- Dark Pact
[18938] = { level=60, rank=3, next=27265, class="WARLOCK" }, -- Dark Pact
[18960] = { level=10, class="DRUID" }, -- Teleport: Moonglade
[19236] = { level=20, rank=1, next=19238, class="PRIEST" }, -- Desperate Prayer
[19238] = { level=26, rank=2, next=19240, class="PRIEST" }, -- Desperate Prayer
[19240] = { level=34, rank=3, next=19241, class="PRIEST" }, -- Desperate Prayer
[19241] = { level=42, rank=4, next=19242, class="PRIEST" }, -- Desperate Prayer
[19242] = { level=50, rank=5, next=19243, class="PRIEST" }, -- Desperate Prayer
[19243] = { level=58, rank=6, next=25437, class="PRIEST" }, -- Desperate Prayer
[19263] = { level=60, class="HUNTER" }, -- Deterrence
[19276] = { level=28, rank=2, next=19277, class="PRIEST" }, -- Devouring Plague
[19277] = { level=36, rank=3, next=19278, class="PRIEST" }, -- Devouring Plague
[19278] = { level=44, rank=4, next=19279, class="PRIEST" }, -- Devouring Plague
[19279] = { level=52, rank=5, next=19280, class="PRIEST" }, -- Devouring Plague
[19280] = { level=60, rank=6, next=25467, class="PRIEST" }, -- Devouring Plague
[19306] = { level=30, rank=1, next=20909, class="HUNTER" }, -- Counterattack
[19386] = { level=40, rank=1, next=24132, class="HUNTER" }, -- Wyvern Sting
[19434] = { level=20, rank=1, next=20900, class="HUNTER" }, -- Aimed Shot
[19740] = { level=4, rank=1, next=19834, class="PALADIN" }, -- Blessing of Might
[10314] = { level=60, rank=6, next=27138, class="PALADIN" }, -- Exorcism
[27138] = { level=68, rank=7, next=48800, class="PALADIN" }, -- Exorcism
[48800] = { level=73, rank=8, next=48801, class="PALADIN" }, -- Exorcism
[19752] = { level=30, class="PALADIN" }, -- Divine Intervention
[19801] = { level=60, class="HUNTER" }, -- Tranquilizing Shot
[19834] = { level=12, rank=2, next=19835, class="PALADIN" }, -- Blessing of Might
[19835] = { level=22, rank=3, next=19836, class="PALADIN" }, -- Blessing of Might
[19836] = { level=32, rank=4, next=19837, class="PALADIN" }, -- Blessing of Might
[19837] = { level=42, rank=5, next=19838, class="PALADIN" }, -- Blessing of Might
[19838] = { level=52, rank=6, next=25291, class="PALADIN" }, -- Blessing of Might
[48801] = { level=79, rank=9, class="PALADIN" }, -- Exorcism
[19750] = { level=20, rank=1, next=19939, class="PALADIN" }, -- Flash of Light
[19939] = { level=26, rank=2, next=19940, class="PALADIN" }, -- Flash of Light
[19940] = { level=34, rank=3, next=19941, class="PALADIN" }, -- Flash of Light
[19876] = { level=28, rank=1, next=19895, class="PALADIN" }, -- Shadow Resistance Aura
[19878] = { level=32, class="HUNTER" }, -- Track Demons
[19879] = { level=50, class="HUNTER" }, -- Track Dragonkin
[19880] = { level=26, class="HUNTER" }, -- Track Elementals
[19882] = { level=40, class="HUNTER" }, -- Track Giants
[19883] = { level=10, class="HUNTER" }, -- Track Humanoids
[19884] = { level=18, class="HUNTER" }, -- Track Undead
[19885] = { level=24, class="HUNTER" }, -- Track Hidden
[19888] = { level=32, rank=1, next=19897, class="PALADIN" }, -- Frost Resistance Aura
[19891] = { level=36, rank=1, next=19899, class="PALADIN" }, -- Fire Resistance Aura
[19895] = { level=40, rank=2, next=19896, class="PALADIN" }, -- Shadow Resistance Aura
[19896] = { level=52, rank=3, next=27151, class="PALADIN" }, -- Shadow Resistance Aura
[19897] = { level=44, rank=2, next=19898, class="PALADIN" }, -- Frost Resistance Aura
[19898] = { level=56, rank=3, next=27152, class="PALADIN" }, -- Frost Resistance Aura
[19899] = { level=48, rank=2, next=19900, class="PALADIN" }, -- Fire Resistance Aura
[19900] = { level=60, rank=3, next=27153, class="PALADIN" }, -- Fire Resistance Aura
[19941] = { level=42, rank=4, next=19942, class="PALADIN" }, -- Flash of Light
[19942] = { level=50, rank=5, next=19943, class="PALADIN" }, -- Flash of Light
[19943] = { level=58, rank=6, next=27137, class="PALADIN" }, -- Flash of Light
[27137] = { level=66, rank=7, next=48784, class="PALADIN" }, -- Flash of Light
[48784] = { level=74, rank=8, next=48785, class="PALADIN" }, -- Flash of Light
[20043] = { level=46, rank=1, next=20190, class="HUNTER" }, -- Aspect of the Wild
[48785] = { level=79, rank=9, class="PALADIN" }, -- Flash of Light
[20164] = { level=22, class="PALADIN" }, -- Seal of Justice
[25894] = { level=54, rank=1, next=25918, class="PALADIN" }, -- Greater Blessing of Wisdom
[25918] = { level=60, rank=2, next=27143, class="PALADIN" }, -- Greater Blessing of Wisdom
[20190] = { level=56, rank=2, next=27045, class="HUNTER" }, -- Aspect of the Wild
[20217] = { level=20, class="PALADIN" }, -- Blessing of Kings
[20230] = { level=20, class="WARRIOR" }, -- Retaliation
[20243] = { level=50, rank=1, next=30016, class="WARRIOR" }, -- Devastate
[20252] = { level=30, class="WARRIOR" }, -- Intercept
[20271] = { level=4, class="PALADIN" }, -- Judgement of Light
[27143] = { level=65, rank=3, next=48937, class="PALADIN" }, -- Greater Blessing of Wisdom
[20484] = { level=20, rank=1, next=20739, class="DRUID" }, -- Rebirth
[20569] = { level=60, rank=5, next=25231, class="WARRIOR" }, -- Cleave
[20608] = { level=30, class="SHAMAN" }, -- Reincarnation
[20609] = { level=24, rank=2, next=20610, class="SHAMAN" }, -- Ancestral Spirit
[20610] = { level=36, rank=3, next=20776, class="SHAMAN" }, -- Ancestral Spirit
[20658] = { level=32, rank=2, next=20660, class="WARRIOR" }, -- Execute
[20660] = { level=40, rank=3, next=20661, class="WARRIOR" }, -- Execute
[20661] = { level=48, rank=4, next=20662, class="WARRIOR" }, -- Execute
[20662] = { level=56, rank=5, next=25234, class="WARRIOR" }, -- Execute
[20719] = { level=40, class="DRUID" }, -- Feline Grace
[20736] = { level=12, rank=1, class="HUNTER" }, -- Distracting Shot
[20739] = { level=30, rank=2, next=20742, class="DRUID" }, -- Rebirth
[20742] = { level=40, rank=3, next=20747, class="DRUID" }, -- Rebirth
[20747] = { level=50, rank=4, next=20748, class="DRUID" }, -- Rebirth
[20748] = { level=60, rank=5, next=26994, class="DRUID" }, -- Rebirth
[20752] = { level=30, rank=2, next=20755, class="WARLOCK" }, -- Create Soulstone
[20755] = { level=40, rank=3, next=20756, class="WARLOCK" }, -- Create Soulstone
[20756] = { level=50, rank=4, next=20757, class="WARLOCK" }, -- Create Soulstone
[20757] = { level=60, rank=5, next=27238, class="WARLOCK" }, -- Create Soulstone
[20770] = { level=58, rank=5, next=25435, class="PRIEST" }, -- Resurrection
[48937] = { level=71, rank=4, next=48938, class="PALADIN" }, -- Greater Blessing of Wisdom
[48938] = { level=77, rank=5, class="PALADIN" }, -- Greater Blessing of Wisdom
[20776] = { level=48, rank=4, next=20777, class="SHAMAN" }, -- Ancestral Spirit
[20777] = { level=60, rank=5, next=25590, class="SHAMAN" }, -- Ancestral Spirit
[20900] = { level=28, rank=2, next=20901, class="HUNTER" }, -- Aimed Shot
[20901] = { level=36, rank=3, next=20902, class="HUNTER" }, -- Aimed Shot
[20902] = { level=44, rank=4, next=20903, class="HUNTER" }, -- Aimed Shot
[20903] = { level=52, rank=5, next=20904, class="HUNTER" }, -- Aimed Shot
[20904] = { level=60, rank=6, next=27065, class="HUNTER" }, -- Aimed Shot
[20909] = { level=42, rank=2, next=20910, class="HUNTER" }, -- Counterattack
[20910] = { level=54, rank=3, next=27067, class="HUNTER" }, -- Counterattack
[6673] = { level=1, rank=1, next=5242, class="WARRIOR" }, -- Battle Shout
[639] = { level=6, rank=2, next=647, class="PALADIN" }, -- Holy Light
[647] = { level=14, rank=3, next=1026, class="PALADIN" }, -- Holy Light
[1026] = { level=22, rank=4, next=1042, class="PALADIN" }, -- Holy Light
[20927] = { level=50, rank=2, next=20928, class="PALADIN" }, -- Holy Shield
[20928] = { level=60, rank=3, next=27179, class="PALADIN" }, -- Holy Shield
[1042] = { level=30, rank=5, next=3472, class="PALADIN" }, -- Holy Light
[3472] = { level=38, rank=6, next=10328, class="PALADIN" }, -- Holy Light
[21551] = { level=48, rank=2, next=21552, class="WARRIOR" }, -- Mortal Strike
[21552] = { level=54, rank=3, next=21553, class="WARRIOR" }, -- Mortal Strike
[21553] = { level=60, rank=4, next=25248, class="WARRIOR" }, -- Mortal Strike
[21562] = { level=48, rank=1, next=21564, class="PRIEST" }, -- Prayer of Fortitude
[21564] = { level=60, rank=2, next=25392, class="PRIEST" }, -- Prayer of Fortitude
[21849] = { level=50, rank=1, next=21850, class="DRUID" }, -- Gift of the Wild
[21850] = { level=60, rank=2, next=26991, class="DRUID" }, -- Gift of the Wild
[22568] = { level=32, rank=1, next=22827, class="DRUID" }, -- Ferocious Bite
[22570] = { level=62, rank=1, next=49802, class="DRUID" }, -- Maim
[22782] = { level=46, rank=2, next=22783, class="MAGE" }, -- Mage Armor
[22783] = { level=58, rank=3, next=27125, class="MAGE" }, -- Mage Armor
[22812] = { level=44, class="DRUID" }, -- Barkskin
[22827] = { level=40, rank=2, next=22828, class="DRUID" }, -- Ferocious Bite
[22828] = { level=48, rank=3, next=22829, class="DRUID" }, -- Ferocious Bite
[22829] = { level=56, rank=4, next=31018, class="DRUID" }, -- Ferocious Bite
[22842] = { level=36, rank=1, class="DRUID" }, -- Frenzied Regeneration
[23028] = { level=56, rank=1, next=27127, class="MAGE" }, -- Arcane Brilliance
[23920] = { level=64, class="WARRIOR" }, -- Spell Reflection
[23922] = { level=40, rank=1, next=23923, class="WARRIOR" }, -- Shield Slam
[23923] = { level=48, rank=2, next=23924, class="WARRIOR" }, -- Shield Slam
[23924] = { level=54, rank=3, next=23925, class="WARRIOR" }, -- Shield Slam
[23925] = { level=60, rank=4, next=25258, class="WARRIOR" }, -- Shield Slam
[24132] = { level=50, rank=2, next=24133, class="HUNTER" }, -- Wyvern Sting
[24133] = { level=60, rank=3, next=27068, class="HUNTER" }, -- Wyvern Sting
[24239] = { level=60, rank=3, next=27180, class="PALADIN" }, -- Hammer of Wrath
[24248] = { level=63, rank=6, next=48576, class="DRUID" }, -- Ferocious Bite
[24274] = { level=52, rank=2, next=24239, class="PALADIN" }, -- Hammer of Wrath
[24275] = { level=44, rank=1, next=24274, class="PALADIN" }, -- Hammer of Wrath
[24398] = { level=62, rank=7, next=33736, class="SHAMAN" }, -- Water Shield
[24974] = { level=30, rank=2, next=24975, class="DRUID" }, -- Insect Swarm
[24975] = { level=40, rank=3, next=24976, class="DRUID" }, -- Insect Swarm
[24976] = { level=50, rank=4, next=24977, class="DRUID" }, -- Insect Swarm
[24977] = { level=60, rank=5, next=27013, class="DRUID" }, -- Insect Swarm
[25202] = { level=62, rank=6, next=25203, class="WARRIOR" }, -- Demoralizing Shout
[25203] = { level=70, rank=7, next=47437, class="WARRIOR" }, -- Demoralizing Shout
[25208] = { level=68, rank=8, next=46845, class="WARRIOR" }, -- Rend
[25210] = { level=63, rank=6, next=25213, class="PRIEST" }, -- Greater Heal
[25213] = { level=68, rank=7, next=48062, class="PRIEST" }, -- Greater Heal
[25217] = { level=65, rank=11, next=25218, class="PRIEST" }, -- Power Word: Shield
[25218] = { level=70, rank=12, next=48065, class="PRIEST" }, -- Power Word: Shield
[25221] = { level=65, rank=11, next=25222, class="PRIEST" }, -- Renew
[25222] = { level=70, rank=12, next=48067, class="PRIEST" }, -- Renew
[25231] = { level=68, rank=6, next=47519, class="WARRIOR" }, -- Cleave
[25233] = { level=61, rank=8, next=25235, class="PRIEST" }, -- Flash Heal
[25234] = { level=65, rank=6, next=25236, class="WARRIOR" }, -- Execute
[25235] = { level=67, rank=9, next=48070, class="PRIEST" }, -- Flash Heal
[25236] = { level=70, rank=7, next=47470, class="WARRIOR" }, -- Execute
[25241] = { level=61, rank=5, next=25242, class="WARRIOR" }, -- Slam
[25242] = { level=69, rank=6, next=47474, class="WARRIOR" }, -- Slam
[25248] = { level=66, rank=5, next=30330, class="WARRIOR" }, -- Mortal Strike
[25258] = { level=66, rank=5, next=30356, class="WARRIOR" }, -- Shield Slam
[25264] = { level=67, rank=7, next=47501, class="WARRIOR" }, -- Thunder Clap
[25269] = { level=63, rank=7, next=30357, class="WARRIOR" }, -- Revenge
[25286] = { level=60, rank=9, next=29707, class="WARRIOR" }, -- Heroic Strike
[25288] = { level=60, rank=6, next=25269, class="WARRIOR" }, -- Revenge
[25289] = { level=60, rank=7, next=2048, class="WARRIOR" }, -- Battle Shout
[10328] = { level=46, rank=7, next=10329, class="PALADIN" }, -- Holy Light
[25291] = { level=60, rank=7, next=27140, class="PALADIN" }, -- Blessing of Might
[10329] = { level=54, rank=8, next=25292, class="PALADIN" }, -- Holy Light
[25294] = { level=60, rank=5, next=27021, class="HUNTER" }, -- Multi-Shot
[25295] = { level=60, rank=9, next=27016, class="HUNTER" }, -- Serpent Sting
[25296] = { level=60, rank=7, next=27044, class="HUNTER" }, -- Aspect of the Hawk
[25297] = { level=60, rank=11, next=26978, class="DRUID" }, -- Healing Touch
[25298] = { level=60, rank=7, next=26986, class="DRUID" }, -- Starfire
[25299] = { level=60, rank=11, next=26981, class="DRUID" }, -- Rejuvenation
[25300] = { level=60, rank=9, next=26863, class="ROGUE" }, -- Backstab
[25302] = { level=60, rank=5, next=27448, class="ROGUE" }, -- Feint
[25304] = { level=60, rank=11, next=27071, class="MAGE" }, -- Frostbolt
[25306] = { level=62, rank=12, next=27070, class="MAGE" }, -- Fireball
[25307] = { level=62, rank=10, next=27209, class="WARLOCK" }, -- Shadow Bolt
[25308] = { level=68, rank=6, next=48072, class="PRIEST" }, -- Prayer of Healing
[25309] = { level=60, rank=8, next=27215, class="WARLOCK" }, -- Immolate
[25311] = { level=60, rank=7, next=27216, class="WARLOCK" }, -- Corruption
[25312] = { level=70, rank=5, next=48073, class="PRIEST" }, -- Divine Spirit
[25314] = { level=60, rank=5, next=25210, class="PRIEST" }, -- Greater Heal
[25315] = { level=60, rank=10, next=25221, class="PRIEST" }, -- Renew
[25316] = { level=60, rank=5, next=25308, class="PRIEST" }, -- Prayer of Healing
[25331] = { level=68, rank=7, next=48077, class="PRIEST" }, -- Holy Nova
[25345] = { level=60, rank=8, next=27075, class="MAGE" }, -- Arcane Missiles
[25349] = { level=60, rank=5, next=26967, class="ROGUE" }, -- Deadly Poison V
[25351] = { level=60, rank=5, next=26968, class="ROGUE" }, -- Deadly Poison V
[25357] = { level=60, rank=10, next=25391, class="SHAMAN" }, -- Healing Wave
[25361] = { level=60, rank=5, next=25528, class="SHAMAN" }, -- Strength of Earth Totem
[25363] = { level=61, rank=9, next=25364, class="PRIEST" }, -- Smite
[25364] = { level=69, rank=10, next=48122, class="PRIEST" }, -- Smite
[25367] = { level=65, rank=9, next=25368, class="PRIEST" }, -- Shadow Word: Pain
[25368] = { level=70, rank=10, next=48124, class="PRIEST" }, -- Shadow Word: Pain
[25372] = { level=63, rank=10, next=25375, class="PRIEST" }, -- Mind Blast
[25375] = { level=69, rank=11, next=48126, class="PRIEST" }, -- Mind Blast
[25384] = { level=66, rank=9, next=48134, class="PRIEST" }, -- Holy Fire
[25387] = { level=68, rank=7, next=48155, class="PRIEST" }, -- Mind Flay
[25389] = { level=70, rank=7, next=48161, class="PRIEST" }, -- Power Word: Fortitude
[25391] = { level=63, rank=11, next=25396, class="SHAMAN" }, -- Healing Wave
[25392] = { level=70, rank=3, next=48162, class="PRIEST" }, -- Prayer of Fortitude
[25396] = { level=70, rank=12, next=49272, class="SHAMAN" }, -- Healing Wave
[25420] = { level=66, rank=7, next=49275, class="SHAMAN" }, -- Lesser Healing Wave
[25422] = { level=61, rank=4, next=25423, class="SHAMAN" }, -- Chain Heal
[25423] = { level=68, rank=5, next=55458, class="SHAMAN" }, -- Chain Heal
[25431] = { level=69, rank=7, next=48040, class="PRIEST" }, -- Inner Fire
[25433] = { level=68, rank=4, next=48169, class="PRIEST" }, -- Shadow Protection
[25435] = { level=68, rank=6, next=48171, class="PRIEST" }, -- Resurrection
[25437] = { level=66, rank=7, next=48172, class="PRIEST" }, -- Desperate Prayer
[25439] = { level=63, rank=5, next=25442, class="SHAMAN" }, -- Chain Lightning
[25442] = { level=70, rank=6, next=49270, class="SHAMAN" }, -- Chain Lightning
[25448] = { level=62, rank=11, next=25449, class="SHAMAN" }, -- Lightning Bolt
[25449] = { level=67, rank=12, next=49237, class="SHAMAN" }, -- Lightning Bolt
[25454] = { level=69, rank=8, next=49230, class="SHAMAN" }, -- Earth Shock
[25457] = { level=70, rank=7, next=49232, class="SHAMAN" }, -- Flame Shock
[25464] = { level=68, rank=5, next=49235, class="SHAMAN" }, -- Frost Shock
[25467] = { level=68, rank=7, next=48299, class="PRIEST" }, -- Devouring Plague
[25469] = { level=63, rank=8, next=25472, class="SHAMAN" }, -- Lightning Shield
[25472] = { level=70, rank=9, next=49280, class="SHAMAN" }, -- Lightning Shield
[25489] = { level=64, rank=7, next=58785, class="SHAMAN" }, -- Flametongue Weapon
[25500] = { level=66, rank=6, next=58794, class="SHAMAN" }, -- Frostbrand Weapon
[25505] = { level=68, rank=5, next=58801, class="SHAMAN" }, -- Windfury Weapon
[25508] = { level=63, rank=7, next=25509, class="SHAMAN" }, -- Stoneskin Totem
[25509] = { level=70, rank=8, next=58751, class="SHAMAN" }, -- Stoneskin Totem
[25525] = { level=67, rank=7, next=58580, class="SHAMAN" }, -- Stoneclaw Totem
[25528] = { level=65, rank=6, next=57622, class="SHAMAN" }, -- Strength of Earth Totem
[25533] = { level=69, rank=7, next=58699, class="SHAMAN" }, -- Searing Totem
[25546] = { level=61, rank=6, next=25547, class="SHAMAN" }, -- Fire Nova
[25547] = { level=70, rank=7, next=61649, class="SHAMAN" }, -- Fire Nova
[25552] = { level=65, rank=5, next=58731, class="SHAMAN" }, -- Magma Totem
[25557] = { level=67, rank=5, next=58649, class="SHAMAN" }, -- Flametongue Totem
[25560] = { level=67, rank=4, next=58741, class="SHAMAN" }, -- Frost Resistance Totem
[25563] = { level=68, rank=4, next=58737, class="SHAMAN" }, -- Fire Resistance Totem
[25567] = { level=69, rank=6, next=58755, class="SHAMAN" }, -- Healing Stream Totem
[25570] = { level=65, rank=5, next=58771, class="SHAMAN" }, -- Mana Spring Totem
[25574] = { level=69, rank=4, next=58746, class="SHAMAN" }, -- Nature Resistance Totem
[25590] = { level=69, rank=6, next=49277, class="SHAMAN" }, -- Ancestral Spirit
[25780] = { level=16, class="PALADIN" }, -- Righteous Fury
[25782] = { level=52, rank=1, next=25916, class="PALADIN" }, -- Greater Blessing of Might
[25292] = { level=60, rank=9, next=27135, class="PALADIN" }, -- Holy Light
[25898] = { level=60, class="PALADIN" }, -- Greater Blessing of Kings
[25899] = { level=60, class="PALADIN" }, -- Greater Blessing of Sanctuary
[25916] = { level=60, rank=2, next=27141, class="PALADIN" }, -- Greater Blessing of Might
[27135] = { level=62, rank=10, next=27136, class="PALADIN" }, -- Holy Light
[27136] = { level=70, rank=11, next=48781, class="PALADIN" }, -- Holy Light
[26669] = { level=50, rank=2, class="ROGUE" }, -- Evasion
[26679] = { level=64, rank=1, next=48673, class="ROGUE" }, -- Deadly Throw
[26688] = { level=68, rank=1, next=57981, class="ROGUE" }, -- Anesthetic Poison
[26785] = { level=68, rank=1, next=57982, class="ROGUE" }, -- Anesthetic Poison
[26839] = { level=61, rank=7, next=26884, class="ROGUE" }, -- Garrote
[26861] = { level=62, rank=9, next=26862, class="ROGUE" }, -- Sinister Strike
[26862] = { level=70, rank=10, next=48637, class="ROGUE" }, -- Sinister Strike
[26863] = { level=68, rank=10, next=48656, class="ROGUE" }, -- Backstab
[26864] = { level=70, rank=4, next=48660, class="ROGUE" }, -- Hemorrhage
[26865] = { level=64, rank=10, next=48667, class="ROGUE" }, -- Eviscerate
[26867] = { level=68, rank=7, next=48671, class="ROGUE" }, -- Rupture
[26884] = { level=70, rank=8, next=48675, class="ROGUE" }, -- Garrote
[26889] = { level=62, rank=3, class="ROGUE" }, -- Vanish
[26890] = { level=68, rank=7, next=57964, class="ROGUE" }, -- Instant Poison VII
[26891] = { level=68, rank=7, next=57967, class="ROGUE" }, -- Instant Poison VII
[26967] = { level=62, rank=6, next=27186, class="ROGUE" }, -- Deadly Poison VI
[26968] = { level=62, rank=6, next=27187, class="ROGUE" }, -- Deadly Poison VI
[26978] = { level=62, rank=12, next=26979, class="DRUID" }, -- Healing Touch
[26979] = { level=69, rank=13, next=48377, class="DRUID" }, -- Healing Touch
[26980] = { level=65, rank=10, next=48442, class="DRUID" }, -- Regrowth
[26981] = { level=63, rank=12, next=26982, class="DRUID" }, -- Rejuvenation
[26982] = { level=69, rank=13, next=48440, class="DRUID" }, -- Rejuvenation
[26983] = { level=70, rank=5, next=48446, class="DRUID" }, -- Tranquility
[26984] = { level=61, rank=9, next=26985, class="DRUID" }, -- Wrath
[26985] = { level=69, rank=10, next=48459, class="DRUID" }, -- Wrath
[26986] = { level=67, rank=8, next=48464, class="DRUID" }, -- Starfire
[26987] = { level=63, rank=11, next=26988, class="DRUID" }, -- Moonfire
[26988] = { level=70, rank=12, next=48462, class="DRUID" }, -- Moonfire
[26989] = { level=68, rank=7, next=53308, class="DRUID" }, -- Entangling Roots
[26990] = { level=70, rank=8, next=48469, class="DRUID" }, -- Mark of the Wild
[26991] = { level=70, rank=3, next=48470, class="DRUID" }, -- Gift of the Wild
[26992] = { level=64, rank=7, next=53307, class="DRUID" }, -- Thorns
[26994] = { level=69, rank=6, next=48477, class="DRUID" }, -- Rebirth
[26995] = { level=70, rank=4, class="DRUID" }, -- Soothe Animal
[26996] = { level=67, rank=8, next=48479, class="DRUID" }, -- Maul
[26997] = { level=64, rank=6, next=48561, class="DRUID" }, -- Swipe (Bear)
[26998] = { level=62, rank=6, next=48559, class="DRUID" }, -- Demoralizing Roar
[27000] = { level=67, rank=6, next=48569, class="DRUID" }, -- Claw
[27001] = { level=61, rank=6, next=27002, class="DRUID" }, -- Shred
[27002] = { level=70, rank=7, next=48571, class="DRUID" }, -- Shred
[27003] = { level=64, rank=5, next=48573, class="DRUID" }, -- Rake
[27004] = { level=69, rank=5, next=48575, class="DRUID" }, -- Cower
[27005] = { level=66, rank=5, next=48578, class="DRUID" }, -- Ravage
[27006] = { level=66, rank=4, next=49803, class="DRUID" }, -- Pounce
[27008] = { level=67, rank=7, next=49799, class="DRUID" }, -- Rip
[27009] = { level=68, rank=7, next=53312, class="DRUID" }, -- Nature's Grasp
[27012] = { level=70, rank=4, next=48467, class="DRUID" }, -- Hurricane
[27013] = { level=70, rank=6, next=48468, class="DRUID" }, -- Insect Swarm
[27014] = { level=63, rank=9, next=48995, class="HUNTER" }, -- Raptor Strike
[27016] = { level=67, rank=10, next=49000, class="HUNTER" }, -- Serpent Sting
[27019] = { level=69, rank=9, next=49044, class="HUNTER" }, -- Arcane Shot
[27021] = { level=67, rank=6, next=49047, class="HUNTER" }, -- Multi-Shot
[27022] = { level=67, rank=4, next=58431, class="HUNTER" }, -- Volley
[27023] = { level=65, rank=6, next=49055, class="HUNTER" }, -- Immolation Trap
[27025] = { level=61, rank=4, next=49066, class="HUNTER" }, -- Explosive Trap
[27044] = { level=68, rank=8, next=61846, class="HUNTER" }, -- Aspect of the Hawk
[27045] = { level=68, rank=3, next=49071, class="HUNTER" }, -- Aspect of the Wild
[27046] = { level=68, rank=8, next=48989, class="HUNTER" }, -- Mend Pet
[27065] = { level=70, rank=7, next=49049, class="HUNTER" }, -- Aimed Shot
[27067] = { level=66, rank=4, next=48998, class="HUNTER" }, -- Counterattack
[27068] = { level=70, rank=4, next=49011, class="HUNTER" }, -- Wyvern Sting
[27070] = { level=66, rank=13, next=38692, class="MAGE" }, -- Fireball
[27071] = { level=63, rank=12, next=27072, class="MAGE" }, -- Frostbolt
[27072] = { level=69, rank=13, next=38697, class="MAGE" }, -- Frostbolt
[27073] = { level=65, rank=8, next=27074, class="MAGE" }, -- Scorch
[27074] = { level=70, rank=9, next=42858, class="MAGE" }, -- Scorch
[27075] = { level=63, rank=9, next=38699, class="MAGE" }, -- Arcane Missiles
[27078] = { level=61, rank=8, next=27079, class="MAGE" }, -- Fire Blast
[27079] = { level=70, rank=9, next=42872, class="MAGE" }, -- Fire Blast
[27080] = { level=62, rank=7, next=27082, class="MAGE" }, -- Arcane Explosion
[27082] = { level=70, rank=8, next=42920, class="MAGE" }, -- Arcane Explosion
[27085] = { level=68, rank=7, next=42939, class="MAGE" }, -- Blizzard
[27086] = { level=64, rank=7, next=42925, class="MAGE" }, -- Flamestrike
[27087] = { level=65, rank=6, next=42930, class="MAGE" }, -- Cone of Cold
[27088] = { level=67, rank=5, next=42917, class="MAGE" }, -- Frost Nova
[27090] = { level=70, rank=9, next=42955, class="MAGE" }, -- Conjure Water
[27101] = { level=68, rank=5, next=42985, class="MAGE" }, -- Conjure Mana Gem
[27124] = { level=69, rank=5, next=43008, class="MAGE" }, -- Ice Armor
[27125] = { level=69, rank=4, next=43023, class="MAGE" }, -- Mage Armor
[27126] = { level=70, rank=6, next=42995, class="MAGE" }, -- Arcane Intellect
[27127] = { level=70, rank=2, next=43002, class="MAGE" }, -- Arcane Brilliance
[27128] = { level=69, rank=6, next=43010, class="MAGE" }, -- Fire Ward
[27130] = { level=63, rank=5, next=33946, class="MAGE" }, -- Amplify Magic
[27131] = { level=68, rank=7, next=43019, class="MAGE" }, -- Mana Shield
[27132] = { level=66, rank=9, next=33938, class="MAGE" }, -- Pyroblast
[27133] = { level=65, rank=6, next=33933, class="MAGE" }, -- Blast Wave
[27134] = { level=64, rank=5, next=33405, class="MAGE" }, -- Ice Barrier
[48781] = { level=75, rank=12, next=48782, class="PALADIN" }, -- Holy Light
[48782] = { level=80, rank=13, class="PALADIN" }, -- Holy Light
[20925] = { level=40, rank=1, next=20927, class="PALADIN" }, -- Holy Shield
[20473] = { level=40, rank=1, next=20929, class="PALADIN" }, -- Holy Shock
[20929] = { level=48, rank=2, next=20930, class="PALADIN" }, -- Holy Shock
[27140] = { level=70, rank=8, next=48931, class="PALADIN" }, -- Blessing of Might
[27141] = { level=70, rank=3, next=48933, class="PALADIN" }, -- Greater Blessing of Might
[20930] = { level=56, rank=3, next=27174, class="PALADIN" }, -- Holy Shock
[27174] = { level=64, rank=4, next=33072, class="PALADIN" }, -- Holy Shock
[27149] = { level=70, rank=8, next=48941, class="PALADIN" }, -- Devotion Aura
[27150] = { level=66, rank=6, next=54043, class="PALADIN" }, -- Retribution Aura
[27151] = { level=63, rank=4, next=48943, class="PALADIN" }, -- Shadow Resistance Aura
[27152] = { level=68, rank=4, next=48945, class="PALADIN" }, -- Frost Resistance Aura
[27153] = { level=70, rank=4, next=48947, class="PALADIN" }, -- Fire Resistance Aura
[33072] = { level=70, rank=5, next=48824, class="PALADIN" }, -- Holy Shock
[48824] = { level=75, rank=6, next=48825, class="PALADIN" }, -- Holy Shock
[48825] = { level=80, rank=7, class="PALADIN" }, -- Holy Shock
[27179] = { level=70, rank=4, next=48951, class="PALADIN" }, -- Holy Shield
[27180] = { level=68, rank=4, next=48805, class="PALADIN" }, -- Hammer of Wrath
[27186] = { level=70, rank=7, next=57969, class="ROGUE" }, -- Deadly Poison VII
[27187] = { level=70, rank=7, next=57972, class="ROGUE" }, -- Deadly Poison VII
[27188] = { level=64, rank=5, next=57974, class="ROGUE" }, -- Wound Poison V
[27189] = { level=64, rank=5, next=57977, class="ROGUE" }, -- Wound Poison V
[27209] = { level=69, rank=11, next=47808, class="WARLOCK" }, -- Shadow Bolt
[27210] = { level=65, rank=7, next=30459, class="WARLOCK" }, -- Searing Pain
[27211] = { level=64, rank=3, next=30545, class="WARLOCK" }, -- Soul Fire
[27212] = { level=69, rank=5, next=47819, class="WARLOCK" }, -- Rain of Fire
[27213] = { level=68, rank=4, next=47823, class="WARLOCK" }, -- Hellfire
[27215] = { level=69, rank=9, next=47810, class="WARLOCK" }, -- Immolate
[27216] = { level=65, rank=8, next=47812, class="WARLOCK" }, -- Corruption
[27217] = { level=67, rank=5, next=47855, class="WARLOCK" }, -- Drain Soul
[27218] = { level=67, rank=7, next=47863, class="WARLOCK" }, -- Curse of Agony
[27219] = { level=62, rank=7, next=27220, class="WARLOCK" }, -- Drain Life
[27220] = { level=69, rank=8, next=47857, class="WARLOCK" }, -- Drain Life
[27222] = { level=68, rank=7, next=57946, class="WARLOCK" }, -- Life Tap
[27223] = { level=68, rank=4, next=47859, class="WARLOCK" }, -- Death Coil
[27224] = { level=61, rank=7, next=30909, class="WARLOCK" }, -- Curse of Weakness
[27228] = { level=69, rank=4, next=47865, class="WARLOCK" }, -- Curse of the Elements
[27230] = { level=68, rank=6, next=47871, class="WARLOCK" }, -- Create Healthstone
[27238] = { level=70, rank=6, next=47884, class="WARLOCK" }, -- Create Soulstone
[27243] = { level=70, rank=1, next=47835, class="WARLOCK" }, -- Seed of Corruption
[27250] = { level=66, rank=5, next=60219, class="WARLOCK" }, -- Create Firestone
[27259] = { level=67, rank=8, next=47856, class="WARLOCK" }, -- Health Funnel
[27260] = { level=70, rank=6, next=47793, class="WARLOCK" }, -- Demon Armor
[27263] = { level=63, rank=7, next=30546, class="WARLOCK" }, -- Shadowburn
[27265] = { level=70, rank=4, next=59092, class="WARLOCK" }, -- Dark Pact
[27441] = { level=66, rank=7, next=48689, class="ROGUE" }, -- Ambush
[27448] = { level=64, rank=6, next=48658, class="ROGUE" }, -- Feint
[27681] = { level=60, rank=1, next=32999, class="PRIEST" }, -- Prayer of Spirit
[27683] = { level=56, rank=1, next=39374, class="PRIEST" }, -- Prayer of Shadow Protection
[27799] = { level=44, rank=4, next=27800, class="PRIEST" }, -- Holy Nova
[27800] = { level=52, rank=5, next=27801, class="PRIEST" }, -- Holy Nova
[27801] = { level=60, rank=6, next=25331, class="PRIEST" }, -- Holy Nova
[27841] = { level=60, rank=4, next=25312, class="PRIEST" }, -- Divine Spirit
[27870] = { level=50, rank=2, next=27871, class="PRIEST" }, -- Lightwell
[27871] = { level=60, rank=3, next=28275, class="PRIEST" }, -- Lightwell
[28172] = { level=66, rank=4, next=47886, class="WARLOCK" }, -- Create Spellstone
[28176] = { level=62, rank=1, next=28189, class="WARLOCK" }, -- Fel Armor
[28189] = { level=69, rank=2, next=47892, class="WARLOCK" }, -- Fel Armor
[28271] = { level=60, class="MAGE" }, -- Polymorph: Turtle
[28272] = { level=60, class="MAGE" }, -- Polymorph: Pig
[28275] = { level=70, rank=4, next=48086, class="PRIEST" }, -- Lightwell
[28609] = { level=60, rank=5, next=32796, class="MAGE" }, -- Frost Ward
[28610] = { level=60, rank=4, next=47890, class="WARLOCK" }, -- Shadow Ward
[28612] = { level=60, rank=7, next=33717, class="MAGE" }, -- Conjure Food
[29166] = { level=40, class="DRUID" }, -- Innervate
[29228] = { level=60, rank=6, next=25457, class="SHAMAN" }, -- Flame Shock
[29707] = { level=66, rank=10, next=30324, class="WARRIOR" }, -- Heroic Strike
[29722] = { level=64, rank=1, next=32231, class="WARLOCK" }, -- Incinerate
[29858] = { level=66, class="WARLOCK" }, -- Soulshatter
[29893] = { level=68, rank=1, next=58887, class="WARLOCK" }, -- Ritual of Souls
[30016] = { level=60, rank=2, next=30022, class="WARRIOR" }, -- Devastate
[30022] = { level=70, rank=3, next=47497, class="WARRIOR" }, -- Devastate
[30108] = { level=50, rank=1, next=30404, class="WARLOCK" }, -- Unstable Affliction
[30283] = { level=50, rank=1, next=30413, class="WARLOCK" }, -- Shadowfury
[30324] = { level=70, rank=11, next=47449, class="WARRIOR" }, -- Heroic Strike
[30330] = { level=70, rank=6, next=47485, class="WARRIOR" }, -- Mortal Strike
[30356] = { level=70, rank=6, next=47487, class="WARRIOR" }, -- Shield Slam
[30357] = { level=70, rank=8, next=57823, class="WARRIOR" }, -- Revenge
[30404] = { level=60, rank=2, next=30405, class="WARLOCK" }, -- Unstable Affliction
[30405] = { level=70, rank=3, next=47841, class="WARLOCK" }, -- Unstable Affliction
[30413] = { level=60, rank=2, next=30414, class="WARLOCK" }, -- Shadowfury
[30414] = { level=70, rank=3, next=47846, class="WARLOCK" }, -- Shadowfury
[30449] = { level=70, class="MAGE" }, -- Spellsteal
[30451] = { level=64, rank=1, next=42894, class="MAGE" }, -- Arcane Blast
[30455] = { level=66, rank=1, next=42913, class="MAGE" }, -- Ice Lance
[30459] = { level=70, rank=8, next=47814, class="WARLOCK" }, -- Searing Pain
[30482] = { level=62, rank=1, next=43045, class="MAGE" }, -- Molten Armor
[30545] = { level=70, rank=4, next=47824, class="WARLOCK" }, -- Soul Fire
[30546] = { level=70, rank=8, next=47826, class="WARLOCK" }, -- Shadowburn
[30706] = { level=50, rank=1, next=57720, class="SHAMAN" }, -- Totem of Wrath
[30909] = { level=69, rank=8, next=50511, class="WARLOCK" }, -- Curse of Weakness
[30910] = { level=70, rank=2, next=47867, class="WARLOCK" }, -- Curse of Doom
[31016] = { level=60, rank=9, next=26865, class="ROGUE" }, -- Eviscerate
[31018] = { level=60, rank=5, next=24248, class="DRUID" }, -- Ferocious Bite
[31224] = { level=66, class="ROGUE" }, -- Cloak of Shadows
[31661] = { level=50, rank=1, next=33041, class="MAGE" }, -- Dragon's Breath
[31709] = { level=60, rank=4, next=27004, class="DRUID" }, -- Cower
[31789] = { level=14, class="PALADIN" }, -- Righteous Defense
[31801] = { level=64, class="PALADIN", faction="Alliance" }, -- Seal of Vengeance
[31884] = { level=70, class="PALADIN" }, -- Avenging Wrath
[2812] = { level=50, rank=1, next=10318, class="PALADIN" }, -- Holy Wrath
[32182] = { level=70, class="SHAMAN", faction="Alliance" }, -- Heroism
[32223] = { level=62, class="PALADIN" }, -- Crusader Aura
[32231] = { level=70, rank=2, next=47837, class="WARLOCK" }, -- Incinerate
[32266] = { level=40, class="MAGE", faction="Alliance" }, -- Portal: Exodar
[32267] = { level=40, class="MAGE", faction="Horde" }, -- Portal: Silvermoon
[32271] = { level=20, class="MAGE", faction="Alliance" }, -- Teleport: Exodar
[32272] = { level=20, class="MAGE", faction="Horde" }, -- Teleport: Silvermoon
[32375] = { level=70, class="PRIEST" }, -- Mass Dispel
[32379] = { level=62, rank=1, next=32996, class="PRIEST" }, -- Shadow Word: Death
[32546] = { level=64, rank=1, next=48119, class="PRIEST" }, -- Binding Heal
[32593] = { level=60, rank=2, next=32594, class="SHAMAN" }, -- Earth Shield
[32594] = { level=70, rank=3, next=49283, class="SHAMAN" }, -- Earth Shield
[32645] = { level=62, rank=1, next=32684, class="ROGUE" }, -- Envenom
[32684] = { level=69, rank=2, next=57992, class="ROGUE" }, -- Envenom
[32699] = { level=60, rank=2, next=32700, class="PALADIN" }, -- Avenger's Shield
[32700] = { level=70, rank=3, next=48826, class="PALADIN" }, -- Avenger's Shield
[32796] = { level=70, rank=6, next=43012, class="MAGE" }, -- Frost Ward
[32996] = { level=70, rank=2, next=48157, class="PRIEST" }, -- Shadow Word: Death
[32999] = { level=70, rank=2, next=48074, class="PRIEST" }, -- Prayer of Spirit
[33041] = { level=56, rank=2, next=33042, class="MAGE" }, -- Dragon's Breath
[33042] = { level=64, rank=3, next=33043, class="MAGE" }, -- Dragon's Breath
[33043] = { level=70, rank=4, next=42949, class="MAGE" }, -- Dragon's Breath
[10318] = { level=60, rank=2, next=27139, class="PALADIN" }, -- Holy Wrath
[33076] = { level=68, rank=1, next=48112, class="PRIEST" }, -- Prayer of Mending
[33357] = { level=65, rank=3, class="DRUID" }, -- Dash
[33405] = { level=70, rank=6, next=43038, class="MAGE" }, -- Ice Barrier
[33690] = { level=60, class="MAGE", faction="Alliance" }, -- Teleport: Shattrath
[33691] = { level=65, class="MAGE", faction="Alliance" }, -- Portal: Shattrath
[33717] = { level=70, rank=8, next=42955, class="MAGE" }, -- Conjure Food
[33736] = { level=69, rank=8, next=57960, class="SHAMAN" }, -- Water Shield
[33745] = { level=66, rank=1, next=48567, class="DRUID" }, -- Lacerate
[33763] = { level=64, rank=1, next=48450, class="DRUID" }, -- Lifebloom
[33786] = { level=70, class="DRUID" }, -- Cyclone
[33876] = { level=50, rank=1, next=33982, class="DRUID" }, -- Mangle (Cat)
[33878] = { level=50, rank=1, next=33986, class="DRUID" }, -- Mangle (Bear)
[33891] = { level=50, class="DRUID" }, -- Tree of Life
[33933] = { level=70, rank=7, next=42944, class="MAGE" }, -- Blast Wave
[33938] = { level=70, rank=10, next=42890, class="MAGE" }, -- Pyroblast
[33943] = { level=60, class="DRUID" }, -- Flight Form
[33944] = { level=67, rank=6, next=43015, class="MAGE" }, -- Dampen Magic
[33946] = { level=69, rank=6, next=43017, class="MAGE" }, -- Amplify Magic
[33982] = { level=58, rank=2, next=33983, class="DRUID" }, -- Mangle (Cat)
[33983] = { level=68, rank=3, next=48565, class="DRUID" }, -- Mangle (Cat)
[33986] = { level=58, rank=2, next=33987, class="DRUID" }, -- Mangle (Bear)
[33987] = { level=68, rank=3, next=48563, class="DRUID" }, -- Mangle (Bear)
[34026] = { level=66, class="HUNTER" }, -- Kill Command
[34074] = { level=20, class="HUNTER" }, -- Aspect of the Viper
[34120] = { level=62, rank=2, next=49051, class="HUNTER" }, -- Steady Shot
[34411] = { level=50, rank=2, next=34412, class="ROGUE" }, -- Mutilate
[34412] = { level=60, rank=3, next=34413, class="ROGUE" }, -- Mutilate
[34413] = { level=70, rank=4, next=48663, class="ROGUE" }, -- Mutilate
[34428] = { level=6, class="WARRIOR" }, -- Victory Rush
[34433] = { level=66, class="PRIEST" }, -- Shadowfiend
[34477] = { level=70, class="HUNTER" }, -- Misdirection
[34600] = { level=68, class="HUNTER" }, -- Snake Trap
[34861] = { level=50, rank=1, next=34863, class="PRIEST" }, -- Circle of Healing
[34863] = { level=56, rank=2, next=34864, class="PRIEST" }, -- Circle of Healing
[34864] = { level=60, rank=3, next=34865, class="PRIEST" }, -- Circle of Healing
[34865] = { level=65, rank=4, next=34866, class="PRIEST" }, -- Circle of Healing
[34866] = { level=70, rank=5, next=48088, class="PRIEST" }, -- Circle of Healing
[34914] = { level=50, rank=1, next=34916, class="PRIEST" }, -- Vampiric Touch
[34916] = { level=60, rank=2, next=34917, class="PRIEST" }, -- Vampiric Touch
[34917] = { level=70, rank=3, next=48159, class="PRIEST" }, -- Vampiric Touch
[35715] = { level=60, class="MAGE", faction="Horde" }, -- Teleport: Shattrath
[35717] = { level=65, class="MAGE", faction="Horde" }, -- Portal: Shattrath
[36916] = { level=70, rank=5, next=53339, class="HUNTER" }, -- Mongoose Bite
[36936] = { level=30, class="SHAMAN" }, -- Totemic Recall
[37420] = { level=65, rank=8, next=27090, class="MAGE" }, -- Conjure Water
[38692] = { level=70, rank=14, next=42832, class="MAGE" }, -- Fireball
[38697] = { level=70, rank=14, next=42841, class="MAGE" }, -- Frostbolt
[38699] = { level=69, rank=10, next=38704, class="MAGE" }, -- Arcane Missiles
[38704] = { level=70, rank=11, next=42843, class="MAGE" }, -- Arcane Missiles
[39374] = { level=70, rank=2, next=48170, class="PRIEST" }, -- Prayer of Shadow Protection
[40120] = { level=71, class="DRUID" }, -- Swift Flight Form
[42650] = { level=80, class="DEATHKNIGHT" }, -- Army of the Dead
[42832] = { level=74, rank=15, next=42833, class="MAGE" }, -- Fireball
[42833] = { level=78, rank=16, class="MAGE" }, -- Fireball
[42841] = { level=75, rank=15, next=42842, class="MAGE" }, -- Frostbolt
[42842] = { level=79, rank=16, class="MAGE" }, -- Frostbolt
[42843] = { level=75, rank=12, next=42846, class="MAGE" }, -- Arcane Missiles
[42846] = { level=79, rank=13, class="MAGE" }, -- Arcane Missiles
[42858] = { level=73, rank=10, next=42859, class="MAGE" }, -- Scorch
[42859] = { level=78, rank=11, class="MAGE" }, -- Scorch
[42872] = { level=74, rank=10, next=42873, class="MAGE" }, -- Fire Blast
[42873] = { level=80, rank=11, class="MAGE" }, -- Fire Blast
[42890] = { level=73, rank=11, next=42891, class="MAGE" }, -- Pyroblast
[42891] = { level=77, rank=12, class="MAGE" }, -- Pyroblast
[42894] = { level=71, rank=2, next=42896, class="MAGE" }, -- Arcane Blast
[42896] = { level=76, rank=3, next=42897, class="MAGE" }, -- Arcane Blast
[42897] = { level=80, rank=4, class="MAGE" }, -- Arcane Blast
[42913] = { level=72, rank=2, next=42914, class="MAGE" }, -- Ice Lance
[42914] = { level=78, rank=3, class="MAGE" }, -- Ice Lance
[42917] = { level=75, rank=6, class="MAGE" }, -- Frost Nova
[42920] = { level=76, rank=9, next=42921, class="MAGE" }, -- Arcane Explosion
[42921] = { level=80, rank=10, class="MAGE" }, -- Arcane Explosion
[42925] = { level=72, rank=8, next=42926, class="MAGE" }, -- Flamestrike
[42926] = { level=79, rank=9, class="MAGE" }, -- Flamestrike
[42930] = { level=72, rank=7, next=42931, class="MAGE" }, -- Cone of Cold
[42931] = { level=79, rank=8, class="MAGE" }, -- Cone of Cold
[42939] = { level=74, rank=8, next=42940, class="MAGE" }, -- Blizzard
[42940] = { level=80, rank=9, class="MAGE" }, -- Blizzard
[42944] = { level=75, rank=8, next=42945, class="MAGE" }, -- Blast Wave
[42945] = { level=80, rank=9, class="MAGE" }, -- Blast Wave
[42949] = { level=75, rank=5, next=42950, class="MAGE" }, -- Dragon's Breath
[42950] = { level=80, rank=6, class="MAGE" }, -- Dragon's Breath
[42955] = { level=75, rank=1, next=42956, class="MAGE" }, -- Conjure Refreshment
[42956] = { level=80, rank=2, class="MAGE" }, -- Conjure Refreshment
[42985] = { level=77, rank=6, class="MAGE" }, -- Conjure Mana Gem
[42995] = { level=80, rank=7, class="MAGE" }, -- Arcane Intellect
[43002] = { level=80, rank=3, class="MAGE" }, -- Arcane Brilliance
[43008] = { level=79, rank=6, class="MAGE" }, -- Ice Armor
[43010] = { level=78, rank=7, class="MAGE" }, -- Fire Ward
[43012] = { level=79, rank=7, class="MAGE" }, -- Frost Ward
[43015] = { level=76, rank=7, class="MAGE" }, -- Dampen Magic
[43017] = { level=77, rank=7, class="MAGE" }, -- Amplify Magic
[43019] = { level=73, rank=8, next=43020, class="MAGE" }, -- Mana Shield
[43020] = { level=79, rank=9, class="MAGE" }, -- Mana Shield
[43023] = { level=71, rank=5, next=43024, class="MAGE" }, -- Mage Armor
[43024] = { level=79, rank=6, class="MAGE" }, -- Mage Armor
[43038] = { level=75, rank=7, next=43039, class="MAGE" }, -- Ice Barrier
[43039] = { level=80, rank=8, class="MAGE" }, -- Ice Barrier
[43045] = { level=71, rank=2, next=43046, class="MAGE" }, -- Molten Armor
[43046] = { level=79, rank=3, class="MAGE" }, -- Molten Armor
[43265] = { level=60, rank=1, next=49936, class="DEATHKNIGHT" }, -- Death and Decay
[43987] = { level=70, rank=1, next=58659, class="MAGE" }, -- Ritual of Refreshment
[44425] = { level=60, rank=1, next=44780, class="MAGE" }, -- Arcane Barrage
[44457] = { level=60, rank=1, next=55359, class="MAGE" }, -- Living Bomb
[44614] = { level=75, rank=1, next=47610, class="MAGE" }, -- Frostfire Bolt
[44780] = { level=70, rank=2, next=44781, class="MAGE" }, -- Arcane Barrage
[44781] = { level=80, rank=3, class="MAGE" }, -- Arcane Barrage
[45438] = { level=30, class="MAGE" }, -- Ice Block
[45462] = { level=55, rank=1, next=49917, class="DEATHKNIGHT" }, -- Plague Strike
[45463] = { level=70, rank=3, next=49923, class="DEATHKNIGHT" }, -- Death Strike
[45477] = { level=55, rank=1, next=49896, class="DEATHKNIGHT" }, -- Icy Touch
[45524] = { level=58, class="DEATHKNIGHT" }, -- Chains of Ice
[45529] = { level=64, class="DEATHKNIGHT" }, -- Blood Tap
[45902] = { level=55, rank=1, next=49926, class="DEATHKNIGHT" }, -- Blood Strike
[46584] = { level=56, class="DEATHKNIGHT" }, -- Raise Dead
[46845] = { level=71, rank=9, next=47465, class="WARRIOR" }, -- Rend
[47436] = { level=78, rank=9, class="WARRIOR" }, -- Battle Shout
[47437] = { level=79, rank=8, class="WARRIOR" }, -- Demoralizing Shout
[47439] = { level=74, rank=2, next=47440, class="WARRIOR" }, -- Commanding Shout
[47440] = { level=80, rank=3, class="WARRIOR" }, -- Commanding Shout
[47449] = { level=72, rank=12, next=47450, class="WARRIOR" }, -- Heroic Strike
[47450] = { level=76, rank=13, class="WARRIOR" }, -- Heroic Strike
[47465] = { level=76, rank=10, class="WARRIOR" }, -- Rend
[47470] = { level=73, rank=8, next=47471, class="WARRIOR" }, -- Execute
[47471] = { level=80, rank=9, class="WARRIOR" }, -- Execute
[47474] = { level=74, rank=7, next=47475, class="WARRIOR" }, -- Slam
[47475] = { level=79, rank=8, class="WARRIOR" }, -- Slam
[47476] = { level=59, class="DEATHKNIGHT" }, -- Strangulate
[47485] = { level=75, rank=7, next=47486, class="WARRIOR" }, -- Mortal Strike
[47486] = { level=80, rank=8, class="WARRIOR" }, -- Mortal Strike
[47487] = { level=75, rank=7, next=47488, class="WARRIOR" }, -- Shield Slam
[47488] = { level=80, rank=8, class="WARRIOR" }, -- Shield Slam
[47497] = { level=75, rank=4, next=47498, class="WARRIOR" }, -- Devastate
[47498] = { level=80, rank=5, class="WARRIOR" }, -- Devastate
[47501] = { level=73, rank=8, next=47502, class="WARRIOR" }, -- Thunder Clap
[47502] = { level=78, rank=9, class="WARRIOR" }, -- Thunder Clap
[47519] = { level=72, rank=7, next=47520, class="WARRIOR" }, -- Cleave
[47520] = { level=77, rank=8, class="WARRIOR" }, -- Cleave
[47528] = { level=57, class="DEATHKNIGHT" }, -- Mind Freeze
[47540] = { level=60, rank=1, next=53005, class="PRIEST" }, -- Penance
[47541] = { level=55, rank=1, next=49892, class="DEATHKNIGHT" }, -- Death Coil
[47568] = { level=75, class="DEATHKNIGHT" }, -- Empower Rune Weapon
[47610] = { level=80, rank=2, class="MAGE" }, -- Frostfire Bolt
[47793] = { level=76, rank=7, next=47889, class="WARLOCK" }, -- Demon Armor
[47808] = { level=74, rank=12, next=47809, class="WARLOCK" }, -- Shadow Bolt
[47809] = { level=79, rank=13, class="WARLOCK" }, -- Shadow Bolt
[47810] = { level=75, rank=10, next=47811, class="WARLOCK" }, -- Immolate
[47811] = { level=80, rank=11, class="WARLOCK" }, -- Immolate
[47812] = { level=71, rank=9, next=47813, class="WARLOCK" }, -- Corruption
[47813] = { level=77, rank=10, class="WARLOCK" }, -- Corruption
[47814] = { level=74, rank=9, next=47815, class="WARLOCK" }, -- Searing Pain
[47815] = { level=79, rank=10, class="WARLOCK" }, -- Searing Pain
[47819] = { level=72, rank=6, next=47820, class="WARLOCK" }, -- Rain of Fire
[47820] = { level=79, rank=7, class="WARLOCK" }, -- Rain of Fire
[47823] = { level=78, rank=5, class="WARLOCK" }, -- Hellfire
[47824] = { level=75, rank=5, next=47825, class="WARLOCK" }, -- Soul Fire
[47825] = { level=80, rank=6, class="WARLOCK" }, -- Soul Fire
[47826] = { level=75, rank=9, next=47827, class="WARLOCK" }, -- Shadowburn
[47827] = { level=80, rank=10, class="WARLOCK" }, -- Shadowburn
[47835] = { level=75, rank=2, next=47836, class="WARLOCK" }, -- Seed of Corruption
[47836] = { level=80, rank=3, class="WARLOCK" }, -- Seed of Corruption
[47837] = { level=74, rank=3, next=47838, class="WARLOCK" }, -- Incinerate
[47838] = { level=80, rank=4, class="WARLOCK" }, -- Incinerate
[47841] = { level=75, rank=4, next=47843, class="WARLOCK" }, -- Unstable Affliction
[47843] = { level=80, rank=5, class="WARLOCK" }, -- Unstable Affliction
[47846] = { level=75, rank=4, next=47847, class="WARLOCK" }, -- Shadowfury
[47847] = { level=80, rank=5, class="WARLOCK" }, -- Shadowfury
[47855] = { level=77, rank=6, class="WARLOCK" }, -- Drain Soul
[47856] = { level=76, rank=9, class="WARLOCK" }, -- Health Funnel
[47857] = { level=78, rank=9, class="WARLOCK" }, -- Drain Life
[47859] = { level=73, rank=5, next=47860, class="WARLOCK" }, -- Death Coil
[47860] = { level=78, rank=6, class="WARLOCK" }, -- Death Coil
[47863] = { level=73, rank=8, next=47864, class="WARLOCK" }, -- Curse of Agony
[47864] = { level=79, rank=9, class="WARLOCK" }, -- Curse of Agony
[47865] = { level=78, rank=5, class="WARLOCK" }, -- Curse of the Elements
[47867] = { level=80, rank=3, class="WARLOCK" }, -- Curse of Doom
[47871] = { level=73, rank=7, next=47878, class="WARLOCK" }, -- Create Healthstone
[47878] = { level=79, rank=8, class="WARLOCK" }, -- Create Healthstone
[47884] = { level=76, rank=7, class="WARLOCK" }, -- Create Soulstone
[47886] = { level=72, rank=5, next=47888, class="WARLOCK" }, -- Create Spellstone
[47888] = { level=78, rank=6, class="WARLOCK" }, -- Create Spellstone
[47889] = { level=80, rank=8, class="WARLOCK" }, -- Demon Armor
[47890] = { level=72, rank=5, next=47891, class="WARLOCK" }, -- Shadow Ward
[47891] = { level=78, rank=6, class="WARLOCK" }, -- Shadow Ward
[47892] = { level=74, rank=3, next=47893, class="WARLOCK" }, -- Fel Armor
[47893] = { level=79, rank=4, class="WARLOCK" }, -- Fel Armor
[47897] = { level=75, rank=1, next=61290, class="WARLOCK" }, -- Shadowflame
[48018] = { level=80, class="WARLOCK" }, -- Demonic Circle: Summon
[48020] = { level=80, class="WARLOCK" }, -- Demonic Circle: Teleport
[48040] = { level=71, rank=8, next=48168, class="PRIEST" }, -- Inner Fire
[48045] = { level=75, rank=1, next=53023, class="PRIEST" }, -- Mind Sear
[48062] = { level=73, rank=8, next=48063, class="PRIEST" }, -- Greater Heal
[48063] = { level=78, rank=9, class="PRIEST" }, -- Greater Heal
[48065] = { level=75, rank=13, next=48066, class="PRIEST" }, -- Power Word: Shield
[48066] = { level=80, rank=14, class="PRIEST" }, -- Power Word: Shield
[48067] = { level=75, rank=13, next=48068, class="PRIEST" }, -- Renew
[48068] = { level=80, rank=14, class="PRIEST" }, -- Renew
[48070] = { level=73, rank=10, next=48071, class="PRIEST" }, -- Flash Heal
[48071] = { level=79, rank=11, class="PRIEST" }, -- Flash Heal
[48072] = { level=76, rank=7, class="PRIEST" }, -- Prayer of Healing
[48073] = { level=80, rank=6, class="PRIEST" }, -- Divine Spirit
[48074] = { level=80, rank=3, class="PRIEST" }, -- Prayer of Spirit
[48077] = { level=75, rank=8, next=48078, class="PRIEST" }, -- Holy Nova
[48078] = { level=80, rank=9, class="PRIEST" }, -- Holy Nova
[48086] = { level=75, rank=5, next=48087, class="PRIEST" }, -- Lightwell
[48087] = { level=80, rank=6, class="PRIEST" }, -- Lightwell
[48088] = { level=75, rank=6, next=48089, class="PRIEST" }, -- Circle of Healing
[48089] = { level=80, rank=7, class="PRIEST" }, -- Circle of Healing
[48112] = { level=74, rank=2, next=48113, class="PRIEST" }, -- Prayer of Mending
[48113] = { level=79, rank=3, class="PRIEST" }, -- Prayer of Mending
[48119] = { level=72, rank=2, next=48120, class="PRIEST" }, -- Binding Heal
[48120] = { level=78, rank=3, class="PRIEST" }, -- Binding Heal
[48122] = { level=74, rank=11, next=48123, class="PRIEST" }, -- Smite
[48123] = { level=79, rank=12, class="PRIEST" }, -- Smite
[48124] = { level=75, rank=11, next=48125, class="PRIEST" }, -- Shadow Word: Pain
[48125] = { level=80, rank=12, class="PRIEST" }, -- Shadow Word: Pain
[48126] = { level=74, rank=12, next=48127, class="PRIEST" }, -- Mind Blast
[48127] = { level=79, rank=13, class="PRIEST" }, -- Mind Blast
[48134] = { level=72, rank=10, next=48135, class="PRIEST" }, -- Holy Fire
[48135] = { level=78, rank=11, class="PRIEST" }, -- Holy Fire
[48155] = { level=74, rank=8, next=48156, class="PRIEST" }, -- Mind Flay
[48156] = { level=80, rank=9, class="PRIEST" }, -- Mind Flay
[48157] = { level=75, rank=3, next=48158, class="PRIEST" }, -- Shadow Word: Death
[48158] = { level=80, rank=4, class="PRIEST" }, -- Shadow Word: Death
[48159] = { level=75, rank=4, next=48160, class="PRIEST" }, -- Vampiric Touch
[48160] = { level=80, rank=5, class="PRIEST" }, -- Vampiric Touch
[48161] = { level=80, rank=8, class="PRIEST" }, -- Power Word: Fortitude
[48162] = { level=80, rank=4, class="PRIEST" }, -- Prayer of Fortitude
[48168] = { level=77, rank=9, class="PRIEST" }, -- Inner Fire
[48169] = { level=76, rank=5, class="PRIEST" }, -- Shadow Protection
[48170] = { level=77, rank=3, class="PRIEST" }, -- Prayer of Shadow Protection
[48171] = { level=78, rank=7, class="PRIEST" }, -- Resurrection
[48172] = { level=73, rank=8, next=48173, class="PRIEST" }, -- Desperate Prayer
[48173] = { level=80, rank=9, class="PRIEST" }, -- Desperate Prayer
[48181] = { level=60, rank=1, next=59161, class="WARLOCK" }, -- Haunt
[48263] = { level=57, class="DEATHKNIGHT" }, -- Frost Presence
[48265] = { level=70, class="DEATHKNIGHT" }, -- Unholy Presence
[48299] = { level=73, rank=8, next=48300, class="PRIEST" }, -- Devouring Plague
[48300] = { level=79, rank=9, class="PRIEST" }, -- Devouring Plague
[48377] = { level=74, rank=14, next=48378, class="DRUID" }, -- Healing Touch
[48378] = { level=79, rank=15, class="DRUID" }, -- Healing Touch
[48438] = { level=60, rank=1, next=53248, class="DRUID" }, -- Wild Growth
[48440] = { level=75, rank=14, next=48441, class="DRUID" }, -- Rejuvenation
[48441] = { level=80, rank=15, class="DRUID" }, -- Rejuvenation
[48442] = { level=71, rank=11, next=48443, class="DRUID" }, -- Regrowth
[48443] = { level=77, rank=12, class="DRUID" }, -- Regrowth
[48446] = { level=75, rank=6, next=48447, class="DRUID" }, -- Tranquility
[48447] = { level=80, rank=7, class="DRUID" }, -- Tranquility
[48450] = { level=72, rank=2, next=48451, class="DRUID" }, -- Lifebloom
[48451] = { level=80, rank=3, class="DRUID" }, -- Lifebloom
[48459] = { level=74, rank=11, next=48461, class="DRUID" }, -- Wrath
[48461] = { level=79, rank=12, class="DRUID" }, -- Wrath
[48462] = { level=75, rank=13, next=48463, class="DRUID" }, -- Moonfire
[48463] = { level=80, rank=14, class="DRUID" }, -- Moonfire
[48464] = { level=72, rank=9, next=48465, class="DRUID" }, -- Starfire
[48465] = { level=78, rank=10, class="DRUID" }, -- Starfire
[48467] = { level=80, rank=5, class="DRUID" }, -- Hurricane
[48468] = { level=80, rank=7, class="DRUID" }, -- Insect Swarm
[48469] = { level=80, rank=9, class="DRUID" }, -- Mark of the Wild
[48470] = { level=80, rank=4, class="DRUID" }, -- Gift of the Wild
[48477] = { level=79, rank=7, class="DRUID" }, -- Rebirth
[48479] = { level=73, rank=9, next=48480, class="DRUID" }, -- Maul
[48480] = { level=79, rank=10, class="DRUID" }, -- Maul
[48505] = { level=60, rank=1, next=53199, class="DRUID" }, -- Starfall
[48559] = { level=71, rank=7, next=48560, class="DRUID" }, -- Demoralizing Roar
[48560] = { level=77, rank=8, class="DRUID" }, -- Demoralizing Roar
[48561] = { level=72, rank=7, next=48562, class="DRUID" }, -- Swipe (Bear)
[48562] = { level=77, rank=8, class="DRUID" }, -- Swipe (Bear)
[48563] = { level=75, rank=4, next=48564, class="DRUID" }, -- Mangle (Bear)
[48564] = { level=80, rank=5, class="DRUID" }, -- Mangle (Bear)
[48565] = { level=75, rank=4, next=48566, class="DRUID" }, -- Mangle (Cat)
[48566] = { level=80, rank=5, class="DRUID" }, -- Mangle (Cat)
[48567] = { level=73, rank=2, next=48568, class="DRUID" }, -- Lacerate
[48568] = { level=80, rank=3, class="DRUID" }, -- Lacerate
[48569] = { level=73, rank=7, next=48570, class="DRUID" }, -- Claw
[48570] = { level=79, rank=8, class="DRUID" }, -- Claw
[48571] = { level=75, rank=8, next=48572, class="DRUID" }, -- Shred
[48572] = { level=80, rank=9, class="DRUID" }, -- Shred
[48573] = { level=72, rank=6, next=48574, class="DRUID" }, -- Rake
[48574] = { level=78, rank=7, class="DRUID" }, -- Rake
[48575] = { level=76, rank=6, class="DRUID" }, -- Cower
[48576] = { level=72, rank=7, next=48577, class="DRUID" }, -- Ferocious Bite
[48577] = { level=78, rank=8, class="DRUID" }, -- Ferocious Bite
[48578] = { level=73, rank=6, next=48579, class="DRUID" }, -- Ravage
[48579] = { level=79, rank=7, class="DRUID" }, -- Ravage
[48637] = { level=76, rank=11, next=48638, class="ROGUE" }, -- Sinister Strike
[48638] = { level=80, rank=12, class="ROGUE" }, -- Sinister Strike
[48656] = { level=74, rank=11, next=48657, class="ROGUE" }, -- Backstab
[48657] = { level=80, rank=12, class="ROGUE" }, -- Backstab
[48658] = { level=72, rank=7, next=48659, class="ROGUE" }, -- Feint
[48659] = { level=78, rank=8, class="ROGUE" }, -- Feint
[48660] = { level=80, rank=5, class="ROGUE" }, -- Hemorrhage
[48663] = { level=75, rank=5, next=48666, class="ROGUE" }, -- Mutilate
[48666] = { level=80, rank=6, class="ROGUE" }, -- Mutilate
[48667] = { level=73, rank=11, next=48668, class="ROGUE" }, -- Eviscerate
[48668] = { level=79, rank=12, class="ROGUE" }, -- Eviscerate
[48671] = { level=74, rank=8, next=48672, class="ROGUE" }, -- Rupture
[48672] = { level=79, rank=9, class="ROGUE" }, -- Rupture
[48673] = { level=70, rank=2, next=48674, class="ROGUE" }, -- Deadly Throw
[48674] = { level=76, rank=3, class="ROGUE" }, -- Deadly Throw
[48675] = { level=75, rank=9, next=48676, class="ROGUE" }, -- Garrote
[48676] = { level=80, rank=10, class="ROGUE" }, -- Garrote
[48689] = { level=70, rank=8, next=48690, class="ROGUE" }, -- Ambush
[48690] = { level=75, rank=9, next=48691, class="ROGUE" }, -- Ambush
[48691] = { level=80, rank=10, class="ROGUE" }, -- Ambush
[48707] = { level=68, class="DEATHKNIGHT" }, -- Anti-Magic Shell
[48721] = { level=58, rank=1, next=49939, class="DEATHKNIGHT" }, -- Blood Boil
[48743] = { level=66, class="DEATHKNIGHT" }, -- Death Pact
[27139] = { level=69, rank=3, next=48816, class="PALADIN" }, -- Holy Wrath
[48816] = { level=72, rank=4, next=48817, class="PALADIN" }, -- Holy Wrath
[48817] = { level=78, rank=5, class="PALADIN" }, -- Holy Wrath
[633] = { level=10, rank=1, next=2800, class="PALADIN" }, -- Lay on Hands
[2800] = { level=30, rank=2, next=10310, class="PALADIN" }, -- Lay on Hands
[48792] = { level=62, class="DEATHKNIGHT" }, -- Icebound Fortitude
[10310] = { level=50, rank=3, next=27154, class="PALADIN" }, -- Lay on Hands
[27154] = { level=69, rank=4, next=48788, class="PALADIN" }, -- Lay on Hands
[48805] = { level=74, rank=5, next=48806, class="PALADIN" }, -- Hammer of Wrath
[48806] = { level=80, rank=6, class="PALADIN" }, -- Hammer of Wrath
[48788] = { level=78, rank=5, class="PALADIN" }, -- Lay on Hands
[1152] = { level=8, next=4987, class="PALADIN" }, -- Purify
[7328] = { level=12, rank=1, next=10322, class="PALADIN" }, -- Redemption
[10322] = { level=24, rank=2, next=10324, class="PALADIN" }, -- Redemption
[10324] = { level=36, rank=3, next=20772, class="PALADIN" }, -- Redemption
[20772] = { level=48, rank=4, next=20773, class="PALADIN" }, -- Redemption
[48826] = { level=75, rank=4, next=48827, class="PALADIN" }, -- Avenger's Shield
[48827] = { level=80, rank=5, class="PALADIN" }, -- Avenger's Shield
[48931] = { level=73, rank=9, next=48932, class="PALADIN" }, -- Blessing of Might
[48932] = { level=79, rank=10, class="PALADIN" }, -- Blessing of Might
[48933] = { level=73, rank=4, next=48934, class="PALADIN" }, -- Greater Blessing of Might
[48934] = { level=79, rank=5, class="PALADIN" }, -- Greater Blessing of Might
[20773] = { level=60, rank=5, next=48949, class="PALADIN" }, -- Redemption
[48949] = { level=72, rank=6, next=48950, class="PALADIN" }, -- Redemption
[48950] = { level=79, rank=7, class="PALADIN" }, -- Redemption
[53601] = { level=80, rank=1, class="PALADIN" }, -- Sacred Shield
[48941] = { level=74, rank=9, next=48942, class="PALADIN" }, -- Devotion Aura
[48942] = { level=79, rank=10, class="PALADIN" }, -- Devotion Aura
[48943] = { level=76, rank=5, class="PALADIN" }, -- Shadow Resistance Aura
[48945] = { level=77, rank=5, class="PALADIN" }, -- Frost Resistance Aura
[48947] = { level=78, rank=5, class="PALADIN" }, -- Fire Resistance Aura
[20165] = { level=30, class="PALADIN" }, -- Seal of Light
[20166] = { level=38, class="PALADIN" }, -- Seal of Wisdom
[48951] = { level=75, rank=5, next=48952, class="PALADIN" }, -- Holy Shield
[48952] = { level=80, rank=6, class="PALADIN" }, -- Holy Shield
[48989] = { level=74, rank=9, next=48990, class="HUNTER" }, -- Mend Pet
[48990] = { level=80, rank=10, class="HUNTER" }, -- Mend Pet
[48995] = { level=71, rank=10, next=48996, class="HUNTER" }, -- Raptor Strike
[48996] = { level=77, rank=11, class="HUNTER" }, -- Raptor Strike
[48998] = { level=72, rank=5, next=48999, class="HUNTER" }, -- Counterattack
[48999] = { level=78, rank=6, class="HUNTER" }, -- Counterattack
[49000] = { level=73, rank=11, next=49001, class="HUNTER" }, -- Serpent Sting
[49001] = { level=79, rank=12, class="HUNTER" }, -- Serpent Sting
[49011] = { level=75, rank=5, next=49012, class="HUNTER" }, -- Wyvern Sting
[49012] = { level=80, rank=6, class="HUNTER" }, -- Wyvern Sting
[49020] = { level=61, rank=1, next=51423, class="DEATHKNIGHT" }, -- Obliterate
[49044] = { level=73, rank=10, next=49045, class="HUNTER" }, -- Arcane Shot
[49045] = { level=79, rank=11, class="HUNTER" }, -- Arcane Shot
[49047] = { level=74, rank=7, next=49048, class="HUNTER" }, -- Multi-Shot
[49048] = { level=80, rank=8, class="HUNTER" }, -- Multi-Shot
[49049] = { level=75, rank=8, next=49050, class="HUNTER" }, -- Aimed Shot
[49050] = { level=80, rank=9, class="HUNTER" }, -- Aimed Shot
[49051] = { level=71, rank=3, next=49052, class="HUNTER" }, -- Steady Shot
[49052] = { level=77, rank=4, class="HUNTER" }, -- Steady Shot
[49055] = { level=72, rank=7, next=49056, class="HUNTER" }, -- Immolation Trap
[49056] = { level=78, rank=8, class="HUNTER" }, -- Immolation Trap
[49066] = { level=71, rank=5, next=49067, class="HUNTER" }, -- Explosive Trap
[49067] = { level=77, rank=6, class="HUNTER" }, -- Explosive Trap
[49071] = { level=76, rank=4, class="HUNTER" }, -- Aspect of the Wild
[49143] = { level=50, rank=1, next=51416, class="DEATHKNIGHT" }, -- Frost Strike
[49158] = { level=20, rank=1, next=51325, class="DEATHKNIGHT" }, -- Corpse Explosion
[49184] = { level=60, rank=1, next=51409, class="DEATHKNIGHT" }, -- Howling Blast
[49230] = { level=74, rank=9, next=49231, class="SHAMAN" }, -- Earth Shock
[49231] = { level=79, rank=10, class="SHAMAN" }, -- Earth Shock
[49232] = { level=75, rank=8, next=49233, class="SHAMAN" }, -- Flame Shock
[49233] = { level=80, rank=9, class="SHAMAN" }, -- Flame Shock
[49235] = { level=73, rank=6, next=49236, class="SHAMAN" }, -- Frost Shock
[49236] = { level=78, rank=7, class="SHAMAN" }, -- Frost Shock
[49237] = { level=73, rank=13, next=49238, class="SHAMAN" }, -- Lightning Bolt
[49238] = { level=79, rank=14, class="SHAMAN" }, -- Lightning Bolt
[49270] = { level=74, rank=7, next=49271, class="SHAMAN" }, -- Chain Lightning
[49271] = { level=80, rank=8, class="SHAMAN" }, -- Chain Lightning
[49272] = { level=75, rank=13, next=49273, class="SHAMAN" }, -- Healing Wave
[49273] = { level=80, rank=14, class="SHAMAN" }, -- Healing Wave
[49275] = { level=72, rank=8, next=49276, class="SHAMAN" }, -- Lesser Healing Wave
[49276] = { level=77, rank=9, class="SHAMAN" }, -- Lesser Healing Wave
[49277] = { level=80, rank=7, class="SHAMAN" }, -- Ancestral Spirit
[49280] = { level=75, rank=10, next=49281, class="SHAMAN" }, -- Lightning Shield
[49281] = { level=80, rank=11, class="SHAMAN" }, -- Lightning Shield
[49283] = { level=75, rank=4, next=49284, class="SHAMAN" }, -- Earth Shield
[49284] = { level=80, rank=5, class="SHAMAN" }, -- Earth Shield
[49358] = { level=35, class="MAGE", faction="Horde" }, -- Teleport: Stonard
[49359] = { level=35, class="MAGE", faction="Alliance" }, -- Teleport: Theramore
[49360] = { level=35, class="MAGE", faction="Alliance" }, -- Portal: Theramore
[49361] = { level=35, class="MAGE", faction="Horde" }, -- Portal: Stonard
[49376] = { level=20, class="DRUID" }, -- Feral Charge - Cat
[49799] = { level=71, rank=8, next=49800, class="DRUID" }, -- Rip
[49800] = { level=80, rank=9, class="DRUID" }, -- Rip
[49802] = { level=74, rank=2, class="DRUID" }, -- Maim
[49803] = { level=77, rank=5, class="DRUID" }, -- Pounce
[49892] = { level=62, rank=2, next=49893, class="DEATHKNIGHT" }, -- Death Coil
[49893] = { level=68, rank=3, next=49894, class="DEATHKNIGHT" }, -- Death Coil
[49894] = { level=76, rank=4, next=49895, class="DEATHKNIGHT" }, -- Death Coil
[49895] = { level=80, rank=5, class="DEATHKNIGHT" }, -- Death Coil
[49896] = { level=61, rank=2, next=49903, class="DEATHKNIGHT" }, -- Icy Touch
[49903] = { level=67, rank=3, next=49904, class="DEATHKNIGHT" }, -- Icy Touch
[49904] = { level=73, rank=4, next=49909, class="DEATHKNIGHT" }, -- Icy Touch
[49909] = { level=78, rank=5, class="DEATHKNIGHT" }, -- Icy Touch
[49917] = { level=60, rank=2, next=49918, class="DEATHKNIGHT" }, -- Plague Strike
[49918] = { level=65, rank=3, next=49919, class="DEATHKNIGHT" }, -- Plague Strike
[49919] = { level=70, rank=4, next=49920, class="DEATHKNIGHT" }, -- Plague Strike
[49920] = { level=75, rank=5, next=49921, class="DEATHKNIGHT" }, -- Plague Strike
[49921] = { level=80, rank=6, class="DEATHKNIGHT" }, -- Plague Strike
[49923] = { level=75, rank=4, next=49924, class="DEATHKNIGHT" }, -- Death Strike
[49924] = { level=80, rank=5, class="DEATHKNIGHT" }, -- Death Strike
[49926] = { level=59, rank=2, next=49927, class="DEATHKNIGHT" }, -- Blood Strike
[49927] = { level=64, rank=3, next=49928, class="DEATHKNIGHT" }, -- Blood Strike
[49928] = { level=69, rank=4, next=49929, class="DEATHKNIGHT" }, -- Blood Strike
[49929] = { level=74, rank=5, next=49930, class="DEATHKNIGHT" }, -- Blood Strike
[49930] = { level=80, rank=6, class="DEATHKNIGHT" }, -- Blood Strike
[49936] = { level=67, rank=2, next=49937, class="DEATHKNIGHT" }, -- Death and Decay
[49937] = { level=73, rank=3, next=49938, class="DEATHKNIGHT" }, -- Death and Decay
[49938] = { level=80, rank=4, class="DEATHKNIGHT" }, -- Death and Decay
[49939] = { level=66, rank=2, next=49940, class="DEATHKNIGHT" }, -- Blood Boil
[49940] = { level=72, rank=3, next=49941, class="DEATHKNIGHT" }, -- Blood Boil
[49941] = { level=78, rank=4, class="DEATHKNIGHT" }, -- Blood Boil
[49998] = { level=56, rank=1, next=49999, class="DEATHKNIGHT" }, -- Death Strike
[49999] = { level=63, rank=2, next=45463, class="DEATHKNIGHT" }, -- Death Strike
[50212] = { level=71, rank=5, next=50213, class="DRUID" }, -- Tiger's Fury
[50213] = { level=79, rank=6, class="DRUID" }, -- Tiger's Fury
[50464] = { level=80, rank=1, class="DRUID" }, -- Nourish
[50511] = { level=71, rank=9, class="WARLOCK" }, -- Curse of Weakness
[50516] = { level=50, rank=1, next=53223, class="DRUID" }, -- Typhoon
[50581] = { level=60, class="WARLOCK" }, -- Shadow Cleave
[50589] = { level=60, class="WARLOCK" }, -- Immolation Aura
[50763] = { level=80, rank=7, class="DRUID" }, -- Revive
[50764] = { level=69, rank=6, next=50763, class="DRUID" }, -- Revive
[50765] = { level=60, rank=5, next=50764, class="DRUID" }, -- Revive
[50766] = { level=48, rank=4, next=50765, class="DRUID" }, -- Revive
[50767] = { level=36, rank=3, next=50766, class="DRUID" }, -- Revive
[50768] = { level=24, rank=2, next=50767, class="DRUID" }, -- Revive
[50769] = { level=12, rank=1, next=50768, class="DRUID" }, -- Revive
[50796] = { level=60, rank=1, next=59170, class="WARLOCK" }, -- Chaos Bolt
[50842] = { level=56, class="DEATHKNIGHT" }, -- Pestilence
[51325] = { level=60, rank=2, next=51326, class="DEATHKNIGHT" }, -- Corpse Explosion
[51326] = { level=70, rank=3, next=51327, class="DEATHKNIGHT" }, -- Corpse Explosion
[51327] = { level=75, rank=4, next=51328, class="DEATHKNIGHT" }, -- Corpse Explosion
[51328] = { level=80, rank=5, class="DEATHKNIGHT" }, -- Corpse Explosion
[51409] = { level=70, rank=2, next=51410, class="DEATHKNIGHT" }, -- Howling Blast
[51410] = { level=75, rank=3, next=51411, class="DEATHKNIGHT" }, -- Howling Blast
[51411] = { level=80, rank=4, class="DEATHKNIGHT" }, -- Howling Blast
[51416] = { level=60, rank=2, next=51417, class="DEATHKNIGHT" }, -- Frost Strike
[51417] = { level=65, rank=3, next=51418, class="DEATHKNIGHT" }, -- Frost Strike
[51418] = { level=70, rank=4, next=51419, class="DEATHKNIGHT" }, -- Frost Strike
[51419] = { level=75, rank=5, next=55268, class="DEATHKNIGHT" }, -- Frost Strike
[51423] = { level=67, rank=2, next=51424, class="DEATHKNIGHT" }, -- Obliterate
[51424] = { level=73, rank=3, next=51425, class="DEATHKNIGHT" }, -- Obliterate
[51425] = { level=79, rank=4, class="DEATHKNIGHT" }, -- Obliterate
[51490] = { level=60, rank=1, next=59156, class="SHAMAN" }, -- Thunderstorm
[51505] = { level=75, rank=1, next=60043, class="SHAMAN" }, -- Lava Burst
[51514] = { level=80, class="SHAMAN" }, -- Hex
[51722] = { level=20, class="ROGUE" }, -- Dismantle
[51723] = { level=80, class="ROGUE" }, -- Fan of Knives
[51724] = { level=71, rank=4, class="ROGUE" }, -- Sap
[51730] = { level=30, rank=1, next=51988, class="SHAMAN" }, -- Earthliving Weapon
[51988] = { level=40, rank=2, next=51991, class="SHAMAN" }, -- Earthliving Weapon
[51991] = { level=50, rank=3, next=51992, class="SHAMAN" }, -- Earthliving Weapon
[51992] = { level=60, rank=4, next=51993, class="SHAMAN" }, -- Earthliving Weapon
[51993] = { level=70, rank=5, next=51994, class="SHAMAN" }, -- Earthliving Weapon
[51994] = { level=80, rank=6, class="SHAMAN" }, -- Earthliving Weapon
[52127] = { level=20, rank=1, next=52129, class="SHAMAN" }, -- Water Shield
[52129] = { level=28, rank=2, next=52131, class="SHAMAN" }, -- Water Shield
[52131] = { level=34, rank=3, next=52134, class="SHAMAN" }, -- Water Shield
[52134] = { level=41, rank=4, next=52136, class="SHAMAN" }, -- Water Shield
[52136] = { level=48, rank=5, next=52138, class="SHAMAN" }, -- Water Shield
[52138] = { level=55, rank=6, next=24398, class="SHAMAN" }, -- Water Shield
[52610] = { level=75, rank=1, class="DRUID" }, -- Savage Roar
[53005] = { level=70, rank=2, next=53006, class="PRIEST" }, -- Penance
[53006] = { level=75, rank=3, next=53007, class="PRIEST" }, -- Penance
[53007] = { level=80, rank=4, class="PRIEST" }, -- Penance
[53023] = { level=80, rank=2, class="PRIEST" }, -- Mind Sear
[53140] = { level=71, class="MAGE" }, -- Teleport: Dalaran
[53142] = { level=74, class="MAGE" }, -- Portal: Dalaran
[53199] = { level=70, rank=2, next=53200, class="DRUID" }, -- Starfall
[53200] = { level=75, rank=3, next=53201, class="DRUID" }, -- Starfall
[53201] = { level=80, rank=4, class="DRUID" }, -- Starfall
[53223] = { level=60, rank=2, next=53225, class="DRUID" }, -- Typhoon
[53225] = { level=70, rank=3, next=53226, class="DRUID" }, -- Typhoon
[53226] = { level=75, rank=4, next=61384, class="DRUID" }, -- Typhoon
[53248] = { level=70, rank=2, next=53249, class="DRUID" }, -- Wild Growth
[53249] = { level=75, rank=3, next=53251, class="DRUID" }, -- Wild Growth
[53251] = { level=80, rank=4, class="DRUID" }, -- Wild Growth
[53271] = { level=75, class="HUNTER" }, -- Master's Call
[53301] = { level=60, rank=1, next=60051, class="HUNTER" }, -- Explosive Shot
[53307] = { level=74, rank=8, class="DRUID" }, -- Thorns
[53308] = { level=78, rank=8, class="DRUID" }, -- Entangling Roots
[53312] = { level=78, rank=8, class="DRUID" }, -- Nature's Grasp
[53338] = { level=76, rank=5, class="HUNTER" }, -- Hunter's Mark
[53339] = { level=80, rank=6, class="HUNTER" }, -- Mongoose Bite
[53351] = { level=71, rank=1, next=61005, class="HUNTER" }, -- Kill Shot
[53407] = { level=28, class="PALADIN" }, -- Judgement of Justice
[53408] = { level=12, class="PALADIN" }, -- Judgement of Wisdom
[53600] = { level=75, rank=1, next=61411, class="PALADIN" }, -- Shield of Righteousness
[5502] = { level=20, class="PALADIN" }, -- Sense Undead
[53736] = { level=66, class="PALADIN", faction="Horde" }, -- Seal of Corruption
[54043] = { level=76, rank=7, class="PALADIN" }, -- Retribution Aura
[10326] = { level=24, class="PALADIN" }, -- Turn Evil
[54785] = { level=60, class="WARLOCK" }, -- Demon Charge
[55050] = { level=50, rank=1, next=55258, class="DEATHKNIGHT" }, -- Heart Strike
[55090] = { level=50, rank=1, next=55265, class="DEATHKNIGHT" }, -- Scourge Strike
[55258] = { level=59, rank=2, next=55259, class="DEATHKNIGHT" }, -- Heart Strike
[55259] = { level=64, rank=3, next=55260, class="DEATHKNIGHT" }, -- Heart Strike
[55260] = { level=69, rank=4, next=55261, class="DEATHKNIGHT" }, -- Heart Strike
[55261] = { level=74, rank=5, next=55262, class="DEATHKNIGHT" }, -- Heart Strike
[55262] = { level=80, rank=6, class="DEATHKNIGHT" }, -- Heart Strike
[55265] = { level=67, rank=2, next=55270, class="DEATHKNIGHT" }, -- Scourge Strike
[55268] = { level=80, rank=6, class="DEATHKNIGHT" }, -- Frost Strike
[55270] = { level=73, rank=3, next=55271, class="DEATHKNIGHT" }, -- Scourge Strike
[55271] = { level=79, rank=4, class="DEATHKNIGHT" }, -- Scourge Strike
[55342] = { level=80, class="MAGE" }, -- Mirror Image
[55359] = { level=70, rank=2, next=55360, class="MAGE" }, -- Living Bomb
[55360] = { level=80, rank=3, class="MAGE" }, -- Living Bomb
[55458] = { level=74, rank=6, next=55459, class="SHAMAN" }, -- Chain Heal
[55459] = { level=80, rank=7, class="SHAMAN" }, -- Chain Heal
[55694] = { level=75, class="WARRIOR" }, -- Enraged Regeneration
[56222] = { level=65, class="DEATHKNIGHT" }, -- Dark Command
[56641] = { level=50, rank=1, next=34120, class="HUNTER" }, -- Steady Shot
[56815] = { level=67, class="DEATHKNIGHT" }, -- Rune Strike
[57330] = { level=65, rank=1, next=57623, class="DEATHKNIGHT" }, -- Horn of Winter
[57622] = { level=75, rank=7, next=58643, class="SHAMAN" }, -- Strength of Earth Totem
[57623] = { level=75, rank=2, class="DEATHKNIGHT" }, -- Horn of Winter
[57720] = { level=60, rank=2, next=57721, class="SHAMAN" }, -- Totem of Wrath
[57721] = { level=70, rank=3, next=57722, class="SHAMAN" }, -- Totem of Wrath
[57722] = { level=80, rank=4, class="SHAMAN" }, -- Totem of Wrath
[57755] = { level=80, class="WARRIOR" }, -- Heroic Throw
[57823] = { level=80, rank=9, class="WARRIOR" }, -- Revenge
[57934] = { level=75, class="ROGUE" }, -- Tricks of the Trade
[57946] = { level=80, rank=8, class="WARLOCK" }, -- Life Tap
[57960] = { level=76, rank=9, class="SHAMAN" }, -- Water Shield
[57964] = { level=73, rank=8, next=57965, class="ROGUE" }, -- Instant Poison VIII
[57965] = { level=79, rank=9, class="ROGUE" }, -- Instant Poison IX
[57967] = { level=73, rank=8, next=57968, class="ROGUE" }, -- Instant Poison VIII
[57968] = { level=79, rank=9, class="ROGUE" }, -- Instant Poison IX
[57969] = { level=76, rank=8, next=57970, class="ROGUE" }, -- Deadly Poison VIII
[57970] = { level=80, rank=9, class="ROGUE" }, -- Deadly Poison IX
[57972] = { level=76, rank=8, next=57973, class="ROGUE" }, -- Deadly Poison VIII
[57973] = { level=80, rank=9, class="ROGUE" }, -- Deadly Poison IX
[57974] = { level=72, rank=6, next=57975, class="ROGUE" }, -- Wound Poison VI
[57975] = { level=78, rank=7, class="ROGUE" }, -- Wound Poison VII
[57977] = { level=72, rank=6, next=57978, class="ROGUE" }, -- Wound Poison VI
[57978] = { level=78, rank=7, class="ROGUE" }, -- Wound Poison VII
[57981] = { level=77, rank=2, class="ROGUE" }, -- Anesthetic Poison II
[57982] = { level=77, rank=2, class="ROGUE" }, -- Anesthetic Poison II
[57992] = { level=74, rank=3, next=57993, class="ROGUE" }, -- Envenom
[57993] = { level=80, rank=4, class="ROGUE" }, -- Envenom
[57994] = { level=16, class="SHAMAN" }, -- Wind Shear
[58431] = { level=74, rank=5, next=58434, class="HUNTER" }, -- Volley
[58434] = { level=80, rank=6, class="HUNTER" }, -- Volley
[58580] = { level=71, rank=8, next=58581, class="SHAMAN" }, -- Stoneclaw Totem
[58581] = { level=75, rank=9, next=58582, class="SHAMAN" }, -- Stoneclaw Totem
[58582] = { level=78, rank=10, class="SHAMAN" }, -- Stoneclaw Totem
[58643] = { level=80, rank=8, class="SHAMAN" }, -- Strength of Earth Totem
[58649] = { level=71, rank=6, next=58652, class="SHAMAN" }, -- Flametongue Totem
[58652] = { level=75, rank=7, next=58656, class="SHAMAN" }, -- Flametongue Totem
[58656] = { level=80, rank=8, class="SHAMAN" }, -- Flametongue Totem
[58659] = { level=80, rank=2, class="MAGE" }, -- Ritual of Refreshment
[58699] = { level=71, rank=8, next=58703, class="SHAMAN" }, -- Searing Totem
[58703] = { level=75, rank=9, next=58704, class="SHAMAN" }, -- Searing Totem
[58704] = { level=80, rank=10, class="SHAMAN" }, -- Searing Totem
[58731] = { level=73, rank=6, next=58734, class="SHAMAN" }, -- Magma Totem
[58734] = { level=78, rank=7, class="SHAMAN" }, -- Magma Totem
[58737] = { level=75, rank=5, next=58739, class="SHAMAN" }, -- Fire Resistance Totem
[58739] = { level=80, rank=6, class="SHAMAN" }, -- Fire Resistance Totem
[58741] = { level=75, rank=5, next=58745, class="SHAMAN" }, -- Frost Resistance Totem
[58745] = { level=80, rank=6, class="SHAMAN" }, -- Frost Resistance Totem
[58746] = { level=75, rank=5, next=58749, class="SHAMAN" }, -- Nature Resistance Totem
[58749] = { level=80, rank=6, class="SHAMAN" }, -- Nature Resistance Totem
[58751] = { level=73, rank=9, next=58753, class="SHAMAN" }, -- Stoneskin Totem
[58753] = { level=78, rank=10, class="SHAMAN" }, -- Stoneskin Totem
[58755] = { level=71, rank=7, next=58756, class="SHAMAN" }, -- Healing Stream Totem
[58756] = { level=76, rank=8, next=58757, class="SHAMAN" }, -- Healing Stream Totem
[58757] = { level=80, rank=9, class="SHAMAN" }, -- Healing Stream Totem
[58771] = { level=71, rank=6, next=58773, class="SHAMAN" }, -- Mana Spring Totem
[58773] = { level=76, rank=7, next=58774, class="SHAMAN" }, -- Mana Spring Totem
[58774] = { level=80, rank=8, class="SHAMAN" }, -- Mana Spring Totem
[58785] = { level=71, rank=8, next=58789, class="SHAMAN" }, -- Flametongue Weapon
[58789] = { level=76, rank=9, next=58790, class="SHAMAN" }, -- Flametongue Weapon
[58790] = { level=80, rank=10, class="SHAMAN" }, -- Flametongue Weapon
[58794] = { level=71, rank=7, next=58795, class="SHAMAN" }, -- Frostbrand Weapon
[58795] = { level=76, rank=8, next=58796, class="SHAMAN" }, -- Frostbrand Weapon
[58796] = { level=80, rank=9, class="SHAMAN" }, -- Frostbrand Weapon
[58801] = { level=71, rank=6, next=58803, class="SHAMAN" }, -- Windfury Weapon
[58803] = { level=76, rank=7, next=58804, class="SHAMAN" }, -- Windfury Weapon
[58804] = { level=80, rank=8, class="SHAMAN" }, -- Windfury Weapon
[58887] = { level=80, rank=2, class="WARLOCK" }, -- Ritual of Souls
[59092] = { level=80, rank=5, class="WARLOCK" }, -- Dark Pact
[59156] = { level=70, rank=2, next=59158, class="SHAMAN" }, -- Thunderstorm
[59158] = { level=75, rank=3, next=59159, class="SHAMAN" }, -- Thunderstorm
[59159] = { level=80, rank=4, class="SHAMAN" }, -- Thunderstorm
[59161] = { level=70, rank=2, next=59163, class="WARLOCK" }, -- Haunt
[59163] = { level=75, rank=3, next=59164, class="WARLOCK" }, -- Haunt
[59164] = { level=80, rank=4, class="WARLOCK" }, -- Haunt
[59170] = { level=70, rank=2, next=59171, class="WARLOCK" }, -- Chaos Bolt
[59171] = { level=75, rank=3, next=59172, class="WARLOCK" }, -- Chaos Bolt
[59172] = { level=80, rank=4, class="WARLOCK" }, -- Chaos Bolt
[60043] = { level=80, rank=2, class="SHAMAN" }, -- Lava Burst
[60051] = { level=70, rank=2, next=60052, class="HUNTER" }, -- Explosive Shot
[60052] = { level=75, rank=3, next=60053, class="HUNTER" }, -- Explosive Shot
[60053] = { level=80, rank=4, class="HUNTER" }, -- Explosive Shot
[60192] = { level=80, rank=1, class="HUNTER" }, -- Freezing Arrow
[60219] = { level=74, rank=6, next=60220, class="WARLOCK" }, -- Create Firestone
[60220] = { level=80, rank=7, class="WARLOCK" }, -- Create Firestone
[61005] = { level=75, rank=2, next=61006, class="HUNTER" }, -- Kill Shot
[61006] = { level=80, rank=3, class="HUNTER" }, -- Kill Shot
[61024] = { level=80, rank=7, class="MAGE" }, -- Dalaran Intellect
[61191] = { level=72, rank=4, class="WARLOCK" }, -- Enslave Demon
[61290] = { level=80, rank=2, class="WARLOCK" }, -- Shadowflame
[61295] = { level=60, rank=1, next=61299, class="SHAMAN" }, -- Riptide
[61299] = { level=70, rank=2, next=61300, class="SHAMAN" }, -- Riptide
[61300] = { level=75, rank=3, next=61301, class="SHAMAN" }, -- Riptide
[61301] = { level=80, rank=4, class="SHAMAN" }, -- Riptide
[61305] = { level=60, class="MAGE" }, -- Polymorph: Black Cat
[61316] = { level=80, rank=3, class="MAGE" }, -- Dalaran Brilliance
[61384] = { level=80, rank=5, class="DRUID" }, -- Typhoon
[61411] = { level=80, rank=2, class="PALADIN" }, -- Shield of Righteousness
[61649] = { level=75, rank=8, next=61657, class="SHAMAN" }, -- Fire Nova
[61657] = { level=80, rank=9, class="SHAMAN" }, -- Fire Nova
[61721] = { level=60, class="MAGE" }, -- Polymorph: Rabbit
[61780] = { level=60, class="MAGE" }, -- Polymorph: Turkey
[61846] = { level=74, rank=1, next=61847, class="HUNTER" }, -- Aspect of the Dragonhawk
[61847] = { level=80, rank=2, class="HUNTER" }, -- Aspect of the Dragonhawk
[61999] = { level=72, class="DEATHKNIGHT" }, -- Raise Ally
[62078] = { level=71, rank=1, class="DRUID" }, -- Swipe (Cat)
[62124] = { level=16, class="PALADIN" }, -- Hand of Reckoning
[62600] = { level=40, class="DRUID" }, -- Savage Defense
[62757] = { level=80, class="HUNTER" }, -- Call Stabled Pet
[63668] = { level=57, rank=2, next=63669, class="HUNTER" }, -- Black Arrow
[63669] = { level=63, rank=3, next=63670, class="HUNTER" }, -- Black Arrow
[63670] = { level=69, rank=4, next=63671, class="HUNTER" }, -- Black Arrow
[63671] = { level=75, rank=5, next=63672, class="HUNTER" }, -- Black Arrow
[63672] = { level=80, rank=6, class="HUNTER" }, -- Black Arrow
[64382] = { level=71, class="WARRIOR" }, -- Shattering Throw
[64843] = { level=80, rank=1, class="PRIEST" }, -- Divine Hymn
[64901] = { level=80, class="PRIEST" }, -- Hymn of Hope
[66842] = { level=30, class="SHAMAN" }, -- Call of the Elements
[66843] = { level=40, class="SHAMAN" }, -- Call of the Ancestors
[66844] = { level=50, class="SHAMAN" }, -- Call of the Spirits
}
