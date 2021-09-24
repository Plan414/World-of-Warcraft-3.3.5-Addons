AsheylaLib:Package( "Notifications" );

Notifications = AsheylaLib:NewModule("Notifications");
local TimerLib = AsheylaLib:Import( "TimerLib" );

function Notifications:GetEvent(...)
    if self:Get("charSpecific") then
        local guid = UnitGUID("player");
        if not guid then return; end
        guid = "0x" .. string.sub(guid, -7, -1);
        if self:Get(guid, "events") == nil then
            self:Set(guid, "events", {});
        end
        return self:Get(guid, "events", ...);
    else
        return self:Get("events", ...);
    end
end

function Notifications:SetEvent(...)
    if self:Get("charSpecific") then
        local guid = UnitGUID("player");
        guid = "0x" .. string.sub(guid, -7, -1);
        self:Set(guid, "events", ...);
    else
        self:Set("events", ...);
    end
end

function Notifications:CheckFlags(data)
    if data.flags then
        local flags = data.flags;
        local inCombat = UnitAffectingCombat("player");
        local inGroup = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0;
        local isAlive = not UnitIsDeadOrGhost("player");
        
        if flags.disabled then return false; end
        
        if flags.whileAlive and not isAlive then return false; end
        if flags.notResting and IsResting() then return false; end
        if not (flags.onlySolo and flags.inGroup) then
            if flags.onlySolo and inGroup then return false; end
            if flags.inGroup and not inGroup then return false; end
        end
        if not (flags.inCombat and flags.outOfCombat) then
            if flags.inCombat and not inCombat then return false; end
            if flags.outOfCombat and inCombat then return false; end
        end
        if not (flags.spec1 and flags.spec2) then
            local spec = GetActiveTalentGroup();
            if flags.spec2 and spec == 1 then return false; end
            if flags.spec1 and spec == 2 then return false; end
        end
    end
    
    return true;
end

function Notifications:FireEvent(event, ...)
    local events = self:GetEvent(event);
    if not events then return; end
    local comp = select(1, ...);
    if events.exact then
        for _, subEvent in ipairs(events.exact) do
            if (string.lower(comp) == string.lower(subEvent.comp)) then
                self:FireAnnouncements(subEvent, ...);
                return;
            end
        end
    end
    
    if events.partial then
        for _, subEvent in ipairs(events.partial) do
            if (string.find(string.lower(comp), string.lower(subEvent.comp))) then
                self:FireAnnouncements(subEvent, ...);
                return;
            end
        end
    end
    
    if events.all then
        self:FireAnnouncements(events.all, ...);
    end
end

local tempData = {};
function Notifications:FireAnnouncements(entries, ...)
    if entries.always then
        for _, data in ipairs(entries.always) do
            if self:CheckFlags(data) then
                self:AnnounceOrDelay(data, ...);
            end
        end
    end
    
    if entries.random and math.random() <= entries.rand / 100 then
        for k in pairs(tempData) do tempData[k] = nil; end
        for d in ipairs(entries.random) do
            if self:CheckFlags(d) then table.insert(tempData, d); end
        end
        self:AnnounceOrDelay(tempData[math.random(1, #tempData)], ...);
    end
end

function Notifications:AnnounceOrDelay(data, ...)
    if data.delay and data.delay > 0 then
        self:Delay(data, ...);
    else
        self:Announce(data, ...);
    end
end

local delayFrame = CreateFrame("Frame", nil, UIParent);
delayFrame.delayedEvents = {};
local delayScript = function(self, elapsed)
    for i, delay in ipairs(self.delayedEvents) do
        delay.elapsed = delay.elapsed + elapsed;
        if delay.elapsed >= delay.duration then
            Notifications:Announce(delay.data, delay.args);
            table.remove(self.delayedEvents, i);
            releaseTable(delay);
            if #self.delayedEvents == 0 then
                self:SetScript("OnUpdate", nil);
            end
        end
    end
end
function Notifications:Delay(data, ...)
    local delay = acquireTable();
    delay.elapsed = 0;
    delay.duration = data.delay;
    delay.data = data;
    delay.args = acquireTable();
    for i = 1, select("#", ...) do
        delay.args[i] = select(i, ...);
    end
    table.insert(delayFrame.delayedEvents, delay);
    delayFrame:SetScript("OnUpdate", delayScript);
end

local subEntries = {};
local subFunc = function(num) return subEntries[tonumber(num)] or num; end
function Notifications:Announce(data, ...)
    local msg, target = data.msg, data.target;
    if (data.msg and string.find(data.msg, "%%%d")) or (data.target and string.find(data.target, "%%%d")) then
        if type(...) == "table" then
            releaseTable(subEntries);
            subEntries = ...;
        else
            local num = select("#", ...);
            for i = 1, num do
                subEntries[i] = select(i, ...);
            end
            for i = num + 1, #subEntries do
                table.remove(subEntries, num + 1);
            end
        end
        if data.msg then msg = string.gsub(data.msg, "%%(%d)", subFunc); end
        if data.target then target = string.gsub(data.target, "%%(%d)", subFunc); end
    end
    
    if data.type == "sound" then
        self:PlaySound("Interface\\AddOns\\DoTimer\\Core\\Files\\" .. data.file);
    elseif data.type == "sct" then
        self:SCTAlert(msg, data.color, data.frame);
    elseif data.type == "alert" then
        self:Alert(msg, data.color.r, data.color.g, data.color.b, data.height);
    elseif data.type == "text" then
        self:Text(msg, data.color.r, data.color.g, data.color.b);
    elseif data.type == "flash" then
        if data.colorName then
            local flash_colors = {
                ["Blue"] = {r = 0, g =  0, b = 1},
                ["Green"] = {r = 0, g = 1, b = 0},
                ["Orange"] = {r = 1, g = .5, b = .2}, -- why did i pick this instead of 0, 1, 1?  it will forever be a mystery
                ["Purple"] = {r = 1, g = 0, b = 1},
                ["Red"] = {r = 1, g = 0, b = 0},
                ["Yellow"] = {r = 1, g = 1, b = 0},
            };
            data.color = flash_colors[data.colorName];
            data.colorName = nil;
        end
        self:Flash(data.color.r, data.color.g, data.color.b, data.fadeInTime, data.fadeOutTime, data.pulses);
    elseif data.type == "chat" then
        self:ChatMsg(msg, data.chatType, target);
    elseif data.type == "timer" then
        local setting = data.setting or self:Get("timerSetting");
        if setting == "None" then setting = nil; end
        self:Timer(msg, data.duration, setting, data.group or self:Get("groupSetting"), data.anchor or self:Get("anchorSetting"));
    end
end

local defaultSound = "Interface\\AddOns\\DoTimer\\Core\\Files\\alert.wav";
function Notifications:PlaySound(soundFile)
    PlaySoundFile(soundFile or defaultSound);
end

local defaultColor = {r = 1, g = 1, b = 1};
function Notifications:SCTAlert(msg, color, frame)
    msg = msg or "Alert!";
    color = color or defaultColor;
    frame = frame or SCT and "SCT Frame 1" or MikSBT and "MikSBT" or "Blizzard FCT";
    
    if SCT and frame == "SCT Frame 1" then
        SCT:DisplayText(msg, color, nil , nil, 1);
    elseif SCT and frame == "SCT Frame 2" then
        SCT:DisplayText(msg, color, nil , nil, 2);
    elseif SCTD and frame == "SCT Damage" then
        SCT:DisplayText(msg, color, nil , nil, 3);
    elseif SCT and frame == "SCT Message" then
        SCT:DisplayMessage(msg, color);
    elseif MikSBT and frame == "MikSBT" then
        MikSBT.DisplayMessage(msg, nil, nil, (color.r * 255), (color.g * 255), (color.b * 255));
    elseif IsAddOnLoaded("Blizzard_CombatText") then
        CombatText_AddMessage(msg, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b);
    end
end

local alertFrame = CreateFrame("Frame", nil, UIParent);
local f = alertFrame:CreateFontString();
local anchor = CreateFrame("Frame");
anchor:SetWidth(1);
anchor:SetHeight(1);
alertFrame.text = f;
alertFrame.anchor = anchor;
f:SetParent(alertFrame);
local name, height = NumberFontNormal:GetFont();
local acctName = GetCVar("accountName");
if (acctName == "zxy98789@aim.com") then
    name = "Fonts\\FRIZQT__.TTF";
end
f:SetFont(name, 20, "THICKOUTLINE");
f:ClearAllPoints();
f:SetPoint("CENTER", anchor);
f:SetText("");
alertFrame:SetAllPoints(f);
alertFrame.updateFunc = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed;
    elapsed = self.elapsed;
    local alpha, scale = 1, 1;
    if elapsed <= .2 then
        alpha = 5 * elapsed;
        scale = .8 + (2 * elapsed);
    elseif elapsed <= .4 then
        scale = 1.2 - elapsed + .2;
    elseif elapsed >= self.duration + 1 then
        alpha = 0;
        self:SetScript("OnUpdate", nil);
    elseif elapsed >= self.duration then
        alpha = 1 - elapsed + self.duration;
    end
    self:SetScale(scale);
    self:SetAlpha(alpha);
end
function alertFrame.SetAlertText(self, text, r, g, b, height, duration)
    self.text:SetText(text or "Alert!");
    self.text:SetTextColor(r or 1, g or 1, b or 1);
    self.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, height or 80);
    self.elapsed = 0;
    self.duration = duration or 3;
    self:SetScale(.8);
    self:SetAlpha(0);
    self:SetScript("OnUpdate", self.updateFunc);
end

function Notifications:Alert(msg, r, g, b, duration)
    alertFrame:SetAlertText(msg, r, g, b, duration);
end

function Notifications:Text(msg, r, g, b)
    msg = msg or "Default Msg";
    DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
end

local flashFrame = CreateFrame("Frame", "NotificationsFlashFrame", UIParent);
flashFrame:Hide();
flashFrame:SetAllPoints(true);
flashFrame:SetToplevel(true);
local t = flashFrame:CreateTexture(nil, "BACKGROUND");
flashFrame.texture = t;
t:SetBlendMode("ADD");
t:SetAllPoints(true);
t:SetTexture("Interface\\AddOns\\DoTimer\\Core\\Files\\Flash");
function flashFrame.SetFlashColor(self, r, g, b)
    self.texture:SetVertexColor(r, g, b);
end
function Notifications:Flash(r, g, b, fadeInTime, fadeOutTime, pulses)
    flashFrame:SetFlashColor(r or 1, g or 0, b or 0);
    fadeInTime = fadeInTime or .5;
    fadeOutTime = fadeOutTime or .5;
    local duration = (pulses or 2) * (fadeInTime + fadeOutTime);
    UIFrameFlash(flashFrame, fadeInTime, fadeOutTime, duration);
end

function Notifications:ChatMsg(msg, chat, target)
    msg = msg or "Default Msg";
    chat = chat or "say";
    if type(tonumber(chat)) == "number" then
        chat = tonumber(chat);
        local id, name = GetChannelName(chat);
        if id > 0 then
            SendChatMessage(msg, "CHANNEL", nil, id);
        end
        return;
    end
    if GetChannelName(chat) > 0 then
        local id, name = GetChannelName(chat);
        SendChatMessage(msg, "CHANNEL", nil, id);
        return;
    end
    chat = string.lower(chat);
    if chat == "auto" then
        if GetNumRaidMembers() > 0 then 
            chat = "raid";
        elseif GetNumPartyMembers() > 0 then 
            chat = "party"; 
        else 
            chat = "say"; 
        end
    end
    if chat == "whisper" then
        local unit = string.match(target, "^%*(.+)%*$");
        if unit then
            target = UnitName(unit);
        end
        SendChatMessage(msg, chat, nil, target);
    elseif chat == "emote" then
        DoEmote(msg);
    else
        SendChatMessage(msg, chat);
    end
end

function Notifications:Timer(msg, duration, setting, group, anchor)
    msg = msg or "Default Msg";
    duration = duration or 5;
    group = group or "Notifications";
    anchor = anchor or "Notifications Anchor";
    local timer = {name = msg, duration = duration, time = GetTime()};
    TimerLib:NewTimer(timer, group, self, setting, nil, nil, anchor, 10, nil);
end

local defaultSettings = {
    enabled = false,
    timerSetting = nil,
    groupSetting = "Notifications",
    anchorSetting = "Notifications Anchor",
    events = {},
};
Notifications:AddDefaultSettings(defaultSettings);

function Notifications:Commands()
    local loaded = LoadAddOn("DoTimer_Options");
    if loaded and not AsheylaLib:InSimpleMode() then
        AsheylaLib:Import( "GUILib" ):ShowPanel("DoTimer", "Notifications");
    end
end
Notifications:MakeSlashCmd("/notifications", "/not");

Notifications:AddSettingsUpdateScript(function(self)
    if not self:Get("updatedSettings4.3.1") then
        self:Set("updatedSettings4.3.1", true);
        local settings = self:Get();
        local new = acquireTable();
        for k, v in pairs(settings) do
            if string.find(k, "0x") and string.len(k) > 10 then
                local newK = "0x" .. string.sub(k, -7, -1);
                new[newK] = v;
                settings[k] = nil;
            end
        end
        for k, v in pairs(new) do
            settings[k] = v;
            new[k] = nil;
        end
    end
end);

TimerLib:AddSettingsUpdateScript(function(self)
    if not self:GetUserSet("anchorSettings", "Notifications Anchor") then
        self:Set("anchorSettings", "Notifications Anchor", {});
    end
end);
