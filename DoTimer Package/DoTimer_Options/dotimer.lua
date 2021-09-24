AsheylaLib:Package( "GUILib" );

local DoTimer = AsheylaLib:Import( "DoTimer" );
local TimerLib = AsheylaLib:Import( "TimerLib" );
local CURRENT_ANCHOR, CURRENT_TIMER = "", "";
local ANCHOR_FRAMES = {};
local PROFILE_FRAMES = {};
local WHITELIST_FRAMES = {};

local optionsTable = {
    { -- section 1
        title = "General Options",
        description = "These options control general usage of DoTimer.",
        showBorder = true,
        simple = true,
        { -- column 1
            {
                title = "Enabled",
                type = "checkButton",
                tooltipText = "Enables or disables the addon.",
                setting = "enabled",
                simple = true,
            },
            {
                title = "Max Buff Duration",
                type = "slider",
                tooltipText = "Sets the maximum duration, in minutes, that a buff can have for DoTimer to track it.  Zero means no restriction.",
                minValue = 0, 
                maxValue = 30,
                valueStep = 2,
                setting = "maxBuffDuration",
                simple = true,
            },
            "BREAK",
        },
        { -- column 2
            {
                title = "Announcing",
                type = "checkButton",
                tooltipText = "If unchecked, attempting to announce a timer will result in no action.",
                setting = "isAnnouncing",
                simple = true,
            },
            {
                title = "Announce Msg",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be sent when you announce a timer.  You can use the following replacements:

    %s: Name of the timer
    %d: Time remaining
    %t: Target name
    %l: Target level
    %r: Target raid icon]]
                ,
                setting = "standardAnnounce",
                simple = true,
            },
            "BREAK",
        },
        { -- column 3
            {
                title = "Key Bindings",
                type = "dropDown",
                tooltipText = "Allows you to change the key bindings for various timer-related functions.",
                func = function() DoTimer.kblib:KBDropDown() end,
            },
            {
                title = "Timer Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to standard timers (not Party Buffs or No Target).  This setting will be applied regardless of the anchor the timer is in.",
                func = function()
                    local setting = "standardSetting";
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == DoTimer:Get(setting);
                        info.func = function() 
                            DoTimer:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = DoTimer:Get(setting) == nil;
                    info.func = function() 
                        DoTimer:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
            {
                title = "White List",
                type = "checkButton",
                tooltipText = "If checked, only timers added to the 'Visible Timers' edit box will be shown.",
                setting = "whiteList",
                simple = true,
                scripts = {
                    OnShow = function(self) 
                        local setting;
                        if self.Get then
                            setting = self.Get(self.setting);
                        else
                            setting = self.module:Get(self.setting);
                        end
                        self:SetChecked(setting and true or false); 
                        for frame in pairs(WHITELIST_FRAMES) do
                            frame:Update();
                        end
                    end,
                    OnClick = function(self) 
                        local val = self:GetChecked() and true or false;
                        if self.Set then
                            self.Set(self.setting, val);
                        else
                            self.module:Set(self.setting, val);
                        end
                        if self.toggle then self.toggle:SetChecked(true); end
                        for frame in pairs(WHITELIST_FRAMES) do
                            frame:Update();
                        end
                    end,
                },
            },
        },
    },
    { -- section 2
        title = "Filters",
        description = "With filters, you can control which timers or targets are visible.",
        showBorder = true,
        simple = true,
        { -- column 1
            {
                title = "Filter Ungrouped",
                type = "checkButton",
                tooltipText = "If checked, buffs you cast on people not in your group will be ignored.",
                setting = "filterUngroupedBuffs",
                simple = true,
            },
            {
                title = "Filter Non-Players",
                type = "checkButton",
                tooltipText = "If checked, buffs you cast on things that aren't players will be ignored.",
                setting = "filterNonPlayerBuffs",
                simple = true,
            },
            {
                title = "Filter Self",
                type = "checkButton",
                tooltipText = "If checked, buffs you cast on yourself will be ignored.",
                setting = "filterSelf",
                simple = true,
            },
        },
        { -- column 2
            {
                title = "Show Only Target",
                type = "checkButton",
                tooltipText = "If checked, when you have a target DoTimer will only display timers from it.  If 'Show Only Focus' is also checked, both targets will be shown.",
                setting = "showOnlyTarget",
                simple = true,
            },
            {
                title = "Show Only Focus",
                type = "checkButton",
                tooltipText = "If checked, when you have a focus DoTimer will only display timers from it.  If 'Show Only Target' is also checked, both targets will be shown.",
                setting = "showOnlyFocus",
                simple = true,
            },
            {
                title = "Apply Always",
                type = "checkButton",
                tooltipText = "If checked, the above 'Show Only ...' settings will apply always, instead of just when the units exist.",
                setting = "always",
                simple = true,
            },
        },
        { -- column 3
            {
                title = "Sort Target",
                type = "checkButton",
                tooltipText = "If checked, your current target will be sorted to the first target position.",
                setting = "sortTarget",
                simple = true,
            },
            {
                title = "Sort Focus",
                type = "checkButton",
                tooltipText = "If checked, your current focus will be sorted to the first target position.  If 'Sort Target' is also checked, your focus will be the 2nd position.",
                setting = "sortFocus",
                simple = true,
            },
            {
                title = "Blocked Types",
                type = "dropDownMultiSelector",
                tooltipText = "Allows you to disable timers for different types of spells.",
                values = {"Helpful", "Harmful"};
                setting = "blockedTypes",
                simple = true,
            },
            {
                title = "Blocked Timers",
                type = "editBoxDropDown",
                tooltipText = "Add here the names of timers you do not wish to see onscreen.  The timer name much match exactly (case insensitive) to be blocked.",
                setting = "blocked",
                simple = true,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if self.module:Get("whiteList") then
                                    self:Hide();
                                else
                                    self:Show();
                                    self:SetText(self.title or ""); self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            WHITELIST_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
            {
                title = "Visible Timers",
                type = "editBoxDropDown",
                tooltipText = "Add here the names of timers you wish to see onscreen.  The timer name much match exactly (case insensitive) to be blocked.",
                setting = "visible",
                simple = true,
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if not self.module:Get("whiteList") then
                                    self:Hide();
                                else
                                    self:Show();
                                    self:SetText(self.title or ""); self:SetCursorPosition(0);
                                end
                                self:UpdateSection();
                            end
                            WHITELIST_FRAMES[self] = true;
                        end
                        self:Update();
                    end,
                },
            },
        },
    },
    { -- section 3
        title = "Party Buffs",
        description = "Party Buffs consolidate buffs you cast on the party or raid into a single timer.  The stack number is the number of people it's on, and the time remaining is from the timer that's going to end first.  You can mouse over the timer for info on who you have timers on, and who you don't.",
        showBorder = true,
        simple = true,
        { -- column 1
            {
                title = "Enabled",
                type = "checkButton",
                tooltipText = "Enables or disables Party Buffs from appearing.",
                setting = "usePartyBuffs",
                simple = true,
            },
            {
                title = "Timer Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to Party Buffs timers.",
                func = function()
                    local setting = "pbSetting";
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == DoTimer:Get(setting);
                        info.func = function() 
                            DoTimer:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = DoTimer:Get(setting) == nil;
                    info.func = function() 
                        DoTimer:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
        },
        { -- column 2
            {
                title = "Display Name",
                type = "editBoxString",
                tooltipText = "Sets the text to be displayed as the name of the Party Buffs group.  If you set this to a value another group is also using (in the same anchor), the two groups will merge into one.",
                setting = "pbName",
            },
            {
                title = "Filters",
                type = "editBoxDropDown",
                tooltipText = "Any timer names that match filters in this list will consolidate into Party Buffs timers.  Prefix with a '^' (no quotes) for it to work as an anti-filter; i.e. if the timer name matches it then it won't be made into a party buff timer.",
                setting = "partyBuffs",
                simple = true,
            },
        },
    },
    { -- section 4
        title = "No Target",
        description = "No Target consolidates timers that may appear on many mobs at once (like AOE fears) or no one at all (like totems).",
        showBorder = true,
        simple = true,
        { -- column 1
            {
                title = "Enabled",
                type = "checkButton",
                tooltipText = "Enables or disables No Target from appearing.  If unchecked, DoTimer will treat the debuff like any other of yours on the unit.",
                setting = "useNoTarget",
                simple = true,
            },
            {
                title = "Timer Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to No Target Timers.",
                func = function()
                    local setting = "ntSetting";
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == DoTimer:Get(setting);
                        info.func = function() 
                            DoTimer:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = DoTimer:Get(setting) == nil;
                    info.func = function() 
                        DoTimer:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
        },
        { -- column 2
            {
                title = "Display Name",
                type = "editBoxString",
                tooltipText = "Sets the text to be displayed as the name of the No Target group.  If you set this to a value another group is also using (in the same anchor), the two groups will merge into one.",
                setting = "ntName",
            },
            {
                title = "Announce Msg",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be send when you announce a timer with no target.  You can use the following replacements:

    %s: Name of the timer
    %d: Time remaining]]
                ,
                setting = "noTargetAnnounce",
                simple = true,
            },
        },
    },
    { -- section 5
        title = "Mouseover Timers",
        description = "Mouseover timers appear next to your cursor when you mouse over a unit in the game world or a unit frame in your interface that isn't your current target.",
        showBorder = true,
        { -- column 1
            { -- row 1
                {
                    title = "Enabled",
                    type = "dropDownSelector",
                    tooltipText = "Sets for whom Mouseover Timers will appear.",
                    values = {"off", "friends", "enemies", "both"};
                    setting = "mouseoverTimers",
                    simple = true,
                },
                {
                    title = "Timer Setting",
                    type = "dropDown",
                    tooltipText = "Select the timer setting you want to apply to Mouseover Timers.",
                    func = function()
                        local setting = "mouseoverSetting";
                        local info;
                        for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = name;
                            info.checked = name == DoTimer:Get(setting);
                            info.func = function() 
                                DoTimer:Set(setting, name);
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info);
                        end
                        
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "None";
                        info.tooltipTitle = "Description";
                        info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                        info.checked = DoTimer:Get(setting) == nil;
                        info.func = function() 
                            DoTimer:Set(setting, nil);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end,
                },
                {
                    title = "Timer Fade Time",
                    type = "slider",
                    tooltipText = "Sets the amount of time, in seconds, it takes for mouseover timers to disappear after the mouse is no longer over the unit.",
                    minValue = 0, 
                    maxValue = 3,
                    valueStep = .25,
                    setting = "mouseoverFadeTime",
                },
            },
        },
    },
    { -- section 6
        title = "Others' Timers",
        description = "You can make timers for buffs and debuffs that aren't your own.  If you type in a name here that also matches a Party Buffs filter, the new timer will appear in Party Buffs.",
        showBorder = true,
        { -- column 1
            { -- row 1
                {
                    title = "Timers",
                    type = "editBoxDropDown",
                    tooltipText = "Add here the names of timers other people made that you want to see.  The timer name much match exactly (case insensitive) to be shown.",
                    setting = "otherTimers",
                },
                {
                    title = "Timer Setting",
                    type = "dropDown",
                    tooltipText = "Select the timer setting you want to apply to others' timers.",
                    func = function()
                        local setting = "otherSetting";
                        local info;
                        for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = name;
                            info.checked = name == DoTimer:Get(setting);
                            info.func = function() 
                                DoTimer:Set(setting, name);
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info);
                        end
                        
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "None";
                        info.tooltipTitle = "Description";
                        info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                        info.checked = DoTimer:Get(setting) == nil;
                        info.func = function() 
                            DoTimer:Set(setting, nil);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end,
                },
            },
        },
    },
    { -- section 2
        title = "Anchor Customization",
        description = "Anchor customization allows you to configure where you want your timers and targets to appear on your screen.",
        padding = 0,
        { -- column 1
            { -- row 1
                {
                    type = "text",
                    text = "Select Anchor to Customize: ",
                },
                {
                    title = "(Select from DropDown Menu)",
                    type = "dropDown",
                    tooltipText = "Select the anchor you want to customize.",
                    func = function(self)
                        local info;
                        for name, settings in alphabetize(TimerLib:Get("anchorSettings")) do
                            if name ~= "Default Anchor" and name ~= "DoTimer Mouseover" and name ~= "Notifications Anchor" then
                                info = UIDropDownMenu_CreateInfo();
                                info.text = name;
                                info.checked = name == CURRENT_ANCHOR;
                                info.func = function() 
                                    CURRENT_ANCHOR = name;
                                    for frame in pairs(ANCHOR_FRAMES) do
                                        frame:Update();
                                    end
                                    CloseDropDownMenus(); 
                                end
                                UIDropDownMenu_AddButton(info);
                            end
                        end
                    end,
                    scripts = {
                        OnShow = function(self)
                            if not self.loaded then
                                self.loaded = true;
                                self.Update = function(self)
                                    getglobal(self:GetName() .. "Text"):SetText(CURRENT_ANCHOR);
                                end
                                ANCHOR_FRAMES[self] = true;
                            end
                            for name, settings in pairs(DoTimer:Get("userAnchors")) do
                                if settings.default then
                                    CURRENT_ANCHOR = name;
                                    for frame in pairs(ANCHOR_FRAMES) do
                                        frame:Update();
                                    end
                                end
                            end
                        end,
                    },
                },
            },
        },
    },
    { -- section 3
        padding = 0,
        showBorder = true,
        { -- column 1
            {
                {
                    title = "Default Anchor",
                    type = "checkButton",
                    tooltipText = "If checked, this anchor will be the default location for all of DoTimer's timers.",
                    module = DoTimer,
                    scripts = {
                        OnShow = function(self)
                            if not self.loaded then
                                self.loaded = true;
                                self.Update = function(self)
                                    self:SetChecked(self.module:Get("userAnchors", CURRENT_ANCHOR, "default"));
                                end
                                ANCHOR_FRAMES[self] = true;
                            end
                            self:Update();
                        end,
                        OnClick = function(self)
                            if self:GetChecked() then
                                for name, settings in pairs(self.module:Get("userAnchors")) do
                                    if name ~= CURRENT_ANCHOR then settings.default = nil; end
                                end
                                self.module:Set("userAnchors", CURRENT_ANCHOR, "default", 1);
                            else
                                self:SetChecked(true);
                                alertUser("You cannot uncheck this setting.  You must check it in another anchor to change it.");
                            end
                        end,
                    },
                },
                {
                    title = "Standard Name",
                    type = "editBoxString",
                    tooltipText = "You can set up timers or targets to use this as their group data instead of their regular data.  Things that use the same group data get put in the same group.",
                    module = DoTimer,
                    scripts = {
                        OnEditFocusGained = function(self) 
                            self:SetText(self.module:Get("userAnchors", CURRENT_ANCHOR, "standardName") or self.module:Get("standardName") or ""); 
                            self:HighlightText(); 
                        end,
                        OnEditFocusLost = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
                        OnShow = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
                        OnEscapePressed = function(self)
                            self:SetText(self.title or ""); self:SetCursorPosition(0);
                            self:ClearFocus();
                        end,
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors", CURRENT_ANCHOR, "standardName", text);
                            self:ClearFocus();
                        end,
                    },
                },
                {
                    title = "Move Here",
                    type = "dropDown",
                    tooltipText = "Select which of the below you want moved into this anchor.",
                    func = function()
                        local list = {"Party Buffs", "No Target", "DoTs", "HoTs", "Others' Timers"};
                        local settings = {"pbLoc", "ntLoc", "dotLoc", "hotLoc", "otherLoc"};
                        local module = DoTimer;
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            for i, name in ipairs(list) do
                                local setting = settings[i];
                                info = UIDropDownMenu_CreateInfo();
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, setting) ~= nil;
                                local pre = info.checked and "|cff00ff00" or "|cff888888";
                                info.text = pre .. name;
                                info.hasArrow = true;
                                info.value = setting;
                                info.arg1 = setting;
                                info.func = function(self, val, _, checked)
                                    checked = not checked;
                                    if checked then
                                        checked = false;
                                    else
                                        checked = nil;
                                    end
                                    for name, settings in pairs(module:Get("userAnchors")) do
                                        settings[val] = nil;
                                    end
                                    module:Set("userAnchors", CURRENT_ANCHOR, val, checked);
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            local val = module:Get("userAnchors", CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE);
                            if val ~= nil then
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Preserve Target Data";
                                info.checked = val == false;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be moved along with the timer.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE, false);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Use Standard Name";
                                info.checked = val == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be replaced with the standard name.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE, true);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            else
                                info = UIDropDownMenu_CreateInfo();
                                local text;
                                for name, settings in pairs(module:Get("userAnchors")) do
                                    if settings[UIDROPDOWNMENU_MENU_VALUE] ~= nil then
                                        text = "Current Anchor: |cff00ffff" .. name;
                                    end
                                end
                                info.text = text or "Currently using default location.";
                                info.notClickable = 1;
                                info.notCheckable = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            end
                        end
                    end,
                },
            },
            { -- row
                {
                    type = "text",
                    small = true,
                    text = "Move these targets here:",
                },
                {
                    title = "<Target Name>",
                    type = "editBoxDropDown",
                    tooltipText = "Type in here the names of targets whose timers you want moved to this anchor.  The target must match exactly what you type (case insensitive) in order to move.  You can type '*target*' or '*focus*' (no quotes) for your current target/focus.",
                    module = DoTimer,
                    scripts = {
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors", CURRENT_ANCHOR, "targets", string.lower(text), {false, false});
                            self:ClearFocus();
                        end,
                    },
                    func = function()
                        local module = DoTimer;
                        local targets = module:Get("userAnchors", CURRENT_ANCHOR, "targets");
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            local needsSpace = false;
                            if targets then
                                for name in alphabetize(targets) do
                                    needsSpace = true;
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = "|cff00ff00" .. name;
                                    info.notCheckable = 1;
                                    info.hasArrow = 1;
                                    info.value = name;
                                    UIDropDownMenu_AddButton(info);
                                end
                            end
                            if not needsSpace then
                                needsSpace = true;
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "No settings for this anchor.";
                                info.notCheckable = 1;
                                info.notClickable = 1;
                                UIDropDownMenu_AddButton(info);
                            end
                            
                            local displayedHeader = false;
                            local uA = module:Get("userAnchors");
                            for anchor, settings in alphabetize(uA) do
                                if anchor ~= CURRENT_ANCHOR then
                                    if settings.targets then
                                        for target in pairs(settings.targets) do
                                            if not displayedHeader then
                                                displayedHeader = true;
                                                if needsSpace then
                                                    info = UIDropDownMenu_CreateInfo();
                                                    info.notCheckable = 1;
                                                    info.text = " ";
                                                    info.isTitle = 1;
                                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                                end
                                                info = UIDropDownMenu_CreateInfo();
                                                info.text = "Other Anchors' Settings:";
                                                info.notCheckable = 1;
                                                info.isTitle = 1;
                                                UIDropDownMenu_AddButton(info);
                                            end
                                            info = UIDropDownMenu_CreateInfo();
                                            info.text = anchor;
                                            info.notCheckable = 1;
                                            info.hasArrow = 1;
                                            info.func = function() 
                                                CURRENT_ANCHOR = anchor;
                                                for frame in pairs(ANCHOR_FRAMES) do
                                                    frame:Update();
                                                end
                                                CloseDropDownMenus(); 
                                            end
                                            info.value = settings.targets;
                                            UIDropDownMenu_AddButton(info);
                                        end
                                    end
                                end
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            if type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Preserve Target Data";
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 1) == false;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be moved along with the timer.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 1, false);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Use Standard Name";
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 1) == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be replaced with the standard name.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 1, true);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.notCheckable = 1;
                                info.text = " ";
                                info.isTitle = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "For Below Timers";
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 2) == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, only the timers specified below on the target specified here will be moved.";
                                info.func = function()
                                    local newVal = not module:Get("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 2);
                                    module:Set("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, 2, newVal);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.notCheckable = 1;
                                info.text = " ";
                                info.isTitle = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "|cffff0000Remove From This List";
                                info.notCheckable = 1;
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "targets", UIDROPDOWNMENU_MENU_VALUE, nil);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            else
                                for target in alphabetize(UIDROPDOWNMENU_MENU_VALUE) do
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = target;
                                    info.notCheckable = 1;
                                    info.notClickable = 1;
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                end
                            end
                        end
                    end,
                },
            },
            { -- row
                {
                    type = "text",
                    small = true,
                    text = "Move these timers here:",
                },
                {
                    title = "<Timer Name>",
                    type = "editBoxDropDown",
                    tooltipText = "Type in here the names of individual timers you want moved to this anchor.  The timer name must match only a fragment (case insensitive) in order to move.",
                    module = DoTimer,
                    scripts = {
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors", CURRENT_ANCHOR, "timers", string.lower(text), false);
                            self:ClearFocus();
                        end,
                    },
                    func = function()
                        local module = DoTimer;
                        local timers = module:Get("userAnchors", CURRENT_ANCHOR, "timers");
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            local needsSpace = false;
                            if timers then
                                for name in alphabetize(timers) do
                                    needsSpace = true;
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = "|cff00ff00" .. name;
                                    info.notCheckable = 1;
                                    info.hasArrow = 1;
                                    info.value = name;
                                    UIDropDownMenu_AddButton(info);
                                end
                            end
                            if not needsSpace then
                                needsSpace = true;
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "No settings for this anchor.";
                                info.notCheckable = 1;
                                info.notClickable = 1;
                                UIDropDownMenu_AddButton(info);
                            end
                            
                            local displayedHeader = false;
                            local uA = module:Get("userAnchors");
                            for anchor, settings in alphabetize(uA) do
                                if anchor ~= CURRENT_ANCHOR then
                                    if settings.timers then
                                        for _ in pairs(settings.timers) do
                                            if not displayedHeader then
                                                displayedHeader = true;
                                                if needsSpace then
                                                    info = UIDropDownMenu_CreateInfo();
                                                    info.notCheckable = 1;
                                                    info.text = " ";
                                                    info.isTitle = 1;
                                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                                end
                                                info = UIDropDownMenu_CreateInfo();
                                                info.text = "Other Anchors' Settings:";
                                                info.notCheckable = 1;
                                                info.isTitle = 1;
                                                UIDropDownMenu_AddButton(info);
                                            end
                                            info = UIDropDownMenu_CreateInfo();
                                            info.text = anchor;
                                            info.notCheckable = 1;
                                            info.hasArrow = 1;
                                            info.func = function() 
                                                CURRENT_ANCHOR = anchor;
                                                for frame in pairs(ANCHOR_FRAMES) do
                                                    frame:Update();
                                                end
                                                CloseDropDownMenus(); 
                                            end
                                            info.value = settings.timers;
                                            UIDropDownMenu_AddButton(info);
                                            break;
                                        end
                                    end
                                end
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            if type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Preserve Target Data";
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == false;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be moved along with the timer.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, false);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Use Standard Name";
                                info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's target data will be replaced with the standard name.";
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, true);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.notCheckable = 1;
                                info.text = " ";
                                info.isTitle = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "|cffff0000Remove From This List";
                                info.notCheckable = 1;
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, nil);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            else
                                for timer in alphabetize(UIDROPDOWNMENU_MENU_VALUE) do
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = timer;
                                    info.notCheckable = 1;
                                    info.notClickable = 1;
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                end
                            end
                        end
                    end,
                },
            },
            { -- row
                {
                    type = "text",
                    small = true,
                    text = "Apply a special setting to these timers:",
                },
                {
                    title = "<Timer Name>",
                    type = "editBoxDropDown",
                    tooltipText = "Type in here the names of timers you want to apply to the timer setting.  The timer name must match only a fragment (case insensitive) to apply.",
                    module = DoTimer,
                    scripts = {
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors", CURRENT_ANCHOR, "timerSettings", string.lower(text), "Default Timer");
                            self:ClearFocus();
                        end,
                    },
                    func = function()
                        local module = DoTimer;
                        local timerSettings = module:Get("userAnchors", CURRENT_ANCHOR, "timerSettings");
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            local needsSpace = false;
                            if timerSettings then
                                for name in alphabetize(timerSettings) do
                                    needsSpace = true;
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = "|cff00ff00" .. name;
                                    info.notCheckable = 1;
                                    info.hasArrow = 1;
                                    info.value = name;
                                    UIDropDownMenu_AddButton(info);
                                end
                            end
                            if not needsSpace then
                                needsSpace = true;
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "No settings for this anchor.";
                                info.notCheckable = 1;
                                info.notClickable = 1;
                                UIDropDownMenu_AddButton(info);
                            end
                            
                            local displayedHeader = false;
                            local uA = module:Get("userAnchors");
                            for anchor, settings in alphabetize(uA) do
                                if anchor ~= CURRENT_ANCHOR then
                                    if settings.timerSettings then
                                        for _ in pairs(settings.timerSettings) do
                                            if not displayedHeader then
                                                displayedHeader = true;
                                                if needsSpace then
                                                    info = UIDropDownMenu_CreateInfo();
                                                    info.notCheckable = 1;
                                                    info.text = " ";
                                                    info.isTitle = 1;
                                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                                end
                                                info = UIDropDownMenu_CreateInfo();
                                                info.text = "Other Anchors' Settings:";
                                                info.notCheckable = 1;
                                                info.isTitle = 1;
                                                UIDropDownMenu_AddButton(info);
                                            end
                                            info = UIDropDownMenu_CreateInfo();
                                            info.text = anchor;
                                            info.notCheckable = 1;
                                            info.hasArrow = 1;
                                            info.func = function() 
                                                CURRENT_ANCHOR = anchor;
                                                for frame in pairs(ANCHOR_FRAMES) do
                                                    frame:Update();
                                                end
                                                CloseDropDownMenus(); 
                                            end
                                            info.value = settings.timerSettings;
                                            UIDropDownMenu_AddButton(info);
                                        end
                                    end
                                end
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            if type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
                                for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = name;
                                    info.checked = name == module:Get("userAnchors", CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE);
                                    info.func = function() 
                                        module:Set("userAnchors", CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE, name);
                                        CloseDropDownMenus(); 
                                    end
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                end
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.notCheckable = 1;
                                info.text = " ";
                                info.isTitle = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "|cffff0000Remove From This List";
                                info.notCheckable = 1;
                                info.func = function()
                                    module:Set("userAnchors", CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE, nil);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            else
                                for timer in alphabetize(UIDROPDOWNMENU_MENU_VALUE) do
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = timer;
                                    info.notCheckable = 1;
                                    info.notClickable = 1;
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                end
                            end
                        end
                    end,
                },
            },
        },
    },
};

local optionsTable2 = {
    { -- section 1
        padding = 0,
        { -- column 1
            {
                title = "Simple Mode",
                type = "checkButton",
                tooltipText = "Uncheck to access the more complex features of DoTimer.",
                scripts = {
                    OnShow = function(self) 
                        local setting = AsheylaLib:InSimpleMode();
                        self:SetChecked(setting and true or false); 
                    end,
                    OnClick = function(self) 
                        AsheylaLib:SetSimpleMode(self:GetChecked() and true or false);
                        GUILib:ReloadGUI();
                    end,
                },
            },
        },
        {
            --[[
            {
                title = "Find Users",
                type = "button",
                tooltipText = "Press this button to find out who in your party or raid uses DoTimer!",
                func = function()
                    AsheylaLib:Import("VersionCommunication"):FindUsers();
                end,
            },--]]
        
        },
    },
    {
        padding = 15,
        {
            {
                type = "text",
                text = "Version Info:",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffNumber|r: |cff00ff00" .. AsheylaLib:ReturnVersion(),
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffReleased|r: |cff00ff00" .. AsheylaLib:ReturnDateUploaded(),
            },
            {
                type = "text",
                text = "Author Info:",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffName|r: |cff00ff00Ross Nichols",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffE-Mail / PayPal|r: |cff00ff00ross456@gmail.com",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffSchool|r: |cff00ff00University of Florida",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffCharacters|r: |cff00ff00Xanido (Shattered Hand Horde), Xanido (Anetheron Alliance)",
            },
            {
                type = "text",
                text = "AddOn Info:",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffDoTimer|r: |cff00ff00/dotimer|r or |cff00ff00/dot",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffCooldowns|r: |cff00ff00/cooldowns|r or |cff00ff00/cd",
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffNotifications|r: |cff00ff00/notifications|r or |cff00ff00/not",
                notSimple = true,
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffPlayerAuras|r: |cff00ff00/playerauras|r or |cff00ff00/pa",
                notSimple = true,
            },
            {
                type = "text",
                small = true,
                text = "   |cffffffffTimerLib|r: |cff00ff00/timerlib|r or |cff00ff00/tl",
                notSimple = true,
            },
            {
                type = "text",
                small = true,
                text = "      Type |cff00ff00/timerlib anchor|r or |cff00ff00/timerlib a|r to open\n      to Anchors.  Else, it will open to Timers.",
                notSimple = true,
            },
        },
    },
    { -- section 4
        title = "Profiles",
        description = "With profiles, you can easily switch between different configurations of DoTimer's modules.",
        showBorder = true,
        { -- column 1
            { -- row
                {
                    title = "Create New",
                    type = "editBoxString",
                    tooltipText = "Type in here the name you wish to give your new profile.",
                    scripts = {
                        OnEditFocusGained = function(self) 
                            self:SetText(""); 
                            self:HighlightText(); 
                        end,
                        OnEditFocusLost = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
                        OnShow = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
                        OnEscapePressed = function(self)
                            self:SetText(self.title or ""); self:SetCursorPosition(0);
                            self:ClearFocus();
                        end,
                        OnEnterPressed = function(self) 
                            local name = self:GetText();
                            if AsheylaLib_Settings[name] then
                                AsheylaLib:AlertUser("You cannot use that name.  Try again!");
                            elseif name ~= "" then
                                AsheylaLib:SetActiveProfile(name);
                                for frame in pairs(PROFILE_FRAMES) do
                                    frame:Update();
                                end
                            end
                            self:ClearFocus();
                        end,
                    },
                },
                {
                    type = "text",
                    small = true,
                    text = "Manage:",
                },
                {
                    title = "(DropDown Menu)",
                    type = "dropDown",
                    tooltipText = "Select the profile you want to be active, or delete a non-active profile.",
                    func = function(self)
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            for name, vals in alphabetize(AsheylaLib_Settings) do
                                if type(vals) == "table" and name ~= AsheylaLib:GetActiveProfile() then
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = name;
                                    info.hasArrow = 1;
                                    info.value = name;
                                    UIDropDownMenu_AddButton(info);
                                end
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            local name = UIDROPDOWNMENU_MENU_VALUE;
                            info = UIDropDownMenu_CreateInfo();
                            info.text = "|cff00ff00Set As Active";
                            info.notCheckable = 1;
                            info.func = function() 
                                AsheylaLib:SetActiveProfile(name);
                                for frame in pairs(PROFILE_FRAMES) do
                                    frame:Update();
                                end
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            
                            info = UIDropDownMenu_CreateInfo();
                            info.notCheckable = 1;
                            info.text = " ";
                            info.isTitle = 1;
                            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            
                            info = UIDropDownMenu_CreateInfo();
                            info.text = "|cff00ffffCopy Settings";
                            info.notCheckable = true;
                            info.func = function()
                                AsheylaLib:CopyFromProfile(name);
                                CloseDropDownMenus();
                            end
                            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            
                            if name ~= "Default" then
                                info = UIDropDownMenu_CreateInfo();
                                info.notCheckable = 1;
                                info.text = " ";
                                info.isTitle = 1;
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "|cffff0000Delete";
                                info.notCheckable = 1;
                                info.func = function() 
                                    AsheylaLib_Settings[name] = nil;
                                    CloseDropDownMenus(); 
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            end
                        end
                    end,
                    scripts = {
                        OnShow = function(self)
                            if not self.loaded then
                                self.loaded = true;
                                PROFILE_FRAMES[self] = 1;
                                self.Update = function(self)
                                    getglobal(self:GetName() .. "Text"):SetText(AsheylaLib:GetActiveProfile());
                                end
                            end
                            self:Update();
                        end,
                    },
                },
            },
            {
                title = "Make this the default profile for this character.",
                type = "checkButton",
                tooltipText = "If checked, this profile will be set to active when you log in on this character.  If none are checked, 'Default' will be loaded.",
                scripts = {
                    OnShow = function(self) 
                        if not self.loaded then
                            self.loaded = true;
                            PROFILE_FRAMES[self] = 1;
                            self.Update = function(self)
                                local id = UnitName("player") .. "-" .. GetRealmName();
                                self:SetChecked(AsheylaLib_Settings[AsheylaLib:GetActiveProfile()][id] and true or false);
                            end
                        end
                        self:Update();
                    end,
                    OnClick = function(self) 
                        local val = self:GetChecked() and true or nil;
                        local id = UnitName("player") .. "-" .. GetRealmName();
                        if val then
                            for name, settings in pairs(AsheylaLib_Settings) do
                                if type(settings) == "table" then settings[id] = nil; end
                            end
                        end
                        AsheylaLib_Settings[AsheylaLib:GetActiveProfile()][id] = val;
                    end,
                },
            },
        },
    },
};

local function defaultFunc()
    AsheylaLib:ClearAllSettings();
end

local function createDGUI()
    GUILib:SetGUIPanel("DoTimer", "main", DoTimer, optionsTable2, {allSimple = true, default = defaultFunc});
    GUILib:SetGUIPanel("DoTimer", "DoTimer", DoTimer, optionsTable);
end
createDGUI();
GUILib:AddGUICreationScript(createDGUI);
