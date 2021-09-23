--[[
DHUD3
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
local L = LibStub("AceLocale-3.0"):NewLocale("DHUD3", "enUS", true)

L["Alphas"] = true
L["Bar font"] = true
L["Bliz Frames"] = true
L["Casting"] = true
L["Center Spacing"] = true
L["Cheking this option will prevent tooltips, frame moving and menu popping for this module"] = true
L["Click Trough Frames"] = true
L["Combat"] = true
L["Configure bar's border functionality"] = true
L["Death"] = true
L["Font size"] = true
L["General Options"] = true
L["General"] = true
L["Off Combat"] = true
L["Regeneration"] = true
L["Selection"] = true
L["Set DHUD3's scale"] = true
L["Set the HUD's situation alpha. The order shown is the precedence order, i.e. Combat alpha will override Selection alpha."] = true
L["Show Bar Borders"] = true
L["Show Bars when empty"] = true
L["Show Blizzard casting bar"] = true
L["Show Blizzard's pet frame. If you hide the Player's frame no matter your choice here the Pet Frame will be hidden."] = true
L["Show Blizzard's player frame"] = true
L["Show Blizzard's target frame"] = true
L["Show Minimap Button"] = true
L["Show bar borders"] = true
L["Show/Hide bliz frames"] = true
L["Show/hide borders"] = true
L["Show/hide empty (0 value) bars"] = true
L["The font used by all Modules."] = true

--Player
L["Bar Colors"] = true
L["Bar Layout"] = true
L["Bar Swap"] = true
L["Bar's Text"] = true
L["Centered"] = true
L["Change Auras's side"] = true
L["Columns"] = true
L["Columns"] = true
L["Configure Health and Power (mana/rage/energy/runic) text options"] = true
L["Configure the player's layout options"] = true
L["Counter Color"] = true
L["Current (Percent%)"] = true
L["Current"] = true
L["Current/Max (Percent%)"] = true
L["Current/Max"] = true
L["Custom Health Style"] = true
L["Custom Power Style"] = true
L["Enable Player Module"] = true
L["Enable Player PvP icon timer"] = true
L["Energy"] = true
L["Enter /dog for in-game LibDogTag-3.0 Tag documentation."] = true
L["Expiration Close"] = true
L["Full"] = true
L["Half Time"] = true
L["Health Inner/Power Outer"] = true
L["Health Left/Power Right"] = true
L["Health Outer/Power Inner"] = true
L["Health Right/Power Left"] = true
L["Health Style"] = true
L["Health"] = true
L["If set this style will override Health Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"] = true
L["If set this style will override Power Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Power Style setting.)"] = true
L["In Combat"] = true
L["Left"] = true
L["Low"] = true
L["Mana"] = true
L["Master Looter"] = true
L["Med"] = true
L["Number of Buffs"] = true
L["Number of Debuffs"] = true
L["Only mine"] = true
L["Only show buffs and debuffs cast by me"] = true
L["PVP Flag"] = true
L["Party Leader"] = true
L["Percent%"] = true
L["Place the Player's bars. Target's bars will be set accordingly"] = true
L["Player Frame"] = true
L["Player Module"] = true
L["Player Options"] = true
L["Player"] = true
L["Player/Target Bars"] = true
L["Power Style"] = true
L["Power"] = true
L["Rage"] = true
L["Resting"] = true
L["Right"] = true
L["Runic Power"] = true
L["Set the display options when targeting"] = true
L["Show Bar Values"] = true
L["Show PvP Timer"] = true
L["Show"] = true
L["Show/Hide Timer"] = true
L["Show/Hide status icons"] = true
L["Show/Hide"] = true
L["Size"] = true
L["Swap Target Auras"] = true
L["Swap player's status for pet's when using vehicles"] = true
L["Target Buffs"] = true
L["Target Debuffs"] = true
L["The player module manages the two main bars (player and target) functionality."] = true
L["Timer Color"] = true
L["Timer"] = true

--Target
L["Colors"] = true
L["Configure the target's layout options"] = true
L["Custom Name Style"] = true
L["Focus (Pet)"] = true
L["General"] = true
L["If set this style will override Name Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Health Style setting.)"] = true
L["Layout"] = true
L["Name Style"] = true
L["PvP Timer"] = true
L["Show Aura Tips"] = true
L["Elite Icon"] = true
L["PvP Flag"] = true
L["Raid Icon"] = true
L["Buffs"] = true
L["Debuffs"] = true
L["Only show buffs cast by me"] = true
L["Only show debuffs applied by me"] = true
L["Show target Name plate"] = true
L["Show target of target Name plate"] = true
L["Show"] = true
L["Text Size"] = true
L["Status Icons"] = true
L["Swap Target Auras"] = true
L["Tapped"] = true
L["Target Auras"] = true
L["Target Bars"] = true
L["Target Frame"] = true
L["Target Name Plate"] = true
L["Target Options"] = true
L["Target Target Name Plate"] = true
L["Target"] = true
L["When NPC"] = true

--Auras
L["Aura filter options"] = true
L["Auras Side"] = true
L["Auras"] = true
L["Border Color"] = true
L["Choose weapon Auras display order"] = true
L["Configure general functionality"] = true
L["Enable Auras Module"] = true
L["Expiration Close"] = true
L["Expiration Minutes"] = true
L["Expiration Seconds"] = true
L["Expired"] = true
L["Filter Auras duration"] = true
L["Filter Auras with a total duration higher than this value (minutes)"] = true
L["Filter Auras"] = true
L["Filter long duration Auras"] = true
L["Filters"] = true
L["First"] = true
L["Half Time"] = true
L["Higher"] = true
L["Last"] = true
L["Lower"] = true
L["Only Mine"] = true
L["Only show own auras"] = true
L["Set Auras' scale"] = true
L["Show Aura tips"] = true
L["Show/Hide Auras from weapon enchants"] = true
L["This setting will override the side setting for the abilities module"] = true
L["Weapon Auras order"] = true
L["Weapon Enchants"] = true
L["Weapon enchant display"] = true
L["Weapons"] = true

--Abilities
L["Abilities Side"] = true
L["Abilities"] = true
L["Bottom Up"] = true
L["Combos"] = true
L["Death Knight Runes"] = true
L["Death Knight"] = true
L["Druid"] = true
L["Enable Abilities"] = true
L["Half Time"] = true
L["Half'n'Away"] = true
L["Hide on Cool down"] = true
L["Hide runes that are on cool down."] = true
L["Lacerates Timer"] = true
L["Lacerates"] = true
L["Lifebloom Timer"] = true
L["Lifebloom"] = true
L["Ready"] = true
L["Rogue"] = true
L["Round Robin"] = true
L["Rune Layout"] = true
L["Rune Timer"] = true
L["Set Abilities' scale"] = true
L["Set how to display the runes. Round Robin places them in a single vertical row, runes rotate moving used ones to the top of the line. Bottom up places them at the lower side of the bars, grouped in pairs. Half'n'Away places them at the center of the bar, in vertical pairs positioned away from the bar. Centered places the runes in the center of the HUD, above the target's name plate (in this mode side setting for abilities won't have any difference)."] = true
L["Shaman Totems"] = true
L["Shaman"] = true
L["Show Abilities tips"] = true
L["Sunder Armor Timer"] = true
L["Sunder Armor"] = true
L["This setting will only be available if the Auras Module is disabled"] = true
L["Totem Timer"] = true
L["Track Death Knight Runes"] = true
L["Track Death Knight runes cool down"] = true
L["Track Druid lacerates expiration"] = true
L["Track Druid lifebloom expiration"] = true
L["Track Shaman Totems"] = true
L["Track Shaman totems expiration"] = true
L["Track Warrior sunder armors expiration"] = true
L["Track Warrior sunder armors"] = true
L["Track druid combo points"] = true
L["Track druid lacerates"] = true
L["Track druid lifebloom"] = true
L["Track rogue combo points"] = true
L["Track vehicle combo points"] = true
L["Unavailable"] = true
L["Vehicle"] = true
L["Warrior"] = true

--Pet
L["Bar Side to track mana"] = true
L["Configure Druid mana tracking when shape shifted"] = true
L["Configure Health and Power (mana/rage/energy/runic) text options"] = true
L["Configure Vehicle/Player options when in vehicle"] = true
L["Custom Mana Style"] = true
L["Druid Bar Values"] = true
L["Druid Mana"] = true
L["Druid"] = true
L["Enable Pet Module"] = true
L["If set this style will override Mana Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Mana Style setting.)"] = true
L["In Vehicle"] = true
L["Mana Style"] = true
L["Pet Happiness Icon"] = true
L["Pet Frame"] = true
L["Pet"] = true
L["PetBars"] = true
L["Place the Pet's bars."] = true
L["Side"] = true
L["The pet module manages the pet bars functionality. Track pet, vehicle or druid mana"] = true
L["Track druid's mana when shape shifted"] = true
L["Unit Pet bars track."] = true
L["Unit"] = true
L["Use pet bars to track vehicle/player stats"] = true
L["Vehicle Tracking"] = true

--Outer
L["Enable Outer Module"] = true
L["Agro Status"] = true
L["Agro Text Style"] = true
L["Agro Tracking"] = true
L["Agro"] = true
L["Bar Settings"] = true
L["Bar Text Style"] = true
L["Bar tracks"] = true
L["Custom Agro Style"] = true
L["Custom Text Style"] = true
L["Enable Pet Module"] = true
L["Focus Health"] = true
L["Focus Power"] = true
L["High"] = true
L["If set this style will override Agro Text Style value. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Agro Text Style setting.)"] = true
L["If set this style will override Bar Text Style value. Replace H (health) and M (mana/power) on your tags by X and DHUD3 will replace it appropriately depending on the status you are tracking. Use LibDogTag-3.0 Tags. (Note: Leave/set blank to use Bar Text Style setting.)"] = true
L["Is Tanking"] = true
L["Left Bar"] = true
L["None"] = true
L["On Party"] = true
L["Only track Agro while on party/raid"] = true
L["Outer"] = true
L["Pull Agro Percent (Total Agro Percent"] = true
L["Raw Threat Percent"] = true
L["Right Bar"] = true
L["Show an icon indicating if your are tanking"] = true
L["Target Of Target Health"] = true
L["Target Of Target Power"] = true
L["The outer module manages the outer bars functionality. Track focus, target of target or agro"] = true
L["Threat Percent"] = true
L["Threat Status"] = true
L["Total Agro Percent = Threat Status"] = true
L["Total Agro Percent"] = true
L["Track your agro status by coloring the bar border"] = true
L["Track your raw threat as a percent of the tank's current threat"] = true
L["Track your total threat as the percent required to pull agro"] = true

--Cast
L["Enable Cast Module"] = true
L["Begin"] = true
L["Cast Bar"] = true
L["Cast bars fills in reverse direction"] = true
L["Cast"] = true
L["Casting Bar"] = true
L["Complete"] = true
L["Delay Time"] = true
L["Half"] = true
L["Reverse"] = true
L["Show Bar Values"] = true
L["Show Blizzard's Cast Bar."] = true
L["Show Blizzard's Cast Bar."] = true
L["Show/Hide Player cast bar"] = true
L["Show/Hide Target cast bar"] = true
L["Side to show the cast bar, target bar will be shown at the opposite side"] = true
L["Spell Name"] = true
L["The cast module manages the cast bars functionality."] = true
