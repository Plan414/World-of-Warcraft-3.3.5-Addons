--With great thanks to fara.webeddie.com/frames for all the great tutorials that taught me xml.


function Binder_OnLoad()
  out_frame("Binder is Loaded. Use /binder to open window");
  this:RegisterEvent( "VARIABLES_LOADED" );
  SLASH_BINDER1 = "/Binder";
  SlashCmdList["BINDER"] = function(msg)
		Binder_SlashCommandHandler(msg);
	end
end

function Binder_OnEvent()
	if ( event == "VARIABLES_LOADED" ) then
		Binder_MinimapButton_Reposition();
		end		
 end

--This appears in your chat frame
function out_frame(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

--This appears on the top of your screen
function out(text)
	UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end
	
function Binder_SlashCommandHandler()
  Binder_Toggle();
end

function Binder_Toggle()
	local frame = getglobal("Binder_Frame")
	if (frame) then
	if (  frame:IsVisible()  ) then
		--When the Frame Goes away
		frame:Hide();
		Binder_Title:Hide();
		--Inside_Frame1:Hide();
		Description_InputBox:Hide();
		Name_Input_Frame:Hide();
		ApplyOrDelete_Frame:Hide();
		Description_Frame:Hide();
		Selection_Frame:Hide();
		Loading_Frame:Hide();
		Options_Frame:Hide();
		Creation_Frame:Hide();
		Description_Input_Frame:Hide();
		Divider_Frame1:Hide();
		Divider_Frame2:Hide();
		Name_InputBox:SetText("");
		Description_InputBox:SetText("");
		Selection = false;
	else
		--When the Frame is Shown again
		frame:Show();
		Binder_Title:Show();
		--Inside_Frame1:Show();
		Name_Input_Frame:Show();
		Description_InputBox:Show();
		ApplyOrDelete_Frame:Show();
		Description_Frame:Show();
		Selection_Frame:Show();
		Loading_Frame:Show();
		Options_Frame:Show();
		Creation_Frame:Show();
		Description_Input_Frame:Show();
		Divider_Frame1:Show();
		Divider_Frame2:Show();
		Name_InputBox:SetText("");
		Description_InputBox:SetText("");
		Selection = false;
	end
	end
end


--Global Variables
ProfileName_OnButton = "";
Currently_Selected_Profile_Num = 0;
Selection = false;

--The Scrolling Frame
function BinderScrollBar_Update()

	local line; 
	local lineplusoffset;
	FauxScrollFrame_Update(BinderScrollBar,Binder_Settings.ProfilesCreated,5,19);
	for line = 1, 5 do 
		lineplusoffset = line + FauxScrollFrame_GetOffset(BinderScrollBar);
		if ( lineplusoffset < (Binder_Settings.ProfilesCreated + 1) ) then
			getglobal("BinderEntry"..line):SetText(Binder_Settings.Profiles[lineplusoffset].Name);
			getglobal("BinderEntry"..line):Show();
		else
			getglobal("BinderEntry"..line):Hide();
		end
	end
	
	if (Currently_Selected_Profile_Num == 0)then
		else
			if (BinderEntry1:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
				BinderEntry1:LockHighlight()
				else
				BinderEntry1:UnlockHighlight();
			end
			
			if (BinderEntry2:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
				BinderEntry2:LockHighlight()
				else
				BinderEntry2:UnlockHighlight();
			end
			
			if (BinderEntry3:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
				BinderEntry3:LockHighlight()
				else
				BinderEntry3:UnlockHighlight();
			end
				
			if (BinderEntry4:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
				BinderEntry4:LockHighlight()
				else
				BinderEntry4:UnlockHighlight();
			end
				
			if (BinderEntry5:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
				BinderEntry5:LockHighlight()
				else
				BinderEntry5:UnlockHighlight();
			end
		end
end

--When you click on a profile
function ProfileSelection_OnClick()
	ProfileName_OnButton = this:GetText()
	
	--Sets Currently_Selected_Profile_Num to the profile number on button you pushed
	for i = 1, Binder_Settings.ProfilesCreated do 
		if ( ProfileName_OnButton ~= Binder_Settings.Profiles[i].Name )then
		end
		if ( ProfileName_OnButton == Binder_Settings.Profiles[i].Name )then
			Currently_Selected_Profile_Num = i
		end
	end
	Description_Update(Currently_Selected_Profile_Num)
	Selection = true
	
	BinderScrollBar_Update()
	--Add the middle option here
	
	--for i=1,5 do
	--	Current_Button = "BinderEntry"..i
	--	Current_Button_Name = Current_Button:GetText()
	--	if (Current_Button_Name == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name)then
	--		Current_Button:LockHighlight()
	--	else
	--		Current_Button:UnlockHighlight()
	--	end
	--end
	
	
end
	
function Description_Update(profilenum)
	if (profilenum == nil)then
	else
		Description_Frame_Text2:SetText(Binder_Settings.Profiles[profilenum].Description)
	end
end

----------------------------------------------------------------------

--These are all of the keybinds that get set when you push the corresponding button

--you really don't need to change the name of the action, unless you know what you are doing well
function Tensai1_OnClick(arg1)
--here you can change what you want it to say at the top of the screen when you push a button
	out("Keybindings have been set to profile: Tensai (Default UI)")
	--this makes sure all other keybinds get set back to default
	LoadBindings(DEFAULT_BINDINGS)
	--This is where you actually set the keybinds
	--here is the format
	--SetBinding("the button you want to set something as","what gets clicked when you push the button")
	SetBinding("SHIFT-1","MULTIACTIONBAR1BUTTON1")
	SetBinding("SHIFT-2","MULTIACTIONBAR1BUTTON2")
	SetBinding("SHIFT-3","MULTIACTIONBAR1BUTTON3")
	SetBinding("SHIFT-4","MULTIACTIONBAR1BUTTON4")
	SetBinding("SHIFT-5","MULTIACTIONBAR1BUTTON5")
	SetBinding("SHIFT-Q","MULTIACTIONBAR1BUTTON6")
	SetBinding("SHIFT-W","MULTIACTIONBAR1BUTTON7")
	SetBinding("SHIFT-E","MULTIACTIONBAR1BUTTON8")
	SetBinding("SHIFT-R","MULTIACTIONBAR1BUTTON9")
	SetBinding("SHIFT-A","MULTIACTIONBAR1BUTTON10")
	SetBinding("SHIFT-S","MULTIACTIONBAR1BUTTON11")
	SetBinding("SHIFT-D","MULTIACTIONBAR1BUTTON12")
	SetBinding("SHIFT-F","MULTIACTIONBAR2BUTTON1")
	SetBinding("F","MULTIACTIONBAR2BUTTON2")
	SetBinding("SHIFT-SPACE","MULTIACTIONBAR2BUTTON3")
	SetBinding("BUTTON3","MULTIACTIONBAR2BUTTON9")
	SetBinding("SHIFT-BUTTON3","MULTIACTIONBAR2BUTTON10")
	SetBinding("CRTL-BUTTON3","MULTIACTIONBAR2BUTTON11")
	SetBinding("SHIFT-H","MULTIACTIONBAR2BUTTON12")
	
	--You can find your own keybinds in the WTF folder inside of World of Warcraft program file
	--it will just be a simple text file
	
	--Thanks, any questions just e-mail me at JTensai24@gmail.com or go to my addon blog at tensai-addons.blogspot.com
	
	
	
	
end


function Create_Button_OnUpdate()
	
	if (Name_InputBox:GetText() == "") then
		Create_Button:Disable()
		else
		Create_Button:Enable()
		end
end

--creation on hover stuff
function Binder_CreateButton_Details(tt, ldb)
	tt:SetText("This will create a new Keybind Profile with|nthe inputed name using your current Keybinds.|n(Description is optional)")
end

function Binder_CreateButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_CreateButton_Details(GameTooltip)
end

Binder_Settings = {
	ProfilesCreated = 0,
	Profiles = {}
}

--The Almighty Button that WILL create your new profile
function Create_OnClick(arg1)

	local NewProfileNum = Binder_Settings.ProfilesCreated +1;
	Binder_Settings.Profiles[NewProfileNum] = {Name = Name_InputBox:GetText(),
												Description = Description_InputBox:GetText(),
												The_Binds = {}
											}
											
	out_frame("Binder Profile Created: " .. Name_InputBox:GetText()) 
	
	--If something is written in the Description box when saved, this shows in the chat screen
	if (Description_InputBox:GetText() ~= "") then
		out_frame("You entered " .. Description_InputBox:GetText().. " as the description for the Profile")
	end
	
	--Creates the Bind Table and saves all the binds to it
	Create_Binds()
	
	--Updates the number of profiles created
	Binder_Settings.ProfilesCreated = Binder_Settings.ProfilesCreated + 1
		
	out("Profile Created: "..Binder_Settings.Profiles[Binder_Settings.ProfilesCreated].Name)
	
	Name_InputBox:SetText("");
	Description_InputBox:SetText("");
	
	BinderScrollBar_Update()	
end

function Create_Binds()

	local TheAction, BindingOne, BindingTwo;
	local TotalBinds = GetNumBindings();
	local NewProfileNum = Binder_Settings.ProfilesCreated +1;
	
	for i = 1, TotalBinds do
		TheAction, BindingOne, BindingTwo = GetBinding(i)
		
		--Something is needed here to over write the keybinds that exist in another table, but not in the saved one
		
		--if (BindingOne == nil) then
		--	BindingOne = nil
		--end
		
		
		Binder_Settings.Profiles[NewProfileNum].The_Binds[i] = {["TheAction"] = TheAction, 
																["BindingOne"] = BindingOne, 
																["BindingTwo"] = BindingTwo
																}
		
																
	end
end

function TestMe_OnClick(arg1)
	
	--if (Currently_Selected_Profile_Num ~= nil and Currently_Selected_Profile_Num ~= 0)then
	out_frame(Currently_Selected_Profile_Num)
		for i = 1, Binder_Settings.ProfilesCreated do
			Binder_Settings.Profiles[i] = nil
		end
	
	Binder_Settings.ProfilesCreated = 0
	out_frame("The update isn't working...")
	BinderScrollBar_Update()
	out_frame("All are nil again")
	--else
		--out_frame("Select a profile")
	--end
	
end
	

-- Minimap coding

BinderMinimapSettings = {
	xposition = 200;
	yposition = 0; -- default position of the minimap icon
}

function Binder_MinimapButton_Reposition()
	local xlim = (((GetScreenWidth() * UIParent:GetEffectiveScale())/2))
	local ylim = (((GetScreenHeight() * UIParent:GetEffectiveScale())/2))
	
	if ( BinderMinimapSettings.xposition > xlim) then
		BinderMinimapSettings.xposition = xlim
		end
	if ( BinderMinimapSettings.xposition < (-1) * xlim) then
		BinderMinimapSettings.xposition = (-1) * xlim
		end
	if ( BinderMinimapSettings.yposition > ylim) then
		BinderMinimapSettings.yposition = ylim
		end
	if ( BinderMinimapSettings.yposition < (-1) * ylim) then
		BinderMinimapSettings.yposition = (-1) * ylim
		end
	
	Binder_MinimapButton:SetPoint("CENTER",BinderMinimapSettings.xposition,BinderMinimapSettings.yposition)
end

function Binder_MinimapButton_DraggingFrame_OnUpdate()
	
	local xcursor, ycursor = GetCursorPosition()
	local xpos = (xcursor - ((GetScreenWidth() * UIParent:GetEffectiveScale())/2));
	local ypos = (ycursor - ((GetScreenHeight() * UIParent:GetEffectiveScale())/2));
	
	BinderMinimapSettings.xposition = xpos
	BinderMinimapSettings.yposition = ypos
	
	Binder_MinimapButton_Reposition() 
end

function Binder_MinimapButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_LEFT")
	Binder_MinimapButton_Details(GameTooltip)
end

function Binder_MinimapButton_Details(tt, ldb)
	tt:SetText("Binder|n|nLeft Click: Open Frame|nRight Click: Drag)")
end

function Minimap_Reset(arg1)
	BinderMinimapSettings.xposition = 0
	BinderMinimapSettings.yposition = 0
	Binder_MinimapButton_Reposition()
end

function Minimap_Reset_Details(tt, ldb)
	tt:SetText("Will reset the position of the|nminimap button to center screen")
end

function Minimap_Reset_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Minimap_Reset_Details(GameTooltip)
end

function Minimap_Checkbox_OnUpdate()
	if (Minimap_CheckButton1:GetChecked() == 1) then
	
		Binder_MinimapButton:Hide();
		showornot = 0;
		--Options_Frame_RadioButton1:Disable()
		--Options_Frame_RadioButton2:Disable()
		
	else
		Binder_MinimapButton:Show();
		
		--Options_Frame_RadioButton1:Enable()
		--Options_Frame_RadioButton2:Enable()
		
		showornot = 1;
	end
end

--Stuff for the Apply Button
function Binder_ApplyButton_Details(tt, ldb)
	tt:SetText("This Button will Apply|nthe currently selected|nBinder profile")
end

function Binder_ApplyButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_ApplyButton_Details(GameTooltip)
end

function Apply_OnClick(arg1)

	LoadBindings(0)
	SetBinding("1")
	SetBinding("2")
	SetBinding("3")
	SetBinding("4")
	SetBinding("5")
	SetBinding("6")
	SetBinding("7")
	SetBinding("8")
	SetBinding("9")
	SetBinding("0")
	SetBinding("-")
	SetBinding("=")
	
	--LoadBindings(2)
	
	for i = 1, GetNumBindings() do 
		local TheAction = Binder_Settings.Profiles[Currently_Selected_Profile_Num].The_Binds[i].TheAction
		local BindingOne = Binder_Settings.Profiles[Currently_Selected_Profile_Num].The_Binds[i].BindingOne
		local BindingTwo = Binder_Settings.Profiles[Currently_Selected_Profile_Num].The_Binds[i].BindingTwo
		
		if (BindingOne ~= nil)then
			SetBinding(BindingOne, TheAction)
		end
		if (BindingOne == nil)then
			--SetBinding(BindingOne)
		end
			
		if (BindingTwo ~= nil)then
			SetBinding(BindingTwo, TheAction)
		end
		if (BindingTwo == nil)then
			--SetBinding(BindingTwo)
		end
	end
	
	--SaveBindings(2)
	out_frame("Profile "..ProfileName_OnButton.." has been loaded")
end

function Apply_Button_OnUpdate()
	
	if (Selection == false) then
		Apply_Button:Disable()
		end
	if (Selection == true) then
		Apply_Button:Enable()
		end
end


--Stuff for the Delete Button
function Binder_DeleteButton_Details(tt, ldb)
	tt:SetText("WARNING!!! If you delete a|nprofile, you CANNOT get it back|n|nSo be careful...)")
end

function Binder_DeleteButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_DeleteButton_Details(GameTooltip)
end


-- Something here is not working the right way!
function Delete_OnClick(arg1)
	
	out_frame("Profile "..ProfileName_OnButton.." was deleted")
	if (Currently_Selected_Profile_Num < Binder_Settings.ProfilesCreated)then
		for i = Currently_Selected_Profile_Num, Binder_Settings.ProfilesCreated-1 do
			Binder_Settings.Profiles[i] = Binder_Settings.Profiles[i + 1]
		end
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
	else
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
 	end
	
	Binder_Settings.ProfilesCreated = Binder_Settings.ProfilesCreated-1
	Currently_Selected_Profile_Num = 0
	Selection = false
	BinderScrollBar_Update()
	
end

function Hide_Areyousure()
	Areyousure_Frame:Hide()
end

function Delete_Button_OnUpdate()
	if (Selection == false) then
		Delete_Button:Disable()
		end
	
	if (Selection == true) then
		Delete_Button:Enable()
		end
end

function DeleteAll_Button_OnClick()
	for i = 1, Binder_Settings.ProfilesCreated do
		Binder_Settings.Profiles[i] = nil
	end
	Binder_Settings.ProfilesCreated = 0
	BinderScrollBar_Update()
	out_frame("All profiles are erased.")
end

function DeleteAll_Button_OnUpdate()
	
	if (Currently_Selected_Profile_Num == 0)then
	else
		if (Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name == "Delete All") then
			DeleteAll_Button:Enable()
		else 
			DeleteAll_Button:Disable()
		end
	end
end

function Close_Button_Details(tt, ldb)
	tt:SetText("Close")
end

function Close_Button_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Close_Button_Details(GameTooltip)
end




