-- Global constants
CASTING_BAR_MAJOR_VERSION = "3";
CASTING_BAR_MINOR_VERSION = "3";
CASTING_BAR_REVISION = "0";
CASTING_BAR_ALPHA_STEP = 0.05;
CASTING_BAR_FLASH_STEP = 0.2;
CASTING_BAR_HOLD_TIME = 1;
CASTING_BAR_WIDTH = 264;
CASTING_BAR_HEIGHT = 30;
CASTING_BAR_LEFT = (GetScreenWidth()-CASTING_BAR_WIDTH)/2
CASTING_BAR_SLIDER_WIDTH_MIN = 100;
CASTING_BAR_SLIDER_WIDTH_MAX = 2000;
CASTING_BAR_SLIDER_HEIGHT_MIN = 20;
CASTING_BAR_SLIDER_HEIGHT_MAX = 60;
CASTING_BAR_SPELL_JUSTIFY = "Center";
CASTINGBAR_ICON_POSITION = {
	{ text = CASTINGBAR_LEFT_TEXT, value = "LEFT"},
	{ text = CASTINGBAR_RIGHT_TEXT, value = "RIGHT"},
	{ text = CASTINGBAR_HIDDEN_TEXT, value = "HIDDEN"}
};
CASTINGBAR_HEADER = strWhite.."eCastingBar v"..strGreen..CASTING_BAR_MAJOR_VERSION..strWhite.."."..strGreen..CASTING_BAR_MINOR_VERSION.."."..strGreen..CASTING_BAR_REVISION..strWhite;
CASTINGBAR_HELP = {
	strLine1 = strYellow.."--- "..CASTINGBAR_HEADER..strYellow.." --- ",
	strLine2 = strWhite..strTab..CASTINGBAR_CHAT_C1..strYellow..CASTINGBAR_HELP_STRING..strWhite
};

-- Global variables
eCastingBar_Saved = {};
eCastingBar_Resolution = nil;
eCastingBar_ResolutionWidth = 0;
eCastingBar_ResolutionHeight = 0;
eCastingBar_MENU_SAVEDSETTINGS = nil;
eCastingBar_SETTINGS_INDEX = "";

-- Local Constants
local CASTING_BAR_COLOR_TEXTURE = "Interface\\AddOns\\eCastingBar\\Textures\\RoundedLightSample.tga";
local CASTING_BAR_BACKGROUND_FILE = "Interface\\Tooltips\\UI-Tooltip-Background";
local CASTING_BAR_EDGE_FILE = "Interface\\Tooltips\\UI-Tooltip-Border";

-- Casting Bar Frame Suffixes
local frameSuffixes = { "", "TargetBar", "FocusBar" }

local CASTING_BAR_DEFAULTS = {
  ["Locked"] = 0,
  ["Enabled"] = 1,
  ["Texture"] = "Perl",
  ["ShowTime"] = 1,
  ["HideBorder"] = 0,
  ["ShowDelay"] = 1,
  ["Width"] = CASTING_BAR_WIDTH,
  ["Height"] = CASTING_BAR_HEIGHT,
  ["Left"] = CASTING_BAR_LEFT,
  ["Bottom"] = 180,
  ["ShowSpellName"] = 1,
  ["ShowSpellRank"] = 1,
  ["FontSize"] = 12,
  ["Alpha"] = 100,
  ["IconPosition"] = "HIDDEN",
  ["MirrorLocked"] = 0,
  ["MirrorEnabled"] = 1,
  ["MirrorTexture"] = "Perl",
  ["MirrorShowTime"] = 1,
  ["MirrorHideBorder"] = 0,
  ["MirrorUseFlightTimer"] = 1,
  ["MirrorWidth"] = CASTING_BAR_WIDTH,
  ["MirrorHeight"] = CASTING_BAR_HEIGHT,
  ["MirrorLeft"] = CASTING_BAR_LEFT,
  ["MirrorBottom"] = 600,
  ["MirrorShowTimerLabel"] = 1,
  ["MirrorFontSize"] = 12,
  ["MirrorAlpha"] = 100,
  ["TargetBarLocked"] = 0,
  ["TargetBarEnabled"] = 1,
  ["TargetBarTexture"] = "Perl",
  ["TargetBarShowTime"] = 1,
  ["TargetBarHideBorder"] = 0,
  ["TargetBarShowDelay"] = 1,
  ["TargetBarWidth"] = CASTING_BAR_WIDTH,
  ["TargetBarHeight"] = CASTING_BAR_HEIGHT,
  ["TargetBarLeft"] = CASTING_BAR_LEFT,
  ["TargetBarBottom"] = 640,
  ["TargetBarShowSpellName"] = 1,
  ["TargetBarShowSpellRank"] = 1,
  ["TargetBarFontSize"] = 12,
	["TargetBarAlpha"] = 100,
  ["TargetBarIconPosition"] = "HIDDEN",
  ["FocusBarLocked"] = 0,
  ["FocusBarEnabled"] = 1,
  ["FocusBarTexture"] = "Perl",
  ["FocusBarShowTime"] = 1,
  ["FocusBarHideBorder"] = 0,
  ["FocusBarShowDelay"] = 1,
  ["FocusBarWidth"] = CASTING_BAR_WIDTH,
  ["FocusBarHeight"] = CASTING_BAR_HEIGHT,
  ["FocusBarLeft"] = CASTING_BAR_LEFT,
  ["FocusBarBottom"] = 560,
  ["FocusBarShowSpellName"] = 1,
  ["FocusBarShowSpellRank"] = 1,
  ["FocusBarFontSize"] = 12,
	["FocusBarAlpha"] = 100,
  ["FocusBarIconPosition"] = "HIDDEN"
}

local CASTING_BAR_DEFAULT_COLORS = {
  ["SpellColor"] = {1.0, 0.7, 0.0, 1.0},
  ["ChannelColor"] = {0.3, 0.3, 1.0, 1},
  ["SuccessColor"] = {0.0, 1.0, 0.0, 1},
  ["FailedColor"] = {1.0, 0.0, 0.0, 1},
  ["FlashBorderColor"] = {1.0, 0.88, 0.25, 1},
  ["FeignDeathColor"] = {1.0, 0.7, 0.0, 1},
  ["ExhaustionColor"] = {1.0, 0.9, 0.0, 1},
  ["BreathColor"] = {0.0, 0.5, 1.0, 1},
  ["FlightColor"] = {.26, 0.93, 1.0, 1.0},
  ["TimeColor"] = {1.0, 1.0, 1.0, 1},
  ["DelayColor"] = {1.0, 0.0, 0.0, 1},
  ["MirrorTimeColor"] = {1.0, 1.0, 1.0, 1},
  ["MirrorFlashBorderColor"] = {1.0, 0.88, 0.25, 1},
  ["TargetBarSpellColor"] = {1.0, 0.7, 0.0, 1.0},
  ["TargetBarChannelColor"] = {0.3, 0.3, 1.0, 1},
  ["TargetBarSuccessColor"] = {0.0, 1.0, 0.0, 1},
  ["TargetBarFailedColor"] = {1.0, 0.0, 0.0, 1},
  ["TargetBarFlashBorderColor"] = {1.0, 0.88, 0.25, 1},
  ["TargetBarTimeColor"] = {1.0, 1.0, 1.0, 1},
  ["TargetBarDelayColor"] = {1.0, 0.0, 0.0, 1},
  ["FocusBarSpellColor"] = {1.0, 0.7, 0.0, 1.0},
  ["FocusBarChannelColor"] = {0.3, 0.3, 1.0, 1},
  ["FocusBarSuccessColor"] = {0.0, 1.0, 0.0, 1},
  ["FocusBarFailedColor"] = {1.0, 0.0, 0.0, 1},
  ["FocusBarFlashBorderColor"] = {1.0, 0.88, 0.25, 1},
  ["FocusBarTimeColor"] = {1.0, 1.0, 1.0, 1},
  ["FocusBarDelayColor"] = {1.0, 0.0, 0.0, 1}
}

-- Local variables

local eCastingBar__FlashBorders = {
	"TOPLEFT",
	"TOP",
	"TOPRIGHT",
	"LEFT",
	"RIGHT",
	"BOTTOMLEFT",
	"BOTTOM",
	"BOTTOMRIGHT"	
}

local eCastingBar__Events = {
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_STOP",
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_FAILED",
	"UNIT_SPELLCAST_DELAYED",
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_CHANNEL_STOP"
}

function ECB_addChat(msg)
	DEFAULT_CHAT_FRAME:AddMessage(CASTINGBAR_HEADER.." "..msg)
end

function eCastingBar_Toggle()
	if eCB_OptionFrame:IsVisible() then
		HideUIPanel(eCB_OptionFrame);
	else
		ShowUIPanel(eCB_OptionFrame);
	end
end

function eCastingBar_OnLoad(unit, frame)
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	eCastingBar_Register(this:GetName());
	this.unit = unit;
	this.frame = frame;
	this.casting = nil;
	this.channeling = nil;
	this.holdTime = 0;
end

function eCastingBarTarget_OnLoad()
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	eCastingBar_OnLoad("target", "TargetBar");
end

function eCastingBarFocus_OnLoad()
	this:RegisterEvent("PLAYER_FOCUS_CHANGED");
	eCastingBar_OnLoad("focus", "FocusBar");
end


function eCastingBar_Register(bar)
    for _,event in pairs(eCastingBar__Events) do
			getglobal(bar):RegisterEvent(event)
    end
end

function eCastingBar_Unregister(bar)
    for _,event in pairs(eCastingBar__Events) do
			getglobal(bar):UnregisterEvent(event)
    end
end

--[[ Handles all the mods' events. ]]--

function eCastingBar_OnEvent(self, newevent, ...)
	local newarg1 = ...;
	local unit = self.unit;
	if newevent == "PLAYER_ENTERING_WORLD" then
		self:Hide();
		local nameChannel  = UnitChannelInfo(unit);
		local nameSpell  = UnitCastingInfo(unit);
		if ( nameChannel ) then
			newevent = "UNIT_SPELLCAST_CHANNEL_START";
			newarg1 = unit;
		elseif ( nameSpell ) then
			newevent = "UNIT_SPELLCAST_START";
			newarg1 = unit;
		end
	end
	if ( newarg1 ~= unit ) then
		return;
	end
	local name = self:GetName();
	local barIcon = getglobal(name.."StatusBarIcon");
	local barFlash = getglobal(name.."Flash")
	local barStatusBar = getglobal(name.."StatusBar");
	local barSpark = getglobal(name.."StatusBarSpark");
	local barText = getglobal(name.."StatusBarText")
	local frame = self.frame
	if( newevent == "UNIT_SPELLCAST_START" ) then
		local spellName, spellRank, displayName, texture, startTime, endTime, isTradeSkill, castID = UnitCastingInfo(unit)
		if ( not spellName) then
			self:Hide();
			return;
		end
		local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."SpellColor"])
		barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
		if ( barSpark ) then
			barSpark:Show();
		end
		self.startTime = (startTime/1000)
		self.maxValue = (endTime/1000)
		barStatusBar:SetMinMaxValues( self.startTime, self.maxValue )
		barStatusBar:SetValue( self.startTime )
	  -- set the text to the spell name
	  if ( eCastingBar_Saved[frame.."ShowSpellName"] == 1 and string.len(spellRank) > 0 and eCastingBar_Saved[frame.."ShowSpellRank"] == 1) then
		  barText:SetText( spellName.." ("..spellRank..")" )
		elseif ( eCastingBar_Saved[frame.."ShowSpellName"] == 1 and ( string.len(spellRank) == 0 or eCastingBar_Saved[frame.."ShowSpellRank"] == 0 ) ) then
		  barText:SetText( spellName )
		elseif ( eCastingBar_Saved[frame.."ShowSpellName"] == 0 and eCastingBar_Saved[frame.."ShowSpellRank"] == 1) then
		  barText:SetText( spellRank )
	  else
	    barText:SetText( "" )
	  end
		if ( barIcon and eCastingBar_Saved[frame.."IconPosition"] ~= "HIDDEN") then
			barIcon:SetTexture(texture);
			barIcon:Show();
		end
		self:SetAlpha( 1.0 )
		self.holdTime = 0
		self.casting = 1
		self.castID = castID;
		self.channeling = nil
		self.fadeOut = nil
		self.delay = 0
		if (eCastingBar_Saved[frame.."Enabled"] == 1) then
			self:Show()
		end

	elseif( newevent == "UNIT_SPELLCAST_STOP" and self.casting ) or ( newevent == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
		if ( not self:IsVisible() ) then
			self:Hide()
		end
		if ( (self.casting and newevent == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or
		     (self.channeling and newevent == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			barSpark:Hide();
			barFlash:SetAlpha(0.0);
			barFlash:Show();
			barStatusBar:SetValue(self.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
  		  local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."SuccessColor"])
  			barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
				self.casting = nil;
			else
				self.channeling = nil;
			end
			self.delay = 0
			self.flash = 1;
			self.fadeOut = 1;
			self.holdTime = 0;
		end

	elseif( newevent == "UNIT_SPELLCAST_FAILED" or newevent == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( self:IsShown() and
		     (self.casting and select(4, ...) == self.castID) and not self.fadeOut ) then
			barStatusBar:SetValue( self.maxValue )
	    local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."FailedColor"])
	    barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
			barSpark:Hide()
			if ( event == "UNIT_SPELLCAST_FAILED" ) then
				barText:SetText( FAILED )
			elseif ( event == "UNIT_SPELLCAST_INTERRUPTED" ) then
				barText:SetText( INTERRUPTED )
			end
			self.casting = nil
			self.channeling = nil
			self.delay = 0
			self.fadeOut = 1
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end
    
	elseif( newevent == "UNIT_SPELLCAST_DELAYED" ) then
		if( self:IsShown() ) then
			local spellName, spellRank, displayName, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
			if (not endTime) then return; end;
			local delayTime = (endTime - (self.maxValue * 1000))
			if ( not spellName) then
				self:Hide();
				return;
			end
			self.startTime = (startTime/1000)
			self.maxValue = (endTime/1000)
			barStatusBar:SetMinMaxValues( self.startTime, self.maxValue )
	    if self.delay == nil then
  	  	self.delay = 0
    	end
			self.delay = self.delay + (delayTime / 1000)
			if ( not self.casting ) then
				local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."SpellColor"])
				barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
				barSpark:Show();
				barFlash:SetAlpha(0.0);
				barFlash:Hide();
				self.casting = 1;
				self.channeling = nil;
				self.flash = 0;
				self.fadeOut = 0;
			end
		end
		
	elseif( newevent == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local spellName, spellRank, displayName, texture, startTime, endTime = UnitChannelInfo(newarg1)
		if ( not spellName) then
			self:Hide();
			return;
		end
  	local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."ChannelColor"])
  	barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
		self.startTime = (startTime/1000)
		self.endTime = (endTime/1000)
		self.maxValue = self.startTime
		barStatusBar:SetMinMaxValues( self.startTime, self.endTime )
		barStatusBar:SetValue( endTime - ( GetTime() - (startTime/1000) ) )
		barSpark:Show()
		if ( barIcon and eCastingBar_Saved[frame.."IconPosition"] ~= "HIDDEN") then
			barIcon:SetTexture(texture);
			barIcon:Show();
		end
	  if ( eCastingBar_Saved[frame.."ShowSpellName"] == 1 and string.len(spellRank) > 0 and eCastingBar_Saved[frame.."ShowSpellRank"] == 1) then
		  barText:SetText( spellName.." ("..spellRank..")" )
	  elseif ( eCastingBar_Saved[frame.."ShowSpellName"] == 1 and ( string.len(spellRank) == 0 or eCastingBar_Saved[frame.."ShowSpellRank"] == 0 ) ) then
		  barText:SetText( spellName )
		elseif ( eCastingBar_Saved[frame.."ShowSpellName"] == 0 and eCastingBar_Saved[frame.."ShowSpellRank"] == 1) then
		  barText:SetText( spellRank )
		else
			barText:SetText( "" )
		end
		self:SetAlpha( 1.0 )
  	self.delay = 0
		self.holdTime = 0
		self.casting = nil
		self.channeling = 1
		self.fadeOut = nil
		if (  eCastingBar_Saved[frame.."Enabled"] == 1) then
			self:Show()
		end

	elseif( newevent == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if( self:IsShown() ) then
			local spellName, spellRank, displayName, texture, startTime, endTime = UnitChannelInfo(newarg1)
			if ( not spellName) then
				self:Hide();
				return;
			end
			self.startTime = startTime / 1000;
			self.endTime = endTime / 1000;
			self.maxValue = self.startTime;
			barStatusBar:SetMinMaxValues(self.startTime, self.endTime);			
		end
	end
end

function eCastingBar_OnUpdate()
	local frame = this.frame
	local bar = getglobal("eCastingBar"..frame)
	local barFlash = getglobal("eCastingBar"..frame.."Flash")
	local barStatusBar = getglobal("eCastingBar"..frame.."StatusBar");
	local barSpark = getglobal("eCastingBar"..frame.."StatusBarSpark");
	local barTime = getglobal("eCastingBar"..frame.."StatusBar_Time");
	local barDelay = getglobal("eCastingBar"..frame.."StatusBar_Delay");
  if( this.casting ) then    
    local intCurrentTime = GetTime()
    if (intCurrentTime > this.maxValue) then
    	intCurrentTime = this.maxValue
    end
 		if ( intCurrentTime == this.maxValue ) then
			barStatusBar:SetValue(this.maxValue);
		  local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."SuccessColor"])
			barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
			this.flash = 1;
			this.delay = 0;
			this.fadeOut = 1;
			this.casting = nil;
			this.channeling = nil;
			return;
		end
    barStatusBar:SetValue( intCurrentTime )
    barFlash:Hide()
    local sparkPosition = ( ( intCurrentTime - this.startTime ) / ( this.maxValue - this.startTime ) ) * barStatusBar:GetWidth()
    if( sparkPosition < 0 ) then		
      sparkPosition = 0			
    end
    barSpark:SetPoint( "CENTER", "eCastingBar"..frame.."StatusBar", "LEFT", sparkPosition, 0 )
    if ( eCastingBar_Saved[frame.."ShowTime"] == 1) then
	if ( eCastingBar_Saved[frame.."ShowMaxTime"] == 1) then
	      barTime:SetText( string.format( "%.1f / %.1f", math.max( this.maxValue - intCurrentTime, 0.0 ), this.maxValue - this.startTime ) )
	else
	      barTime:SetText( string.format( "%.1f", math.max( this.maxValue - intCurrentTime, 0.0 ) ) )
	end
    else
      barTime:SetText("")
    end
    if (( eCastingBar_Saved[frame.."ShowDelay"] == 1 ) and ( this.delay ~= 0)) then  
	    barDelay:SetText("+"..string.format( "%.1f", this.delay ) )
    else
      barDelay:SetText("")
    end
  -- no, we channeling?	
  elseif ( this.channeling ) then
    -- yes
    local intTimeLeft = GetTime()
		if ( intTimeLeft > this.endTime ) then
			intTimeLeft = this.endTime;
		end
		if ( intTimeLeft == this.endTime ) then
		  local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[frame.."SuccessColor"])
			barStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
			this.flash = 1;
			this.delay = 0;
			this.fadeOut = 1;
			this.casting = nil;
			this.channeling = nil;
			return;
		end
    local intBarValue = this.startTime + ( this.endTime - intTimeLeft )
    barStatusBar:SetValue( intBarValue )
    barFlash:Hide()
    local sparkPosition = ( ( intBarValue - this.startTime ) / ( this.endTime - this.startTime ) ) * getglobal("eCastingBar"..frame.."Background"):GetWidth()
    barSpark:SetPoint( "CENTER", "eCastingBar"..frame.."StatusBar", "LEFT", sparkPosition, 0 )
    if (eCastingBar_Saved[frame.."ShowTime"] == 1) then    	
      local timeLeft = math.max( getglobal("eCastingBar"..frame).endTime - intTimeLeft, 0.0 )
      local timeMsg = nil
      local minutes = 0
      local seconds = 0
      
      if (timeLeft > 60) then
        minutes = math.floor( ( timeLeft / 60 ))
        local seconds = math.ceil( timeLeft - ( 60 * minutes ))
        if (seconds == 60) then
          minutes = minutes + 1
          seconds = 0
        end
        timeMsg = format("%s:%s", minutes, getFormattedNumber(seconds))
      else
        timeMsg = string.format( "%.1f", timeLeft )
      end
      barTime:SetText( timeMsg )
    else
      barTime:SetText("")
    end
    if ((eCastingBar_Saved[frame.."ShowDelay"] == 1) and (this.delay ~= 0)) then
      barDelay:SetText("+"..string.format( "%.1f", this.delay ) )
    else
      barDelay:SetText("")
    end
  elseif( GetTime() < this.holdTime ) then
    return
  elseif( this.flash ) then
    local intAlpha = barFlash:GetAlpha() + CASTING_BAR_FLASH_STEP
    barTime:SetText( "" )
    if( intAlpha < 1 ) then
      barFlash:SetAlpha( intAlpha )
    else
			barFlash:SetAlpha(1.0);
      this.flash = nil
    end
  elseif ( this.fadeOut ) then
    local intAlpha = this:GetAlpha() - CASTING_BAR_ALPHA_STEP
    if( intAlpha > 0 ) then
      this:SetAlpha( intAlpha )
    else
      this.fadeOut = nil
      this:Hide()
    end
  end
end

function eCastingBarTarget_OnEvent(self, event, arg1, ...)
	local newevent = event;
	local newarg1 = arg1;
	if( newevent == "PLAYER_TARGET_CHANGED") then
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			newevent = "UNIT_SPELLCAST_CHANNEL_START";
			newarg1 = "target";
		elseif ( nameSpell ) then
			newevent = "UNIT_SPELLCAST_START";
			newarg1 = "target";
		else
			self.casting = nil;
			self.channeling = nil;
			self:Hide();
			return;
		end
	end
	if UnitIsUnit("player", "target") then
		return;
	end
	eCastingBar_OnEvent(self, newevent, newarg1, ...);

end

function eCastingBarFocus_OnEvent(self, event, arg1, ...)
	local newevent = event;
	local newarg1 = arg1;
	if( event == "PLAYER_FOCUS_CHANGED") then
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			newevent = "UNIT_SPELLCAST_CHANNEL_START";
			newarg1 = "focus";
		elseif ( nameSpell ) then
			newevent = "UNIT_SPELLCAST_START";
			newarg1 = "focus";
		else
			self.casting = nil;
			self.channeling = nil;
			self:Hide();
			return;
		end
	end
	if ( UnitIsUnit("player", "focus") ) then
		return;
	end
	eCastingBar_OnEvent(self, newevent, newarg1, ...);

end


function eCastingBar_ResetSettings()
	ECB_addChat(CASTINGBAR_RESET)
	eCastingBar_Saved = {}
  -- reset General Options
	for option in pairs(CASTING_BAR_DEFAULTS) do
		eCastingBar_Saved[option] = CASTING_BAR_DEFAULTS[option]
	end
  -- reset Colors
	for color in pairs(CASTING_BAR_DEFAULT_COLORS) do
		eCastingBar_Saved[color] = CASTING_BAR_DEFAULT_COLORS[color]
	end
	setup()
end

function eCastingBar_CheckSettings()
  -- reset General Options
	for option in pairs(CASTING_BAR_DEFAULTS) do
		if (eCastingBar_Saved[option] == nil) then
			eCastingBar_Saved[option] = CASTING_BAR_DEFAULTS[option]
		end
	end
  -- check for nil colors
	for color in pairs(CASTING_BAR_DEFAULT_COLORS) do
		if (eCastingBar_Saved[color] == nil) then
			eCastingBar_Saved[color] = CASTING_BAR_DEFAULT_COLORS[color]
		end
	end
end

function setup()
	eCastingBar_checkEnabled()
	eCastingBar_checkLocked()
	eCastingBar_checkBorders()
	eCastingBar_checkTimeColors()
	eCastingBar_setDelayColor()
	eCastingBar_SetSize()
	eCastingBar_checkFlashBorderColors()
	eCastingBar_checkTextures()
	eCastingBar_setIcons()
end

--[[ Iniitialization ]]--

function eCastingBar_LoadVariables()	
    setup()
    eCastingBar_SetSavedSettingsMenu()
    
    -- make the casting bar link to the movable button
		eCastingBar:SetPoint("TOPLEFT", "eCastingBar_Outline", "TOPLEFT", 0, 0 )
		eCastingBarTargetBar:SetPoint("TOPLEFT", "eCastingBarTargetBar_Outline", "TOPLEFT", 0, 0 )
		eCastingBarFocusBar:SetPoint("TOPLEFT", "eCastingBarFocusBar_Outline", "TOPLEFT", 0, 0 )
    
    -- make the mirror casting bar link to the movable button
		eCastingBarMirror1:SetPoint("TOPLEFT", "eCastingBarMirror_Outline", "TOPLEFT", 0, 0 )
		
    -- reset variables
    for index, option in pairs(frameSuffixes) do
      getglobal("eCastingBar"..option).casting = nil
      getglobal("eCastingBar"..option).holdTime = 0
    end
    
		SlashCmdList["ECASTINGBAR"] = eCastingBar_SlashHandler
		SLASH_ECASTINGBAR1 = "/eCastingBar"
		SLASH_ECASTINGBAR2 = "/eCB"
		SLASH_ECASTINGBAR3 = "/???"    
    -- resolution
    SetResolution(GetScreenResolutions())
    --[[
    local i,j = string.find(eCastingBar_Resolution, "x")
    eCastingBar_ResolutionWidth = tonumber(string.sub(eCastingBar_Resolution, 0, i - 1))
    eCastingBar_ResolutionHeight = tonumber(string.sub(eCastingBar_Resolution, i + 1, string.len(eCastingBar_Resolution)))
    ]]
    -- override these for now until I can figure out why blizzard is jacked up
    eCastingBar_ResolutionWidth = 2000
    eCastingBar_ResolutionHeight = 2000
    
    setupConfigFrame()
    setupDefaultConfigFrame()
    setupColorsConfigFrame()
end

function setupConfigFrame()
  -- set all text values
  eCB_Option_DefaultsButton:SetText(CASTINGBAR_DEFAULTS_BUTTON)
  eCB_Option_CloseButton:SetText(CASTINGBAR_CLOSE_BUTTON)
  eCastingBarSaveSettingsButton:SetText(CASTINGBAR_SAVE_BUTTON)
  eCastingBarLoadSettingsButton:SetText(CASTINGBAR_LOAD_BUTTON)
  eCastingBarDeleteSettingsButton:SetText(CASTINGBAR_DELETE_BUTTON)
end

function setupDefaultConfigFrame()
  -- set all text values
  for option in pairs(CASTING_BAR_BUTTONS) do
    local btnText = getglobal("eCastingBar"..option.."Text")
    btnText:SetText(CASTING_BAR_BUTTONS[option])
  end
  
  eCastingBarStatusBarText:SetJustifyH(CASTING_BAR_SPELL_JUSTIFY)
  eCastingBarSelectTexture_Label:SetText(CASTINGBAR_CASTINGBAR_TEXTURE_TEXT)
  eCastingBarSelectTexture_Setting:SetText(eCastingBar_Saved.Texture)

  eCastingBarIconPosition_Label:SetText(CASTINGBAR_ICON_POSITION_TEXT)
  eCastingBarIconPosition_Setting:SetText(getglobal("CASTINGBAR_"..eCastingBar_Saved.IconPosition.."_TEXT"))
  
	for index, option in pairs(frameSuffixes) do
		local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[option.."SpellColor"])
		getglobal("eCastingBar"..option.."ExampleStatusBar"):SetStatusBarColor( Red, Green, Blue, Alpha )
	end
  local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved.BreathColor)
  eCastingBarMirrorExampleStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )

  
  eCastingBarTargetBarStatusBarText:SetJustifyH(CASTING_BAR_SPELL_JUSTIFY)
  eCastingBarTargetBarSelectTexture_Label:SetText(CASTINGBAR_TARGETBAR_TEXTURE_TEXT)
  eCastingBarTargetBarSelectTexture_Setting:SetText(eCastingBar_Saved.TargetBarTexture)

  eCastingBarFocusBarStatusBarText:SetJustifyH(CASTING_BAR_SPELL_JUSTIFY)
  eCastingBarFocusBarSelectTexture_Label:SetText(CASTINGBAR_FOCUSBAR_TEXTURE_TEXT)
  eCastingBarFocusBarSelectTexture_Setting:SetText(eCastingBar_Saved.FocusBarTexture)

  eCastingBarTargetBarIconPosition_Label:SetText(CASTINGBAR_ICON_POSITION_TEXT)
  eCastingBarTargetBarIconPosition_Setting:SetText(getglobal("CASTINGBAR_"..eCastingBar_Saved.TargetBarIconPosition.."_TEXT"))

  eCastingBarFocusBarIconPosition_Label:SetText(CASTINGBAR_ICON_POSITION_TEXT)
  eCastingBarFocusBarIconPosition_Setting:SetText(getglobal("CASTINGBAR_"..eCastingBar_Saved.FocusBarIconPosition.."_TEXT"))
  
  eCastingBarMirrorSelectTexture_Label:SetText(CASTINGBAR_MIRRORBAR_TEXTURE_TEXT)
  eCastingBarMirrorSelectTexture_Setting:SetText(eCastingBar_Saved.MirrorTexture)
  
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
    getglobal("eCastingBarMirror"..index.."StatusBarText"):SetJustifyH(CASTING_BAR_SPELL_JUSTIFY)
  end

	-- Disable the Load and Delete Buttons on Startup
	eCastingBarLoadSettingsButton:Disable(); 
	eCastingBarDeleteSettingsButton:Disable();

  -- set all checks
  for option in pairs(CASTING_BAR_BUTTONS) do
    local btn = getglobal("eCastingBar"..option)
    btn:SetChecked(eCastingBar_Saved[option])
  end
  
  local slider, sliderText, low, high, width, height
  local optionTabs = { "", "Mirror", "TargetBar", "FocusBar" }
  
  for index, option in pairs(optionTabs) do
    local slidervalue
    -- setup the width slider
    slider = getglobal("eCastingBar"..option.."WidthSlider")
    sliderText = getglobal("eCastingBar"..option.."WidthSliderText")
    low = getglobal("eCastingBar"..option.."WidthSliderLow")
    high = getglobal("eCastingBar"..option.."WidthSliderHigh")
    slidervalue = eCastingBar_Saved[option.."Width"]
    slider:SetMinMaxValues(CASTING_BAR_SLIDER_WIDTH_MIN, eCastingBar_ResolutionWidth)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_WIDTH_TEXT)
    low:SetText(CASTING_BAR_SLIDER_WIDTH_MIN)
    high:SetText(eCastingBar_ResolutionWidth)
    
    -- setup the height slider
    slidervalue = eCastingBar_Saved[option.."Height"]
    slider = getglobal("eCastingBar"..option.."HeightSlider")
    sliderText = getglobal("eCastingBar"..option.."HeightSliderText")
    low = getglobal("eCastingBar"..option.."HeightSliderLow")
    high = getglobal("eCastingBar"..option.."HeightSliderHigh")
    
    slider:SetMinMaxValues(CASTING_BAR_SLIDER_HEIGHT_MIN, CASTING_BAR_SLIDER_HEIGHT_MAX)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_HEIGHT_TEXT)
    low:SetText(CASTING_BAR_SLIDER_HEIGHT_MIN)
    high:SetText(CASTING_BAR_SLIDER_HEIGHT_MAX)
    
    -- setup the x slider
    slider = getglobal("eCastingBar"..option.."LeftSlider")
    sliderText = getglobal("eCastingBar"..option.."LeftSliderText")
    low = getglobal("eCastingBar"..option.."LeftSliderLow")
    high = getglobal("eCastingBar"..option.."LeftSliderHigh")
    
    if (option == "Mirror") then
      width = tonumber(string.format("%.0f", getglobal("eCastingBarMirror1"):GetWidth()))
      height = tonumber(string.format("%.0f", getglobal("eCastingBarMirror1"):GetHeight()))
    else
      width = tonumber(string.format("%.0f", getglobal("eCastingBar"..option):GetWidth()))
      height = tonumber(string.format("%.0f", getglobal("eCastingBar"..option):GetHeight()))
    end
    slidervalue = eCastingBar_Saved[option.."Left"]
    slider:SetMinMaxValues(-1000, eCastingBar_ResolutionWidth)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_LEFT_TEXT)
    low:SetText(-1000)
    high:SetText(eCastingBar_ResolutionWidth)
    
    -- setup the y slider
    slider = getglobal("eCastingBar"..option.."BottomSlider")
    sliderText = getglobal("eCastingBar"..option.."BottomSliderText")
    low = getglobal("eCastingBar"..option.."BottomSliderLow")
    high = getglobal("eCastingBar"..option.."BottomSliderHigh")
    
    slidervalue = eCastingBar_Saved[option.."Bottom"]
    slider:SetMinMaxValues(-1000, eCastingBar_ResolutionHeight)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_BOTTOM_TEXT)
    low:SetText(-1000)
    high:SetText(eCastingBar_ResolutionHeight)
    
    -- setup the font slider
    slider = getglobal("eCastingBar"..option.."FontSlider")
    sliderText = getglobal("eCastingBar"..option.."FontSliderText")
    low = getglobal("eCastingBar"..option.."FontSliderLow")
    high = getglobal("eCastingBar"..option.."FontSliderHigh")
    
    slidervalue = eCastingBar_Saved[option.."FontSize"]
    slider:SetMinMaxValues(6, 40)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_FONT_TEXT)
    low:SetText(6)
    high:SetText(40)
    
    -- setup the alpha slider
    slider = getglobal("eCastingBar"..option.."AlphaSlider")
    sliderText = getglobal("eCastingBar"..option.."AlphaSliderText")

    low = getglobal("eCastingBar"..option.."AlphaSliderLow")
    high = getglobal("eCastingBar"..option.."AlphaSliderHigh")
    slidervalue = eCastingBar_Saved[option.."Alpha"]
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(1)
    slider:SetValue(slidervalue)
    sliderText:SetText(CASTINGBAR_SLIDER_ALPHA_TEXT)
    low:SetText("0%")
    high:SetText("100%")
  end
end

function setupColorsConfigFrame()
  -- set the textures
  for color in pairs(CASTINGBAR_COLOR_LABEL) do
    local btnColor = getglobal("btn"..color.."Texture")
    
    -- set the texture
    btnColor:SetTexture(CASTING_BAR_COLOR_TEXTURE)
    
    -- set the vertex color
    btnColor:SetVertexColor(unpack(eCastingBar_Saved[color]))
    
    -- set the label
    getglobal("lbl"..color.."Text"):SetText(CASTINGBAR_COLOR_LABEL[color])
  end
end

function SetResolution(...)
  local iRes = GetCurrentResolution()
  for i=1, select("#",...), 1 do
    if (iRes == i) then
    	eCastingBar_Resolution = select(i,...)
    end
  end
end

--[[ Handles all the slash commands if cosmos isn't present. ]]--

function eCastingBar_SlashHandler( strMessage )
  local command, param
  -- make it it all lower case to be sure
	strMessage = string.lower( strMessage )
  
  if(index) then
		command = string.sub(strMessage, 1, (index - 1))
		param = string.sub(strMessage, (index + 1)  )
	else
		command = strMessage
	end
  
	if( command == CASTINGBAR_CHAT_C1 ) then 
    ShowUIPanel(eCB_OptionFrame);
  elseif ( command == CASTINGBAR_CHAT_C2) then
    eCastingBar_ChatHelp()
	else
    ShowUIPanel(eCB_OptionFrame);
	end
	
  setupDefaultConfigFrame()
  setupColorsConfigFrame()
end

--[[ Handles chat help messages. ]]--

function eCastingBar_ChatHelp()
	local intIndex = 0
	local strMessage = ""
	
  -- prints each line in CASTINGBAR_HELP = { }
	for intIndex, strMessage in pairs(CASTINGBAR_HELP) do
		ECB_addChat( strMessage )
	end
end

function getFormattedNumber(number)
	if (strlen(number) < 2 ) then
		return "0"..number
	else
		return number
	end	
end

--[[ Starts moving the frame. ]]--

function eCastingBar_MouseUp( strButton, frmFrame, frameType )
	if( eCastingBar_Saved[frameType.."Locked"] == 0 ) then
		getglobal( frmFrame ):StopMovingOrSizing()
    eCastingBar_Saved[frameType.."Left"] = getglobal(frmFrame):GetLeft()
    eCastingBar_Saved[frameType.."Bottom"] = getglobal(frmFrame):GetBottom()
    
    getglobal("eCastingBar"..frameType.."LeftSlider"):SetValue(eCastingBar_Saved[frameType.."Left"])
    getglobal("eCastingBar"..frameType.."BottomSlider"):SetValue(eCastingBar_Saved[frameType.."Bottom"])
	end
end

--[[ Stops moving the frame. ]]--

function eCastingBar_MouseDown( strButton, frmFrame, frameType )
	if( strButton == "LeftButton" and (eCastingBar_Saved[frameType.."Locked"] == 0 ) ) then
		getglobal( frmFrame ):StartMoving()
	end
end

function eCastingBarGeneral_MouseUp( strButton, frmFrame )
		getglobal( frmFrame ):StopMovingOrSizing()
end

--[[ Stops moving the frame. ]]--

function eCastingBarGeneral_MouseDown( strButton, frmFrame, frameType )
	if( strButton == "LeftButton") then
		getglobal( frmFrame ):StartMoving()
	end
end

function eCastingBar_getShowDelay()
	return eCastingBar_Saved.ShowDelay
end

function eCastingBar_setShowDelay( intShowDelay )
	eCastingBar_Saved.ShowDelay = intShowDelay
end

function eCastingBar_checkBorders()
  for index, option in pairs(frameSuffixes) do
  	local bar = getglobal("eCastingBar"..option)
    if (eCastingBar_Saved[option.."HideBorder"] == 1) then
      bar:SetBackdrop(nil)
    else
      bar:SetBackdrop({bgFile = CASTING_BAR_BACKGROUND_FILE, edgeFile = CASTING_BAR_EDGE_FILE, tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }}) 
      bar:SetBackdropColor(0,0,0,0.5)
    end
  end
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
  	local bar = getglobal("eCastingBarMirror"..index)
    if (eCastingBar_Saved.MirrorHideBorder == 1) then
      bar:SetBackdrop(nil)
    else
      bar:SetBackdrop({bgFile = CASTING_BAR_BACKGROUND_FILE, edgeFile = CASTING_BAR_EDGE_FILE, tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }}) 
      bar:SetBackdropColor(0,0,0,0.5)
    end
  end
end

--[[-------------------------------------------
	Functions for Locked State
-------------------------------------------]]--

function eCastingBar_checkLocked()
  for index, option in pairs(frameSuffixes) do
   	local barOutline = getglobal("eCastingBar"..option.."_Outline")
    -- only show the outline if we are enabled
    if (eCastingBar_Saved[option.."Enabled"] == 1 and
          eCastingBar_Saved[option.."Locked"] == 0) then
      barOutline:Show()
    else
      barOutline:Hide()
    end
  end
  

  -- only show the outline if we are enabled
  if (eCastingBar_Saved.MirrorEnabled == 1 and eCastingBar_Saved.MirrorLocked == 0) then
  	eCastingBarMirror_Outline:Show()
  else
    eCastingBarMirror_Outline:Hide()
  end
end

--[[-------------------------------------------
	Functions for Enabled State
-------------------------------------------]]--

--[[ Disables the frame. ]]--

function eCastingBar_Disable( frame )
  eCastingBar_Saved[frame.."Enabled"] = 0
  local bar = getglobal("eCastingBar"..frame)
  if (frame == "") then
		local oldbar = CastingBarFrame
		if (BCastBarCastBar) then
			oldbar = BCastBarCastBar
		end
  	oldbar.showCastbar = true
 		if UnitCastingInfo(oldbar.unit) or UnitChannelInfo(oldbar.unit) then
		oldbar:Show()
	end

  end
 	if bar.casting then
		bar:Hide()
	end
  -- the frame unlocked?
	if( eCastingBar_Saved[frame.."Locked"] == 0 ) then
    -- yes, lets hide the outline
		getglobal("eCastingBar"..frame.."_Outline"):Hide()
	end
end


--[[ Enables the frame. ]]--

function eCastingBar_Enable( frame )
  eCastingBar_Saved[frame.."Enabled"] = 1  
  local bar = getglobal("eCastingBar"..frame)
  if (frame == "") then
		local oldbar = CastingBarFrame
		if (BCastBarCastBar) then
			oldbar = BCastBarCastBar
		end
  	oldbar.showCastbar = nil;
  	oldbar:Hide();
	end
	if UnitCastingInfo(bar.unit) or UnitChannelInfo(bar.unit) then
		bar:Show()
	end
  -- the frame unlocked?
	if( eCastingBar_Saved[frame.."Locked"] == 0 ) then
    -- yes, lets show the outline
		getglobal("eCastingBar"..frame.."_Outline"):Show()
	end
end

--[[ Toggle enabled state. ]]--

function eCastingBar_checkEnabled()
  for index, option in pairs(frameSuffixes) do
  	if (eCastingBar_Saved[option.."Enabled"] == 1) then
  		eCastingBar_Enable(option)
    else
      eCastingBar_Disable(option)
  	end
  end
  
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
    if (eCastingBar_Saved.MirrorEnabled == 1) then
  		if( eCastingBar_Saved.MirrorLocked == 0 ) then	
        -- yes, lets show the outline
        getglobal("eCastingBarMirror_Outline"):Show()        
      end		
    else
      if( eCastingBar_Saved.MirrorLocked == 0 ) then
        -- yes, lets hide the outline
        getglobal("eCastingBarMirror_Outline"):Hide()
      end
  	end
  end
end

--[[-------------------------------------------
	Functions for using the Texture 
-------------------------------------------]]--

--[[ Toggle enabled state. ]]--

function eCastingBar_checkTextures()
  for index, option in pairs(frameSuffixes) do
  	if eCastingBar_Saved[option.."Texture"] == nil then 
  		eCastingBar_Saved[option.."Texture"] = "Perl"
  	end
  	if eCastingBar_Saved[option.."Texture"] == "Halycon" then
  		eCastingBar_Saved[option.."Texture"] = "Halcyon"
  	end
    getglobal("eCastingBar"..option.."StatusBarTexture"):SetTexture( CASTING_BAR_TEXTURES[eCastingBar_Saved[option.."Texture"]] )
    getglobal("eCastingBar"..option.."StatusBarTexture"):SetWidth(20)
    getglobal("eCastingBar"..option.."StatusBarTexture"):SetHeight(10)
    getglobal("eCastingBar"..option.."ExampleStatusBarTexture"):SetTexture( CASTING_BAR_TEXTURES[eCastingBar_Saved[option.."Texture"]] )
    getglobal("eCastingBar"..option.."ExampleStatusBarText"):SetText( eCastingBar_Saved[option.."Texture"] )
  end
  
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
  	if eCastingBar_Saved.MirrorTexture == nil then
  		eCastingBar_Saved.MirrorTexture = "Perl"
  	end
  	if eCastingBar_Saved.MirrorTexture == "Halycon" then
  		eCastingBar_Saved.MirrorTexture = "Halcyon"
  	end
   	getglobal("eCastingBarMirror"..index.."StatusBarTexture"):SetTexture( CASTING_BAR_TEXTURES[eCastingBar_Saved.MirrorTexture] )
    getglobal("eCastingBarMirror"..index.."StatusBarTexture"):SetWidth(20)
    getglobal("eCastingBarMirror"..index.."StatusBarTexture"):SetHeight(10)  
  end
  eCastingBarMirrorExampleStatusBarTexture:SetTexture( CASTING_BAR_TEXTURES[eCastingBar_Saved.MirrorTexture] )
  eCastingBarMirrorExampleStatusBarText:SetText(eCastingBar_Saved.MirrorTexture)
end

function eCastingBar_setColor(colorFrame)
	if colorFrame == "SpellColor" or colorFrame == "ChannelColor" then
		local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[colorFrame])
  	eCastingBarExampleStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
  	if (eCastingBar.casting) then
  	  local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved.SpellColor)
		  eCastingBarStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
		elseif (eCastingBar.channeling) then
			local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved.ChannelColor)
  		eCastingBarStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
  	end
	elseif colorFrame == "TargetBarSpellColor" or colorFrame == "TargetBarChannelColor" then
		local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[colorFrame])
  	eCastingBarTargetBarExampleStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
	elseif colorFrame == "FocusBarSpellColor" or colorFrame == "FocusBarChannelColor" then
		local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[colorFrame])
  	eCastingBarFocusBarExampleStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
	else
		local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[colorFrame])
  	eCastingBarMirrorExampleStatusBar:SetStatusBarColor( Red, Green, Blue, Alpha )
		local timer = strupper(gsub(colorFrame, "Color", ""))
	  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
			local frame = getglobal("eCastingBarMirror"..index);
			if ( frame:IsVisible() and (frame.timer == timer) ) then
				local	Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[colorFrame])
  			getglobal("eCastingBarMirror"..index.."StatusBar"):SetStatusBarColor( Red, Green, Blue, Alpha )
  		end
  	end
  end
end

function eCastingBar_setIcons()
  for index, option in pairs(frameSuffixes) do
  	if (eCastingBar_Saved[option.."IconPosition"] == nil) then 
  		eCastingBar_Saved[option.."IconPosition"] = "HIDDEN"
  	end
  	if (eCastingBar_Saved[option.."IconPosition"] == "LEFT") then
	  	getglobal("eCastingBar"..option.."StatusBarIcon"):ClearAllPoints()
			getglobal("eCastingBar"..option.."StatusBarIcon"):SetPoint("RIGHT", getglobal("eCastingBar"..option), "LEFT", -5)
			if getglobal("eCastingBar"..option).casting or getglobal("eCastingBar"..option).channeling then
				getglobal("eCastingBar"..option.."StatusBarIcon"):Show()
			end
		elseif (eCastingBar_Saved[option.."IconPosition"] == "RIGHT") then
	  	getglobal("eCastingBar"..option.."StatusBarIcon"):ClearAllPoints()
			getglobal("eCastingBar"..option.."StatusBarIcon"):SetPoint("LEFT", getglobal("eCastingBar"..option), "RIGHT", 5)
			if getglobal("eCastingBar"..option).casting or getglobal("eCastingBar"..option).channeling then
				getglobal("eCastingBar"..option.."StatusBarIcon"):Show()
			end
		else
			getglobal("eCastingBar"..option.."StatusBarIcon"):Hide()
		end
  end
end

function eCastingBar_checkTimeColors()
  for index, option in pairs(frameSuffixes) do
    local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[option.."TimeColor"])
    getglobal("eCastingBar"..option.."StatusBar_Time"):SetTextColor(Red,Green,Blue, Alpha )
  end
  local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved.MirrorTimeColor)
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
    getglobal("eCastingBarMirror"..index.."StatusBar_Time"):SetTextColor(Red,Green,Blue, Alpha )
  end
end

function eCastingBar_setDelayColor()
  for index, option in pairs(frameSuffixes) do
    local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[option.."DelayColor"])
    getglobal("eCastingBar"..option.."StatusBar_Delay"):SetTextColor(Red,Green,Blue, Alpha )
  end
end

--[[ sets up the flash to look cool ]]--

--(thanks goes to kaitlin for the code used while resting). 

function eCastingBar_checkFlashBorderColors()
	local frmFrame = "eCastingBarFlash"
	local intIndex = 0
	local strBorder = ""
  
  for index, option in pairs(frameSuffixes) do
    local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[option.."FlashBorderColor"])
    
    -- for each border in eCastingBar__FlashBorders set the color to gold.
    for intIndex, strBorder in pairs(eCastingBar__FlashBorders) do
      getglobal( "eCastingBar"..option.."Flash_"..strBorder ):SetVertexColor( Red, Green, Blue, Alpha )	
    end
  end
	
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
    local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved.MirrorFlashBorderColor)
    for intIndex, strBorder in pairs(eCastingBar__FlashBorders) do
      getglobal( "eCastingBarMirror"..index.."Flash_"..strBorder ):SetVertexColor( Red, Green, Blue, Alpha )	
    end
  end
end


-- Sets the width and height of the casting bar

function eCastingBar_SetSize()
  local width, height, bottom, left, bar
  for index, option in pairs(frameSuffixes) do
    -- check boundaries
    if (eCastingBar_Saved[option.."Width"] < CASTING_BAR_SLIDER_WIDTH_MIN) then
      width = CASTING_BAR_SLIDER_WIDTH_MIN
    elseif (eCastingBar_Saved[option.."Width"] > CASTING_BAR_SLIDER_WIDTH_MAX ) then
      width = CASTING_BAR_SLIDER_WIDTH_MAX
    else
      width = eCastingBar_Saved[option.."Width"]
    end
    
    if (eCastingBar_Saved[option.."Height"] > CASTING_BAR_SLIDER_HEIGHT_MAX) then
      height = CASTING_BAR_SLIDER_HEIGHT_MAX
    elseif (eCastingBar_Saved[option.."Height"] < CASTING_BAR_SLIDER_HEIGHT_MIN ) then
      height = CASTING_BAR_SLIDER_HEIGHT_MIN
    else
      height = eCastingBar_Saved[option.."Height"]
    end
    
    left = eCastingBar_Saved[option.."Left"]
    bottom = eCastingBar_Saved[option.."Bottom"]
    
    --[[
    if (eCastingBar_Saved[option.."Left"] < 0) then
      left = 0;
    else
      left = eCastingBar_Saved[option.."Left"];
    end
    
    if (eCastingBar_Saved[option.."Bottom"] < 0 ) then
      bottom = 0;;
    else
      bottom = eCastingBar_Saved[option.."Bottom"];
    end
    ]]--
    
    getglobal("eCastingBar"..option):SetWidth(width)
    getglobal("eCastingBar"..option):SetHeight(height)
    
    getglobal("eCastingBar"..option.."Background"):SetWidth(width - 9)
    getglobal("eCastingBar"..option.."Background"):SetHeight(height - 10)
    
    getglobal("eCastingBar"..option.."Flash"):SetWidth(width)
    getglobal("eCastingBar"..option.."Flash"):SetHeight(height)
    
    getglobal("eCastingBar"..option.."StatusBar"):SetWidth(width - 9)
    getglobal("eCastingBar"..option.."StatusBar"):SetHeight(height - 10)

    getglobal("eCastingBar"..option.."StatusBarIcon"):SetWidth(height - 6)
    getglobal("eCastingBar"..option.."StatusBarIcon"):SetHeight(height - 6)
    
    getglobal("eCastingBar"..option.."_Outline"):SetWidth(width)
    getglobal("eCastingBar"..option.."_Outline"):SetHeight(height)
    getglobal("eCastingBar"..option.."_Outline"):ClearAllPoints()
    getglobal("eCastingBar"..option.."_Outline"):SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", left, bottom )
    
    getglobal("eCastingBar"..option.."Flash_TOP"):SetWidth(width - 24)
    getglobal("eCastingBar"..option.."Flash_BOTTOM"):SetWidth(width - 24)
    getglobal("eCastingBar"..option.."Flash_LEFT"):SetHeight(height - 24)
    getglobal("eCastingBar"..option.."Flash_RIGHT"):SetHeight(height - 24)
    
    getglobal("eCastingBar"..option.."StatusBarSpark"):SetHeight(height + 13)
    
    getglobal("eCastingBar"..option.."StatusBarText"):SetWidth(width - 49)
    getglobal("eCastingBar"..option.."StatusBarText"):SetHeight(height + 13)
    
    -- set the font size
    local fontName, _, fontFlags = getglobal("eCastingBar"..option.."StatusBarText"):GetFont()
		getglobal("eCastingBar"..option.."StatusBarText"):SetFont(fontName, eCastingBar_Saved[option.."FontSize"], fontFlags)
		getglobal("eCastingBar"..option.."StatusBar_Time"):SetFont(fontName, eCastingBar_Saved[option.."FontSize"], fontFlags)

		-- set the Alpha
		local newAlpha = (eCastingBar_Saved[option.."Alpha"]/100)
		local Red, Green, Blue, Alpha = getglobal("eCastingBar"..option):GetBackdropColor()
		getglobal("eCastingBar"..option):SetBackdropColor(Red, Green, Blue, newAlpha)
		getglobal("eCastingBar"..option.."Background"):SetAlpha(newAlpha)
		Red, Green, Blue, Alpha = getglobal("eCastingBar"..option.."_Outline"):GetBackdropColor()
		getglobal("eCastingBar"..option.."_Outline"):SetBackdropColor(Red, Green, Blue, newAlpha)
  end
  
  for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
    
    -- check boundaries
    if (eCastingBar_Saved.MirrorWidth < CASTING_BAR_SLIDER_WIDTH_MIN) then
      width = CASTING_BAR_SLIDER_WIDTH_MIN
    elseif (eCastingBar_Saved.MirrorWidth > CASTING_BAR_SLIDER_WIDTH_MAX ) then
      width = CASTING_BAR_SLIDER_WIDTH_MAX
    else
      width = eCastingBar_Saved.MirrorWidth
    end
    
    if (eCastingBar_Saved.MirrorHeight > CASTING_BAR_SLIDER_HEIGHT_MAX) then
      height = CASTING_BAR_SLIDER_HEIGHT_MAX
    elseif (eCastingBar_Saved.MirrorHeight < CASTING_BAR_SLIDER_HEIGHT_MIN ) then
      height = CASTING_BAR_SLIDER_HEIGHT_MIN
    else
      height = eCastingBar_Saved.MirrorHeight
    end
    
    left = eCastingBar_Saved.MirrorLeft
    bottom = eCastingBar_Saved.MirrorBottom
    
    --[[
    if (eCastingBar_Saved.MirrorLeft < 0) then
      left = 0
    else
      left = eCastingBar_Saved.MirrorLeft
    end
    
    if (eCastingBar_Saved.MirrorBottom < 0 ) then
      bottom = 0
    else
      bottom = eCastingBar_Saved.MirrorBottom
    end
    ]]--
    
    getglobal("eCastingBarMirror"..index):SetWidth(width)
    getglobal("eCastingBarMirror"..index):SetHeight(height)
    
    getglobal("eCastingBarMirror"..index.."Background"):SetWidth(width - 9)
    getglobal("eCastingBarMirror"..index.."Background"):SetHeight(height - 10)
    
    getglobal("eCastingBarMirror"..index.."Flash"):SetWidth(width)
    getglobal("eCastingBarMirror"..index.."Flash"):SetHeight(height)
    
    getglobal("eCastingBarMirror"..index.."StatusBar"):SetWidth(width - 9)
    getglobal("eCastingBarMirror"..index.."StatusBar"):SetHeight(height - 10)
    
    getglobal("eCastingBarMirror_Outline"):SetWidth(width)
    getglobal("eCastingBarMirror_Outline"):SetHeight(height)
    getglobal("eCastingBarMirror_Outline"):ClearAllPoints()
    getglobal("eCastingBarMirror_Outline"):SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", left, bottom )
    
    getglobal("eCastingBarMirror"..index.."Flash_TOP"):SetWidth(width - 24)
    getglobal("eCastingBarMirror"..index.."Flash_BOTTOM"):SetWidth(width - 24)
    getglobal("eCastingBarMirror"..index.."Flash_LEFT"):SetHeight(height - 24)
    getglobal("eCastingBarMirror"..index.."Flash_RIGHT"):SetHeight(height - 24)
    
    getglobal("eCastingBarMirror"..index.."StatusBarSpark"):SetHeight(height + 13)
    
    getglobal("eCastingBarMirror"..index.."StatusBarText"):SetWidth(width - 49)
    getglobal("eCastingBarMirror"..index.."StatusBarText"):SetHeight(height + 13)
    
    -- set the font size
    local fontName, _, fontFlags = getglobal("eCastingBarMirror"..index.."StatusBarText"):GetFont()
		getglobal("eCastingBarMirror"..index.."StatusBarText"):SetFont(fontName, eCastingBar_Saved.MirrorFontSize, fontFlags)
		getglobal("eCastingBarMirror"..index.."StatusBar_Time"):SetFont(fontName, eCastingBar_Saved.MirrorFontSize, fontFlags)
		-- set the Alpha
		local newAlpha = (eCastingBar_Saved.MirrorAlpha/100)
		local Red, Green, Blue, Alpha = getglobal("eCastingBarMirror"..index):GetBackdropColor()
		getglobal("eCastingBarMirror"..index):SetBackdropColor(Red, Green, Blue, newAlpha)
		getglobal("eCastingBarMirror"..index.."Background"):SetAlpha(newAlpha)
		Red, Green, Blue, Alpha = eCastingBarMirror_Outline:GetBackdropColor()
		eCastingBarMirror_Outline:SetBackdropColor(Red, Green, Blue, newAlpha)
  end
end

function eCastingBar_Copy_Table(src, dest)
	for index, value in pairs(src) do
		if (type(value) == "table") then
			dest[index] = {};
			eCastingBar_Copy_Table(value, dest[index]);
		else
			dest[index] = value;
		end
	end
end
