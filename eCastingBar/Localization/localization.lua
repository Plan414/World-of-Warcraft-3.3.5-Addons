-- Version : English
-- Last Update : 07/20/2008

-- Start Not Localized --
strTab = "	";
strWhite = "|cffffffff";
strYellow = "|cffffff00";
strGreen = "|cff00ff00";
-- End Not Localized --

CASTINGBAR_CHAT_C1				= "config";
CASTINGBAR_CHAT_C2				= "help";

-- Help Text
CASTINGBAR_LOADED = "Loaded.  Type /ecb for Options."
CASTINGBAR_PROFILE_LOADED = "Profile Loaded.";
CASTINGBAR_PROFILE_DELETED = "Profile Deleted.";
CASTINGBAR_PROFILE_SAVED = "Profile Saved.";
CASTINGBAR_HELP_STRING = " - Shows the config window"
CASTINGBAR_BROKENSAVE = "	First Load or broken save, Loading defaults." 
CASTINGBAR_RESET = "Resetting Default Settings"

-- Bindings
BINDING_HEADER_ECASTINGBAR = "eCastingBar"
BINDING_NAME_ECASTINGBARDLG = "Toggle Configuration Window";
ECASTINGBAR_TITLE = "Configure eCastingBar"

-- Bar Text
OUTLINE_TXT = "eCasting Bar Outline."
MIRROR_OUTLINE_TXT = "Mirror Bar Outline."
TARGET_OUTLINE_TXT = "Target Bar Outline."
FOCUS_OUTLINE_TXT = "Focus Bar Outline."

-- general buttons
CASTINGBAR_CASTING_TAB      = "Casting Bar"
CASTINGBAR_MIRROR_TAB       = "Mirror Bar"
CASTINGBAR_TARGET_TAB       = "Target Bar"
CASTINGBAR_FOCUS_TAB        = "Focus Bar"
CASTINGBAR_PROFILE_TAB      = "Profiles"
CASTINGBAR_DEFAULTS_BUTTON  = "Defaults"
CASTINGBAR_CLOSE_BUTTON     = "Close"
CASTINGBAR_SAVE_BUTTON      = "Save Settings"
CASTINGBAR_LOAD_BUTTON      = "Load"
CASTINGBAR_DELETE_BUTTON    = "Delete"

-- options
CASTING_BAR_BUTTONS = {
  ["Locked"] = "Hide Outline",
  ["Enabled"] = "Enabled",
  ["ShowTime"] = "Show Time",
  ["HideBorder"] = "Hide Border",
  ["ShowDelay"] = "Show Delay",
  ["ShowSpellName"] = "Show Spell Name",
	["ShowSpellRank"] = "Show Spell Rank",
  ["MirrorLocked"] = "Hide Outline",
  ["MirrorEnabled"] = "Enabled",
  ["MirrorShowTime"] = "Show Time",
  ["MirrorHideBorder"] = "Hide Border",
  ["MirrorUseFlightTimer"] = "Use Flight Timer",
  ["MirrorShowTimerLabel"] = "Show Timer Label",
  ["TargetBarLocked"] = "Hide Outline",
  ["TargetBarEnabled"] = "Enabled",
  ["TargetBarShowTime"] = "Show Time",
  ["TargetBarHideBorder"] = "Hide Border",
  ["TargetBarShowDelay"] = "Show Delay",
  ["TargetBarShowSpellName"] = "Show Spell Name",
	["TargetBarShowSpellRank"] = "Show Spell Rank",
  ["FocusBarLocked"] = "Hide Outline",
  ["FocusBarEnabled"] = "Enabled",
  ["FocusBarShowTime"] = "Show Time",
  ["FocusBarHideBorder"] = "Hide Border",
  ["FocusBarShowDelay"] = "Show Delay",
  ["FocusBarShowSpellName"] = "Show Spell Name",
	["FocusBarShowSpellRank"] = "Show Spell Rank"
}

CASTINGBAR_SLIDER_WIDTH_TEXT            = "Width"
CASTINGBAR_SLIDER_HEIGHT_TEXT           = "Height"
CASTINGBAR_SLIDER_LEFT_TEXT             = "X"
CASTINGBAR_SLIDER_BOTTOM_TEXT           = "Y"
CASTINGBAR_SLIDER_FONT_TEXT             = "Font Size"
CASTINGBAR_SLIDER_ALPHA_TEXT            = "Background Alpha"
CASTINGBAR_CASTINGBAR_TEXTURE_TEXT      = "Casting Bar Texture"
CASTINGBAR_MIRRORBAR_TEXTURE_TEXT       = "Mirror Bar Texture"
CASTINGBAR_TARGETBAR_TEXTURE_TEXT       = "Target Bar Texture"
CASTINGBAR_FOCUSBAR_TEXTURE_TEXT        = "Focus Bar Texture"
CASTINGBAR_ICON_POSITION_TEXT           = "Spell Icon Position"
CASTINGBAR_LEFT_TEXT                    = "Left"
CASTINGBAR_RIGHT_TEXT                   = "Right"
CASTINGBAR_HIDDEN_TEXT                  = "Hidden"

-- color
CASTINGBAR_COLOR_LABEL = {
  ["SpellColor"] = "Spell",
  ["ChannelColor"] = "Channel",
  ["SuccessColor"] = "Success",
  ["FailedColor"] = "Failed",
  ["TimeColor"] = "Time",
  ["DelayColor"] = "Delay",
  ["FlashBorderColor"] = "Flash Border",
  ["FeignDeathColor"] = "Feign Death",
  ["ExhaustionColor"] = "Exhaustion",
  ["BreathColor"] = "Breath",
  ["FlightColor"] = "Flight Color",
  ["MirrorTimeColor"] = "Mirror Time",
  ["MirrorFlashBorderColor"] = "Mirror Flash Border",
  ["TargetBarSpellColor"] = "Target Spell",
  ["TargetBarChannelColor"] = "Target Channel",
  ["TargetBarSuccessColor"] = "Target Success",
  ["TargetBarFailedColor"] = "Target Failed",
  ["TargetBarTimeColor"] = "Target Time",
  ["TargetBarDelayColor"] = "Target Delay",
  ["TargetBarFlashBorderColor"] = "Target Flash Border",
  ["FocusBarSpellColor"] = "Focus Spell",
  ["FocusBarChannelColor"] = "Focus Channel",
  ["FocusBarSuccessColor"] = "Focus Success",
  ["FocusBarFailedColor"] = "Focus Failed",
  ["FocusBarTimeColor"] = "Focus Time",
  ["FocusBarDelayColor"] = "Focus Delay",
  ["FocusBarFlashBorderColor"] = "Focus Flash Border",
}



----------------------------------
-- Version : Korean
-- Korean text by Bitz
----------------------------------

if ( GetLocale() == "koKR" ) then

CASTINGBAR_CHAT_C1	= "설정";
CASTINGBAR_CHAT_C2	= "도움말";

-- Help Text
CASTINGBAR_LOADED 					= "|1이;가; 실행되었습니다. 설정 명령어: /시전바";
CASTINGBAR_PROFILE_LOADED 	= "프로파일을 불러왔습니다.";
CASTINGBAR_PROFILE_SAVED 		= "프로파일이 저장되었습니다.";
CASTINGBAR_PROFILE_DELETED	= "프로파일이 삭제되었습니다.";
CASTINGBAR_HELP_STRING 			= " - 설정 창을 엽니다."
CASTINGBAR_BROKENSAVE 			= "처음 사용하는 것이거나 저장된 설정값에 오류가 있습니다. 초기값을 불러옵니다." 
CASTINGBAR_RESET 						= "설정을 초기화합니다."

-- Bindings
BINDING_HEADER_ECASTINGBAR  = "eCastingBar"
BINDING_NAME_ECASTINGBARDLG = "설정 창 열기/닫기";

-- Bar Text
OUTLINE_TXT         = "시전바 위치 조정"
MIRROR_OUTLINE_TXT  = "타이머바 위치 조정"
TARGET_OUTLINE_TXT  = "대상 시전바 위치 조정"
FOCUS_OUTLINE_TXT 	= "주시 대상 시전바 위치 조정"

-- genral
ECASTINGBAR_TITLE           = "eCastingBar 설정"

CASTINGBAR_CASTING_TAB      = "시전바"
CASTINGBAR_MIRROR_TAB       = "타이머바"
CASTINGBAR_TARGET_TAB       = "대상 시전바"
CASTINGBAR_FOCUS_TAB        = "주시 대상 시전바"
CASTINGBAR_PROFILE_TAB      = "프로파일"
CASTINGBAR_DEFAULTS_BUTTON  = "초기화"
CASTINGBAR_CLOSE_BUTTON     = "닫기"
CASTINGBAR_SAVE_BUTTON      = "설정 저장"
CASTINGBAR_LOAD_BUTTON      = "불러오기"
CASTINGBAR_DELETE_BUTTON    = "지우기"

-- options
CASTING_BAR_BUTTONS = {
  ["Locked"]                  = " 시전바 위치 잠금",
  ["Enabled"]                 = " 시전바 사용",
  ["ShowTime"]                = " 시전 시간 표시",
  ["HideBorder"]              = " 외곽선 숨기기",
  ["ShowDelay"]               = " 시전 지연 시간 표시",
  ["ShowSpellName"]           = " 주문 이름 표시",
  ["ShowSpellRank"]           = " 주문 레벨 표시",
  ["MirrorLocked"]            = " 타이머바 위치 잠금",
  ["MirrorEnabled"]           = " 타이머바 사용",
  ["MirrorShowTime"]          = " 남은 시간 표시",
  ["MirrorHideBorder"]        = " 외곽선 숨기기",
  ["MirrorUseFlightTimer"]    = " 비행 타이머 사용",
  ["MirrorShowTimerLabel"]    = " 상태 이름 표시",
  ["TargetBarLocked"]         = " 대상 시전바 위치 잠금",
  ["TargetBarEnabled"]        = " 대상 시전바 사용",
  ["TargetBarShowTime"]       = " 시전 시간 표시",
  ["TargetBarHideBorder"]     = " 외곽선 숨기기",
  ["TargetBarShowDelay"]      = " 시전 지연 시간 표시",
  ["TargetBarShowSpellName"]  = " 주문 이름 표시",
  ["TargetBarShowSpellRank"]  = " 주문 레벨 표시",
  ["FocusBarLocked"]					= " 주시 대상 시전바 위치 잠금",
  ["FocusBarEnabled"]					= " 주시 대상 시전바 사용",
  ["FocusBarShowTime"]				= " 시전 시간 표시",
  ["FocusBarHideBorder"]			= " 외곽선 숨기기",
  ["FocusBarShowDelay"]				= " 시전 지연 시간 표시",
  ["FocusBarShowSpellName"]		= " 주문 이름 표시",
  ["FocusBarShowSpellRank"]		= " 주문 레벨 표시",
}

CASTINGBAR_SLIDER_WIDTH_TEXT        = "넓이"
CASTINGBAR_SLIDER_HEIGHT_TEXT       = "높이"
CASTINGBAR_SLIDER_LEFT_TEXT         = "X 좌표"
CASTINGBAR_SLIDER_BOTTOM_TEXT       = "Y 좌표"
CASTINGBAR_SLIDER_FONT_TEXT         = "글자 크기"
CASTINGBAR_SLIDER_ALPHA_TEXT        = "배경 투명도"
CASTINGBAR_CASTINGBAR_TEXTURE_TEXT  = "시전바 텍스쳐"
CASTINGBAR_MIRRORBAR_TEXTURE_TEXT   = "타이머바 텍스쳐"
CASTINGBAR_TARGETBAR_TEXTURE_TEXT   = "시전바 텍스쳐"
CASTINGBAR_FOCUSBAR_TEXTURE_TEXT    = "주시 대상 시전바 텍스쳐"
CASTINGBAR_ICON_POSITION_TEXT       = "주문 아이콘 표시"
CASTINGBAR_LEFT_TEXT                = "왼쪽"
CASTINGBAR_RIGHT_TEXT               = "오른쪽"
CASTINGBAR_HIDDEN_TEXT              = "숨기기"

-- color
CASTINGBAR_COLOR_LABEL = {
  ["SpellColor"]                = "주문 시전",
  ["ChannelColor"]              = "정신 집중",
  ["SuccessColor"]              = "시전 성공",
  ["FailedColor"]               = "시전 실패",
  ["TimeColor"]                 = "시전 시간",
  ["DelayColor"]                = "시전 지연 시간",
  ["FlashBorderColor"]          = "외곽선 번쩍임",
  ["FeignDeathColor"]           = "죽은 척 하기",
  ["ExhaustionColor"]           = "피로",
  ["BreathColor"]               = "호흡",
  ["FlightColor"]               = "비행",
  ["MirrorTimeColor"]           = "남은 시간",
  ["MirrorFlashBorderColor"]    = "외곽선 번쩍임",
  ["TargetBarSpellColor"]       = "주문 시전",
  ["TargetBarChannelColor"]     = "정신 집중",
  ["TargetBarSuccessColor"]     = "시전 성공",
  ["TargetBarFailedColor"]      = "시전 실패",
  ["TargetBarTimeColor"]        = "시전 시간",
  ["TargetBarDelayColor"]       = "시전 지연 시간",
  ["TargetBarFlashBorderColor"] = "외곽선 번쩍임",
  ["FocusBarSpellColor"] 				= "주문 시전",
  ["FocusBarChannelColor"] 			= "정신 집중",
  ["FocusBarSuccessColor"] 			= "시전 성공",
  ["FocusBarFailedColor"] 			= "시전 실패",
  ["FocusBarTimeColor"] 				= "시전 시간",
  ["FocusBarDelayColor"] 				= "시전 지연 시간",
  ["FocusBarFlashBorderColor"] 	= "외곽선 번쩍임",
}
end

----------------------------------
-- Version : French
-- French text by Malkoms
----------------------------------

if ( GetLocale() == "frFR" ) then

-- Help Text
CASTINGBAR_LOADED = "Charge\195\169e.  Taper /ecb pour les Options."
CASTINGBAR_PROFILE_LOADED = "Profil Charge\195\169.";
CASTINGBAR_PROFILE_DELETED = "Profil Effac\195\169.";
CASTINGBAR_PROFILE_SAVED = "Profil Sauv\195\169.";
CASTINGBAR_HELP_STRING = " - Affiche la fen\195\170tre de Configuration"
CASTINGBAR_BROKENSAVE = "	1er Chargement ou Sauvegarde abim\195\169e, Chargement des Options par d\195\169faut."  
CASTINGBAR_RESET = "Options par d\195\169faut"


-- Bindings
BINDING_HEADER_ECASTINGBAR = "eCastingBar"
BINDING_NAME_ECASTINGBARDLG = "Afficher la fen\195\170tre de Configuration";
ECASTINGBAR_TITLE = "Configuration de eCB"

-- Bar Text
OUTLINE_TXT = "Barre de Cast"
MIRROR_OUTLINE_TXT = "Barre Miroir"
TARGET_OUTLINE_TXT = "Barre Cible"
FOCUS_OUTLINE_TXT = "Barre Focus"

-- general buttons
CASTINGBAR_CASTING_TAB      = "Barre de Cast"
CASTINGBAR_MIRROR_TAB       = "Barre Miroir"
CASTINGBAR_TARGET_TAB       = "Barre Cible"
CASTINGBAR_FOCUS_TAB        = "Barre Focus"
CASTINGBAR_PROFILE_TAB      = "Profils"
CASTINGBAR_DEFAULTS_BUTTON  = "D\195\169faut"
CASTINGBAR_CLOSE_BUTTON     = "Fermer"
CASTINGBAR_SAVE_BUTTON      = "Sauver"
CASTINGBAR_LOAD_BUTTON      = "Charger"
CASTINGBAR_DELETE_BUTTON    = "Effacer"

-- options
CASTING_BAR_BUTTONS = {
  ["Locked"] = "Cacher les contours",
  ["Enabled"] = "Activ\195\169",
  ["ShowTime"] = "Afficher le temps",
  ["HideBorder"] = "Cacher la Bordure",
  ["ShowDelay"] = "Afficher le D\195\169lai",
  ["ShowSpellName"] = "Afficher le Nom du Sort",
  ["ShowSpellRank"] = "Afficher le Rang du Sort",
  ["MirrorLocked"] = "Cacher les contours",
  ["MirrorEnabled"] = "Activ\195\169",
  ["MirrorShowTime"] = "Afficher le temps",
  ["MirrorHideBorder"] = "Cacher la Bordure",
  ["MirrorUseFlightTimer"] = "Utiliser le Timer de Vol",
  ["MirrorShowTimerLabel"] = "Afficher le Libell\195\169 du Vol",
  ["TargetBarLocked"] = "Cacher les contours",
  ["TargetBarEnabled"] = "Activ\195\169",
  ["TargetBarShowTime"] = "Afficher le temps",
  ["TargetBarHideBorder"] = "Cacher la Bordure",
  ["TargetBarShowDelay"] = "Afficher le D\195\169lai",
  ["TargetBarShowSpellName"] = "Afficher le Nom du Sort",
  ["TargetBarShowSpellRank"] = "Afficher le Rang du Sort",
  ["FocusBarLocked"] = "Cacher les contours",
  ["FocusBarEnabled"] = "Activ\195\169",
  ["FocusBarShowTime"] = "Afficher le temps",
  ["FocusBarHideBorder"] = "Cacher la Bordure",
  ["FocusBarShowDelay"] = "Afficher le D\195\169lai",
  ["FocusBarShowSpellName"] = "Afficher le Nom du Sort",
  ["FocusBarShowSpellRank"] = "Afficher le Rang du Sort",
}

CASTINGBAR_SLIDER_WIDTH_TEXT            = "Largeur"
CASTINGBAR_SLIDER_HEIGHT_TEXT           = "Hauteur"
CASTINGBAR_SLIDER_LEFT_TEXT             = "X"
CASTINGBAR_SLIDER_BOTTOM_TEXT           = "Y"
CASTINGBAR_SLIDER_FONT_TEXT             = "Taille de la Police"
CASTINGBAR_SLIDER_ALPHA_TEXT            = "Alpha de Fond"
CASTINGBAR_CASTINGBAR_TEXTURE_TEXT      = "Texture de la Barre de Cast"
CASTINGBAR_MIRRORBAR_TEXTURE_TEXT       = "Texture de la Barre Miroir"
CASTINGBAR_TARGETBAR_TEXTURE_TEXT       = "Texture de la Barre Cible"
CASTINGBAR_FOCUSBAR_TEXTURE_TEXT        = "Texture de la Barre Focus"
CASTINGBAR_ICON_POSITION_TEXT           = "Icone du Sort"
CASTINGBAR_LEFT_TEXT                    = "Gauche"
CASTINGBAR_RIGHT_TEXT                   = "Droite"
CASTINGBAR_HIDDEN_TEXT                  = "Cacher"

-- color
CASTINGBAR_COLOR_LABEL = {
  ["SpellColor"] = "Sort",
  ["ChannelColor"] = "Canal",
  ["SuccessColor"] = "Succ\195\168s",
  ["FailedColor"] = "Echou\195\169",
  ["TimeColor"] = "Temps",
  ["DelayColor"] = "D\195\169lais",
  ["FlashBorderColor"] = "Flash",
  ["FeignDeathColor"] = "Feinte de la Mort",
  ["ExhaustionColor"] = "Epuisement",
  ["BreathColor"] = "Souffle",
  ["FlightColor"] = "Vol",
  ["MirrorTimeColor"] = "Temps",
  ["MirrorFlashBorderColor"] = "Flash",
  ["TargetBarSpellColor"] = "Sort",
  ["TargetBarChannelColor"] = "Canal",
  ["TargetBarSuccessColor"] = "Succ\195\168s",
  ["TargetBarFailedColor"] = "Echou\195\169",
  ["TargetBarTimeColor"] = "Temps",
  ["TargetBarDelayColor"] = "D\195\169lai",
  ["TargetBarFlashBorderColor"] = "Flash",
  ["FocusBarSpellColor"] = "Sort",
  ["FocusBarChannelColor"] = "Canal",
  ["FocusBarSuccessColor"] = "Succ\195\168s",
  ["FocusBarFailedColor"] = "Echou\195\169",
  ["FocusBarTimeColor"] = "Temps",
  ["FocusBarDelayColor"] = "D\195\169lai",
  ["FocusBarFlashBorderColor"] = "Flash",
}
end                  

----------------------------------
-- Version : zhCN
-- Chinese text by wowui.cn
----------------------------------

if ( GetLocale() == "zhCN" ) then

-- Help Text
CASTINGBAR_LOADED = "已加载.  输入 /ecb 进行配置."
CASTINGBAR_PROFILE_LOADED = "配置文件已加载.";
CASTINGBAR_PROFILE_DELETED = "配置文件已删除.";
CASTINGBAR_PROFILE_SAVED = "配置文件已保存.";
CASTINGBAR_HELP_STRING = " - 显示插件设置窗口"
CASTINGBAR_BROKENSAVE = "	初次加载或配置文件已损坏,正在加载默认配置."  
CASTINGBAR_RESET = "重置为默认配置"


-- Bindings
BINDING_HEADER_ECASTINGBAR = "eCastingBar"
BINDING_NAME_ECASTINGBARDLG = "插件设置窗口开关";
ECASTINGBAR_TITLE = "设置"

-- Bar Text
OUTLINE_TXT = "施法条文字"
MIRROR_OUTLINE_TXT = "镜像施法条"
TARGET_OUTLINE_TXT = "目标施法条"
FOCUS_OUTLINE_TXT = "焦点施法条"

-- general buttons
CASTINGBAR_CASTING_TAB      = "施法条"
CASTINGBAR_MIRROR_TAB       = "镜像施法条"
CASTINGBAR_TARGET_TAB       = "目标施法条"
CASTINGBAR_FOCUS_TAB        = "焦点施法条"
CASTINGBAR_PROFILE_TAB      = "配置文件"
CASTINGBAR_DEFAULTS_BUTTON  = "默认配置"
CASTINGBAR_CLOSE_BUTTON     = "关闭"
CASTINGBAR_SAVE_BUTTON      = "保存设置"
CASTINGBAR_LOAD_BUTTON      = "加载"
CASTINGBAR_DELETE_BUTTON    = "删除"

-- options
CASTING_BAR_BUTTONS = {
  ["Locked"] = "锁定",
  ["Enabled"] = "启用",
  ["ShowTime"] = "显示时间",
  ["HideBorder"] = "隐藏边框",
  ["ShowDelay"] = "显示延迟",
  ["ShowSpellName"] = "显示法术名称",
  ["ShowSpellRank"] = "显示法术等级",
  ["MirrorLocked"] = "锁定",
  ["MirrorEnabled"] = "启用",
  ["MirrorShowTime"] = "显示时间",
  ["MirrorHideBorder"] = "隐藏边框",
  ["MirrorUseFlightTimer"] = "飞行时间",
  ["MirrorShowTimerLabel"] = "时间标签",
  ["TargetBarLocked"] = "锁定",
  ["TargetBarEnabled"] = "启用",
  ["TargetBarShowTime"] = "显示时间",
  ["TargetBarHideBorder"] = "隐藏边框",
  ["TargetBarShowDelay"] = "显示延迟",
  ["TargetBarShowSpellName"] = "显示法术名称",
  ["TargetBarShowSpellRank"] = "显示法术等级",
  ["FocusBarLocked"] = "锁定",
  ["FocusBarEnabled"] = "启用",
  ["FocusBarShowTime"] = "显示时间",
  ["FocusBarHideBorder"] = "隐藏边框",
  ["FocusBarShowDelay"] = "显示延迟",
  ["FocusBarShowSpellName"] = "显示法术名字",
  ["FocusBarShowSpellRank"] = "显示法术等级",
}

CASTINGBAR_SLIDER_WIDTH_TEXT            = "宽"
CASTINGBAR_SLIDER_HEIGHT_TEXT           = "高"
CASTINGBAR_SLIDER_LEFT_TEXT             = "X"
CASTINGBAR_SLIDER_BOTTOM_TEXT           = "Y"
CASTINGBAR_SLIDER_FONT_TEXT             = "文字大小"
CASTINGBAR_SLIDER_ALPHA_TEXT            = "背景透明"
CASTINGBAR_CASTINGBAR_TEXTURE_TEXT      = "施法条材质"
CASTINGBAR_MIRRORBAR_TEXTURE_TEXT       = "镜像施法条材质"
CASTINGBAR_TARGETBAR_TEXTURE_TEXT       = "目标施法条材质"
CASTINGBAR_FOCUSBAR_TEXTURE_TEXT        = "焦点施法条材质"
CASTINGBAR_ICON_POSITION_TEXT           = "法术图标位置"
CASTINGBAR_LEFT_TEXT                    = "左"
CASTINGBAR_RIGHT_TEXT                   = "右"
CASTINGBAR_HIDDEN_TEXT                  = "隐藏"

-- color
CASTINGBAR_COLOR_LABEL = {
  ["SpellColor"] = "法术",
  ["ChannelColor"] = "通道法术",
  ["SuccessColor"] = "施法成功",
  ["FailedColor"] = "施法失败",
  ["TimeColor"] = "时间",
  ["DelayColor"] = "延迟",
  ["FlashBorderColor"] = "边框闪烁",
  ["FeignDeathColor"] = "假死",
  ["ExhaustionColor"] = "疲劳",
  ["BreathColor"] = "呼吸",
  ["FlightColor"] = "飞行",
  ["MirrorTimeColor"] = "时间",
  ["MirrorFlashBorderColor"] = "边框闪烁",
  ["TargetBarSpellColor"] = "法术",
  ["TargetBarChannelColor"] = "通道法术",
  ["TargetBarSuccessColor"] = "施法成功",
  ["TargetBarFailedColor"] = "施法失败",
  ["TargetBarTimeColor"] = "时间",
  ["TargetBarDelayColor"] = "延迟",
  ["TargetBarFlashBorderColor"] = "边框闪烁",
  ["FocusBarSpellColor"] = "法术",
  ["FocusBarChannelColor"] = "通道法术",
  ["FocusBarSuccessColor"] = "施法成功",
  ["FocusBarFailedColor"] = "施法失败",
  ["FocusBarTimeColor"] = "时间",
  ["FocusBarDelayColor"] = "颜色",
  ["FocusBarFlashBorderColor"] = "边框闪烁",
}
end                  