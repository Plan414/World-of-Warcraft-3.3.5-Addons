AsheylaLib:Package( "GUILib" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local SECTION_NAME = "DoTimer Timers";

local blacklist = {
    ["Default Timer"] = true,
    ["DoTimer Timer"] = true,
    ["Cooldowns Timer"] = true,
    ["PlayerAuras Timer"] = true,
};

local function prefix()
    return ""
end

local function createGUI(name)
    local optionsTable = {
        { -- section 1
            title = "Timer Customization",
            description = "Timer settings are how you can change the appearance of your timers.  You create a new timer setting and customize all its options, and then you assign it to whatever anchors or timers you want.Each module (DoTimer, Cooldowns, etc) contains settings to assign timer settings to timers, and each anchor can have a default timer setting.  \n\n" ..
                "If the little checkbox next to a specific setting is unchecked, other timer settings are checked in a specific order.  First, if a basis timer setting has been selected below, it is checked for a value.  Then, the anchor's default timer setting is checked.  Finally, the value from Default Timer is used.",
            padding = 10,
            { -- column 1
                {
                    {
                        type = "text",
                        text = name,
                    },
                },       
                {
                    title = "Preview",
                    type = "button",
                    tooltipText = "Show a preview of timers with this setting.",
                    func = function()
                        local offset = 0;
                        for i = 1, 2 do
                            local g = "Scary Mob " .. i;
                            for j = 1, 3 do
                                TimerLib:NewTimer({duration = 15 + offset, time = GetTime(), name = "Cool Timer " .. j}, g, nil, name);
                                offset = offset + .5;
                            end
                        end
                    end,
                },
            },
        },
        { -- section 2
            subTitle = "General Options",
            description = "These options control basic aspects of the timer.",
            showBorder = true,
            padding = 15,
            { -- column 1
                {
                    title = "Timer Format",
                    type = "dropDownSelector",
                    tooltipText = "Sets the format of the timer.  The format dictates the major appearance, and several timer settings only apply to one of the formats.",
                    values = {"bar", "icon"};
                    setting = "timerFormat",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Clickable",
                    type = "checkButton",
                    tooltipText = "If checked, the timer will respond to mouse events such as clicking and mousing over.",
                    setting = "clickable",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Tenths",
                    type = "checkButton",
                    tooltipText = "If checked, the time remaining will display tenths of a second when the time remaining is less than 10 seconds.",
                    setting = "tenths",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Sound Alert",
                    type = "checkButton",
                    tooltipText = "If checked, a sound will be played when the timer hits its red point.",
                    setting = "soundAlert",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Ghosts",
                    type = "checkButton",
                    tooltipText = "If checked, the timer will turn into a ghost timer when finished.",
                    setting = "ghosts",
                    hasToggle = name ~= "Default Timer",
                },
            },
            {
                {
                    title = "Tooltips",
                    type = "checkButton",
                    tooltipText = "If checked, the timer will display a tooltip when moused over.",
                    setting = "tooltips",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Time Format",
                    type = "dropDownSelector",
                    tooltipText = "If letters, then the timer's time remaining will be displayed in a format like '5s'.  If digital, it will be ':05'.",
                    values = {"letters", "digital"};
                    setting = "timeFormat",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Alpha",
                    type = "slider",
                    tooltipText = "Sets the alpha of the timer.  Certain parts of the timer, such as text, are not affected by this setting.",
                    minValue = 0, 
                    maxValue = 1,
                    valueStep = .05,
                    setting = "alpha",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Scale",
                    type = "slider",
                    tooltipText = "Sets the scale of the timer.",
                    minValue = .5, 
                    maxValue = 2,
                    valueStep = .1,
                    setting = "scale",
                    hasToggle = name ~= "Default Timer",
                },
            },
            {
                {
                    title = "Ghost Duration",
                    type = "slider",
                    tooltipText = "Sets the duration that the timer persists after finishing as a ghost.  Zero means that the timer will stay as a ghost until all timers in its group are also ghosts.",
                    minValue = 0, 
                    maxValue = 15,
                    valueStep = 1,
                    setting = "ghostLength",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Fade In Length",
                    type = "slider",
                    tooltipText = "Sets the amount of time it takes the timer to fade in when it begins.",
                    minValue = 0, 
                    maxValue = 5,
                    valueStep = .25,
                    setting = "fadeInLength",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Fade Out Length",
                    type = "slider",
                    tooltipText = "Sets the amount of time it takes the timer to fade out when it finishes.",
                    minValue = 0, 
                    maxValue = 5,
                    valueStep = .25,
                    setting = "fadeOutLength",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Red Point",
                    type = "editBoxString",
                    tooltipText = "Type in here the point at which you want the timer to turn its final color (default red).  Type it in the form '5m', '10s', '5m 30s', etc. (no quotes).",
                    setting = "redPoint",
                    hasToggle = name ~= "Default Timer",
                    setting = "redPoint",
                    notSimple = true,
                    scripts = {
                        OnEditFocusGained = function(self) 
                            local num;
                            if self.Get then
                                num = self.Get(self.setting);
                            else
                                num = self.module:Get(self.setting);
                            end
                            self:SetText(text and numToText(num) or ""); 
                            self:HighlightText(); 
                        end,
                        OnEnterPressed = function(self) 
                            local text = self:GetText();
                            local num = textToNum(text);
                            if self.Set then
                                self.Set(self.setting, num);
                            else
                                self.module:Set(self.setting, num); 
                            end
                            if self.toggle then self.toggle:SetChecked(true); end
                            self:ClearFocus();
                        end,
                    },
                },
            },
        },
        {
            subTitle = "Colors",
            description = "These settings control the colors that the timer can have set.",
            showBorder = true,
            padding = 15,
            {
                {
                    title = "Start",
                    type = "colorSelect",
                    tooltipText = "Sets the initial color of the timer.",
                    setting = "startColor",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Background",
                    type = "colorSelect",
                    tooltipText = "Sets the color of the bar background in bar mode and the border of the icon in icon mode if 'Use Background' is checked.",
                    setting = "barBackgroundColor",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Middle",
                    type = "colorSelect",
                    tooltipText = "Sets the color the timer will change to at 50% completion.",
                    setting = "middleColor",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Ghost",
                    type = "colorSelect",
                    tooltipText = "Sets the color of the ghost timer.",
                    setting = "ghostColor",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Final",
                    type = "colorSelect",
                    tooltipText = "Sets the color the timer will change to at 'Red Point' seconds left.",
                    setting = "finalColor",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Bar Text",
                    type = "colorSelect",
                    tooltipText = "Sets the color of the bar text.",
                    setting = "barTextColor",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
        },
        {
            subTitle = "Icon Settings",
            description = "These settings affect the look of the timer if it appears as an icon.",
            showBorder = true,
            padding = 15,
            { -- column 2
                {
                    title = "Show CD",
                    type = "checkButton",
                    tooltipText = "If checked, a cooldown clock will display on the anchor.",
                    setting = "iconShowCooldown",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Reverse CD",
                    type = "checkButton",
                    tooltipText = "If checked, the cooldown clock will increase darkness instead of increasing lightness.",
                    setting = "iconReverseCooldown",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Flip Text",
                    type = "checkButton",
                    tooltipText = "If checked, the time remaining string, if displayed outside the icon, will flip to the oppsosite side of the icon.",
                    setting = "iconFlipText",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Use Background",
                    type = "checkButton",
                    tooltipText = "If checked, the border around the icon will use the background color, selected above, instead of the color of the duration text.",
                    setting = "iconUseBG",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Display Format",
                    type = "dropDownSelector",
                    tooltipText = "Sets where the time remaining will appear: outside the icon, inside the icon, or nowhere.",
                    values = {"inside", "outside", "none"};
                    setting = "iconDisplayFormat",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Font Height",
                    type = "slider",
                    tooltipText = "Sets the height of the font showing the duration text.",
                    minValue = 5, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "iconFontHeight",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
        },
        {
            subTitle = "Bar Settings",
            description = "These settings affect the look of the timer if it appears as a bar.",
            showBorder = true,
            padding = 15,
            { -- column 3
                {
                    title = "Flip Icon",
                    type = "checkButton",
                    tooltipText = "If checked, the icon will be displayed to the right of the bar instead of the left.",
                    setting = "barFlipIcon",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Show Icon",
                    type = "checkButton",
                    tooltipText = "If unchecked, no icon will be shown next to the bar.",
                    setting = "barShowIcon",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Reversed",
                    type = "checkButton",
                    tooltipText = "If checked, the bar will shrink/grow from the right/top instead of the left/bottom.",
                    setting = "barReversed",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Grow",
                    type = "checkButton",
                    tooltipText = "If checked, the bar will grow instead of shrink.",
                    setting = "barGrow",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Major Length",
                    type = "slider",
                    tooltipText = "Sets the major length of the bar.  This is its width when horizontal and height when vertical.",
                    minValue = 50, 
                    maxValue = 250,
                    valueStep = 5,
                    setting = "barMajorLength",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Minor Length",
                    type = "slider",
                    tooltipText = "Sets the minor length of the bar.  This is its height when horizontal and width when vertical.",
                    minValue = 5, 
                    maxValue = 30,
                    valueStep = 1,
                    setting = "barMinorLength",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Font Height",
                    type = "slider",
                    tooltipText = "Sets the height of the font inside the bar.",
                    minValue = 5, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "barFontHeight",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Absolute Scale",
                    type = "slider",
                    tooltipText = "Sets the absolute scale of the bar.  If the scaling is set to 'absolute', the bar won't change until the timer has this much time remaining, at which point the bar will change as if the timer's duration is this setting.",
                    minValue = 1, 
                    maxValue = 30,
                    valueStep = 1,
                    setting = "barAbsScale",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Orientation",
                    type = "dropDownSelector",
                    tooltipText = "Sets the orientation of the bar.",
                    values = {"horizontal", "vertical"},
                    setting = "barOrientation",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Texture",
                    type = "dropDown",
                    tooltipText = "Sets the texture for the bar.",
                    func = function()
                        local level = UIDROPDOWNMENU_MENU_LEVEL;
                        local info;
                        if (level == 1) then
                            info = UIDropDownMenu_CreateInfo();
                            info.notCheckable = true;
                            info.hasArrow = true;
                            info.text = "Horizontal";
                            info.value = "horiz";
                            UIDropDownMenu_AddButton(info);
                            
                            info = UIDropDownMenu_CreateInfo();
                            info.notCheckable = true;
                            info.hasArrow = true;
                            info.text = "Vertical";
                            info.value = "vert";
                            UIDropDownMenu_AddButton(info);
                            
                            if sharedMedia() then
                                for i = 1, math.ceil(#sharedMedia():List("statusbar") / 10) do
                                    info = UIDropDownMenu_CreateInfo();
                                    info.notCheckable = true;
                                    info.hasArrow = true;
                                    info.text = "Shared Media-" .. i;
                                    info.value = "shared" .. i;
                                    UIDropDownMenu_AddButton(info, level);
                                end
                            end
                        elseif (level == 2) then
                            local list = UIDROPDOWNMENU_MENU_VALUE;
                            local values, start, finish;
                            if list == "horiz" then
                                values = {"Aluminium", "Banto", "Charcoal", "Elven", "Glaze", "Gloss", "Grunge", "Halycon", "Healbot", "LiteStep", "Moonmaster", "OtraviCB", "Perl", "Rocks", "Runes", "Smooth", "Solid", "Steel", "Stone"};
                                start = 1;
                                finish = #values;
                            elseif list == "vert" then
                                values = {"Aluminium-V", "Banto-V", "Charcoal-V", "Elven-V", "Glaze-V", "Gloss-V", "Grunge-V", "Halycon-V", "Healbot-V", "LiteStep-V", "Moonmaster-V", "OtraviCB-V", "Perl-V", "Rocks-V", "Runes-V", "Smooth-V", "Solid-V", "Steel-V", "Stone-V"};
                                start = 1;
                                finish = #values;
                            elseif string.find(list, "shared") then
                                values = sharedMedia() and sharedMedia():List("statusbar");
                                local group = string.match(list, "(%d+)");
                                start = (10 * (group - 1)) + 1;
                                finish = 10 * group;
                            end
                            if values then
                                for i = start, finish do
                                    local value = values[i];
                                    if value then
                                        info = UIDropDownMenu_CreateInfo();
                                        info.text = value;
                                        info.checked = TimerLib:Get("timerSettings", name, "barTexture") == value;
                                        info.func = function() 
                                            TimerLib:Set("timerSettings", name, "barTexture", value);
                                            CloseDropDownMenus(); 
                                            InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name == "Default Timer" and "main" or name);
                                        end
                                        UIDropDownMenu_AddButton(info, level);
                                    end
                                end
                            end
                        end
                    end,
                    setting = "barTexture",
                    hasToggle = name ~= "Default Timer",
                },
                {
                    title = "Scaling",
                    type = "dropDownSelector",
                    tooltipText = "Sets how the bar will change its value.  If standard, it will change linearly.  If absolute, it will not change until it hits the Absolute Scale setting.  If exponential, the bar will change faster when the timer is nearing completion.",
                    values = {"standard", "absolute", "exponential"},
                    setting = "barScaling",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Left Text",
                    type = "dropDownSelector",
                    tooltipText = "Sets the text on the left side of the bar.",
                    values = {"Timer Name", "Timer Name (Stack)", "Group Name", "Time Remaining", "None"},
                    setting = "barLeftText",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
                {
                    title = "Right Text",
                    type = "dropDownSelector",
                    tooltipText = "Sets the text on the right side of the bar.",
                    values = {"Timer Name", "Timer Name (Stack)", "Group Name", "Time Remaining", "None"},
                    setting = "barRightText",
                    hasToggle = name ~= "Default Timer",
                    notSimple = true,
                },
            },
        },
    };
    
    if name == "Default Timer" then
        if not AsheylaLib:InSimpleMode() then
            local newButton = {
                title = "Make New Setting!",
                type = "editBoxString",
                tooltipText = "Type in the name of a new timer setting to be customized.",
                scripts = {
                    OnEditFocusGained = function(self) self:SetText(""); self:HighlightText() end,
                    OnEnterPressed = function(self) 
                        local text = self:GetText();
                        if not TimerLib:Get("timerSettings", text) then
                            TimerLib:Set("timerSettings", text, {});
                        end
                        GUILib:ShowPanel(SECTION_NAME, text == "Default Anchor" and "main" or text);
                        self:ClearFocus();
                    end,
                },
            };
            table.insert(optionsTable[1][1][1], newButton);
        end
    elseif not blacklist[name] then
        local newButton1 = {
            title = "Delete",
            type = "button",
            tooltipText = "Deletes this setting.",
            func = function() 
                local frame = StaticPopup_Show("TIMERLIBTIMER", name)
                frame.data = name;
            end,
        };
        local newButton2 = {
            title = "Basis Timer Setting",
            type = "dropDown",
            tooltipText = "Select the timer setting you want to have applied for the settings you don't set up below (i.e., ones that don't have their little checkbox checked).",
            func = function()
                local setting = "reference";
                local info;
                for setName, settings in alphabetize(TimerLib:Get("timerSettings")) do
                    if setName ~= "Default Timer" and setName ~= name then
                        info = UIDropDownMenu_CreateInfo();
                        info.text = setName;
                        info.checked = setName == TimerLib:Get("timerSettings", name, setting);
                        info.func = function() 
                            TimerLib:Set("timerSettings", name, setting, setName);
                            CloseDropDownMenus(); 
                            InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name);
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                end
                
                info = UIDropDownMenu_CreateInfo();
                info.text = "None";
                info.tooltipTitle = "Description";
                info.tooltipText = "If you select 'None', a default value will be found instead.";
                info.checked = TimerLib:Get("timerSettings", name, setting) == nil;
                info.func = function() 
                    TimerLib:Set("timerSettings", name, setting, nil);
                    CloseDropDownMenus(); 
                    InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name);
                end
                UIDropDownMenu_AddButton(info);
            end,
            setting = "reference",
        };
        table.insert(optionsTable[1][1][1], newButton1);
        table.insert(optionsTable[1][1][1], newButton2);
    else
        local newButton = {
            title = "Basis Timer Setting",
            type = "dropDown",
            tooltipText = "Select the timer setting you want to have applied for the settings you don't set up below (i.e., ones that don't have their little checkbox checked).",
            func = function()
                local setting = "reference";
                local info;
                for setName, settings in alphabetize(TimerLib:Get("timerSettings")) do
                    if setName ~= "Default Timer" and setName ~= name then
                        info = UIDropDownMenu_CreateInfo();
                        info.text = setName;
                        info.checked = setName == TimerLib:Get("timerSettings", name, setting);
                        info.func = function() 
                            TimerLib:Set("timerSettings", name, setting, setName);
                            CloseDropDownMenus(); 
                            InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name);
                        end
                        UIDropDownMenu_AddButton(info);
                    end
                end
                
                info = UIDropDownMenu_CreateInfo();
                info.text = "None";
                info.tooltipTitle = "Description";
                info.tooltipText = "If you select 'None', a default value will be found instead.";
                info.checked = TimerLib:Get("timerSettings", name, setting) == nil;
                info.func = function() 
                    TimerLib:Set("timerSettings", name, setting, nil);
                    CloseDropDownMenus(); 
                    InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name);
                end
                UIDropDownMenu_AddButton(info);
            end,
            setting = "reference",
        };
        table.insert(optionsTable[1][1][1], newButton);
    end
    if not AsheylaLib:InSimpleMode() and sharedMedia() then
        table.insert(optionsTable[2][2], 3, {
            title = "Font",
            type = "dropDownSelector",
            tooltipText = "Sets the font of any text in the timer.",
            values = sharedMedia():List("font");
            setting = "font",
            hasToggle = name ~= "Default Timer",
        });
    end
    
    local defaultFunc = function()
        TimerLib:Set("timerSettings", name, {});
        InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name == "Default Timer" and "main" or name);
    end
    
    local getFunc = function(...)
        local val, isReal;
        local checked = acquireTable();
        local ref = name;
        while ref and val == nil and not checked[ref] do
            val = TimerLib:Get("timerSettings", ref, ...);
            isReal = val ~= nil and ref == name;
            checked[ref] = true;
            ref = TimerLib:Get("timerSettings", ref, "reference");
        end
        releaseTable(checked);
        if val == nil then
            val = TimerLib:Get("timerSettings", "Default Timer", ...);
        end
        return val, isReal;
    end
    
    local setFunc = function(...)
        TimerLib:Set("timerSettings", name, ...);
    end
    
    local toggleTooltip = "If this checkbutton is unchecked, the setting does not apply and a default value will be used instead.  The default value will be found first by looking at the basis timer setting, then at the value in the anchor's default timer setting, then at the value in Default Timer.";
    if AsheylaLib:InSimpleMode() then
        optionsTable[1].description = "Timer Settings let you change the appearance of the timers that DoTimer and Cooldowns create.";
    end
    local highlight = not blacklist[name];
    GUILib:SetGUIPanel(SECTION_NAME, name == "Default Timer" and "main" or prefix( name ) .. name, TimerLib, optionsTable, {default = defaultFunc, get = getFunc, set = setFunc, toggleTooltip = toggleTooltip, allSimple = true, highlight = highlight});
end

StaticPopupDialogs["TIMERLIBTIMER"] = {
    text = "You are about to delete the timer setting |cff00ff00%s|r.  Do you wish to proceed?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, name) 
        TimerLib:Set("timerSettings", name, nil);
        GUILib:ShowPanel(SECTION_NAME, "main");
    end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}

local existing = {};
local function createTimerGUI()
    table.wipe(existing);
    local cats = INTERFACEOPTIONS_ADDONCATEGORIES;
    local parent;
    for i = #cats, 1, -1 do
        if cats[i].parent == SECTION_NAME then
            if TimerLib:Get("timerSettings", cats[i].name) then
                table.insert(existing, cats[i].name);
                existing[cats[i].name] = cats[i];
                if not blacklist[cats[i].name] then    
                    table.remove(cats, i);
                end
            else
                table.remove(cats, i);
            end
        elseif cats[i].name == SECTION_NAME then
            parent = cats[i];
            existing[cats[i].name] = true;
        end
    end
    if parent and #existing == 0 then
        parent.hasChildren = false;
        parent.collapsed = nil;
    end
    
    if AsheylaLib:InSimpleMode() then
        if not existing[SECTION_NAME] then createGUI("Default Timer"); end
    else
        if not existing[SECTION_NAME] then createGUI("Default Timer"); end
        if not existing[SECTION_NAME] then createGUI("DoTimer Timer"); end
        if not existing[SECTION_NAME] then createGUI("Cooldowns Timer"); end
        if not existing[SECTION_NAME] then createGUI("PlayerAuras Timer"); end
        for name in alphabetize(TimerLib:Get("timerSettings")) do
            if not (blacklist[name]) then
                local old = existing[name];
                if old then
                    InterfaceOptions_AddCategory(old);
                else
                    createGUI(name);
                end
            end
        end
    end
end

-- todo: helper functions
    -- depth
    -- parent
    -- prefix
--[[
local function createTimerGUI( remaking )
    table.wipe(existing);
    local cats = INTERFACEOPTIONS_ADDONCATEGORIES;
    -- if we aren't totally redoing the GUI, then first we want to find
    -- the panels we've already made, so we don't have to bother remaking
    for i = #cats, 1, -1 do
        if cats[i].parent == SECTION_NAME then
            if not remaking and TimerLib:Get("timerSettings", cats[i].name) then
                existing[cats[i].name:trim()] = cats[i];  
                table.remove(cats, i);
            else
                table.remove(cats, i);
            end
        elseif cats[i].name == SECTION_NAME then
            if not remaking then
                existing[cats[i].name] = true;
            else
                table.remove( cats, i );
            end
        end
    end
    
    if AsheylaLib:InSimpleMode() then
        -- since Simple Mode doesn't have extra settings, just make this one
        if not existing[SECTION_NAME] then createGUI("Default Timer"); end
    else
        -- first, identify all the timer settings we'll be displaying
        -- note that some may not have panels (if they were just made)
        for name in pairs( TimerLib:Get( "timerSettings" ) ) do
            if name ~= "Default Timer" then
                table.insert( existing, name );
            end
        end
        
        -- sort them based on the tree structure that we'll be displaying!
        table.sort( existing, function( a, b )
            local aSetting, bSetting = a:trim(), b:trim();
            local aDepth, bDepth = depth( aSetting ), depth( bSetting );
            while aDepth > bDepth do
                a = parent( a );
                aDepth = aDepth - 1;
            end
            while bDepth > aDepth do
                b = parent( b );
                bDepth = bDepth - 1;
            end
            while parent( a ) ~= parent( b ) do
                a = parent( a );
                b = parent( b );
            end
            if blacklist[ a ] ~= blacklist[ b ] then
                return blacklist[ a ] == true;
            end
            return a < b;
        end );
        
        -- add in the main one if necessary
        if not existing[SECTION_NAME] then createGUI("Default Timer"); end
        
        -- now we know how we can add them back in
        for _, name in ipairs( existing ) do
            local old = existing[name];
            if old then
                old.name = prefix( name ) .. name;
                InterfaceOptions_AddCategory(old);
            else
                createGUI(name);
            end
        end
    end
end--]]
createTimerGUI(true);
GUILib:AddGUICreationScript(function() createTimerGUI(true) end);
GUILib:AddProfileChangeScript(function() createTimerGUI(false) end);
TimerLib:AddSettingsUpdateScript(function() createTimerGUI(false) end);
