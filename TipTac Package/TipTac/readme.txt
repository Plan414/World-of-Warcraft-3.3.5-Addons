TipTac - An Advanced Tooltip Addon
----------------------------------
TipTac is a tooltip enchancement addon, it allows you to configure various aspects of the tooltip, such as moving where it's shown, the font, the scale of tips, plus a lot more.

To open the option dialog, just use "/tip" without any parameters. Use "/tip anchor" to show the anchor frame and position it as you want.

You can always get the latest release of this addon on WoWInterface.com. Please post your comments, questions and suggestions for this addon there.

Current Features
----------------
- Shows the buffs and debuffs of the target with cooldown models. Has options to make it only show the ones you cast.
- When in a raid or party, there is an option to show who from the group is targeting the unit.
- Vast anchoring options allows you to change between Normal, Mouse and Parent anchor, this is configurable for both unit and non-unit tips on a frame or non-frames.
- Anchoring frame lets you decide exactly where you want tips with the normal anchoring option.
- Able to change the font face and size for all tips in the User Interface. Uses "LibSharedMedia" if installed.
- Can show a Health, Mana, Energy, Rage, Runic Power or Focus bar inside the tip, which can be enabled or disabled as you prefer.
- Configurable fading options, both a prefade and fadeout time can be set. They can also be set to zero if you prefer the tips to just hide instantly.
- Allows for you to change the background and border color of the tooltips.

Layout Templates
----------------
Currently TipTac comes with a few presets, these are a collection of preset settings. You can find the presets in the options.
I am looking for more layout presets to include in future releases of TipTac. So feel free to post your saved settings.

Special Tip Modification
------------------------
TipTac does not only configure the tip for units, you can also use TipTac to modify other tips in the WoW Interface.
The way they are getting modified are both in scale and appearance. The border and background of the modified tips can be changed to colors of your desire.
You can disable this appearance change by disabling the option "Hook Special Tips" under the General tab of the options dialog.
Currently these tips are getting modified, but you can add more if you wish by editing the "TipTac\core.lua" file, look for the "TT_TipsToModify" table.
GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, ItemRefTooltip, WorldMapTooltip, AtlasLootTooltip and QuestHelperTooltip.

Other TipTac Addons
-------------------
There are two other addons, included in the TipTac package, which improves tip functionality in WoW.
First one is "TipTacTalents", which will show player talents in the tip.
The second addon is "TipTacItemRef", which improves the look of the ItemRefTooltip, which is the one shown when clicking on an item, spell or achievement link in the chat.
Please refer to each addon's readme.txt file for more information regarding their functionality.

Saving Settings Per Character
-----------------------------
If you prefer to have TipTac configured differently on each of your characters, you will have to manually edit the "TipTac.toc" file.
In this file, you will have to locate "SavedVariables", and change it into "SavedVariablesPerCharacter". You must restart WoW for it to take effect, and it will reset your current settings.

Lacking Features, Ideas & Problems
----------------------------------
- Currently doesn't work well with the Russian client, because it is unable to find the level line using the "TT_LevelMatch" pattern.
  There is a fix here: http://wow.curseforge.com/addons/tip-tac/tickets/3-overachiever-ru-ru-compatibility/
- Sometimes tips may not fade for a mage's mirror images. This happens because GTT:GetUnit() does not return a unit token when you mouse over them.
- Even with the option "Instantly Hide World Frame Tips", some tips still fades out, this is because TipTac uses a "mouse cursor change" event to find out when to instantly hide world tips.
  But since not all world objects change the mouse cursor, you wont see tips fading out instantly for them.
- Change the font of the "GameTooltipMoneyFrame" texts.
- Adding a castbar in addition to the already existing health and power bar.