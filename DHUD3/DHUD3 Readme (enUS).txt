DHUD3 is a recode, new features adition and optimization of Drathal's original DHUD.

********************
Drathals HUD3  - DHUD3
Copyright (c) 2006 by Markus Inger, 2006 by Caeryn Dryad, 2007-2009 by Horacio Hoyos

This file is part of DHUD3.

    DHUD2 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DHUD2 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DHUD3.  If not, see <http://www.gnu.org/licenses/>.
********************

== DHUD3 ==
**DHUD3 is a modular Heads Up Display Addon.**
=== **Core Module** ===
Core functionality on which the other modules build up. Lets you set DHUD3 general settings.

* 6 Transparency (Alpha) settings for:
	** In Combat
	** Casting
	** Target Selected
	** No Target
	** Regeneracy
	** Dead 
* Show/Hide bar borders
* Show/Hide bars when empty
* Addon scale
* Selectable font for all DHUD3 texts
* Configuration via '''/dhud3''' menu or Bliz's Interface->Addons Menu
        
=== **Player Module** ===
Bars to show Player and Target Health/Power information, and Target and Target of Target name plates.

* 2 sets of Health/Power (mana, rage, energy, focus, runic power, happiness) Bars that change colors as they diminish and that give a number value of the status shown
* Configurable color (full, medium and low level) for health and each of the power types.
* Configurable display, with centered (health to one side, power to the other) or sided options. 
* Configurable bar value display using DogTags
* Show/Hide bar values
* Movable bar values (alt+click)
* Drop down menus for self and party actions 

# Player
	** Option to swap player's status for pet's when riding a vehicle
	** Status indicator icon to show if you're resting
	** Status indicator icon to show if you're in combat
	** Status indicator icon to show if you're party leader
	** Status indicator icon to show if you're loot master
	** Status indicator icon to show if you are in PvP (remaining time mouse over)  

# Target
	** Target and Target of Target name plates, with configurable style using DogTags
	** Click-2-Target on Target of Target name plate
	** Status indicator icon to show raid icons (X, circle, skull, etc)
	** Status indicator icon to show Target PvP Status
	** Support for up to 40 target buffs and debuffs, with option to show tips
	** Status indicator icon to show if the mob is elite (new arts!)

=== **Auras Module** ===
Show player buffs and/or weapon enchants close to expiring.

* 16 slots that display buff icon and time left
* Independent scaling
* Configurable time filter to display buffs
* Configurable time left font size
* Configurable border and text color to emphasize expiration (color starts to change when less than 20 seconds remain)
* Option to display weapon enchants as buffs
	** Option to configure the slots used by the weapon enchants
* Buffs can be shown to the left or to the right
* Option to show tool tip with information about the buff    

=== **Abilities Module** ===
Show/track abilities specific to your class applied to your target (DoTs, HoTs, etc), or Death Knight runes.

* 6 slots to track abilities
* Independant scaling
* Configurable border and text color to emphasize expiration/readyness
* Track time left if ability has it
* CLASS SPECIFIC:
	** Druids:
		*** Combo Points
		*** Lacerates
		*** Lifeblooms
	** Rogues:
		*** Combo Points
	** Warriors:
		*** Sunder armors
	** Death Knights
		*** Runes (Runes can be displayed in 1 of 4 possible layouts)
	** Shamans
		*** Totems
	** Vehicles
		*** Combo points

=== **Pet Module** ===
Bars to display Pet's Health/Power information. You can also use them to show Vehicle/Player information when in a vehicle and/or to show druid mana while shape shifted.

* 2 sets of Health/Power (mana, rage, energy, focus, runic power, happiness) Bars that change colors as they diminish and that give a number value of the status shown. This bars are smaller than the Player Module ones and located to it's inside
* Icon to track pet happines
* Configurable bar value display using DogTags. Separte options for Pet status and Druid mana.
* Show/Hide bar values
* Movable bar values (alt+click)
* Configurable colors for high, medium and low values for Health and each of the Power types.
* Configurable display, with centered (health to one side, power to the other) or sided options.
* Configurable Druid mana bar side, independant of pet display configuration.

=== **Outer Module** ===
Bars to display Focus' or Target of Target's Health/Power, and/or Threat information.

* 2 sets of Health/Power (mana, rage, energy, focus, runic power, happiness) or Threat Barsthat change colors as they diminish and that give a number value of the status shown
* Each bar has individual settings
* Configurable color (full, medium and low level) for health, each of the power types and threat.
* Configurable bar value display using DogTags
* Show/Hide bar values
* Movable bar values (alt+click)

	# Options
		** Track Focus Health/Power
		** Track Target of Target Health/Power
		** Track Threat percent as a fraction of the tanks threat
		** Option to show threat bar only when in Party

=== **Cast Module** ===
Bars to display PLayer and Target cast. The bars overlap with the Player Module

* Cast bar that fills to show spell casting progress. The cast bar is not full, but just a border.
* Configurable color (complete, half and start) that afects bar and cast timer
* Option to show/hide texts
* Configurable font size
* Option to show cast in reverse
* Cpnfigurable color for spell name and delay
* Independant options for player and targer bar



=== TO DO ===
* Add more tracking posibilities to the Abilities Module.
* Option to show/hide blizz player and target frames
* Minimap button for "self" menu
* Option to enable/disable player PvP Icon when targeting
* Movable bars (This one I am still thinking about)


=== Known Issues ===
Focusing using drop down menu is now a protected function. Using the focus option in DHUD3 drop-down menus will generate an error. 