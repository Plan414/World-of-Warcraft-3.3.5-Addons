AsheylaLib:Package( "DoTimer" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local SpellLib = AsheylaLib:Import( "SpellLib" );
local core = AsheylaLib:Import( "core" );
local listener = DoTimer;

local types = {
    [DoTimer.HELPFUL_TYPE] = "Helpful",
    [DoTimer.HARMFUL_TYPE] = "Harmful",
};

function listener:FindAnchor(tarName, timerName, tarGUID, filter, isMine)
    timerName = string.lower(timerName);
    local isPB = tarName == "Party Buffs";
    local isNT = tarName == "No Target";
    local isDoT = filter == self.HARMFUL_TYPE;
    local isHoT = filter == self.HELPFUL_TYPE;
    tarName = string.lower(tarName);
    local isStandard = not isPB and not isNT;
    local isFocus = isStandard and tarGUID == UnitGUID("focus");
    local isTarget = isStandard and tarGUID == UnitGUID("target");
    local otherLoc, specificLocT, specificLocF, specificLocN, targetLoc, focusLoc, standardLoc, timerLoc, dotLoc, hotLoc, nonStandardLoc, defaultLoc;
    local otherGroup, specificGroupT, specificGroupF, specificGroupN, targetGroup, focusGroup, standardGroup, timerGroup, dotGroup, hotGroup, nonStandardGroup, defaultGroup;
    
    for anchor, settings in pairs(self:Get("userAnchors")) do
        --[[
        if settings.specificTimers then
            local allowed = false;
            if settings.timers then
                for query in pairs(settings.timers) do
                    if string.find(timerName, query) then
                        allowed = anchor;
                        break;
                    end
                end
            end
            if settings.targets and allowed then
                if isTarget and settings.targets["*target*"] then
                    specificLocT = anchor;
                elseif isFocus and settings.targets["*focus*"] then
                    specificLocF = anchor;
                elseif isStandard and settings.targets[tarName] then
                    specificLocN = anchor;
                end
            end
        else
            if settings.timers then
                for query in pairs(settings.timers) do
                    if string.find(timerName, query) then
                        timerLoc = anchor;
                    end
                end
            end
            if settings.targets then
                if isTarget and settings.targets["*target*"] then
                    targetLoc = anchor;
                elseif isFocus and settings.targets["*focus*"] then
                    focusLoc = anchor;
                elseif isStandard and settings.targets[tarName] then
                    standardLoc = anchor;
                end
            end
        end--]]
        local standardName = settings.standardName or self:Get("standardName");
        
        local forBelow = false;
        if settings.targets then
            for k, v in pairs(settings.targets) do
                forBelow = forBelow or v[2];
            end
        end
        
        local allowed = false;
        if settings.timers then
            for query, useGroup in pairs(settings.timers) do
                if string.find(timerName, query) then
                    if not forBelow then
                        timerLoc = anchor;
                        timerGroup = useGroup and standardName;
                    end
                    allowed = true;
                end
            end
        end
        
        if settings.targets then
            if isTarget and settings.targets["*target*"] then
                local useGroup, checkTimer = unpack(settings.targets["*target*"]);
                if checkTimer then
                    if allowed then
                        specificLocT = anchor;
                        specificGroupT = useGroup and standardName;
                    end
                else
                    targetLoc = anchor;
                    targetGroup = useGroup and standardName;
                end
            elseif isFocus and settings.targets["*focus*"] then
                local useGroup, checkTimer = unpack(settings.targets["*focus*"]);
                if checkTimer then
                    if allowed then
                        specificLocF = anchor;
                        specificGroupF = useGroup and standardName;
                    end
                else
                    focusLoc = anchor;
                    focusGroup = useGroup and standardName;
                end
            elseif isStandard and settings.targets[tarName] then
                local useGroup, checkTimer = unpack(settings.targets[tarName]);
                if checkTimer then
                    if allowed then
                        specificLocN = anchor;
                        specificGroupN = useGroup and standardName;
                    end
                else
                    standardLoc = anchor;
                    standardName = useGroup and standardName;
                end
            end
        end
        
        
        if not isMine and settings.otherLoc ~= nil then otherLoc = anchor; otherGroup = settings.otherLoc and standardName; end
        if isPB and settings.pbLoc ~= nil then nonStandardLoc = anchor; nonStandardGroup = settings.pbLoc and standardName; end
        if isNT and settings.ntLoc ~= nil then nonStandardLoc = anchor; nonStandardGroup = settings.ntLoc and standardName; end
        if isDoT and settings.dotLoc ~= nil then dotLoc = anchor; dotGroup = settings.dotLoc and standardName; end
        if isHoT and settings.hotLoc ~= nil  then hotLoc = anchor; hotGroup = settings.hotLoc and standardName; end
        if settings.default then defaultLoc = anchor; defaultGroup = nil; end
    end
    
    return otherLoc or specificLocT or specificLocF or specificLocN or targetLoc or focusLoc or standardLoc or timerLoc or nonStandardLoc or dotLoc or hotLoc or defaultLoc, 
        otherGroup or specificGroupT or specificGroupF or specificGroupN or targetGroup or focusGroup or standardGroup or timerGroup or nonStandardGroup or dotGroup or hotGroup or defaultGroup; 
end

function listener:FindTimerSettings(name, anchor, tarName, isMine)
    name = string.lower(name);
    if isMine then
        local settings = self:Get("userAnchors", anchor);
        if settings and settings.timerSettings then
            for set, setting in pairs(settings.timerSettings) do
                if string.find(name, set) then
                    return setting;
                end
            end
        end
    end
    local setting = "standardSetting";
    if tarName == "No Target" then
        setting = "ntSetting";
    elseif tarName == "Party Buffs" then
        setting = "pbSetting";
    elseif not isMine then
        setting = "otherSetting";
    end
    return self:Get(setting);
end

function listener:MakeTimer(target, timer)
    --self:Print(string.format("New Timer: %s on %s!", timer.name, target.name));
    local isHidden;
    if self:Get("whiteList") then
        isHidden = timer.module == self and not self:Get("visible", string.lower(timer.name));
    else
        isHidden = timer.module == self and (self:Get("blocked", string.lower(timer.name)) or self:Get("blockedTypes", types[timer.type]));
    end
    local priority = timer.module == self and 0 or 10;
    local tPriority, tHidden = self:GetPriority(target);
    local anchor, group = self:FindAnchor(target.name, timer.name, target.uniqueID, timer.type, timer.isMine);
    local timerSettings;
    if timer.module == self then
        timerSettings = self:FindTimerSettings(timer.name, anchor, target.name, timer.isMine);
    else
        timerSettings = timer.module.GetTimerSettings and timer.module:GetTimerSettings(self, timer.name) or nil;
    end
    --local group = target.name == "No Target" and self:Get("ntName") or target.name == "Party Buffs" and self:Get("pbName") or movedTimer and self:Get("standardName") or target;
    --local group = (target.name == "No Target" or target.name == "Party Buffs") and "Important" or target;
    if not group then
        group = target.name == "No Target" and self:Get("ntName") or target.name == "Party Buffs" and self:Get("pbName") or target;
    end
    if type(group) == "string" then
        tPriority, tHidden = 10, nil;
    end
    timer.id = TimerLib:NewTimer(timer, group, timer.module, timerSettings, priority, isHidden, anchor, tPriority, tHidden);
end

function listener:RemoveTimer(target, timer)
    --self:Print(string.format("Timer Done: %s on %s!", timer.name, target.name));
    TimerLib:DeleteTimer(timer.id, (timer.module ~= self));
end

function listener:UpdateTargetData(target)
    --self:Print(string.format("The target data for %s has changed!", target.name));
    for timer in target:GetTimers() do
        TimerLib:UpdateGroup(timer.id);
    end
end

function listener:UpdateTimerData(timer)
    --self:Print(string.format("The timer data of %s on %s has changed!", timer.name, timer.target.name));
    TimerLib:UpdateTimer(timer.id);
    if timer.nameChanged then
        timer.nameChanged = false;
        self:UpdateAnchor(timer);
    end
end

function listener:GetPriority(target)
    local tarID, focID = UnitGUID("target"), UnitGUID("focus");
    local sT, sF, soT, soF = self:Get("sortTarget"), self:Get("sortFocus"), self:Get("showOnlyTarget"), self:Get("showOnlyFocus");
    local always = self:Get("always");
    
    local hidden = nil;
    if soT and soF and (tarID or focID or always) then
        if not (target.uniqueID == tarID or target.uniqueID == focID) then
            hidden = true;
        end
    elseif soT and (tarID or always) then
        if target.uniqueID ~= tarID then
            hidden = true;
        end
    elseif soF and (focID or always) then
        if target.uniqueID ~= focID then
            hidden = true;
        end
    end
    
    local priority = 2;
    if sT and target.uniqueID == tarID then
        priority = 0;
    elseif sF and target.uniqueID == focID then
        priority = 1;
    elseif target.name == "No Target" then
        priority = 3;
        hidden = nil;
    elseif target.name == "Party Buffs" then
        priority = 4;
        hidden = nil;
    end
    
    return priority, hidden;
end

function listener:UpdateAllPriorities()
    for _, target in DoTimer:GetTargets() do
        local priority, hidden = self:GetPriority(target);
        local group = (target.name == "No Target" or target.name == "Party Buffs") and target.name or target;
        for timer in target:GetTimers() do
            TimerLib:UpdateGroupInfo(timer.id, priority, hidden);
        end
    end
end

listener.kblib = AsheylaLib:Import( "KBLib" ).new( listener );

listener:SetScript("OnTimerEnter", function(self, target, timer, id, frame)
    if not timer then return; end
    local point = "ANCHOR_RIGHT";
    local counter = 5;
    repeat
        target = timer.target;
        Ash_GameTooltip:SetOwner(frame, point);
        Ash_GameTooltip:ClearLines();
        local time = GetTime();
        
        if target.name == "Party Buffs" then
            Ash_GameTooltip:AddLine("Filter: |cff00ff00" .. timer.partyBuffType);
            
            Ash_GameTooltip:AddLine("Active Spells:");
            local t = acquireTable();
            for guid, info in pairs(timer.affecting) do
                t[info.name] = 1;
            end
            for spell in pairs(t) do
                Ash_GameTooltip:AddLine("   |cff00ffff" .. spell);
            end
            releaseTable(t);
            
            Ash_GameTooltip:AddLine("Active On:");
            for guid, info in pairs(timer.affecting) do
                Ash_GameTooltip:AddLine(string.format("   |cffffffff%s|r (|cff6666ff%s|r)", info.person, string.format(TimerLib:FormatTime(id, info.duration - time + info.time))));
            end
            
            local displayedHeader = false;
            for guid, info in pairs(timer.notAffecting) do
                if not displayedHeader then
                    Ash_GameTooltip:AddLine("Not Active On:");
                    displayedHeader = true;
                end
                Ash_GameTooltip:AddLine("   |cffffffff" .. info.person);
            end
        else
            if timer.foundTooltip == nil then
                timer.foundTooltip = false;
                if timer.totemID then
                    timer.foundTooltip = true;
                else
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
            end
            
            if timer.foundTooltip then
                if timer.totemID then
                    Ash_GameTooltip:SetTotem(timer.totemID);
                elseif timer.tooltipType == "spell" then
                    Ash_GameTooltip:SetSpell(timer.tooltipIndex, timer.tooltipBook);
                else
                    Ash_GameTooltip:SetHyperlink(SpellLib:ReturnItemLink(timer.tooltipItemID));
                end
                Ash_GameTooltip:AddLine(" ");
            end
            
            Ash_GameTooltip:AddLine(string.format("|cff00ff00%s|r %s", timer.name, timer.rank and "(|cff00ffff" .. timer.rank .. "|r)" or ""));
            if target.name ~= "No Target" then
                Ash_GameTooltip:AddLine(string.format("On: |cffffffff[%s] %s", target.level == -1 and "??" or target.level, target.name)); 
            end
            Ash_GameTooltip:AddLine("Remaining: |cff6666ff" .. string.format(TimerLib:FormatTime(id, timer.duration - time + timer.time)));
            
            Ash_GameTooltip:AddLine(" ");
            Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Announce") .. "|r to announce.");
            Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Remove") .. "|r to remove.");
            Ash_GameTooltip:AddLine("|cffffffff" .. listener.kblib:GetKeyBinding("Timer", "Block") .. "|r to block.");
        end
        
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
        if timer.target.name == "Party Buffs" then
            core.alertUser("Party Buffs timers are non-interactable.");
        else
            listener.kblib:ProcessClick("Timer", button, timer, id);
        end
    else
        TimerLib:DeleteTimer(id, 1);
    end
end)
listener.kblib:SetClickAction("Timer", "Remove", function(timer, id)
    if timer.totemID then
        DestroyTotem(timer.totemID);
    else
        TimerLib:DeleteTimer(id, 1);
    end
end)
listener.kblib:SetClickAction("Timer", "Block", function(timer)
    if timer then
        if timer.isMine then
            local frame = StaticPopup_Show("DOTIMER", timer.name)
            frame.data = timer.name;
            frame.data2 = listener;
        else
            local frame = StaticPopup_Show("DOTIMER2", timer.name)
            frame.data = timer.name;
            frame.data2 = listener;
        end
    end
end)
local subTarget, subTimer, subID;
local raidIcons = {
    "star", "circle", "diamond", "triangle", "moon", "square", "cross", "skull"
};
local subFunc = function(a)
    if a == "%s" then
        return subTimer.name;
    elseif a == "%d" then
        return string.format(TimerLib:FormatTime(subID, subTimer.duration - GetTime() + subTimer.time));
    elseif a == "%l" then
        return (subTarget.level == -1 and "??" or subTarget.level);
    elseif a == "%r" then
        return (not subTarget.icon or subTarget.icon == 0) and "" or "{" .. raidIcons[subTarget.icon] .. "}";
    elseif a == "%t" then
        return subTarget.name;
    else
        return "";
    end
end
listener.kblib:SetClickAction("Timer", "Announce", function(timer, id)
    if listener:Get("isAnnouncing") then
        local target = timer.target;
        local subStr = target.name == "No Target" and listener:Get("noTargetAnnounce") or listener:Get("standardAnnounce");
        subTarget, subTimer, subID = target, timer, id;
        local msg = string.gsub(subStr, "(%%%a)", subFunc);
        local loc = GetNumRaidMembers() > 0 and "RAID" or GetNumPartyMembers() > 0 and "PARTY" or "SAY";
        SendChatMessage(msg, loc);
    end
end)
StaticPopupDialogs["DOTIMER"] = {
    text = "Are you sure you want to block |cff00ff00%s|r?  This can be undone from the options panel.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, name, module) module:Set("blocked", string.lower(name), 1); end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}
StaticPopupDialogs["DOTIMER2"] = {
    text = "Are you sure you want to stop seeing others' |cff00ff00%s|r?  This can be redone in the options panel.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, name, module) module:Set("otherTimers", string.lower(name), nil); end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}
--]]
local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_TARGET_CHANGED");
f:RegisterEvent("PLAYER_FOCUS_CHANGED");
f:SetScript("OnEvent", function(self, event)
    DoTimer:UpdateTimerAnchors();
end);

local defaultSettings = {
    sortTarget = false;
    sortFocus = false;
    showOnlyTarget = false;
    showOnlyFocus = false;
    keybindings = {},
    userAnchors = {},
    blocked = {},
    visible = {},
    whiteList = false,
    blockedTypes = {},
    isAnnouncing = true,
    pbName = "Party Buffs",
    ntName = "No Target",
    standardName = "DoTimer",
    standardSetting = nil,
    ntSetting = nil,
    pbSetting = nil,
    otherSetting = nil,
    noTargetAnnounce = "My %s will expire in %d.",
    standardAnnounce = "My %s on %r%t will expire in %d.",
};
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
    if self:GetUserSet("userAnchors") == nil then
        self:Set("userAnchors", {
            ["DoTimer Anchor"] = {
                default = true,
                targets = {},
                timerSettings = {},
            },
        });
    end
    if not self:Get("updatedSettings4.3") then
        self:Set("updatedSettings4.3", true);
        
        local uA = self:Get("userAnchors");
        for anchor, settings in pairs(uA) do
            if settings.targets then
                for name, val in pairs(settings.targets) do
                    -- in the new layout, we need to track 2 pieces of information.
                    -- first is if we're changing name.  again, currently impossible, so set to false.
                    -- second is if we're only moving for below timers.  look at settings.specificTimers for value.
                    if val then
                        settings.targets[name] = {false, settings.specificTimers and true or false};
                    else
                        settings.targets[name] = nil;
                    end
                end
            end
            
            if settings.timers then
                for name, val in pairs(settings.timers) do
                    -- again, changing name or not.  this one was actually possible.  negate settings.preserveTarget.
                    if val then
                        settings.timers[name] = not settings.preserveTarget;
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
        self:RegisterEvent("DOTIMER_NEW_TIMER", self.MakeTimer);
        self:RegisterEvent("DOTIMER_DONE_TIMER", self.RemoveTimer);
        self:RegisterEvent("DOTIMER_UPDATE_TARGETDATA", self.UpdateTargetData);
        self:RegisterEvent("DOTIMER_UPDATE_TIMERDATA", self.UpdateTimerData);
        self:UpdateTimerAnchors();
    else
        self:UnregisterEvent("DOTIMER_NEW_TIMER");
        self:UnregisterEvent("DOTIMER_DONE_TIMER");
        self:UnregisterEvent("DOTIMER_UPDATE_TARGETDATA");
        self:UnregisterEvent("DOTIMER_UPDATE_TIMERDATA");
        TimerLib:DeleteAllTimers(self);
    end
end);

function listener:UpdateAnchor(timer)
    local target = timer.target;
    local tPriority, tHidden = self:GetPriority(target);
    local anchor, group = self:FindAnchor(target.name, timer.name, target.uniqueID, timer.type, timer.isMine);
    local isHidden;
    if self:Get("whiteList") then
        isHidden = timer.module == self and not self:Get("visible", string.lower(timer.name));
    else
        isHidden = timer.module == self and (self:Get("blocked", string.lower(timer.name)) or self:Get("blockedTypes", types[timer.type]));
    end
    local priority = timer.module == self and 0 or 10;
    local timerSettings = self:FindTimerSettings(timer.name, anchor, target.name, timer.isMine);
    TimerLib:UpdateTimerInfo(timer.id, priority, isHidden, timerSettings);
    --local group = target.name == "No Target" and self:Get("ntName") or target.name == "Party Buffs" and self:Get("pbName") or movedTimer and self:Get("standardName") or target;
    if not group then
        group = target.name == "No Target" and self:Get("ntName") or target.name == "Party Buffs" and self:Get("pbName") or target;
    end
    TimerLib:MoveTimer(timer.id, group, anchor, type(group) ~= "string" and tPriority or 10, type(group) ~= "string" and tHidden or nil);
    if group == target then
        TimerLib:UpdateGroupInfo(timer.id, tPriority, tHidden);
    end
end

function listener:UpdateTimerAnchors()
    for i, target in self:GetTargets() do
        for timer in target:GetTimers() do
            self:UpdateAnchor(timer);
        end
    end
end

TimerLib:AddSettingsUpdateScript(function(self)
    if not self:GetUserSet("anchorSettings", "DoTimer Anchor") then
        self:Set("anchorSettings", "DoTimer Anchor", {defaultTimerSetting = "DoTimer Timer"});
    end
    if not self:GetUserSet("timerSettings", "DoTimer Timer") then
        self:Set("timerSettings", "DoTimer Timer", {});
    end
    
    local default;
    for name, settings in pairs(DoTimer:Get("userAnchors")) do
        if not self:Get("anchorSettings", name) then
            DoTimer:Set("userAnchors", name, nil);
        elseif settings.default then
            default = name;
        end
    end
    if not default then
        DoTimer:Set("userAnchors", "DoTimer Anchor", "default", true);
    end
end);
