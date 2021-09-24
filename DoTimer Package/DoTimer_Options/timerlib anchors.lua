AsheylaLib:Package( "GUILib" );

local TimerLib = AsheylaLib:Import( "TimerLib" );
local SECTION_NAME = "DoTimer Anchors";

local blacklist = {
    ["Default Anchor"] = true,
    ["DoTimer Mouseover"] = true,
    ["Notifications Anchor"] = true,
    ["DoTimer Anchor"] = true,
    ["Cooldowns Anchor"] = true,
    ["PlayerAuras Anchor"] = true,
};

local function createGUI(name)
    local optionsTable = {
        { -- section 1
            title = "Anchor Customization",
            description = "Anchors are locations on the screen to which timers are added, organized in groups.  In each module's (DoTimer, Cooldowns, etc) settings, you can control which timers are added to which anchors, and in these settings, you can control how those anchors are configured.  Settings that do not have a checkmark in the little checkbutton next to them will have Default Anchor's value used instead.",
            padding = 10,
            { -- column 1
                {
                    type = "text",
                    text = name,
                },
                {
                    {
                        title = "Preview",
                        type = "button",
                        tooltipText = "Show a preview of timers on this anchor.",
                        func = function()
                            local offset = 0;
                            for i = 1, 2 do
                                local g = "Scary Mob " .. i;
                                for j = 1, 3 do
                                    TimerLib:NewTimer({duration = 15 + offset, time = GetTime(), name = "Cool Timer " .. j}, g, nil, nil, nil, nil, name);
                                    offset = offset + .5;
                                end
                            end
                        end,
                    },
                    {
                        title = "Reset Position",
                        type = "button",
                        tooltipText = "Reset the position of this anchor.",
                        func = function()
                            TimerLib:Set("anchorSettings", name, "positionX", nil);
                            TimerLib:Set("anchorSettings", name, "positionY", nil);
                            TimerLib:Set("anchorPoint", name, "TOPLEFT", nil);
                            TimerLib:Set("relativePoint", name, "BOTTOMLEFT", nil);
                            TimerLib:Set("relativeTo", name, "UIParent", nil);
                        end,
                    },
                },
            },
        },
        {
            subTitle = "General Options",
            description = "These settings control basic aspects of the anchor.",
            showBorder = true,
            padding = 15,
            {
                {
                    title = "Locked",
                    type = "checkButton",
                    tooltipText = "If unchecked, you may change the location of the anchor by dragging any timer currently running on it or the name of any group in it.",
                    setting = "locked",
                    hasToggle = name ~= "Default Anchor",
                },
                {
                    title = "Hide All",
                    type = "checkButton",
                    tooltipText = "If checked, this anchor (and all its timers) will be hidden from view.",
                    setting = "hideAll",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Interactive",
                    type = "checkButton",
                    tooltipText = "If unchecked, any timers and their group names on this anchor will be unclickable.  Note that an anchor must both be interactable and unlocked in order to move it to a new position.",
                    setting = "interactable",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Timer Setting",
                    type = "dropDown",
                    tooltipText = "Select the timer setting you want to apply to timers that don't have their own setting.",
                    func = function(self)
                        local setting = "defaultTimerSetting";
                        local info;
                        for timerName, settings in alphabetize(TimerLib:Get("timerSettings")) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = timerName;
                            info.checked = timerName == TimerLib:Get("anchorSettings", name, setting);
                            info.func = function() 
                                TimerLib:Set("anchorSettings", name, setting, timerName);
                                if self:GetParent().toggle then
                                    self:GetParent().toggle:SetChecked(true);
                                end
                                CloseDropDownMenus(); 
                            end
                            UIDropDownMenu_AddButton(info);
                        end
                    end,
                    setting = "defaultTimerSetting",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Scale",
                    type = "slider",
                    tooltipText = "Sets the scale of the anchor.",
                    minValue = .5, 
                    maxValue = 2,
                    valueStep = .1,
                    setting = "scale",
                    hasToggle = name ~= "Default Anchor",
                },
            },
        },
        {
            subTitle = "Group Names",
            description = "These settings affect the display of the names of each group.",
            showBorder = true,
            padding = 15,
            {
                {
                    title = "Display Names",
                    type = "checkButton",
                    tooltipText = "If checked, groups will have their name displayed at the head of the group.",
                    setting = "displayNames",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Display Icons",
                    type = "checkButton",
                    tooltipText = "If checked, groups will display a raid icon if applicable.",
                    setting = "displayIcons",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Move Name",
                    type = "checkButton",
                    tooltipText = "If checked, the group name will be moved to a more streamlined location.",
                    setting = "moveName",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Name Scale",
                    type = "slider",
                    tooltipText = "Sets the scale of the group names.  This affects both the text and the raid icon.",
                    minValue = .5, 
                    maxValue = 2,
                    valueStep = .1,
                    setting = "nameScale",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Name Spacing",
                    type = "slider",
                    tooltipText = "Sets how far the group names are from the group's timers.",
                    minValue = 0, 
                    maxValue = 10,
                    valueStep = 1,
                    setting = "nameSpacing",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Name Font Height",
                    type = "slider",
                    tooltipText = "Sets the height font for the group name.",
                    minValue = 5, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "nameFontHeight",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Name Format",
                    type = "editBoxString",
                    tooltipText = [[Sets how the name text is formatted.  You can use the following replacements:

        %s: Name of the group (may get newlines added to it)
        %l: Group level (if exists; uses below setting)
        %r: Group raid icon (if exists; uses below setting)]]
                    ,
                    setting = "nameFormat",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Name Level Format",
                    type = "editBoxString",
                    tooltipText = [[Sets how the level in the name text is formatted.  You can use the following replacement:

        %s: Group level]]
                    ,
                    setting = "nameLevelFormat",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Name Raid Icon Format",
                    type = "editBoxString",
                    tooltipText = [[Sets how the raid icon in the name text is formatted.  You can use the following replacement:

        %s: Raid icon]]
                    ,
                    setting = "nameRaidIconFormat",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Name Text Color",
                    type = "colorSelect",
                    tooltipText = "Sets the color of the groups' name.",
                    setting = "nameTextColor",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
        },
        {
            subTitle = "Layout and Positioning",
            padding = 15,
            description = "These settings control the behavior of the anchoring of the timers and groups of the anchor.",
            showBorder = true,
            {
                {
                    title = "Justification",
                    type = "dropDownSelector",
                    tooltipText = "Sets the justification of the timers and groups.  By default the timers/groups are aligned to the top or to the left, depending on situation.  This setting allows you to change that behavior.",
                    values = {"auto", "bottom", "right"};
                    setting = "timerJustification",
                    hasToggle = name ~= "Default Anchor",
                }, 
                {
                    title = "Centering",
                    type = "dropDownSelector",
                    tooltipText = "By default, groups in an anchor are aligned on one of the timers' sides.  This setting lets you align the groups in the center of the timers instead.",
                    values = {"none", "horizontal", "vertical"};
                    setting = "centering",
                    hasToggle = name ~= "Default Anchor",
                },
                {
                    title = "Group Sort",
                    type = "dropDownSelector",
                    tooltipText = "Sets the manner in which groups are sorted.",
                    values = {"Time Added (A)", "Time Added (D)", "Alphabetical (A)", "Alphabetical (D)"};
                    setting = "groupSortMethod",
                    hasToggle = name ~= "Default Anchor",
                }, 
                {
                    title = "Timer Sort",
                    type = "dropDownSelector",
                    tooltipText = "Sets the manner in which timers in a group are sorted.",
                    values = {"Time Added (A)", "Time Added (D)", "Time Remaining (A)", "Time Remaining (D)", "Percent Remaining (A)", "Percent Remaining (D)", "Alphabetical (A)", "Alphabetical (D)"};
                    setting = "timerSortMethod",
                    hasToggle = name ~= "Default Anchor",
                },
            },
            {
                {
                    title = "Overflow Point",
                    type = "slider",
                    tooltipText = "Sets the number of timers a group can have before it starts overflowing.  Overflow timers will be placed in a new group anchored relative to the original group.",
                    minValue = 0, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "overflowPoint",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Overflow Direction",
                    type = "dropDownSelector",
                    tooltipText = "Sets the direction overflow groups are added to a group.",
                    values = {"up", "down", "left", "right"};
                    setting = "overflowDirection",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Group Direction",
                    type = "dropDownSelector",
                    tooltipText = "Sets the direction new groups are added.",
                    values = {"up", "down", "left", "right"};
                    setting = "groupDirection",
                    hasToggle = name ~= "Default Anchor",
                },
                {
                    title = "Timer Direction",
                    type = "dropDownSelector",
                    tooltipText = "Sets the direction new timers are added to a group.",
                    values = {"up", "down", "left", "right"};
                    setting = "timerDirection",
                    hasToggle = name ~= "Default Anchor",
                },
                "BREAK",
            },
            {
                {
                    title = "Max Num Groups",
                    type = "slider",
                    tooltipText = "Sets the maximum number of displayable groups.  Zero means no restriction.",
                    minValue = 0, 
                    maxValue = 10,
                    valueStep = 1,
                    setting = "maxNumGroups",
                    hasToggle = name ~= "Default Anchor",
                },
                {
                    title = "Group Spacing",
                    type = "slider",
                    tooltipText = "Sets the amount of space between groups.",
                    minValue = 0, 
                    maxValue = 20,
                    valueStep = 1,
                    setting = "groupSpacing",
                    hasToggle = name ~= "Default Anchor",
                },
                {
                    title = "Timer Spacing",
                    type = "slider",
                    tooltipText = "Sets the amount of space between timers.",
                    minValue = 0, 
                    maxValue = 10,
                    valueStep = 1,
                    setting = "timerSpacing",
                    hasToggle = name ~= "Default Anchor",
                },
            },
        },
        {
            subTitle = "Visibility",
            description = "These settings control the visibility of the anchor under various conditions.",
            showBorder = true,
            padding = 15,
            {
                {
                    title = "No Combat Alpha",
                    type = "slider",
                    tooltipText = "Sets the alpha of the anchor while out of combat.",
                    minValue = 0, 
                    maxValue = 1,
                    valueStep = .05,
                    setting = "standardAlpha",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
                {
                    title = "Combat Alpha",
                    type = "slider",
                    tooltipText = "Sets the alpha of the anchor while in combat.",
                    minValue = 0, 
                    maxValue = 1,
                    valueStep = .05,
                    setting = "combatAlpha",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
            {
                {
                    title = "Mouseover Alpha",
                    type = "slider",
                    tooltipText = "Sets the alpha of the anchor while mousing over its groups.",
                    minValue = 0, 
                    maxValue = 1,
                    valueStep = .05,
                    setting = "mouseoverAlpha",
                    hasToggle = name ~= "Default Anchor",
                    notSimple = true,
                },
            },
        },
        {
            subTitle = "Anchoring",
            description = "These settings control how the anchor is anchored to your interface.  Note that, in some cases, parts of the anchor (generally the group names) may not be included in the anchor's total width or height.",
            showBorder = true,
            padding = 15,
            { -- column 1
                { -- row
                    {
                        title = "Anchor Point",
                        type = "dropDownSelector",
                        tooltipText = "Sets the point that will be anchored.",
                        values = {"TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT", "CENTER"};
                        setting = "anchorPoint",
                        hasToggle = name ~= "Default Anchor",
                        notSimple = true,
                    },
                    {
                        title = "Relative Point",
                        type = "dropDownSelector",
                        tooltipText = "Sets the point to be anchored to.",
                        values = {"TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT", "CENTER"};
                        setting = "relativePoint",
                        hasToggle = name ~= "Default Anchor",
                        notSimple = true,
                    },
                    {
                        title = "Relative To",
                        type = "editBoxString",
                        tooltipText = "Sets the frame to be anchored to.  If you want to anchor to another anchor, type \"anchor: anchorName\", without quotes.",
                        hasToggle = name ~= "Default Anchor",
                        setting = "relativeTo",
                        notSimple = true,
                        scripts = {
                            OnEditFocusGained = function(self) self:SetText(self.Get( "relativeTo" )); self:HighlightText() end,
                            OnEnterPressed = function(self) 
                                local text = self:GetText();
                                TimerLib:Set( "anchorSettings", name, "relativeTo", text );
                                self:ClearFocus();
                                if self.toggle then self.toggle:SetChecked(true); end
                            end,
                        },
                    },
                },
                {
                    {
                        title = "X Offset",
                        type = "editBoxString",
                        tooltipText = "Sets the X offset of the anchoring.",
                        hasToggle = name ~= "Default Anchor",
                        setting = "positionX",
                        notSimple = true,
                        scripts = {
                            OnEditFocusGained = function(self) self:SetText(self.Get( "positionX" )); self:HighlightText() end,
                            OnEnterPressed = function(self) 
                                local text = self:GetText();
                                TimerLib:Set( "anchorSettings", name, "positionX", tonumber(text) );
                                self:ClearFocus();
                                if self.toggle then self.toggle:SetChecked(true); end
                            end,
                        },
                    },
                    {
                        title = "Y Offset",
                        type = "editBoxString",
                        tooltipText = "Sets the Y offset of the anchoring.",
                        hasToggle = name ~= "Default Anchor",
                        setting = "positionY",
                        notSimple = true,
                        scripts = {
                            OnEditFocusGained = function(self) self:SetText(self.Get( "positionY" )); self:HighlightText() end,
                            OnEnterPressed = function(self) 
                                local text = self:GetText();
                                TimerLib:Set( "anchorSettings", name, "positionY", tonumber(text) );
                                self:ClearFocus();
                                if self.toggle then self.toggle:SetChecked(true); end
                            end,
                        },
                    },
                },
            },
        },
    };
    
    if not AsheylaLib:InSimpleMode() then
        local newButton;
        if name == "Default Anchor" then
            newButton = {
                title = "Make New Anchor!",
                type = "editBoxString",
                tooltipText = "Type in the name of a new anchor to be customized.",
                scripts = {
                    OnEditFocusGained = function(self) self:SetText(""); self:HighlightText() end,
                    OnEnterPressed = function(self) 
                        local text = self:GetText();
                        if not TimerLib:Get("anchorSettings", text) then
                            TimerLib:Set("anchorSettings", text, {});
                        end
                        GUILib:ShowPanel(SECTION_NAME, text == "Default Anchor" and "main" or text);
                        self:ClearFocus();
                    end,
                },
            };
        else
            if not blacklist[name] then
                newButton = {
                    title = "Delete",
                    type = "button",
                    tooltipText = "Deletes this anchor.  If a timer is added to an anchor that doesn't exist, the anchor will be recreated.",
                    func = function() 
                        local frame = StaticPopup_Show("TIMERLIBANCHOR", name)
                        frame.data = name;
                    end,
                };
            end
        end
        optionsTable[1][1][1] = {optionsTable[1][1][1], newButton};
        if sharedMedia() then
            table.insert(optionsTable[3][1], 4, {
                title = "Font",
                type = "dropDownSelector",
                tooltipText = "Sets the font of any text in the timer.",
                values = sharedMedia():List("font");
                setting = "font",
                hasToggle = name ~= "Default Anchor",
            });
        end
    end
    
    local defaultFunc = function()
        TimerLib:Set("anchorSettings", name, {});
        InterfaceOptionsFrame:Hide(); GUILib:ShowPanel(SECTION_NAME, name == "Default Anchor" and "main" or name);
    end
    
    local getFunc = function(...)
        local val = TimerLib:Get("anchorSettings", name, ...);
        local isReal = val ~= nil;
        if val == nil then
            val = TimerLib:Get("anchorSettings", "Default Anchor", ...);
        end
        return val, isReal;
    end
    
    local setFunc = function(...)
        TimerLib:Set("anchorSettings", name, ...);
    end
    
    local highlight = not blacklist[name];
    local toggleTooltip = "If this checkbutton is unchecked, the setting does not apply and a default value will be used instead.  The default value will be found by looking at Default Anchor.";
    if AsheylaLib:InSimpleMode() then
        optionsTable[1].description = "Anchors are locations on the screen to which timers are added, organized in groups.  DoTimer and Cooldowns each have their own anchor where their timers are added.";
    end
    
    GUILib:SetGUIPanel(SECTION_NAME, name == "Default Anchor" and "main" or name, TimerLib, optionsTable, {default = defaultFunc, get = getFunc, set = setFunc, toggleTooltip = toggleTooltip, allSimple = true, highlight = highlight});
end

StaticPopupDialogs["TIMERLIBANCHOR"] = {
    text = "You are about to delete the anchor |cff00ff00%s|r.  Do you wish to proceed?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, name) 
        TimerLib:Set("anchorSettings", name, nil);
        GUILib:ShowPanel(SECTION_NAME, "main");
    end,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
}

local existing = {};
local function createAnchorGUI()
    table.wipe(existing);
    local cats = INTERFACEOPTIONS_ADDONCATEGORIES;
    local parent;
    for i = #cats, 1, -1 do
        if cats[i].parent == SECTION_NAME then
            if TimerLib:Get("anchorSettings", cats[i].name) then
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
        if not existing[SECTION_NAME] then createGUI("Default Anchor"); end
    else
        if not existing[SECTION_NAME] then createGUI("Default Anchor"); end
        if not existing["DoTimer Anchor"] then createGUI("DoTimer Anchor"); end
        if not existing["DoTimer Mouseover"] then createGUI("DoTimer Mouseover"); end
        if not existing["Cooldowns Anchor"] then createGUI("Cooldowns Anchor"); end
        if not existing["PlayerAuras Anchor"] then createGUI("PlayerAuras Anchor"); end
        if not existing["Notifications Anchor"] then createGUI("Notifications Anchor"); end
        for name in alphabetize(TimerLib:Get("anchorSettings")) do
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
createAnchorGUI();
GUILib:AddGUICreationScript(createAnchorGUI);
GUILib:AddProfileChangeScript(createAnchorGUI);
TimerLib:AddSettingsUpdateScript(createAnchorGUI);
