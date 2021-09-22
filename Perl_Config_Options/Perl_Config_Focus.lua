function Perl_Config_Focus_Display()
	Perl_Config_Hide_All();
	if (Perl_Focus_Frame) then
		Perl_Config_Focus_Frame:Show();
		Perl_Config_Focus_Set_Values();
	else
		Perl_Config_Focus_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Focus_Set_Values()
	local vartable = Perl_Focus_GetVars();

	Perl_Config_Focus_Frame_Slider2Low:SetText("0");
	Perl_Config_Focus_Frame_Slider2High:SetText("16");
	Perl_Config_Focus_Frame_Slider2:SetValue(vartable["numbuffsshown"]);

	Perl_Config_Focus_Frame_Slider3Low:SetText("0");
	Perl_Config_Focus_Frame_Slider3High:SetText("16");
	Perl_Config_Focus_Frame_Slider3:SetValue(vartable["numdebuffsshown"]);

	if (vartable["showclassicon"] == 1) then
		Perl_Config_Focus_Frame_CheckButton1:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton1:SetChecked(nil);
	end

	if (vartable["showpvpicon"] == 1) then
		Perl_Config_Focus_Frame_CheckButton3:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton3:SetChecked(nil);
	end

	if (vartable["showclassframe"] == 1) then
		Perl_Config_Focus_Frame_CheckButton4:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton4:SetChecked(nil);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Focus_Frame_CheckButton8:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton8:SetChecked(nil);
	end

	if (vartable["showportrait"] == 1) then
		Perl_Config_Focus_Frame_CheckButton10:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton10:SetChecked(nil);
	end

	if (vartable["threedportrait"] == 1) then
		Perl_Config_Focus_Frame_CheckButton11:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton11:SetChecked(nil);
	end

	if (vartable["portraitcombattext"] == 1) then
		Perl_Config_Focus_Frame_CheckButton12:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton12:SetChecked(nil);
	end

	if (vartable["showrareeliteframe"] == 1) then
		Perl_Config_Focus_Frame_CheckButton13:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton13:SetChecked(nil);
	end

	if (vartable["nameframecombopoints"] == 1) then
		Perl_Config_Focus_Frame_CheckButton14:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton14:SetChecked(nil);
	end

	if (vartable["framestyle"] == 2) then
		Perl_Config_Focus_Frame_CheckButton16:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton16:SetChecked(nil);
	end

	if (vartable["compactmode"] == 1) then
		Perl_Config_Focus_Frame_CheckButton17:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton17:SetChecked(nil);
	end

	if (vartable["compactpercent"] == 1) then
		Perl_Config_Focus_Frame_CheckButton18:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton18:SetChecked(nil);
	end

	if (vartable["hidebuffbackground"] == 1) then
		Perl_Config_Focus_Frame_CheckButton19:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton19:SetChecked(nil);
	end

	if (vartable["shortbars"] == 1) then
		Perl_Config_Focus_Frame_CheckButton20:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton20:SetChecked(nil);
	end

	if (vartable["healermode"] == 1) then
		Perl_Config_Focus_Frame_CheckButton21:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton21:SetChecked(nil);
	end

	if (vartable["displaycastablebuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton23:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton23:SetChecked(nil);
	end

	if (vartable["classcolorednames"] == 1) then
		Perl_Config_Focus_Frame_CheckButton24:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton24:SetChecked(nil);
	end

	if (vartable["showmanadeficit"] == 1) then
		Perl_Config_Focus_Frame_CheckButton25:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton25:SetChecked(nil);
	end

	if (vartable["invertbuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton26:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton26:SetChecked(nil);
	end

	if (vartable["displaycurabledebuff"] == 1) then
		Perl_Config_Focus_Frame_CheckButton27:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton27:SetChecked(nil);
	end

	if (vartable["displaybufftimers"] == 1) then
		Perl_Config_Focus_Frame_CheckButton28:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton28:SetChecked(nil);
	end

	if (vartable["displayonlymydebuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton29:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton29:SetChecked(nil);
	end

	Perl_Config_Focus_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Focus_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Focus_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Focus_Frame_CheckButton9:SetChecked(1);
	else
		Perl_Config_Focus_Frame_CheckButton9:SetChecked(nil);
	end

	Perl_Config_Focus_Frame_Slider4Low:SetText("0");
	Perl_Config_Focus_Frame_Slider4High:SetText("100");
	Perl_Config_Focus_Frame_Slider4:SetValue(vartable["transparency"]*100);

	Perl_Config_Focus_Frame_Slider5Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Focus_Frame_Slider5High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Focus_Frame_Slider5:SetValue(floor(vartable["buffdebuffscale"]*100+0.5));
end

function Perl_Config_Focus_Set_Buffs(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Buffs(value);
	end
end

function Perl_Config_Focus_Set_Debuffs(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Debuffs(value);
	end
end

function Perl_Config_Focus_Class_Icon_Update()
	if (Perl_Config_Focus_Frame_CheckButton1:GetChecked() == 1) then
		Perl_Focus_Set_Class_Icon(1);
	else
		Perl_Focus_Set_Class_Icon(0);
	end
end

function Perl_Config_Focus_PvP_Status_Icon_Update()
	if (Perl_Config_Focus_Frame_CheckButton3:GetChecked() == 1) then
		Perl_Focus_Set_PvP_Status_Icon(1);
	else
		Perl_Focus_Set_PvP_Status_Icon(0);
	end
end

function Perl_Config_Focus_Class_Frame_Update()
	if (Perl_Config_Focus_Frame_CheckButton4:GetChecked() == 1) then
		Perl_Focus_Set_Class_Frame(1);
	else
		Perl_Focus_Set_Class_Frame(0);
	end
end

function Perl_Config_Focus_Lock_Update()
	if (Perl_Config_Focus_Frame_CheckButton8:GetChecked() == 1) then
		Perl_Focus_Set_Lock(1);
	else
		Perl_Focus_Set_Lock(0);
	end
end

function Perl_Config_Focus_Portrait_Update()
	if (Perl_Config_Focus_Frame_CheckButton10:GetChecked() == 1) then
		Perl_Focus_Set_Portrait(1);
	else
		Perl_Focus_Set_Portrait(0);
	end
end

function Perl_Config_Focus_3D_Portrait_Update()
	if (Perl_Config_Focus_Frame_CheckButton11:GetChecked() == 1) then
		Perl_Focus_Set_3D_Portrait(1);
	else
		Perl_Focus_Set_3D_Portrait(0);
	end
end

function Perl_Config_Focus_Portrait_Combat_Text_Update()
	if (Perl_Config_Focus_Frame_CheckButton12:GetChecked() == 1) then
		Perl_Focus_Set_Portrait_Combat_Text(1);
	else
		Perl_Focus_Set_Portrait_Combat_Text(0);
	end
end

function Perl_Config_Focus_Rare_Elite_Update()
	if (Perl_Config_Focus_Frame_CheckButton13:GetChecked() == 1) then
		Perl_Focus_Set_Rare_Elite(1);
	else
		Perl_Focus_Set_Rare_Elite(0);
	end
end

function Perl_Config_Focus_Combo_Name_Frame_Update()
	if (Perl_Config_Focus_Frame_CheckButton14:GetChecked() == 1) then
		Perl_Focus_Set_Combo_Name_Frame(1);
	else
		Perl_Focus_Set_Combo_Name_Frame(0);
	end
end

function Perl_Config_Focus_Alternate_Frame_Style_Update()
	if (Perl_Config_Focus_Frame_CheckButton16:GetChecked() == 1) then
		Perl_Focus_Set_Frame_Style(2);
	else
		Perl_Focus_Set_Frame_Style(1);
	end
end

function Perl_Config_Focus_Compact_Mode_Update()
	if (Perl_Config_Focus_Frame_CheckButton17:GetChecked() == 1) then
		Perl_Focus_Set_Compact_Mode(1);
	else
		Perl_Focus_Set_Compact_Mode(0);
	end
end

function Perl_Config_Focus_Compact_Percents_Update()
	if (Perl_Config_Focus_Frame_CheckButton18:GetChecked() == 1) then
		Perl_Focus_Set_Compact_Percents(1);
	else
		Perl_Focus_Set_Compact_Percents(0);
	end
end

function Perl_Config_Focus_Short_Bars_Update()
	if (Perl_Config_Focus_Frame_CheckButton20:GetChecked() == 1) then
		Perl_Focus_Set_Short_Bars(1);
	else
		Perl_Focus_Set_Short_Bars(0);
	end
end

function Perl_Config_Focus_Buff_Background_Update()
	if (Perl_Config_Focus_Frame_CheckButton19:GetChecked() == 1) then
		Perl_Focus_Set_Buff_Debuff_Background(1);
	else
		Perl_Focus_Set_Buff_Debuff_Background(0);
	end
end

function Perl_Config_Focus_Healer_Update()
	if (Perl_Config_Focus_Frame_CheckButton21:GetChecked() == 1) then
		Perl_Focus_Set_Healer(1);
	else
		Perl_Focus_Set_Healer(0);
	end
end

function Perl_Config_Focus_Class_Buffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton23:GetChecked() == 1) then
		Perl_Focus_Set_Class_Buffs(1);
	else
		Perl_Focus_Set_Class_Buffs(0);
	end
end

function Perl_Config_Focus_Class_Colored_Names_Update()
	if (Perl_Config_Focus_Frame_CheckButton24:GetChecked() == 1) then
		Perl_Focus_Set_Class_Colored_Names(1);
	else
		Perl_Focus_Set_Class_Colored_Names(0);
	end
end

function Perl_Config_Focus_Mana_Deficit_Update()
	if (Perl_Config_Focus_Frame_CheckButton25:GetChecked() == 1) then
		Perl_Focus_Set_Mana_Deficit(1);
	else
		Perl_Focus_Set_Mana_Deficit(0);
	end
end

function Perl_Config_Focus_Invert_Buffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton26:GetChecked() == 1) then
		Perl_Focus_Set_Invert_Buffs(1);
	else
		Perl_Focus_Set_Invert_Buffs(0);
	end
end

function Perl_Config_Focus_Class_Debuffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton27:GetChecked() == 1) then
		Perl_Focus_Set_Class_Debuffs(1);
	else
		Perl_Focus_Set_Class_Debuffs(0);
	end
end

function Perl_Config_Focus_Buff_Timers_Update()
	if (Perl_Config_Focus_Frame_CheckButton28:GetChecked() == 1) then
		Perl_Focus_Set_Buff_Timers(1);
	else
		Perl_Focus_Set_Buff_Timers(0);
	end
end

function Perl_Config_Focus_Only_Self_Debuffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton29:GetChecked() == 1) then
		Perl_Focus_Set_Only_Self_Debuffs(1);
	else
		Perl_Focus_Set_Only_Self_Debuffs(0);
	end
end

function Perl_Config_Focus_Set_Scale(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Focus_Frame_Slider1Text:SetText(value);
			Perl_Config_Focus_Frame_Slider1:SetValue(value);
		end
		Perl_Focus_Set_Scale(value);

		vartable = Perl_Focus_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_Focus_Frame_CheckButton9:SetChecked(1);
		else
			Perl_Config_Focus_Frame_CheckButton9:SetChecked(nil);
		end
	end
end

function Perl_Config_Focus_Set_BuffDebuff_Scale(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Focus_Frame_Slider5Text:SetText(value);
			Perl_Config_Focus_Frame_Slider5:SetValue(value);
		end
		Perl_Focus_Set_BuffDebuff_Scale(value);
	end
end

function Perl_Config_Focus_Set_Transparency(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Transparency(value);
	end
end