AsheylaLib:Package( "KBLib" );
--[[
    KBLib class
--]]

-- the order in which the constructor expects the fields
local order = {
    "module"
};

local fields = {
    module = Class.READONLY,    -- table            which settings to use
};

local externalFuncs = {
    ProcessClick = true,    -- group, button,...    processes a click of <button> for <group>
    SetClickAction = true,  -- group, action, func  sets what function should be called for <action> in <group>
    KBDropDown = true,      -- <none>               creates a dropdown menu for changing keybindings
    GetKeyBinding = true,   -- group, action        returns a human-readable string for that key binding
    
    Destruct = function( self )                 --  this object should never be destroyed
        error( "Attempt to destroy a KBLib" );
    end,
};

local persistent = {}

local getModifierState, subFunc;

-- grab local copies of globals
local gsub = string.gsub;
local match = string.match;
local pairs = pairs;
local IsShiftKeyDown = IsShiftKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local IsAltKeyDown = IsAltKeyDown;

-- map from external objects to their internal data
local internal;

local internalFuncs = {
    ProcessClick = function( self, group, button, ... )
        local module = self.module;
        local potentials = module:Get( "keybindings", group );
        if potentials then
            local num;
            if button == "LeftButton" then num = "1";
            elseif button == "RightButton" then num = "2";
            elseif button == "MiddleButton" then num = "3";
            else num = match(button, "(%d+)");
            end
            if not num then return end
            
            local modifierState = getModifierState();
            for i,v in pairs(potentials) do
                local modifiers, mouse = match(v, "(.-)-?(%d+)$");
                if mouse == num and modifiers == modifierState then 
                    self:PerformClickAction(group, i, ...);
                    break;
                end
            end
        end
    end,
    
    SetClickAction = function( self, group, action, func )
        self.actions[ group ] = self.actions[ group ] or {};
        self.actions[ group ][ action ] = func;
    end,
    
    PerformClickAction = function( self, group, action, ... )
        if self.actions[ group ] and self.actions[ group ][ action ] then
            self.actions[ group ][ action ]( ... );
        end
    end,
    
    GetKeyBinding = function( self, group, action )
        local kb = self.module:Get("keybindings",group,action) or "";
        kb = gsub(kb, "%a%-", subFunc);
        kb = gsub(kb, "%d", subFunc);
        return kb;
    end,
    
    KBDropDown = function( self )
        local module = self.module;
        local LEVEL = UIDROPDOWNMENU_MENU_LEVEL;
        local count = 0;
        local soleGroup;
        for n in pairs(module:Get("keybindings")) do
            count = count + 1;
            soleGroup = n;
        end
        if count == 1 then
            LEVEL = LEVEL + 1;
        else
            soleGroup = nil;
        end
        
        local info
        if LEVEL == 3 then
            local groupandaction = UIDROPDOWNMENU_MENU_VALUE;
            local group = groupandaction[ 1 ];
            local action = groupandaction[ 2 ];
            
            info = UIDropDownMenu_CreateInfo()
            info.text = "Current Keybinding"
            info.notCheckable = 1
            info.isTitle = 1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            
            info = UIDropDownMenu_CreateInfo()
            info.text = self:GetKeyBinding(group,action)
            info.notClickable = 1
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            
            info = UIDropDownMenu_CreateInfo()
            info.text = ""
            info.notClickable = 1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            
            info = UIDropDownMenu_CreateInfo()
            info.text = "Click to Change"
            info.tooltipTitle = "Note"
            info.tooltipText = "The mouse button you click with, as well as the modifiers you press, will determine the new binding."
            info.value = "KBLIB"
            info.arg1 = self
            info.arg2 = groupandaction;
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            
            local i = 1;
            local str = "DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button";
            local f = getglobal(str .. i);
            while f do
                f:RegisterForClicks("AnyUp");
                i = i + 1;
                f = getglobal(str .. i);
            end
        elseif LEVEL == 2 then
            local group = soleGroup or UIDROPDOWNMENU_MENU_VALUE
            local actions = module:Get("keybindings",group)
            for action in pairs(actions) do
                info = UIDropDownMenu_CreateInfo()
                info.text = action
                info.value = { group, action };
                info.hasArrow = 1
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        elseif LEVEL == 1 then
            local groups = module:Get("keybindings")
            for i,v in pairs(groups) do
                info = UIDropDownMenu_CreateInfo()
                info.notCheckable = 1
                info.text = i
                info.value = i
                info.hasArrow = 1
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        end
    end,
};

local states = {
    [0] = "",
    [4] = "s",
    [2] = "c",
    [1] = "a",
    [6] = "s-c",
    [5] = "s-a",
    [3] = "c-a",
    [7] = "s-c-a",
}
function getModifierState()
    return states[ (IsShiftKeyDown() and 4 or 0) + (IsControlKeyDown() and 2 or 0) + (IsAltKeyDown() and 1 or 0) ];
end

subFunc = function(a)
    if a == "s-" then return "Shift-"; end
    if a == "c-" then return "Control-"; end
    if a == "a-" then return "Alt-"; end
    if a == "1" then return "Left Click"; end
    if a == "2" then return "Right Click"; end
    if a == "3" then return "Middle Click"; end
    return "Mouse " .. a;
end

hooksecurefunc("UIDropDownMenuButton_OnClick", function(frame, button)
    if frame.value == "KBLIB" then
        local self = frame.arg1;
        local module = self.module;
        local group = frame.arg2[ 1 ];
        local action = frame.arg2[ 2 ];
        local mouse = button == "LeftButton" and 1 or 
            button == "RightButton" and 2 or 
            button == "MiddleButton" and 3 or 
            tonumber(string.match(button, "(%d+)"));
        
        local str = ""
        if IsShiftKeyDown() then str = str.."s-" end
        if IsControlKeyDown() then str = str.."c-" end
        if IsAltKeyDown() then str = str.."a-" end
        str = str..mouse
        local otheractions = module:Get("keybindings",group)
        for act,kb in pairs(otheractions) do
            if not (action == act) then
                if kb == str then
                    module:HeaderPrint("Unable to set keybinding (another action is already using it).")
                    return
                end
            end
        end
        module:Set("keybindings", group, action, str)
        module:HeaderPrint( "Keybinding for ", group, "'s ", action, " successfully set to ", self:GetKeyBinding( group, action ) );
        CloseDropDownMenus();
    end
end);

KBLib, internal = Class( "KBLib", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = KBLib.new;
KBLib.new = function( module )
    local t, fresh = oldNew( module );
    local int = internal[ t ];
    if ( fresh ) then
        int.actions = {};
    end
    
    if not module:GetDefault( "keybindings" ) then
        module:AddDefaultSettings( {
            keybindings = {};
        } );
    end
    
    return t;
end

