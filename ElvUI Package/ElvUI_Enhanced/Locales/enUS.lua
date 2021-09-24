local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "enUS", true)

-- DESC locales
L["ENH_LOGIN_MSG"] = "You are using |cff1784d1ElvUI Enhanced|r |cffff8000(WotLK)|r version %s%s|r."
L["DURABILITY_DESC"] = "Adjust the settings for the durability information on the character screen."
L["ITEMLEVEL_DESC"] = "Adjust the settings for the item level information on the character screen."
L["WATCHFRAME_DESC"] = "Adjust the settings for the visibility of the watchframe (questlog) to your personal preference."

-- Incompatibility
L["GearScore '3.1.20b - Release' is not for WotLK. Download 3.1.7. Disable this version?"] = true

-- AddOn List
L["Enable All"] = true
L["Dependencies: "] = true
L["Disable All"] = true
L["Load AddOn"] = true
L["Requires Reload"] = true

-- Chat
L["Filter DPS meters Spam"] = true
L["Replaces reports from damage meters with a clickable hyperlink to reduce chat spam"] = true

-- Datatext
L["Death Recap Frame"] = true
L["Ammo/Shard Counter"] = true
L["Combat Indicator"] = true
L["Distance"] = true
L["In Combat"] = true
L["New Mail"] = true
L["No Mail"] = true
L["Out of Combat"] = true
L["Reincarnation"] = true
L["Target Range"] = true

-- Death Recap
L["%s %s"] = true
L["%s by %s"] = true
L["%s sec before death at %s%% health."] = true
L["(%d Absorbed)"] = true
L["(%d Blocked)"] = true
L["(%d Overkill)"] = true
L["(%d Resisted)"] = true
L["Death Recap unavailable."] = true
L["Death Recap"] = true
L["Killing blow at %s%% health."] = true
L["You died."] = true

-- Decline Duels
L["Auto decline all duels"] = true
L["Decline Duel"] = true
L["Declined duel request from "] = true

-- Enhanced Character Frame / Paperdoll Backgrounds
L["Character Background"] = true
L["Enhanced Character Frame"] = true
L["Inspect Background"] = true
L["Enhanced Model Frames"] = true
L["Paperdoll Backgrounds"] = true
L["Pet Background"] = true

-- Equipment
L["Damaged Only"] = true
L["Enable/Disable the display of durability information on the character screen."] = true
L["Enable/Disable the display of item levels on the character screen."] = true
L["Only show durabitlity information for items that are damaged."] = true
L["Quality Color"] = true

-- General
L["Add button to Dressing Room frame with ability to undress model."] = true
L["Add button to Trainer frame with ability to train all available skills in one click."] = true
L["Alt-Click Merchant"] = true
L["Already Known"] = true
L["Animated Achievement Bars"] = true
L["Automatically change your watched faction on the reputation bar to the faction you got reputation points for."] = true
L["Automatically release body when killed inside a battleground."] = true
L["Automatically select the quest reward with the highest vendor sell value."] = true
L["Change color of item icons which already known."] = true
L["Changes the transparency of all the movers."] = true
L["Display quest levels at Quest Log."] = true
L["Hide Zone Text"] = true
L["Holding Alt key while buying something from vendor will now buy an entire stack."] = true
L["Mover Transparency"] = true
L["PvP Autorelease"] = true
L["Select Quest Reward"] = true
L["Show Quest Level"] = true
L["Track Reputation"] = true
L["Train All Button"] = true
L["Undress Button"] = true
L["Undress"] = true

-- HD Models Portrait Fix
L["Debug"] = true
L["List of models with broken portrait camera. Separete each model name with ';' simbol"] = true
L["Models to fix"] = true
L["Portrait HD Fix"] = true
L["Print to chat model names of units with enabled 3D portraits."] = true

-- Interrupt Tracker
L["Interrupt Tracker"] = true

-- Nameplates
L["Cache Unit Class"] = true

-- Minimap
L["Above Minimap"] = true
L["Combat Hide"] = true
L["FadeIn Delay"] = true
L["Hide minimap while in combat."] = true
L["Show Location Digits"] = true
L["Toggle Location Digits."] = true
L["Location Digits"] = true
L["Location Panel"] = true
L["Number of digits for map location."] = true
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = true
L["Toggle Location Panel."] = true

-- Timer Tracker
L["Timer Tracker"] = true
L["Hook DBM"] = true

-- Tooltip
L["Check Player"] = true
L["Check achievement completion instead of boss kill stats.\nSome servers log incorrect boss kill statistics, this is an alternative way to get player progress."] = true
L["Colorize the tooltip border based on item quality."] = true
L["Icecrown Citadel"] = true
L["Item Border Color"] = true
L["Progress Info"] = true
L["Ruby Sanctum"] = true
L["Show/Hides an Icon for Achievements on the Tooltip."] = true
L["Show/Hides an Icon for Items on the Tooltip."] = true
L["Show/Hides an Icon for Spells and Items on the Tooltip."] = true
L["Show/Hides an Icon for Spells on the Tooltip."] = true
L["Tiers"] = true
L["Tooltip Icon"] = true
L["Trial of the Crusader"] = true
L["Ulduar"] = true

-- Movers
L["Loss Control"] = true
L["Player Portrait"] = true
L["Target Portrait"] = true

-- Lose Control
L["CC"] = true
L["Disarm"] = true
L["Lose Control"] = true
L["PvE"] = true
L["Root"] = true
L["Silence"] = true
L["Snare"] = true

-- Unitframes
L["Class Icons"] = true
L["Detached Height"] = true
L["Show class icon for units."] = true

-- WatchFrame
L["Hidden"] = true
L["Collapsed"] = true
L["City (Resting)"] = true
L["PvP"] = true
L["Party"] = true
L["Raid"] = true

--
L["Drag"] = true
L["Left-click on character and drag to rotate."] = true
L["Mouse Wheel Down"] = true
L["Mouse Wheel Up"] = true
L["Reset Position"] = true
L["Right-click on character and drag to move it within the window."] = true
L["Rotate Left"] = true
L["Rotate Right"] = true
L["Zoom In"] = true
L["Zoom Out"] = true

--
L["Character Stats"] = true
L["Damage Per Second"] = "DPS"
L["Equipment Manager"] = true
L["Hide Character Information"] = true
L["Hide Pet Information"] = true
L["Item Level"] = true
L["New Set"] = true
L["Resistance"] = true
L["Show Character Information"] = true
L["Show Pet Information"] = true
L["Titles"] = true
L["Total Companions"] = true
L["Total Mounts"] = true

L["ALL"] = "All"
L["ALT_KEY"] = "ALT key"

L["%d mails\nShift-Click to remove empty mails."] = true
L["Addon |cffFFD100%s|r was merged into |cffFFD100ElvUI_Enhanced|r.\nPlease remove it to avoid conflicts."] = true
L["Cache Unit Guilds / NPC Titles"] = true
L["Check Achievements"] = true
L["Collected "] = true
L["Collection completed."] = true
L["Collection stopped, inventory is full."] = true
L["Color based on reaction type."] = true
L["Compact mode"] = true
L["Companion Background"] = true
L["Desaturate"] = true
L["Detached Portrait"] = true
L["Dressing Room"] = true
L["Enhanced"] = true
L["Equipment Info"] = true
L["Error Frame"] = true
L["Everywhere"] = true
L["Fog of War"] = true
L["Grow direction"] = true
L["Guild"] = true
L["Inside Minimap"] = true
L["Key Press Animation"] = true
L["Map"] = true
L["Minimap Button Grabber"] = true
L["NPC"] = true
L["Overlay Color"] = true
L["Reaction Color"] = true
L["Reported by %s"] = true
L["Rotation"] = true
L["Separator"] = true
L["Set the height of Error Frame. Higher frame can show more lines at once."] = true
L["Set the width of Error Frame. Too narrow frame may cause messages to be split in several lines"] = true
L["Show Everywhere"] = true
L["Show on Arena."] = true
L["Show on Battleground."] = true
L["Smooth Animations"] = true
L["Take All"] = true
L["Take All Mail"] = true
L["Take Cash"] = true
L["This addon has been disabled. You should install an updated version."] = true
L["Where to show"] = true
L["seconds"] = true
