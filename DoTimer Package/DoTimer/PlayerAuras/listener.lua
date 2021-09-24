AsheylaLib:Package( "PlayerAuras" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local listener = PlayerAuras;

local defaultSettings = {
    isAnnouncing = true,
};

for unit in pairs(PlayerAuras.units) do
    local suffix = unit == "player" and "" or "-" .. unit;
    
    defaultSettings["displayName-Buffs" .. suffix] = "Buffs";
    defaultSettings["blocked-Buffs" .. suffix] = {};
    defaultSettings["visible-Buffs" .. suffix] = {};
    defaultSettings["whiteList-Buffs" .. suffix] = false;
    defaultSettings["userAnchors-Buffs" .. suffix] = {};
    defaultSettings["standardAnnounce-Buffs" .. suffix] = "My %s will expire in %d.";
    defaultSettings["noDurationAnnounce-Buffs" .. suffix] = "I have the %s buff.";
    defaultSettings["standardSetting-Buffs" .. suffix] = nil;
    defaultSettings["noDurSetting-Buffs" .. suffix] = nil;
    defaultSettings["displayName-Debuffs" .. suffix] = "Debuffs";
    defaultSettings["blocked-Debuffs" .. suffix] = {};
    defaultSettings["visible-Debuffs" .. suffix] = {};
    defaultSettings["whiteList-Debuffs" .. suffix] = false;
    defaultSettings["userAnchors-Debuffs" .. suffix] = {};
    defaultSettings["standardAnnounce-Debuffs" .. suffix] = "My %s will expire in %d.";
    defaultSettings["noDurationAnnounce-Debuffs" .. suffix] = "I'm afflicted by the %s debuff.";
    defaultSettings["standardSetting-Debuffs" .. suffix] = nil;
    defaultSettings["noDurSetting-Debuffs" .. suffix] = nil;
    defaultSettings["timerSetting-Magic" .. suffix] = nil;
    defaultSettings["timerSetting-Poison" .. suffix] = nil;
    defaultSettings["timerSetting-Disease" .. suffix] = nil;
    defaultSettings["timerSetting-Curse" .. suffix] = nil;
    defaultSettings["timerSetting-Physical" .. suffix] = nil;
end

local function capitalize(str)
    return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2));
end

function listener:FindAnchor(name, target, duration, suffix)
    name = string.lower(name);
    local default, noDurLoc;
    local defaultGroup, noDurGroup;
    for anchor, settings in pairs(self:Get("userAnchors-" .. target .. suffix)) do
        local standardName = settings.standardName or self:Get("displayName-" .. target .. suffix);
        if duration == nil and settings.noDurLoc ~= nil then
            noDurLoc = anchor;
            noDurGroup = settings.noDurLoc and standardName;
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
    
    return noDurLoc or default, 
        noDurGroup or defaultGroup;
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
    
    for _, bnd in pairs(PlayerAuras.units) do
        for _, target in pairs(bnd) do
            for timer in target:GetTimers() do
                PlayerAuras:UpdateAnchor(timer);
            end
        end
    end
end );--]]

function listener:GetCurrentTargetInfo()
    return currentTargetInfo;
end

function listener:FindTimerSettings(name, anchor, target, duration, type, suffix)
    name = string.lower(name);
    local settings = self:Get("userAnchors-" .. target .. suffix, anchor);
    if settings and settings.timerSettings then
        for set, setting in pairs(settings.timerSettings) do
            if string.find(name, set) then
                return setting;
            end
        end
    end
    if type then
        local setting = self:Get("timerSetting-" .. type .. suffix);
        if setting then
            return setting;
        end
    end
    local setting = "standardSetting-" .. target .. suffix;
    if not duration then
        setting = "noDurSetting-" .. target .. suffix;
    end
    return self:Get(setting);
end

function listener:MakeTimer(target, timer)
    --print(target.unit, target.name, timer.name);
    local suffix = target.unit == "player" and "" or "-" .. target.unit;
    local anchor, group = self:FindAnchor(timer.name, target.name, timer.duration, suffix);
    local timerSettings;
    if timer.module == self then
        timerSettings = self:FindTimerSettings(timer.name, anchor, target.name, timer.duration, timer.debuffType, suffix);
    else
        timerSettings = timer.module.GetTimerSettings and timer.module:GetTimerSettings(self, timer.name) or nil;
    end
    local isHidden;
    if self:Get("whiteList-" .. target.name .. suffix) then
        isHidden = timer.module == self and not self:Get("visible-" .. target.name .. suffix, string.lower(timer.name));
    else
        isHidden = timer.module == self and self:Get("blocked-" .. target.name .. suffix, string.lower(timer.name));
    end
    local priority = timer.module == self and 0 or 10;
    group = group or self:Get("displayName-" .. target.name .. suffix);
    if group == "*target*" then
        if UnitExists("target") then
            group = self:GetCurrentTargetInfo();
        else
            group = target.name;
        end
        timer.onTarget = true;
    else
        timer.onTarget = false;
    end
    local tID = TimerLib:NewTimer(timer, group, timer.module, timerSettings, priority, isHidden, anchor, 10, nil);
    timer.id = tID;
end

function listener:RemoveTimer(target, timer)
    TimerLib:DeleteTimer(timer.id, (timer.module ~= self));
end

function listener:UpdateTimerData(timer)
    local updated = TimerLib:UpdateTimer(timer.id);
    if updated then
        if timer.nameChanged then
            timer.nameChanged = false;
            self:UpdateAnchor(timer);
        end
    else
        -- stupid blizzard's stupid temp enchant code causing stupid problems
        if timer.type == "tempEnchant" then
            self:ClearTempEnchantTimer(timer);
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
        local filter = target.name == "Buffs" and "HELPFUL" or "HARMFUL";
        Ash_GameTooltip:SetOwner(frame, point);
        Ash_GameTooltip:ClearLines();
        local time = GetTime();
        
        if timer.type == "tempEnchant" then
            Ash_GameTooltip:SetInventoryItem("player", timer.weapID);
        elseif timer.type == "tracking" then
            Ash_GameTooltip:SetTracking(timer.trackID);
        elseif timer.type == "stance" then
            Ash_GameTooltip:SetShapeshift(timer.stanceID);
        else
            Ash_GameTooltip:SetUnitAura(target.unit, timer.buffID, filter);
            
            -- The following code is from the addon ICWutUDidThere by Shefki (taken by permission).
            local TOOLTIP_TEXT = "Applied by %s";
            local PET_TEXT = "%s <%s>";
            local _, _, _, _, _, _, _, caster = UnitAura(target.unit, timer.buffID, filter);
            if caster then
                local display_name;
                if caster == "vehicle" or caster == "pet" then
                    display_name = string.format(PET_TEXT, UnitName(caster), UnitName("player"));
                elseif string.sub(caster, 1, 8) == "partypet" and string.sub(caster, -6) ~= "target" then
                    local party_id = string.sub(caster, 9);
                    display_name = string.format(PET_TEXT, UnitName(caster), UnitName("party" .. party_id));
                elseif string.sub(caster, 1, 7) == "raidpet" and string.sub(caster, -6) ~= "target" then
                    local raid_id = string.sub(caster, 8);
                    display_name = string.format(PET_TEXT, UnitName(caster), UnitName("raid" .. raid_id));
                else
                    display_name = UnitName(caster);
                end

                Ash_GameTooltip:AddLine(string.format(TOOLTIP_TEXT, display_name));
            end
            -- end code stealing!
            
        end
        Ash_GameTooltip:AddLine(" ");
        
        Ash_GameTooltip:AddLine(string.format("|cff00ff00%s|r", timer.name));
        if timer.duration then
            Ash_GameTooltip:AddLine("Remaining: |cff6666ff" .. string.format(TimerLib:FormatTime(id, timer.duration - time + timer.time)));
        end
        
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
        listener.kblib:ProcessClick("Timer", button, timer, id, timer.target);
    else
        TimerLib:DeleteTimer(id, 1);
    end
end)
listener.kblib:SetClickAction("Timer", "Remove", function(timer, id)
    if timer.type == "tempEnchant" then
        CancelItemTempEnchantment(timer.weapID - 15);
    elseif timer.type == "tracking" then
        SetTracking(nil);
    elseif timer.type == "stance" then
        -- can't cancel stances, silly!
    elseif UnitIsUnit(timer.target.unit, "player") then
        CancelUnitBuff("player", timer.buffID, timer.filter);
    end
end)
listener.kblib:SetClickAction("Timer", "Block", function(timer, _, target)
    if timer then
        local frame = StaticPopup_Show("PLAYERAURAS", timer.name)
        frame.data = timer.name;
        frame.data2 = target.name .. (target.unit == "player" and "" or "-" .. target.unit);
    end
end)
local subTimer, subID;
local subFunc = function(a)
    if a == "%s" then
        return subTimer.name;
    elseif a == "%d" then
        return subTimer.duration and string.format(TimerLib:FormatTime(subID, subTimer.duration - GetTime() + subTimer.time)) or "";
    else
        return "";
    end
end
listener.kblib:SetClickAction("Timer", "Announce", function(timer, id, target)
    if listener:Get("isAnnouncing") then
        local prefix = timer.duration and "standardAnnounce-" or "noDurationAnnounce-";
        local suffix = target.name .. (target.unit == "player" and "" or "-" .. target.unit);
        local subStr = listener:Get(prefix .. suffix);
        subTimer, subID = timer, id;
        local msg = string.gsub(subStr, "(%%%a)", subFunc);
        local loc = GetNumRaidMembers() > 0 and "RAID" or GetNumPartyMembers() > 0 and "PARTY" or "SAY";
        SendChatMessage(msg, loc);
    end
end)
StaticPopupDialogs["PLAYERAURAS"] = {
    text = "Are you sure you want to block |cff00ff00%s|r?  This can be undone from the options panel.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, name, target) listener:Set("blocked-" .. target, string.lower(name), 1); end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}
--]]
function listener:UpdateAnchor(timer)
    local name = timer.target.name;
    local suffix = timer.target.unit == "player" and "" or "-" .. timer.target.unit;
    local anchor, group = self:FindAnchor(timer.name, name, timer.duration, suffix);
    
    local timerSettings = self:FindTimerSettings(timer.name, anchor, name, timer.duration, timer.debuffType, suffix);
    local isHidden;
    if self:Get("whiteList-" .. name .. suffix) then
        isHidden = timer.module == self and not self:Get("visible-" .. name .. suffix, string.lower(timer.name));
    else
        isHidden = timer.module == self and self:Get("blocked-" .. name .. suffix, string.lower(timer.name));
    end
    local priority = timer.module == self and 0 or 10;
    TimerLib:UpdateTimerInfo(timer.id, priority, isHidden, timerSettings);
    group = group or self:Get("displayName-" .. name .. suffix);
    if group == "*target*" then
        if UnitExists("target") then
            group = self:GetCurrentTargetInfo();
        else
            group = target.name;
        end
        timer.onTarget = true;
    else
        timer.onTarget = false;
    end
    TimerLib:MoveTimer(timer.id, group, anchor, 10, nil);
end

local bnd = {"Buffs", "Debuffs"};
listener:AddDefaultSettings(defaultSettings);
listener:AddSettingsUpdateScript(function(self)
    --print(debugstack());
    --AceLibrary('AceConsole-2.0'):PrintLiteral(self:Get("userAnchors-Buffs"))
    if self:GetUserSet("keybindings") == nil then
        self:Set("keybindings", {
            ["Timer"] = {
                ["Announce"] = "1",
                ["Remove"] = "2",
                ["Block"] = "s-2",
            },
        });
    end
    for unit in pairs(self.units) do
        local suffix = unit == "player" and "" or "-" .. unit;
        if not self:GetUserSet("userAnchors-Buffs" .. suffix) then
            self:Set("userAnchors-Buffs" .. suffix, {
                [capitalize(unit) .. "Auras Anchor"] = {
                    default = true,
                    timers = {},
                    timerSettings = {},
                },
            });
        end
        if not self:GetUserSet("userAnchors-Debuffs" .. suffix) then
            self:Set("userAnchors-Debuffs" .. suffix, {
                [capitalize(unit) .. "Auras Anchor"] = {
                    default = true,
                    timers = {},
                    timerSettings = {},
                },
            });
        end
        if self:GetUserSet("buffsName" .. suffix) then
            local old = self:Get("buffsName" .. suffix);
            self:Set("buffsName" .. suffix, nil);
            self:Set("displayName-Buffs" .. suffix, old);
        end
        if self:GetUserSet("debuffsName" .. suffix) then
            local old = self:Get("debuffsName" .. suffix);
            self:Set("debuffsName" .. suffix, nil);
            self:Set("displayName-Debuffs" .. suffix, old);
        end
    end
    --AceLibrary('AceConsole-2.0'):PrintLiteral(self:Get("userAnchors-Buffs"))
    if not self:Get("updatedSettings4.3") then
        self:Set("updatedSettings4.3", true);
        for unit in pairs(self.units) do
            for _, t in ipairs(bnd) do
                local uA = self:Get("userAnchors-" .. t .. (unit == "player" and "" or "-" .. unit));
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
        end
    end
    --AceLibrary('AceConsole-2.0'):PrintLiteral(self:Get("userAnchors-Buffs"))
    if not self:Get("updatedSettings4.3.3") then
        self:Set("updatedSettings4.3.3", true);
        self:Set("whiteList-Buffs", self:Get("whiteList"));
        self:Set("whiteList-Debuffs", self:Get("whiteList"));
        self:Set("whiteList", nil);
        for unit in pairs(self.units) do
            local suffix = unit == "player" and "" or "-" .. unit;
            if suffix ~= "" then
                for _, t in ipairs(bnd) do
                    local old = self:Get("userAnchors-" .. t .. suffix, "PlayerAuras Anchor-" .. unit);
                    if old then
                        self:Set("userAnchors-" .. t .. suffix, capitalize(unit) .. "Auras Anchor", old);
                        self:Set("userAnchors-" .. t .. suffix, "PlayerAuras Anchor-" .. unit, nil);
                    end
                end
                local old = TimerLib:Get("anchorSettings", "PlayerAuras Anchor-" .. unit);
                if old then
                    TimerLib:Set("anchorSettings", capitalize(unit) .. "Auras Anchor", old);
                    TimerLib:Set("anchorSettings", "PlayerAuras Anchor-" .. unit, nil);
                end
            end
        end
    end
    --AceLibrary('AceConsole-2.0'):PrintLiteral(self:Get("userAnchors-Buffs"))
    if self:Get("enabled") and not AsheylaLib:InSimpleMode() then
        self:RegisterEvent("PLAYERAURAS_NEW_TIMER", self.MakeTimer);
        self:RegisterEvent("PLAYERAURAS_DONE_TIMER", self.RemoveTimer);
        self:RegisterEvent("PLAYERAURAS_UPDATE_TIMERDATA", self.UpdateTimerData);
        
        for unit, filters in pairs(self.units) do
            local suffix = unit == "player" and "" or "-" .. unit;
            if self:Get("showUnit" .. suffix) then
                if not TimerLib:Get("anchorSettings", capitalize(unit) .. "Auras Anchor") then
                    TimerLib:Set("anchorSettings", capitalize(unit) .. "Auras Anchor", {
                        groupSortMethod = "Alphabetical (A)",
                        defaultTimerSetting = "PlayerAuras Timer",
                    });
                end
                for name, target in pairs(filters) do
                    for timer in target:GetTimers() do
                        self:UpdateAnchor(timer);
                    end
                end
            end
        end
    else
        self:UnregisterEvent("PLAYERAURAS_NEW_TIMER");
        self:UnregisterEvent("PLAYERAURAS_DONE_TIMER");
        self:UnregisterEvent("PLAYERAURAS_UPDATE_TIMERDATA");
        TimerLib:DeleteAllTimers(self);
    end
    --AceLibrary('AceConsole-2.0'):PrintLiteral(self:Get("userAnchors-Buffs"))
    --print("end")
end);

TimerLib:AddSettingsUpdateScript(function(self)
    if not self:GetUserSet("timerSettings", "PlayerAuras Timer") then
        self:Set("timerSettings", "PlayerAuras Timer", {});
    end
    
    for unit in pairs(PlayerAuras.units) do
        local suffix = unit == "player" and "" or "-" .. unit;
        if PlayerAuras:Get("showUnit" .. suffix) then
            if not self:GetUserSet("anchorSettings", capitalize(unit) .. "Auras Anchor") then
                self:Set("anchorSettings", capitalize(unit) .. "Auras Anchor", {
                    groupSortMethod = "Alphabetical (A)",
                    defaultTimerSetting = "PlayerAuras Timer",
                });
            end
            
            local default;
            for name, settings in pairs(PlayerAuras:Get("userAnchors-Buffs" .. suffix)) do
                if not self:Get("anchorSettings", name) then
                    PlayerAuras:Set("userAnchors-Buffs" .. suffix, name, nil);
                elseif settings.default then
                    default = name;
                end
            end
            if not default then
                PlayerAuras:Set("userAnchors-Buffs" .. suffix, capitalize(unit) .. "Auras Anchor", "default", true);
            end
            
            default = nil;
            for name, settings in pairs(PlayerAuras:Get("userAnchors-Debuffs" .. suffix)) do
                if not self:Get("anchorSettings", name) then
                    PlayerAuras:Set("userAnchors-Debuffs" .. suffix, name, nil);
                elseif settings.default then
                    default = name;
                end
            end
            if not default then
                PlayerAuras:Set("userAnchors-Debuffs" .. suffix, capitalize(unit) .. "Auras Anchor", "default", true);
            end
        end
    end
end);
