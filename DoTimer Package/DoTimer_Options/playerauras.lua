AsheylaLib:Package( "GUILib" );

local PlayerAuras = AsheylaLib:Import( "PlayerAuras" );
local TimerLib = AsheylaLib:Import( "TimerLib" );
local CURRENT_UNIT, CURRENT_ANCHOR, CURRENT_MODULE, CURRENT_TIMER = "player", "", "Buffs", "";
local ANCHOR_FRAMES = {};
local WHITELIST_FRAMES = {};

local excludedSettings = {["enabled"] = 1, ["blizzBuffs"] = 1, ["isAnnouncing"] = 1, ["noDuration"] = 1};

local set = function(...)
    if CURRENT_UNIT == "player" or excludedSettings[...] then
        PlayerAuras:Set(...);
    else
        local first = ...;
        first = first .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
        PlayerAuras:Set(first, select(2, ...));
    end
end

local get = function(...)
    if CURRENT_UNIT == "player" or excludedSettings[...] then
        return PlayerAuras:Get(...);
    else
        local first = ...;
        first = first .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
        return PlayerAuras:Get(first, select(2, ...));
    end
end

local optionsTable = {
    { -- section 1
        title = "General Options",
        description = "These options control general usage of PlayerAuras.",
        showBorder = true,
        { -- column 1
            {
                title = "Enabled",
                type = "checkButton",
                tooltipText = "Enables or disables the addon.",
                setting = "enabled",
            },
            {
                title = "Blizzard Buffs",
                type = "checkButton",
                tooltipText = "If checked, Blizzard's default buffs will be shown.",
                setting = "blizzBuffs",
            },
        },
        { -- column 2
            {
                title = "Announcing",
                type = "checkButton",
                tooltipText = "If unchecked, attempting to announce a timer will result in no action.",
                setting = "isAnnouncing",
            },
            {
                title = "No Duration",
                type = "editBoxDropDown",
                tooltipText = "Add here the names of timers you want to be displayed as having no duration.  The timer name much match exactly (case insensitive).",
                setting = "noDuration",
            },
        },
        { -- column 3
            {
                title = "Key Bindings",
                type = "dropDown",
                tooltipText = "Allows you to change the key bindings for various timer-related functions.",
                func = function() PlayerAuras.kblib:KBDropDown() end,
            },
        },
    },
    { -- section 2
        title = "Unit Customization",
        description = "PlayerAuras works for both your and your pet's buffs and debuffs.  You must configure them separately.  All settings below this point are dependent upon the unit you select.",
        padding = 5,
        { -- column 1
            { -- row 1
                {
                    type = "text",
                    text = "Select Unit to Customize: ",
                    color = {r = 0, g = 1, b = 1},
                },
                {
                    title = "player",
                    type = "dropDown",
                    tooltipText = "Select which unit you want to customize.  All below settings are affected by this selection.",
                    func = function(self)
                        local info;
                        for name in alphabetize(PlayerAuras.units) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = name;
                            info.checked = name == CURRENT_UNIT;
                            info.func = function() 
                                CURRENT_UNIT = name;
                                getglobal(self:GetParent():GetName() .. "Text"):SetText(name);
                                GUILib:RefreshCurrentPanel();
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info);
                        end
                    end,
                },
                {
                    title = "Enabled",
                    type = "checkButton",
                    tooltipText = "If checked, timers for this unit will be created.",
                    setting = "showUnit",
                },
            },
        },
    },
    { -- section 2
        subTitle = "Buffs",
        description = "These options control the look and functionality of the buffs on the unit you've selected.",
        showBorder = true,
        padding = 10,
        { -- column 1
            {
                title = "Blocked Timers",
                type = "editBoxDropDown",
                tooltipText = "Add here the names of timers you do not wish to see onscreen.  The timer name much match exactly (case insensitive) to be blocked.",
                setting = "blocked-Buffs",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if self.Get("whiteList-Buffs") then
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
                setting = "visible-Buffs",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if not self.Get("whiteList-Buffs") then
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
                title = "Display Name",
                type = "editBoxString",
                tooltipText = "Sets the text to be displayed as the name of the Buffs group.  If you set this to a value another group is also using (in the same anchor), the two groups will merge into one.  If you set this to '*target*' (no quotes), the timers will act as if they were on your current target.",
                setting = "displayName-Buffs",
            },
            "BREAK",
        },
        {
            {
                title = "Standard Announce",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be sent when you announce a timer.  You can use the following replacements:

    %s: Name of the timer
    %d: Time remaining]]
                ,
                setting = "standardAnnounce-Buffs",
            },
            {
                title = "No Dur. Announce",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be sent when you announce a timer with no duration.  You can use the following replacements:

    %s: Name of the timer]]
                ,
                setting = "noDurationAnnounce-Buffs",
            },
            "BREAK",
        },
        {
            {
                title = "Standard Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to standard timers.",
                func = function()
                    local setting = "standardSetting-Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == PlayerAuras:Get(setting);
                        info.func = function() 
                            PlayerAuras:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = PlayerAuras:Get(setting) == nil;
                    info.func = function() 
                        PlayerAuras:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
            {
                title = "No Dur. Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to timers with no duration.",
                func = function()
                    local setting = "noDurSetting-Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == PlayerAuras:Get(setting);
                        info.func = function() 
                            PlayerAuras:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = PlayerAuras:Get(setting) == nil;
                    info.func = function() 
                        PlayerAuras:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
            {
                title = "White List",
                type = "checkButton",
                tooltipText = "If checked, only buffs added to the 'Visible Timers' edit box to the left will be shown.",
                setting = "whiteList-Buffs",
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
    {
        subTitle = "Debuffs",
        description = "These options control the look and functionality of the debuffs on the unit you've selected.",
        showBorder = true,
        padding = 10,
        { -- column 2
            {
                title = "Blocked Timers",
                type = "editBoxDropDown",
                tooltipText = "Add here the names of timers you do not wish to see onscreen.  The timer name much match exactly (case insensitive) to be blocked.",
                setting = "blocked-Debuffs",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if self.Get("whiteList-Debuffs") then
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
                setting = "visible-Debuffs",
                scripts = {
                    OnShow = function(self)
                        if not self.loaded then
                            self.loaded = true;
                            self.Update = function(self)
                                if not self.Get("whiteList-Debuffs") then
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
                title = "Display Name",
                type = "editBoxString",
                tooltipText = "Sets the text to be displayed as the name of the Debuffs group.  If you set this to a value another group is also using (in the same anchor), the two groups will merge into one.  If you set this to '*target*' (no quotes), the timers will act as if they were on your current target.",
                setting = "displayName-Debuffs",
            },
            "BREAK",
        },
        {
            {
                title = "Standard Announce",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be sent when you announce a timer.  You can use the following replacements:

    %s: Name of the timer
    %d: Time remaining]]
                ,
                setting = "standardAnnounce-Debuffs",
            },
            {
                title = "No Dur. Announce",
                type = "editBoxString",
                tooltipText = [[Sets the message that will be sent when you announce a timer with no duration.  You can use the following replacements:

    %s: Name of the timer]]
                ,
                setting = "noDurationAnnounce-Debuffs",
            },
            "BREAK",
        },
        { -- column 3
            {
                title = "Standard Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to standard timers.",
                func = function()
                    local setting = "standardSetting-Debuffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == PlayerAuras:Get(setting);
                        info.func = function() 
                            PlayerAuras:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = PlayerAuras:Get(setting) == nil;
                    info.func = function() 
                        PlayerAuras:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
            {
                title = "No Dur. Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to timers with no duration.",
                func = function()
                    local setting = "noDurSetting-Debuffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                    local info;
                    for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = name;
                        info.checked = name == PlayerAuras:Get(setting);
                        info.func = function() 
                            PlayerAuras:Set(setting, name);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                    
                    info = UIDropDownMenu_CreateInfo();
                    info.text = "None";
                    info.tooltipTitle = "Description";
                    info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                    info.checked = PlayerAuras:Get(setting) == nil;
                    info.func = function() 
                        PlayerAuras:Set(setting, nil);
                        CloseDropDownMenus(); 
                    end
                    UIDropDownMenu_AddButton(info);
                end,
            },
            {
                title = "Type Setting",
                type = "dropDown",
                tooltipText = "Select the timer setting you want to apply to all debuffs of a certain type.",
                func = function()
                    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                        for _, type in ipairs({"Magic", "Curse", "Disease", "Poison", "Physical"}) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = type;
                            info.value = type;
                            info.hasArrow = 1;
                            UIDropDownMenu_AddButton(info);
                        end
                    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                        local setting = "timerSetting-" .. UIDROPDOWNMENU_MENU_VALUE .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                        local info;
                        for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = name;
                            info.checked = name == PlayerAuras:Get(setting);
                            info.func = function() 
                                PlayerAuras:Set(setting, name);
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                        end
                        
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "None";
                        info.tooltipTitle = "Description";
                        info.tooltipText = "If you select 'None', the standard/no duration settings will be used instead.";
                        info.checked = PlayerAuras:Get(setting) == nil;
                        info.func = function() 
                            PlayerAuras:Set(setting, nil);
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                    end
                end,
            },
            {
                title = "White List",
                type = "checkButton",
                tooltipText = "If checked, only debuffs added to the 'Visible Timers' edit box to the left will be shown.",
                setting = "whiteList-Debuffs",
                scripts = {
                    OnShow = function(self) 
                        local setting;
                        if self.Get then
                            setting = self.Get(self.setting);
                        else
                            setting = self.module:Get(self.setting);
                        end
                        self:SetChecked(setting and true or false); 
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
    { -- section 3
        subTitle = "Anchor Customization",
        description = "Anchor customization allows you to configure where you want your timers to appear on your screen.",
        padding = 0,
        { -- column 1
            { -- row 2
                {
                    type = "text",
                    text = "Select Module to Customize: ",
                },
                {
                    title = "(Select from DropDown Menu)",
                    type = "dropDown",
                    tooltipText = "Select the module you want to customize.",
                    func = function(self)
                        local info;
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "Buffs";
                        info.checked = "Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT) == CURRENT_MODULE;
                        info.func = function() 
                            CURRENT_MODULE = "Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                            getglobal(self:GetParent():GetName() .. "Text"):SetText("Buffs");
                            for name, settings in pairs(PlayerAuras:Get("userAnchors-" .. CURRENT_MODULE)) do
                                if settings.default then CURRENT_ANCHOR = name; end
                            end
                            for frame in pairs(ANCHOR_FRAMES) do
                                frame:Update();
                            end
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                        
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "Debuffs";
                        info.checked = "Debuffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT) == CURRENT_MODULE;
                        info.func = function() 
                            CURRENT_MODULE = "Debuffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                            getglobal(self:GetParent():GetName() .. "Text"):SetText("Debuffs");
                            for name, settings in pairs(PlayerAuras:Get("userAnchors-" .. CURRENT_MODULE)) do
                                if settings.default then CURRENT_ANCHOR = name; end
                            end
                            for frame in pairs(ANCHOR_FRAMES) do
                                frame:Update();
                            end
                            CloseDropDownMenus(); 
                        end
                        UIDropDownMenu_AddButton(info);
                    end,
                    scripts = {
                        OnShow = function(self)
                            CURRENT_MODULE = "Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT);
                            getglobal(self:GetName() .. "Text"):SetText("Buffs");
                            for frame in pairs(ANCHOR_FRAMES) do
                                frame:Update();
                            end
                        end,
                    },
                },
            },
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
                                    getglobal(self:GetParent():GetName() .. "Text"):SetText(name);
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
                            for name, settings in pairs(PlayerAuras:Get("userAnchors-Buffs" .. (CURRENT_UNIT == "player" and "" or "-" .. CURRENT_UNIT))) do
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
    { -- section 4
        padding = 0,
        showBorder = true,
        { -- column 1
            {
                {
                    title = "Default Anchor",
                    type = "checkButton",
                    tooltipText = "If checked, this anchor will be the default location for all of PlayerAuras's timers for whatever unit/module you've selected.",
                    module = PlayerAuras,
                    scripts = {
                        OnShow = function(self)
                            if not self.loaded then
                                self.loaded = true;
                                self.Update = function(self)
                                    self:SetChecked(self.module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "default"));
                                end
                                ANCHOR_FRAMES[self] = true;
                            end
                            self:Update();
                        end,
                        OnClick = function(self)
                            if self:GetChecked() then
                                for name, settings in pairs(self.module:Get("userAnchors-" .. CURRENT_MODULE)) do
                                    if name ~= CURRENT_ANCHOR then settings.default = nil; end
                                end
                                self.module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "default", 1);
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
                    tooltipText = "You can set up timers to use this as their group data instead of the regular display name.  Things that use the same group data get put in the same group.  If you set this to '*target*' (no quotes), the timers will act as if they were on your current target.",
                    module = PlayerAuras,
                    scripts = {
                        OnEditFocusGained = function(self) 
                            self:SetText(self.module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "standardName") or self.module:Get("displayName" .. CURRENT_MODULE) or ""); 
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
                            self.module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "standardName", text);
                            self:ClearFocus();
                        end,
                    },
                },
                {
                    title = "Move Here",
                    type = "dropDown",
                    tooltipText = "Select which of the below you want moved into this anchor.",
                    func = function()
                        local list = {"No Duration Timers"};
                        local settings = {"noDurLoc"};
                        local module = PlayerAuras;
                        local info;
                        if UIDROPDOWNMENU_MENU_LEVEL == 1 then
                            for i, name in ipairs(list) do
                                local setting = settings[i];
                                info = UIDropDownMenu_CreateInfo();
                                info.checked = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, setting) ~= nil;
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
                                    for name, settings in pairs(module:Get("userAnchors-" .. CURRENT_MODULE)) do
                                        settings[val] = nil;
                                    end
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, val, checked);
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            end
                        elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
                            local val = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE);
                            if val ~= nil then
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Preserve Display Name";
                                info.checked = val == false;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's group name will be the Display Name.";
                                info.func = function()
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE, false);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Use Standard Name";
                                info.checked = val == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's group name will be the Standard Name.";
                                info.func = function()
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE, true);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                            else
                                info = UIDropDownMenu_CreateInfo();
                                local text;
                                for name, settings in pairs(module:Get("userAnchors-" .. CURRENT_MODULE)) do
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
                    text = "Move these timers here:",
                },
                {
                    title = "<Timer Name>",
                    type = "editBoxDropDown",
                    tooltipText = "Type in here the names of individual timers you want moved to this anchor.  The timer name must match only a fragment (case insensitive) in order to move.",
                    module = PlayerAuras,
                    scripts = {
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", string.lower(text), false);
                            self:ClearFocus();
                        end,
                    },
                    func = function()
                        local module = PlayerAuras;
                        local timers = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers");
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
                            local uA = module:Get("userAnchors-" .. CURRENT_MODULE);
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
                                info.text = "Preserve Display Name";
                                info.checked = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == false;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's group name will be the Display Name.";
                                info.func = function()
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, false);
                                    CloseDropDownMenus();
                                end
                                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                
                                info = UIDropDownMenu_CreateInfo();
                                info.text = "Use Standard Name";
                                info.checked = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == true;
                                info.tooltipTitle = "Note";
                                info.tooltipText = "If checked, the timer's group name will be the Standard Name.";
                                info.func = function()
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, true);
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
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, nil);
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
                    module = PlayerAuras,
                    scripts = {
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            self.module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timerSettings", string.lower(text), "Default Timer");
                            self:ClearFocus();
                        end,
                    },
                    func = function()
                        local module = PlayerAuras;
                        local timerSettings = module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timerSettings");
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
                            local uA = module:Get("userAnchors-" .. CURRENT_MODULE);
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
                                    info.checked = name == module:Get("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE);
                                    info.func = function() 
                                        module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE, name);
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
                                    module:Set("userAnchors-" .. CURRENT_MODULE, CURRENT_ANCHOR, "timerSettings", UIDROPDOWNMENU_MENU_VALUE, nil);
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

local function createPAGUI()
    if not AsheylaLib:InSimpleMode() then
        GUILib:SetGUIPanel("DoTimer", "PlayerAuras", PlayerAuras, optionsTable, {set = set, get = get});
    end
end
createPAGUI();
GUILib:AddGUICreationScript(createPAGUI);
