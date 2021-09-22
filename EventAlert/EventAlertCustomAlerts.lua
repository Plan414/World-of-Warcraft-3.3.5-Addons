function Custom_Events_OnLoad()
    UIPanelWindows["Custom_Events_Frame"] = {area = "center", pushable = 0};

    Custom_Events_Frame_SaveCustom_Box:SetFontObject(ChatFontNormal);
	Custom_Events_Frame_SaveCustom_Box:SetText("Spell ID here");
end


function pairsByKeys (t, f)
	local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end


function EventAlert_CustomAlert_SaveSetting()

	local tempcustom = Custom_Events_Frame_SaveCustom_Box:GetText()

    if (tempcustom == nil or tempcustom == "" or tempcustom == "Spell ID here") then return;end

   	local EA_name, EA_rank = GetSpellInfo(tempcustom);

    if (EA_name == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("Invalid spell ID.");
    else
	    tempcustom = tonumber(tempcustom);

    	if (EA_CustomItems[EA_playerClass][tempcustom] == nil) then
	    	EA_CustomItems[EA_playerClass][tempcustom] = true;
	    end;

        EventAlert_CreateCustomFrames();
	    DEFAULT_CHAT_FRAME:AddMessage("Added spell ID "..tempcustom.." to EventAlert.");
		Custom_Events_Frame_SaveCustom_Box:SetText("")
    end

end






-- Functions for deleting custom events

function EventAlert_DeleteCustom_Box_OnLoad()
    UIDropDownMenu_Initialize(this, EventAlert_DeleteCustom_Box_OnShow);
	UIDropDownMenu_SetWidth(Custom_Events_Frame_DeleteCustom_Box, 175);
end


function EventAlert_DeleteCustom_Box_OnShow()
	if (EA_PreLoadComplete == 1) then

	for index,value in pairsByKeys(EA_CustomItems[EA_playerClass]) do
		if (type(value) == "number") then
			value = tostring(index)
		elseif (type(value) == "boolean") then
			if (value) then
				value = "true"
		    else
			    value = "false"
		    end
		  end

    	local EA_name, EA_rank = GetSpellInfo(index);

   		local selectedValue = UIDropDownMenu_GetSelectedValue(Custom_Events_Frame_DeleteCustom_Box) ;
		local info;

		info = {};
		info.text = EA_name.." ["..index.."]";
		info.func = EventAlert_DeleteCustom_Box_OnClick;
		info.value = index;
	    if ( info.value == selectedValue ) then
			info.checked = index;
		end
    	UIDropDownMenu_AddButton(info);

    end

    end

end


function EventAlert_DeleteCustom_Box_OnClick()
	UIDropDownMenu_SetSelectedValue(Custom_Events_Frame_DeleteCustom_Box, this.value);
end



function EventAlert_CustomAlert_DeleteSetting()

	local selectedValue = UIDropDownMenu_GetSelectedValue(Custom_Events_Frame_DeleteCustom_Box) ;

	for index,value in pairsByKeys(EA_CustomItems[EA_playerClass]) do
		if (type(value) == "number") then
			value = tostring(index)
		elseif (type(value) == "boolean") then
			if (value) then
				value = "true"
		    else
			    value = "false"
		    end
		  end

	     local EA_name, EA_rank = GetSpellInfo(index);

		 if (index == selectedValue) then
		 	EA_CustomItems[EA_playerClass][selectedValue] = nil;
          	DEFAULT_CHAT_FRAME:AddMessage("Removed "..EA_name.." ["..index.."] from EventAlert.");
         end
    end

end


function removeCustomValue(tab, value)
	for pos, name in ipairs(tab) do
		if (name == value) then
			table.remove(tab, pos)
		end
	end
end



function Custom_Events_Frame_MouseDown(button)
    if button == "LeftButton" then
        Custom_Events_Frame:StartMoving();
    end
end

function Custom_Events_Frame_MouseUp(button)
    if button == "LeftButton" then
        Custom_Events_Frame:StopMovingOrSizing();
    end
end