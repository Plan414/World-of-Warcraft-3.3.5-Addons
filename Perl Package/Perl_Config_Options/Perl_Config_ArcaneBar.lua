function Perl_Config_ArcaneBar_Display()
	Perl_Config_Hide_All();
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_Config_ArcaneBar_Frame:Show();
		Perl_Config_ArcaneBar_Set_Values();
	else
		Perl_Config_ArcaneBar_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_ArcaneBar_Set_Values()
	local vartable = Perl_ArcaneBar_GetVars();

	if (vartable["playerenabled"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton1:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton1:SetChecked(nil);
	end

	if (vartable["playershowtimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton2:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton2:SetChecked(nil);
	end

	if (vartable["playerlefttimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton5:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton5:SetChecked(nil);
	end

	if (vartable["playernamereplace"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton4:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton4:SetChecked(nil);
	end

	if (vartable["targetenabled"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton6:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton6:SetChecked(nil);
	end

	if (vartable["targetshowtimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton7:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton7:SetChecked(nil);
	end

	if (vartable["targetlefttimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton8:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton8:SetChecked(nil);
	end

	if (vartable["targetnamereplace"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton9:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton9:SetChecked(nil);
	end

	if (vartable["focusenabled"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton10:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton10:SetChecked(nil);
	end

	if (vartable["focusshowtimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton11:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton11:SetChecked(nil);
	end

	if (vartable["focuslefttimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton12:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton12:SetChecked(nil);
	end

	if (vartable["focusnamereplace"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton13:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton13:SetChecked(nil);
	end

	if (vartable["partyenabled"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton14:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton14:SetChecked(nil);
	end

	if (vartable["partyshowtimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton15:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton15:SetChecked(nil);
	end

	if (vartable["partylefttimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton16:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton16:SetChecked(nil);
	end

	if (vartable["partynamereplace"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton17:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton17:SetChecked(nil);
	end

	if (vartable["hideoriginal"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton3:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton3:SetChecked(nil);
	end

	Perl_Config_ArcaneBar_Frame_Slider1Low:SetText("0");
	Perl_Config_ArcaneBar_Frame_Slider1High:SetText("100");
	Perl_Config_ArcaneBar_Frame_Slider1:SetValue(vartable["transparency"]*100);

	if (Perl_Target_Frame == nil) then
		Perl_Config_ArcaneBar_Frame_Target_Text:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton6:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton7:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton8:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton9:Hide();
	end

	if (Perl_Focus_Frame == nil) then
		Perl_Config_ArcaneBar_Frame_Focus_Text:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton10:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton11:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton12:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton13:Hide();
	end

	if (Perl_Party_Frame == nil) then
		Perl_Config_ArcaneBar_Frame_Party_Text:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton14:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton15:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton16:Hide();
		Perl_Config_ArcaneBar_Frame_CheckButton17:Hide();
	end
end

function Perl_Config_ArcaneBar_Player_Enabled_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton1:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Player_Enabled(1);
	else
		Perl_ArcaneBar_Set_Player_Enabled(0);
	end
end

function Perl_Config_ArcaneBar_Player_Show_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton2:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Player_Show_Timer(1);
	else
		Perl_ArcaneBar_Set_Player_Show_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Player_Left_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton5:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Player_Left_Timer(1);
	else
		Perl_ArcaneBar_Set_Player_Left_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Player_Name_Replace_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton4:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Player_Name_Replace(1);
	else
		Perl_ArcaneBar_Set_Player_Name_Replace(0);
	end
end

function Perl_Config_ArcaneBar_Target_Enabled_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton6:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Target_Enabled(1);
	else
		Perl_ArcaneBar_Set_Target_Enabled(0);
	end
end

function Perl_Config_ArcaneBar_Target_Show_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton7:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Target_Show_Timer(1);
	else
		Perl_ArcaneBar_Set_Target_Show_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Target_Left_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton8:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Target_Left_Timer(1);
	else
		Perl_ArcaneBar_Set_Target_Left_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Target_Name_Replace_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton9:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Target_Name_Replace(1);
	else
		Perl_ArcaneBar_Set_Target_Name_Replace(0);
	end
end

function Perl_Config_ArcaneBar_Focus_Enabled_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton10:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Focus_Enabled(1);
	else
		Perl_ArcaneBar_Set_Focus_Enabled(0);
	end
end

function Perl_Config_ArcaneBar_Focus_Show_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton11:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Focus_Show_Timer(1);
	else
		Perl_ArcaneBar_Set_Focus_Show_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Focus_Left_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton12:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Focus_Left_Timer(1);
	else
		Perl_ArcaneBar_Set_Focus_Left_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Focus_Name_Replace_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton13:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Focus_Name_Replace(1);
	else
		Perl_ArcaneBar_Set_Focus_Name_Replace(0);
	end
end

function Perl_Config_ArcaneBar_Party_Enabled_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton14:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Party_Enabled(1);
	else
		Perl_ArcaneBar_Set_Party_Enabled(0);
	end
end

function Perl_Config_ArcaneBar_Party_Show_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton15:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Party_Show_Timer(1);
	else
		Perl_ArcaneBar_Set_Party_Show_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Party_Left_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton16:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Party_Left_Timer(1);
	else
		Perl_ArcaneBar_Set_Party_Left_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Party_Name_Replace_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton17:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Party_Name_Replace(1);
	else
		Perl_ArcaneBar_Set_Party_Name_Replace(0);
	end
end

function Perl_Config_ArcaneBar_Hide_Original_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton3:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Hide_Original(1);
	else
		Perl_ArcaneBar_Set_Hide_Original(0);
	end
end

function Perl_Config_ArcaneBar_Set_Transparency(value)
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then	-- this check is to prevent errors if you aren't using ArcaneBar
		Perl_ArcaneBar_Set_Transparency(value);
	end
end
