AsheylaLib:Package( "TimerLib" );
--[[
    GroupFrameManager class
    
    Should be created with a group object and never destroyed.
--]]

-- the order in which the constructor expects the fields
local order = {
    "group"
};

local fields = {
    group = Class.READONLY,     -- table        the group that owns this manager
    
    -- the below are not arguments externally, but are instead populated later
    
    frame = Class.READONLY,     -- table        the frame that the group is rendered in
};

local externalFuncs = {
    GroupDone = true,       -- <none>           hides the frame, other cleanup stuff
    AddChild = true,        -- timer            sets the timer frame's parent to this group frame
    RemoveChild = true,     -- timer            removes the timer frame's parent
    Resize = true,          -- timers, reanchor resizes the group, reanchors the timers if specified
    DrawFrame = true,       -- <none>           does the heavy lifting for rendering the group    
    UpdateShown = true,     -- <none>           hides or shows the frame
    UpdateData = true,      -- <none>           updates the data of the group
    
    Destruct = function( self )             --  this object should never be destroyed
        error( "Attempt to destroy a GroupFrameManager" );
    end,
};

local persistent = {
    group = true,
    frame = true,
};

local subFunc, subGroup;

-- grab local copies of globals
local fmod = math.fmod;
local max = math.max;
local format = string.format;
local gsub = gsub;
local pairs = pairs;
local CreateFrame = CreateFrame;
local SetRaidTargetIconTexture = SetRaidTargetIconTexture;
local type = type;
local tostring = tostring;

-- map from external objects to their internal data
local internal;

local oldDestruct;
local internalFuncs = {
    UpdateData = function( self, noresize )
        local frame = self.frame;
        local group = self.group;
        subGroup = group;
        local text = gsub(group:Get( "nameFormat" ), "(%%%a)", subFunc):trim();
        
        local displayNames = group:Get("displayNames");
        local displayIcons = group:Get("displayIcons");
        frame.Name.Text:SetText(displayNames and text or "");
        frame.Name:SetWidth(max(displayNames and frame.Name.Text:GetStringWidth() or 1, 
            (displayIcons and group.icon) and frame.Name.Icon:GetWidth() or 1));
        frame.Name:SetHeight(max(displayNames and frame.Name.Text:GetStringHeight() or 1, 
            (displayIcons and group.icon) and frame.Name.Icon:GetHeight() or 1));
        SetRaidTargetIconTexture(frame.Name.Icon, displayIcons and group.icon or 0);
        
        if not noresize then
            self:Resize();
        end
    end,
    
    GroupDone = function( self, anchor )
        self.frame:Hide();
        if self.frame.beingDragged then
            anchor:CallScript( "StopMoving" );
        end
        self.frame.beingDragged = false;
        if self.frame.mouseIsOver then
            anchor:CallScript( "UpdateAlpha" );
        end
        self.frame.mouseIsOver = false;
        oldDestruct( self, true );
    end,
    
    AddChild = function( self, timer )
        timer.frame:SetParent( self.frame );
    end,
    
    RemoveChild = function( self, timer )
        timer.frame:SetParent( nil );
    end,
    
    UpdateShown = function( self )
        if self.group:IsShown() then
            self.frame:Show();
        else
            self.frame:Hide();
        end
    end,
    
    Resize = function( self, timers, reanchor )
        local group = self.group;
        
        if group:IsShown() then
            local groupDirection = group:Get("groupDirection");
            local horizGroups = (groupDirection == "left" or groupDirection == "right");
            local moveName = group:Get("moveName") or horizGroups;
            local showingName = group:Get("displayNames") or (group:Get("displayIcons") and group.icon);
            local timerAnchor = self.frame.TimerAnchor;
            
            if timers then
                local dir = group:Get("timerDirection");
                local overflowDir = group:Get("overflowDirection");
                local spacing = group:Get("timerSpacing");
                local overflowPoint = group:Get("overflowPoint");
                local justify = group:Get("timerJustification");
                local ref1, ref2, offset;
                
                if reanchor then
                    if dir == "up" then
                        ref1, ref2 = "BOTTOMLEFT", "TOPLEFT";
                        if overflowDir == "left" or justify == "right" then
                            ref1, ref2 = "BOTTOMRIGHT", "TOPRIGHT";
                        end
                        offset = spacing;
                    elseif dir == "down" then
                        ref1, ref2 = "TOPLEFT", "BOTTOMLEFT";
                        if overflowDir == "left" or justify == "right" then
                            ref1, ref2 = "TOPRIGHT", "BOTTOMRIGHT";
                        end
                        offset = -spacing;
                    elseif dir == "left" then
                        ref1, ref2 = "TOPRIGHT", "TOPLEFT";
                        if overflowDir == "up" or justify == "bottom" then
                            ref1, ref2 = "BOTTOMRIGHT", "BOTTOMLEFT";
                        end
                        offset = -spacing;
                    elseif dir == "right" then
                        ref1, ref2 = "TOPLEFT", "TOPRIGHT";
                        if overflowDir == "up" or justify == "bottom" then
                            ref1, ref2 = "BOTTOMLEFT", "BOTTOMRIGHT";
                        end
                        offset = spacing;
                    end
                end
                
                local totalWidth, totalHeight, width, height = 0, 0, 0, 0;
                local lastFrame;
                local num = #timers;
                for i = 1, num do
                    if not timers[i]:IsShown() then
                        num = i - 1;
                        break;
                    end
                end
                for i = 1, num do
                    local timer = timers[ i ];
                    
                    local frame = timer.frame;
                    local mod = fmod(i, overflowPoint);
                    
                    if (overflowPoint > 0 and mod == 1) or (overflowPoint == 0 and i == 1) or 
                        (overflowPoint == 1) then
                        if reanchor then
                            local x, y = 0, 0;
                            x = overflowDir == "left" and -totalWidth or overflowDir == "right" and totalWidth or x;
                            y = overflowDir == "up" and totalHeight or overflowDir == "down" and -totalHeight or y;
                            frame:ClearAllPoints();
                            frame:SetPoint(ref1, self.frame.TimerAnchor, ref1, x, y);
                        end
                        width = frame:GetWidth();
                        height = frame:GetHeight();
                    elseif dir == "up" or dir == "down" then
                        if reanchor then
                            frame:ClearAllPoints();
                            frame:SetPoint(ref1, lastFrame, ref2, 0, offset);
                        end
                        width = max(width, frame:GetWidth());
                        height = height + frame:GetHeight() + spacing;
                    elseif dir == "left" or dir == "right" then
                        if reanchor then
                            frame:ClearAllPoints();
                            frame:SetPoint(ref1, lastFrame, ref2, offset, 0);
                        end
                        width = width + frame:GetWidth() + spacing;
                        height = max(height, frame:GetHeight());
                    end
                    lastFrame = frame;
                    
                    if (overflowPoint > 0 and mod == 0) or (i == num) then
                        if overflowDir == "left" or overflowDir == "right" then
                            totalWidth = totalWidth + width + (i == num and 0 or spacing);
                            totalHeight = max(totalHeight, height);
                        else
                            totalWidth = max(totalWidth, width);
                            totalHeight = totalHeight + height + (i == num and 0 or spacing);
                        end
                    end
                end
                
                timerAnchor:SetWidth(totalWidth);
                timerAnchor:SetHeight(totalHeight);
            end
            
            local name = self.frame.Name;
            local oldW, oldH = self.frame:GetSize();
            self.frame:SetWidth(max(timerAnchor:GetWidth() + self.nameX, 
                showingName and horizGroups and (name:GetWidth() * name:GetScale()) or 0));
            self.frame:SetHeight(max(timerAnchor:GetHeight() + self.nameY, 
                showingName and (not moveName) and (name:GetHeight() * name:GetScale()) or 0));
            if self.frame:GetWidth() ~= oldW or self.frame:GetHeight() ~= oldH then
                group.anchor:GroupUpdated( group, "size" );
            end
        end
    end,
    
    DrawFrame = function( self )
        local frame = self.frame;
        local group = self.group;
        
        self:UpdateData( true );
        
        local font;
        if sharedMedia() then
            font = sharedMedia():Fetch("font", group:Get("font"));
        else
            font = GameFontNormal:GetFont();
        end
        local fontHeight = group:Get("nameFontHeight");
        frame.Name.Text:SetFont(font, fontHeight);
        local color = group:Get("nameTextColor");
        frame.Name.Text:SetTextColor(color.r, color.g, color.b);
        frame.Name:EnableMouse(group:Get("interactable") and group.anchor.frame.anchorFrame:IsMovable());
        
        local timerAnchor = frame.TimerAnchor;
        local name = frame.Name;
        name:ClearAllPoints();
        timerAnchor:ClearAllPoints();
        local width, height;
        
        local timerDirection = group:Get("timerDirection");
        local groupDirection = group:Get("groupDirection");
        local justify = group:Get("timerJustification");
        
        local horizGroups = (groupDirection == "left" or groupDirection == "right");
        local moveName = group:Get("moveName") or horizGroups;
        local showingName = group:Get("displayNames") or (group:Get("displayIcons") and group.icon);
        local ref1, ref2, obj, ref3, ref4, x1, y1, x2, y2;
        local nameX, nameY = 0, 0;
        local nS = group:Get("nameSpacing");
        if timerDirection == "up" then
            if showingName then
                if moveName then
                    if groupDirection == "left" or groupDirection == "right" then
                        ref1, obj, ref2, x1, y1 = "BOTTOM", frame, "BOTTOM", 0, 0;
                        ref3, ref4, x2, y2 = "TOP", "BOTTOM", 0, -nS;
                    else
                        ref1, obj, ref2, x1, y1 = "BOTTOM", name, "TOP", 0, nS;
                        ref3, ref4, x2, y2 = "BOTTOM", "BOTTOM", 0, 0;
                        nameY = name:GetHeight() + nS;
                    end
                else
                    ref1, obj, ref2, x1, y1 = "BOTTOM", frame, "BOTTOM", 0, 0;
                    if justify == "right" then
                        ref3, ref4, x2, y2 = "BOTTOMLEFT", "BOTTOMRIGHT", nS, 0;
                    else
                        ref3, ref4, x2, y2 = "BOTTOMRIGHT", "BOTTOMLEFT", -nS, 0;
                    end
                end
            else
                ref1, obj, ref2, x1, y1 = "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0;
            end
        elseif timerDirection == "down" then
            if showingName then
                if moveName then
                    if groupDirection == "left" or groupDirection == "right" then
                        ref1, obj, ref2, x1, y1 = "TOP", frame, "TOP", 0, 0;
                        ref3, ref4, x2, y2 = "BOTTOM", "TOP", 0, nS;
                    else
                        ref1, obj, ref2, x1, y1 = "TOP", name, "BOTTOM", 0, -nS;
                        ref3, ref4, x2, y2 = "TOP", "TOP", 0, 0;
                        nameY = name:GetHeight() + nS;
                    end
                else
                    ref1, obj, ref2, x1, y1 = "BOTTOM", frame, "BOTTOM", 0, 0;
                    if justify == "right" then
                        ref3, ref4, x2, y2 = "TOPLEFT", "TOPRIGHT", nS, 0;
                    else
                        ref3, ref4, x2, y2 = "TOPRIGHT", "TOPLEFT", -nS, 0;
                    end
                end
            else
                ref1, obj, ref2, x1, y1 = "TOPLEFT", frame, "TOPLEFT", 0, 0;
            end
        elseif timerDirection == "left" then
            if showingName then
                if moveName then
                    if groupDirection == "up" then
                        ref1, obj, ref2, x1, y1 = "BOTTOMRIGHT", name, "TOPRIGHT", 0, nS;
                        ref3, ref4, x2, y2 = "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0;
                        if group:Get("centering") == "horizontal" then
                            ref1, ref2, ref3, ref4 = "BOTTOM", "TOP", "BOTTOM", "BOTTOM";
                        end
                    else
                        ref1, obj, ref2, x1, y1 = "TOPRIGHT", name, "BOTTOMRIGHT", 0, -nS;
                        ref3, ref4, x2, y2 = "TOPRIGHT", "TOPRIGHT", 0, 0;
                        if group:Get("centering") == "horizontal" then
                            ref1, ref2, ref3, ref4 = "TOP", "BOTTOM", "TOP", "TOP";
                        end
                    end
                    nameY = name:GetHeight() + nS;
                else
                    if groupDirection == "up" then
                        ref1, obj, ref2, x1, y1 = "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0;
                        ref3, ref4, x2, y2 = "BOTTOMLEFT", "BOTTOMRIGHT", nS, 0;
                    else
                        ref1, obj, ref2, x1, y1 = "TOPRIGHT", frame, "TOPRIGHT", 0, 0;
                        ref3, ref4, x2, y2 = "TOPLEFT", "TOPRIGHT", nS, 0;
                    end
                end
            else
                ref1, obj, ref2, x1, y1 = "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0;
            end
        elseif timerDirection == "right" then
            if showingName then
                if moveName then
                    if groupDirection == "up" then
                        ref1, obj, ref2, x1, y1 = "BOTTOMLEFT", name, "TOPLEFT", 0, nS;
                        ref3, ref4, x2, y2 = "BOTTOMLEFT", "BOTTOMLEFT", 0, 0;
                        if group:Get("centering") == "horizontal" then
                            ref1, ref2, ref3, ref4 = "BOTTOM", "TOP", "BOTTOM", "BOTTOM";
                        end
                    else
                        ref1, obj, ref2, x1, y1 = "TOPLEFT", name, "BOTTOMLEFT", 0, -nS;
                        ref3, ref4, x2, y2 = "TOPLEFT", "TOPLEFT", 0, 0;
                        if group:Get("centering") == "horizontal" then
                            ref1, ref2, ref3, ref4 = "TOP", "BOTTOM", "TOP", "TOP";
                        end
                    end
                    nameY = name:GetHeight() + nS;
                else
                    if groupDirection == "up" then
                        ref1, obj, ref2, x1, y1 = "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0;
                        ref3, ref4, x2, y2 = "BOTTOMRIGHT", "BOTTOMLEFT", -nS, 0;
                    else
                        ref1, obj, ref2, x1, y1 = "TOPLEFT", frame, "TOPLEFT", 0, 0;
                        ref3, ref4, x2, y2 = "TOPRIGHT", "TOPLEFT", -nS, 0;
                    end
                end
            else
                ref1, obj, ref2, x1, y1 = "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0;
            end
        end
        
        self.nameX = nameX;
        self.nameY = nameY;
        
        timerAnchor:SetPoint(ref1, obj, ref2, x1, y1);
        if showingName then
            name:Show();
            name:SetPoint(ref3, frame, ref4, x2, y2);
            name:SetScale(group:Get("nameScale"));
        else
            name:Hide();
        end
    end,
};

subFunc = function(a)
    if a == "%s" then
        local groupDirection = subGroup:Get("groupDirection");
        local moveName = subGroup:Get("moveName") or (groupDirection == "left" or groupDirection == "right");
        return moveName and subGroup.name or gsub(subGroup.name, " ", "\n");
    elseif a == "%l" then
        return not subGroup.level and "" or subGroup:Get("nameLevelFormat"):format(subGroup.level == -1 and "??" or subGroup.level);
    elseif a == "%r" then
        return (not subGroup.icon or subGroup.icon == 0) and "" or 
            subGroup:Get("nameRaidIconFormat"):format(("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t"):format(subGroup.icon));
    else
        return "";
    end
end

local frameScripts = {
    OnDragStart = function( self )
        self.mainFrame.beingDragged = true;
        self.group.anchor:CallScript( "StartMoving" );
    end,
    OnDragStop = function( self )
        self.mainFrame.beingDragged = false;
        self.group.anchor:CallScript( "StopMoving" );
    end,
    OnEnter = function( self )
        self.mainFrame.mouseIsOver = true;
        self.group.anchor:CallScript( "UpdateAlpha" );
    end,
    OnLeave = function( self )
        self.mainFrame.mouseIsOver = false;
        self.group.anchor:CallScript( "UpdateAlpha" );
    end,
};

local function acquireGroupFrame( group )
    local frame = CreateFrame("Frame", nil, nil, "TimerLibGroupFrameTemplate");
    sanitize( frame );
    frame.Name.Text:SetPoint( "CENTER" );
    frame.Name.Icon:SetPoint( "CENTER" );
    frame.Name.Icon:SetWidth( 24 );
    frame.Name.Icon:SetHeight( 24 );
    frame.Name.mainFrame = frame;
    for k, v in pairs( frameScripts ) do
        frame.Name:SetScript( k, v );
    end
    
    frame.Name:RegisterForDrag("LeftButton");
    
    frame.group = group;
    frame.Name.group = group;
    
    if drawingBackground then
        local t = frame:CreateTexture();
        t:SetAllPoints(true);
        t:SetTexture(0, 1, 0, .5);
        t = frame.Name:CreateTexture();
        t:SetAllPoints(true);
        t:SetTexture(0, 0, 1, .5);
        t = frame.TimerAnchor:CreateTexture();
        t:SetAllPoints(true);
        t:SetTexture(0, 1, 0, .5);
    end
    
    return frame;
end

GroupFrameManager, internal, oldDestruct = Class( "GroupFrameManager", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = GroupFrameManager.new;
GroupFrameManager.new = function( group )
    local t = oldNew();
    local int = internal[ t ];
    local frame = acquireGroupFrame( group );
    int.fields.frame = frame;
    
    int.fields.group = group;
    
    return t;
end


