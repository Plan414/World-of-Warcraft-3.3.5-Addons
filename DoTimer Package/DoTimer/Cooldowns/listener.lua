AsheylaLib:Package( "Cooldowns" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local listener = Cooldowns;

local defaultSettings = {
    userAnchors = {},
    keybindings = {},
    isAnnouncing = true,
    standardSetting = nil,
    visible = {},
    whiteList = false,
    displayName = "Cooldowns",
    standardAnnounce = "My cooldown on %s will finish in %d.",
};

function listener:FindAnchor(name, isExternal)
    name = string.lower(name);
    local default, externalLoc;
    local defaultGroup, externalGroup;
    for anchor, settings in pairs(self:Get("userAnchors")) do
        local standardName = settings.standardName or self:Get("displayName");
        if isExternal and settings.externalLoc ~= nil then
            externalLoc = anchor;
            externalGroup = settings.externalLoc and standardName;
        end
        if settings.timers then
            for entry, useGroup in pairs(settings.timers) do
                if string.find(name, entry) then
                    return anchor, useGroup and standardName;
                end
            end
        end
        if settings.default then default = anchor; end
    end
    
    return externalLoc or default, 
        externalGroup or defaultGroup;
end

local currentTargetInfo = {};
local f = CreateFrame("Frame");
f:RegisterEvent( "PLAYER_TARGET_CHANGED" );
f:SetScript( "OnEvent", function( self, event )
    local t = currentTargetInfo;
    if UnitExists("target") then
        t.name = UnitName("target");
        t.level = UnitLevel("target");
        t.icon = GetRaidTargetIndex("target") or 0;
        t.uniqueID = UnitGUID("target");
    end
    
    for timer in Cooldowns:GetCooldownsTarget():GetTimers() do
        if timer.onTarget then
            Cooldowns:UpdateAnchor( timer );
        end
    end
end );--]]

function listener:GetCurrentTargetInfo()
    return currentTargetInfo;
end

function listener:FindTimerSettings(name, anchor)
    name = string.lower(name);
    local settings = self:Get("userAnchors", anchor);
    if settings and settings.timerSettings then
        for set, setting in pairs(settings.timerSettings) do
            if string.find(name, set) then
                return setting;
            end
        end
    end
    return self:Get("standardSetting");
end

function listener:MakeTimer(timer)
    --self:Print(string.format("New Cooldown: %s (%f)!", timer.name, timer.duration));
    local anchor, group = self:FindAnchor(timer.name, timer.module ~= self);
    group = group or self:Get("displayName");
    if group == "*target*" then
        if UnitExists("target") then
            group = self:GetCurrentTargetInfo();
        else
            group = "Cooldowns";
        end
        timer.onTarget = true;
    else
        timer.onTarget = false;
    end
    local timerSettings;
    if timer.module == self then
        timerSettings = self:FindTimerSettings(timer.name, anchor);
    else
        timerSettings = timer.module.GetTimerSettings and timer.module:GetTimerSettings(self, timer.name) or nil;
    end
    local isHidden;
    if self:Get("whiteList") then
        isHidden = timer.module == self and not self:Get("visible", string.lower(timer.name));
    else
       isHidden = timer.module == self and self:Get("blocked", string.lower(timer.name));
    end
    local priority = timer.module == self and 0 or 10;
    local tID = TimerLib:NewTimer(timer, group, timer.module, timerSettings, priority, isHidden, anchor, 10, nil);
    --local tID, gID = TimerLib:NewTimer(timer, "Important", timer.module, nil, timer.module == self and 0 or 10, isHidden, "Important Anchor", 10, nil);
    timer.id = tID;
end

function listener:RemoveTimer(timer)
    --self:Print(string.format("Cooldown Done: %s!", timer.name));
    TimerLib:DeleteTimer(timer.id, (timer.module ~= self));
end

function listener:UpdateTimerData(timer)
    --self:Print(string.format("The timer data of %s has changed!", timer.name));
    TimerLib:UpdateTimer(timer.id);
    if timer.nameChanged then
        timer.nameChanged = false;
        self:UpdateAnchor(timer);
    end
end

listener.kblib = AsheylaLib:Import( "KBLib" ).new( listener );

listener:SetScript("OnTimerEnter", function(self, target, timer, id, frame)
    if not timer then return; end
    local point = "ANCHOR_RIGHT";
    local counter = 5;
    repeat
        local SpellLib = AsheylaLib:Import("SpellLib");
        target = timer.target;
        Ash_GameTooltip:SetOwner(frame, point);
        Ash_GameTooltip:ClearLines();
        local time = GetTime();
        
        if timer.foundTooltip == nil then
            timer.foundTooltip = false;
            local _, book, index = SpellLib:FindSpellInfo(timer.name, timer.rank, "spell");
            if book and index then
                timer.foundTooltip = true;
                timer.tooltipType = "spell";
                timer.tooltipBook = book;
                timer.tooltipIndex = index;
            else
                local _, _, itemID = SpellLib:FindSpellInfo(timer.name, nil, "item");
                if itemID then
                    timer.foundTooltip = true;
                    timer.tooltipType = "item";
                    timer.tooltipItemID = itemID;
                end
            end
        end
        
        if timer.foundTooltip then
            if timer.tooltipType == "spell" then
                Ash_GameTooltip:SetSpell(timer.tooltipIndex, timer.tooltipBook);
            else
                Ash_GameTooltip:SetHyperlink(SpellLib:ReturnItemLink(timer.tooltipItemID));
            end
            Ash_GameTooltip:AddLine(" ");
        end
        
        Ash_GameTooltip:AddLine(string.format("|cff00ff00%s|r %s", timer.name, timer.rank and "(|cff00ffff" .. timer.rank .. "|r)" or ""));
        Ash_GameTooltip:AddLine("Remaining: |cff6666ff" .. string.format(TimerLib:FormatTime(id, timer.duration - time + timer.time)));
        
        Ash_GameTooltip:AddLine(" ");
        Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Announce") .. "|r to announce.");
        Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Remove") .. "|r to remove.");
        Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Block") .. "|r to block.");
        
        Ash_GameTooltip:Show();
        if Ash_GameTooltip:GetWidth() * Ash_GameTooltip:GetEffectiveScale() >= (UIParent:GetRight() * UIParent:GetEffectiveScale()) - (frame:GetRight() * frame:GetEffectiveScale()) then
            if point == "ANCHOR_LEFT" then
                break;
            else
                point = "ANCHOR_LEFT";
            end
        else   
            break;
        end
        counter = counter - 1;
    until counter <= 0;
end)

listener:SetScript("OnTimerLeave", function(self, target, timer, id, frame)
    Ash_GameTooltip:Hide();
end)

listener:SetScript("OnTimerClick",function(self, target, timer, id, button)
    if timer then
        listener.kblib:ProcessClick("Timer", button, timer, id);
    else
        TimerLib:DeleteTimer(id, timer, 1);
    end
end)
listener.kblib:SetClickAction("Timer", "Remove", function(timer, id)
    TimerLib:DeleteTimer(id, timer, 1);
end)
listener.kblib:SetClickAction("Timer", "Block", function(timer)
    if timer then
        local frame = StaticPopup_Show("COOLDOWNS", timer.name)
        frame.data = timer.name;
        frame.data2 = listener;
    end
end)
local subTimer, subID;
local subFunc = function(a)
    if a == "%s" then
        return subTimer.name;
    elseif a == "%d" then
        return string.format(TimerLib:FormatTime(subID, subTimer.duration - GetTime() + subTimer.time));
    else
        return "";
    end
end
listener.kblib:SetClickAction("Timer", "Announce", function(timer, id)
    if listener:Get("isAnnouncing") then
        local subStr = listener:Get("standardAnnounce");
        subTimer, subID = timer, id;
        local msg = string.gsub(subStr, "(%%%a)", subFunc);
        local loc = GetNumRaidMembers() > 0 and "RAID" or GetNumPartyMembers() > 0 and "PARTY" or "SAY";
        SendChatMessage(msg, loc);
    end
end)
StaticPopupDialogs["COOLDOWNS"] = {
    text = "Are you sure you want to block |cff00ff00%s|r?  This can be undone from the options panel.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, name, module) module:Set("blocked", string.lower(name), 1); end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}
--]]
listener:AddDefaultSettings(defaultSettings);
listener:AddSettingsUpdateScript(function(self)
    if self:GetUserSet("keybindings") == nil then
        self:Set("keybindings", {
            ["Timer"] = {
                ["Announce"] = "1",
                ["Remove"] = "2",
                ["Block"] = "s-2",
            },
        });
    end
    if not self:GetUserSet("userAnchors") then
        self:Set("userAnchors", {
            ["Cooldowns Anchor"] = {
                default = true,
                timers = {},
                timerSettings = {},
                externalLoc = true,
            },
        });
    end
    if not self:Get("updatedSettings4.3") then
        self:Set("updatedSettings4.3", true);
        
        local uA = self:Get("userAnchors");
        for anchor, settings in pairs(uA) do
            if settings.timers then
                for name, val in pairs(settings.timers) do
                    if val then
                        settings.timers[name] = false;
                    else
                        settings.timers[name] = nil;
                    end
                end
            end
            
            if settings.timerSettings then
                local t = acquireTable();
                for anchor, entries in pairs(settings.timerSettings) do
                    -- reversing the lookup.  old system stored a list of timers per timer setting.  
                    -- new will store a list of timers whose value is the timer setting.
                    for entry in pairs(entries) do
                        t[entry] = anchor;
                    end
                end
                local oldT = settings.timerSettings;
                settings.timerSettings = t;
                releaseTable(oldT);
            end
            
            for name, val in pairs(settings) do
                if type(val) ~= "table" and name ~= "default" then
                    -- this changes e.g. settings.pbLoc from true to false, and false to nil.
                    -- in the new layout, nil = nothing, true = changing name, false = preserving target data.
                    -- currently, it's impossible not to preserve the target data here, so just setting it to false.
                    if val then
                        settings[name] = false; 
                    else
                        settings[name] = nil;
                    end
                end
            end
        end
    end
    if self:Get("enabled") then
        self:RegisterEvent("COOLDOWNS_NEW_TIMER", self.MakeTimer);
        self:RegisterEvent("COOLDOWNS_DONE_TIMER", self.RemoveTimer);
        self:RegisterEvent("COOLDOWNS_UPDATE_TIMERDATA", self.UpdateTimerData);
        for timer in self:GetCooldownsTarget():GetTimers() do
            self:UpdateAnchor(timer);
        end
    else
        self:UnregisterEvent("COOLDOWNS_NEW_TIMER");
        self:UnregisterEvent("COOLDOWNS_DONE_TIMER");
        self:UnregisterEvent("COOLDOWNS_UPDATE_TIMERDATA");
        TimerLib:DeleteAllTimers(self);
    end
end);

function listener:UpdateAnchor(timer)
    local anchor, group = self:FindAnchor(timer.name);
    group = group or self:Get("displayName");
    if group == "*target*" then
        if UnitExists("target") then
            group = self:GetCurrentTargetInfo();
        else
            group = "Cooldowns";
        end
        timer.onTarget = true;
    else
        timer.onTarget = false;
    end
    local timerSettings = self:FindTimerSettings(timer.name, anchor);
    local isHidden;
    if self:Get("whiteList") then
        isHidden = timer.module == self and not self:Get("visible", string.lower(timer.name));
    else
       isHidden = timer.module == self and self:Get("blocked", string.lower(timer.name));
    end
    local priority = timer.module == self and 0 or 10;
    TimerLib:UpdateTimerInfo(timer.id, priority, isHidden, timerSettings);
    TimerLib:MoveTimer(timer.id, group, anchor, 10, nil);
end

TimerLib:AddSettingsUpdateScript(function(self)
    if not self:GetUserSet("anchorSettings", "Cooldowns Anchor") then
        self:Set("anchorSettings", "Cooldowns Anchor", {defaultTimerSetting = "Cooldowns Timer"});
    end
    if not self:GetUserSet("timerSettings", "Cooldowns Timer") then
        self:Set("timerSettings", "Cooldowns Timer", {});
    end
    
    local default;
    for name, settings in pairs(Cooldowns:Get("userAnchors")) do
        if not self:Get("anchorSettings", name) then
            Cooldowns:Set("userAnchors", name, nil);
        elseif settings.default then
            default = name;
        end
    end
    if not default then
        Cooldowns:Set("userAnchors", "Cooldowns Anchor", "default", true);
    end
end);

local f = CreateFrame( "Frame" );
f.seen = {};
--f:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );
f:SetScript( "OnEvent", function( self, _, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName )
    if sourceGUID ~= UnitGUID( "player" ) then return; end
    
    if event == "SPELL_AURA_REMOVED" then
        local tar = self.seen[ destGUID ];
        if tar then
            tar[ spellName ] = nil;
        end
    end
    
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_PERIODIC_DAMAGE" then
        local time = GetTime();
        print( ("saw tick for %s: %.2f"):format( spellName, time ) );
        local tar = self.seen[ destGUID ] or {};
        self.seen[ destGUID ] = tar;
        local seen = tar[ spellName ] or {};
        tar[ spellName ] = seen;
        
        if seen[ -1 ] then
            print( ("error in guess: %.2f"):format( math.abs( time - seen[ -1 ] ) ) );
        end
        
        table.insert( seen, time );
        local n = #seen;
        if n == 2 then
            seen[ 0 ] = seen[ 2 ] - seen[ 1 ];
        elseif n > 2 then
            seen[ 0 ] = ( ( seen[ 0 ] * (n - 2) ) + (seen[ n ] - seen[ n - 1 ] ) ) / (n - 1);
        end
        if n > 1 then
            local elapsed = seen[ 0 ];
            seen[ -1 ] = time + elapsed;
            print( ("average elapsed time: %.2f"):format( elapsed ) );
            print( ("predicted tick for %s: %.2f"):format( spellName, time + elapsed ) );
        end
    end
end );
