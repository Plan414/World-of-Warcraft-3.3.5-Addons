-----------------------
TellMeWhen 1.2.5

Credit:
-Nephthys of Hyjal <lieandswell@yahoo.com>
  for creating the Original Version of TellMeWhen
-Oozebull of Twisting Nether <oozebull@gmail.com>
  for creating the Fan Update for 3.2
-Oodyboo of Mug'thol
  for assitance with features added in 1.2.0
Further contributions by
-Sweetums of Shadowmoon
-Predeter of Proudmoore
-Jabborwok
-----------------------

TellMeWhen provides a flexible system of icons for displaying vital information -- and only vital information -- about cooldowns, buffs, debuffs, and reactive abilities... always in a consistent place on your screen.  

You choose which spells, abilities, items, buffs, and debuffs TellMeWhen shows.  The number, size, and position of icons are all customizable.  Cooldown icons can be shown when an ability/item is either usable or is unusable.  Buff/debuff icons can be shown when the buff/debuff is either present or is absent.  Icons can be set to only show in combat.  

Some examples of things you can do with TellMeWhen: 

- Display an icon when a boost trinket is finished cooling down and is ready to use
- Display an icon when a clearcasting buff procs
- A death knight could have icons appear to show that Horn of Winter has dropped and needs to be refreshed, to show when Rune Strike is usable, and to show when Sudden Doom proc
- A mage could have a Polymorph icon appear when the mob they've set to focus becomes unsheeped
- A rogue could monitor their own stack of Deadly Poison on a mob
- A warlock could monitor the number of Sunder Armor debuffs on a mob, so they can wait to dps until their warrior tank has enough threat

------------
Instructions
------------

General options are available in the Blizzard interface options menu.  You can type "/tellmewhen" or "/tmw" to lock/unlock the addon.  To configure individual icons, right click them when unlocked.  When you're finished and ready to play, enable the icons by locking the addon.  

For buffs and debuffs not in your spellbook, TellMeWhen will at first show a pocketwatch icon to indicate that it is waiting to learn the texture for the buff/debuff.  The icon will have the correct texture after you encounter the buff/debuff while playing.  

Remember that buffs sometimes have different names than the items and abilities that provide them.  For example, the buff from the death knight Sudden Doom talent is called "Death Trance!".   

Buff Equivalencies can be used in place of lists for spells with similar effects. 
Use the following groups (capitalization matters):
  -Bleeding
  -VulnerableToBleed
  -Incapacitated
  -StunnedOrIncapacitated
  -Stunned
  -DontMelee
  -ImmunToStun
  -ImmuneToMagicCC
  -FaerieFires
  -MeleeSlowed
  -MovementSlowed
  -CastingSlowed

------------------------------------
Possible features planned for future versions
------------------------------------

- Support for dragging spells/items onto icons
- Support for Options for only showing icon when in Stance/Form/Presence
- ButtonFacade Support
- Cleanup Storage system - Don't populate and store defaults for every possible icon 
  (Populate required defaults when rows/columns are added in options)

- Audit performance
- "Global" bar setting for use with alts


----------
Change log
----------
Version 1.2.5
-Added Position Reset buttton in options panel that will move any group to the center of the screen. This is useful when changing screen resolutions or when the default locations for some groups are off the screen.
-Added InRange and NoMana checks for Spells and Reactive abilities. If one of these checks fails but the spell is otherwise castable, the icon will be dimmed, but not disappear.
-Update speed increased. This may reduce performance on older machines, but will increase the responsiveness of spell icons.
-The Lock/Unlock button on the interface options panel will now only play one click sound.
-Added more buff equivalencies


Version 1.2.4
-Added 'ShowTimer' option for Reactive abilities

Big thanks to Predeter of Proudmoore for:
-Added support for multiple Auras in the same icon via semicolon (;) separated lists.
-Added Buff Equivalencies for groups of spells with similar effects. 


Version 1.2.3
-Fixed GCD problem


Version 1.2.2
-Updated for 3.3.2
-timers on buffs should now reset properly when switching targets or looking at a dead target.


Version 1.2.1
- Fixed Buffs not showing properly in patch 3.3
- reactive abilities with cooldowns like Revenge for warrs will now show a cooldown timer if they're set to show Always or show when Unusable.


Version 1.2.0 
- Added options for targetoffocus and targetofpet
- Added "/tmw options" as a shortcut to options menu

(Major thanks to Oodyboo for the following changes)
- Changed how spec settings are saved
- Editbox for "Choose spell/buff/item" retains previous entered value
- Supports 8 bars instead of the old 4
- Added primary/secondary spec toggles for each bar
- Disabled bars and icons don't process everything


Version 1.1.6
- Fixed a bug where pets caused an endless stream of errormessages when dismissed/killed
- Fixed a bug where Buff/Debuff set to "Show when Absent" was acting as it was set to "Always Visible"


Version 1.1.5 (Updated for 3.2)
- Changed Interface and Version numbers in TOC
- Buffs/Debuffs set to Always Visible now indicates if they are missing
- Icontextures should update correctly now


Version 1.1.4
- DualSpec Support


Version 1.1.3
- Rewrote Buffcheck to use UNIT_AURA instead of COMBAT_LOG_EVENT_UNFILTERED.
- Removed a bunch of variables that was created, but not used.


Version 1.1.1 (Updated for 3.1)
- Added support for multiple Buffs/Debuffs, seperated by ;
- Added support for spellIDs / itemIDs
- Added option "always" to BuffShowWhen & CooldownShowWhen


Version 1.1
-  Added cooldown and buff/debuff timers.  Compatible with OmniCC.  


Version 1.0.1
-  Updated for WoW 3.0


Version 1.0
-  Hello world!
