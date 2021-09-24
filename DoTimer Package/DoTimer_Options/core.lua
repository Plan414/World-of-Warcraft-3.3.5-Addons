AsheylaLib:Package( "GUILib" );
GUILib = AsheylaLib:NewModule("GUILib");
local gui = GUILib;

local scripts = {
    checkButton = {
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
        end,
    },
    slider = {
        OnShow = function(self) 
            self.real = false;
            local setting;
            if self.Get then
                setting = self.Get(self.setting);
            else
                setting = self.module:Get(self.setting);
            end
            self:SetValue(setting or 0);
            self.real = true; 
        end,
        OnValueChanged = function(self)
            local value = self:GetValue();
            local formatstring;
            local trimming = false;
            if math.floor(value) == value then 
                formatstring = "%d";
            else
                formatstring = "%.2f";
                trimming = true;
            end
            local text = string.format(formatstring, value);
            getglobal(self:GetName() .. "Value"):SetText(trimming and text:trim("0") or text);
            if self.real then
                if self.Set then
                    self.Set(self.setting, value);
                else
                    self.module:Set(self.setting, value);
                end
                if self.toggle then self.toggle:SetChecked(true); end
            end
        end,
    },
    editBoxString = {
        OnEditFocusGained = function(self) 
            local text;
            if self.Get then
                text = self.Get(self.setting);
            else
                text = self.module:Get(self.setting);
            end
            self:SetText(text or ""); 
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
            if self.Set then
                self.Set(self.setting, text);
            else
                self.module:Set(self.setting, text); 
            end
            if self.toggle then self.toggle:SetChecked(true); end
            self:ClearFocus();
        end,
    },
    editBoxDropDown = {
        OnEditFocusGained = function(self) self:SetText(""); self:HighlightText() end,
        OnEditFocusLost = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
        OnShow = function(self) self:SetText(self.title or ""); self:SetCursorPosition(0); end,
        OnEscapePressed = function(self)
            self:SetText(self.title or ""); self:SetCursorPosition(0);
            self:ClearFocus();
        end,
        OnEnterPressed = function(self) 
            local text = self:GetText();
            if self.Set then
                self.Set(self.setting, string.lower(text), 1);
            else
                self.module:Set(self.setting, string.lower(text), 1); 
            end
            if self.toggle then self.toggle:SetChecked(true); end
            self:ClearFocus();
        end,
    },
    colorSelect = {
        OnClick = function(self)
            ColorPickerFrame.func = function() 
                local r, g, b = ColorPickerFrame:GetColorRGB();
                getglobal(self:GetName() .. "NormalTexture"):SetVertexColor(r, g, b);
                if self.Set then
                    self.Set(self.setting, {r = r, g = g, b = b});
                else
                    self.module:Set(self.setting, {r = r, g = g, b = b});
                end
                if self.toggle then self.toggle:SetChecked(true); end
            end
            local r, g, b = getglobal(self:GetName().."NormalTexture"):GetVertexColor();
            ColorPickerFrame:SetColorRGB(r, g, b);
            ColorPickerFrame.previousValues = {r = r, g = g, b = b, isReal = self.isReal};
            ColorPickerFrame.cancelFunc = function(prev)
                if prev.isReal then
                    if self.Set then
                        self.Set(self.setting, {r = r, g = g, b = b});
                    else
                        self.module:Set(self.setting, {r = r, g = g, b = b});
                    end
                    if self.toggle then self.toggle:SetChecked(true); end
                else
                    if self.Set then
                        self.Set(self.setting, nil);
                    else
                        self.module:Set(self.setting, nil);
                    end
                    if self.toggle then self.toggle:SetChecked(false); end
                end
                getglobal(self:GetName().."NormalTexture"):SetVertexColor(prev.r, prev.g, prev.b);
            end
            ShowUIPanel(ColorPickerFrame);
        end,
        OnEnter = function(self)
            getglobal(self:GetName() .. "SwatchBg"):SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            if self.tooltipText then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1);
            end
        end,
        OnLeave = function(self)
            getglobal(self:GetName() .. "SwatchBg"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
            GameTooltip:Hide();
        end,
        OnShow = function(self)
            local color;
            local isReal = true;
            if self.Get then
                color, isReal = self.Get(self.setting);
            else
                color = self.module:Get(self.setting);
            end
            if color then
                self.isReal = isReal;
                getglobal(self:GetName() .. "NormalTexture"):SetVertexColor(color.r, color.g, color.b);
            end
        end,
    },
    button = {
        OnClick = function(self)
            if self.func then
                self.func();
            end
        end,
    },
    toggle = {
        OnShow = function(self)
            local value, isChecked;
            if self.Get then
                value, isChecked = self.Get(self.setting);
            else
                value = self.module:Get(self.setting);
            end
            if isChecked == nil then
                isChecked = (value ~= nil and true or false);
            end
            self:SetChecked(isChecked);
        end,
        OnClick = function(self) 
            if self:GetChecked() then
                self:SetChecked(false);
                AsheylaLib:AlertUser("You cannot check this button.  It becomes checked when you change the setting to the right.");
            else
                if self.Set then
                    self.Set(self.setting, nil);
                else
                    self.module:Set(self.setting, nil);
                end
                local ownerShowFunc = self.owner:GetScript("OnShow");
                if ownerShowFunc then 
                    ownerShowFunc(self.owner);
                end
            end
        end,
    },
};

InterfaceOptionsFrame:SetFrameStrata("HIGH")

local scrollFunc = function(self, value)
    local scrollBar = getglobal(self:GetName() .. "ScrollBar");
    if ( value > 0 ) then
        scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() / 4));
    else
        scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 4));
    end
end

local counter = 0;
function gui:SetGUIPanel(panel, subCat, module, options, extras)
    counter = counter + 1;
    extras = extras or {};
    self.panels = self.panels or {};
    self.panels[panel] = self.panels[panel] or {};
    self.panels[panel][subCat] = { options = options, }; 
    local panelTable = self.panels[panel][subCat];
    local f = CreateFrame("Frame", "Ash_Menu" .. counter, nil, "Ash_CoreMenuTemplate");
    panelTable.panel = f;
    if subCat ~= "main" then
        f.parent = panel;
        f.name = subCat;
    else
        f.name = panel;
    end
    f.highlight = extras.highlight;
    
    f.default = extras.default or function() module:ClearSettings(); InterfaceOptionsFrame:Hide(); gui:ShowPanel(panel, subCat); end
    f.okay = extras.okay;
    InterfaceOptions_AddCategory(f);
    
    f:SetScript("OnShow", function(self)
        if not self.loaded then
            self.loaded = true;
            local f = getglobal(self:GetName() .. "ScrollFrameContainer");
            f.mainFrame = self;
            gui:GenerateMenu(f, module, options, extras);
            gui:ShowPanel(panel, subCat);
            --f:SetHeight(2000)
            if f:GetHeight() < self:GetHeight() then
                getglobal(self:GetName() .. "ScrollFrameScrollBar"):Hide();
            end
        end
    end);
    getglobal(f:GetName() .. "ScrollFrameScrollBar"):SetScale(.7);
    getglobal(f:GetName() .. "ScrollFrame"):SetScript("OnMouseWheel", scrollFunc);
    
    local title = InterfaceOptionsFrame:GetTitleRegion();
    if not title then
        InterfaceOptionsFrame:SetMovable(true);
        title = InterfaceOptionsFrame:CreateTitleRegion();
        title:SetAllPoints(InterfaceOptionsFrameHeader);
    end
end

function gui:GenerateMenu(frame, module, options, extras)
    frame.sections = {};
    local anchor = frame;
    local x, y, rel = 0, 0, "TOPLEFT";
    local width, height = 0, 0;
    for i, section in ipairs(options) do
        local sectionFrame, padding = self:GenerateSection(module, frame, section, extras);
        sectionFrame.padding = padding;
        sectionFrame.menu = frame;
        table.insert(frame.sections, sectionFrame);
        sectionFrame:SetPoint("TOPLEFT", anchor, rel, x, y);
        anchor = sectionFrame;
        x, y = 0, -(padding or 25);
        rel = "BOTTOMLEFT";
        width = math.max(width, sectionFrame:GetWidth());
        height = height + sectionFrame:GetHeight() + (i == #options and 5 or (padding or 25));
    end
    frame:SetWidth(width);
    frame:SetHeight(height);
    
    if extras.help then
        local helpFrame = CreateFrame("Button", module:GetName() .. "HelpButton", frame, "Ash_CoreButtonTemplate");
        getglobal(helpFrame:GetName() .. "Text"):SetText("Help");
        helpFrame:SetPoint("BOTTOM", 0, 20);
        UIDropDownMenu_Initialize(getglobal(helpFrame:GetName() .. "DropDown"), extras.help);
    end--[[ Removed to comply with the new addon policy!
    local donationText = frame:CreateFontString();
    donationText:SetFontObject(GameFontNormalSmall);
    donationText:SetPoint("BOTTOM", 0, 6);
    donationText:SetJustifyV("BOTTOM");
    donationText:SetText("Donations are appreciated at ross456@gmail.com via PayPal.");--]]
end

local function updateSection(item)
    local section = item.section;
    -- recalculate height, anchoring of section and items in it
    local sectionHeight = 0;
    local sectionPoint, sectionRef, sectionX, sectionY = "TOPLEFT", section, 0, 0;
    if section.titleFrame and section.descFrame then
        sectionRef = section.descFrame;
        sectionPoint = "BOTTOMLEFT";
        sectionY = -5;
    end
    local firstColumn, lastColumn;
    local maxHeight = 0;
    for _, column in ipairs(section.columns) do
        column:Show();
        --first, figure out the new dimensions of column
        local width, height = 0, 0;
        local point, ref, x, y = "TOPLEFT", column, 0, 0;
        column.numVisible = 0;
        for _, holder in ipairs(column.items) do
            local visible = true;
            if holder.item and not holder.item:IsShown() then visible = false; end
            if visible then
                column.numVisible = column.numVisible + 1;
                width = math.max(width, holder:GetWidth());
                height = height + holder:GetHeight();
                holder:ClearAllPoints();
                holder:SetPoint("TOPLEFT", ref, point, x, y);
                ref = holder;
                point = "BOTTOMLEFT";
            end
        end
        if width == 0 or height == 0 then
            column:Hide();
        else
            firstColumn = firstColumn or column;
            lastColumn = column;
            column:SetHeight(height);
            maxHeight = math.max(maxHeight, height);
            column:SetWidth(width);
            column:ClearAllPoints();
            column:SetPoint("TOPLEFT", sectionRef, sectionPoint, sectionX, sectionY);
            sectionHeight = math.max(sectionHeight, height);
            sectionPoint = "TOPRIGHT";
            sectionRef = column;
            sectionX = 8;
            sectionY = 0;
        end
    end
    if sectionHeight > 0 then
        section:Show();
        for i, column in ipairs(section.columns) do
            if column:IsShown() then
                --print(i, column:GetHeight(), maxHeight);
                local difference = maxHeight - column:GetHeight();
                if difference > 0 then
                    if #column.breaks > 0 then
                        difference = difference / #column.breaks;
                        for _, breakFrame in ipairs(column.breaks) do
                            breakFrame:SetHeight(difference);
                        end
                    elseif column.numVisible > 1 then
                        difference = difference / (column.numVisible - 1);
                        for i = 2, #column.items do
                            local a, b, c, d, e = column.items[i]:GetPoint();
                            column.items[i]:ClearAllPoints();
                            column.items[i]:SetPoint(a, b, c, d, -difference);
                        end
                    end
                end
            end
        end
        local otherHeight = 0;
        if section.titleFrame and section.descFrame then
            section.titleFrame:Show();
            section.descFrame:Show();
            otherHeight = section.titleFrame:GetHeight() + section.descFrame:GetHeight() + 5;
        end
        section:SetHeight(sectionHeight + otherHeight);
        section:SetWidth(1);
        if section.borderFrame then
            local border = section.borderFrame;
            border:Show();
            border:ClearAllPoints();
            border:SetPoint("TOPLEFT", firstColumn, -2, 3);
            border:SetPoint("TOPRIGHT", lastColumn, 2, 3);
            border:SetHeight(sectionHeight + 6);
        end
    else
        section:Hide();
        if section.titleFrame then section.titleFrame:Hide(); end
        if section.descFrame then section.descFrame:Hide(); end
        if section.borderFrame then section.borderFrame:Hide(); end
    end
    
    local container = section.menu;
    local ref, anchor, x, y = "TOPLEFT", container, 0, 0;
    local width, height, lastPadding = 0, 0, 0;
    for _, section in ipairs(container.sections) do
        if section:IsShown() then
            --print(section, section == Ash_MenuItem1.section, anchor:GetName(), ref);
            section:SetPoint("TOPLEFT", anchor, ref, x, y);
            anchor = section;
            ref = "BOTTOMLEFT";
            x = 0;
            y = -(section.padding or 25);
            lastPadding = -y;
            width = math.max(width, section:GetWidth());
            height = height + section:GetHeight() + lastPadding;
        end
    end
    container:SetWidth(width);
    container:SetHeight(height - lastPadding + 5);
    local bar = getglobal(container.mainFrame:GetName() .. "ScrollFrameScrollBar");
    if container:GetHeight() <= container.mainFrame:GetHeight() then
        bar:SetValue(select(2, bar:GetMinMaxValues()));
        bar:Hide();
    else
        bar:Show();
    end
end

function gui:GenerateSection(module, frame, section, extras)
    local sectionFrame = CreateFrame("Frame", nil, frame);
    sectionFrame.columns = {};
    local anchor = sectionFrame;
    local x, y, rel = 0, 0, "TOPLEFT";
    local otherHeight = 0;
    
    local title, desc, border;
    if (extras.allSimple and not section.notSimple) or section.simple or not AsheylaLib:InSimpleMode() then
        if section.title or section.subTitle then
            title = CreateFrame("Frame", nil, frame);
            sectionFrame.titleFrame = title;
            local s = title:CreateFontString();
            title.text = s;
            s:SetFont((GameFontNormal:GetFont()), 13 - (section.subTitle and 2 or 0));
            s:SetJustifyH("LEFT");
            s:SetText(section.title or section.subTitle);
            s:SetAllPoints(title);
            title:SetWidth(s:GetStringWidth() + 10);
            title:SetHeight(s:GetStringHeight());
            title:SetPoint("TOPLEFT", anchor, rel, x, y);
            --local t=title:CreateTexture()t:SetAllPoints(true)t:SetTexture(1,0,1,.5)
            anchor = title;
            rel = "BOTTOMLEFT";
            otherHeight = otherHeight + title:GetHeight();
        end
        
        if section.description then
            desc = CreateFrame("Frame", nil, frame);
            sectionFrame.descFrame = desc;
            local s = desc:CreateFontString();
            desc.text = s;
            s:SetFontObject(GameFontNormalSmall);
            s:SetJustifyH("LEFT");
            s:SetText("|cff44ff44" .. section.description);
            s:SetAllPoints(desc);
            s:SetWidth(300);
            desc:SetWidth(s:GetWidth() + 10);
            desc:SetHeight(s:GetHeight());
            desc:SetPoint("TOPLEFT", anchor, rel, x, y);
            --local t=desc:CreateTexture()t:SetAllPoints(true)t:SetTexture(1,0,1,.5)
            anchor = desc;
            rel = "BOTTOMLEFT";
            y = -5;
            otherHeight = otherHeight + desc:GetHeight() + 5;
        end
    end
    
    if section.showBorder then
        border = CreateFrame("Frame", nil, sectionFrame, "Ash_CoreColumnBackgroundTemplate");
        sectionFrame.borderFrame = border;
        border.section = sectionFrame;
    end
    
    local width, height = -8, 0;
    for _, column in ipairs(section) do
        local columnFrame = self:GenerateColumn(module, border or sectionFrame, column, extras);
        table.insert(sectionFrame.columns, columnFrame);
        height = math.max(height, columnFrame:GetHeight());
        width = width + columnFrame:GetWidth() + 8;
        columnFrame:SetPoint("TOPLEFT", anchor, rel, x, y);
        anchor = columnFrame;
        x, y = 8, 0;
        rel = "TOPRIGHT";
    end
    
    for i = #sectionFrame.columns, 1, -1 do
        local column = sectionFrame.columns[i];
        if column:IsShown() then
            local difference = height - column:GetHeight();
            if difference > 0 then
                if #column.breaks > 0 then
                    difference = difference / #column.breaks;
                    for _, breakFrame in ipairs(column.breaks) do
                        breakFrame:SetHeight(difference);
                    end
                elseif #column.items > 1 then
                    difference = difference / (#column.items - 1);
                    for i = 2, #column.items do
                        column.items[i]:ClearAllPoints();
                        column.items[i]:SetPoint("TOPLEFT", column.items[i - 1], "BOTTOMLEFT", 0, -difference);
                    end
                end
            end
        else
            table.remove(sectionFrame.columns, i);
        end
    end
    
    if #sectionFrame.columns == 0 then
        if title then title:Hide(); end
        if desc then desc:Hide(); end
        if border then border:Hide(); end
        height = 1;
        otherHeight = 0;
    elseif border then
        border:SetPoint("TOPLEFT", sectionFrame.columns[1], -2, 3);
        border:SetPoint("TOPRIGHT", sectionFrame.columns[#sectionFrame.columns], 2, 3);
        border:SetHeight(height + 6);
    end
    sectionFrame:SetWidth(1);
    sectionFrame:SetHeight(height + otherHeight);
    return sectionFrame, section.padding;
end

function gui:GenerateColumn(module, frame, column, extras)
    local columnFrame = CreateFrame("Frame", nil, frame);
    columnFrame.section = frame.section or frame;
    columnFrame.items = {};
    columnFrame.breaks = {};
    local height, width = 0, 0;
    local anchor = columnFrame;
    local x, y, rel = 0, 0, "TOPLEFT";
    for _, item in ipairs(column) do
        if item == "BREAK" then
            local breakFrame = CreateFrame("Frame", nil, frame);
            table.insert(columnFrame.breaks, breakFrame);
            breakFrame:SetWidth(1);
            breakFrame:SetHeight(1);
            breakFrame:SetPoint("TOPLEFT", anchor, rel, x, y);
            x, y = 0, 0;
            anchor = breakFrame;
            rel = "BOTTOMLEFT";
        elseif (extras.allSimple and not item.notSimple) or item.simple or not AsheylaLib:InSimpleMode() then
            local itemFrame = item[1] and self:GenerateRow(module, columnFrame, item, extras) or self:GenerateItem(module, columnFrame, item, extras);
            table.insert(columnFrame.items, itemFrame);
            height = height + itemFrame:GetHeight();
            width = math.max(width, itemFrame:GetWidth());
            itemFrame:SetPoint("TOPLEFT", anchor, rel, x, y);
            x, y = 0, 0;
            anchor = itemFrame;
            rel = "BOTTOMLEFT";
        end
    end
    
    if (width == 0 and height == 0) then
        columnFrame:SetWidth(1);
        columnFrame:SetHeight(1);
        columnFrame:Hide();
    else
        columnFrame:SetWidth(width);
        columnFrame:SetHeight(height);
    end
    --local t = columnFrame:CreateTexture() t:SetAllPoints(true) t:SetTexture(0, 0, 1, .5);
    --local bg = CreateFrame("Frame", nil, columnFrame, "Ash_CoreColumnBackgroundTemplate");
    --bg:SetPoint("TOPLEFT", -3, 3);
    --bg:SetPoint("BOTTOMRIGHT", 3, -3);
    return columnFrame;
end

function gui:GenerateRow(module, frame, row, extras)
    local rowFrame = CreateFrame("Frame", nil, frame);
    rowFrame.section = frame.section;
    local height, width = 0, -5;
    local anchor = rowFrame;
    local x, y, rel = 0, 0, "LEFT";
    for _, item in ipairs(row) do
        local itemFrame = self:GenerateItem(module, rowFrame, item, extras);
        height = math.max(height, itemFrame:GetHeight());
        width = width + itemFrame:GetWidth() + 5;
        itemFrame:SetPoint("LEFT", anchor, rel, x, y);
        x, y = 5, 0;
        anchor = itemFrame;
        rel = "RIGHT";
    end
    rowFrame:SetWidth(width);
    rowFrame:SetHeight(height);
    return rowFrame;
end

local counter = 0;
function gui:GenerateItem(module, frame, item, extras)
    module = item.module or module;
    counter = counter + 1;
    local holderFrame = CreateFrame("Frame", nil, frame);
    local itemFrame, width, height, point;
    
    local x, y = 0, 0;
    local toggleOffset = 0;
    if item.type == "checkButton" then
        itemFrame = CreateFrame("CheckButton", "Ash_MenuItem" .. counter, frame, "Ash_CoreCheckButtonTemplate");
        getglobal(itemFrame:GetName() .. "Text"):SetText(item.title);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Text"):GetStringWidth();
        height = itemFrame:GetHeight() * .8;
        point = "LEFT";
        x = -1;
    elseif item.type == "slider" then
        itemFrame = CreateFrame("Slider", "Ash_MenuItem" .. counter, frame, "Ash_CoreSliderTemplate");
        getglobal(itemFrame:GetName() .. "Title"):SetText(item.title);
        getglobal(itemFrame:GetName() .. "Value"):SetText("aa");
        getglobal(itemFrame:GetName() .. "Low"):SetText("");
        getglobal(itemFrame:GetName() .. "High"):SetText("");
        itemFrame:SetMinMaxValues(item.minValue, item.maxValue);
        itemFrame:SetValueStep(item.valueStep);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Value"):GetWidth() + 8;
        height = itemFrame:GetHeight() + getglobal(itemFrame:GetName() .. "Title"):GetStringHeight() + 5;
        point = "BOTTOMLEFT";
    elseif item.type == "editBoxString" then
        itemFrame = CreateFrame("EditBox", "Ash_MenuItem" .. counter, frame, "Ash_CoreEditBoxTemplate");
        itemFrame.title = item.title;
        width = itemFrame:GetWidth() + 10;
        height = itemFrame:GetHeight() + 6;
        point = "BOTTOMLEFT";
        x = 5;
        y = 3;
        toggleOffset = -5;
    elseif item.type == "dropDownSelector" then
        itemFrame = CreateFrame("Button", "Ash_MenuItem" .. counter, frame, "Ash_CoreDropDownTemplate");
        getglobal(itemFrame:GetName() .. "Text"):SetText(item.title);
        local func = function()
            local info;
            for _, value in ipairs(item.values) do
                info = UIDropDownMenu_CreateInfo();
                info.text = value;
                if item.get then
                    info.checked = item.get(item.setting) == value;
                elseif extras.get then
                    info.checked = extras.get(item.setting) == value;
                else
                    info.checked = module:Get(item.setting) == value;
                end
                info.func = item.func or function() 
                    if extras.set then
                       extras.set(item.setting, value);
                    else
                        module:Set(item.setting, value); 
                    end
                    if itemFrame.toggle then itemFrame.toggle:SetChecked(true); end
                    CloseDropDownMenus(); 
                end
                info.arg1 = value;
                UIDropDownMenu_AddButton(info);
            end
        end
        UIDropDownMenu_Initialize(getglobal(itemFrame:GetName() .. "DropDown"), func);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Text"):GetStringWidth() + 6;
        height = itemFrame:GetHeight();
        point = "LEFT";
        x = 1;
    elseif item.type == "dropDownMultiSelector" then
        itemFrame = CreateFrame("Button", "Ash_MenuItem" .. counter, frame, "Ash_CoreDropDownTemplate");
        getglobal(itemFrame:GetName() .. "Text"):SetText(item.title);
        local func = function()
            local info;
            for _, value in ipairs(item.values) do
                info = UIDropDownMenu_CreateInfo();
                info.text = value;
                if extras.get then
                    info.checked = extras.get(item.setting, value);
                else
                    info.checked = module:Get(item.setting, value);
                end
                info.func = function(frame, _, _, wasChecked) 
                    local val = not wasChecked and 1 or nil;
                    if extras.set then
                        extras.set(item.setting, value, val);
                    else
                        module:Set(item.setting, value, val); 
                    end
                    if itemFrame.toggle then itemFrame.toggle:SetChecked(true); end
                    CloseDropDownMenus(); 
                end
                UIDropDownMenu_AddButton(info);
            end
        end
        UIDropDownMenu_Initialize(getglobal(itemFrame:GetName() .. "DropDown"), func);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Text"):GetStringWidth() + 6;
        height = itemFrame:GetHeight();
        point = "LEFT";
        x = 1;
    elseif item.type == "dropDown" then
        itemFrame = CreateFrame("Button", "Ash_MenuItem" .. counter, frame, "Ash_CoreDropDownTemplate");
        getglobal(itemFrame:GetName() .. "Text"):SetText(item.title);
        UIDropDownMenu_Initialize(getglobal(itemFrame:GetName() .. "DropDown"), item.func);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Text"):GetStringWidth() + 6;
        height = itemFrame:GetHeight();
        point = "TOPLEFT";
        x = 1;
    elseif item.type == "editBoxDropDown" then
        itemFrame = CreateFrame("EditBox", "Ash_MenuItem" .. counter, frame, "Ash_CoreEditBoxDropDownTemplate");
        itemFrame.title = item.title;
        local func = item.func or function()
            local info;
            for value in alphabetize(extras.get and extras.get(item.setting) or module:Get(item.setting)) do
                info = UIDropDownMenu_CreateInfo();
                info.text = value;
                info.notCheckable = 1;
                info.func = function() 
                    if extras.set then
                        extras.set(item.setting, value, nil);
                    else
                        module:Set(item.setting, value, nil); 
                    end
                    if itemFrame.toggle then itemFrame.toggle:SetChecked(true); end
                    CloseDropDownMenus(); 
                end
                UIDropDownMenu_AddButton(info);
            end
        end
        UIDropDownMenu_Initialize(getglobal(itemFrame:GetName() .. "ButtonDropDown"), func);
        UIDropDownMenu_SetAnchor(getglobal(itemFrame:GetName() .. "ButtonDropDown"), nil, nil, "TOPRIGHT", getglobal(itemFrame:GetName() .. "Button"), "BOTTOMLEFT");
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Button"):GetWidth() + 8;
        height = itemFrame:GetHeight() + 6;
        point = "LEFT";
        x = 8;
    elseif item.type == "text" then
        itemFrame = CreateFrame("Frame", "Ash_MenuItem" .. counter, frame);
        local s = itemFrame:CreateFontString();
        itemFrame.text = s;
        s:SetFontObject(item.small and GameFontNormalSmall or GameFontNormal);
        s:SetJustifyH("LEFT");
        s:SetJustifyV("CENTER");
        s:SetText(item.text);
        if item.color then
            s:SetTextColor(item.color.r, item.color.g, item.color.b);
        end
        s:SetPoint("LEFT", itemFrame, "LEFT", 0, 1);
        itemFrame:SetWidth(s:GetStringWidth() + 4);
        itemFrame:SetHeight(s:GetStringHeight() + 4);
        width = itemFrame:GetWidth();
        height = itemFrame:GetHeight() + 4;
        point = "LEFT";
    elseif item.type == "colorSelect" then
        itemFrame = CreateFrame("Button", "Ash_MenuItem" .. counter, frame, "Ash_CoreColorSwatchTemplate");
        getglobal(itemFrame:GetName() .. "Title"):SetText(item.title);
        width = itemFrame:GetWidth() + getglobal(itemFrame:GetName() .. "Title"):GetStringWidth() + 10;
        height = itemFrame:GetHeight() + 4;
        point = "LEFT";
    elseif item.type == "button" then
        itemFrame = CreateFrame("Button", "Ash_MenuItem" .. counter, frame, "Ash_CoreButtonTemplate");
        itemFrame.func = item.func;
        getglobal(itemFrame:GetName() .. "Text"):SetText(item.title);
        width = itemFrame:GetWidth();
        height = itemFrame:GetHeight();
        point = "LEFT";
    end
    
    itemFrame.section = frame.section;
    itemFrame.UpdateSection = updateSection;
    itemFrame.tooltipText = item.tooltipText;
    itemFrame.data = item.data;
    itemFrame.module = module;
    itemFrame.setting = item.setting;
    itemFrame.Get = extras.get;
    itemFrame.Set = extras.set;
    if scripts[item.type] then
        for name, func in pairs(scripts[item.type]) do
            itemFrame:SetScript(name, func);
        end
    end
    if item.scripts then
        for name, func in pairs(item.scripts) do
            itemFrame:SetScript(name, func);
        end
    end
    if item.hasToggle then
        local toggleFrame = CreateFrame("CheckButton", nil, frame, "Ash_CoreToggleTemplate");
        toggleFrame:SetPoint("RIGHT", itemFrame, "LEFT", toggleOffset, 0);
        toggleFrame.tooltipText = extras.toggleTooltip;
        toggleFrame.Set = extras.set;
        toggleFrame.Get = extras.get;
        for name, func in pairs(scripts.toggle) do
            toggleFrame:SetScript(name, func);
        end
        toggleFrame.setting = item.setting;
        toggleFrame.module = module;
        toggleFrame.owner = itemFrame;
        itemFrame.toggle = toggleFrame;
        x = x + toggleFrame:GetWidth() + 3;
        width = width + toggleFrame:GetWidth();
    else
        x = x + 2;
        width = width + 2;
    end
    itemFrame:SetPoint(point, holderFrame, point, x, y);
    itemFrame.holder = holderFrame;
    holderFrame.item = itemFrame;
    holderFrame:SetWidth(width);
    holderFrame:SetHeight(height);
    --local t = holderFrame:CreateTexture() t:SetAllPoints(true) t:SetTexture(0, 1, 0, .5);
    return holderFrame;
end

function gui:ShowPanel(panel, subCat)
    subCat = subCat or "main";
    for panelName, panelTable in pairs(self.panels) do
        if string.find(panelName, panel .. "$") then
            local f = panelTable[subCat].panel;
            InterfaceOptionsFrame:Hide(); 
            InterfaceOptionsFrame_OpenToCategory(f);
            break;
        end
    end
end

local SHOWN_PANEL, SHOWN_SUBCAT;
hooksecurefunc("InterfaceOptionsList_DisplayPanel", function(f) 
    if f.parent then
        SHOWN_PANEL = f.parent;
        SHOWN_SUBCAT = f.name;
    else
        SHOWN_PANEL = f.name;
        SHOWN_SUBCAT = nil;
    end
end);

function gui:RefreshCurrentPanel()
    InterfaceOptionsFrame:Hide(); 
    self:ShowPanel(SHOWN_PANEL, SHOWN_SUBCAT);
end

local creationFuncs = {};
function gui:AddGUICreationScript(func)
    table.insert(creationFuncs, func);
end

function gui:ReloadGUI()
    local cats = INTERFACEOPTIONS_ADDONCATEGORIES;
    for _, panel in pairs(self.panels) do
        for subCat, panelTable in pairs(panel) do
            for i = #cats, 1, -1 do
                if cats[i] == panelTable.panel then
                    table.remove(cats, i);
                    break;
                end
            end
        end
    end
    self.panels = {};
    for i, func in ipairs(creationFuncs) do
        func();
    end
    InterfaceOptionsFrame:Hide(); 
    gui:ShowPanel(SHOWN_PANEL, SHOWN_SUBCAT);
end

local profileFuncs = {};
function gui:AddProfileChangeScript(func)
    table.insert(profileFuncs, func);
end

gui:RegisterEvent("PROFILE_UPDATE");
gui:SetScript("OnEvent", function()
    for i, func in ipairs(profileFuncs) do
        func();
    end
    InterfaceOptionsFrame:Hide(); 
    gui:ShowPanel(SHOWN_PANEL, SHOWN_SUBCAT);
end);

local o = CreateFont( "AsheylaGUILibFont" );
o:CopyFontObject( "GameFontNormalSmall" );
o:SetTextColor( 1, .95, .7 );
hooksecurefunc( "OptionsList_DisplayButton", function( button, element )
    if ( element.highlight ) then
        button:SetNormalFontObject( o );
        button:SetHighlightFontObject( o );
    end
end );
