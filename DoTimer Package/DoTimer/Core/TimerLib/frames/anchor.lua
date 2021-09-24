AsheylaLib:Package( "TimerLib" );
--[[
    AnchorFrameManager class
    
    Should be created with an anchor object and never destroyed.
--]]

-- the order in which the constructor expects the fields
local order = {
    "anchor"
};

local fields = {
    anchor = Class.READONLY,    -- table        the anchor that owns this manager
    
    -- the below are not arguments externally, but are instead populated later
    
    frame = Class.READONLY,     -- table        the frame that the anchor is rendered in
};

local externalFuncs = {
    AddChild = true,        -- group            sets the group frame's parent to this anchor frame
    RemoveChild = true,     -- group            removes the group frame's parent
    Resize = true,          -- groups, reanchor resizes the anchor, reanchors the groups if specified
    DrawFrame = true,       -- <none>           does the main work for rendering the frame
    UpdateToCursor = true,  -- <none>           updates the anchor's position to the mouse cursor
    SetFrameAlpha = true,   -- alpha            sets the frame's alpha
    StartMoving = true,     -- <none>           makes the anchor start moving
    StopMoving = true,      -- <none>           makes the anchor stop moving
    UpdateShown = true,     -- <none>           hides or shows the frame
    UpdateAlpha = true,     -- <none>           updates the anchor alpha, returns new value
    
    Destruct = function( self )             --  this object should never be destroyed
        error( "Attempt to destroy an AnchorFrameManager" );
    end,
};

local persistent = {};

local getPosition;

-- grab local copies of globals
local max = math.max;
local find = string.find;
local match = string.match;
local UIParent = UIParent;
local CreateFrame = CreateFrame;
local getglobal = getglobal;
local print = print;
local GetTime = GetTime;
local UnitAffectingCombat = UnitAffectingCombat;

-- map from external objects to their internal data
local internal;

local internalFuncs = {
    AddChild = function( self, group )
        group.frame:SetParent( self.frame );
    end,
    
    RemoveChild = function( self, group )
        group.frame:SetParent( nil );
    end,
    
    UpdateAlpha = function( self )
        local alpha;
        local anchor = self.anchor;
        if self.frame:IsMouseOver() then
            alpha = anchor:Get("mouseoverAlpha");
        else
            alpha = UnitAffectingCombat("player") and anchor:Get("combatAlpha") or anchor:Get("standardAlpha");
        end
        self.frame:SetAlpha( alpha );
        return alpha;
    end,
    
    UpdateShown = function( self )
        if not self.anchor:IsShown() then
           self:SetSize( 1, 1 );
        end
    end,
    
    SetSize = function( self, width, height )
        self.frame:SetSize( width, height );
        self.frame.anchorFrame:SetSize( width / self.frame:GetScale(), height / self.frame:GetScale() );
    end,
    
    StartMoving = function( self )
        local frame = self.frame.anchorFrame;
        self.oldX, self.oldY = getPosition( frame, self.anchor:Get( "anchorPoint" ) );
        if frame:IsMovable() then frame:StartMoving(); end
    end,
    
    StopMoving = function( self )
        local anchor = self.anchor;
        local frame = self.frame.anchorFrame;
        if frame:IsMovable() then
            frame:StopMovingOrSizing();
            local x, y = getPosition( frame, self.anchor:Get( "anchorPoint" ) );
            --[[local centering = anchor:Get("centering");
            if centering ~= "none" then
                local scale = self.frame:GetScale();
                local width, height = self.frame:GetWidth() * scale, self.frame:GetHeight() * scale;
                local point = self.ref1;
                local hMod, vMod = .5, .5;
                if (find(point, "TOP")) then vMod = -.5; end
                if (find(point, "RIGHT")) then hMod = -.5; end
                if not (point == "LEFT" or point == "RIGHT" or point == "BOTTOM" or point == "TOP") then
                    if centering == "vertical" then
                        y = y + (vMod * height);
                    elseif centering == "horizontal" then
                        x = x + (hMod * width);
                    end
                end
            end
            local expectedScale = anchor:Get("expectedScale");
            local scaling = expectedScale / UIParent:GetScale();
            anchor:Set("anchorPoint", "TOPLEFT");
            anchor:Set("relativePoint", "BOTTOMLEFT");
            anchor:Set("relativeTo", "UIParent");
            anchor:Set("positionX", x / scaling);
            anchor:Set("positionY", y / scaling);--]]
            local expectedScale = anchor:Get("expectedScale");
            local scaling = expectedScale / UIParent:GetScale();
            local delX = (x - self.oldX) / scaling;
            local delY = (y - self.oldY) / scaling;
            anchor:Set( "positionX", anchor:Get( "positionX" ) + delX );
            anchor:Set( "positionY", anchor:Get( "positionY" ) + delY );
        end
    end,
    
    CalculateAnchors = function( self )
        local anchor = self.anchor;
        local ref1, ref2;
        local dir = anchor:Get("groupDirection");
        local timerDir = anchor:Get("timerDirection");
        local overflowDir = anchor:Get("overflowDirection");
        local justify = anchor:Get("timerJustification");
        local spacing = anchor:Get("groupSpacing");
        local centering = anchor:Get("centering");
        local x, y;
        if dir == "down" then
            ref1, ref2 = "TOPLEFT", "BOTTOMLEFT";
            if timerDir == "left" or overflowDir == "left" or justify == "right" then
                ref1, ref2 = "TOPRIGHT", "BOTTOMRIGHT";
            end
            if centering == "horizontal" then
                ref1, ref2 = "TOP", "BOTTOM";
            end
            x, y = 0, -spacing;
        elseif dir == "up" then
            ref1, ref2 = "BOTTOMLEFT", "TOPLEFT";
            if timerDir == "left" or overflowDir == "left" or justify == "right" then
                ref1, ref2 = "BOTTOMRIGHT", "TOPRIGHT";
            end
            if centering == "horizontal" then
                ref1, ref2 = "BOTTOM", "TOP";
            end
            x, y = 0, spacing;
        elseif dir == "left" then
            ref1, ref2 = "TOPRIGHT", "TOPLEFT";
            if timerDir == "up" or overflowDir == "up" or justify == "buttom" then
                ref1, ref2 = "BOTTOMRIGHT", "BOTTOMLEFT";
            end
            if centering == "vertical" then
                ref1, ref2 = "RIGHT", "LEFT";
            end
            x, y = -spacing, 0;
        elseif dir == "right" then
            ref1, ref2 = "TOPLEFT", "TOPRIGHT";
            if timerDir == "up" or overflowDir == "up" or justify == "bottom" then
                ref1, ref2 = "BOTTOMLEFT", "BOTTOMRIGHT";
            end
            if centering == "vertical" then
                ref1, ref2 = "LEFT", "RIGHT";
            end
            x, y = spacing, 0;
        end
        
        self.ref1, self.ref2, self.x, self.y = ref1, ref2, x, y;
    end,
    
    Resize = function( self, groups, reanchor )
        if self.anchor:IsShown() then
            local anchor = self.anchor;
            local dir = anchor:Get("groupDirection");
            local spacing = anchor:Get("groupSpacing");
            local width, height = 0, 0;
            
            local first = 1;
            while (first <= #groups and not groups[first]:IsShown()) do
                first = first + 1;
            end
            if first <= #groups then
                local maxNum = anchor:Get("maxNumGroups");
                if maxNum > 0 then
                    maxNum = maxNum + first - 1;
                end
                local lastGroup;
                for i = first, #groups do
                    local group = groups[ i ];
                    local frame = group.frame;
                    
                    if reanchor then
                        if i == first then
                            frame:ClearAllPoints();
                            frame:SetPoint(self.ref1, self.frame, self.ref1);
                        else
                            if (i <= maxNum or maxNum == 0) then
                                group.hiddenByAnchor = false;
                                frame:ClearAllPoints();
                                frame:SetPoint(self.ref1, lastGroup.frame, self.ref2, self.x, self.y);
                            else
                                group.hiddenByAnchor = true;
                            end
                        end
                    end
                    
                    if not group.hiddenByAnchor then
                        if (dir == "up" or dir == "down") then
                            width = max(width, frame:GetWidth());
                            height = height + frame:GetHeight() + (i == first and 0 or spacing);
                        else
                            width = width + frame:GetWidth() + (i == first and 0 or spacing);
                            height = max(height, frame:GetHeight());
                        end
                    end
                    
                    lastGroup = group;
                end
            end
            
            width = max( width, 1 );
            height = max( height, 1 );
            
            self:SetSize( width, height );
        end
    end,
    
    --[[
    Center = function( self, groups )
        local anchor = self.anchor;
        local scale = self.frame:GetScale();
        local width, height = self.frame:GetWidth() * scale, self.frame:GetHeight() * scale;
        local centering = anchor:Get("centering");
        local f = self.frame.anchorFrame;
        if #groups > 0 then
            local point = self.ref1;
            local hMod, vMod = .5, .5;
            if (string.find(point, "BOTTOM")) then vMod = -.5; end
            if (string.find(point, "LEFT")) then hMod = -.5; end
            
            local x, y, scaling = anchor:Get("positionX"), anchor:Get("positionY"), anchor:Get("expectedScale");
            scaling = scaling / UIParent:GetScale();
            if x and y then
                x, y = x * scaling, y * scaling;
            else
                x, y = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2;
            end
            if not (point == "LEFT" or point == "RIGHT" or point == "BOTTOM" or point == "TOP") then
                if centering == "vertical" then
                    y = y + (vMod * height);
                elseif centering == "horizontal" then
                    x = x + (hMod * width);
                end
            end
            f:ClearAllPoints();
            f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);
        end
    end,--]]
    
    SetFrameAlpha = function( self, alpha )
        self.frame:SetAlpha( alpha );
    end,
    
    DrawFrame = function( self )
        local anchor = self.anchor;
        local f = self.frame;
        local a = f.anchorFrame;
        a:SetMovable(not anchor:Get("locked"));
        a:ClearAllPoints();
        local expectedScale = anchor:Get("expectedScale");
        if not expectedScale then
            anchor:Set("expectedScale", UIParent:GetScale());
            expectedScale = UIParent:GetScale();
        end
        local scaling = expectedScale / UIParent:GetScale();
        
        f:SetScale(anchor:Get("scale") * scaling);
        self:UpdateShown();
        self:CalculateAnchors();
        f:SetPoint( self.ref1, a );
        if self.anchorsToCursor then
            self:UpdateAnchorToCursor();
        else
            local anchorPoint, relativePoint = anchor:Get("anchorPoint"), anchor:Get("relativePoint");
            local relativeTo = anchor:Get("relativeTo");
            local anchorTo = match( relativeTo, "anchor: ?(.+)" );
            if anchorTo then
                if TimerLib:Get("anchorSettings", anchorTo ) then
                    relativeTo = TimerLib:GetAnchor(anchorTo).frame;
                else
                    relativeTo = UIParent;
                end
            else
                relativeTo = getglobal( relativeTo ) or UIParent;
                relativeTo = relativeTo[0] and relativeTo or UIParent;
            end
            local x, y = anchor:Get("positionX"), anchor:Get("positionY");
            a:SetPoint(anchorPoint, relativeTo, relativePoint, x * scaling, y * scaling);
        end
    end,
    
    UpdateToCursor = function( self )
        local x, y = GetCursorPosition();
        local scale = UIParent:GetScale();
        x, y = (x + self.anchor:Get( "positionX" )) / scale, (y + self.anchor:Get( "positionY" )) / scale;
        self.frame.anchorFrame:ClearAllPoints();
        self.frame.anchorFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
    end,
};

local funcs = {
    TOPLEFT = function( f ) return f:GetLeft(), f:GetTop() end,
    TOP = function( f ) return (f:GetLeft()+f:GetRight()) / 2, f:GetTop() end,
    TOPRIGHT = function( f ) return f:GetRight(), f:GetTop() end,
    RIGHT = function( f ) return f:GetRight(), (f:GetBottom()+f:GetTop()) / 2 end,
    BOTTOMRIGHT = function( f ) return f:GetRight(), f:GetBottom() end,
    BOTTOM = function( f ) return (f:GetLeft()+f:GetRight()) / 2, f:GetBottom() end,
    BOTTOMLEFT = function( f ) return f:GetLeft(), f:GetBottom() end,
    LEFT = function( f ) return f:GetLeft(), (f:GetBottom()+f:GetTop()) / 2 end,
    CENTER = function( f ) return (f:GetLeft()+f:GetRight()) / 2, (f:GetBottom()+f:GetTop()) / 2 end,
};
function getPosition( frame, point )
    return funcs[ point ]( frame );
end

local onUpdateFunc = function(self)
    if not self.mainFrame:IsMouseOver() then
        self.mainFrame:EnableMouse(true);
        self.anchor:CallScript( "UpdateAlpha" );
        self:SetScript("OnUpdate", nil);
    end
end

local onEnterFunc = function(self)
    self:EnableMouse(false);
    self.anchor:CallScript( "UpdateAlpha" );
    self.anchorFrame:SetScript("OnUpdate", onUpdateFunc);
end

local function acquireAnchorFrame( anchor )
    local a = CreateFrame("Frame", nil, UIParent, "TimerLibAnchorFrameAnchorTemplate");
    sanitize( a );
    local f = CreateFrame("Frame", nil, a, "TimerLibAnchorFrameTemplate");
    sanitize( f );
    f.elapsed = 0;
    f.anchor = anchor;
    a.anchor = anchor;
    f.anchorFrame = a;
    a.mainFrame = f;
    
    a:RegisterEvent("PLAYER_REGEN_ENABLED");
    a:RegisterEvent("PLAYER_REGEN_DISABLED");
    a:SetScript("OnEvent", function(self) anchor:CallScript( "UpdateAlpha" ); end);
    f:EnableMouse( true );
    f:SetScript( "OnEnter", onEnterFunc );
    
    if drawingBackground then
        local t=a:CreateTexture();
        t:SetAllPoints(true);
        t:SetTexture(1, 0, 0, .5);
    end
    
    return f;
end

AnchorFrameManager, internal = Class( "AnchorFrameManager", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = AnchorFrameManager.new;
AnchorFrameManager.new = function( anchor )
    local t = oldNew();
    local int = internal[ t ];
    local frame = acquireAnchorFrame( anchor );
    int.fields.frame = frame;
    
    int.fields.anchor = anchor;
    
    return t;
end

