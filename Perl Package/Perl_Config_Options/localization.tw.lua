if (GetLocale() == "zhTW") then
	-- Buttons and Titles
	PERL_LOCALIZED_CONFIG_ALL = "全局設定";
	PERL_LOCALIZED_CONFIG_ARCANEBAR = "施法條設定";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY = "戰鬥狀態條";
	PERL_LOCALIZED_CONFIG_FOCUS = "Focus";
	PERL_LOCALIZED_CONFIG_PARTY = "隊伍訊息設定";
	PERL_LOCALIZED_CONFIG_PARTYPET = "隊伍寵物設定";
	PERL_LOCALIZED_CONFIG_PARTYTARGET = "隊伍目標設定";
	PERL_LOCALIZED_CONFIG_PLAYER = "玩家訊息設定";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF = "玩家Buff設定";
	PERL_LOCALIZED_CONFIG_PLAYERPET = "玩家寵物設定";
	PERL_LOCALIZED_CONFIG_TARGET = "目標訊息設定";
	PERL_LOCALIZED_CONFIG_TARGETTARGET = "目標的目標";

	-- Perl Config Shared Strings
	PERL_LOCALIZED_CONFIG_TRANSPARENCY = "透明度";
	PERL_LOCALIZED_CONFIG_SCALING = "縮放比例";
	PERL_LOCALIZED_CONFIG_SCALING_SET_CURRENT = "設定為當前UI的縮放比例";
	PERL_LOCALIZED_CONFIG_MISC = "其他設置";
	PERL_LOCALIZED_CONFIG_DISPLAY_MODE = "顯示模式";
	PERL_LOCALIZED_CONFIG_DRUIDBAR = "支持Druid Bar插件";
	PERL_LOCALIZED_CONFIG_RESET_FRAMES = "重設所有框體";
	PERL_LOCALIZED_CONFIG_PORTRAITS = "顯示人物頭像";
	PERL_LOCALIZED_CONFIG_THREED_PORTRAITS = "顯示3D人物頭像";
	PERL_LOCALIZED_CONFIG_ALWAYS_SHOWN = "始終顯示";
	PERL_LOCALIZED_CONFIG_HIDDEN_IN_RAID = "在團隊是隱藏";
	PERL_LOCALIZED_CONFIG_ALWAYS_HIDDEN = "始終隱藏";
	PERL_LOCALIZED_CONFIG_BUFF_LOCATION = "Buff 位置";
	PERL_LOCALIZED_CONFIG_DEBUFF_LOCATION = "Debuff 位置";
	PERL_LOCALIZED_CONFIG_BUFF_SIZE_SMALL = "Buff 大小 (預設為12)";
	PERL_LOCALIZED_CONFIG_DEBUFF_SIZE_SMALL = "Debuff 大小 (預設為12)";
	PERL_LOCALIZED_CONFIG_BUFF_SIZE_LARGE = "Buff 大小 (預設為16)";
	PERL_LOCALIZED_CONFIG_DEBUFF_SIZE_LARGE = "Debuff 大小 (預設為16)";
	PERL_LOCALIZED_CONFIG_BUFF_NUMBER = "Buff 數量";
	PERL_LOCALIZED_CONFIG_DEBUFF_NUMBER = "Debuff 數量";
	PERL_LOCALIZED_CONFIG_COMBAT_TEXT = "戰鬥信息";
	PERL_LOCALIZED_CONFIG_COMPACT = "簡潔模式";
	PERL_LOCALIZED_CONFIG_DISPLAY_PERCENTS = "顯示百分比";
	PERL_LOCALIZED_CONFIG_SHORT_BARS = "簡略狀態條";
	PERL_LOCALIZED_CONFIG_VERTICAL_FRAMES = "垂直顯示團隊框體";
	PERL_LOCALIZED_CONFIG_HIDE_CLASSICON_FRAME = "隱藏職業圖示";
	PERL_LOCALIZED_CONFIG_HEALER_MODE = "治療者模式";
	PERL_LOCALIZED_CONFIG_PET_SUPPORT = "顯示寵物訊息條";
	PERL_LOCALIZED_CONFIG_CLASS_COLORED_NAMES = "根據職業改變名字顏色";
	PERL_LOCALIZED_CONFIG_SMALL = "小";
	PERL_LOCALIZED_CONFIG_BIG = "大";
	PERL_LOCALIZED_CONFIG_HIDE_POWER_BARS = "隱藏能量條";
	PERL_LOCALIZED_CONFIG_DISPLAY_MANA_DEFICIT = "顯示能量消耗百分比";
	PERL_LOCALIZED_CONFIG_PVP_STATUS_ICON = "PvP 狀態圖示";
	PERL_LOCALIZED_CONFIG_SHOW_BAR_VALUES = "顯示狀態和能量條數值";
	PERL_LOCALIZED_CONFIG_INVERT_BAR_VALUES = "反轉狀態和能量條數值";
	PERL_LOCALIZED_CONFIG_COLOR_FRAME_DEBUFF = "以顏色框體顯示Debuff";

	-- Perl Config Generic
	PERL_LOCALIZED_CONFIG_HEADER = "Perl控制面板";
	PERL_LOCALIZED_CONFIG_CLOSE = "關閉";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED = "未載入";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED_EXPLANATION = "需要的插件沒有安裝或者啟用";

	-- Perl Config All
	PERL_LOCALIZED_CONFIG_ALL_TEXTURED_BARS = "狀態條背景";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_ONE = "紋理 #1";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_TWO = "紋理 #2";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_THREE = "紋理 #3";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_FOUR = "紋理 #4";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_FIVE = "紋理 #5";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_SIX = "紋理 #6";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_NONE = "無紋理";
	PERL_LOCALIZED_CONFIG_ALL_MINIMAP_POSITION = "小地圖按鈕的位置";
	PERL_LOCALIZED_CONFIG_ALL_SHOW_MINIMAP = "顯示小地圖按鈕";
	PERL_LOCALIZED_CONFIG_ALL_FRAMES = "框體";
	PERL_LOCALIZED_CONFIG_ALL_TRANSPARENT_BACKGROUND = "透明背景";
	PERL_LOCALIZED_CONFIG_ALL_LOCK_ALL = "鎖定所有框體";
	PERL_LOCALIZED_CONFIG_ALL_UNLOCK_ALL = "解鎖所有框體";
	PERL_LOCALIZED_CONFIG_ALL_LOAD = "載入全局設定";
	PERL_LOCALIZED_CONFIG_ALL_SAVE = "保存全局設定";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 全局設定讀取成功.";
	PERL_LOCALIZED_CONFIG_ALL_SAVE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 全局設定保存成功.";
	PERL_LOCALIZED_CONFIG_ALL_RESET_FRAMES_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 窗體位置已重置.";
	PERL_LOCALIZED_CONFIG_ALL_CLICKHEALING = "支持CastParty/Genesis/AceHeal/ClickHeal";
	PERL_LOCALIZED_CONFIG_ALL_PROGRESSIVE = "生命條顏色動態變化";
	PERL_LOCALIZED_CONFIG_ALL_NO_PROFILE_SELECTED_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 沒有選擇任何框體項目.";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 框體項目設定載入成功: ";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_HEADER = "載入框體項目";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_BUTTON = "載入";
	PERL_LOCALIZED_CONFIG_ALL_DELETE_PROFILE_BUTTON = "刪除";
	PERL_LOCALIZED_CONFIG_ALL_DELETE_PROFILE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 框體項目設定從列表裡移除: ";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURED_BACKGROUND = "有紋理的背景條";
	PERL_LOCALIZED_CONFIG_ALL_FADE_BARS = "背景條淺色隱藏";
	PERL_LOCALIZED_CONFIG_ALL_CLICKCASTABLE_NAME_FRAMES = "點擊目標框體施法";
	PERL_LOCALIZED_CONFIG_ALL_MINIMAP_RADIUS = "MiniMap Button Radius";

	-- Perl Config ArcaneBar
	PERL_LOCALIZED_CONFIG_ARCANEBAR_ENABLE = "啟用"..PERL_LOCALIZED_CONFIG_ARCANEBAR;
	PERL_LOCALIZED_CONFIG_ARCANEBAR_DISPLAY_TIMER = "顯示施法時間";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_HIDE_BLIZZARD = "隱藏系統施法條";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_REPLACE_NAME = "按照規則順序重新排列玩家姓名";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_LEFT_TIMER = "Left Align Cast Timer";

	-- Perl Config CombatDisplay
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_PERSIST_MODES = "治療模式";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_TARGET_SETTINGS = "目標設置";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_AUTOATTACK = "自動攻擊模式";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_ONAGRO = "戰鬥狀態模式";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_HEALTH_PERSIST = "生命值動態模式";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MANA_PERSIST = "法力動態模式";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MENU = "啟用右鍵目錄";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_COMBATDISPLAY.."框體";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_ENABLE_TARGET = "啟用目標框體";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_DISPLAY_COMBOPOINT_BAR = "顯示連擊點數條";

	-- Perl Config Party
	PERL_LOCALIZED_CONFIG_PARTY_SPACING = "間距 (預設為95)";
	PERL_LOCALIZED_CONFIG_PARTY_FKEYS = "顯示F鍵";
	PERL_LOCALIZED_CONFIG_PARTY_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_PARTY.."框體";

	-- Perl Config Party Pet
	PERL_LOCALIZED_CONFIG_PARTYPET_ENABLE = "開啟"..PERL_LOCALIZED_CONFIG_PARTYPET.." 框體";
	PERL_LOCALIZED_CONFIG_PARTYPET_RESET_FRAMES_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": "..PERL_LOCALIZED_CONFIG_PARTYPET.."框體位置已經被重置";
	PERL_LOCALIZED_CONFIG_PARTYPET_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_PARTYPET.."框體";

	-- Perl Config Party Target
	PERL_LOCALIZED_CONFIG_PARTYTARGET_ENABLE = "開啟"..PERL_LOCALIZED_CONFIG_PARTYTARGET.."框體";
	PERL_LOCALIZED_CONFIG_PARTYTARGET_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_PARTYTARGET.."框體";

	-- Perl Config Player
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_MODE = "經驗值條模式";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_EXPERIENCE = "經驗值";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_PVPRANK = "PvP 軍階";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_REPUTATION = "聲望值";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_HIDDEN = "隱藏";
	PERL_LOCALIZED_CONFIG_PLAYER_RAID_GROUP = "顯示團隊隊伍編號";
	PERL_LOCALIZED_CONFIG_PLAYER_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_PLAYER.."框體";
	PERL_LOCALIZED_CONFIG_PLAYER_RAID_GROUP_IN_NAME = "在名稱框體中顯示在團隊中的小隊編號";
	
	-- Perl Config Player Buff
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_ENABLE = "開啟玩家Buffs框體";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_WARNING = "開啟Buffs時間剩餘30秒提示訊息";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HIDESECONDS = "隱藏秒數";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HORIZONTAL_SPACING = "Buffs水平間隔(預設為10)";

	-- Perl Config Player Pet
	PERL_LOCALIZED_CONFIG_PLAYERPET_EXPERIENCE = "顯示寵物經驗條";
	PERL_LOCALIZED_CONFIG_PLAYERPET_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_PLAYERPET.."框體";
	PERL_LOCALIZED_CONFIG_PLAYERPET_HIDENAME = "隱藏名稱";

	-- Perl Config Target
	PERL_LOCALIZED_CONFIG_TARGET_BUFFDEBUFF_SCALING = "Buff/Debuff 圖標縮放(預設為100)";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_LOCATION = "連擊點顯示位置";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_ICON = "職業圖示";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_FRAME = "職業框體";
	PERL_LOCALIZED_CONFIG_TARGET_RARE_ELITE_FRAME = "稀有怪/精英 框體";
	PERL_LOCALIZED_CONFIG_TARGET_HIDE_BUFFDEBUFF_BACKGROUND = "隱藏 Buff/Debuff 背景";
	PERL_LOCALIZED_CONFIG_TARGET_SOUND_ON_TARGET_CHANGE = "目標變化聲音提示";
	PERL_LOCALIZED_CONFIG_TARGET_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_TARGET.."框體";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_POINT_FRAME = "連擊點框體";
	PERL_LOCALIZED_CONFIG_TARGET_DISPLAY_IN_NAME_FRAME = "顯示在姓名欄";
	PERL_LOCALIZED_CONFIG_TARGET_DEBUFF_STACKS_IN_COMBO_FRAME = "顯示Debuff疊加數連擊點框體";
	PERL_LOCALIZED_CONFIG_TARGET_ALTERNATE_FRAME_STYLE = "改變框體風格";
	PERL_LOCALIZED_CONFIG_TARGET_INVERT_BUFFS_DEBUFFS = "反轉Buffs/Debuffs";
	PERL_LOCALIZED_CONFIG_TARGET_GUILD_FRAME = "公會名稱框體";

	-- Perl Config Target Target
	PERL_LOCALIZED_CONFIG_TARGETTARGET_MAIN = "主選項";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ALERT_MODE = "警報模式";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ALERT_SIZE = "警告訊息字體大小";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ENABLE_TOT = "啟用目標的目標";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ENABLE_TOTOT = "啟用目標的目標的目標";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_AUDIO_ALERT_ON_AGRO = "OT音頻警報";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_LOCK = "鎖定"..PERL_LOCALIZED_CONFIG_TARGETTARGET.."框體";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOT_BUFFS = "顯示目標的目標的Buffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOT_DEBUFFS = "顯示目標的目標的Debuffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOTOT_BUFFS = "顯示目標的目標的目標的Buffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOTOT_DEBUFFS = "顯示目標的目標的目標的Debuffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_DPS_MODE = "DPS 模式";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TANK_MODE = "Tank 模式";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_HEALER_MODE = "治療者模式";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SMALL_TEXT = "小字體(提示訊息)";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_LARGE_TEXT = "大字體(提示訊息)";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_NO_TEXT = "無字體(無提示訊息)";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_RIGHT_OF_TARGET_FRAME = "目標的目標框體置右";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TOP_OF_TARGET_FRAME = "目標的目標框體置頂";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_RIGHT_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 目標的目標窗體已靠右排列.";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TOP_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": 目標的目標窗體已置頂排列.";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_FRIENDLY_HEALTH = "顯示友好的生命數值";
end
