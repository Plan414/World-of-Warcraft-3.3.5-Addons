AsheylaLib:Package( "DoTimer" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local mouseoverModule = AsheylaLib:NewModule("Mouseover Timers");
local CURRENT_GUID;

function mouseoverModule:MakeTimer(target, timer)
    if target.uniqueID == CURRENT_GUID then
        if not DoTimer:Get("blocked", string.lower(timer.name)) then
            local id = TimerLib:NewTimer(timer, "", mouseoverModule, DoTimer:Get("mouseoverSetting"), nil, nil, "DoTimer Mouseover", nil, nil);
            timer.mouseoverID = id;
        end
    end
end

function mouseoverModule:RemoveTimer(target, timer)
    if target.uniqueID == CURRENT_GUID and timer.mouseoverID then
        TimerLib:DeleteTimer(timer.mouseoverID, timer);
    end
end

function mouseoverModule:UpdateTimerData(timer)
    if timer.mouseoverID then
        TimerLib:UpdateTimer(timer.mouseoverID, timer);
    end
end

local f = CreateFrame("Frame");
local updateFunc = function(self, elapsed)
    if (not UnitExists("mouseover")) or UnitIsUnit("target", "mouseover") then
        self.timeNoUnit = self.timeNoUnit + elapsed;
        TimerLib:UpdateAnchorToCursor("DoTimer Mouseover");
        if self.timeNoUnit >= DoTimer:Get("mouseoverFadeTime") then
            local curr = DoTimer:GetTargetByGUID(CURRENT_GUID);
            if curr then
                for timer in curr:GetTimers() do
                    timer.mouseoverID = nil;
                end
            end
            TimerLib:DeleteAllTimers(mouseoverModule);
            self:SetScript("OnUpdate", nil);
            CURRENT_GUID = nil;
            mouseoverModule:UnregisterEvent("DOTIMER_NEW_TIMER");
            mouseoverModule:UnregisterEvent("DOTIMER_DONE_TIMER");
            mouseoverModule:UnregisterEvent("DOTIMER_UPDATE_TIMERDATA");
        end
    else
        TimerLib:UpdateAnchorToCursor("DoTimer Mouseover");
        self.timeNoUnit = 0;
    end
end
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
f:SetScript("OnEvent", function(self, event)
    local exists = false;
    local curr = DoTimer:GetTargetByGUID(CURRENT_GUID);
    if curr then
        for timer in curr:GetTimers() do
            timer.mouseoverID = nil;
        end
    end
    if UnitExists("mouseover") and not UnitIsUnit("target", "mouseover") then
        exists = DoTimer:GetTargetByGUID(UnitGUID("mouseover"));
    end
    
    TimerLib:DeleteAllTimers(mouseoverModule);
    self:SetScript("OnUpdate", nil);
    CURRENT_GUID = nil;
    mouseoverModule:UnregisterEvent("DOTIMER_NEW_TIMER");
    mouseoverModule:UnregisterEvent("DOTIMER_DONE_TIMER");
    mouseoverModule:UnregisterEvent("DOTIMER_UPDATE_TIMERDATA");
    local filter = DoTimer:Get("mouseoverTimers");
    local isApplicable = filter == "both" or (filter == "friends" and not UnitCanAttack("mouseover", "player")) or (filter == "enemies" and UnitCanAttack("mouseover", "player"));
    if exists and isApplicable then
        for timer in exists:GetTimers() do
            if not DoTimer:Get("blocked", string.lower(timer.name)) then
                local id = TimerLib:NewTimer(timer, "", mouseoverModule, DoTimer:Get("mouseoverSetting"), nil, nil, "DoTimer Mouseover", nil, nil);
                timer.mouseoverID = id;
            end
        end
        self.timeNoUnit = 0;
        self:SetScript("OnUpdate", updateFunc);
        CURRENT_GUID = UnitGUID("mouseover");
        mouseoverModule:RegisterEvent("DOTIMER_NEW_TIMER", mouseoverModule.MakeTimer);
        mouseoverModule:RegisterEvent("DOTIMER_DONE_TIMER", mouseoverModule.RemoveTimer);
        mouseoverModule:RegisterEvent("DOTIMER_UPDATE_TIMERDATA", mouseoverModule.UpdateTimerData);
    end
end);

TimerLib:AddSettingsUpdateScript(function(self)
    if not self:Get("anchorSettings", "DoTimer Mouseover") then
        self:Set("anchorSettings", "DoTimer Mouseover", {
            displayNames = false,
            anchorsToCursor = true,
            groupDirection = "down",
            timerDirection = "down", 
            overflowDirection = "right",
            overflowPoint = 0,
            standardAlpha = 1,
            mouseoverAlpha = 1,
            combatAlpha = 1,
            timerSpacing = 5,
            positionX = 30,
            positionY = -10,
        });
    end
end);

local defaultSettings = {
    mouseoverTimers = "enemies",
    mouseoverFadeTime = 0,
    mouseoverSetting = nil,
};
DoTimer:AddDefaultSettings(defaultSettings);

DoTimer:AddSettingsUpdateScript(function(self)
    if self:Get("enabled") and self:Get("mouseoverTimers") ~= "off" then
        f:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    else
        f:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
    end
    if not self:Get( "updatedSettingsMouseover5.0" ) then
        self:Set( "updatedSettingsMouseover5.0", true );
        TimerLib:Set( "anchorSettings", "DoTimer Mouseover", "positionX", 25 );
        TimerLib:Set( "anchorSettings", "DoTimer Mouseover", "positionY", -10 );
    end
end);
