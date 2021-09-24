AsheylaLib:Package( "GUILib" );

local Notifications = AsheylaLib:Import( "Notifications" );
local TimerLib = AsheylaLib:Import( "TimerLib" );
local CURRENT_STATE, CURRENT_EVENT, IS_STANDARD, MATCHING, SENDING, CURRENT_TABLE, CURRENT_SUPERTABLE = "none", "", true, "all", "always", {}, {};
local STATE_FRAMES, MATCH_FRAMES, TYPE_FRAMES, RANDOM_FRAMES, CHAT_FRAMES = {}, {}, {}, {}, {};
local CREATE_BUTTON, DONE_BUTTON;

local STANDARD_EVENTS = {
    ["Player"] = {
        ["Begin Casting"] = "Sent when you begin casting a spell.  \n%1: Spell Name; %2: Spell's Target",
        ["Finish Casting"] = "Sent when you finish casting a spell.  \n%1: Spell Name; %2: Spell's Target",
        ["Item Usage"] = "Sent when you use an item.  \n%1: Item Name; %2: Item Target (if applicable)",
        ["Spell Damage"] = "Sent when a spell or ability does damage.  \n%1: Spell Name; %2: Target; %3: Amount",
        ["Spell Crit"] = "Sent when a spell or ability crits.  \n%1: Spell Name; %2: Target; %3: Amount",
        ["Heal"] = "Sent when you heal someone.  \n%1: Spell Name; %2: Target; %3: Amount",
        ["Heal Crit"] = "Sent when you crit heal someone.  \n%1: Spell Name; %2: Target; %3: Amount",
        ["Spell Failed"] = "Sent when your spellcast fails.  \n%1: Spell Name; %2: Reason",
        ["Buff Gain"] = "Sent when you gain a buff.  \n%1: Buff Name",
        ["Debuff Gain"] = "Sent when you gain a debuff.  \n%1: Debuff Name",
        ["Buff Fade"] = "Sent when a buff fades from you.  \n%1: Buff Name",
        ["Debuff Fade"] = "Sent when a debuff fades from you.  \n%1: Debuff Name",
        ["Spell Active"] = "Sent when a spell or ability becomes available for use.  \n%1: Spell Name",
    },
    ["Timers"] = {
        ["DoTimer Begin Timer"] = "Sent when a DoTimer timer is made.  \n%1: Timer Name; %2: Target",
        ["DoTimer Break Early"] = "Sent when a DoTimer timer breaks early.  \n%1: Timer Name; %2: Target",
        ["DoTimer End Timer"] = "Sent when a DoTimer timer ends.  \n%1: Timer Name; %2: Target",
        ["Cooldowns Begin Timer"] = "Sent when a Cooldowns timer begins.  \n%1: Timer Name",
        ["Cooldowns End Timer"] = "Sent when a Cooldowns timer ends.  \n%1: Timer Name",
    },
    ["Others"] = {
        ["Grouped Buff Gain"] = "Sent when someone you're grouped with gains a buff.  \n%1: Aura name; %2: Unit Name",
        ["Grouped Buff Fade"] = "Sent when someone you're grouped with loses a buff.  \n%1: Aura name; %2: Unit Name",
        ["Grouped Debuff Gain"] = "Sent when someone you're grouped with gains a debuff.  \n%1: Aura name; %2: Unit Name",
        ["Grouped Debuff Fade"] = "Sent when someone you're grouped with loses a debuff.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Buff Gain"] = "Sent when an enemy gains a buff.  \nDoesn't fire if it's your target.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Debuff Gain"] = "Sent when an enemy gains a debuff.  \nDoesn't fire if it's your target.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Buff Fade"] = "Sent when an enemy loses a buff.  \nDoesn't fire if it's your target.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Debuff Fade"] = "Sent when an enemy loses a debuff.  \nDoesn't fire if it's your target.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Target Buff Gain"] = "Sent when your enemy target gains a buff.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Target Debuff Gain"] = "Sent when your enemy target gains a debuff.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Target Buff Fade"] = "Sent when your enemy target loses a buff.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Target Debuff Fade"] = "Sent when your enemy target loses a debuff.  \n%1: Aura name; %2: Unit Name",
        ["Enemy Begin Casting"] = "Sent when an enemy begins casting a spell.  \nDoesn't fire if it's your target.  \n%1: Spell Name; %2: Unit Name",
        ["Enemy Target Begin Casting"] = "Sent when your enemy target begins casting a spell.  \n%1: Spell Name; %2: Unit Name",
        ["Enemy Player Begin Casting"] = "Sent when an enemy player begins casting a spell.  \nDoesn't fire if it's your target.  Fires in addition to Enemy Begin Casting.  \n%1: Spell Name; %2: Unit Name",
        ["Enemy Mob Begin Casting"] = "Sent when an enemy mob begins casting a spell.  \nDoesn't fire if it's your target.  Fires in addition to Enemy Begin Casting.  \n%1: Spell Name; %2: Unit Name",
    },
};
local OTHER_EVENTS = {
    ["Aggro Gain"] = "Sent when your current target switches aggro from someone else to you.",
    ["Aggro Loss"] = "Sent when your current target switches aggro from you to someone else.",
    ["DoTimer Time Remaining"] = "Sent every second for each of your DoTimer timers.  \n%1: Timer Name; %2: Time Remaining; %3: Target Name",
    ["Cooldowns Time Remaining"] = "Sent every second for each of your Cooldowns timers.  \n%1: Timer Name; %2: Time Remaining",
    ["PlayerAuras Time Remaining"] = "Sent every second for each of your PlayerAuras timers.  \n%1: \n%1: Timer Name; %2: Time Remaining",
    ["Combat Log"] = "Sent when your combat log gets a new entry.  \nYour match string determines the arguments.",
    ["Chat Log"] = "Sent when your chat log gets a new entry.  \nYour match string determines the arguments.",
    ["Health"] = "Sent when your health changes.  \n%1: Current Health",
    ["Target Health"] = "Sent when your target's health changes.  \n%1: Current Health",
    ["Mana"] = "Sent when your mana/rage/energy changes.  \n%1: Current Mana",
    ["Buff Missing"] = "Sent when you don't have specified buffs.  \nThey are checked every 30 seconds.  \n%1: Buff Name",
    ["Item Cooldown Up"] = "Sent when specified items aren't on cooldown.  \nThey are checked every 30 seconds.  \n%1: Item Name",
    ["Spell Cooldown Up"] = "Sent when specified items aren't on cooldown.  \nThey are checked every 30 seconds.  \n%1: Spell Name",
};

local NOTIFICATIONS_TYPES = {
    ["text"] = "Output text to your chat log.",
    ["alert"] = "Create an alert message in the middle of the screen.",
    ["sct"] = "Send a message through SCT, MikSBT, or Blizzard Floating Combat Text (BFCT must be enabled)",
    ["chat"] = "Send a chat message.",
    ["flash"] = "Make the screen flash.",
    ["timer"] = "Create a timer.",
    ["sound"] = "Play a sound.",
};

local chat_types = {
    "say",
    "party",
    "raid",
    "auto",
    "whisper",
    "raid_warning",
    "emote",
};

local function insertBlank(level)
    level = level or UIDROPDOWNMENU_MENU_LEVEL;
    local info = UIDropDownMenu_CreateInfo();
    info.notCheckable = 1;
    info.text = " ";
    info.isTitle = 1;
    UIDropDownMenu_AddButton(info, level);
end

local function scanTablesForEmpty()
    local self = Notifications;
    local hasEvents = false;
    for event, matches in pairs(self:GetEvent()) do
        hasEvents = true;
        local IS_STANDARD = not OTHER_EVENTS[event];
        local hasSubCats = false;
        if IS_STANDARD then
            for _, matching in ipairs({"all", "partial", "exact"}) do
                if matches[matching] then
                    hasSubCats = true;
                    if matching == "all" then
                        local m = matches[matching];
                        local hasSending = false;
                        for _, sending in ipairs({"always", "random"}) do
                            if m[sending] then
                                hasSending = true;
                                if #m[sending] == 0 then
                                    m[sending] = nil;
                                    scanTablesForEmpty();
                                end
                            end
                        end
                        if not hasSending then
                            matches[matching] = nil;
                            scanTablesForEmpty();
                        end
                    else
                        if #matches[matching] == 0 then
                            matches[matching] = nil;
                            scanTablesForEmpty();
                        else
                            for i, m in ipairs(matches[matching]) do
                                local hasSending = false;
                                for _, sending in ipairs({"always", "random"}) do
                                    if m[sending] then
                                        hasSending = true;
                                        if #m[sending] == 0 then
                                            m[sending] = nil;
                                            scanTablesForEmpty();
                                        end
                                    end
                                end
                                if not hasSending then
                                    table.remove(matches[matching], i);
                                    scanTablesForEmpty();
                                end
                            end
                        end
                    end
                end
            end
        else
            if #matches > 0 then
                hasSubCats = true;
                for i, m in ipairs(matches) do
                    local hasSending = false;
                    for _, sending in ipairs({"always", "random"}) do
                        if m[sending] then
                            hasSending = true;
                            if #m[sending] == 0 then
                                m[sending] = nil;
                                scanTablesForEmpty();
                            end
                        end
                    end
                    if not hasSending then
                        table.remove(matches, i);
                        scanTablesForEmpty();
                    end
                end
            end
        end
        if not hasSubCats then
            self:SetEvent(event, nil);
            scanTablesForEmpty();
        end
    end
    
    if not hasEvents then
        self:SetEvent(nil);
    end
end

local function dropDownCreate()
    CURRENT_STATE = "none";
    for frame in pairs(STATE_FRAMES) do
        frame:Update();
    end
    local info;
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        for name, events in alphabetize(STANDARD_EVENTS) do
            info = UIDropDownMenu_CreateInfo();
            info.text = name;
            info.hasArrow = true;
            info.value = events;
            info.notCheckable = true;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        info = UIDropDownMenu_CreateInfo();
        info.text = "Misc";
        info.hasArrow = true;
        info.value = OTHER_EVENTS;
        info.notCheckable = true;
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
        local events = UIDROPDOWNMENU_MENU_VALUE;
        for name, tooltip in alphabetize(events) do
            info = UIDropDownMenu_CreateInfo();
            info.text = name;
            info.tooltipTitle = "Description";
            info.tooltipText = tooltip;
            info.notCheckable = true;
            info.func = function()
                CURRENT_STATE = "create";
                CURRENT_EVENT = name;
                CURRENT_TABLE = {};
                CURRENT_SUPERTABLE = {};
                IS_STANDARD = (not OTHER_EVENTS[name]);
                MATCHING = "all";
                SENDING = "always";
                for frame in pairs(STATE_FRAMES) do
                    frame:Update();
                end
                CloseDropDownMenus();
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
    end
end

local function findTable(t, e)
    local f;
    for k, v in pairs(t) do
        if v == e then
            return t;
        elseif type(v) == "table" then
            f = f or findTable(v, e);
        end
    end
    return f;
end

local function findSuper(e)
    local t = Notifications:GetEvent();
    return findTable(t, findTable(t, e));
end

local function findNext(t, last, foundLast)
    local nextEvent;
    if t.type then
        -- it's an event!
        if last == nil or foundLast then
            foundLast = true;
            nextEvent = t;
        elseif t == last then
            foundLast = true;
        end
    else
        for _, v in pairs(t) do
            if type(v) == "table" then
                foundLast, nextEvent = findNext(v, last, foundLast);
                if nextEvent then 
                    break;
                end
            end
        end
    end
    
    return foundLast, nextEvent;
end

local function findEvents(t, last)
    local found, nextEvent = findNext(t, last);
    if found then
        return nextEvent;
    end
end

local function allEvents(t)
    return findEvents, t, nil;
end

local function dropDownManage()
    local info;
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        for event, subTable in pairs(Notifications:GetEvent()) do
            info = UIDropDownMenu_CreateInfo();
            info.text = event;
            info.notCheckable = true;
            info.hasArrow = true;
            info.value = event;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        insertBlank();
        info = UIDropDownMenu_CreateInfo();
        info.text = "|cffff0000Delete All";
        info.notCheckable = 1;
        info.func = function()
            Notifications:SetEvent(nil);
            CloseDropDownMenus();
        end
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
        local event = UIDROPDOWNMENU_MENU_VALUE;
        for e in allEvents(Notifications:GetEvent(event)) do
            info = UIDropDownMenu_CreateInfo();
            info.text = e.name;
            info.notCheckable = true;
            info.hasArrow = true;
            info.value = e;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        insertBlank();
        info = UIDropDownMenu_CreateInfo();
        info.text = "|cffff0000Delete All";
        info.notCheckable = 1;
        info.func = function()
            Notifications:SetEvent(event, nil);
            scanTablesForEmpty();
            CloseDropDownMenus();
        end
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
    elseif UIDROPDOWNMENU_MENU_LEVEL == 3 then
        local entry = UIDROPDOWNMENU_MENU_VALUE;
        local super = findSuper(entry);
        
        if entry.standard then
            info = UIDropDownMenu_CreateInfo();
            info.isTitle = true;
            info.text = "Matching";
            info.notCheckable = true;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
            info = UIDropDownMenu_CreateInfo();
            info.notCheckable = true;
            info.notClickable = true;
            info.text = entry.matching;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        if entry.matching ~= "all" or not entry.standard then
            info = UIDropDownMenu_CreateInfo();
            info.isTitle = true;
            info.text = "Match";
            info.notCheckable = true;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
            info = UIDropDownMenu_CreateInfo();
            info.notCheckable = true;
            info.notClickable = true;
            if super.comp2 then
                info.text = string.format("%s (%s)", super.comp, super.comp2);
            else
                info.text = super.comp;
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        info = UIDropDownMenu_CreateInfo();
        info.isTitle = true;
        info.text = "Sending";
        info.notCheckable = true;
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        info = UIDropDownMenu_CreateInfo();
        info.notCheckable = true;
        info.notClickable = true;
        info.text = entry.sending;
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        
        if entry.sending == "random" then
            info = UIDropDownMenu_CreateInfo();
            info.isTitle = true;
            info.text = "Percent";
            info.notCheckable = true;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
            info = UIDropDownMenu_CreateInfo();
            info.notCheckable = true;
            info.notClickable = true;
            info.text = super.sending;
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        end
        
        info = UIDropDownMenu_CreateInfo();
        info.isTitle = true;
        info.text = "Type";
        info.notCheckable = true;
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        info = UIDropDownMenu_CreateInfo();
        info.notCheckable = true;
        info.notClickable = true;
        info.text = entry.type;
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        
        insertBlank();
        info = UIDropDownMenu_CreateInfo();
        info.text = "|cff4444ffDuplicate";
        info.tooltipTitle = "Description";
        info.tooltipText = "Lets you customize a new notification for this same event.";
        info.notCheckable = true;
        info.func = function()
            CURRENT_TABLE = copyTable(entry);
            CURRENT_STATE = "create";
            CURRENT_EVENT = entry.event;
            IS_STANDARD = entry.standard;
            CURRENT_SUPERTABLE = {comp = super.comp, comp2 = super.comp2};
            SENDING = entry.sending;
            MATCHING = entry.matching;
            for frame in pairs(STATE_FRAMES) do
                frame:Update();
            end
            CloseDropDownMenus();
        end
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        
        info = UIDropDownMenu_CreateInfo();
        info.text = "|cff00ff00Edit";
        info.notCheckable = true;
        info.func = function()
            CURRENT_TABLE = entry;
            CURRENT_STATE = "edit";
            CURRENT_EVENT = entry.event;
            IS_STANDARD = entry.standard;
            CURRENT_SUPERTABLE = super;
            SENDING = entry.sending;
            MATCHING = entry.matching;
            for frame in pairs(STATE_FRAMES) do
                frame:Update();
            end
            CloseDropDownMenus();
        end
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
        
        info = UIDropDownMenu_CreateInfo();
        info.text = "|cffff0000Delete";
        info.notCheckable = 1;
        info.func = function()
            local c, s, u = super, entry.sending, entry;
            for i, e in ipairs(c[s]) do
                if e == u then
                    table.remove(c[s], i);
                    break;
                end
            end
            scanTablesForEmpty();
            CloseDropDownMenus();
        end
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
    end
end

local optionsTable = {
    { -- section 1
        title = "General Options",
        description = "These options control general usage of Notifications.",
        showBorder = true,
        { -- column 1
            { -- row
                {
                    title = "Enabled",
                    type = "checkButton",
                    tooltipText = "Enables or disables the addon.",
                    setting = "enabled",
                },
                {
                    title = "Character Specific Settings",
                    type = "checkButton",
                    tooltipText = "If checked, Notifications will act on a per-character basis instead of globally.",
                    setting = "charSpecific",
                },
            },
        },
    },
    { -- section 2
        title = "Event Management",
        description = "You can create notifications in response to various events in the game.  These notifications can be displayed in a variety of ways.",
        padding = 10,
        { -- column 1
            { -- row
                {
                    title = "New Event",
                    type = "dropDown", 
                    tooltipText = "Select an event from the dropdown to make a new notification.",
                    func = dropDownCreate,
                },
                {
                    title = "Manage Events",
                    type = "dropDown", 
                    tooltipText = "Manage your current notifications.  You can edit or delete them.",
                    func = dropDownManage,
                },
            },
        },
    },
    { -- section 3
        padding = 5,
        { -- column 1
            {
                type = "text",
                text = "(This is the event being managed)",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        --self.text:SetText(...);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    self.text:SetText("Current Event: |cff00ffff" .. CURRENT_EVENT);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                type = "text",
                text = "(This is the event description)",
                small = true,
                scripts = {
                    OnShow = function(self) -- state watcher code
                        --self.text:SetText(...);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if OTHER_EVENTS[CURRENT_EVENT] then
                                        self.text:SetText(OTHER_EVENTS[CURRENT_EVENT]);
                                    else
                                        for _, events in pairs(STANDARD_EVENTS) do
                                            if events[CURRENT_EVENT] then
                                                self.text:SetText(events[CURRENT_EVENT]);
                                            end
                                        end
                                    end
                                    self:SetHeight(self.text:GetStringHeight());
                                    self:SetWidth(self.text:GetStringWidth() + 10);
                                    local h = self.holder;
                                    local oldH = h:GetHeight();
                                    h:SetWidth(self:GetWidth());
                                    h:SetHeight(self:GetHeight());
                                    self:UpdateSection();
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
    },
    {
        subTitle = "Event Creation",
        description = "These options are only available when first creating this notification.  They cannot be edited later.",
        padding = 15,
        showBorder = true,
        {
            {
                title = "Match",
                type = "editBoxString",
                tooltipText = "changed based on state",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_SUPERTABLE.comp = text;
                        for frame in pairs(MATCH_FRAMES) do
                            frame:Update();
                        end
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_SUPERTABLE.comp);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_SUPERTABLE.comp = text;
                        self:HighlightText(0, 0);
                        for frame in pairs(MATCH_FRAMES) do
                            frame:Update();
                        end
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_SUPERTABLE.comp); 
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_STATE == "edit" then
                                    self:Hide();
                                else
                                    local isShowing;
                                    if CURRENT_EVENT == "Health" or CURRENT_EVENT == "Mana" or CURRENT_EVENT == "Target Health" then
                                        self.tooltipText = "Enter here the amount of health or mana you want to trigger this notification.  Prefix your number with a '+' to fire when your health goes over this value, or a '-' for under.  Append a '%' to the number for it to be treated as a percent.";
                                        isShowing = true;
                                    elseif string.find(CURRENT_EVENT, "Time Remaining") then
                                        isShowing = true;
                                        self.tooltipText = "Enter here the name of the timer.  You can enter 'all' for all timers to match.  No partial matches.";
                                    elseif CURRENT_EVENT == "Buff Missing" then
                                        isShowing = true;
                                        self.tooltipText = "Enter here the name of the buff.  It can be a fragment of the full name (case insensitive) if you want to look for types of buffs, like auras.";
                                    elseif string.find(CURRENT_EVENT, "Cooldown Up") then
                                        isShowing = true;
                                        self.tooltipText = "Enter here the name of the spell or item.  It must be the exact name (case insensitive).";
                                    elseif CURRENT_EVENT == "Combat Log" or CURRENT_EVENT == "Chat Log" then
                                        isShowing = true;
                                        self.tooltipText = "Whatever you enter here will be compared to incoming chat or combat log messages.  You can use Lua string parsing regex to create return values.";
                                    else
                                        self.tooltipText = "When the event occurs, the event's 1st argument (%1) is compared to whatever you type here to see if this notification should be sent.  You can allow partial matches to be accepted by the checkbutton to the right.  Type 'all' (no quotes) for all arguments to be accepted.";
                                    end
                                    isShowing = isShowing or IS_STANDARD;
                                    if isShowing then
                                        self:Show();
                                        CURRENT_SUPERTABLE.comp = CURRENT_SUPERTABLE.comp or (IS_STANDARD and "all" or "");
                                        self:SetText(self.title or ""); 
                                        self:SetCursorPosition(0);
                                        for frame in pairs(MATCH_FRAMES) do
                                            frame:Update();
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
        {
            {
                title = "Time",
                type = "editBoxString",
                tooltipText = "This needs to change based on state.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(numToText(self.table[self.index]));
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(numToText(self.table[self.index]));
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        --self:SetText(self.title or ""); 
                        --self:SetCursorPosition(0);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_STATE == "edit" or not string.find(CURRENT_EVENT, "Time Remaining") then
                                    self:Hide();
                                else
                                    self.table = CURRENT_SUPERTABLE;
                                    self.index = "comp2";
                                    if not CURRENT_SUPERTABLE.comp2 then
                                        CURRENT_SUPERTABLE.comp2 = 5;
                                    end
                                    self.tooltipText = "Enter here the amount of time remaining you want for this notification to fire.  Type it in a form like '5m 2s'.  Whole seconds only.";
                                    self.title = "Time Remaining";
                                    self:Show();
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
        {
            {
                title = "Partial Matches",
                type = "checkButton",
                tooltipText = "If checked, the match you typed into the 'Match' edit box will be used as a partial match instead of an exact match.",
                scripts = {
                    OnShow = function(self) 
                        --local setting = self.Get and self.Get(self.setting) or self.module:Get(self.setting);
                        --self:SetChecked(setting and true or false); 
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_STATE == "edit" or not IS_STANDARD then
                                    self:SetChecked(false);
                                    self:Hide();
                                else
                                    if CURRENT_SUPERTABLE.comp == "all" then
                                        MATCHING = "all";
                                        self:Hide();
                                    else
                                        self:Show();
                                        if self:GetChecked() then
                                            MATCHING = "partial";
                                        else
                                            MATCHING = "exact";
                                        end
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            MATCH_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self) 
                        self:Update();
                    end,
                },
            },
        },
    },
    { 
        subTitle = "Basic Options",
        description = "Some basic options for your Notification.",
        showBorder = true,
        {
            {
                title = "Notification Name",
                type = "editBoxString",
                tooltipText = "Type here the name you want associated with this notification.  You will use this name when managing this notification later.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.name = text;
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_TABLE.name);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.name = text;
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_TABLE.name); 
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if not CURRENT_TABLE.name then
                                        CURRENT_TABLE.name = "Default Name";
                                    end
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Type",
                type = "dropDown",
                tooltipText = "Select the type of notification you want this to be.",
                func = function()
                    local info;
                    local curr = CURRENT_TABLE.type;
                    for name, tooltip in alphabetize(NOTIFICATIONS_TYPES) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.tooltipTitle = "Description";
                        info.tooltipText = tooltip;
                        info.checked = (name == curr);
                        info.func = function()
                            CURRENT_TABLE.type = name;
                            for frame in pairs(TYPE_FRAMES) do
                                frame:Update();
                            end
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if not CURRENT_TABLE.type then
                                        CURRENT_TABLE.type = "text";
                                        for frame in pairs(TYPE_FRAMES) do
                                            frame:Update();
                                        end
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },--]]
        },
        {
            {
                title = "Time",
                type = "editBoxString",
                tooltipText = "This needs to change based on state.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(numToText(self.table[self.index]));
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(numToText(self.table[self.index]));
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        --self:SetText(self.title or ""); 
                        --self:SetCursorPosition(0);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self.table = CURRENT_TABLE;
                                    self.index = "delay";
                                    if not CURRENT_TABLE.delay then
                                        CURRENT_TABLE.delay = 0;
                                    end
                                    self.tooltipText = "Enter here how long of a delay you want before this notification fires.  Type it in a form like '5m 2s'.  Whole seconds only.";
                                    self.title = "Delay";
                                    self:Show();
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
        {
            {
                title = "Random",
                type = "checkButton",
                tooltipText = "If checked, this notification will be sent randomly instead of all the time.  Notifications decides based on the 'Random Chance' setting whether or not to send exactly one of the notifications you set to 'Random' for this event.",
                scripts = {
                    OnShow = function(self) 
                        --local setting = self.Get and self.Get(self.setting) or self.module:Get(self.setting);
                        --self:SetChecked(setting and true or false); 
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self, clicked)
                                if CURRENT_STATE == "none" then
                                    self:SetChecked(false);
                                    self:Hide();
                                else
                                    self:Show();
                                    if self:GetChecked() then
                                        SENDING = "random";
                                    else
                                        SENDING = "always";
                                    end
                                    if CURRENT_STATE == "edit" then
                                        if CURRENT_SUPERTABLE.always then
                                            for i, t in ipairs(CURRENT_SUPERTABLE.always) do
                                                if t == CURRENT_TABLE then
                                                    table.remove(CURRENT_SUPERTABLE.always, i);
                                                    break;
                                                end
                                            end
                                        end
                                        if CURRENT_SUPERTABLE.random then
                                            for i, t in ipairs(CURRENT_SUPERTABLE.random) do
                                                if t == CURRENT_TABLE then
                                                    table.remove(CURRENT_SUPERTABLE.random, i);
                                                    break;
                                                end
                                            end
                                        end
                                        if not CURRENT_SUPERTABLE[SENDING] then
                                            CURRENT_SUPERTABLE[SENDING] = {};
                                        end
                                        table.insert(CURRENT_SUPERTABLE[SENDING], CURRENT_TABLE);
                                    end
                                    if clicked then
                                        for frame in pairs(RANDOM_FRAMES) do
                                            frame:Update();
                                        end
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self) 
                        self:Update(true);
                    end,
                },
            },--]]
            {
                title = "Random Chance",
                type = "slider",
                tooltipText = "Select here the percent chance that one of your random notifications will be sent.",
                minValue = 0,
                maxValue = 100,
                valueStep = 1,
                scripts = {
                    OnShow = function(self) 
                        --self.real = false;
                        --self:SetValue((self.Get and (self.Get(self.setting) or 0)) or self.module:Get(self.setting)); 
                        --self.real = true; 
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or SENDING ~= "random" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if not CURRENT_SUPERTABLE.rand then
                                        CURRENT_SUPERTABLE.rand = 100;
                                    end
                                    self:SetValue(CURRENT_SUPERTABLE.rand);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            RANDOM_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnValueChanged = function(self)
                        local value = self:GetValue();
                        getglobal(self:GetName() .. "Value"):SetText(value);
                        CURRENT_SUPERTABLE.rand = value;
                    end,
                },
            },
        },--]]
    },
    ---[[
    { -- section 4
        subTitle = "Customization Options",
        description = "Your notification can be customized in different ways depending on the type you selected above.  Please look through each of the below options and read their tooltips so you can make it do what you want.",
        showBorder = true;
        padding = 15,
        { -- column 1
            {
                title = "Message",
                type = "editBoxString",
                tooltipText = "Type here the message you want for this notification.  You can use %1, %2, etc. from the arguments from the event.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.msg = text;
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_TABLE.msg);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.msg = text;
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_TABLE.msg);
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    local type = CURRENT_TABLE.type;
                                    if (type ~= "sound" and type ~= "flash") then
                                        self:Show();
                                        self:SetText(self.title or ""); 
                                        self:SetCursorPosition(0);
                                        if not CURRENT_TABLE.msg then
                                            CURRENT_TABLE.msg = "Default Msg!";
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Group Name",
                type = "editBoxString",
                tooltipText = "Sets the text to be displayed as the group name for this timer.  Timers with the same group name in the same anchor will be put in the same group.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.group = text;
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_TABLE.group);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.group = text;
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_TABLE.group);
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    local type = CURRENT_TABLE.type;
                                    if (type == "timer") then
                                        self:Show();
                                        self:SetText(self.title or ""); 
                                        self:SetCursorPosition(0);
                                        if not CURRENT_TABLE.group then
                                            CURRENT_TABLE.group = "Notifications";
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Offset",
                type = "slider",
                minValue = 20,
                maxValue = 200,
                valueStep = 10,
                tooltipText = "Sets how high above the center of the screen the alert will be shown.",
                scripts = {
                    OnValueChanged = function(self)
                        local val = self:GetValue();
                        getglobal(self:GetName() .. "Value"):SetText(val);
                        CURRENT_TABLE.height = val;
                    end,
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    local type = CURRENT_TABLE.type;
                                    if (type == "alert") then
                                        self:Show();
                                        if not CURRENT_TABLE.height then
                                            CURRENT_TABLE.height = 80;
                                        end
                                        self:SetValue(CURRENT_TABLE.height);
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
        { -- column 2
            {
                title = "Color",
                type = "colorSelect",
                tooltipText = "Select the color for your notification.",
                scripts = {
                    OnClick = function(self)
                        ColorPickerFrame.func = function() 
                            local r, g, b = ColorPickerFrame:GetColorRGB();
                            getglobal(self:GetName() .. "NormalTexture"):SetVertexColor(r, g, b);
                            CURRENT_TABLE.color = {r = r, g = g, b = b};
                        end
                        local r, g, b = getglobal(self:GetName().."NormalTexture"):GetVertexColor();
                        ColorPickerFrame:SetColorRGB(r, g, b);
                        ColorPickerFrame.previousValues = {r = r, g = g, b = b};
                        ColorPickerFrame.cancelFunc = function(prev)
                            getglobal(self:GetName().."NormalTexture"):SetVertexColor(prev.r, prev.g, prev.b);
                        end
                        ShowUIPanel(ColorPickerFrame);
                    end,
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    local type = CURRENT_TABLE.type;
                                    if (type == "alert" or type == "text" or type == "sct" or type == "flash") then
                                        self:Show();
                                        if not CURRENT_TABLE.color then
                                            if CURRENT_TABLE.colorName then
                                                local flash_colors = {
                                                    ["Blue"] = {r = 0, g =  0, b = 1},
                                                    ["Green"] = {r = 0, g = 1, b = 0},
                                                    ["Orange"] = {r = 1, g = .5, b = .2}, -- why did i pick this instead of 0, 1, 1?  it will forever be a mystery
                                                    ["Purple"] = {r = 1, g = 0, b = 1},
                                                    ["Red"] = {r = 1, g = 0, b = 0},
                                                    ["Yellow"] = {r = 1, g = 1, b = 0},
                                                };
                                                CURRENT_TABLE.color = flash_colors[CURRENT_TABLE.colorName];
                                                CURRENT_TABLE.colorName = nil;
                                            else
                                                CURRENT_TABLE.color = {r = 1, g = 1, b = 1};
                                            end
                                        end
                                        
                                        local color = CURRENT_TABLE.color;
                                        getglobal(self:GetName() .. "NormalTexture"):SetVertexColor(color.r, color.g, color.b);
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Chat",
                type = "dropDown",
                tooltipText = "Select the chat channel for your message.  'Auto' means raid or party, whichever applies.",
                func = function()
                    local info;
                    local curr = CURRENT_TABLE.chatType;
                    for _, name in ipairs(chat_types) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = (name == curr);
                        info.func = function()
                            CURRENT_TABLE.chatType = name;
                            for frame in pairs(CHAT_FRAMES) do
                                frame:Update();
                            end
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "chat" then
                                        self:Show();
                                        if not CURRENT_TABLE.chatType then
                                            CURRENT_TABLE.chatType = "auto";
                                        end
                                        for frame in pairs(CHAT_FRAMES) do
                                            frame:Update();
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Target",
                type = "editBoxString",
                tooltipText = "Type here the name of the target for your chat message.  You can use %1, %2, etc. from the arguments from the event.  If you put stars around what you type in, e.g. '*target*', it will be treated as a unit token.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.target = text;
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_TABLE.target);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.target = text;
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_TABLE.target);
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        --self:SetText(self.title or ""); 
                        --self:SetCursorPosition(0);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_TABLE.type ~= "chat" or CURRENT_TABLE.chatType ~= "whisper" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if not CURRENT_TABLE.target then
                                        CURRENT_TABLE.target = "%2";
                                    end
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                            CHAT_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "File",
                type = "editBoxString",
                tooltipText = "Type here the name of the sound file you want played.  This file should be found in DoTimer\\Core\\Files.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.file = text;
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(CURRENT_TABLE.file);
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        CURRENT_TABLE.file = text;
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(CURRENT_TABLE.file);
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        --self:SetText(self.title or ""); 
                        --self:SetCursorPosition(0);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_TABLE.type ~= "sound" then
                                    self:Hide();
                                else
                                    self:Show();
                                    if not CURRENT_TABLE.file then
                                        CURRENT_TABLE.file = "alert.wav";
                                    end
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Time",
                type = "editBoxString",
                tooltipText = "This needs to change based on state.",
                scripts = {
                    OnChar = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                    end,
                    OnEditFocusGained = function(self) 
                        self:SetText(numToText(self.table[self.index]));
                        self:HighlightText(); 
                    end,
                    OnEditFocusLost = function(self)
                        local text = self:GetText();
                        self.table[self.index] = textToNum(text);
                        self:HighlightText(0, 0);
                    end,
                    OnEscapePressed = function(self)
                        self:SetText(numToText(self.table[self.index]));
                        self:SetCursorPosition(0);
                        self:ClearFocus();
                    end,
                    OnEnterPressed = function(self) 
                        self:ClearFocus();
                    end,
                    OnShow = function(self) -- state watcher code
                        --self:SetText(self.title or ""); 
                        --self:SetCursorPosition(0);
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" or CURRENT_TABLE.type ~= "timer" then
                                    self:Hide();
                                else
                                    self.table = CURRENT_TABLE;
                                    self.index = "duration";
                                    if not CURRENT_TABLE.duration then
                                        CURRENT_TABLE.duration = 5;
                                    end
                                    self.tooltipText = "Enter here how long you want your timer to last.  Type it in a form like '5m 2s'.  Whole seconds only.";
                                    self.title = "Duration";
                                    self:Show();
                                    self:SetText(self.title or ""); 
                                    self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Number of Pulses",
                type = "slider",
                tooltipText = "Select here how many times you want your flash to fade in and out.",
                minValue = 1,
                maxValue = 5,
                valueStep = 1,
                setting = "pulses",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "flash" then
                                        self:Show();
                                        if not CURRENT_TABLE.pulses then
                                            CURRENT_TABLE.pulses = 2;
                                        end
                                        self:SetValue(CURRENT_TABLE.pulses);
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnValueChanged = function(self)
                        local value = self:GetValue();
                        getglobal(self:GetName() .. "Value"):SetText(value);
                        CURRENT_TABLE.pulses = value;
                    end,
                },
            },
        },
        { -- column 3
            {
                title = "Timer Anchor",
                type = "dropDown",
                tooltipText = "Select the anchor you want to send timers to.",
                func = function()
                    local setting = "anchorSetting";
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("anchorSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == CURRENT_TABLE.anchor;
                        info.func = function() 
                            CURRENT_TABLE.anchor = name;
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "timer" then
                                        self:Show();
                                        if not CURRENT_TABLE.anchor then
                                            CURRENT_TABLE.anchor = "Notifications Anchor";
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Timer Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to timers.",
                func = function()
                    local setting = "timerSetting";
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == CURRENT_TABLE.setting;
                        info.func = function() 
                            CURRENT_TABLE.setting = name;
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = CURRENT_TABLE.setting == "None";
                    info.func = function() 
                        CURRENT_TABLE.setting = "None";
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "timer" then
                                        self:Show();
                                        if not CURRENT_TABLE.setting then
                                            CURRENT_TABLE.setting = "None";
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Output Frame",
                type = "dropDownSelector",
                tooltipText = "Select which scrolling text frame you want to output to.",
                setting = "frame",
                values = {"SCT Frame 1", "SCT Frame 2", "SCT Message", "SCT Damage", "MikSBT", "Blizzard FCT"},
                func = function(frame, newVal)
                    CURRENT_TABLE.frame = newVal;
                end,
                get = function()
                    return CURRENT_TABLE.frame;
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "sct" then
                                        self:Show();
                                        if not CURRENT_TABLE.frame then
                                            CURRENT_TABLE.frame = SCT and "SCT Frame 1" or MikSBT and "MikSSBT" or "Blizzard FCT";
                                        end
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Fade In Time",
                type = "slider",
                tooltipText = "Select here the amount of time you want to have the flash spend fading in.",
                minValue = .25,
                maxValue = 2,
                valueStep = .25,
                setting = "fadeInTime",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "flash" then
                                        self:Show();
                                        if not CURRENT_TABLE.fadeInTime then
                                            CURRENT_TABLE.fadeInTime = .5;
                                        end
                                        self:SetValue(CURRENT_TABLE.fadeInTime);
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnValueChanged = function(self)
                        local value = self:GetValue();
                        getglobal(self:GetName() .. "Value"):SetText(value);
                        CURRENT_TABLE.fadeInTime = value;
                    end,
                },
            },
            {
                title = "Fade Out Time",
                type = "slider",
                tooltipText = "Select here the amount of time you want to have the flash spend fading out.",
                minValue = .25,
                maxValue = 2,
                valueStep = .25,
                setting = "fadeOutTime",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_TABLE.type == "flash" then
                                        self:Show();
                                        if not CURRENT_TABLE.fadeOutTime then
                                            CURRENT_TABLE.fadeOutTime = .5;
                                        end
                                        self:SetValue(CURRENT_TABLE.fadeOutTime);
                                    else
                                        self:Hide();
                                    end
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            TYPE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnValueChanged = function(self)
                        local value = self:GetValue();
                        getglobal(self:GetName() .. "Value"):SetText(value);
                        CURRENT_TABLE.fadeOutTime = value;
                    end,
                },
            },
        },
    },--]]
    {
        subTitle = "Filters",
        description = "Control the conditions under which you want your notification to be sent.",
        showBorder = true,
        {
            {
                title = "In Combat",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're in combat.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.inCombat;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.inCombat = checked;
                    end,
                },
            },
            {
                title = "While Solo",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're solo.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.onlySolo;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.onlySolo = checked;
                    end,
                },
            },
            {
                title = "Spec 1",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're using your first talent specialization.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.spec1;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.spec1 = checked;
                    end,
                },
            },
        },
        {
            {
                title = "Out of Combat",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're out of combat.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.outOfCombat;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.outOfCombat = checked;
                    end,
                },
            },
            {
                title = "While Grouped",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're in a group.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.inGroup;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.inGroup = checked;
                    end,
                },
            },
            {
                title = "Spec 2",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're using your second talent specialization.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.spec2;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.spec2 = checked;
                    end,
                },
            },
        },
        {
            {
                title = "While Alive",
                type = "checkButton",
                tooltipText = "If checked, this notification will only be sent while you're alive.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.whileAlive;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.whileAlive = checked;
                    end,
                },
            },
            {
                title = "Not Resting",
                type = "checkButton",
                tooltipText = "If checked, this notification will not fire if you're resting.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.notResting;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.notResting = checked;
                    end,
                },
            },
            {
                title = "Disabled",
                type = "checkButton",
                tooltipText = "If checked, this notification will never fire.",
                scripts = {
                    OnShow = function(self) -- state watcher code
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                    local checked = CURRENT_TABLE.flags and CURRENT_TABLE.flags.disabled;
                                    self:SetChecked(checked);
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                    OnClick = function(self)
                        local checked = self:GetChecked() and true or false;
                        CURRENT_TABLE.flags = CURRENT_TABLE.flags or {};
                        CURRENT_TABLE.flags.disabled = checked;
                    end,
                },
            },
        },
    },
    {
        {
            {
                title = "Create!",
                type = "button",
                tooltipText = "Create this Notification!",
                func = function()
                    local t;
                    local needs_comp2 = string.find(CURRENT_EVENT, "Time Remaining");
                    if IS_STANDARD then
                        t = Notifications:GetEvent(CURRENT_EVENT, MATCHING);
                        if not t then
                            t = {};
                            Notifications:SetEvent(CURRENT_EVENT, MATCHING, t);
                        end
                    else
                        t = Notifications:GetEvent(CURRENT_EVENT);
                        if not t then
                            t = {};
                            Notifications:SetEvent(CURRENT_EVENT, t);
                        end
                    end
                    local realSuper;
                    if MATCHING == "all" and IS_STANDARD then
                        realSuper = t;
                    else
                        for i, entry in ipairs(t) do
                            if string.find(CURRENT_EVENT, "Aggro") or (entry.comp == CURRENT_SUPERTABLE.comp and ((not needs_comp2) or (entry.comp2 == CURRENT_SUPERTABLE.comp2))) then
                                realSuper = entry;
                                break;
                            end
                        end
                    end
                    if not realSuper then
                        realSuper = CURRENT_SUPERTABLE;
                        table.insert(t, CURRENT_SUPERTABLE);
                    end
                    realSuper.rand = SENDING == "random" and CURRENT_SUPERTABLE.rand or realSuper.rand;
                    t = realSuper[SENDING];
                    if not t then
                        t = {};
                        realSuper[SENDING] = t;
                    end
                    table.insert(realSuper[SENDING], CURRENT_TABLE);
                    
                    CURRENT_TABLE.matching = MATCHING;
                    CURRENT_TABLE.sending = SENDING;
                    CURRENT_TABLE.event = CURRENT_EVENT;
                    CURRENT_TABLE.standard = IS_STANDARD;
                    
                    CURRENT_STATE = "none";
                    Notifications:Set("enabled", true);
                    InterfaceOptionsFrame:Hide(); GUILib:ShowPanel("DoTimer", "Notifications");
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE ~= "create" then
                                    self:Hide();
                                else
                                    self:Show();
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            CREATE_BUTTON = self;
                        end
                        self:Update();
                    end,
                },
            },
        },
        {
            {
                title = "Preview",
                type = "button",
                tooltipText = "Shows an example notification for the selected type.",
                func = function()
                    local t = CURRENT_TABLE;
                    local type = t.type;
                    if type == "sound" then
                        Notifications:PlaySound("Interface\\AddOns\\DoTimer\\Core\\Files\\" .. t.file);
                    elseif type == "sct" then
                        Notifications:SCTAlert(t.msg, t.color, t.frame);
                    elseif type == "alert" then
                        Notifications:Alert(t.msg, t.color.r, t.color.g, t.color.b, t.height);
                    elseif type == "text" then
                        Notifications:Text(t.msg, t.color.r, t.color.g, t.color.b);
                    elseif type == "chat" then
                        Notifications:ChatMsg(t.msg, t.chatType, UnitName("player"));
                    elseif type == "timer" then
                        Notifications:Timer(t.msg, t.duration, t.setting, t.group, t.anchor);
                    elseif type == "flash" then
                        Notifications:Flash(t.color.r, t.color.g, t.color.b, t.fadeInTime, t.fadeOutTime, t.pulses);
                    end
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    self:Show();
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
        {
            {
                title = "(change based on state)",
                type = "button",
                tooltipText = "(change based on state)",
                func = function()
                    CURRENT_STATE = "none";
                    for frame in pairs(STATE_FRAMES) do
                        frame:Update();
                    end
                end,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if CURRENT_STATE == "none" then
                                    self:Hide();
                                else
                                    if CURRENT_STATE == "create" then
                                        self.title = "Cancel";
                                        self.tooltipText = "Cancels the creation of a new notification.";
                                    else
                                        self.title = "Done";
                                        self.tooltipText = "Click here when you're done editing.";
                                    end
                                    getglobal(self:GetName() .. "Text"):SetText(self.title);
                                    self:Show();
                                end
                                self:UpdateSection();
                            end
                            STATE_FRAMES[self] = true;
                            DONE_BUTTON = self;
                        end
                        self:Update();
                    end,
                },
            },
        },
    },--]]
};

local okayFunc = function()
    if CURRENT_STATE == "create" and CREATE_BUTTON then
        CREATE_BUTTON:Click();
    elseif CURRENT_STATE == "edit" and DONE_BUTTON then
        DONE_BUTTON:Click();
    end
end

local function createNGUI()
    if not AsheylaLib:InSimpleMode() then
        GUILib:SetGUIPanel("DoTimer", "Notifications", Notifications, optionsTable, {okay = okayFunc, cancel = okayFunc});
    end
end
createNGUI();
GUILib:AddGUICreationScript(createNGUI);
