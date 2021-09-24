AsheylaLib:Package( "TimerLib" );
--[[
    TimerFrameManager class
    
    Should be created with a timer object and never destroyed.
--]]

-- the order in which the constructor expects the fields
local order = {
    "timer"
};

local fields = {
    timer = Class.READONLY,     -- table        the timer that owns this manager
    
    -- the below are not arguments externally, but are instead populated later
    
    frame = Class.READONLY,     -- table        the frame that the timer is rendered in
};

local externalFuncs = {
    Update = true,          -- remaining        makes the frame update itself
    UpdateData = true,      -- <none>           when the data of the timer changes
    UpdateToGhost = true,   -- <none>           updates the frame to a ghost
    DrawFrame = true,       -- <none>           does the heavy lifting for rendering the timer
    TimerDone = true,       -- <none>           hides the frame, other cleanup stuff
    UpdateShown = true,     -- <none>           hides or shows the frame
    UpdateFadeIn = true,    -- time             updates the fading in of the timer
    UpdateFadeOut = true,   -- time             updates the fading out of the timer, returns true if done fading
    StartFadingOut = true,  -- <none>           makes the timer start fading out if it hasn't already
    FormatTime = true,      -- number           transforms the number into a string representing time
    
    Destruct = function( self )         --  this object should never be destroyed
        error( "Attempt to destroy a TimerFrameManager" );
    end,
};

local persistent = {
    timer = true,
    frame = true,
};

-- the actual functions that operate on the frame
local frameFuncs;

-- for ButtonFacade support
local LBF = LibStub and LibStub("LibButtonFacade", true)
local LBFGroup;
local calledLBF = false;
if LBF then
    LBFGroup = LBF:Group("DoTimer");
    LBF:RegisterSkinCallback("DoTimer", function( _, id, gloss, bd, isNil, _, colors )
        if isNil == nil and calledLBF then
            TimerLib:Set( "LBF", "skinID", id );
            TimerLib:Set( "LBF", "gloss", gloss );
            TimerLib:Set( "LBF", "backdrop", bd );
            TimerLib:Set( "LBF", "colors", colors );
        end
    end);
end

-- grab local copies of globals
local min = math.min;
local pow = math.pow;
local max = math.max;
local fmod = math.fmod;
local huge = math.huge;
local pairs = pairs;
local type = type;
local GetTime = GetTime;
local CreateFrame = CreateFrame;
local print = print;

-- map from external objects to their internal data
local internal;

local oldDestruct;
local internalFuncs = {
    FormatTime = function( self, number )
        local timer = self.timer;
        number = max(number, 0);
        local form = self.timeFormat;
        local numHours = number / 3600;
        local numMinutes = fmod(number, 3600);
        local numSeconds = fmod(numMinutes, 60);
        numMinutes = numMinutes / 60;
        
        if form == "letters" then
            if numHours >= 1 then
                return "%dh", numHours + 1;
            elseif numMinutes >= 1 then
                return "%dm", numMinutes + 1;
            else
                local str = (self.tenths and number < 9.95) and "%.1fs" or "%ds";
                return str, numSeconds;
            end
        elseif form == "digital" then
            local str = (self.tenths and number < 9.95) and ":%.2d.%d" or ":%.2d";
            if numHours >= 1 then
                return "%d:%d" .. str, numHours, numMinutes, numSeconds;
            elseif numMinutes >= 1 then
                return "%d" .. str, numMinutes, numSeconds;
            else
                return "0" .. str, numSeconds, 10 * fmod(numSeconds, 1);
            end
        end
    end,
    
    UpdateFadeIn = function( self, time )
        local timer = self.timer;
        if not self.doneFading then
            local fadeInLength = min(self.fadeInLength, (timer.duration or huge) / 2);
            local elapsedPastStart = time - timer.start;
            if elapsedPastStart <= fadeInLength then
                self.frame:SetAlpha( elapsedPastStart / fadeInLength );
            else
                self.frame:SetAlpha( 1 );
                self.doneFading = true;
            end
        end
    end,
    
    UpdateFadeOut = function( self, time )
        local timer = self.timer;
        local ghostLength = self.ghostLength;
        local fadeOutLength = self.fadeOutLength;
        local ghosts = self.ghosts;
        local elapsedPastGhost;
        if ghosts then
            if ghostLength == 0 or self.fadingOut then
                elapsedPastGhost = time - (self.fadeStart or time);
            else
                elapsedPastGhost = time - timer.start - ghostLength;
            end
        else
            elapsedPastGhost = time - timer.start;
        end
        
        if self.fadingOut or ghostLength > 0 or not ghosts then
            if elapsedPastGhost >= fadeOutLength then
                return true;
            elseif elapsedPastGhost > 0 then
                self.fadingOut = true;
                self.fadeStart = self.fadeStart or GetTime();
                self.frame:SetAlpha( 1 - (elapsedPastGhost / fadeOutLength) );
            end
        end
        
        return false;
    end,
    
    StartFadingOut = function( self )
        if not self.fadingOut and self.ghostLength == 0 then
            self.fadingOut = true;
            self.fadeStart = GetTime();
        end
    end,
    
    UpdateShown = function( self )
        if self.timer:IsShown() then
            self.frame:Show();
        else
            self.frame:Hide();
        end
    end,
    
    TimerDone = function( self, anchor )
        local frame = self.frame;
        local timer = self.timer;
        frame:Hide();
        if frame.beingDragged then
            anchor:CallScript( "StopMoving" );
        end
        frame.beingDragged = false;
        if frame.mouseIsOver then
            if self.tooltips then
                timer.frame:SetScript("OnUpdate", nil);
                timer.module:CallScript("OnTimerLeave", timer.group.data, timer.data, timer.id, self);
            end
            anchor:CallScript( "UpdateAlpha" );
        end
        frame.mouseIsOver = false;
        oldDestruct( self, true );
    end,
    
    UpdateColor = function( self, remaining )
        local timer = self.timer;
        local redPoint = self.redPoint;
        local inColorChangeRange = false;
        local toFinal = remaining - redPoint;
        local toMiddle = remaining - (timer.duration / 2);
        if (toFinal >= 0 and toFinal <= 2) or (toMiddle >= 0 and toMiddle <= 2) then
            inColorChangeRange = true;
        end
        if self.changingColor then
            self.funcs.updateColor( self, self.timer, self.frames, remaining );
        end
        self.changingColor = inColorChangeRange;
    end,
    
    Update = function( self, remaining )
        self.funcs.update( self, self.timer, self.frames, remaining );
        self:UpdateColor( remaining );
        self:CheckSound( remaining );
    end,
    
    CheckSound = function( self, remaining )
        local timer = self.timer;
        local redPoint = self.redPoint;
        if remaining <= redPoint and not self.playedSound then
            self.playedSound = true;
            if timer.duration > redPoint and self.soundAlert then
                PlaySoundFile("Interface\\AddOns\\DoTimer\\Core\\Files\\alert.wav");
            end
        end
    end,
    
    UpdateData = function( self )
        self.changingColor = true;
        local timer = self.timer;
        if timer.duration then
            local remaining = timer.duration - GetTime() + timer.time;
            if remaining > self.redPoint then
                self.playedSound = false;
            end
        end
        return self.funcs.updateData( self, self.timer, self.frames );
    end,
    
    UpdateToGhost = function( self )
        return self.funcs.updateToGhost( self, self.timer, self.frames );
    end,
    
    UpdateCachedSettings = function( self )
        local timer = self.timer;
        self.ghosts = timer:Get( "ghosts" );
        self.duration = timer:Get( "duration" );
        self.tooltips = timer:Get( "tooltips" );
        self.barReversed = timer:Get( "barReversed" );
        self.barScaling = timer:Get( "barScaling" );
        self.barTextColor = timer:Get( "barTextColor" );
        self.ghostColor = timer:Get( "ghostColor" );
        self.barGrow = timer:Get( "barGrow" );
        self.fadeInLength = timer:Get( "fadeInLength" );
        self.barFlipIcon = timer:Get( "barFlipIcon" );
        self.barTexture = timer:Get( "barTexture" );
        self.timeFormat = timer:Get( "timeFormat" );
        self.barMinorLength = timer:Get( "barMinorLength" );
        self.iconReverseCooldown = timer:Get( "iconReverseCooldown" );
        self.font = timer:Get( "font" );
        self.redPoint = timer:Get( "redPoint" );
        self.timerFormat = timer:Get( "timerFormat" );
        self.fadeOutLength = timer:Get( "fadeOutLength" );
        self.barAbsScale = timer:Get( "barAbsScale" );
        self.barLeftText = timer:Get( "barLeftText" );
        self.iconShowCooldown = timer:Get( "iconShowCooldown" );
        self.scale = timer:Get( "scale" );
        self.iconUseBG = timer:Get( "iconUseBG" );
        self.barShowIcon = timer:Get( "barShowIcon" );
        self.clickable = timer:Get( "clickable" );
        self.soundAlert = timer:Get( "soundAlert" );
        self.iconDisplayFormat = timer:Get( "iconDisplayFormat" );
        self.barRightText = timer:Get( "barRightText" );
        self.iconFontHeight = timer:Get( "iconFontHeight" );
        self.tenths = timer:Get( "tenths" );
        self.alpha = timer:Get( "alpha" );
        self.startColor = timer:Get( "startColor" );
        self.middleColor = timer:Get( "middleColor" );
        self.finalColor = timer:Get( "finalColor" );
        self.iconFlipText = timer:Get( "iconFlipText" );
        self.barFontHeight = timer:Get( "barFontHeight" );
        self.barMajorLength = timer:Get( "barMajorLength" );
        self.ghostLength = timer:Get( "ghostLength" );
        self.barBackgroundColor = timer:Get( "barBackgroundColor" );
        self.barOrientation = timer:Get( "barOrientation" );
    end,
    
    DrawFrame = function( self )
        local timer = self.timer;
        self:UpdateCachedSettings();
        if ( self.timerFormat == "bar" ) then
            self.frames = self.frame.frames.bar;
            self.funcs = frameFuncs.bar;
            self.frame.frames.icon.mainFrame:Hide();
        else
            self.frames = self.frame.frames.icon;
            self.funcs = frameFuncs.icon;
            self.frame.frames.bar.mainFrame:Hide();
        end
        self.mainFrame = self.frames.mainFrame;
        self.funcs.drawFrame( self, timer, self.frames );
        self.funcs.updateData( self, timer, self.frames );
        self:Resize();
            
        if timer.isGhost then
            self.funcs.updateToGhost( self, timer, self.frames );
        else
            self.funcs.updateColor( self, timer, self.frames );
        end
    end,
    
    Resize = function( self )
        local f = self.mainFrame;
        self.frame:SetWidth(f:GetWidth() * f:GetScale());
        self.frame:SetHeight(f:GetHeight() * f:GetScale());
        self.timer.group:TimerUpdated( self.timer, "size" );
    end,
};

-- TODO: these still need to be revised
-- TODO: OnLoad needs to be removed

local onEnterFunc = function( self )
    local timer = self.timer;
    if self:IsMouseOver() then
        timer.module:CallScript("OnTimerEnter", timer.group.data, timer.data, timer.id, self);
    else
        self.mouseIsOver = false;
        if self.tooltips then
            timer.frame:SetScript("OnUpdate", nil);
            timer.module:CallScript("OnTimerLeave", timer.group.data, timer.data, timer.id, self);
        end
        timer.group.anchor:CallScript( "UpdateAlpha" );
    end
end

frameFuncs = {
    bar = {
        updateColor = function( self, timer, frames, remaining )
            local r, g, b = frameFuncs.getColor( self, timer, remaining );
            frames.statusBar:SetStatusBarColor( r, g, b );
            frames.border:SetVertexColor( r, g, b );
        end,
        
        update = function( self, timer, frames, remaining )
            local absScale = self.barAbsScale;
            local scaling = self.barScaling;
            local remainingFraction;
            if scaling == "absolute" then
                remainingFraction = min( 1, remaining / (absScale > 0 and absScale or timer.duration) );
            elseif scaling == "standard" then
                remainingFraction = remaining / timer.duration;
            elseif scaling == "exponential" then
                remainingFraction = 1 - pow( 1 - (remaining / timer.duration), 2 );
            end
            
            if self.barGrow then
                remainingFraction = 1 - remainingFraction;
            end
            frames.statusBar:SetValue( remainingFraction );
            
            if self.barOrientation == "horizontal" then
                frameFuncs.bar.setBarText( self, timer, frames, remaining, true );
                if self.barReversed then
                    remainingFraction = 1 - remainingFraction;
                    frames.statusBar:SetPoint( "LEFT", frames.statusFrame, "LEFT", 
                        remainingFraction * self.barMajorLength, 0 );
                    frames.spark:SetPoint( "CENTER", frames.statusBar, "LEFT" );
                else
                    frames.spark:SetPoint( "CENTER", frames.statusBar, "LEFT", 
                        remainingFraction * self.barMajorLength, 0 );
                end
            else
                if self.barReversed then
                    remainingFraction = 1 - remainingFraction;
                    frames.statusBar:SetPoint( "BOTTOM", frames.statusFrame, "BOTTOM", 0, 
                        remainingFraction * self.barMajorLength );
                end
            end
            
            return false;
        end,
        
        updateData = function( self, timer, frames )
            if timer.group then
                frameFuncs.bar.setBarText( self, timer, frames );
            end
            
            if timer.stack and timer.stack > 1 then
                frames.stack:SetText( timer.stack );
            else
                frames.stack:SetText( "" );
            end
            
            frames.texture:SetTexture(timer.texture);
        end,
        
        updateToGhost = function( self, timer, frames )
            frameFuncs.bar.setBarText( self, timer, frames );
            frames.stack:SetText( "" );
            frames.spark:Hide();
            self.frame:SetAlpha( 1 );
            
            if self.ghosts then
                local color = self.ghostColor;
                frames.statusBar:SetStatusBarColor( color.r, color.g, color.b );
                frames.border:SetVertexColor( color.r, color.g, color.b );
                frames.statusBar:SetValue( 1 );
                frames.statusBar:SetAllPoints( true );
            end
        end,
        
        drawFrame = function( self, timer, frames )
            local barFrame = frames.mainFrame;
            local iconFrame = frames.iconFrame;
            local statusFrame = frames.statusFrame;
            
            barFrame:Show();
            barFrame:SetScale(self.scale);
            frames.button:EnableMouse(timer.group:Get("interactable") and self.clickable);
            
            local alpha = self.alpha;
            frames.texture:SetAlpha(alpha);
            frames.textureBackground:SetAlpha(alpha / 2);
            frames.border:SetAlpha(alpha);
            frames.spark:SetAlpha(alpha);
            frames.statusBar:SetAlpha(alpha);
            frames.statusBackground:SetAlpha(alpha / 2);
            frames.statusBar:SetValue( 1 );
            
            local texture;
            if sharedMedia() then
                texture = sharedMedia():Fetch("statusbar", self.barTexture, 1);
            end
            if texture == nil then
                texture = "Interface\\AddOns\\DoTimer\\Core\\Files\\" .. self.barTexture;
            end
            if texture == nil then
                texture = "Interface\\TargetingFrame\\UI-StatusBar";
            end
            frames.statusBar:SetStatusBarTexture(texture);
            frames.statusBackground:SetStatusBarTexture(texture);
            
            local color = self.barBackgroundColor;
            frames.statusBackground:SetStatusBarColor(color.r, color.g, color.b);
            
            local orient = self.barOrientation;
            local leftFavored = true;
            local fontHeight = self.barFontHeight;
            if fontHeight <= self.barMinorLength and orient == "horizontal" then
                leftFavored = self.barRightText ~= "Time Remaining";
                self.leftText = self.barLeftText;
                self.rightText = self.barRightText;
            else
                self.leftText = "None";
                self.rightText = "None";
            end
            
            local left = frames.leftText;
            local right = frames.rightText;
            local font;
            if sharedMedia() then
                font = sharedMedia():Fetch("font", self.font);
            else
                font = GameFontNormal:GetFont();
            end
            left:SetFont(font, fontHeight);
            right:SetFont(font, fontHeight);
            font = frames.stack:GetFont();
            frames.stack:SetFont(font, fontHeight, "OUTLINE");
            
            local color = self.barTextColor;
            left:SetTextColor(color.r, color.g, color.b);
            right:SetTextColor(color.r, color.g, color.b);
            
            left:ClearAllPoints();
            right:ClearAllPoints();
            left:SetPoint("TOPLEFT", statusFrame, "TOPLEFT", 3, 0);
            left:SetPoint("BOTTOMLEFT", statusFrame, "BOTTOMLEFT", 3, 1);
            right:SetPoint("TOPRIGHT", statusFrame, "TOPRIGHT", -3, 0);
            right:SetPoint("BOTTOMRIGHT", statusFrame, "BOTTOMRIGHT", -3, 1);
            if leftFavored then
                right:SetPoint("LEFT", left, "RIGHT");
            else
                left:SetPoint("RIGHT", right, "LEFT");
            end
            
            frameFuncs.bar.setBarText( self, timer, frames );
            local barWidth, barHeight = self.barMajorLength, self.barMinorLength;
            if orient == "vertical" then
                barWidth, barHeight = barHeight, barWidth;
            end
            if self.barReversed then
                local f = frames.statusBar;
                f:SetAllPoints(false);
                f:ClearAllPoints();
                f:SetWidth(barWidth);
                f:SetHeight(barHeight);
                if orient == "horizontal" then
                    f:SetPoint("LEFT", statusFrame, "LEFT");
                else
                    f:SetPoint("BOTTOM", statusFrame, "BOTTOM");
                end
            else
                frames.statusBar:SetAllPoints(true);
            end
            
            frames.statusBar:SetOrientation(orient);
            statusFrame:ClearAllPoints();
            if self.barShowIcon then
                iconFrame:Show();
                iconFrame:ClearAllPoints();
                local flip = self.barFlipIcon;
                local pos;
                if orient == "horizontal" then
                    pos = flip and "right" or "left";
                else
                    pos = flip and "top" or "bottom";
                end
                local iRef, sRef, iW, iH, bW, bH, x, y;
                if pos == "left" then
                    iRef, sRef = "LEFT", "RIGHT";
                    iW, iH = barHeight, barHeight;
                    bW, bH = barWidth + barHeight, barHeight;
                    x, y = -1, 0;
                elseif pos == "right" then
                    iRef, sRef = "RIGHT", "LEFT";
                    iW, iH = barHeight, barHeight;
                    bW, bH = barWidth + barHeight, barHeight;
                    x, y = 1, 0;
                elseif pos == "top" then
                    iRef, sRef = "TOP", "BOTTOM";
                    iW, iH = barWidth, barWidth;
                    bW, bH = barWidth, barWidth + barHeight;
                    x, y = 0, 1;
                elseif pos == "bottom" then
                    iRef, sRef = "BOTTOM", "TOP";
                    iW, iH = barWidth, barWidth;
                    bW, bH = barWidth, barWidth + barHeight;
                    x, y = 0, -1;
                end
                
                local border = frames.border;
                iconFrame:SetPoint(iRef, barFrame, iRef);
                statusFrame:SetPoint(iRef, border, sRef, x, y);
                iconFrame:SetWidth(iW - 1);
                iconFrame:SetHeight(iH - 1);
                border:SetWidth(iW);
                border:SetHeight(iH);
                barFrame:SetWidth(bW);
                barFrame:SetHeight(bH);
            else
                iconFrame:Hide();
                statusFrame:SetPoint("TOPLEFT", barFrame, "TOPLEFT");
                barFrame:SetWidth(barWidth);
                barFrame:SetHeight(barHeight);
            end
            
            statusFrame:SetWidth(barWidth);
            statusFrame:SetHeight(barHeight);
            frames.spark:SetHeight(barHeight * 2);
            if orient == "horizontal" and timer.duration then
                frames.spark:Show();
            else
                frames.spark:Hide();
            end
        end,
        
        -- special function: only called from other bar funcs; not part of interface
        setBarText = function( self, timer, frames, remaining, onlyNecessary )
            local left = frames.leftText;
            if self.leftText == "Time Remaining" and timer.duration and not timer.isGhost then
                remaining = remaining or timer.duration - GetTime() + timer.time;
                left:SetFormattedText(self:FormatTime(remaining));
            elseif not onlyNecessary then
                if self.leftText == "Timer Name" then
                    left:SetText(timer.name);
                elseif self.leftText == "Group Name" then
                    left:SetText(timer.group.name);
                elseif self.leftText == "Timer Name (Stack)" then
                    if timer.stack and timer.stack > 1 then
                        left:SetFormattedText( "%s (%d)", timer.name, timer.stack );
                    else
                        left:SetText( timer.name );
                    end
                else
                    left:SetText("");
                end
            end
            
            local right = frames.rightText;
            if self.rightText == "Time Remaining" and timer.duration and not timer.isGhost then
                remaining = remaining or timer.duration - GetTime() + timer.time;
                right:SetFormattedText(self:FormatTime(remaining));
            elseif not onlyNecessary then
                if self.rightText == "Timer Name" then
                    right:SetText(timer.name);
                elseif self.rightText == "Group Name" then
                    right:SetText(timer.group.name);
                elseif self.rightText == "Timer Name (Stack)" then
                    if timer.stack and timer.stack > 1 then
                        right:SetFormattedText( "%s (%d)", timer.name, timer.stack );
                    else
                        right:SetText( timer.name );
                    end
                else
                    right:SetText("");
                end
            end
        end,
    },
    
    icon = {
        updateColor = function( self, timer, frames, remaining )
            local r, g, b = frameFuncs.getColor( self, timer, remaining );
            if not self.iconUseBG then
                if LBF then
                    LBF:SetNormalVertexColor( frames.button, r, g, b );
                else
                    frames.border:SetVertexColor(r, g, b);
                end
            end
            frames.innerText:SetTextColor(r, g, b);
            frames.outerText:SetTextColor(r, g, b);
        end,
        
        update = function( self, timer, frames, remaining )
            local dispFormat = self.iconDisplayFormat;
            if dispFormat == "inside" then
                frames.innerText:SetFormattedText(self:FormatTime(remaining));
            elseif dispFormat == "outside" then
                frames.outerText:SetFormattedText(self:FormatTime(remaining));
                local width;
                if self.textPos == "h" then
                    width = (frames.button:GetWidth() * self.scale) + 3 + 
                        frames.outerText:GetStringWidth();
                else
                    width = max(frames.button:GetWidth() * self.scale, 
                        frames.outerText:GetStringWidth());
                end
                if width > frames.mainFrame:GetWidth() then
                    frames.mainFrame:SetWidth(width);
                    self:Resize();
                end
            end
        end,
        
        updateData = function( self, timer, frames )
            if timer.group then
                if timer.duration then
                    if self.iconShowCooldown then
                        frames.cooldown:SetCooldown(timer.time, timer.duration);
                    end
                end
            end
            
            local inner = frames.innerText;
            inner:ClearAllPoints();
            if timer.stack and timer.stack > 1 then
                frames.stack:SetText(timer.stack);
                inner:SetPoint("TOP", frames.button, "TOP", 1, -1);
            else
                frames.stack:SetText("");
                inner:SetPoint("CENTER", frames.button, "CENTER", 1, 0);
            end
            
            frames.texture:SetTexture(timer.texture);
        end,
        
        updateToGhost = function( self, timer, frames )
            if self.ghosts then
                local color = self.ghostColor;
                if LBF then
                    LBF:SetNormalVertexColor( frames.button, color.r, color.g, color.b );
                else
                    frames.border:SetVertexColor(color.r, color.g, color.b);
                end
            end
            frames.cooldown:Hide();
            frames.stack:SetText( "" );
            frames.innerText:SetText("");
            frames.outerText:SetText("");
            self.frame:SetAlpha( 1 );
            frames.mainFrame:SetWidth(frames.button:GetWidth() * self.scale);
            frames.mainFrame:SetHeight(frames.button:GetHeight() * self.scale);
            self:Resize();
        end,
        
        drawFrame = function( self, timer, frames )
            local iconFrame = frames.mainFrame;
            iconFrame:Show();
            
            local font;
            if sharedMedia() then
                font = sharedMedia():Fetch("font", self.font);
            else
                font = GameFontNormal:GetFont();
            end
            local fontHeight = self.iconFontHeight;
            frames.stack:SetFont(font, fontHeight, "OUTLINE");
            
            local buttonFrame = frames.button;
            local scale = self.scale;
            local alpha = self.alpha;
            buttonFrame:SetScale(scale);
            buttonFrame:SetAlpha(alpha);
            frames.border:SetAlpha( alpha );
            frames.highlight:SetAlpha( alpha );
            frames.texture:SetAlpha( alpha );
            frames.textureBackground:SetAlpha( alpha / 2 );
            frames.textureBackground:SetParent( frames.texture:GetParent() );
            frames.cooldown:SetAlpha( alpha );
            buttonFrame:EnableMouse(timer.group:Get("interactable") and self.clickable);
            
            if self.iconUseBG then
                local color = self.barBackgroundColor;
                if LBF then
                    LBF:SetNormalVertexColor( frames.button, color.r, color.g, color.b );
                else
                    frames.border:SetVertexColor(color.r, color.g, color.b);
                end
            end
            
            local cooldownFrame = frames.cooldown;
            if self.iconShowCooldown and self.duration then
                cooldownFrame:Show();
                cooldownFrame:SetCooldown(timer.time, timer.duration);
                cooldownFrame:SetReverse(self.iconReverseCooldown);
            else
                cooldownFrame:Hide();
            end
            
            local display = self.iconDisplayFormat;
            local outterText = frames.outerText;
            local innerText = frames.innerText;
            
            if display == "none" then
                outterText:Hide();
                innerText:Hide();
                buttonFrame:ClearAllPoints();
                buttonFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT");
                iconFrame:SetWidth(buttonFrame:GetWidth() * scale);
                iconFrame:SetHeight(buttonFrame:GetHeight() * scale);
            elseif display == "inside" then
                outterText:Hide();
                innerText:Show();
                innerText:SetFont(font, fontHeight, "OUTLINE");
                innerText:ClearAllPoints();
                innerText:SetPoint("CENTER", buttonFrame, "CENTER");
                innerText:SetText("");
                buttonFrame:ClearAllPoints();
                buttonFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT");
                iconFrame:SetWidth(buttonFrame:GetWidth() * scale);
                iconFrame:SetHeight(buttonFrame:GetHeight() * scale);
            elseif display == "outside" then
                innerText:Hide();
                outterText:Show();
                outterText:SetText(" ");
                local fontHeight = self.iconFontHeight;
                outterText:SetFont(font, fontHeight);
                local dir = timer.group:Get("timerDirection");
                local flip = self.iconFlipText;
                buttonFrame:ClearAllPoints();
                outterText:ClearAllPoints();
                if timer.duration then
                    if dir == "left" or dir == "right" then
                        self.textPos = "v";
                        if flip then --top
                            buttonFrame:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMLEFT");
                            outterText:SetPoint("BOTTOM", buttonFrame, "TOP", 0, 3);
                        else --bottom
                            buttonFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT");
                            outterText:SetPoint("TOP", buttonFrame, "BOTTOM", 0, -3);
                        end
                        iconFrame:SetHeight((buttonFrame:GetHeight() * scale) + 3 + 
                            outterText:GetHeight());
                        iconFrame:SetWidth(max(buttonFrame:GetWidth() * scale, 
                            outterText:GetWidth()));
                    else
                        self.textPos = "h";
                        if flip then --left
                            buttonFrame:SetPoint("TOPRIGHT", iconFrame, "TOPRIGHT");
                            outterText:SetPoint("RIGHT", buttonFrame, "LEFT", -3, 0);
                        else --right
                            buttonFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT");
                            outterText:SetPoint("LEFT", buttonFrame, "RIGHT", 3, 0);
                        end
                        iconFrame:SetHeight(max(buttonFrame:GetHeight() * scale, 
                            outterText:GetHeight()));
                        iconFrame:SetWidth((buttonFrame:GetWidth() * scale) + 3 + 
                            outterText:GetWidth());
                    end
                else
                    outterText:Hide();
                    buttonFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT");
                    iconFrame:SetWidth(buttonFrame:GetWidth() * scale);
                    iconFrame:SetHeight(buttonFrame:GetHeight() * scale);
                end
            end
        end,
    },
    
    getColor = function(self, timer, remaining)
        local time = GetTime();
        local old, new;
        if timer.duration then
            remaining = remaining or timer.duration - GetTime() + timer.time;
            local redPoint = self.redPoint;
            local halfway = timer.duration / 2;
            if (remaining <= redPoint) then
                color = self.finalColor;
            elseif (remaining <= redPoint + 2) then
                if (remaining <= halfway and redPoint + 2 <= halfway) then
                    old = self.middleColor 
                else
                    old = self.startColor;
                end
                new = self.finalColor;
                fraction = 1 - ((remaining - redPoint) / 2);
            elseif (remaining <= halfway) then
                color = self.middleColor;
            elseif (remaining <= halfway + 2 and redPoint + 2 <= halfway) then
                old = self.startColor;
                new = self.middleColor;
                fraction = 1 - ((remaining - halfway) / 2);
            else
                color = self.startColor;
            end
        else
            color = self.startColor;
        end
        
        if ( old and new ) then
            return old.r + ((new.r - old.r) * fraction), 
                old.g + ((new.g - old.g) * fraction), 
                old.b + ((new.b - old.b) * fraction);
        else
            return color.r, color.g, color.b;
        end
    end,
};

local frameScripts = {
    OnClick = function( self, button )
        self.timer.module:CallScript("OnTimerClick", self.timer.group.data, self.timer.data, self.timer.id, button);
    end,
    OnEnter = function( self )
        local timer = self.timer;
        self.mainFrame.mouseIsOver = true;
        if self.manager.tooltips then
            timer.frame:SetScript("OnUpdate", onEnterFunc);
        end
        timer.group.anchor:CallScript( "UpdateAlpha" );
    end,
    OnDragStart = function( self )
        self.mainFrame.beingDragged = true;
        self.timer.group.anchor:CallScript( "StartMoving" );
    end,
    OnDragStop = function( self )
        self.mainFrame.beingDragged = false;
        self.timer.group.anchor:CallScript( "StopMoving" );
    end,
    OnLeave = function( self )
        local timer = self.timer;
        self.mainFrame.mouseIsOver = false;
        if self.manager.tooltips then
            timer.frame:SetScript("OnUpdate", nil);
            timer.module:CallScript("OnTimerLeave", timer.group.data, timer.data, timer.id, self);
        end
        timer.group.anchor:CallScript( "UpdateAlpha" );
    end,
};

local function acquireTimerFrame( timer, manager )
    local frame = CreateFrame("Frame", nil, nil, "TimerLibTimerFrameTemplate");
    sanitize( frame );
    
    frame.frames = {
        bar = {
            mainFrame = frame.Bar,
            border = frame.Bar.Icon.Border,
            stack = frame.Bar.Icon.Stack,
            texture = frame.Bar.Icon.Texture,
            textureBackground = frame.Bar.Icon.Background,
            button = frame.Bar.Button,
            
            statusFrame = frame.Bar.Status,
            iconFrame = frame.Bar.Icon,
            statusBar = frame.Bar.Status.Front,
            statusBackground = frame.Bar.Status.Background,
            spark = frame.Bar.Icon.Spark,
            leftText = frame.Bar.Status.Text,
            rightText = frame.Bar.Status.TextRight,
        },
        icon = {
            mainFrame = frame.Icon,
            border = frame.Icon.Button.Border,
            stack = frame.Icon.Button.Holder.Stack,
            texture = frame.Icon.Button.Texture,
            textureBackground = frame.Icon.Button.Background,
            button = frame.Icon.Button,
            
            cooldown = frame.Icon.Button.Cooldown,
            innerText = frame.Icon.Button.Text,
            outerText = frame.Icon.Text,
            stackHolder = frame.Icon.Button.Holder,
            highlight = frame.Icon.Button.Highlight,
        },
    };
    
    frame:SetClampedToScreen(true);
    
    -- constant things on the bar frames
    local frames = frame.frames.bar;
    --frames.iconFrame:SetFrameLevel( frames.iconFrame:GetFrameLevel() + 1 );
    frames.statusBar:SetFrameLevel( frames.statusBar:GetFrameLevel() - 1 );
    frames.statusBackground:SetFrameLevel( frames.statusBackground:GetFrameLevel() - 2 );
    frames.mainFrame:SetPoint("TOPLEFT", frame);
    frames.textureBackground:SetPoint( "TOPLEFT", frames.iconFrame, "TOPLEFT", 2, -2 );
    frames.textureBackground:SetPoint( "BOTTOMRIGHT", frames.iconFrame, "BOTTOMRIGHT", -2, 2 );
    frames.button:SetAllPoints( true ); -- parent is mainFrame
    frames.texture:SetAllPoints( true ); -- parent is iconFrame
    frames.statusBar:SetAllPoints( true ); -- parent is statusFrame
    frames.statusBackground:SetAllPoints( true ); -- parent is statusFrame
    frames.border:SetPoint( "CENTER" );
    frames.spark:SetHeight( 32 );
    frames.stack:SetPoint( "BOTTOMRIGHT", frames.texture, "BOTTOMRIGHT", 1, 0 );
    frames.button.mainFrame = frame;
    for k, v in pairs( frameScripts ) do
        frames.button:SetScript( k, v );
    end
    
    -- constant things on the icon frames
    frames = frame.frames.icon;
    frames.mainFrame:SetPoint("TOPLEFT", frame);
    frames.border:SetAllPoints( true );
    frames.border:SetDrawLayer( "OVERLAY" );
    frames.button:SetWidth( 24 );
    frames.button:SetHeight( 24 );
    frames.texture:SetPoint( "TOPLEFT", frames.button, "TOPLEFT", 1, -1 );
    frames.texture:SetPoint( "BOTTOMRIGHT", frames.button, "BOTTOMRIGHT", -1, 1 );
    frames.textureBackground:SetAllPoints( frames.texture );
    frames.texture:SetSize( 24, 24 );
    
    frames.cooldown:SetAllPoints( true ); -- parent is button
    frames.stackHolder:SetAllPoints( true ); -- parent is button
    frames.stack:SetPoint( "BOTTOMRIGHT", frames.stackHolder, "BOTTOMRIGHT", -1, 1 );
    --hooksecurefunc( frames.stack, "SetPoint", function() print( debugstack() ) end );
    frames.button.mainFrame = frame;
    for k, v in pairs( frameScripts ) do
        frames.button:SetScript( k, v );
    end
    
    frame.frames.bar.button:RegisterForDrag("LeftButton");
    frame.frames.icon.button:RegisterForDrag("LeftButton");
    frame.frames.bar.button:RegisterForClicks("AnyUp");
    frame.frames.icon.button:RegisterForClicks("AnyUp");
    
    frame.frames.bar.button.timer = timer;
    frame.frames.bar.button.manager = manager;
    frame.frames.icon.button.timer = timer;
    frame.frames.icon.button.manager = manager;
    frame.timer = timer;
    
    if drawingBackground then
        local t = frame.Icon:CreateTexture();
        t:SetAllPoints(true);
        t:SetTexture(1, 0, 1, .5);
    end
    
    return frame;
end

TimerFrameManager, internal, oldDestruct = Class( "TimerFrameManager", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = TimerFrameManager.new;
TimerFrameManager.new = function( timer )
    local t = oldNew();
    local int = internal[ t ];
    local frame = acquireTimerFrame( timer, int );
    int.fields.frame = frame;
    
    if LBF then
        frame.Icon.Button.GetName = function( self ) return "NONAME" end
        
        LBFGroup:AddButton( frame.Icon.Button, {
            Icon = frame.frames.icon.texture,
            Cooldown = frame.frames.icon.cooldown,
            AutoCast = false,
            AutoCastable = false,
            HotKey = false,
            Count = frame.frames.icon.stack,
            Name = false,
            Border = frame.frames.icon.border,
            Highlight = frame.frames.icon.highlight,
        });
    end
    
    int.fields.timer = timer;
    
    return t;
end

local f = CreateFrame( "Frame" );
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );
f:SetScript( "OnEvent", function( self, event )
    if LBF then
        calledLBF = true;
        local settings = TimerLib:Get( "LBF" );
        LBFGroup:Skin( settings.skinID, settings.gloss, settings.backdrop, settings.color );
    end
    self:UnregisterAllEvents();
end);

getfenv( 0 ).r_fint = internalFuncs;
