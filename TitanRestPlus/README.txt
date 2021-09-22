	ADDON  INFORMATION
	Name: TitanRestPlus
	Purpose: Keeps track of the RestXP amounts and status for all of your characters.
	Command-line: /restplus help
	Author: until 2.0.2 GrayElf, 3.0.0. and later by Maillen, 3.0.2 by Vogonjeltz

TitanRestPlus keeps track of the RestXP amounts and status for all of your characters.

TitanRestPlus is a RestXP-displaying Titan plugin that features a compact and customizable display. It has been coded especially to assist players who have characters on more than one server -- for this reason, the display is very compact (allowing more characters to be shown than similar mods can), and it groups and sorts characters by server (with the current server displayed at the top of the list). The list is colorized based on the state of each character's Rest level.

TitanRestPlus saves information about your characters' experience (XP) and rest XP at logout. It uses this information to calculate the amount of rest experience accumulated for any of your characters at any time. This is accomplished using simple arithmetic: Every X hours you get 5% of the experience required to reach your next level, until you hit the cap of 150%. X is 8 hours if you are logged out in a resting state, and 32 if you are not.

The addon alerts you when one of your characters has enough rest XP to last until the end of their current level, and also when one of the characters has reached the rest XP cap.


FEATURES
-- Displays a list of all your characters and their RestXP information.
-- Sorts current server's characters to the top of the list.
-- Groups characters by server (with or without server labels enabled).
-- Colorizes character names so you know which ones are maxed, which can reach the next level, and which cannot.
-- Very compact display allows for more characters than similar addons can show.
-- Can display raw or percentage formats for XP, Rest, and/or the Titan button.
-- Can hide or display Server names, character classes, and/or levels.
-- Level 60 characters are supported by showing a "Maxed Experience" label in the tooltip display.
-- Can toggle the Titan bar display to show the icon, label text, both, or neither.


COMMANDS
/restplus                         = print rest info in chat
/restplus help                    = show command info
/restplus save                    = save current character
/restplus reset                   = delete all saved data
/restplus remove charName realm   = delete one character
/restplus sound                   = toggle sound on/off
/restplus timer                   = toggle timer on/off
/restplus delay n                 = set alert timer to n seconds
/restplus recycle                = reset options to default
/log                             = save current character and log out


VERSION HISTORY
v3.0.2
-- Fixed to show in Titan Panel 4

v3.0.1
-- Minor repair - change file location

v3.0.0
-- Updated for WOTKL and WoW 3.0.x.
-- Updated for 80 lvl

v2.0.2
-- Updated for patch 2.4.x.
-- Added some documentation.

v2.0.0
-- Updated for TBC and WoW 2.0.x.

v11100-1
-- Updated for Patch 1.11.

v10900-1
-- Initial release
