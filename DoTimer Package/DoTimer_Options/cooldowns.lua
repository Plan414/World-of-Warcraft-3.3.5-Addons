AsheylaLib:Package( "GUILib" );

local Cooldowns = AsheylaLib:Import( "Cooldowns" );
local TimerLib = AsheylaLib:Import( "TimerLib" );
local CURRENT_ANCHOR, CURRENT_TIMER = "", "";
local ANCHOR_FRAMES = {};
local WHITELIST_FRAMES = {};

local function createCGUI()
    local optionsTable = {
        { -- section 1
            title = "General Options",
            description = "These options control general usage of Cooldowns.",
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
                    title = "Min Duration",
                    type = "slider",
                    tooltipText = "Sets the minimum duration, in seconds, that a cooldown must have in order to track it.  Zero means no restriction.",
                    minValue = 0, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "minCooldown",
                    simple = true,
                },
                {
                    title = "Max Duration",
                    type = "slider",
                    tooltipText = "Sets the maximum duration, in minutes, that a cooldown can have in order to track it.  Zero means no restriction.",
                    minValue = 0, 
                    maxValue = 60,
                    valueStep = 5,
                    setting = "maxCooldown",
                    simple = true,
                },
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
        %d: Time remaining]]
                    ,
                    setting = "standardAnnounce",
                    simple = true,
                },
                {
                    title = "Force Show",
                    type = "editBoxDropDown",
                    tooltipText = "Add here the names of timers that should always show a cooldown timer (i.e., never be merged into another similar timer).  The timer name much match exactly (case insensitive) to be force-shown.",
                    setting = "forceShow",
                    simple = false,
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
            { -- column 3
                {
                    title = "Key Bindings",
                    type = "dropDown",
                    tooltipText = "Allows you to change the key bindings for various timer-related functions.",
                    func = function() Cooldowns.kblib:KBDropDown() end,
                },
                {
                    title = "Timer Setting",
                    type = "dropDown",
                    tooltipText = "Select the timer setting you want to apply to the timers.",
                    func = function()
                        local setting = "standardSetting";
                        local info;
                        for name, settings in alphabetize(TimerLib:Get("timerSettings")) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = name;
                            info.checked = name == Cooldowns:Get(setting);
                            info.func = function() 
                                Cooldowns:Set(setting, name);
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info);
                        end
                        
                        info = UIDropDownMenu_CreateInfo();
                        info.text = "None";
                        info.tooltipTitle = "Description";
                        info.tooltipText = "If you select 'None', the default for the anchor will be used instead.";
                        info.checked = Cooldowns:Get(setting) == nil;
                        info.func = function() 
                            Cooldowns:Set(setting, nil);
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
                {
                    title = "Display Name",
                    type = "editBoxString",
                    tooltipText = "Sets the text to be displayed as the name of the group.  If you set this to a value another group is also using (in the same anchor), the two groups will merge into one.  If you set this to '*target*' (no quotes), the timers will act as if they were on your current target.",
                    setting = "displayName",
                },
                "BREAK",
            },
        },
        { -- section 4
            title = "Anchor Customization",
            description = "Anchor customization allows you to configure where you want your timers to appear on your screen.",
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
                                for name, settings in pairs(Cooldowns:Get("userAnchors")) do
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
                        tooltipText = "If checked, this anchor will be the default location for all of Cooldowns's timers.",
                        module = Cooldowns,
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
                        tooltipText = "You can set up timers to use this as their group data instead of the regular display name.  Things that use the same group data get put in the same group.  If you set this to '*target*' (no quotes), the timers will act as if they were on your current target.",
                        module = Cooldowns,
                        scripts = {
                            OnEditFocusGained = function(self) 
                                self:SetText(self.module:Get("userAnchors", CURRENT_ANCHOR, "standardName") or self.module:Get("displayName") or ""); 
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
                    --[[{
                        title = "Move Here",
                        type = "dropDown",
                        tooltipText = "Select which of the below you want moved into this anchor.",
                        func = function()
                            local list = {"Communicated Timers"};
                            local settings = {"externalLoc"};
                            local module = Cooldowns;
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
                                    info.text = "Preserve Display Name";
                                    info.checked = val == false;
                                    info.tooltipTitle = "Note";
                                    info.tooltipText = "If checked, the timer's group name will be the Display Name.";
                                    info.func = function()
                                        module:Set("userAnchors", CURRENT_ANCHOR, UIDROPDOWNMENU_MENU_VALUE, false);
                                        CloseDropDownMenus();
                                    end
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                    
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = "Use Standard Name";
                                    info.checked = val == true;
                                    info.tooltipTitle = "Note";
                                    info.tooltipText = "If checked, the timer's group name will be the Standard Name.";
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
                    },--]]
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
                        module = Cooldowns,
                        scripts = {
                            OnEnterPressed = function(self) 
                                local text = self:GetText();
                                self.module:Set("userAnchors", CURRENT_ANCHOR, "timers", string.lower(text), false);
                                self:ClearFocus();
                            end,
                        },
                        func = function()
                            local module = Cooldowns;
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
                                    info.text = "Preserve Display Name";
                                    info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == false;
                                    info.tooltipTitle = "Note";
                                    info.tooltipText = "If checked, the timer's group name will be the Display Name.";
                                    info.func = function()
                                        module:Set("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE, false);
                                        CloseDropDownMenus();
                                    end
                                    UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
                                    
                                    info = UIDropDownMenu_CreateInfo();
                                    info.text = "Use Standard Name";
                                    info.checked = module:Get("userAnchors", CURRENT_ANCHOR, "timers", UIDROPDOWNMENU_MENU_VALUE) == true;
                                    info.tooltipTitle = "Note";
                                    info.tooltipText = "If checked, the timer's group name will be the Standard Name.";
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
                        module = Cooldowns,
                        scripts = {
                            OnEnterPressed = function(self) 
                                local text = self:GetText();
                                self.module:Set("userAnchors", CURRENT_ANCHOR, "timerSettings", string.lower(text), "Default Timer");
                                self:ClearFocus();
                            end,
                        },
                        func = function()
                            local module = Cooldowns;
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
    
    GUILib:SetGUIPanel("DoTimer", "Cooldowns", Cooldowns, optionsTable);
end
createCGUI();
GUILib:AddGUICreationScript(createCGUI);
