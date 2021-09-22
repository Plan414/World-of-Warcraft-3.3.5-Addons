function Perl_Config_CombatDisplay_Display()
	Perl_Config_Hide_All();
	if (Perl_CombatDisplay_Frame) then
		Perl_Config_CombatDisplay_Frame:Show();
		Perl_Config_CombatDisplay_Set_Values();
	else
		Perl_Config_CombatDisplay_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_CombatDisplay_Set_Values()
	local vartable = Perl_CombatDisplay_GetVars();

	if (vartable["state"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	elseif (vartable["state"] == 2) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	elseif (vartable["state"] == 3) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(1);
	end
	Perl_Config_CombatDisplay_Frame_CheckButton2:Hide();

	if (vartable["healthpersist"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton5:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton5:SetChecked(nil);
	end

	if (vartable["manapersist"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton6:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton6:SetChecked(nil);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton8:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton8:SetChecked(nil);
	end

	Perl_Config_CombatDisplay_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_CombatDisplay_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_CombatDisplay_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(nil);
	end

	Perl_Config_CombatDisplay_Frame_Slider2Low:SetText("0");
	Perl_Config_CombatDisplay_Frame_Slider2High:SetText("100");
	Perl_Config_CombatDisplay_Frame_Slider2:SetValue(vartable["transparency"]*100);

	if (vartable["showtarget"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton10:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton10:SetChecked(nil);
	end

	if (vartable["showdruidbar"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton12:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton12:SetChecked(nil);
	end

	if (vartable["showpetbars"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton13:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton13:SetChecked(nil);
	end

	if (vartable["rightclickmenu"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton14:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton14:SetChecked(nil);
	end

	if (vartable["displaypercents"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton16:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton16:SetChecked(nil);
	end

	if (vartable["showcp"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton17:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton17:SetChecked(nil);
	end

	if (vartable["clickthrough"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton18:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton18:SetChecked(nil);
	end
end

function Perl_Config_CombatDisplay_Mode_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton1:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(1);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton2:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(2);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton3:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(3);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton4:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(0);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(1);
		Perl_CombatDisplay_Set_State(0);
	end
end

function Perl_Config_CombatDisplay_Health_Persistance_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton5:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Health_Persistance(1);
	else
		Perl_CombatDisplay_Set_Health_Persistance(0);
	end
end

function Perl_Config_CombatDisplay_Mana_Persistance_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton6:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Mana_Persistance(1);
	else
		Perl_CombatDisplay_Set_Mana_Persistance(0);
	end
end

function Perl_Config_CombatDisplay_Lock_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton8:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Lock(1);
	else
		Perl_CombatDisplay_Set_Lock(0);
	end
end

function Perl_Config_CombatDisplay_Target_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton10:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Target(1);
	else
		Perl_CombatDisplay_Set_Target(0);
	end
end

function Perl_Config_CombatDisplay_DruidBar_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton12:GetChecked() == 1) then
		Perl_CombatDisplay_Set_DruidBar(1);
	else
		Perl_CombatDisplay_Set_DruidBar(0);
	end
end

function Perl_Config_CombatDisplay_PetBars_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton13:GetChecked() == 1) then
		Perl_CombatDisplay_Set_PetBars(1);
	else
		Perl_CombatDisplay_Set_PetBars(0);
	end
end

function Perl_Config_CombatDisplay_Right_Click_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton14:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Right_Click(1);
	else
		Perl_CombatDisplay_Set_Right_Click(0);
	end
end

function Perl_Config_CombatDisplay_Display_Percents_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton16:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Display_Percents(1);
	else
		Perl_CombatDisplay_Set_Display_Percents(0);
	end
end

function Perl_Config_CombatDisplay_ComboPoint_Bars_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton17:GetChecked() == 1) then
		Perl_CombatDisplay_Set_ComboPoint_Bars(1);
	else
		Perl_CombatDisplay_Set_ComboPoint_Bars(0);
	end
end

function Perl_Config_CombatDisplay_Click_Through_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton18:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Click_Through(1);
	else
		Perl_CombatDisplay_Set_Click_Through(0);
	end
end

function Perl_Config_CombatDisplay_Set_Scale(value)
	if (Perl_CombatDisplay_Frame) then	-- this check is to prevent errors if you aren't using CombatDisplay
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_CombatDisplay_Frame_Slider1Text:SetText(value);
			Perl_Config_CombatDisplay_Frame_Slider1:SetValue(value);
		end
		Perl_CombatDisplay_Set_Scale(value);

		vartable = Perl_CombatDisplay_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(1);
		else
			Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(nil);
		end
	end
end

function Perl_Config_CombatDisplay_Set_Transparency(value)
	if (Perl_CombatDisplay_Frame) then	-- this check is to prevent errors if you aren't using CombatDisplay
		Perl_CombatDisplay_Set_Transparency(value);
	end
end
