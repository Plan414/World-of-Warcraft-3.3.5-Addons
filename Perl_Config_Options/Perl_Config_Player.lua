function Perl_Config_Player_Display()
	Perl_Config_Hide_All();
	if (Perl_Player_Frame) then
		Perl_Config_Player_Frame:Show();
		Perl_Config_Player_Set_Values();
	else
		Perl_Config_Player_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Player_Set_Values()
	local vartable = Perl_Player_GetVars();

	if (vartable["xpbarstate"] == 1) then
		Perl_Config_Player_Frame_CheckButton1:SetChecked(1);
		Perl_Config_Player_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton15:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton3:SetChecked(nil);
	elseif (vartable["xpbarstate"] == 2) then
		Perl_Config_Player_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton2:SetChecked(1);
		Perl_Config_Player_Frame_CheckButton15:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton3:SetChecked(nil);
	elseif (vartable["xpbarstate"] == 3) then
		Perl_Config_Player_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton15:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton3:SetChecked(1);
	elseif (vartable["xpbarstate"] == 4) then
		Perl_Config_Player_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton15:SetChecked(1);
		Perl_Config_Player_Frame_CheckButton3:SetChecked(nil);
	else
		Perl_Config_Player_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton15:SetChecked(nil);
		Perl_Config_Player_Frame_CheckButton3:SetChecked(1);
	end

	if (vartable["compactmode"] == 1) then
		Perl_Config_Player_Frame_CheckButton4:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton4:SetChecked(nil);
	end

	if (vartable["healermode"] == 1) then
		Perl_Config_Player_Frame_CheckButton5:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton5:SetChecked(nil);
	end

	if (vartable["showraidgroup"] == 1) then
		Perl_Config_Player_Frame_CheckButton6:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton6:SetChecked(nil);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Player_Frame_CheckButton8:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton8:SetChecked(nil);
	end

	if (vartable["showportrait"] == 1) then
		Perl_Config_Player_Frame_CheckButton10:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton10:SetChecked(nil);
	end

	if (vartable["compactpercent"] == 1) then
		Perl_Config_Player_Frame_CheckButton11:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton11:SetChecked(nil);
	end

	if (vartable["threedportrait"] == 1) then
		Perl_Config_Player_Frame_CheckButton12:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton12:SetChecked(nil);
	end

	if (vartable["portraitcombattext"] == 1) then
		Perl_Config_Player_Frame_CheckButton13:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton13:SetChecked(nil);
	end

	if (vartable["showdruidbar"] == 1) then
		Perl_Config_Player_Frame_CheckButton14:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton14:SetChecked(nil);
	end

	if (vartable["shortbars"] == 1) then
		Perl_Config_Player_Frame_CheckButton17:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton17:SetChecked(nil);
	end

	if (vartable["classcolorednames"] == 1) then
		Perl_Config_Player_Frame_CheckButton18:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton18:SetChecked(nil);
	end

	if (vartable["hideclasslevelframe"] == 1) then
		Perl_Config_Player_Frame_CheckButton19:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton19:SetChecked(nil);
	end

	if (vartable["showmanadeficit"] == 1) then
		Perl_Config_Player_Frame_CheckButton21:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton21:SetChecked(nil);
	end

	if (vartable["hiddeninraid"] == 1) then
		Perl_Config_Player_Frame_CheckButton22:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton22:SetChecked(nil);
	end

	if (vartable["showpvpicon"] == 1) then
		Perl_Config_Player_Frame_CheckButton23:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton23:SetChecked(nil);
	end

	if (vartable["showbarvalues"] == 1) then
		Perl_Config_Player_Frame_CheckButton24:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton24:SetChecked(nil);
	end

	if (vartable["showraidgroupinname"] == 1) then
		Perl_Config_Player_Frame_CheckButton25:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton25:SetChecked(nil);
	end

	if (vartable["fivesecondrule"] == 1) then
		Perl_Config_Player_Frame_CheckButton27:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton27:SetChecked(nil);
	end

	if (vartable["totemtimers"] == 1) then
		Perl_Config_Player_Frame_CheckButton28:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton28:SetChecked(nil);
	end

	if (vartable["runeframe"] == 1) then
		Perl_Config_Player_Frame_CheckButton29:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton29:SetChecked(nil);
	end

	if (vartable["pvptimer"] == 1) then
		Perl_Config_Player_Frame_CheckButton30:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton30:SetChecked(nil);
	end

	Perl_Config_Player_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Player_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Player_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Player_Frame_CheckButton9:SetChecked(1);
	else
		Perl_Config_Player_Frame_CheckButton9:SetChecked(nil);
	end

	Perl_Config_Player_Frame_Slider2Low:SetText("0");
	Perl_Config_Player_Frame_Slider2High:SetText("100");
	Perl_Config_Player_Frame_Slider2:SetValue(vartable["transparency"]*100);
end

function Perl_Config_Player_XPMode_Update()
	if (Perl_Config_Player_Frame_CheckButton1:GetChecked() == 1) then
		Perl_Player_XPBar_Display(1);
	elseif (Perl_Config_Player_Frame_CheckButton2:GetChecked() == 1) then
		Perl_Player_XPBar_Display(2);
	elseif (Perl_Config_Player_Frame_CheckButton3:GetChecked() == 1) then
		Perl_Player_XPBar_Display(3);
	elseif (Perl_Config_Player_Frame_CheckButton15:GetChecked() == 1) then
		Perl_Player_XPBar_Display(4);
	else
		Perl_Config_Player_Frame_CheckButton3:SetChecked(1);
		Perl_Player_XPBar_Display(3);
	end
end

function Perl_Config_Player_Compact_Update()
	if (Perl_Config_Player_Frame_CheckButton4:GetChecked() == 1) then
		Perl_Player_Set_Compact(1);
	else
		Perl_Player_Set_Compact(0);
	end
end

function Perl_Config_Player_Healer_Update()
	if (Perl_Config_Player_Frame_CheckButton5:GetChecked() == 1) then
		Perl_Player_Set_Healer(1);
	else
		Perl_Player_Set_Healer(0);
	end
end

function Perl_Config_Player_Raid_Update()
	if (Perl_Config_Player_Frame_CheckButton6:GetChecked() == 1) then
		Perl_Player_Set_RaidGroupNumber(1);
	else
		Perl_Player_Set_RaidGroupNumber(0);
	end
end

function Perl_Config_Player_Lock_Update()
	if (Perl_Config_Player_Frame_CheckButton8:GetChecked() == 1) then
		Perl_Player_Set_Lock(1);
	else
		Perl_Player_Set_Lock(0);
	end
end

function Perl_Config_Player_Portrait_Update()
	if (Perl_Config_Player_Frame_CheckButton10:GetChecked() == 1) then
		Perl_Player_Set_Portrait(1);
	else
		Perl_Player_Set_Portrait(0);
	end
end

function Perl_Config_Player_Compact_Percent_Update()
	if (Perl_Config_Player_Frame_CheckButton11:GetChecked() == 1) then
		Perl_Player_Set_Compact_Percent(1);
	else
		Perl_Player_Set_Compact_Percent(0);
	end
end

function Perl_Config_Player_Short_Bars_Update()
	if (Perl_Config_Player_Frame_CheckButton17:GetChecked() == 1) then
		Perl_Player_Set_Short_Bars(1);
	else
		Perl_Player_Set_Short_Bars(0);
	end
end

function Perl_Config_Player_3D_Portrait_Update()
	if (Perl_Config_Player_Frame_CheckButton12:GetChecked() == 1) then
		Perl_Player_Set_3D_Portrait(1);
	else
		Perl_Player_Set_3D_Portrait(0);
	end
end

function Perl_Config_Player_Portrait_Combat_Text_Update()
	if (Perl_Config_Player_Frame_CheckButton13:GetChecked() == 1) then
		Perl_Player_Set_Portrait_Combat_Text(1);
	else
		Perl_Player_Set_Portrait_Combat_Text(0);
	end
end

function Perl_Config_Player_DruidBar_Update()
	if (Perl_Config_Player_Frame_CheckButton14:GetChecked() == 1) then
		Perl_Player_Set_DruidBar(1);
	else
		Perl_Player_Set_DruidBar(0);
	end
end

function Perl_Config_Player_Class_Colored_Names_Update()
	if (Perl_Config_Player_Frame_CheckButton18:GetChecked() == 1) then
		Perl_Player_Set_Class_Colored_Names(1);
	else
		Perl_Player_Set_Class_Colored_Names(0);
	end
end

function Perl_Config_Player_Hide_Class_Level_Frame_Update()
	if (Perl_Config_Player_Frame_CheckButton19:GetChecked() == 1) then
		Perl_Player_Set_Hide_Class_Level_Frame(1);
	else
		Perl_Player_Set_Hide_Class_Level_Frame(0);
	end
end

function Perl_Config_Player_Mana_Deficit_Update()
	if (Perl_Config_Player_Frame_CheckButton21:GetChecked() == 1) then
		Perl_Player_Set_Mana_Deficit(1);
	else
		Perl_Player_Set_Mana_Deficit(0);
	end
end

function Perl_Config_Player_Hidden_In_Raids_Update()
	if (Perl_Config_Player_Frame_CheckButton22:GetChecked() == 1) then
		Perl_Player_Set_Hidden_In_Raids(1);
	else
		Perl_Player_Set_Hidden_In_Raids(0);
	end
end

function Perl_Config_Player_PvP_Icon_Update()
	if (Perl_Config_Player_Frame_CheckButton23:GetChecked() == 1) then
		Perl_Player_Set_PvP_Icon(1);
	else
		Perl_Player_Set_PvP_Icon(0);
	end
end

function Perl_Config_Player_Show_Bar_Values_Update()
	if (Perl_Config_Player_Frame_CheckButton24:GetChecked() == 1) then
		Perl_Player_Set_Show_Bar_Values(1);
	else
		Perl_Player_Set_Show_Bar_Values(0);
	end
end

function Perl_Config_Player_Show_Raid_Group_In_Name_Update()
	if (Perl_Config_Player_Frame_CheckButton25:GetChecked() == 1) then
		Perl_Player_Set_Show_Raid_Group_In_Name(1);
	else
		Perl_Player_Set_Show_Raid_Group_In_Name(0);
	end
end

function Perl_Config_Player_Show_Five_second_Rule_Update()
	if (Perl_Config_Player_Frame_CheckButton27:GetChecked() == 1) then
		Perl_Player_Set_Show_Five_second_Rule(1);
	else
		Perl_Player_Set_Show_Five_second_Rule(0);
	end
end

function Perl_Config_Player_Show_Totem_Timers_Update()
	if (Perl_Config_Player_Frame_CheckButton28:GetChecked() == 1) then
		Perl_Player_Set_Show_Totem_Timers(1);
	else
		Perl_Player_Set_Show_Totem_Timers(0);
	end
end

function Perl_Config_Player_Show_Rune_Frame_Update()
	if (Perl_Config_Player_Frame_CheckButton29:GetChecked() == 1) then
		Perl_Player_Set_Show_Rune_Frame(1);
	else
		Perl_Player_Set_Show_Rune_Frame(0);
	end
end

function Perl_Config_Player_Show_PvP_Timer_Update()
	if (Perl_Config_Player_Frame_CheckButton30:GetChecked() == 1) then
		Perl_Player_Set_Show_PvP_Timer(1);
	else
		Perl_Player_Set_Show_PvP_Timer(0);
	end
end

function Perl_Config_Player_Set_Scale(value)
	if (Perl_Player_Frame) then	-- this check is to prevent errors if you aren't using Player
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Player_Frame_Slider1Text:SetText(value);
			Perl_Config_Player_Frame_Slider1:SetValue(value);
		end
		Perl_Player_Set_Scale(value);

		vartable = Perl_Player_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_Player_Frame_CheckButton9:SetChecked(1);
		else
			Perl_Config_Player_Frame_CheckButton9:SetChecked(nil);
		end
	end
end

function Perl_Config_Player_Set_Transparency(value)
	if (Perl_Player_Frame) then	-- this check is to prevent errors if you aren't using Player
		Perl_Player_Set_Transparency(value);
	end
end
