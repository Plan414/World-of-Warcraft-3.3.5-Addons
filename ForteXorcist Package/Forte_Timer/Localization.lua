--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": korean

!! Make sure to keep this saved as UTF-8 format !!

]]

--[[>> still needs translating]]
local FWL = FW.L;

--FWL.CLEARCASTING = FW:SpellName(12536);
--FWL.SUMMON_VALKYR = "Val'kyr Guardian"; -- uncomment to change the name of the val'kyr bars

-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

-- French
if GetLocale() == "frFR" then
	FWL.SPELL_TIMER = "Spell Timer";
	FWL.DISPLAY_MODES = "Display Modes";
	FWL.EXTRA = "Extra";
	FWL.SHOW_HEADER = "Show header";
	FWL.DISPLAY_TYPES = "Display Types";
	FWL.TIMER_HIDING = "Hiding";

	FWL.ST_HINT1 = "Once you have set up the timer, you can lock it and hide its header.";
	FWL.ST_HINT2 = "Right-clicking a debuff icon will fill in that spell in the custom filter field.";
	FWL.ST_HINT3 = "When the timer is locked you will click through it and the automatic hiding will work.";

	FWL.ST_BASIC1_TT = "Visually enable the spell timer.";		
	FWL.ST_BASIC3_TT = "Showing the header can be usefull for setting up the timer, but there's no reason not to hide it. You can still drag the timer from the header spot if the header itself is hidden.";

	FWL.NORMAL_TEXT = "Normal text";
	FWL.NORMAL_TEXT_TT = "The color used for the texts belonging to any non-target/focus unit.";
	FWL.TARGET_TEXT = "Target text";
	FWL.TARGET_TEXT_TT = "The color used for the texts belonging to your target.";
	FWL.FOCUS_TEXT = "Focus text";
	FWL.FOCUS_TEXT_TT = "The color used for the texts belonging to your focus.";
	FWL.COUNTDOWN_TEXT = "Countdown text";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "Label Font";
	FWL.LABEL_FONT_TT = "The font to use for the unit labels in between the bars. (if enabled)";
	FWL.UNIT_SPACING = "Unit spacing";
	FWL.UNIT_SPACING_TT = "The spacing between bar groups belonging to different units. Only applies when grouping by unit.";
	FWL.UNIT_LABEL_HEIGHT = "Unit label height";
	FWL.UNIT_LABEL_HEIGHT_TT = "The height of the unit labels in between the bars. (if enabled)";
	FWL.COUNTDOWN_WIDTH = "Countdown text width";
	FWL.COUNTDOWN_WIDTH_TT = "You can increase the width your countdown text takes up, in case the text doesnt always fit for some reason.";
	FWL.MAXIMIZE_SPACE = "Maximize name space (ugly)";
	FWL.MAXIMIZE_SPACE_TT = "Maximizes the space used for the unit/spell texts. As a result, these texts will no longer be displayed in the exact center of the bars. This can be usefull if you have very short bars.";
	FWL.COUNTDOWN_ON_RIGHT = "Count down on right";
	FWL.COUNTDOWN_ON_RIGHT_TT = "You can display the countdown text on the right or on the left of the timer bars.";
	
	FWL.ONEMAX = "Adapt to one maximum";
	FWL.ONEMAX_TT = "Adapt all bars to one maximum. In other words, all the bars will use the duration of the spell with the longest duration currently on the timer. This may make it easier to time spellcasts.";
	FWL.FORCEMAX = "Force maximum time";
	FWL.FORCEMAX_TT = "Forces the maximum time setting on all bars, even if the longest timer has a shorter duration.";
	FWL.MAXTIME = "Maximum time";
	FWL.MAXTIME_TT = "Maximum time that's displayed on a bar. This option is mostly there for making the 'one maximum' setting more practical.";
	
	FWL.DISPLAY_MODES7 = "Group by unit";
	FWL.DISPLAY_MODES7_TT = "Groups timers belonging to the same units together.";
	FWL.DISPLAY_MODES8 = "Show unit #";
	FWL.DISPLAY_MODES8_TT = "Shows the 'id' number of each unit in front of its name. This way you can distinguish between units with the same name.";
--[[>>]]FWL.DISPLAY_MODES9 = "Show spell names instead";
--[[>>]]FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
--[[>>]]FWL.DISPLAY_MODES10 = "Show name tags/headers";
--[[>>]]FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";

	FWL.DISPLAY_TYPES1 = "Show powerup buffs";
	FWL.DISPLAY_TYPES1_TT = "The timer will also display beneficial powerup buffs.";
	FWL.DISPLAY_TYPES2 = "Show Vulnerability";
	FWL.DISPLAY_TYPES2_TT = "Show vulnerabilities like the Improved Shadowbolt debuff on your target as a powerup.";
	FWL.DISPLAY_TYPES3 = "Hide timers if remaining over";
	FWL.DISPLAY_TYPES3_TT = "Spells that still last longer than this time (seconds) will be hidden from the timer. They will be unhidden again when they get below this time or get removed early. In addition, hidden spells are again shown on your target when you reselect it, so it's still easy to see what spells are up.";
	FWL.DISPLAY_TYPES4 = "Pre-hide display time";
	FWL.DISPLAY_TYPES4_TT = "The time a spell is diplayed before being hidden.";
	FWL.DISPLAY_TYPES5 = "Show failed spells";
	FWL.DISPLAY_TYPES5_TT = "Also show failed spells on the timer (due to resist, immune etc). Very usefull visual aid.";
	FWL.DISPLAY_TYPES6 = "Failed display time";
	FWL.DISPLAY_TYPES6_TT = "The time a spell that failed is diplayed before fading away.";
	FWL.DISPLAY_TYPES7 = "Show harmful spells";
	FWL.DISPLAY_TYPES7_TT = "Show your harmfull spells in the Spell Timer.";
	FWL.DISPLAY_TYPES8 = "Show heals";
	FWL.DISPLAY_TYPES8_TT = "Show your HoTs in the Spell Timer.";
	FWL.DISPLAY_TYPES9 = "Show friendly spells";
	FWL.DISPLAY_TYPES9_TT = "Show your friendly spells in the Spell Timer.";
	FWL.DISPLAY_TYPES10 = "Show pet spells";
	FWL.DISPLAY_TYPES10_TT = "Show your pet's spells in the Spell Timer.";
	FWL.DISPLAY_TYPES11 = "No hiding on bosses";
	FWL.DISPLAY_TYPES11_TT = "Enable this option to keep all your longer spells visible on bosses.";
	
	FWL.FADING1 = "Blink expiring bars";
	FWL.FADING1_TT = "When enabled, bars expiring in X seconds will start to blink. First slow, fast in the end. A nice indication of expiring bars, without changing the actual color.";
	FWL.FADING2 = "Fade out bars";
	FWL.FADING2_TT = "When enabled, your timer bars will smoothly fade out.";
	FWL.FADING3 = "Standard fade delay";
	FWL.FADING3_TT = "The delay before a timer bar that already expired, starts fading out. Also known as 'ghost time'.";
	FWL.FADING4 = "Fade time (animation)";
	FWL.FADING4_TT = "The time it takes for the bars to fade out (speed of the fade out animations).";
	FWL.FADING5 = "Highlight new casts";
	FWL.FADING5_TT = "Newly cast spells will start out bright and change to their normal color in half a second. An extra aid to see where your newly cast spell appeared on the timer.";
	FWL.FADING6 = "Non-target alpha";
	FWL.FADING6_TT = "Timers that do not belong to your target or focus, can be displayed with a different transparency. This makes it very easy to see what unit you have currently selected.";

	FWL.EXTRA1 = "Show Raid Target Icons";
	FWL.EXTRA1_TT = "Show the raid target icon of each unit in the bar background."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "Raid Target Icons Alpha";
	FWL.EXTRA2_TT = "The alpha (transparency) of the raid target icons.";
	FWL.EXTRA3 = "Improve: Use dot ticks";
	FWL.EXTRA3_TT = "When enabled, the timer will watch your combat log for dot damage to help remove bars that no longer apply.";
	FWL.EXTRA4 = "Improve: Use party/raid targets";
	FWL.EXTRA4_TT = "When enabled, the timer will watch party/raid member targets to help remove bars that no longer apply.";
	FWL.EXTRA5 = "Synchronize durations";
	FWL.EXTRA5_TT = "Synchronize spell timer durations to the actual debuff/buff durations of their targets. This is needed for example for debuffs that can reset their duration through other abilities. The addon has never done this before, but currently debuff/buff information seems much more reliable.";
	FWL.EXTRA6 = "Remove mob timers after combat";
	FWL.EXTRA6_TT = "Every time you exit combat the addon will remove remaining timers belonging to NPCs. May be useful to disable this in some cases.";
	
	FWL.HIGHLIGHT = "Highlight new";
	FWL.FAIL = "Fail";
	FWL.MAGIC_DOT = "Magic dot";
	FWL.CURSE = "Curse";
	FWL.BANE = "Bane";
	FWL.CC = "Crowd control";
	FWL.POWERUP_BUFFS = "Powerup buffs";
	FWL.HEAL = "Heal";
	FWL.FRIENDLY_BUFFS = "Friendly buffs";

	FWL.ST_CUSTOMIZE_TT = "Customize each of your spells or buffs.";
	FWL.FAILED_MESSAGE_COLOR = "Failed spell messages";
	FWL.SHOW_FAILED = "Show failed spells";
	FWL.SHOW_FAILED_TT = "Show spells that failed due to resist, immune etc.";

	FWL.SHORT_HIDE = "hide";
	FWL.SHORT_FADE = "fade";
	FWL.SHORT_REMOVED = "remo";
	FWL.SHORT_RESISTED = "resi";
	FWL.SHORT_IMMUNE = "immu";
	FWL.SHORT_EVADED = "evad";
	FWL.SHORT_REFLECTED = "refl";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "Update interval spell timer";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "Delay target debuff check";
	FWL.DELAY_DOT_TICKS_INIT = "Delay dot ticks init";
	FWL.DELAY_DOT_TICKS = "Delay dot ticks";
	
	FWL.TIME_LEFT = "Announce fade time";
	
	FWL.NORMAL_TYPE = "Normal Type";
	FWL.NORMAL_TYPE_TT = "Normal Spell Types";
	FWL.SHARED_TYPE = "Shared Type (1)";
	FWL.SHARED_TYPE_TT = "Types of spells that allow only one spell of this kind up on one target (for example Curses).";
	FWL.OTHER_DEBUFFS = "Raid debuffs";
	FWL.OTHER_DEBUFFS_TT = "This may be important debuffs cast by others, or debuffs that belong to you that aren't triggered directly by spellcasts. These are only shown for your current target.";

	FWL.TICKS = "Show Ticks";
	FWL.TICKS_TT = "Show remaining DoT ticks on the bars.";
	FWL.TICKS_NEXT = "Next Tick only";
	FWL.TICKS_NEXT_TT = "Only show the next Tick on the bars.";
	
	FWL.DRAIN = "Drain";
	FWL.DRAIN_TT = "Show Drain and some other Channeling spells.";
	FWL.CHANNEL = "Channel / Drain";
	FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "Fade";
	FWL.BREAK = "Break";
	FWL.RESIST = "Resist";
	
	FWL.TICKS_COLOR = "Tick color";
	FWL.TICKS_COLOR_TT = "Set the tick colors to any color you like.";
	
	FWL.TIMER_OUTWARDS = "Highest timers outwards";
	FWL.TIMER_OUTWARDS_TT = "Bars will be sorted with the longest remaining times the furthest from the spell timer header/anchor.";
	FWL.TEST_BARS = "Enable Test Bars";
	FWL.TEST_BARS_TT = "Enable Test Bars. This option makes it easier to configure the timer without having to cast on units. You still need to select units to test target/focus settings, but this can also be yourself.";

	FWL.CAST_GLOW = "Show cast time Glow";
	FWL.CAST_GLOW_TT = "The timer bars indicate the time it will take to cast this spell or how long global cooldown would take up after the cast. This makes it much easier to time spell casts.";

	FWL.CUSTOM_TAG = "Custom tag";
	FWL.CUSTOM_TAG_TT = "Use your own customized tag for the spell timer bars.\n|cff00ff00id|r is replaced by the target's id (if any).\n|cff00ff00target|r is replaced by the target unit name (if any).\n|cff00ff00spell|r is replaced by the spell name.\n|cff00ff00stacks|r is replaced by the number of stacks of the buff/debuff (if any).";

	FWL.UNIQUE_TYPE = "Unique Type";
	FWL.UNIQUE_TYPE_TT = "Types of spells that can only be cast on one target at a time. For example most crowd control spells.";
	
	FWL.BAR_BG_ALPHA = "Empty bar alpha";
	FWL.BAR_BG_ALPHA_TT = "The alpha the 'empty' part of a timer bar will have.";
	FWL.TIMER_FORMATS = "Additional layout";
	FWL.TIMER_UNITS = "Units";
	FWL.TIMER_MAXIMUM_TIME = "Maximum Time and Hiding";
	FWL.TIMER_TICKS = "Ticks";
	FWL.TIMER_RAID_TARGET_ICONS = "Raid Target Icons";

	FWL.TIMER_SHOW_TARGET = "Show target unit";
	FWL.TIMER_SHOW_TARGET_TT = "Show the bars belonging to your current target in this timer frame instance.";
	FWL.TIMER_SHOW_FOCUS = "Show focus unit";
	FWL.TIMER_SHOW_FOCUS_TT = "Show the bars belonging to your current focus in this timer frame instance.";
	FWL.TIMER_SHOW_OTHER = "Show other units";
	FWL.TIMER_SHOW_OTHER_TT = "Show the bars belonging to all other units in this timer frame instance.";

	FWL.COOLDOWNS = "Cooldowns";
	FWL.COOLDOWNS_TT = "Show a small selection of cooldowns.";
	FWL.DEBUFFS = "Debuffs on me";
	FWL.DEBUFFS_TT = "Show a small selection of debuffs on yourself.";

	FWL.TARGET_BACKGROUND = "Target background";
	FWL.FOCUS_BACKGROUND = "Focus background";

	FWL.EXPIRED = "Expired";
	FWL.EXPIRED_TT = "Enable to make expired bars take a different color.";

	FWL._RIGHTCLICK_FOR_OPTIONS = " (right-click for options)"

	FWL.CLONES_WORKING = "CLONES AREN'T FULLY WORKING. YOU CANNOT CHANGE WHAT IS DISPLAYED IN THEM YET.";

	FWL.SHOW_WITHOUT_UNIT = "Show without target";
	FWL.TIMER_SORT_ORDER = "Spell Type sort order";
	FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

	FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";
	
	FWL.SHARED_TYPE2 = "Shared Type (2)";
	FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

	FWL.SHARED_TYPE3 = "Shared Type (3)";
	FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

	FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
	FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
	FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

	FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
	FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

	FWL.TIMER_SMOOTHING = "Duration update smoothing";
	FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

	FWL.TIMER_COUNTDOWN = "Show Count down text";
	FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

	FWL.TIMER_ICONS = "Show icons";
	FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
	FWL.TIMER_ICONS_RIGHT = "Icons on right";
	FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

	FWL.TIMER_STACKS = "Show stacks on icons";
	FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
	FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
	FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

	FWL.LABEL_LIMIT = "Limit name tag size";
	FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
	FWL.SPARK_TICK = "Spark tick indication";
	FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
	FWL.CAST_OVERLAP = "Include tick overlap";
	FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

	FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
	FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
	FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
	FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";
	
	FWL.FLIP_TAG = "Flip tag location";
	FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
	FWL.NAMING_GROUPING = "Naming and Grouping";
	
	FWL.CAST_GCD = "Include Global Cooldown";
	FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- Russian
elseif GetLocale() == "ruRU" then

	FWL.SPELL_TIMER = "Таймер заклинаний";
	FWL.DISPLAY_MODES = "Режимы отображения";
	FWL.EXTRA = "Дополнительно";
	FWL.SHOW_HEADER = "Показывать заголовок";
--[[>>]]FWL.DISPLAY_TYPES = "Display Types";
--[[>>]]FWL.TIMER_HIDING = "Hiding";

	FWL.ST_HINT1 = "После настройки таймера, вы можете заблокировать его и скрыть его заголовок.";
--[[>>]]FWL.ST_HINT2 = "Right-clicking a debuff icon will fill in that spell in the custom filter field.";
--[[>>]]FWL.ST_HINT3 = "When the timer is locked you will click through it and the automatic hiding will work.";

	FWL.ST_BASIC1_TT = "Разрешить отображения таймера заклинаний.";		
	FWL.ST_BASIC3_TT = "Отображение заголовка может быть полезно при настройке таймера, но нет никакой причиные не скрыть его. вы все равно можете перетянуть таймер из места заголовка, даже если сам заголовок скрыт.";

	FWL.NORMAL_TEXT = "Обычный текст";
	FWL.NORMAL_TEXT_TT = "Цвет, используемый для текстов, соответствующих любому элементу, не являющемуся целью или фокусом.";
	FWL.TARGET_TEXT = "Текст цели";
	FWL.TARGET_TEXT_TT = "Цвет, использумый для текстов, относящихся к вашей цели.";
	FWL.FOCUS_TEXT = "Текст фокуса";
	FWL.FOCUS_TEXT_TT = "Цвет, используемый для текстов, относящихся к вашему фокусу.";
	FWL.COUNTDOWN_TEXT = "Текст кулдаунов";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "Шрифт меток";
	FWL.LABEL_FONT_TT = "Шрифт, используемый для меток элементов между панелями (если включено)";
	FWL.UNIT_SPACING = "Отступ элементов";
	FWL.UNIT_SPACING_TT = "Отступ между группами панелей, принадлежащих к разным элементам. ТОлько применимо, когда производится группировка по номеру элемента.";
	FWL.UNIT_LABEL_HEIGHT = "Высота метки элемента";
	FWL.UNIT_LABEL_HEIGHT_TT = "Высота метки элемента между панелями (если включено)";
	FWL.COUNTDOWN_WIDTH = "Ширина текста обратного отсчета";
	FWL.COUNTDOWN_WIDTH_TT = "Вы можете увеличить ширину текста обратного отсчета, если он не помещается по какой-либо причине.";
	FWL.MAXIMIZE_SPACE = "Увеличить размер пространства имен (некрасиво)";
	FWL.MAXIMIZE_SPACE_TT = "Увеличивает размер, используемый для имен элементов/заклинаний. Как результат, эти тексты не будут отображаться в середине панелей. Может быть полезно при использовании очень коротких панелей.";
	FWL.COUNTDOWN_ON_RIGHT = "Обратный отсчет справа";
	FWL.COUNTDOWN_ON_RIGHT_TT = "Вы можете отображать текст обратного отсчета справа или слева панелей таймеров.";
	
	FWL.ONEMAX = "Привести к максимальной";
--[[>>]]FWL.ONEMAX_TT = "Привести размер всех панелей к максимальной. In other words, all the bars will use the duration of the spell with the longest duration currently on the timer. Это поможет легче отслеживать время чтения заклинаний.";
--[[>>]]FWL.FORCEMAX = "Force maximum time";
--[[>>]]FWL.FORCEMAX_TT = "Forces the maximum time setting on all bars, even if the longest timer has a shorter duration.";
	FWL.MAXTIME = "Максимальное время";
	FWL.MAXTIME_TT = "Максимальное время, отображаемое на панели. Эта опция предназначена в основном, для повышения практичности настройки 'привести к максимальной'.";

	FWL.DISPLAY_MODES7 = "Группировать по номеру элемента";
	FWL.DISPLAY_MODES7_TT = "Группирует таймеры, относящиеся к одним и тем же элементам.";
	FWL.DISPLAY_MODES8 = "Показывать номер элемента";
	FWL.DISPLAY_MODES8_TT = "Показывает идентификатор каждого элемента перед его именем. Это позволит отделять элементы с одинаковыми именами.";
--[[>>]]FWL.DISPLAY_MODES9 = "Show spell names instead";
--[[>>]]FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
--[[>>]]FWL.DISPLAY_MODES10 = "Show name tags/headers";
--[[>>]]FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";

	FWL.DISPLAY_TYPES1 = "Показывать приобретенные баффы";
	FWL.DISPLAY_TYPES1_TT = "Таймер также будет показывать положительные приобретенные баффы.";
	FWL.DISPLAY_TYPES2 = "Показывать уязвимость";
	FWL.DISPLAY_TYPES2_TT = "Показывать уязвимости, такие как дебафф Улучшенной Стрелы тьмы на вашей цели, как приобретение.";
--[[>>]]FWL.DISPLAY_TYPES3 = "Hide timers if remaining over";
--[[>>]]FWL.DISPLAY_TYPES3_TT = "Spells that still last longer than this time (seconds) will be hidden from the timer. They will be unhidden again when they get below this time or get removed early. In addition, hidden spells are again shown on your target when you reselect it, so it's still easy to see what spells are up.";
--[[>>]]FWL.DISPLAY_TYPES4 = "Pre-hide display time";
--[[>>]]FWL.DISPLAY_TYPES4_TT = "The time a spell is diplayed before being hidden.";
	FWL.DISPLAY_TYPES5 = "Показывать неудачные заклинания";
	FWL.DISPLAY_TYPES5_TT = "Также показывать неудачные заклинания на таймере (сопротивление, неуязвимость итд). Очень помогает.";
	FWL.DISPLAY_TYPES6 = "Время отображения неудачных";
	FWL.DISPLAY_TYPES6_TT = "Время, которое неудачное заклинание отображается до исчезновения.";
--[[>>]]FWL.DISPLAY_TYPES7 = "Show harmfull spells";
--[[>>]]FWL.DISPLAY_TYPES7_TT = "Show your harmful spells in the Spell Timer.";
--[[>>]]FWL.DISPLAY_TYPES8 = "Show heals";
--[[>>]]FWL.DISPLAY_TYPES8_TT = "Show your HoTs in the Spell Timer.";
--[[>>]]FWL.DISPLAY_TYPES9 = "Show friendly spells";
--[[>>]]FWL.DISPLAY_TYPES9_TT = "Show your friendly spells in the Spell Timer.";
--[[>>]]FWL.DISPLAY_TYPES10 = "Show pet spells";
--[[>>]]FWL.DISPLAY_TYPES10_TT = "Show your pet's spells in the Spell Timer.";
--[[>>]]FWL.DISPLAY_TYPES11 = "No hiding on bosses";
--[[>>]]FWL.DISPLAY_TYPES11_TT = "Enable this option to keep all your longer spells visible on bosses.";

	FWL.FADING1 = "Мигать истекающими панелями";
	FWL.FADING1_TT = "Когда включено, панели истекающие через X секунды, начнут мигать. Медленно сначала, быстро в конце. Хороший показатель для истекающих панелей без смены их цвета.";
	FWL.FADING2 = "Затухание панелей";
	FWL.FADING2_TT = "Когда включено, панели буду плавно затухать.";
	FWL.FADING3 = "Стандартная задержка затухания";
	FWL.FADING3_TT = "Задержка после истечения панели таймера, до момента начала затухания. Также известна как 'призрачное время'.";
	FWL.FADING4 = "Время затухания";
	FWL.FADING4_TT = "Время, которое требуется панелям, чтобы пропасть.";
	FWL.FADING5 = "Подсвечивать новые заклинания";
	FWL.FADING5_TT = "Недавно прочинтанные заклинания будут ярче и будут менять свой цвет примерно за полсекунды. Дополнительная помощь при отслеживании новых заклинаний на таймере.";
	FWL.FADING6 = "Прозрачность не-цели";
	FWL.FADING6_TT = "Таймеры, которые не принадлежает в вашей текущей цели или фокусу, будут отображаться с другой прозрачностью. Это делает очень простым видеть, какой элемент выбран в данный момент.";

	FWL.EXTRA1 = "Показывать значки рейдовых целей";
	FWL.EXTRA1_TT = "Показывать значки рейдовых целей каждого элемента на фоне панелей."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "Прозрачность значков рейдовых целей";
	FWL.EXTRA2_TT = "Прозрачность значков рейдовых целей.";
	FWL.EXTRA3 = "Улучшение: показывать тики дотов";
	FWL.EXTRA3_TT = "Когда включено, таймер будет отслеживать периодический урон по истории боя (combat log), чтоб поможет убрирать неактивные панели.";
	FWL.EXTRA4 = "Улучшение: Использовать цели группы/рейда";
	FWL.EXTRA4_TT = "Когда включено, таймер будет отслеживать цели партии/рейда для убирания неактивных панелей.";
--[[>>]]FWL.EXTRA5 = "Synchronize durations";
--[[>>]]FWL.EXTRA5_TT = "Synchronize spell timer durations to the actual debuff/buff durations of their targets. This is needed for example for debuffs that can reset their duration through other abilities. The addon has never done this before, but currently debuff/buff information seems much more reliable.";
--[[>>]]FWL.EXTRA6 = "Remove mob timers after combat";
--[[>>]]FWL.EXTRA6_TT = "Every time you exit combat the addon will remove remaining timers belonging to NPCs. May be useful to disable this in some cases.";
	
	FWL.HIGHLIGHT = "Выделение";
	FWL.FAIL = "Неудача";
	FWL.MAGIC_DOT = "Магический дот";
	FWL.CURSE = "Проклятье";
--[[>>]]FWL.BANE = "Bane";
	FWL.CC = "Контроль толпы";
	FWL.POWERUP_BUFFS = "Положительный бафф";
	FWL.HEAL = "Лечение";
	FWL.FRIENDLY_BUFFS = "Дружеский бафф";

	FWL.ST_CUSTOMIZE_TT = "Настроить каждый из ваших спеллов или баффов.";
	FWL.FAILED_MESSAGE_COLOR = "Сообщения о неудачных заклинаниях";
	FWL.SHOW_FAILED = "Показывать неудачные заклинания";
	FWL.SHOW_FAILED_TT = "Показывать заклинания, неудавшиеся из-за сопротивления, неуязвимости итд.";

	FWL.SHORT_HIDE = "скрыто";
	FWL.SHORT_FADE = "затух";
	FWL.SHORT_REMOVED = "снято";
	FWL.SHORT_RESISTED = "сопр";
	FWL.SHORT_IMMUNE = "неуязв";
	FWL.SHORT_EVADED = "мимо";
	FWL.SHORT_REFLECTED = "отраж";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "Интервал обновления таймера заклинаний";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "Задержка проверки дебаффов цели";
	FWL.DELAY_DOT_TICKS_INIT = "Задержка инициализации тиков дотов";
	FWL.DELAY_DOT_TICKS = "Задержка тиков дотов";
	
--[[>>]]FWL.TIME_LEFT = "Announce fade time";

--[[>>]]FWL.NORMAL_TYPE = "Normal Type";
--[[>>]]FWL.NORMAL_TYPE_TT = "Normal Spell Types";
--[[>>]]FWL.SHARED_TYPE = "Shared Type (1)";
--[[>>]]FWL.SHARED_TYPE_TT = "Types of spells that allow only one spell of this kind up on one target (for example Curses).";
--[[>>]]FWL.OTHER_DEBUFFS = "Other Debuffs";
--[[>>]]FWL.OTHER_DEBUFFS_TT = "This may be important debuffs cast by others, or debuffs that belong to you that aren't triggered directly by spellcasts. These are only shown for your current target.";
--[[>>]]FWL.CC_TT = "Crowd control or silencing spells";

--[[>>]]FWL.TICKS = "Show Ticks";
--[[>>]]FWL.TICKS_TT = "Show remaining DoT ticks on the bars.";
--[[>>]]FWL.TICKS_NEXT = "Next Tick only";
--[[>>]]FWL.TICKS_NEXT_TT = "Only show the next Tick on the bars.";
	
--[[>>]]FWL.DRAIN = "Drain";
--[[>>]]FWL.DRAIN_TT = "Show Drain spells that benefit from haste";
--[[>>]]FWL.CHANNEL = "Channel / Drain";
--[[>>]]FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";

--[[>>]]FWL.FADE = "Fade";
--[[>>]]FWL.BREAK = "Break";
--[[>>]]FWL.RESIST = "Resist";

--[[>>]]FWL.TICKS_COLOR = "Tick Color";
--[[>>]]FWL.TICKS_COLOR_TT = "Set the tick colors to any color you like.";

--[[>>]]FWL.TIMER_OUTWARDS = "Highest timers outwards";
--[[>>]]FWL.TIMER_OUTWARDS_TT = "Bars will be sorted with the longest remaining times the furthest from the spell timer header/anchor.";
--[[>>]]FWL.TEST_BARS = "Enable Test Bars";
--[[>>]]FWL.TEST_BARS_TT = "Enable Test Bars. This option makes it easier to configure the timer without having to cast on units. You still need to select units to test target/focus settings, but this can also be yourself.";


--[[>>]]FWL.CAST_GLOW = "Show cast time Glow";
--[[>>]]FWL.CAST_GLOW_TT = "The timer bars indicate the time it will take to cast this spell or how long global cooldown would take up after the cast. This makes it much easier to time spell casts.";

--[[>>]]FWL.CUSTOM_TAG = "Custom tag";
--[[>>]]FWL.CUSTOM_TAG_TT = "Use your own customized tag for the spell timer bars.\n|cff00ff00id|r is replaced by the target's id (if any).\n|cff00ff00target|r is replaced by the target unit name (if any).\n|cff00ff00spell|r is replaced by the spell name.\n|cff00ff00stacks|r is replaced by the number of stacks of the buff/debuff (if any).";

--[[>>]]FWL.UNIQUE_TYPE = "Unique Type";
--[[>>]]FWL.UNIQUE_TYPE_TT = "Types of spells that can only be cast on one target at a time. For example most crowd control spells.";
	
--[[>>]]FWL.BAR_BG_ALPHA = "Empty bar alpha";
--[[>>]]FWL.BAR_BG_ALPHA_TT = "The alpha the 'empty' part of a timer bar will have.";
--[[>>]]FWL.TIMER_FORMATS = "Additional layout";
--[[>>]]FWL.TIMER_UNITS = "Units";
--[[>>]]FWL.TIMER_MAXIMUM_TIME = "Maximum time";
--[[>>]]FWL.TIMER_TICKS = "Ticks";
--[[>>]]FWL.TIMER_RAID_TARGET_ICONS = "Raid Target Icons";

--[[>>]]FWL.TIMER_SHOW_TARGET = "Show target unit";
--[[>>]]FWL.TIMER_SHOW_TARGET_TT = "Show the bars belonging to your current target in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_FOCUS = "Show focus unit";
--[[>>]]FWL.TIMER_SHOW_FOCUS_TT = "Show the bars belonging to your current focus in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_OTHER = "Show other units";
--[[>>]]FWL.TIMER_SHOW_OTHER_TT = "Show the bars belonging to all other units in this timer frame instance.";

--[[>>]]FWL.COOLDOWNS = "Cooldowns";
--[[>>]]FWL.COOLDOWNS_TT = "Show a small selection of cooldowns.";
--[[>>]]FWL.DEBUFFS = "Debuffs on me";
--[[>>]]FWL.DEBUFFS_TT = "Show a small selection of debuffs on yourself.";

--[[>>]]FWL.TARGET_BACKGROUND = "Target background";
--[[>>]]FWL.FOCUS_BACKGROUND = "Focus background";

--[[>>]]FWL.EXPIRED = "Expired";
--[[>>]]FWL.EXPIRED_TT = "Enable to make expired bars take a different color.";

--[[>>]]FWL._RIGHTCLICK_FOR_OPTIONS = " (right-click for options)"

--[[>>]]FWL.CLONES_WORKING = "CLONES AREN'T FULLY WORKING. YOU CANNOT CHANGE WHAT IS DISPLAYED IN THEM YET.";
--[[>>]]FWL.SHOW_WITHOUT_UNIT = "Show without target";
--[[>>]]FWL.TIMER_SORT_ORDER = "Spell Type sort order";
--[[>>]]FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

--[[>>]]FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";
	
--[[>>]]FWL.SHARED_TYPE2 = "Shared Type (2)";
--[[>>]]FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

--[[>>]]FWL.SHARED_TYPE3 = "Shared Type (3)";
--[[>>]]FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

--[[>>]]FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
--[[>>]]FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
--[[>>]]FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

--[[>>]]FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
--[[>>]]FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

--[[>>]]FWL.TIMER_SMOOTHING = "Duration update smoothing";
--[[>>]]FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

--[[>>]]FWL.TIMER_COUNTDOWN = "Show Count down text";
--[[>>]]FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

--[[>>]]FWL.TIMER_ICONS = "Show icons";
--[[>>]]FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
--[[>>]]FWL.TIMER_ICONS_RIGHT = "Icons on right";
--[[>>]]FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

--[[>>]]FWL.TIMER_STACKS = "Show stacks on icons";
--[[>>]]FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
--[[>>]]FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
--[[>>]]FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

--[[>>]]FWL.LABEL_LIMIT = "Limit name tag size";
--[[>>]]FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
--[[>>]]FWL.SPARK_TICK = "Spark tick indication";
--[[>>]]FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
--[[>>]]FWL.CAST_OVERLAP = "Include tick overlap";
--[[>>]]FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

--[[>>]]FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
--[[>>]]FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
--[[>>]]FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
--[[>>]]FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";

--[[>>]]FWL.FLIP_TAG = "Flip tag location";
--[[>>]]FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
--[[>>]]FWL.NAMING_GROUPING = "Naming and Grouping";
	
--[[>>]]FWL.CAST_GCD = "Include Global Cooldown";
--[[>>]]FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- simple chinese
elseif GetLocale() == "zhCN" then

	FWL.SPELL_TIMER = "法术计时条";
	FWL.DISPLAY_MODES = "显示模式";
	FWL.EXTRA = "扩展";
	FWL.SHOW_HEADER = "显示标题栏";
	FWL.DISPLAY_TYPES = "显示类型";
	FWL.TIMER_HIDING = "隐藏";

	FWL.ST_HINT1 = "设置好计时条后可以锁定并隐藏标题栏.";
	FWL.ST_HINT2 = "右键单击debuff图标过滤.";
--[[>>]]FWL.ST_HINT3 = "计时条锁定时点击穿过.";

	FWL.ST_BASIC1_TT = "计时条可视.";		
	FWL.ST_BASIC3_TT = "显示标题栏对设置计时条很有帮助,但最好还是隐藏了它,它隐藏后依然能够通过拖拽它移动计时条.";

	FWL.NORMAL_TEXT = "一般文字";
	FWL.NORMAL_TEXT_TT = "任何非目标/焦点的目标的计时文字颜色.";
	FWL.TARGET_TEXT = "目标文字";
	FWL.TARGET_TEXT_TT = "你目标的计时文字颜色.";
	FWL.FOCUS_TEXT = "焦点文字";
	FWL.FOCUS_TEXT_TT = "你焦点的计时文字颜色.";
	FWL.COUNTDOWN_TEXT = "冷却文字";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "标签字体";
	FWL.LABEL_FONT_TT = "对象标签的字体. (当开启按对象分类时)";
	FWL.UNIT_SPACING = "对象间距";
	FWL.UNIT_SPACING_TT = "不同对象计时条之间的间距. 只有当设定按对象分类计时条才有效.";
	FWL.UNIT_LABEL_HEIGHT = "对象标签高度";
	FWL.UNIT_LABEL_HEIGHT_TT = "对象标签的高度. (当开启按对象分类时)";
	FWL.COUNTDOWN_WIDTH = "计时文字宽度";
	FWL.COUNTDOWN_WIDTH_TT = "你可以增加计时文字的宽度, 因为有时候计时文字可能显示不完全.";
	FWL.MAXIMIZE_SPACE = "最大名字空间(丑)";
	FWL.MAXIMIZE_SPACE_TT = "对象/法术的空间最大化. 结果是这些文字将不会在计时条中间显示. 当你把计时条设置非常短时有所帮助.";
	FWL.COUNTDOWN_ON_RIGHT = "右侧显示计时";
	FWL.COUNTDOWN_ON_RIGHT_TT = "在计时条左侧或右侧显示计时.";

	FWL.ONEMAX = "统一上限时间";
	FWL.ONEMAX_TT = "所有的计时条都统一计时上限，就是所有的计时条的显示计时上限都统一为当前的最大计时时间，这样更容易看出施法计时.";
	FWL.FORCEMAX = "强制上限时间";
	FWL.FORCEMAX_TT = "所有的计时条都强制最大计时上限，哪怕计时上限长于最大的计时时间.";
	FWL.MAXTIME = "上限时间";
	FWL.MAXTIME_TT = "计时条显示的上限时间.";
	
	FWL.DISPLAY_MODES7 = "按对象号分类";
	FWL.DISPLAY_MODES7_TT = "将一个对象的计时条排在一起显示.";
	FWL.DISPLAY_MODES8 = "显示对象号";
	FWL.DISPLAY_MODES8_TT = "在每个对象名字前显示其编号. 有助于分辨出同名对象.";
--[[>>]]FWL.DISPLAY_MODES9 = "Show spell names instead";
--[[>>]]FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
--[[>>]]FWL.DISPLAY_MODES10 = "Show name tags/headers";
--[[>>]]FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";

	FWL.DISPLAY_TYPES1  = "显示增强buffs";
	FWL.DISPLAY_TYPES1_TT = "计时条显示增益buff.";
	FWL.DISPLAY_TYPES2 = "显示暗影易伤";
	FWL.DISPLAY_TYPES2_TT = "显示目标身上的类似暗影易伤的debuff作为自己的增强buff.";
	FWL.DISPLAY_TYPES3 = "计时阀值";
	FWL.DISPLAY_TYPES3_TT = "法术剩余时间比这个时间长的时候不显示法术，当这些法术持续时间低于这个时间或者提前被移除时将会再次显示，此外，被隐藏的法术在你重选定它时会显示在你的目标上，因此你可以很容易看到有哪些法术存在，设置0则禁用.";
	FWL.DISPLAY_TYPES4 = "隐藏前显示时间";
	FWL.DISPLAY_TYPES4_TT = "法术隐藏前的显示时间.";
	FWL.DISPLAY_TYPES5 = "显示失败法术";
	FWL.DISPLAY_TYPES5_TT = "失败法术仍在计时条显示 (例如抵抗,免疫之类). 很有用.";
	FWL.DISPLAY_TYPES6 = "失败法术显示时间";
	FWL.DISPLAY_TYPES6_TT = "失败法术在计时条上显示时间.";
	
	FWL.DISPLAY_TYPES7 = "显示伤害法术";
	FWL.DISPLAY_TYPES7_TT = "计时条中显示你的伤害法术.";
	FWL.DISPLAY_TYPES8 = "显示治疗";
	FWL.DISPLAY_TYPES8_TT = "计时条中显示你的HoTs.";
	FWL.DISPLAY_TYPES9 = "显示友善法术";
	FWL.DISPLAY_TYPES9_TT = "计时条显示你的友善法术.";
	FWL.DISPLAY_TYPES10 = "显示Pet法术";
	FWL.DISPLAY_TYPES10_TT = "计时条显示你的Pet法术.";
	FWL.DISPLAY_TYPES11 = "boss战全显示";
	FWL.DISPLAY_TYPES11_TT = "启用这个选项，boss战的时候显示所有长计时法术";

	FWL.FADING1 = "法术结束前闪烁";
	FWL.FADING1_TT = "启动此选项,计时条结束3秒前闪烁.先慢后快. 颜色不变";
	FWL.FADING2 = "计时条渐隐";
	FWL.FADING2_TT = "开启后计时条平滑消失.";
	FWL.FADING3 = "渐隐消失时间";
	FWL.FADING3_TT = "计时结束,计时条渐隐持续时间";
	FWL.FADING4 = "渐隐时间";
	FWL.FADING4_TT = "计时条渐隐需用时间.";
	FWL.FADING5 = "高亮新释放法术";
	FWL.FADING5_TT = "新释放法术将高亮显示,目的是为了分辨新释放法术.";
	FWL.FADING6 = "没有目标时的透明度";
	FWL.FADING6_TT = "当计时条显示的不是你的目标或者焦点时,可以设置不同的透明度. 很容易分辨出自己的目标.";

	FWL.EXTRA1 = "显示团队图标";
	FWL.EXTRA1_TT = "在对象计时条背景上显示团队图标."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "团队图标透明度";
	FWL.EXTRA2_TT = "团队图标透明度.";
	FWL.EXTRA3 = "DOT判读";
	FWL.EXTRA3_TT = "启动此功能,计时条将查看你的战斗记录DOT伤害,来判读移除失效计时条.";
	FWL.EXTRA4 = "队友判读";
	FWL.EXTRA4_TT = "启动此功能,计时条将查看你队友的目标,来帮助判读移除失效计时条.";
	FWL.EXTRA5 = "计时同步";
	FWL.EXTRA5_TT = "将法术计时和其对目标造成的buff/debuff计时同步，需要设置样本技能.";
	FWL.EXTRA6 = "战斗结束后移除计时条";
	FWL.EXTRA6_TT = "每次离开战斗将NPC的计时条移除，也许有用吧.";

	
	FWL.HIGHLIGHT = "高亮";
	FWL.FAIL = "失败";
	FWL.MAGIC_DOT = "DOT";
	FWL.CURSE = "诅咒";
--[[>>]]FWL.BANE = "Bane";
	FWL.CC = "控制";
	FWL.POWERUP_BUFFS = "增强buffs";
	FWL.HEAL = "治疗";
	FWL.FRIENDLY_BUFFS = "友善buffs";

	FWL.ST_CUSTOMIZE_TT = "自定义计时法术/buffs."
	FWL.FAILED_MESSAGE_COLOR = "失败法术信息";
	FWL.SHOW_FAILED = "显示失败法术";
	FWL.SHOW_FAILED_TT = "显示由于抵抗,免疫等释放失败的法术.";

	FWL.SHORT_HIDE = "隐藏";
	FWL.SHORT_FADE = "消失";
	FWL.SHORT_REMOVED = "移除";
	FWL.SHORT_RESISTED = "抵抗";
	FWL.SHORT_IMMUNE = "免疫";
	FWL.SHORT_EVADED = "闪避";
	FWL.SHORT_REFLECTED = "反射";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "计时条更新间隔";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "目标debuff检查延迟";
	FWL.DELAY_DOT_TICKS_INIT = "DOT初始化延迟";
	FWL.DELAY_DOT_TICKS = "DoT延迟";
	
	FWL.TIME_LEFT = "显示法术剩余时间";
	
	FWL.NORMAL_TYPE = "普通";
	FWL.NORMAL_TYPE_TT = "普通模式";
	FWL.SHARED_TYPE = "公用模式";
	FWL.SHARED_TYPE_TT = "每种法术类型只显示一个计时条.";
	FWL.OTHER_DEBUFFS = "其他 Debuffs";
	FWL.OTHER_DEBUFFS_TT = "他人的重要debuff，或者不是由你的法术直接触发的debuff，只对当前目标有效.";
	FWL.CC_TT = "控制或沉默法术";
	
	FWL.TICKS = "显示DoT跳数";
	FWL.TICKS_TT = "显示DoT剩余跳数.";
	FWL.TICKS_NEXT = "显示下一跳";
	FWL.TICKS_NEXT_TT = "只显示计时条的的下一跳.";
	
	FWL.DRAIN = "吸取法术";
	FWL.DRAIN_TT = "显示受到急速效果加成的吸取法术";
--[[>>]]FWL.CHANNEL = "Channel / Drain";
--[[>>]]FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "消退";
	FWL.BREAK = "打断";
	FWL.RESIST = "抵抗";

	FWL.TICKS_COLOR = "跳数颜色";
	FWL.TICKS_COLOR_TT = "设置跳数颜色.";
	
	FWL.TIMER_OUTWARDS = "最长持续时间";
	FWL.TIMER_OUTWARDS_TT = "计时条记录最长的法术持续时间.";
	FWL.TEST_BARS = "启用测试计时条";
	FWL.TEST_BARS_TT = "测试计时条.";
	
	FWL.CAST_GLOW = "施法时间发光";
--[[>>]]FWL.CAST_GLOW_TT = "计时条显示该法术施放的准备时间或者是施放后的公共CD，帮助计算施法时间，公共CD只有启用'"..FWL.ONEMAX.."' 和冷却计时条时显示.";

	FWL.CUSTOM_TAG = "自定义标签";
	FWL.CUSTOM_TAG_TT = "使用自定义计时条标签.\n|cff00ff00id|r 替换目标id.\n|cff00ff00目标名|r 替换目标名字.\n|cff00ff00法术名|r 替换法术名字.\n|cff00ff00跳数|r 替换buff/debuff的跳数.";

	FWL.UNIQUE_TYPE = "单独类型";
	FWL.UNIQUE_TYPE_TT = "只能在同一时间对一个目标使用的法术. 比如大多数控制技能.";

--[[>>]]FWL.BAR_BG_ALPHA = "Empty bar alpha";
--[[>>]]FWL.BAR_BG_ALPHA_TT = "The alpha the 'empty' part of a timer bar will have.";
--[[>>]]FWL.TIMER_FORMATS = "Additional layout";
--[[>>]]FWL.TIMER_UNITS = "Units";
--[[>>]]FWL.TIMER_MAXIMUM_TIME = "Maximum time";
--[[>>]]FWL.TIMER_TICKS = "Ticks";
--[[>>]]FWL.TIMER_RAID_TARGET_ICONS = "Raid Target Icons";

--[[>>]]FWL.TIMER_SHOW_TARGET = "Show target unit";
--[[>>]]FWL.TIMER_SHOW_TARGET_TT = "Show the bars belonging to your current target in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_FOCUS = "Show focus unit";
--[[>>]]FWL.TIMER_SHOW_FOCUS_TT = "Show the bars belonging to your current focus in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_OTHER = "Show other units";
--[[>>]]FWL.TIMER_SHOW_OTHER_TT = "Show the bars belonging to all other units in this timer frame instance.";

--[[>>]]FWL.COOLDOWNS = "Cooldowns";
--[[>>]]FWL.COOLDOWNS_TT = "Show a small selection of cooldowns.";
--[[>>]]FWL.DEBUFFS = "Debuffs on me";
--[[>>]]FWL.DEBUFFS_TT = "Show a small selection of debuffs on yourself.";

--[[>>]]FWL.TARGET_BACKGROUND = "Target background";
--[[>>]]FWL.FOCUS_BACKGROUND = "Focus background";

--[[>>]]FWL.EXPIRED = "Expired";
--[[>>]]FWL.EXPIRED_TT = "Enable to make expired bars take a different color.";

--[[>>]]FWL._RIGHTCLICK_FOR_OPTIONS = " (right-click for options)"

--[[>>]]FWL.CLONES_WORKING = "CLONES AREN'T FULLY WORKING. YOU CANNOT CHANGE WHAT IS DISPLAYED IN THEM YET.";
--[[>>]]FWL.SHOW_WITHOUT_UNIT = "Show without target";
--[[>>]]FWL.TIMER_SORT_ORDER = "Spell Type sort order";
--[[>>]]FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

--[[>>]]FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";
	
--[[>>]]FWL.SHARED_TYPE2 = "Shared Type (2)";
--[[>>]]FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

--[[>>]]FWL.SHARED_TYPE3 = "Shared Type (3)";
--[[>>]]FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

--[[>>]]FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
--[[>>]]FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
--[[>>]]FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

--[[>>]]FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
--[[>>]]FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

--[[>>]]FWL.TIMER_SMOOTHING = "Duration update smoothing";
--[[>>]]FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

--[[>>]]FWL.TIMER_COUNTDOWN = "Show Count down text";
--[[>>]]FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

--[[>>]]FWL.TIMER_ICONS = "Show icons";
--[[>>]]FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
--[[>>]]FWL.TIMER_ICONS_RIGHT = "Icons on right";
--[[>>]]FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

--[[>>]]FWL.TIMER_STACKS = "Show stacks on icons";
--[[>>]]FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
--[[>>]]FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
--[[>>]]FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

--[[>>]]FWL.LABEL_LIMIT = "Limit name tag size";
--[[>>]]FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
--[[>>]]FWL.SPARK_TICK = "Spark tick indication";
--[[>>]]FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
--[[>>]]FWL.CAST_OVERLAP = "Include tick overlap";
--[[>>]]FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

--[[>>]]FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
--[[>>]]FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
--[[>>]]FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
--[[>>]]FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";

--[[>>]]FWL.FLIP_TAG = "Flip tag location";
--[[>>]]FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
--[[>>]]FWL.NAMING_GROUPING = "Naming and Grouping";
	
--[[>>]]FWL.CAST_GCD = "Include Global Cooldown";
--[[>>]]FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- tradition chinese
elseif GetLocale() == "zhTW" then

	FWL.SPELL_TIMER = "法術計時條";
	FWL.DISPLAY_MODES = "顯示模式";
	FWL.EXTRA = "擴展";
	FWL.SHOW_HEADER = "顯示標題欄";
	FWL.DISPLAY_TYPES = "顯示類型";
	FWL.TIMER_HIDING = "隱藏";
	
	FWL.ST_HINT1 = "設置好計時條後可以鎖定並隱藏標題欄.";
	FWL.ST_HINT2 = "按右鍵debuff圖示過濾.";
--[[>>]]FWL.ST_HINT3 = "計時條鎖定時點擊穿過.";

	FWL.ST_BASIC1_TT = "計時條可視.";		
	FWL.ST_BASIC3_TT = "顯示標題欄對設置計時條很有幫助,但最好還是隱藏了它,它隱藏後依然能夠通過拖拽它移動計時條.";

	FWL.NORMAL_TEXT = "一般文字";
	FWL.NORMAL_TEXT_TT = "任何非目標/焦點的目標的計時文字顏色.";
	FWL.TARGET_TEXT = "目標文字";
	FWL.TARGET_TEXT_TT = "你目標的計時文字顏色.";
	FWL.FOCUS_TEXT = "焦點文字";
	FWL.FOCUS_TEXT_TT = "你焦點的計時文字顏色.";
	FWL.COUNTDOWN_TEXT = "冷卻文字";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "標籤字體";
	FWL.LABEL_FONT_TT = "物件標籤的字體. (當開啟按對象分類時)";
	FWL.UNIT_SPACING = "對象間距";
	FWL.UNIT_SPACING_TT = "不同物件計時條之間的間距. 只有當設定按物件分類計時條才有效.";
	FWL.UNIT_LABEL_HEIGHT = "對象標籤高度";
	FWL.UNIT_LABEL_HEIGHT_TT = "對象標籤的高度. (當開啟按對象分類時)";
	FWL.COUNTDOWN_WIDTH = "計時文字寬度";
	FWL.COUNTDOWN_WIDTH_TT = "你可以增加計時文字的寬度, 因為有時候計時文字可能顯示不完全.";
	FWL.MAXIMIZE_SPACE = "最大名字空間(醜)";
	FWL.MAXIMIZE_SPACE_TT = "物件/法術的空間最大化. 結果是這些文字將不會在計時條中間顯示. 當你把計時條設置非常短時有所幫助.";
	FWL.COUNTDOWN_ON_RIGHT = "右側顯示計時";
	FWL.COUNTDOWN_ON_RIGHT_TT = "在計時條左側或右側顯示計時.";

	FWL.ONEMAX = "統一上限時間";
	FWL.ONEMAX_TT = "所有的計時條都統一計時上限，就是所有的計時條的顯示計時上限都統一為當前的最大計時時間，這樣更容易看出施法計時.";
	FWL.FORCEMAX = "強制上限時間";
	FWL.FORCEMAX_TT = "所有的計時條都強制最大計時上限，哪怕計時上限長於最大的計時時間.";
	FWL.MAXTIME = "上限時間";
	FWL.MAXTIME_TT = "計時條顯示的上限時間.";

	FWL.DISPLAY_MODES7 = "按對象號分類";
	FWL.DISPLAY_MODES7_TT = "將一個物件的計時條排在一起顯示.";
	FWL.DISPLAY_MODES8 = "顯示物件號";
	FWL.DISPLAY_MODES8_TT = "在每個物件名字前顯示其編號. 有助於分辨出同名物件.";
--[[>>]]FWL.DISPLAY_MODES9 = "Show spell names instead";
--[[>>]]FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
--[[>>]]FWL.DISPLAY_MODES10 = "Show name tags/headers";
--[[>>]]FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";

	FWL.DISPLAY_TYPES1 = "顯示增強buffs";
	FWL.DISPLAY_TYPES1_TT = "計時條顯示增益buff.";
	FWL.DISPLAY_TYPES2 = "顯示暗影易傷";
	FWL.DISPLAY_TYPES2_TT = "顯示目標身上的類似暗影易傷的debuff作為自己的增強buff.";
	FWL.DISPLAY_TYPES3 = "計時閥值";
	FWL.DISPLAY_TYPES3_TT = "持續時間比這個時間長的法術不會在計時器裏顯示，當這些法術持續時間低於這個時間或者提前被移除時將會再次顯示，此外，被隱藏的法術在你重選定它時會顯示在你的目標上，因此你可以很容易看到有哪些法術存在，設置0則禁用.";
	FWL.DISPLAY_TYPES4 = "預備隱藏時間";
	FWL.DISPLAY_TYPES4_TT = "法術隱藏前的顯示時間.";
	FWL.DISPLAY_TYPES5 = "顯示失敗法術";
	FWL.DISPLAY_TYPES5_TT = "失敗法術仍在計時條顯示 (例如抵抗,免疫之類). 很有用.";
	FWL.DISPLAY_TYPES6 = "失敗法術顯示時間";
	FWL.DISPLAY_TYPES6_TT = "失敗法術在計時條上顯示時間.";
	FWL.DISPLAY_TYPES7 = "顯示傷害法術";
	FWL.DISPLAY_TYPES7_TT = "計時條中顯示你的傷害法術.";
	FWL.DISPLAY_TYPES8 = "顯示治療";
	FWL.DISPLAY_TYPES8_TT = "計時條中顯示你的HoTs.";
	FWL.DISPLAY_TYPES9 = "顯示友善法術";
	FWL.DISPLAY_TYPES9_TT = "計時條顯示你的友善法術.";
	FWL.DISPLAY_TYPES10 = "顯示Pet法術";
	FWL.DISPLAY_TYPES10_TT = "計時條顯示你的Pet法術.";
	FWL.DISPLAY_TYPES11 = "boss戰全顯示";
	FWL.DISPLAY_TYPES11_TT = "啟用這個選項，boss戰的時候顯示所有長計時法術";

	FWL.FADING1 = "法術結束前閃爍";
	FWL.FADING1_TT = "啟動此選項,計時條結束3秒前閃爍.先慢後快. 顏色不變";
	FWL.FADING2 = "計時條漸隱";
	FWL.FADING2_TT = "開啟後計時條平滑消失.";
	FWL.FADING3 = "漸隱消失時間";
	FWL.FADING3_TT = "計時結束,計時條漸隱持續時間";
	FWL.FADING4 = "漸隱時間";
	FWL.FADING4_TT = "計時條漸隱需用時間.";
	FWL.FADING5 = "高亮新釋放法術";
	FWL.FADING5_TT = "新釋放法術將高亮顯示,目的是為了分辨新釋放法術.";
	FWL.FADING6 = "沒有目標時的透明度";
	FWL.FADING6_TT = "當計時條顯示的不是你的目標或者焦點時,可以設置不同的透明度. 很容易分辨出自己的目標.";

	FWL.EXTRA1 = "顯示團隊圖示";
	FWL.EXTRA1_TT = "在物件計時條背景上顯示團隊圖示."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "團隊圖示透明度";
	FWL.EXTRA2_TT = "團隊圖示透明度.";
	FWL.EXTRA3 = "DOT判讀";
	FWL.EXTRA3_TT = "啟動此功能,計時條將查看你的戰鬥記錄DOT傷害,來判讀移除失效計時條.";
	FWL.EXTRA4 = "隊友判讀";
	FWL.EXTRA4_TT = "啟動此功能,計時條將查看你隊友的目標,來幫助判讀移除失效計時條.";
	FWL.EXTRA5 = "計時同步";
	FWL.EXTRA5_TT = "將法術計時和其對目標造成的buff/debuff計時同步，需要設置樣本技能.";
	FWL.EXTRA6 = "戰鬥結束後移除計時條";
	FWL.EXTRA6_TT = "每次離開戰鬥將NPC的計時條移除，也許有用吧.";

	
	FWL.HIGHLIGHT = "高亮";
	FWL.FAIL = "失敗";
	FWL.MAGIC_DOT = "DOT";
	FWL.CURSE = "詛咒";
--[[>>]]FWL.BANE = "Bane";
	FWL.CC = "控制";
	FWL.POWERUP_BUFFS = "增強buffs";
	FWL.HEAL = "治療";
	FWL.FRIENDLY_BUFFS = "友善buffs";

	FWL.ST_CUSTOMIZE_TT = "自定義計時法術/buffs."
	FWL.FAILED_MESSAGE_COLOR = "失敗法術資訊";
	FWL.SHOW_FAILED = "顯示失敗法術";
	FWL.SHOW_FAILED_TT = "顯示由於抵抗,免疫等釋放失敗的法術.";

	FWL.SHORT_HIDE = "隱藏";
	FWL.SHORT_FADE = "消失";
	FWL.SHORT_REMOVED = "移除";
	FWL.SHORT_RESISTED = "抵抗";
	FWL.SHORT_IMMUNE = "免疫";
	FWL.SHORT_EVADED = "閃避";
	FWL.SHORT_REFLECTED = "反射";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "計時條更新間隔";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "目標debuff檢查延遲";
	FWL.DELAY_DOT_TICKS_INIT = "DOT初始化延遲";
	FWL.DELAY_DOT_TICKS = "DoT延遲";

	FWL.TIME_LEFT = "顯示法術剩餘時間";

	FWL.NORMAL_TYPE = "普通";
	FWL.NORMAL_TYPE_TT = "普通法術計時";
	FWL.SHARED_TYPE = "公用";
	FWL.SHARED_TYPE_TT = "每種類型的法術只顯示一個計時條.";
	FWL.OTHER_DEBUFFS = "其他 Debuffs";
	FWL.OTHER_DEBUFFS_TT = "他人釋放的重要debuff，或者不是由你的法術直接觸發的debuff，只對當前目標有效.";
	FWL.CC_TT = "控制或者沉默法術";

	FWL.TICKS = "顯示DoT跳數";
	FWL.TICKS_TT = "顯示DoT剩餘跳數.";
	FWL.TICKS_NEXT = "顯示下一跳";
	FWL.TICKS_NEXT_TT = "只顯示計時條的的下一跳.";
	
	FWL.DRAIN = "吸取法術";
	FWL.DRAIN_TT = "顯示受到急速效果加成的吸取法術";
--[[>>]]FWL.CHANNEL = "Channel / Drain";
--[[>>]]FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "消退";
	FWL.BREAK = "打斷";
	FWL.RESIST = "抵抗";

	FWL.TICKS_COLOR = "跳數顏色";
	FWL.TICKS_COLOR_TT = "設置跳數顏色.";
	
	FWL.TIMER_OUTWARDS = "最長持續時間";
	FWL.TIMER_OUTWARDS_TT = "計時條記錄最長的法術持續時間.";
	FWL.TEST_BARS = "啟用測試計時條";
	FWL.TEST_BARS_TT = "測試計時條.";
	
	FWL.CAST_GLOW = "施法時間發光";
--[[>>]]FWL.CAST_GLOW_TT = "計時條顯示該法術施放的準備時間或者是施放後的公共CD，幫助計算施法時間，公共CD只有啟用'"..FWL.ONEMAX.."' 和冷卻計時條時顯示.";

	FWL.CUSTOM_TAG = "自訂標籤";
	FWL.CUSTOM_TAG_TT = "使用自訂計時條標籤.\n|cff00ff00id|r 替換目標id.\n|cff00ff00目標名|r 替換目標名字.\n|cff00ff00法術名|r 替換法術名字.\n|cff00ff00跳數|r 替換buff/debuff的跳數.";

	FWL.UNIQUE_TYPE = "單獨類型";
	FWL.UNIQUE_TYPE_TT = "只能在同一時間對一個目標使用的法術. 比如大多數控制技能.";
	
--[[>>]]FWL.BAR_BG_ALPHA = "Empty bar alpha";
--[[>>]]FWL.BAR_BG_ALPHA_TT = "The alpha the 'empty' part of a timer bar will have.";
--[[>>]]FWL.TIMER_FORMATS = "Additional layout";
--[[>>]]FWL.TIMER_UNITS = "Units";
--[[>>]]FWL.TIMER_MAXIMUM_TIME = "Maximum time";
--[[>>]]FWL.TIMER_TICKS = "Ticks";
--[[>>]]FWL.TIMER_RAID_TARGET_ICONS = "Raid Target Icons";

--[[>>]]FWL.TIMER_SHOW_TARGET = "Show target unit";
--[[>>]]FWL.TIMER_SHOW_TARGET_TT = "Show the bars belonging to your current target in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_FOCUS = "Show focus unit";
--[[>>]]FWL.TIMER_SHOW_FOCUS_TT = "Show the bars belonging to your current focus in this timer frame instance.";
--[[>>]]FWL.TIMER_SHOW_OTHER = "Show other units";
--[[>>]]FWL.TIMER_SHOW_OTHER_TT = "Show the bars belonging to all other units in this timer frame instance.";

--[[>>]]FWL.COOLDOWNS = "Cooldowns";
--[[>>]]FWL.COOLDOWNS_TT = "Show a small selection of cooldowns.";
--[[>>]]FWL.DEBUFFS = "Debuffs on me";
--[[>>]]FWL.DEBUFFS_TT = "Show a small selection of debuffs on yourself.";

--[[>>]]FWL.TARGET_BACKGROUND = "Target background";
--[[>>]]FWL.FOCUS_BACKGROUND = "Focus background";

--[[>>]]FWL.EXPIRED = "Expired";
--[[>>]]FWL.EXPIRED_TT = "Enable to make expired bars take a different color.";

--[[>>]]FWL._RIGHTCLICK_FOR_OPTIONS = " (right-click for options)"

--[[>>]]FWL.CLONES_WORKING = "CLONES AREN'T FULLY WORKING. YOU CANNOT CHANGE WHAT IS DISPLAYED IN THEM YET.";
--[[>>]]FWL.SHOW_WITHOUT_UNIT = "Show without target";
--[[>>]]FWL.TIMER_SORT_ORDER = "Spell Type sort order";
--[[>>]]FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

--[[>>]]FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";
	
--[[>>]]FWL.SHARED_TYPE2 = "Shared Type (2)";
--[[>>]]FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

--[[>>]]FWL.SHARED_TYPE3 = "Shared Type (3)";
--[[>>]]FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

--[[>>]]FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
--[[>>]]FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
--[[>>]]FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

--[[>>]]FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
--[[>>]]FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

--[[>>]]FWL.TIMER_SMOOTHING = "Duration update smoothing";
--[[>>]]FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

--[[>>]]FWL.TIMER_COUNTDOWN = "Show Count down text";
--[[>>]]FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

--[[>>]]FWL.TIMER_ICONS = "Show icons";
--[[>>]]FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
--[[>>]]FWL.TIMER_ICONS_RIGHT = "Icons on right";
--[[>>]]FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

--[[>>]]FWL.TIMER_STACKS = "Show stacks on icons";
--[[>>]]FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
--[[>>]]FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
--[[>>]]FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

--[[>>]]FWL.LABEL_LIMIT = "Limit name tag size";
--[[>>]]FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
--[[>>]]FWL.SPARK_TICK = "Spark tick indication";
--[[>>]]FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
--[[>>]]FWL.CAST_OVERLAP = "Include tick overlap";
--[[>>]]FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

--[[>>]]FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
--[[>>]]FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
--[[>>]]FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
--[[>>]]FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";

--[[>>]]FWL.FLIP_TAG = "Flip tag location";
--[[>>]]FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
--[[>>]]FWL.NAMING_GROUPING = "Naming and Grouping";
	
--[[>>]]FWL.CAST_GCD = "Include Global Cooldown";
--[[>>]]FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
elseif GetLocale() == "deDE" then
	--[[>>]]FWL.SPELL_TIMER = "Spell Timer";
	FWL.DISPLAY_MODES = "Anzeigemodi";
	FWL.EXTRA = "Extra";
	FWL.SHOW_HEADER = "Kopfzeilen anzeigen";
	FWL.DISPLAY_TYPES = "Typen anzeigen";
	FWL.TIMER_HIDING = "Verbergen";

	FWL.ST_HINT1 = "Timer sperren um die Kopfleisten zu verbergen wenn die Einstellungen abgeschlossen sind.";
	FWL.ST_HINT2 = "Rechtsklick auf ein Debufficon fügt diesen in das Filter anpassen Feld ein.";
--[[>>]]FWL.ST_HINT3 = "Wenn die Timer gesperrt sind klickst du durch sie hindurch.";

	FWL.ST_BASIC1_TT = "Aktiviert die Anzeige der Spell Timer.";		
	--[[>>]]FWL.ST_BASIC3_TT = "Showing the header can be usefull for setting up the timer, but there's no reason not to hide it. You can still drag the timer from the header spot if the header itself is hidden.";

	FWL.NORMAL_TEXT = "Normaler Text";
	FWL.NORMAL_TEXT_TT = "Die Farbe des Textes der Einheiten, welche du nicht im Ziel oder Focus hast.";
	FWL.TARGET_TEXT = "Ziel Text";
	FWL.TARGET_TEXT_TT = "Die Farbe des Textes der Einheit, die du im Zieles hast.";
	FWL.FOCUS_TEXT = "Focus Text";
	FWL.FOCUS_TEXT_TT = "Die Farbe des Textes der Einheit, die du im Focus hast.";
	FWL.COUNTDOWN_TEXT = "Zeit Text";
	FWL.COUNTDOWN_TEXT_TT = "Die Farbe des Textes der ablaufenden Zeit.";

	FWL.LABEL_FONT = "Leistenschriftart";
	FWL.LABEL_FONT_TT = "Die Schriftart die für den Text auf den Leisten verwendet wird (wenn aktiviert)";
	FWL.UNIT_SPACING = "Einheitenabstand";
	FWL.UNIT_SPACING_TT = "Der Abstand der Leistengruppen zwischen den verschiedenen Einheiten. Hat nur Auswirkung wenn 'Gruppiere nach Einheiten-ID' aktiv ist.";
	FWL.UNIT_LABEL_HEIGHT = "Höhe des Leistentextes";
	FWL.UNIT_LABEL_HEIGHT_TT = "Die Höhe des Textes auf den Leisten (wenn aktiviert).";
	FWL.COUNTDOWN_WIDTH = "Zeit Textbreite";
	FWL.COUNTDOWN_WIDTH_TT = "Du kannst die Zeit Textbreite erhöhen, wenn dieser nicht in allen Leisten ausreichend ist.";
	FWL.MAXIMIZE_SPACE = "Maximiere Namensplatz (unschön)";
	FWL.MAXIMIZE_SPACE_TT = "Maximiert den Platz des Einheiten/Spell Textes. Dadurch wird der Text nicht mehr exakt in der Mitte der Leiste angezeigt. Dies kann hilfreich sein wenn du sehr kurze Leisten eingestellt hast.";
	FWL.COUNTDOWN_ON_RIGHT = "Zeittext Rechts";
	FWL.COUNTDOWN_ON_RIGHT_TT = "Der Zeittext kann auf der linken oder rechten Seite der Leisten angezeigt werden.";
	
	FWL.ONEMAX = "An ein Maximum anpassen";
	FWL.ONEMAX_TT = "Passt alle Leisten an einen maximalen Wert an. Mit anderen Worten, alle Leisten nutzen zur Anzeige die Laufzeit des Spells mit der längsten Laufzeit. Dies macht es einfacher, Spells zu timen.";
	FWL.FORCEMAX = "Erzwinge maximale Zeit";
	FWL.FORCEMAX_TT = "Erzwingt die 'Maximale Zeit' Einstellung auf allen Leisten auch wenn der längste Timer eine kürzere Laufzeit hat.";
	FWL.MAXTIME = "Maximale Zeit";
	FWL.MAXTIME_TT = "Maximale Zeit die in einer Leiste angezeigt wird. Durch diese Einstellung wird die '"..FWL.ONEMAX.."' Einstellung etwas praktischer.";
	
	FWL.DISPLAY_MODES7 = "Gruppiere nach Einheiten-ID";
	FWL.DISPLAY_MODES7_TT = "Gruppiert die Timer nach Einheiten der selben ID.";
	FWL.DISPLAY_MODES8 = "Zeige Einheiten-ID";
	FWL.DISPLAY_MODES8_TT = "Zeigt die ID einer Einheit vor dem Namen. Dies hilft dir, Einheiten mit dem selben Namen auseinander zu halten.";
--[[>>]]FWL.DISPLAY_MODES9 = "Show spell names instead";
--[[>>]]FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
--[[>>]]FWL.DISPLAY_MODES10 = "Show name tags/headers";
--[[>>]]FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";

	FWL.DISPLAY_TYPES1 = "Zeige Powerup Buffs";
	FWL.DISPLAY_TYPES1_TT = "Der Spell Timer zeigt nützliche Powerup Buffs an.";
--[[>>]]FWL.DISPLAY_TYPES2 = "Zeige Schwachstellen";
--[[>>]]FWL.DISPLAY_TYPES2_TT = "Zeigt Schwachstellen wie den 'Verbesserter Schattenblitz' Debuff auf deinem Ziel als Powerup.";
	FWL.DISPLAY_TYPES3 = "Ausblenden wenn Laufzeit über";
	FWL.DISPLAY_TYPES3_TT = "Spells, deren Laufzeiten über dieser Zeit (in Sekunden) liegen, werden ausgeblendet. Sie werden wieder eingeblendet wenn ihre Laufzeiten unter die eingestellte Zeit fällt oder wenn sie frühzeitig entfernt werden. Ausgeblendete Spells werden auch wieder angezeigt, wenn du das Ziel erneut anwählst. So ist es einfach, zu sehen, welche Spells auf dem Ziel aktiv sind.";
	FWL.DISPLAY_TYPES4 = "Anzeigezeit vor Ausblenden";
	FWL.DISPLAY_TYPES4_TT = "Die Zeit, die ein Spell angezeigt wird, bevor er ausgeblendet wird.";
	FWL.DISPLAY_TYPES5 = "Zeige fehlgeschlagene Spells";
	FWL.DISPLAY_TYPES5_TT = "Zeigt fehlgeschlagene Spells im Timer (infolge von Resistenzen, Immunitäten etc). Sehr nützliche visuelle Hilfe.";
	FWL.DISPLAY_TYPES6 = "Anzeigezeit Fehlgeschlagener";
	FWL.DISPLAY_TYPES6_TT = "Die Zeit, die ein fehlgeschlagener Spell angezeigt wird, bevor er wieder ausgeblendet wird.";
	FWL.DISPLAY_TYPES7 = "Zeige schädliche Spells";
	FWL.DISPLAY_TYPES7_TT = "Zeigt deine schädlichen Spells im Spell Timer.";
	FWL.DISPLAY_TYPES8 = "Zeige Heilungen";
	FWL.DISPLAY_TYPES8_TT = "Zeigt deine HoTs im Spell Timer.";
	FWL.DISPLAY_TYPES9 = "Zeige freundliche Spells";
	FWL.DISPLAY_TYPES9_TT = "Zeigt deine freundlichen Spells im Spell Timer.";
	FWL.DISPLAY_TYPES10 = "Zeige Pet Spells";
	FWL.DISPLAY_TYPES10_TT = "Zeigt die Spells deines Pet's im Spell Timer.";
	FWL.DISPLAY_TYPES11 = "Kein ausblenden bei Bossen";
	FWL.DISPLAY_TYPES11_TT = "Aktiviere dies um Spells mit längerer Laufzeit nicht bei Bossen auszublenden.";
	
	FWL.FADING1 = "Blinkende endende Leisten";
	FWL.FADING1_TT = "Wenn aktiviert blinken Leisten, die in X Sekunden auslaufen werden. Sie blinken erst langsam und am Ende schnell. Eine schöne Hervorhebung von auslaufenden Leisten ohne die aktuelle Farbe zu ändern.";
	FWL.FADING2 = "Sanft ausblenden";
	FWL.FADING2_TT = "Wenn aktiviert werden die Leisten sanft ausgeblendet.";
	FWL.FADING3 = "Standard Ausblendverzögerung";
	FWL.FADING3_TT = "Die Zeit bevor eine ausgelaufene Leiste den Ausblendvorgang startet. Auch bekannt als 'ghost time'.";
	FWL.FADING4 = "Ausblendzeit";
	FWL.FADING4_TT = "Die Zeit die eine Leiste zum ausblenden verwendet.";
	FWL.FADING5 = "Neue hervorheben";
	FWL.FADING5_TT = "Neue Spells starten hell leuchtend und wechseln nach einer halben Sekunde zu ihrer normalen Farbe. Eine extra Hilfe um zu sehen, welche Spells neu zu den Spell Timern hinzugefügt wurden.";
	FWL.FADING6 = "Nicht-Ziel alpha";
	FWL.FADING6_TT = "Timer welche nicht zu deinem Ziel oder Fokus gehören, können mit einer anderen Transparenz (alpha) angezeigt werden. Dies macht es sehr leicht zu sehen, welche Einheit du gerade ausgewählt hast.";

	FWL.EXTRA1 = "Zeige Raid Zielicons";
	FWL.EXTRA1_TT = "Zeigt das Raid Zielicon jeder Einheit im Leistenhintergrund."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "Raid Zielicon Alpha";
	FWL.EXTRA2_TT = "Die Transparenz (alpha) eines Raid Zielicons.";
	FWL.EXTRA3 = "Verbesserung: Überwache DoT Ticks";
	FWL.EXTRA3_TT = "Wenn aktiviert überwachen die Timer deinen Kampflog auf DoT Schaden um Leisten zu entfernen, die nicht länger benötigt werden.";
	FWL.EXTRA4 = "Verbesserung: Überwache Gruppen/Raid Ziele";
	FWL.EXTRA4_TT = "Wenn aktiviert überwachen die Timer die Ziele der Gruppen/Raid Mitglieder um Leisten zu entfernen, die nicht länger benötigt werden.";
	FWL.EXTRA5 = "Synchronisiere Laufzeiten";
	--[[>>]]FWL.EXTRA5_TT = "Synchronisiere Spell Timer Laufzeiten mit den aktuellen Debuff/Buff Laufzeiten ihrer Ziele. Dies wird benötigt für zum Beispiel Debuffs, die ihre Laufzeit durch andere Fähigkeiten zurücksetzen können. Das Addon beendet diese nicht vorher aber aktuelle Debuff/Buff Informationen sind scheinbar etwas zuverlässiger. (Korrekt übersetzt? originaler Text:  The addon has never done this before, but currently debuff/buff information seems much more reliable.)";
	FWL.EXTRA6 = "Entferne Mob Timer nach Kampf";
	FWL.EXTRA6_TT = "Immer wenn du nicht mehr im Kampf bist entfernt das Addon verbleibende Timer, die NPCs betreffen. Es kann sinnvoll sein, dies in manchen Situationen zu deaktivieren.";
	
	FWL.HIGHLIGHT = "Hervorheben";
	FWL.FAIL = "Fehlschlag";
	FWL.MAGIC_DOT = "Magischer DoT";
	FWL.CURSE = "Fluch";
--[[>>]]FWL.BANE = "Bane";
--[[>>]]FWL.CC = "Crowd Control";
--[[>>]]FWL.POWERUP_BUFFS = "Powerup Buffs";
	FWL.HEAL = "Heilung";
	FWL.FRIENDLY_BUFFS = "Freundliche Buffs";

	FWL.ST_CUSTOMIZE_TT = "Anpassen jeden deiner Spells oder Buffs.";
	FWL.FAILED_MESSAGE_COLOR = "Fehlgeschlagene Spells Nachrichten";
	FWL.SHOW_FAILED = "Zeige fehlgeschlagene Spells";
	FWL.SHOW_FAILED_TT = "Zeige Spells die infolge von Resistenzen, Immunitäten etc. fehlgeschlagen sind.";

	--[[>>]]FWL.SHORT_HIDE = "hide";
	--[[>>]]FWL.SHORT_FADE = "fade";
	--[[>>]]FWL.SHORT_REMOVED = "remo";
	--[[>>]]FWL.SHORT_RESISTED = "resi";
	--[[>>]]FWL.SHORT_IMMUNE = "immu";
	--[[>>]]FWL.SHORT_EVADED = "evad";
	--[[>>]]FWL.SHORT_REFLECTED = "refl";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "Spell Timer-Aktualisierungsintervall";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "Verzögerung Ziel Debuffprüfung";
	FWL.DELAY_DOT_TICKS_INIT = "Verzögerung DoT Ticks start";
	FWL.DELAY_DOT_TICKS = "Verzögerung DoT Ticks";
	
	FWL.TIME_LEFT = "Ansagen der Laufzeit";
	
	FWL.NORMAL_TYPE = "Normale Typen";
	FWL.NORMAL_TYPE_TT = "Normale Spell Typen";
	FWL.SHARED_TYPE = "Gemeinsame Typen (1)";
	FWL.SHARED_TYPE_TT = "Spell Typen von denen nur einer auf dem Ziel sein darf (Beispielsweise Flüche/Auren).";
	FWL.OTHER_DEBUFFS = "Andere Debuffs";
	FWL.OTHER_DEBUFFS_TT = "Dies ist für wichtige von anderen gezauberte Debuffs oder für Debuffs, welche du direkt beim zaubern bestimmter Spells bekommst. Diese werden nur für dein aktuelles Ziel angezeigt.";
	FWL.CC_TT = "Crowd control or silencing spells";

	FWL.TICKS = "Zeige Ticks";
	FWL.TICKS_TT = "Zeige verbleibende DoT Ticks auf den Leisten";
	FWL.TICKS_NEXT = "Nur nächster Tick";
	FWL.TICKS_NEXT_TT = "Zeigt nur den nächsten verbleibenden Tick auf den Leisten.";
	
	--[[>>]]FWL.DRAIN = "Drain";
	--[[>>]]FWL.DRAIN_TT = "Zeige Drain und einige andere Kannalisierende Spells.";
--[[>>]]FWL.CHANNEL = "Channel / Drain";
--[[>>]]FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "Auslaufend";
	FWL.BREAK = "Unterbrochen";
	FWL.RESIST = "Resistent";
	
	FWL.TICKS_COLOR = "Tick Farbe";
	FWL.TICKS_COLOR_TT = "Setze die Tickfarben auf die Farbe die du angezeigt bekommen möchtest.";
	
	FWL.TIMER_OUTWARDS = "Längste Timer ganz oben";
	FWL.TIMER_OUTWARDS_TT = "Leisten werden nach der Laufzeit sortiert, die längste Laufzeit ist am weitesten von der Kopfzeile/dem Ankerpunkt entfernt.";
	FWL.TEST_BARS = "Aktiviere Testleisten";
	FWL.TEST_BARS_TT = "Aktiviert Testleisten. Dies macht es einfach, die Timer einzustellen ohne Spells auf Einheiten zu zaubern. Du mußt eine Einheit anwählen um die Ziel/Fokus Einstellungen zu testen, dies kannst auch du selbst sein.";

	FWL.CAST_GLOW = "Zeige Zauberzeit Leuchtspur";
	FWL.CAST_GLOW_TT = "Die Leiste zeigt die benötigte Zauberzeit eines Spells an oder wie lang dessen globaler Cooldown nach dem zaubern ist. Dies vereinfacht das Timing der zu zaubernden Spells. Der globale Cooldown wird nur angezeigt wenn '"..FWL.ONEMAX.."' aktiviert ist.";

	FWL.CUSTOM_TAG = "Eigener Text";
	FWL.CUSTOM_TAG_TT = "Verwende einen eigenen angepassten Text für die Leisten.\n|cff00ff00id|r wird ersetzt durch die Ziel-ID (gegebenenfalls).\n|cff00ff00target|r wird ersetzt durch den Namen der Zieleinheit (gegebenenfalls).\n|cff00ff00spell|r wird ersetzt durch den Spellnamen.\n|cff00ff00stacks|r wird ersetzt durch die Anzahl der Stacks des Buffs/Debuffs (gegebenenfalls).";

	FWL.UNIQUE_TYPE = "Einzigartige Typen";
	FWL.UNIQUE_TYPE_TT = "Typen der Spells, von denen nur einer auf einem Ziel zur selben Zeit sein kann. Zum Beispiel die meisten Crowd Control Spells.";

	FWL.BAR_BG_ALPHA = "Leerer Leistenbereich alpha";
	FWL.BAR_BG_ALPHA_TT = "Die sichtbarkeit (alpha) des Teiles der Leiste welcher 'leer' ist.";
	FWL.TIMER_FORMATS = "Leistentext";
	FWL.TIMER_UNITS = "Einheiten";
	FWL.TIMER_MAXIMUM_TIME = "Maximale Zeit";
	FWL.TIMER_TICKS = "Ticks";
	FWL.TIMER_RAID_TARGET_ICONS = "Raid Zielicons";

	FWL.TIMER_SHOW_TARGET = "Zeige Zieleinheit";
	FWL.TIMER_SHOW_TARGET_TT = "Zeige die Leisten, die dein aktuelles Ziel betreffen.";
	FWL.TIMER_SHOW_FOCUS = "Zeige Fokuseinheit";
	FWL.TIMER_SHOW_FOCUS_TT = "Zeige die Leisten, die dein Fokus betreffen.";
	FWL.TIMER_SHOW_OTHER = "Zeige andere Einheiten";
	FWL.TIMER_SHOW_OTHER_TT = "Zeige die Leisten aller anderen Einheiten.";

	FWL.COOLDOWNS = "Cooldowns";
	FWL.COOLDOWNS_TT = "Zeige eine kleine Auswahl von Cooldowns.";
	FWL.DEBUFFS = "Debuffs auf mir";
	FWL.DEBUFFS_TT = "Zeige eine kleine Auswahl von sich auf dir selbst befindenden Debuffs.";

	FWL.TARGET_BACKGROUND = "Ziel Hintergrund";
	FWL.FOCUS_BACKGROUND = "Fokus Hintergrund";

	FWL.EXPIRED = "Ablaufend";
	FWL.EXPIRED_TT = "Aktivieren um auslaufende Leisten in einer anderen Farbe zu zeigen.";

	FWL._RIGHTCLICK_FOR_OPTIONS = " (Rechtsklick für Einstellungen)"

	FWL.CLONES_WORKING = "DAS KLONEN IST NOCH UNVOLLSTÄNDIG. WAS ANGEZEIGT WERDEN SOLL KANNST DU NOCH NICHT ÄNDERN.";
--[[>>]]FWL.SHOW_WITHOUT_UNIT = "Show without target";
--[[>>]]FWL.TIMER_SORT_ORDER = "Spell Type sort order";
--[[>>]]FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

--[[>>]]FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";
	
--[[>>]]FWL.SHARED_TYPE2 = "Shared Type (2)";
--[[>>]]FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

--[[>>]]FWL.SHARED_TYPE3 = "Shared Type (3)";
--[[>>]]FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

--[[>>]]FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
--[[>>]]FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
--[[>>]]FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

--[[>>]]FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
--[[>>]]FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

--[[>>]]FWL.TIMER_SMOOTHING = "Duration update smoothing";
--[[>>]]FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

--[[>>]]FWL.TIMER_COUNTDOWN = "Show Count down text";
--[[>>]]FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

--[[>>]]FWL.TIMER_ICONS = "Show icons";
--[[>>]]FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
--[[>>]]FWL.TIMER_ICONS_RIGHT = "Icons on right";
--[[>>]]FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

--[[>>]]FWL.TIMER_STACKS = "Show stacks on icons";
--[[>>]]FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
--[[>>]]FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
--[[>>]]FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

--[[>>]]FWL.LABEL_LIMIT = "Limit name tag size";
--[[>>]]FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
--[[>>]]FWL.SPARK_TICK = "Spark tick indication";
--[[>>]]FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
--[[>>]]FWL.CAST_OVERLAP = "Include tick overlap";
--[[>>]]FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

--[[>>]]FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
--[[>>]]FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
--[[>>]]FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
--[[>>]]FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";

--[[>>]]FWL.FLIP_TAG = "Flip tag location";
--[[>>]]FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
--[[>>]]FWL.NAMING_GROUPING = "Naming and Grouping";
	
--[[>>]]FWL.CAST_GCD = "Include Global Cooldown";
--[[>>]]FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- korean
elseif GetLocale() == "koKR" then

    FWL.SPELL_TIMER = "주문 타이머";
	FWL.DISPLAY_MODES = "표시 모드";
	FWL.EXTRA = "추가 설정";
	FWL.SHOW_HEADER = "헤더 표시";
	FWL.DISPLAY_TYPES = "표시 종류";
	FWL.TIMER_HIDING = "숨기기";

	FWL.ST_HINT1 = "설정을 모두 마치면 타이머를 잠그고 헤더를 숨길 수 있습니다.";
	FWL.ST_HINT2 = "디버프 아이콘을 오른클릭하면 세부설정을 할 수 있습니다.";
--[[>>]]FWL.ST_HINT3 = "주문 타이머을 잠그면 타이머 뒤를 클릭할 수 있습니다.";

	FWL.ST_BASIC1_TT = "주문 타이머를 표시합니다.";		
	FWL.ST_BASIC3_TT = "주문 타이머의 헤더를 노출하면 설정하기엔 편하지만 숨기지 않을 이유도 없지요. 헤더를 숨겨도 헤더가 있는 위치에 마우스를 올려 끌면 주문 타이머의 위치를 변경할 수 있습니다.";

	FWL.NORMAL_TEXT = "일반 글씨";
	FWL.NORMAL_TEXT_TT = "대상(/대상) 혹은 주시대상(/주시) 이 아닌 타이머 그룹에 표시되는 글씨의 색상을 변경합니다.";
	FWL.TARGET_TEXT = "대상 글씨";
	FWL.TARGET_TEXT_TT = "대상(/대상) 타이머 그룹에 표시되는 글씨의 색상을 변경합니다.";
	FWL.FOCUS_TEXT = "주시대상 글씨";
	FWL.FOCUS_TEXT_TT = "주시대상(/주시) 타이머 그룹에 표시되는 글씨의 색상을 변경합니다.";
	FWL.COUNTDOWN_TEXT = "카운트다운 글씨";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "이름표 글씨체";
	FWL.LABEL_FONT_TT = "주문 타이머의 이름표에 사용될 글씨체를 설정합니다.";
	FWL.UNIT_SPACING = "그룹간(대상/주시/기타) 간격";
	FWL.UNIT_SPACING_TT = "타이머 그룹 간에 간격을 조정합니다.";
	FWL.UNIT_LABEL_HEIGHT = "이름표 높이";
	FWL.UNIT_LABEL_HEIGHT_TT = "유닛의 이름표 높이를 설정합니다.";
	FWL.COUNTDOWN_WIDTH = "카운트다운 글씨 넓이";
	FWL.COUNTDOWN_WIDTH_TT = "카운트다운 글씨가 어떤 이유로 잘 맞지 않는 경우 타이머 바에서 차지하는 넓이를 늘릴 수 있습니다.";
	FWL.MAXIMIZE_SPACE = "이름 간격 최대화(경고: 보기안좋음)";
	FWL.MAXIMIZE_SPACE_TT = "유닛과 주문 글씨에 사용되는 공간을 최대화합니다. 결과적으로 글씨는 타이머 바의 정중앙에 배치되지 않을 것입니다. 타이머바가 짧다면 이 설정을 활용하세요.";
	FWL.COUNTDOWN_ON_RIGHT = "카운트다운 글씨 우측 배치";
	FWL.COUNTDOWN_ON_RIGHT_TT = "체크를 하면 카운트다운 글씨가 우측에 배치됩니다.";
	
	FWL.ONEMAX = "시간이 가장 긴 바를 기준으로 정렬";
	FWL.ONEMAX_TT = "시간이 가장 긴 바를 기준으로 모든 바가 정렬이 됩니다.";
	FWL.FORCEMAX = "최대시간 고정";
	FWL.FORCEMAX_TT = "모든 바에 설정한 시간이 최대 시간이었던 것처럼 표시합니다.";
	FWL.MAXTIME = "최대시간";
	FWL.MAXTIME_TT = "바 하나에 표시될 수 있는 최대 시간을 설정합니다. 이 옵션은 [최대 시간 고정]을 좀 더 유용하게 만들기 위해 제공됩니다.";	
	
	FWL.DISPLAY_MODES7 = "같은 유닛(대상/주시/기타) 별로 그룹 형성";
	FWL.DISPLAY_MODES7_TT = "같은 유닛에 포함된 타이머 바는 한 그룹으로 묶습니다.";
	FWL.DISPLAY_MODES8 = "유닛 ID 를 함께 표시";
	FWL.DISPLAY_MODES8_TT = "각 유닛의 이름 앞에 ID 번호를 표시합니다. 같은 이름을 가진 유닛들을 구별할때 도움이 될것입니다.";
	FWL.DISPLAY_MODES9 = "유닛 이름 대신 주문 이름을 대신 표시";
	FWL.DISPLAY_MODES9_TT = "대상의 이름 대신 시전한 주문의 이름을 바에 표시합니다.";
	FWL.DISPLAY_MODES10 = "이름 태그와 헤더를 표시(툴팁 참고)";
	FWL.DISPLAY_MODES10_TT = "'"..FWL.DISPLAY_MODES7.."'옵션이 활성화되어 있으면 각 바 그룹에 이름 태그가 나타날 것입니다.";
		
	FWL.DISPLAY_TYPES1 = "일시적인 강화효과 표시";
	FWL.DISPLAY_TYPES1_TT = "타이머로 이익이 되는 일시적인 강화효과를 표시합니다. ";
	FWL.DISPLAY_TYPES2 = "공유하는 디버프 효과 표시";
	FWL.DISPLAY_TYPES2_TT = "흑마법사의 '어둠과 불길' 과 같은 본인의 대상에 걸린 약화 디버프를 주문 타이머에 표시합니다.";
	FWL.DISPLAY_TYPES3 = "특정시간 이전까지 숨김";
	FWL.DISPLAY_TYPES3_TT = "설정한 특정 시간이 되기전까진 타이머 주문 바를 숨깁니다. 정해진 시간보다 일찍 제거될 경우 표시가 됩니다.  또한 추적하고 있는 대상이 바뀌었다가 다시 돌아올경우 설정한 시간여부와 상관없이 표시가 됩니다.";
	FWL.DISPLAY_TYPES4 = "미리 숨김";
	FWL.DISPLAY_TYPES4_TT = "주문의 지속시간이 끝나기 전에 타이머 바를 숨깁니다.";
	FWL.DISPLAY_TYPES5 = "실패한 주문 표시";
	FWL.DISPLAY_TYPES5_TT = "저항이나 면역으로 인해 주문이 실패할 경우 깜빡이는 바 형태로 알려줍니다.";
	FWL.DISPLAY_TYPES6 = "실패한 주문 알림 지속시간";
	FWL.DISPLAY_TYPES6_TT = "실패한 주문을 알려주는 타이머 바가 사라지기 전까지 얼마나 표시될지 설정합니다.";
	FWL.DISPLAY_TYPES7 = "본인의 공격 주문 표시";
	FWL.DISPLAY_TYPES7_TT = "플레이어가 시전하는 해로운 주문을 타이머 바로 표시합니다.";
	FWL.DISPLAY_TYPES8 = "지속 치유 주문 표시";
	FWL.DISPLAY_TYPES8_TT = "지속적으로 들어오는 도트 힐을 타이머 바로 표시합니다.";
	FWL.DISPLAY_TYPES9 = "아군 주문 표시";
	FWL.DISPLAY_TYPES9_TT = "아군이 시전하는 주문을 표시합니다.";
	FWL.DISPLAY_TYPES10 = "소환수 주문 표시";
	FWL.DISPLAY_TYPES10_TT = "소환수의 주문이나 기술을 표시합니다.";
	FWL.DISPLAY_TYPES11 = "보스에게 걸린것은 숨기지 않음";
	FWL.DISPLAY_TYPES11_TT = "보스에게 건 모든 주문은 사리지지 않습니다.";
	
	FWL.FADING1 = "종료 깜빡임 알림";
	FWL.FADING1_TT = "주문 타이머 바가 종료되기 3초 전부터 깜빡이기 시작합니다. 처음엔 천천히 동작하다가 후엔 점점 빨라질 것입니다. 실제로 색을 바꾸지 않아도 종료를 미리 알아챌 수 있는 좋은 효과입니다.";
	FWL.FADING2 = "바 서서히 사라짐";
	FWL.FADING2_TT = "타이머 바가 종료시 서서히 사라집니다. 특정 즉시시전 주문의 경우 쿨다운이 주문 타이머로 추적되고 있을때 쿨다운이 끝난 직후 바로 사용시 쿨다운 바가 재생되지않고 누락되는 버그가 있을 수 있습니다. (예를들면 점화)";
	FWL.FADING3 = "서서히 사라지는 효과 지연";
	FWL.FADING3_TT = "이미 종료가 된 타이머 바가 서서히 사라지기 전까지 시간을 의미합니다.";
	FWL.FADING4 = "사라지는 시간(애니메이션 동작)";
	FWL.FADING4_TT = "종료 후 서서히 사라지는 총 시간입니다.";
	FWL.FADING5 = "최근 시전 강조";
	FWL.FADING5_TT = "가장 최근에 시전한 주문으로 인해 타이머 바가 생성시 0.5 초간 밝은 색깔을 띄어서 확인할 수 있게 합니다.";
	FWL.FADING6 = "유닛 간 투명화로 구분";
	FWL.FADING6_TT = "대상(/대상)이나 주시대상(/주시) 유닛이 아닌 기타에 속한 유닛 타이머 바 경우 투명화 효과를 주어 구분하기 쉽게 만듭니다.";
	FWL.EXTRA1 = "공격대 아이콘 표시";
	FWL.EXTRA1_TT = "각 유닛의 타이머 바 배경에 공격대 아이콘을 표시합니다."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "공격대 아이콘 투명값";
	FWL.EXTRA2_TT = "공격대 아이콘을 표시할 때 얼마나 투명할지 설정합니다.";
	FWL.EXTRA3 = "개선: 지속피해 효과(도트 틱) 사용";
	FWL.EXTRA3_TT = "전투기록을 참고하여 지속 데미지 효과를 추적합니다. 좀 더 정확하게 활성화 여부를 판가름할 수 있습니다.";
	FWL.EXTRA4 = "개션: 파티/공격대 대상 사용";
	FWL.EXTRA4_TT = "파티/공격대 동료의 대상 정보를 참고하여 효과를 추적합니다. 사라지지 않는 주문을 효과적으로 제거할 수 있습니다.";
	FWL.EXTRA5 = "지속 시간 동기화";
	FWL.EXTRA5_TT = "주문 타이머의 지속시간 추적을 대상의 실제 디버프/버프 지속시간과 동기화합니다. 일부 디버프가 다른 기술에 의해서 지속시간이 초기화될 때 필요할 수 있습니다. 하지만 대상의 디버프/버프 정보가 더 신뢰성이 있습니다.";
	FWL.EXTRA6 = "전투 종료 후 강제 소거";
	FWL.EXTRA6_TT = "매번 전투가 종료될 때마다 남은 지속시간 여부와 상관없이 NPCs 와 관련된 타이머 바를 강제로 제거합니다. 일부상황에서 맞지 않을 가능성이 있으므로 추천하지 않습니다.";

	FWL.HIGHLIGHT = "최근 주문 강조";
	FWL.FAIL = "실패한 주문";
	FWL.MAGIC_DOT = "마법 지속 피해(도트) 효과";
	FWL.CURSE = "저주";
--[[>>]]FWL.BANE = "Bane";
	FWL.CC = "군중제어 효과";
	FWL.POWERUP_BUFFS = "일시적 강화 효과";
	FWL.HEAL = "치유 효과";
	FWL.FRIENDLY_BUFFS = "아군 버프 효과";

	FWL.ST_CUSTOMIZE_TT = "개별적으로 설정합니다.";
	FWL.FAILED_MESSAGE_COLOR = "실패 주문 메시지";
	FWL.SHOW_FAILED = "실패한 주문 보기";
	FWL.SHOW_FAILED_TT = "저항이나 면역으로 인해 실패한 주문을 표시합니다.";

	FWL.SHORT_HIDE = "숨기기";
	FWL.SHORT_FADE = "사라짐";
	FWL.SHORT_REMOVED = "제거";
	FWL.SHORT_RESISTED = "저항";
	FWL.SHORT_IMMUNE = "면역";
	FWL.SHORT_EVADED = "회피";
	FWL.SHORT_REFLECTED = "반사";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "주문 타이머 업데이트 주기";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "대상 디버프 추적 지연시간";
	FWL.DELAY_DOT_TICKS_INIT = "초기 지속효과 틱 지연";
	FWL.DELAY_DOT_TICKS = "지속효과 틱 지연";
	
	FWL.TIME_LEFT = "사라짐 시간 알림";
	
	FWL.NORMAL_TYPE = "일반 형태";
	FWL.NORMAL_TYPE_TT = "일반적으로 사용되는 대다수의 주문이나 기술을 말합니다.";
	FWL.SHARED_TYPE = "공유 형태(1)";
	FWL.SHARED_TYPE_TT = "한 대상에 오로지 한 종류만 시전 가능한 주문이나 기술을 말합니다. (예를들면 저주)";
	FWL.OTHER_DEBUFFS = "레이드 디버프";
	FWL.OTHER_DEBUFFS_TT = "다른 사람이 시전한 중요한 디버프나 본인이 직접 시전을 통해 발생하지는 않지만 부가적으로 발생하는 디버프를 추적합니다.(예를들면 임계질량이나 어둠과 불길 이 둘은 어둠의 화살,소각 혹은불태우기 기술을 시전시 간접적으로 발생하는 것들입니다) 오로지 대상(/대상)에게 걸린 것만 타이머 바로 표시됩니다.";
	FWL.CC_TT = "군중제어 기술 혹은 침묵 효과 주문을 의미합니다.";

	FWL.TICKS = "틱 표시";
	FWL.TICKS_TT = "타이머 바에 지속 효과의 틱을 표시합니다.";
	FWL.TICKS_NEXT = "다음 틱만 표시";
	FWL.TICKS_NEXT_TT = "타이머 바에 다음에 적용될 틱만 표시합니다.";
	
	FWL.DRAIN = "흡수 및 채널링 형태";
	FWL.DRAIN_TT = "흡수 계열 주문을 표시합니다.";
--[[>>]]FWL.CHANNEL = "Channel / Drain";
--[[>>]]FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "사라짐";
	FWL.BREAK = "풀림";
	FWL.RESIST = "저항";
	
	FWL.TICKS_COLOR = "틱 색상";
	FWL.TICKS_COLOR_TT = "틱을 표시하는 색상을 지정합니다.";
	
	FWL.TIMER_OUTWARDS = "높은 순서대로 타이머 재정렬";
	FWL.TIMER_OUTWARDS_TT = "타이머 바들 중 가장 길게 시간이 남은 것이 헤더로 부터 가장 먼 곳에 우선 배치되어 정렬됩니다.";
	FWL.TEST_BARS = "사용 가능한 테스트 바";
	FWL.TEST_BARS_TT = "테스트 용 타이머 바를 생성합니다. 여전히 대상(/대상)이나 주시대상(/주시) 유닛에 관련된 타이머 바는 직접 선택해야 합니다.";

	FWL.CAST_GLOW = "시전 시간 미리 알림";
	FWL.CAST_GLOW_TT = "타이머 바를 통해 해당 주문을 다시 시전하기 위해 필요한 시간이나 얼마나 글로벌 쿨타임이 필요한지 알려줍니다. 이 설정은 주문을 다시 적용하기 아주 편리하게 만듭니다. 글로벌 쿨다운은 '"..FWL.ONEMAX.."'이 설정되었을때만 지원이 됩니다.";

	FWL.CUSTOM_TAG = "임의 이름표 제작";
	FWL.CUSTOM_TAG_TT = "타이머 바에 표시될 임의의 이름표를 만듭니다.\n|cff00ff00id|r 는 대상의 ID .\n|cff00ff00target|r 는 대상의 이름.\n|cff00ff00spell|r 는 주문의 이름 .\n|cff00ff00stacks|r 는 주문의 중첩횟수를 의미합니다.";

	FWL.UNIQUE_TYPE = "고유한 형태";
	FWL.UNIQUE_TYPE_TT = "군중제어 효과 주문들처럼 대상에 한 번에 한 가지만 적용이 되는 주문 형태들을 말합니다.";

	FWL.BAR_BG_ALPHA = "빈 바의 투명도";
	FWL.BAR_BG_ALPHA_TT = "비어있는 타이머 바의 투명함 정도를 설정합니다.";
	FWL.TIMER_FORMATS = "타이머 구성 방식";
	FWL.TIMER_UNITS = "유닛";
	FWL.TIMER_MAXIMUM_TIME = "최대 시간";
	FWL.TIMER_TICKS = "틱";
	FWL.TIMER_RAID_TARGET_ICONS = "공격대 대상 아이콘";

	FWL.TIMER_SHOW_TARGET = "대상 유닛 표시";
	FWL.TIMER_SHOW_TARGET_TT = "대상에게 걸린 주문을 추적하여 표시합니다.";
	FWL.TIMER_SHOW_FOCUS = "주시대상 유닛 표시";
	FWL.TIMER_SHOW_FOCUS_TT = "현재 주시대상에게 걸린 주문을 추적하여 표시합니다.";
	FWL.TIMER_SHOW_OTHER = "모든 기타 유닛 표시";
	FWL.TIMER_SHOW_OTHER_TT = "대상과 주시대상을 제외한 모든 기타 대상에게 걸린 주문을 추적하여 표시합니다.";

	FWL.COOLDOWNS = "쿨다운 표시";
	FWL.COOLDOWNS_TT = "임의로 지정한 주문의 쿨다운을 표시합니다.";
	FWL.DEBUFFS = "q본인에게 걸린 디버프";
	FWL.DEBUFFS_TT = "본인에게 걸린 디버프의 지속시간을 표시합니다.";

	FWL.TARGET_BACKGROUND = "대상 배경";
	FWL.FOCUS_BACKGROUND = "주시대상 배경";

	FWL.EXPIRED = "종료";
	FWL.EXPIRED_TT = "종료된 타이머 바의 색상을 지정합니다.";

	FWL._RIGHTCLICK_FOR_OPTIONS = "(오른쪽 클릭 옵션 열기)"
	
	FWL.CLONES_WORKING = "복사본 기능은 현재 제대로 작동하고 있지 않습니다. 무엇이 표시되어야할 지 변경할 수 없습니다. 추후 업데이트 될 것입니다.";
	FWL.SHOW_WITHOUT_UNIT = "유닛 구분과 무관하게 표시";
	FWL.TIMER_SORT_ORDER = "주문형태 분류순서";
	FWL.TIMER_SORT_ORDER_TT =  "서로 다른 주문 형태를 임의의 순서로 분류하여 주문 타이머에 표시합니다. 가장 왼쪽에 위치한 태그는 헤더/앵커에 가장 가깝게 표시될 것입니다.이 설정은 '그룹 별로 유닛 표시' 설정이 활성화되었을 때만 제대로 작동합니다. \n|cff00ff00버프|r 은 자신에게 걸린 강화 효과를 의미합니다.\n|cff00ff00걸린디버프|r 는 자신에게 걸린 디버프를 의미합니다.\n|cff00ff00디버프|r 는 자신의 현재 대상에 걸린 디버프를 의미합니다.\n|cff00ff00쿨다운|r 은 자신의 디버프를 의미합니다.\n|cff00ff00대상없음|r 은 대상이 없는 주문이나 대상을 찾거나 수정해야할 필요가 있는 주문이 표시 됩니다.\n|cff00ff00대상|r 은 각 유닛들에게 시전된 기타 모든 주문을 의미합니다.";

	FWL.TIMER_SPARK_TT = "바 사이에 적절한 공간에 스파크 효과를 표시합니다.";
	
	FWL.SHARED_TYPE2 = "공유형태(2)";
	FWL.SHARED_TYPE2_TT = "오로지 한 대상에 한종류의 형태만 허용이 되는 주문 계열을 의미합니다. (예를 들면, 파멸).";

	FWL.SHARED_TYPE3 = "공유형태(3)";
	FWL.SHARED_TYPE3_TT = "오로지 한 대상에 한종류의 형태만 허용이 되는 주문 계열을 의미합니다.";

	FWL.TIMER_SHOW_UKNOWN = "파악하지 못한 유닛의 타이머 표시";
	FWL.TIMER_SHOW_YOU = "본인에게 걸린 것/쿨다운 표시";
	FWL.TIMER_RAID_DEBUFFS = "레이드 디버프를 표시";

	FWL.SMART_COUNTDOWN_WIDTH = "스마트 카운트다운 텍스트 기능 사용";
	FWL.SMART_COUNTDOWN_WIDTH_TT = "이 옵션을 켜면 카운트다운 텍스트가 우측에 배치될 시, 차지하고 있는 너비와 이름표 너비 간의 충돌을 최소화 해줍니다.";

	FWL.TIMER_SMOOTHING = "지속시간 변경 반영 속도";
	FWL.TIMER_SMOOTHING_TT = "1 은 변경된 지속시간이 즉시 반영이 되며, 20 은 아주 부드럽게 반영이 이루어집니다.";

	FWL.TIMER_COUNTDOWN = "카운트다운 텍스트 표시";
	FWL.TIMER_COUNTDOWN_TT = "바에 남은 시간을 표시합니다.";

	FWL.TIMER_ICONS = "아이콘 표시";
	FWL.TIMER_ICONS_TT = "바에 아이콘을 표시합니다.";
	FWL.TIMER_ICONS_RIGHT = "아이콘을 우측에 배치";
	FWL.TIMER_ICONS_RIGHT_TT = "아이콘을 원하는 곳에 배치할 수 있습니다.";

	FWL.TIMER_STACKS = "아이콘에 중첩 효과 표시";
	FWL.TIMER_STACKS_TT = "이름표 대신 아이콘에 중첩 효과를 숫자로 표시합니다.";
	FWL.TIMER_BAR_LABELS = "유닛/주문 이름 텍스트 표시";
	FWL.TIMER_BAR_LABELS_TT = "정말 조그마한 바에 도움이 될 것입니다.";

--[[>>]]FWL.LABEL_LIMIT = "Limit name tag size";
--[[>>]]FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
--[[>>]]FWL.SPARK_TICK = "Spark tick indication";
--[[>>]]FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
--[[>>]]FWL.CAST_OVERLAP = "Include tick overlap";
--[[>>]]FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

--[[>>]]FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
--[[>>]]FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
--[[>>]]FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
--[[>>]]FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";

--[[>>]]FWL.FLIP_TAG = "Flip tag location";
--[[>>]]FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
--[[>>]]FWL.NAMING_GROUPING = "Naming and Grouping";
	
--[[>>]]FWL.CAST_GCD = "Include Global Cooldown";
--[[>>]]FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";

-- ENGLISH
else	-- standard english version
	FWL.SPELL_TIMER = "Spell Timer";
	FWL.DISPLAY_MODES = "Display Modes";
	FWL.EXTRA = "Extra";
	FWL.SHOW_HEADER = "Show header";
	FWL.DISPLAY_TYPES = "Display Types";
	FWL.TIMER_HIDING = "Hiding";

	FWL.ST_HINT1 = "Once you have set up the timer, you can lock it and hide its header.";
	FWL.ST_HINT2 = "Right-clicking a debuff icon will fill in that spell in the custom filter field.";
	FWL.ST_HINT3 = "When the timer is locked you will click through it and the automatic hiding will work.";

	FWL.ST_BASIC1_TT = "Visually enable the spell timer.";		
	FWL.ST_BASIC3_TT = "Showing the header can be usefull for setting up the timer, but there's no reason not to hide it. You can still drag the timer from the header spot if the header itself is hidden.";

	FWL.NORMAL_TEXT = "Normal text";
	FWL.NORMAL_TEXT_TT = "The color used for the texts belonging to any non-target/focus unit.";
	FWL.TARGET_TEXT = "Target text";
	FWL.TARGET_TEXT_TT = "The color used for the texts belonging to your target.";
	FWL.FOCUS_TEXT = "Focus text";
	FWL.FOCUS_TEXT_TT = "The color used for the texts belonging to your focus.";
	FWL.COUNTDOWN_TEXT = "Countdown text";
	FWL.COUNTDOWN_TEXT_TT = "";

	FWL.LABEL_FONT = "Label Font";
	FWL.LABEL_FONT_TT = "The font to use for the unit labels in between the bars. (if enabled)";
	FWL.UNIT_SPACING = "Unit spacing";
	FWL.UNIT_SPACING_TT = "The spacing between bar groups belonging to different units. Only applies when grouping by unit.";
	FWL.UNIT_LABEL_HEIGHT = "Unit label height";
	FWL.UNIT_LABEL_HEIGHT_TT = "The height of the unit labels in between the bars. (if enabled)";
	FWL.COUNTDOWN_WIDTH = "Countdown text width";
	FWL.COUNTDOWN_WIDTH_TT = "You can increase the width your countdown text takes up, in case the text doesnt always fit for some reason.";
	FWL.MAXIMIZE_SPACE = "Maximize name space (ugly)";
	FWL.MAXIMIZE_SPACE_TT = "Maximizes the space used for the unit/spell texts. As a result, these texts will no longer be displayed in the exact center of the bars. This can be usefull if you have very short bars.";
	FWL.COUNTDOWN_ON_RIGHT = "Count down on right";
	FWL.COUNTDOWN_ON_RIGHT_TT = "You can display the countdown text on the right or on the left of the timer bars.";
	
	FWL.ONEMAX = "Adapt to one maximum";
	FWL.ONEMAX_TT = "Adapt all bars to one maximum. In other words, all the bars will use the duration of the spell with the longest duration currently on the timer. This may make it easier to time spellcasts.";
	FWL.FORCEMAX = "Force maximum time";
	FWL.FORCEMAX_TT = "Forces the maximum time setting on all bars, even if the longest timer has a shorter duration.";
	FWL.MAXTIME = "Maximum time";
	FWL.MAXTIME_TT = "Maximum time that's displayed on a bar. This option is mostly there for making the 'one maximum' setting more practical.";
	
	FWL.DISPLAY_MODES7 = "Group by unit";
	FWL.DISPLAY_MODES7_TT = "Groups timers belonging to the same units together.";
	FWL.DISPLAY_MODES8 = "Show unit #";
	FWL.DISPLAY_MODES8_TT = "Shows the 'id' number of each unit in front of its name. This way you can distinguish between units with the same name.";
	FWL.DISPLAY_MODES9 = "Show spell names instead";
	FWL.DISPLAY_MODES9_TT = "This will display the names of your spells on the timer bars, instead of the target name.";
	FWL.DISPLAY_MODES10 = "Show name tags/headers";
	FWL.DISPLAY_MODES10_TT = "With the '"..FWL.DISPLAY_MODES7.."' option on, unit name tags will appear for each bar group.";
	
	FWL.DISPLAY_TYPES1 = "Show powerup buffs";
	FWL.DISPLAY_TYPES1_TT = "The timer will also display beneficial powerup buffs.";
	FWL.DISPLAY_TYPES2 = "Show Vulnerability";
	FWL.DISPLAY_TYPES2_TT = "Show vulnerabilities like the Improved Shadowbolt debuff on your target as a powerup.";
	FWL.DISPLAY_TYPES3 = "Hide timers if remaining over";
	FWL.DISPLAY_TYPES3_TT = "Spells that still last longer than this time (seconds) will be hidden from the timer. They will be unhidden again when they get below this time or get removed early. In addition, hidden spells are again shown on your target when you reselect it, so it's still easy to see what spells are up.";
	FWL.DISPLAY_TYPES4 = "Pre-hide display time";
	FWL.DISPLAY_TYPES4_TT = "The time a spell is diplayed before being hidden.";
	FWL.DISPLAY_TYPES5 = "Show failed spells";
	FWL.DISPLAY_TYPES5_TT = "Also show failed spells on the timer (due to resist, immune etc). Very usefull visual aid.";
	FWL.DISPLAY_TYPES6 = "Failed display time";
	FWL.DISPLAY_TYPES6_TT = "The time a spell that failed is diplayed before fading away.";
	FWL.DISPLAY_TYPES7 = "Show harmful spells";
	FWL.DISPLAY_TYPES7_TT = "Show your harmfull spells in the Spell Timer.";
	FWL.DISPLAY_TYPES8 = "Show heals";
	FWL.DISPLAY_TYPES8_TT = "Show your HoTs in the Spell Timer.";
	FWL.DISPLAY_TYPES9 = "Show friendly spells";
	FWL.DISPLAY_TYPES9_TT = "Show your friendly spells in the Spell Timer.";
	FWL.DISPLAY_TYPES10 = "Show pet spells";
	FWL.DISPLAY_TYPES10_TT = "Show your pet's spells in the Spell Timer.";
	FWL.DISPLAY_TYPES11 = "No hiding on bosses";
	FWL.DISPLAY_TYPES11_TT = "Enable this option to keep all your longer spells visible on bosses.";
	
	FWL.FADING1 = "Blink expiring bars";
	FWL.FADING1_TT = "When enabled, bars expiring in X seconds will start to blink. First slow, fast in the end. A nice indication of expiring bars, without changing the actual color.";
	FWL.FADING2 = "Fade out bars";
	FWL.FADING2_TT = "When enabled, your timer bars will smoothly fade out.";
	FWL.FADING3 = "Standard fade delay";
	FWL.FADING3_TT = "The delay before a timer bar that already expired, starts fading out. Also known as 'ghost time'.";
	FWL.FADING4 = "Fade time (animation)";
	FWL.FADING4_TT = "The time it takes for the bars to fade out (speed of the fade out animations).";
	FWL.FADING5 = "Highlight new casts";
	FWL.FADING5_TT = "Newly cast spells will start out bright and change to their normal color in half a second. An extra aid to see where your newly cast spell appeared on the timer.";
	FWL.FADING6 = "Non-target alpha";
	FWL.FADING6_TT = "Timers that do not belong to your target or focus, can be displayed with a different transparency. This makes it very easy to see what unit you have currently selected.";

	FWL.EXTRA1 = "Show Raid Target Icons";
	FWL.EXTRA1_TT = "Show the raid target icon of each unit in the bar background."..FWL._EDITBOX_TRANSPARENCY;
	FWL.EXTRA2 = "Raid Target Icons Alpha";
	FWL.EXTRA2_TT = "The alpha (transparency) of the raid target icons.";
	FWL.EXTRA3 = "Improve: Use dot ticks";
	FWL.EXTRA3_TT = "When enabled, the timer will watch your combat log for dot damage to help remove bars that no longer apply.";
	FWL.EXTRA4 = "Improve: Use party/raid targets";
	FWL.EXTRA4_TT = "When enabled, the timer will watch party/raid member targets to help remove bars that no longer apply.";
	FWL.EXTRA5 = "Synchronize durations";
	FWL.EXTRA5_TT = "Synchronize spell timer durations to the actual debuff/buff durations of their targets. This is needed for example for debuffs that can reset their duration through other abilities. The addon has never done this before, but currently debuff/buff information seems much more reliable.";
	FWL.EXTRA6 = "Remove mob timers after combat";
	FWL.EXTRA6_TT = "Every time you exit combat the addon will remove remaining timers belonging to NPCs. May be useful to disable this in some cases.";
	
	FWL.HIGHLIGHT = "Highlight new";
	FWL.FAIL = "Fail";
	FWL.MAGIC_DOT = "Magic dot";
	FWL.CURSE = "Curse";
	FWL.BANE = "Bane";
	FWL.CC = "Crowd control";
	FWL.POWERUP_BUFFS = "Powerup buffs";
	FWL.HEAL = "Heal";
	FWL.FRIENDLY_BUFFS = "Friendly buffs";

	FWL.ST_CUSTOMIZE_TT = "Customize each of your spells or buffs.";
	FWL.FAILED_MESSAGE_COLOR = "Failed spell messages";
	FWL.SHOW_FAILED = "Show failed spells";
	FWL.SHOW_FAILED_TT = "Show spells that failed due to resist, immune etc.";

	FWL.SHORT_HIDE = "hide";
	FWL.SHORT_FADE = "fade";
	FWL.SHORT_REMOVED = "remo";
	FWL.SHORT_RESISTED = "resi";
	FWL.SHORT_IMMUNE = "immu";
	FWL.SHORT_EVADED = "evad";
	FWL.SHORT_REFLECTED = "refl";

	FWL.UPDATE_INTERVAL_SPELL_TIMER = "Update interval spell timer";
	FWL.DELAY_TARGET_DEBUFF_CHECK = "Delay target debuff check";
	FWL.DELAY_DOT_TICKS_INIT = "Delay dot ticks init";
	FWL.DELAY_DOT_TICKS = "Delay dot ticks";
	
	FWL.TIME_LEFT = "Announce fade time";
	
	FWL.NORMAL_TYPE = "Normal Type";
	FWL.NORMAL_TYPE_TT = "Normal Spell Types";
	FWL.SHARED_TYPE = "Shared Type (1)";
	FWL.SHARED_TYPE_TT = "Types of spells that allow only one spell of this kind up on one target (for example Curses).";
	FWL.OTHER_DEBUFFS = "Raid debuffs";
	FWL.OTHER_DEBUFFS_TT = "This may be important debuffs cast by others, or debuffs that belong to you that aren't triggered directly by spellcasts. These are only shown for your current target.";
	FWL.CC_TT = "Crowd control or silencing spells";

	FWL.TICKS = "Show Ticks";
	FWL.TICKS_TT = "Show remaining DoT ticks on the bars.";
	FWL.TICKS_NEXT = "Next Tick only";
	FWL.TICKS_NEXT_TT = "Only show the next Tick on the bars.";
	
	FWL.DRAIN = "Drain";
	FWL.DRAIN_TT = "Show Drain and some other Channeling spells.";
	FWL.CHANNEL = "Channel / Drain";
	FWL.CHANNEL_TT = "Show Channelled spells. This also includes Drains.";
	
	FWL.FADE = "Fade";
	FWL.BREAK = "Break";
	FWL.RESIST = "Resist";
	
	FWL.TICKS_COLOR = "Tick color";
	FWL.TICKS_COLOR_TT = "Set the tick colors to any color you like.";
	
	FWL.TIMER_OUTWARDS = "Highest timers outwards";
	FWL.TIMER_OUTWARDS_TT = "Bars will be sorted with the longest remaining times the furthest from the spell timer header/anchor.";
	FWL.TEST_BARS = "Enable Test Bars";
	FWL.TEST_BARS_TT = "Enable Test Bars. This option makes it easier to configure the timer without having to cast on units. You still need to select units to test target/focus settings, but this can also be yourself.";

	FWL.CAST_GLOW = "Show cast time Glow";
	FWL.CAST_GLOW_TT = "The timer bars indicate the time it will take to cast this spell or how long global cooldown would take up after the cast. This makes it much easier to time spell casts.";

	FWL.CUSTOM_TAG = "Custom tag";
	FWL.CUSTOM_TAG_TT = "Use your own customized tag for the spell timer bars.\n|cff00ff00id|r is replaced by the target's id (if any).\n|cff00ff00target|r is replaced by the target unit name (if any).\n|cff00ff00spell|r is replaced by the spell name.\n|cff00ff00stacks|r is replaced by the number of stacks of the buff/debuff (if any).";

	FWL.UNIQUE_TYPE = "Unique Type";
	FWL.UNIQUE_TYPE_TT = "Types of spells that can only be cast on one target at a time. For example most crowd control spells.";
	
	FWL.BAR_BG_ALPHA = "Empty bar alpha";
	FWL.BAR_BG_ALPHA_TT = "The alpha the 'empty' part of a timer bar will have.";
	FWL.TIMER_FORMATS = "Additional layout";
	FWL.TIMER_UNITS = "Units";
	FWL.TIMER_MAXIMUM_TIME = "Maximum Time and Hiding";
	FWL.TIMER_TICKS = "Ticks";
	FWL.TIMER_RAID_TARGET_ICONS = "Raid Target Icons";

	FWL.TIMER_SHOW_TARGET = "Show target unit";
	FWL.TIMER_SHOW_TARGET_TT = "Show the bars belonging to your current target in this timer frame instance.";
	FWL.TIMER_SHOW_FOCUS = "Show focus unit";
	FWL.TIMER_SHOW_FOCUS_TT = "Show the bars belonging to your current focus in this timer frame instance.";
	FWL.TIMER_SHOW_OTHER = "Show other units";
	FWL.TIMER_SHOW_OTHER_TT = "Show the bars belonging to all other units in this timer frame instance.";

	FWL.COOLDOWNS = "Cooldowns";
	FWL.COOLDOWNS_TT = "Show a small selection of cooldowns.";
	FWL.DEBUFFS = "Debuffs on me";
	FWL.DEBUFFS_TT = "Show a small selection of debuffs on yourself.";

	FWL.TARGET_BACKGROUND = "Target background";
	FWL.FOCUS_BACKGROUND = "Focus background";

	FWL.EXPIRED = "Expired";
	FWL.EXPIRED_TT = "Enable to make expired bars take a different color.";

	FWL._RIGHTCLICK_FOR_OPTIONS = " (right-click for options)"

	FWL.CLONES_WORKING = "CLONES AREN'T FULLY WORKING. YOU CANNOT CHANGE WHAT IS DISPLAYED IN THEM YET.";

	FWL.SHOW_WITHOUT_UNIT = "Show without target";
	FWL.TIMER_SORT_ORDER = "Spell Type sort order";
	FWL.TIMER_SORT_ORDER_TT =  "Customize the order in which the different spell types appear on the Spell Timer. The most left tag will appear the closest to the header/anchor. This setting is only used when 'Group by unit' is enabled.\n|cff00ff00buff|r are your self (powerup) buffs.\n|cff00ff00selfdebuff|r are the debuffs on yourself.\n|cff00ff00debuff|r are the raid debuffs on your current target.\n|cff00ff00cooldown|r are your cooldowns.\n|cff00ff00notarget|r are spells that don't have a target (or still need to find/correct their target).\n|cff00ff00target|r are all the other spells that have been cast on units.";

	FWL.TIMER_SPARK_TT = "Show sparks at the appropriate place in the bars.";

	FWL.SHARED_TYPE2 = "Shared Type (2)";
	FWL.SHARED_TYPE2_TT = "Types of spells that allow only one spell of this kind up on one target (for example Banes).";

	FWL.SHARED_TYPE3 = "Shared Type (3)";
	FWL.SHARED_TYPE3_TT = "Types of spells that allow only one spell of this kind up on one target.";

	FWL.TIMER_SHOW_UKNOWN = "Show unknown units";
	FWL.TIMER_SHOW_YOU = "Show on you / cooldowns";
	FWL.TIMER_RAID_DEBUFFS = "Show raid debuffs";

	FWL.SMART_COUNTDOWN_WIDTH = "Use smart countdown text width";
	FWL.SMART_COUNTDOWN_WIDTH_TT = "With this option enabled the width that the countdown text takes up, and therefore also the width of the name label, will remain the same for X seconds. This avoids erratic changes in long names and the position of the countdown texts when on the right side.";

	FWL.TIMER_SMOOTHING = "Duration update smoothing";
	FWL.TIMER_SMOOTHING_TT = "1 means timers are changed to their new duration instantly, 20 means a very smooth transition.";

	FWL.TIMER_COUNTDOWN = "Show Count down text";
	FWL.TIMER_COUNTDOWN_TT = "Show the remaining time on the bars.";

	FWL.TIMER_ICONS = "Show icons";
	FWL.TIMER_ICONS_TT = "Show the spell icons on the bars.";
	FWL.TIMER_ICONS_RIGHT = "Icons on right";
	FWL.TIMER_ICONS_RIGHT_TT = "You can display the spell icons on the left or right of the bars.";

	FWL.TIMER_STACKS = "Show stacks on icons";
	FWL.TIMER_STACKS_TT = "Show the spell stacks on the icons instead of in the bar name label.";
	FWL.TIMER_BAR_LABELS = "Show unit/spell name text";
	FWL.TIMER_BAR_LABELS_TT = "Show the bar unit/spell name labels. This may be useful for really small bars.";

	FWL.LABEL_LIMIT = "Limit name tag size";
	FWL.LABEL_LIMIT_TT = "Limit name tag size to frame width.";
	FWL.SPARK_TICK = "Spark tick indication";
	FWL.SPARK_TICK_TT = "Use the spark to indicate when your spell does damage. You can also set the maximum scale factor the spark will grow.";
	FWL.CAST_OVERLAP = "Include tick overlap";
	FWL.CAST_OVERLAP_TT = "Include the time you now have to safely overlap spells in the cast time glow.";

	FWL.SHOW_WITHOUT_UNIT_TT = "Show bars for spells that can have no or multiple targets, and are added without a specific unit assigned to it. E.g. area of effect spells.";
	FWL.TIMER_SHOW_UKNOWN_TT = "Show bars for 'unknown' units. This group of bars is created when FX detects that a spell was cast, but can't tell what unit it belongs to yet.";
	FWL.TIMER_SHOW_YOU_TT = "Show the spells that are only directly related to yourself.";
	FWL.TIMER_RAID_DEBUFFS_TT = "Show the raid debuffs on your current target.";
	
	FWL.FLIP_TAG = "Flip tag location";
	FWL.FLIP_TAG_TT = "Change the name tag/label location from before its bars, to after its bars. If this is on the top or the bottom of the group depends on the group expansion direction.";
	FWL.NAMING_GROUPING = "Naming and Grouping";
	
	FWL.CAST_GCD = "Include Global Cooldown";
	FWL.CAST_GCD_TT = "In addition to real cast times, also show the time the Global Cooldown would take up after casting.";
end