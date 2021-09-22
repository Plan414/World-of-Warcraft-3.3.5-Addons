Description
-----------
RankWatch will monitor the spells cast by you and other members of your party
or raid and warn them if they are using a downranked spell.

While downranked spells were formerly used to save mana, this use is no longer supported,
and while it is occasionally intended, the use of downranked spells is generally a mistake.
Sometimes this happens when people forget to train at level 80, sometimes it happens when
they spend talent points to obtain a spell which is not a base skill for the class (for
example, a Death Knight's Frost Strike our Scourge Strike) but fail to train the ranks
for the newly talented spell. In my experience, the most common cause is training while
dual specced. For example, if you level up as a feral druid, you will train new ranks of
Rejuvenation etc, but the new ranks will not appear on your bars when you change to the
Resto spec.

There are a few special cases - Life Tap and Health Funnel are not reported, since Life Tap
is often used by warlocks to proc the Glyph and stack trinkets, and Health Funnel costs less
health at lower ranks. Polymorph is sometimes downranked to control the duration, for example,
when a player is mind controlled. Rank 1 Frostbolt is used in pvp for the snare effect since
its cast time is shorter. Two different ranks of Flamestrike may be alternated to allow stacking
ground DOTs.  Occasionally (Anub'arak in ToC for example) healers may down rank to control
the amount of healing, I suggest you simply disable the addon for this fight.  If you know
of other valid uses of downranked spells, please let me know.

You can turn off the auto-whisper, ignore downranks from certain players, get a report of
all the downranked spells seen, and of course, disable the addon completely.
Type /rankwatch for help.

Installation
------------
To install RankWatch manually, download and unzip the RankWatch distribution file. The
resulting directory should contain a RankWatch folder, which will contain RankWatch.toc
and several other files. Move the RankWatch folder to your
World of Warcraft\Interface\Addons folder. Make sure when you're done that Addons contains
a folder named RankWatch, and RankWatch contains RankWatch.toc with no additional intervening
levels of folders.

Usage
-----
Once installed RankWatch will whisper level 80 players who are observed to be using
downranked spells other than the special cases noted above.  The first whisper to any
player will include a couple of lines of explanation.  Thereafter, each observed spell
will result in a one-line message.  No spell will be reported more often than once
every 60 seconds.

A few commands are available by typing /rankwatch in the chat input:
   /rankwatch enable          - enables RankWatch
   /rankwatch disable         - disables RankWatch
   /rankwatch report          - reports recently seen downranked spells
   /rankwatch clear           - clears the list of recently seen downranked spells
   /rankwatch 80              - report only level 80 players who use downranked spells
   /rankwatch all             - report all levels who use downranked spells
   /rankwatch whisper         - whisper players who use downranked spells
   /rankwatch party           - report players who use downranked spells in party/raid/bg chat
   /rankwatch say             - report players who use downranked spells with /say
   /rankwatch none            - report downranked spells only in your chat window
   /rankwatch self            - report only your own downranked spells
   /rankwatch explain enable  - first-time whispers include a short explanation
   /rankwatch explain disable - first-time whispers will not include a short explanation
   /rankwatch interval <seconds> - minimum time between whispers to the same person regarding the same spell
   /rankwatch ignore          - list players on the ignore list
   /rankwatch ignore <name>   - never report spells cast by that player
   /rankwatch watch <name>    - no longer ignore spells cast by that player

To Do
-----

 * Report on obsolete spells such as Priest's Heal, Warlock's Demon Skin, Druid's
   Cure Poison when the new version (Greater Heal, Demon Armor, Abolish Poison) is
   available

 * Configuration GUI

Copyright and Licensing 
-----------------------
Copyright (C) 2009 by Gronzig of Rexxar/US.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Change Notes
------------
Release 1.01
30 November 2009

Don't warn about Frostbolt Rank 1
Don't whisper yourself
Add version number to toc and welcome msgs
Fix inconsistent licensing information

Release 1.02
2 December 2009

Add "explain" option to turn off the first-time whisper
Communicate with other RankWatch users in the party/raid so that downrankers only receive one message
Fix erroneous reports when a paladin has Improved Lay On Hands

Release 1.03
6 December 2009

Report downranked abilities used by players below level 80
"/rankwatch whisper" now has 3 values - all, 80, none
Do not report any rank of Life Tap or Health Funnel
Do not report uses of Flamestrike one rank below the maximum rank
Fix a problem ignoring users from other realms in battlegrounds

Release 1.04
9 December 2009

Ignore events caused by removal of buffs - if a downranked buff is replaced or expires,
  reporting at this time just causes confusion.
If we're buffing someone lower level than us, then the level of the target determines the
  level of the buff which is applied.
Change default repeat interval to 5 minutes and add a command to adjust it
Patch 3.3 - remove ranks of Stealth and Prowl

Release 1.05
19 December 2009

Add Polymorph to the list of rank 1 exceptions
Add an option to send reports to Party/Raid/BG, Say, Whisper, or none (i.e. only in your chat window)

Release 1.06
30 December 2009

The appropriate rank for hots on lower level players is determined by the level of the target.
Avoid "You are not in a Raid" messages when in a battleground

Release 1.07
2 January 2009

Localization (courtesy of Flyhard).
Translations: frFR (Rhaj), deDE (Luntarion, cremor, Flyhard), zhCN and zhTW (andy52005), esES (Igb and LigthSora).
Fix a small bug in reporting settings.
Do not report players below level 80 until their spells are a full level out of date.
Add Thorns to the list of spells determined by the level of the target.
Report uses of obsolete spells when a better replacement is available: Demon Skin, Lesser Heal, Heal, Frost Armor, Rockbiter Weapon, Aspect of the Monkey, Aspect of the Hawk, Abolish Poison
Add Conjure Water, Food, Refreshement to the list of any-rank exceptions.
Detect downranked Rogue poisons.

Release 1.08
6 January 2009

Fix nasty bug in reporting.

Release 1.09
24 January 2009

Don't put a message in local chat when the downranking user is on the ignore list.
Add Power Word: Shield to the list of spells determined by minimum of target level and caster level
Fix times in "/rankwatch report" output
Fix a problem in code designed to prevent double whispers when there are multiple rankwatch users in the group

Release 1.10

When the user levels up, a message will be displayed listing the new spells which are available.
Add Arcane Intellect to the "target level" list.

Release 1.11

Cure Poison is no longer reported - it can be used in conjunction with Abolish Poison for quicker dispels
Drain Soul Rank 1 is no longer reported - it is used to obtain soul shards without killing the target too quickly
Dark Pact rank 1 is no longer reported - it also is used to proc the Glyph of Life Tap
Readme corrected to reflect the WoW bug-fix which enabled whispers in cross-realm dungeons
Add Amplify Magic, Dampen Magic, Power Word: Shield to the list of spells determined by minimum of target level and caster level
Use spell links in chat messages
Add an option to watch only your own spells - /rankwatch self
Russian translation (Thanks, galead!)