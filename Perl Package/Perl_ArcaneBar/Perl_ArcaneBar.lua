--	ArcaneBar
--		Adds a second casting bar to the player frame.
--	
--	By: Zlixar
--	
--	Adds a second casting bar to the player frame.
--	
--	Modified by Nymbia for Nymbia's Perl Unitframes
--	Heavily modified again by Global for Perl Classic Unit Frames

---------------
-- Variables --
---------------
Perl_ArcaneBar_Config = {};

-- Default Saved Variables (also set in Perl_ArcaneBar_GetVars)
local playerenabled = 1;
local targetenabled = 1;
local focusenabled = 1;
local partyenabled = 1;
local playershowtimer = 1;
local targetshowtimer = 1;
local focusshowtimer = 1;
local partyshowtimer = 1;
local playerlefttimer = 0;
local targetlefttimer = 1;
local focuslefttimer = 1;
local partylefttimer = 0;
local playernamereplace = 0;
local targetnamereplace = 0;
local focusnamereplace = 0;
local partynamereplace = 0;
local hideoriginal = 1;
local transparency = 1;

-- Default Local Variables
local Initialized = nil;		-- waiting to be initialized
local runonce = 0;
local Perl_ArcaneBar_Colors = {		-- color table
	main = {r = 1.0, g = 0.7, b = 0.0},
	channel = {r = 0.0, g = 1.0, b = 0.0},
	success = {r = 0.0, g = 1.0, b = 0.0},
	failure = {r = 1.0, g = 0.0, b = 0.0}
}


----------------------
-- Loading Function --
----------------------
function Perl_ArcaneBar_OnLoad(self)
	self.unit = string.sub(self:GetName(), 16);
	self.barFlash = getglobal(self:GetName().."_Flash");
	self.barSpark = getglobal(self:GetName().."Spark");
	self.castTimeText = getglobal(self:GetName().."_CastTime");

	if (self.unit == "player") then
		self.nameframetext = Perl_Player_NameBarText;
		self.parentframe = Perl_Player_Frame;
	elseif (self.unit == "target") then
		self.nameframetext = Perl_Target_NameBarText;
	elseif (self.unit == "focus") then
		self.nameframetext = Perl_Focus_NameBarText;
	elseif (self.unit == "party1") then
		self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
		self.parentframe = Perl_Party_MemberFrame1;
	elseif (self.unit == "party2") then
		self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
		self.parentframe = Perl_Party_MemberFrame2;
	elseif (self.unit == "party3") then
		self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
		self.parentframe = Perl_Party_MemberFrame3;
	elseif (self.unit == "party4") then
		self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
		self.parentframe = Perl_Party_MemberFrame4;
	end

	self.nameframewidth = 0;

	-- Defaults
	self.casting = nil;
	self.channeling = nil;
	self.delaySum = 0;
	self.holdTime = 0;
	self.unitname = nil;
end


---------------------------
-- Event/Update Handlers --
---------------------------
function Perl_ArcaneBar_Loaded_Frame_OnEvent()
	if (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") then
		Perl_ArcaneBar_Initialize();
	end
end

function Perl_ArcaneBar_OnEvent(self, event, arg1, arg2)
	if (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") then
		self.unitname = UnitName(self.unit);
		if (UnitChannelInfo(self.unit)) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
		elseif (UnitCastingInfo(self.unit)) then
			event = "UNIT_SPELLCAST_START";
		else
			self.casting = nil;
			self.channeling = nil;
			self:Hide();
			return;
		end
		arg1 = self.unit;
	end

	if (arg1 ~= self.unit) then
		return;
	end

	if (self.parentframe) then
		if (not self.parentframe:IsShown()) then
			return;
		end
	end

	if (event == "UNIT_SPELLCAST_START") then
		local text, _, _, _, startTime, endTime, _ = UnitCastingInfo(arg1);

		self:SetStatusBarColor(Perl_ArcaneBar_Colors.main.r, Perl_ArcaneBar_Colors.main.g, Perl_ArcaneBar_Colors.main.b, transparency);
		self.barSpark:Show();
		self.startTime = startTime / 1000;
		self.maxValue = endTime / 1000;
		self:SetMinMaxValues(self.startTime, self.maxValue);
		self:SetValue(self.startTime);

		if (self.namereplace == 1) then
			if (self.nameframetext == nil) then
				if (self.unit == "player") then
					self.nameframetext = Perl_Player_NameBarText;
					self.parentframe = Perl_Player_Frame;
				elseif (self.unit == "target") then
					self.nameframetext = Perl_Target_NameBarText;
				elseif (self.unit == "focus") then
					self.nameframetext = Perl_Focus_NameBarText;
				elseif (self.unit == "party1") then
					self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame1;
				elseif (self.unit == "party2") then
					self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame2;
				elseif (self.unit == "party3") then
					self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame3;
				elseif (self.unit == "party4") then
					self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame4;
				end
			end
			self.nameframetext:SetText(text);
		end

		self:SetAlpha(0.8);
		self.holdTime = 0;
		self.casting = 1;
		self.channeling = nil;
		self.fadeOut = nil;
		self.delaySum = 0;
		self:Show();

		if (self.showtimer == 1) then
			self.castTimeText:Show();
		else
			self.castTimeText:Hide();
		end
	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		if (self:IsShown()) then
			if (self.channeling == nil) then
				self.barSpark:Hide();
			end
			self.barFlash:SetAlpha(0.0);
			self.barFlash:Show();
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(Perl_ArcaneBar_Colors.success.r, Perl_ArcaneBar_Colors.success.g, Perl_ArcaneBar_Colors.success.b, transparency);
			if (event == "UNIT_SPELLCAST_STOP") then
				self.casting = nil;
			else
				self.channeling = nil;
			end
			self.delaySum = 0;
			self.flash = 1;
			self.fadeOut = 1;
			self.holdTime = 0;

			if (self.showtimer == 1) then
				self.castTimeText:Show();
			end
		end

		if (self.namereplace == 1) then
			if (self.casting == nil and self.channeling == nil) then
				if (self.nameframetext == nil) then
					if (self.unit == "player") then
						self.nameframetext = Perl_Player_NameBarText;
						self.parentframe = Perl_Player_Frame;
					elseif (self.unit == "target") then
						self.nameframetext = Perl_Target_NameBarText;
					elseif (self.unit == "focus") then
						self.nameframetext = Perl_Focus_NameBarText;
					elseif (self.unit == "party1") then
						self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
						self.parentframe = Perl_Party_MemberFrame1;
					elseif (self.unit == "party2") then
						self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
						self.parentframe = Perl_Party_MemberFrame2;
					elseif (self.unit == "party3") then
						self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
						self.parentframe = Perl_Party_MemberFrame3;
					elseif (self.unit == "party4") then
						self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
						self.parentframe = Perl_Party_MemberFrame4;
					end
				end
				self.nameframetext:SetText(self.unitname);
			end
		end
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
		if (self:IsShown() and not self.channeling) then
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(Perl_ArcaneBar_Colors.failure.r, Perl_ArcaneBar_Colors.failure.g, Perl_ArcaneBar_Colors.failure.b, transparency);
			self.barSpark:Hide();
			self.casting = nil;
			self.channeling = nil;
			self.fadeOut = 1;
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		end
	elseif (event == "UNIT_SPELLCAST_FAILED") then
		if (self:IsShown() and not self.channeling) then
			local text, _, _, _, startTime, endTime, _ = UnitCastingInfo(arg1);
			if (text == arg2) then
				self:SetValue(self.maxValue);
				self:SetStatusBarColor(Perl_ArcaneBar_Colors.failure.r, Perl_ArcaneBar_Colors.failure.g, Perl_ArcaneBar_Colors.failure.b, transparency);
				self.barSpark:Hide();
				self.casting = nil;
				self.channeling = nil;
				self.fadeOut = 1;
				self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
			end
		end
	elseif (event == "UNIT_SPELLCAST_DELAYED") then
		if(self:IsShown()) then
			local _, _, _, _, startTime, endTime, _ = UnitCastingInfo(arg1);

			if (endTime ~= nil) then
				self.delaySum = self.delaySum + (endTime - self.maxValue * 1000);
				self.startTime = startTime / 1000;
				self.maxValue = endTime / 1000;

				self:SetMinMaxValues(self.startTime, self.maxValue);
			end
		end
	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
		local text, _, _, _, startTime, endTime, _ = UnitChannelInfo(arg1);

		self:SetStatusBarColor(Perl_ArcaneBar_Colors.channel.r, Perl_ArcaneBar_Colors.channel.g, Perl_ArcaneBar_Colors.channel.b, transparency);
		self.barSpark:Show();

		self.startTime = startTime / 1000;
		self.endTime = endTime / 1000;
		self.duration = self.endTime - self.startTime;
		self.maxValue = self.startTime;
		self:SetMinMaxValues(self.startTime, self.endTime);
		self:SetValue(self.endTime);

		self:SetAlpha(0.8);
		self.holdTime = 0;
		self.casting = nil;
		self.channeling = 1;
		self.fadeOut = nil;
		self.delaySum = 0;
		self:Show();

		if (self.namereplace == 1) then
			if (self.nameframetext == nil) then
				if (self.unit == "player") then
					self.nameframetext = Perl_Player_NameBarText;
					self.parentframe = Perl_Player_Frame;
				elseif (self.unit == "target") then
					self.nameframetext = Perl_Target_NameBarText;
				elseif (self.unit == "focus") then
					self.nameframetext = Perl_Focus_NameBarText;
				elseif (self.unit == "party1") then
					self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame1;
				elseif (self.unit == "party2") then
					self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame2;
				elseif (self.unit == "party3") then
					self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame3;
				elseif (self.unit == "party4") then
					self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame4;
				end
			end
			if (text == nil) then
				self.nameframetext:SetText(PERL_LOCALIZED_ARCANEBAR_CHANNELING);
			else
				self.nameframetext:SetText(text);
			end
		end

		if (self.showtimer == 1) then
			self.castTimeText:Show();
		else
			self.castTimeText:Hide();
		end
	elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
		if (self:IsShown()) then
			local _, _, _, _, startTime, endTime, _ = UnitChannelInfo(arg1);

			self.delaySum = self.delaySum + (endTime - self.maxValue * 1000);
			self.startTime = startTime / 1000;
			self.endTime = endTime / 1000;
			self.maxValue = self.startTime;
			self:SetMinMaxValues(self.startTime, self.endTime);
		end
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - ArcaneBar: Report the following event error to the author: "..event);
		end
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_ArcaneBar_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		if (runonce == 0) then
			-- We need to call focus and target frame info (player is taken care of already), and disable frames we aren't using
			if (Perl_Target_Frame) then
				Perl_Target_ArcaneBar_Support();
			else
				targetenabled = 0;
			end
			if (Perl_Focus_Frame) then
				Perl_Focus_ArcaneBar_Support();
			else
				focusenabled = 0;
			end
			if (Perl_Party_Frame) then
				Perl_Party_ArcaneBar_Support();
			else
				partyenabled = 0;
			end
			Perl_ArcaneBar_UpdateVars();
			Perl_ArcaneBar_Frame_Style();
			runonce = 1;
		end
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_ArcaneBar_Config[UnitName("player")]) == "table") then
		Perl_ArcaneBar_GetVars();
	else
		Perl_ArcaneBar_UpdateVars();
	end

	-- Make the unit name appear above the casting bar
	if (Perl_Player_Frame) then
		Perl_ArcaneBar_player:SetParent(Perl_Player_Frame);
		Perl_ArcaneBar_player:SetFrameLevel(Perl_Player_NameFrame:GetFrameLevel() + 1);
		Perl_Player_Name:SetFrameLevel(Perl_Player_NameFrame:GetFrameLevel() + 2);
	end
	if (Perl_Target_Frame) then
		Perl_ArcaneBar_target:SetParent(Perl_Target_Frame);
		Perl_ArcaneBar_target:SetFrameLevel(Perl_Target_NameFrame:GetFrameLevel() + 1);
		Perl_Target_Name:SetFrameLevel(Perl_Target_NameFrame:GetFrameLevel() + 2);
	end
	if (Perl_Focus_Frame) then
		Perl_ArcaneBar_focus:SetParent(Perl_Focus_Frame);
		Perl_ArcaneBar_focus:SetFrameLevel(Perl_Focus_NameFrame:GetFrameLevel() + 1);
		Perl_Focus_Name:SetFrameLevel(Perl_Focus_NameFrame:GetFrameLevel() + 2);
	end
	if (Perl_Party_Frame) then
		for id=1,4 do
			getglobal("Perl_ArcaneBar_party"..id):SetParent(getglobal("Perl_Party_MemberFrame"..id));
			getglobal("Perl_ArcaneBar_party"..id):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetFrameLevel() + 1);
			getglobal("Perl_Party_MemberFrame"..id.."_Name"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetFrameLevel() + 2);
		end
	end

	-- Major config options.
	Perl_ArcaneBar_Frame_Style();

	-- MyAddOns Support
	Perl_ArcaneBar_myAddOns_Support();

	Initialized = 1;
end


----------------------
-- Update Functions --
----------------------
function Perl_ArcaneBar_Set_Spark_Width(player, target, focus, party)
	if (player ~= nil) then
		Perl_ArcaneBar_player.nameframewidth = player;
	elseif (target ~= nil) then
		Perl_ArcaneBar_target.nameframewidth = target;
	elseif (focus ~= nil) then
		Perl_ArcaneBar_focus.nameframewidth = focus;
	elseif (party ~= nil) then
		Perl_ArcaneBar_party1.nameframewidth = party;
		Perl_ArcaneBar_party2.nameframewidth = party;
		Perl_ArcaneBar_party3.nameframewidth = party;
		Perl_ArcaneBar_party4.nameframewidth = party;
	end
end

function Perl_ArcaneBar_Set_Scale_Actual(player, target, focus, party)
	if (player ~= nil) then
		Perl_ArcaneBar_player:SetScale(1);
	elseif (target ~= nil) then
		Perl_ArcaneBar_target:SetScale(1);
	elseif (focus ~= nil) then
		Perl_ArcaneBar_focus:SetScale(1);
	elseif (party ~= nil) then
		Perl_ArcaneBar_party1:SetScale(1);
		Perl_ArcaneBar_party2:SetScale(1);
		Perl_ArcaneBar_party3:SetScale(1);
		Perl_ArcaneBar_party4:SetScale(1);
	end
end

function Perl_ArcaneBar_Register(frame, register)
	if (register == 1) then
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		frame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
		frame:RegisterEvent("UNIT_SPELLCAST_FAILED");
		frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		frame:RegisterEvent("UNIT_SPELLCAST_START");
		frame:RegisterEvent("UNIT_SPELLCAST_STOP");

		if (frame == Perl_ArcaneBar_target) then
			frame:RegisterEvent("PLAYER_TARGET_CHANGED");
		elseif (frame == Perl_ArcaneBar_focus) then
			frame:RegisterEvent("PLAYER_FOCUS_CHANGED");
		end

		if (frame ~= CastingBarFrame) then
			frame:SetScript("OnUpdate", Perl_ArcaneBar_OnUpdate)
		end
	else
		frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
		frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		frame:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
		frame:UnregisterEvent("UNIT_SPELLCAST_FAILED");
		frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		frame:UnregisterEvent("UNIT_SPELLCAST_START");
		frame:UnregisterEvent("UNIT_SPELLCAST_STOP");

		if (frame == Perl_ArcaneBar_target) then
			frame:UnregisterEvent("PLAYER_TARGET_CHANGED");
		elseif (frame == Perl_ArcaneBar_focus) then
			frame:UnregisterEvent("PLAYER_FOCUS_CHANGED");
		end

		if (frame ~= CastingBarFrame) then
			frame:SetScript("OnUpdate", nil)
		end

		frame:Hide();
	end
end


-----------------------
-- OnUpdate Function --
-----------------------
function Perl_ArcaneBar_OnUpdate(self)
	local getTime = GetTime();

	if (self.showtimer == 1) then
		local current_time = self.maxValue - getTime;
		if (self.channeling) then
			current_time = self.endTime - getTime;
		end
		if (current_time < 0) then
			current_time = 0;
		end

		--local text = string.sub(math.max(current_time, 0) + 0.001, 1, 4);
		local text = math.max(current_time, 0) + 0.001, 1, 4;
		if (text >= 100) then
			text = string.sub(text, 1, 3);
		else
			text = string.sub(text, 1, 4);
		end
		if (self.delaySum ~= 0) then
			local delay = string.sub(math.max(self.delaySum / 1000, 0) + 0.001, 1, 4);
			if (self.channeling == 1) then
				self.sign = "-";
			else
				self.sign = "+";
			end
			text = "|cffcc0000"..self.sign..delay.."|r "..text;
		end
		self.castTimeText:SetText(text);
	end

	if (self.casting) then
		local status = getTime;
		if (status > self.maxValue) then
			status = self.maxValue;
		end
		if (status == self.maxValue) then
			self:SetValue(status);
			self:SetStatusBarColor(0.0, 1.0, 0.0);
			self.barSpark:Hide();
			self.barFlash:SetAlpha(0.0);
			self.barFlash:Show();
			self.flash = 1;
			self.fadeOut = 1;
			self.casting = nil;
			self.channeling = nil;
			self.delaySum = 0;
			if (self.nameframetext == nil) then
				if (self.unit == "player") then
					self.nameframetext = Perl_Player_NameBarText;
					self.parentframe = Perl_Player_Frame;
				elseif (self.unit == "target") then
					self.nameframetext = Perl_Target_NameBarText;
				elseif (self.unit == "focus") then
					self.nameframetext = Perl_Focus_NameBarText;
				elseif (self.unit == "party1") then
					self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame1;
				elseif (self.unit == "party2") then
					self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame2;
				elseif (self.unit == "party3") then
					self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame3;
				elseif (self.unit == "party4") then
					self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame4;
				end
			end
			self.nameframetext:SetText(self.unitname);
			return;
		end
		self:SetValue(status);
		self.barFlash:Hide();
		local sparkPosition = ((status - self.startTime) / (self.maxValue - self.startTime)) * (self.nameframewidth - 10);
		if (sparkPosition < 0) then
			sparkPosition = 0;
		end
		self.barSpark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);
	elseif (self.channeling) then
		local time = getTime;
		if (time > self.endTime) then
			time = self.endTime;
		end
		if (time == self.endTime) then
			self:SetStatusBarColor(0.0, 1.0, 0.0);
			self.barSpark:Hide();
			self.barFlash:SetAlpha(0.0);
			self.barFlash:Show();
			self.flash = 1;
			self.fadeOut = 1;
			self.casting = nil;
			self.channeling = nil;
			self.delaySum = 0;
			if (self.nameframetext == nil) then
				if (self.unit == "player") then
					self.nameframetext = Perl_Player_NameBarText;
					self.parentframe = Perl_Player_Frame;
				elseif (self.unit == "target") then
					self.nameframetext = Perl_Target_NameBarText;
				elseif (self.unit == "focus") then
					self.nameframetext = Perl_Focus_NameBarText;
				elseif (self.unit == "party1") then
					self.nameframetext = Perl_Party_MemberFrame1_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame1;
				elseif (self.unit == "party2") then
					self.nameframetext = Perl_Party_MemberFrame2_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame2;
				elseif (self.unit == "party3") then
					self.nameframetext = Perl_Party_MemberFrame3_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame3;
				elseif (self.unit == "party4") then
					self.nameframetext = Perl_Party_MemberFrame4_Name_NameBarText;
					self.parentframe = Perl_Party_MemberFrame4;
				end
			end
			self.nameframetext:SetText(self.unitname);
			return;
		end
		local barValue = self.startTime + (self.endTime - time);
		self:SetValue(barValue);
		self.barFlash:Hide();
		local sparkPosition = ((barValue - self.startTime) / (self.endTime - self.startTime)) * (self.nameframewidth - 10);
		self.barSpark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);
	elseif (getTime < self.holdTime) then
		return;
	elseif (self.flash) then
		local alpha = self.barFlash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		if (alpha < 1) then
			self.barFlash:SetAlpha(alpha);
		else
			self.barFlash:SetAlpha(0.8);
			self.flash = nil;
		end
	elseif (self.fadeOut) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if (alpha > 0) then
			self:SetAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_ArcaneBar_Frame_Style()
	if (playerenabled == 1) then
		Perl_ArcaneBar_Register(Perl_ArcaneBar_player, 1);
	else
		Perl_ArcaneBar_Register(Perl_ArcaneBar_player, 0);
	end

	if (targetenabled == 1) then
		Perl_ArcaneBar_Register(Perl_ArcaneBar_target, 1);
	else
		Perl_ArcaneBar_Register(Perl_ArcaneBar_target, 0);
	end

	if (focusenabled == 1) then
		Perl_ArcaneBar_Register(Perl_ArcaneBar_focus, 1);
	else
		Perl_ArcaneBar_Register(Perl_ArcaneBar_focus, 0);
	end

	if (partyenabled == 1) then
		for id=1,4 do
			Perl_ArcaneBar_Register(getglobal("Perl_ArcaneBar_party"..id), 1);
		end
	else
		for id=1,4 do
			Perl_ArcaneBar_Register(getglobal("Perl_ArcaneBar_party"..id), 0);
		end
	end

	if (playershowtimer == 0) then
		Perl_ArcaneBar_player_CastTime:Hide();
		Perl_ArcaneBar_player.showtimer = 0;
	else
		Perl_ArcaneBar_player.showtimer = 1;
	end

	if (targetshowtimer == 0) then
		Perl_ArcaneBar_target_CastTime:Hide();
		Perl_ArcaneBar_target.showtimer = 0;
	else
		Perl_ArcaneBar_target.showtimer = 1;
	end

	if (focusshowtimer == 0) then
		Perl_ArcaneBar_focus_CastTime:Hide();
		Perl_ArcaneBar_focus.showtimer = 0;
	else
		Perl_ArcaneBar_focus.showtimer = 1;
	end

	if (partyshowtimer == 0) then
		for id=1,4 do
			getglobal("Perl_ArcaneBar_party"..id.."_CastTime"):Hide();
			getglobal("Perl_ArcaneBar_party"..id).showtimer = 0;
		end
	else
		for id=1,4 do
			getglobal("Perl_ArcaneBar_party"..id).showtimer = 1;
		end
	end

	if (Perl_Player_Frame) then
		Perl_Player_Frame_Style();
	end

	if (Perl_Target_Frame) then
		Perl_Target_Main_Style();
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Main_Style();
	end

	if (Perl_Party_Frame) then
		Perl_Party_Frame_Style();
	end

	if (playernamereplace == 0) then
		if (Perl_ArcaneBar_player.unitname ~= nil) then
			Perl_Player_NameBarText:SetText(Perl_ArcaneBar_player.unitname);
		end
		Perl_ArcaneBar_player.namereplace = 0;
	else
		Perl_ArcaneBar_player.namereplace = 1;
	end

	if (targetnamereplace == 0) then
		if (Perl_Target_Frame) then
			if (UnitExists("target")) then
				Perl_Target_NameBarText:SetText(UnitName("target"));
			end
		end
		Perl_ArcaneBar_target.namereplace = 0;
	else
		Perl_ArcaneBar_target.namereplace = 1;
	end

	if (focusnamereplace == 0) then
		if (Perl_Focus_Frame) then
			if (UnitExists("focus")) then
				Perl_Focus_NameBarText:SetText(UnitName("focus"));
			end
		end
		Perl_ArcaneBar_focus.namereplace = 0;
	else
		Perl_ArcaneBar_focus.namereplace = 1;
	end

	if (partynamereplace == 0) then
		for id=1,4 do
			if (Perl_Party_Frame) then
				if (UnitExists("party"..id)) then
					getglobal("Perl_Party_MemberFrame"..id.."_Name_NameBarText"):SetText(UnitName("party"..id));
				end
			end
			getglobal("Perl_ArcaneBar_party"..id).namereplace = 0;
		end
	else
		for id=1,4 do
			getglobal("Perl_ArcaneBar_party"..id).namereplace = 1;
		end
	end

	if (hideoriginal == 0) then
		Perl_ArcaneBar_Register(CastingBarFrame, 1);
	else
		Perl_ArcaneBar_Register(CastingBarFrame, 0);
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_ArcaneBar_Set_Player_Enabled(newvalue)
	playerenabled = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Target_Enabled(newvalue)
	targetenabled = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Focus_Enabled(newvalue)
	focusenabled = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Party_Enabled(newvalue)
	partyenabled = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Player_Show_Timer(newvalue)
	playershowtimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Target_Show_Timer(newvalue)
	targetshowtimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Focus_Show_Timer(newvalue)
	focusshowtimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Party_Show_Timer(newvalue)
	partyshowtimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Player_Left_Timer(newvalue)
	playerlefttimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Target_Left_Timer(newvalue)
	targetlefttimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Focus_Left_Timer(newvalue)
	focuslefttimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Party_Left_Timer(newvalue)
	partylefttimer = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Player_Name_Replace(newvalue)
	playernamereplace = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Target_Name_Replace(newvalue)
	targetnamereplace = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Focus_Name_Replace(newvalue)
	focusnamereplace = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Party_Name_Replace(newvalue)
	partynamereplace = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Hide_Original(newvalue)
	hideoriginal = newvalue;
	Perl_ArcaneBar_UpdateVars();
	Perl_ArcaneBar_Frame_Style();
end

function Perl_ArcaneBar_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);		-- convert the user input to a wow acceptable value
	end
	Perl_ArcaneBar_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_ArcaneBar_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	playerenabled = Perl_ArcaneBar_Config[name]["PlayerEnabled"];
	targetenabled = Perl_ArcaneBar_Config[name]["TargetEnabled"];
	focusenabled = Perl_ArcaneBar_Config[name]["FocusEnabled"];
	partyenabled = Perl_ArcaneBar_Config[name]["PartyEnabled"];
	playershowtimer = Perl_ArcaneBar_Config[name]["PlayerShowTimer"];
	targetshowtimer = Perl_ArcaneBar_Config[name]["TargetShowTimer"];
	focusshowtimer = Perl_ArcaneBar_Config[name]["FocusShowTimer"];
	partyshowtimer = Perl_ArcaneBar_Config[name]["PartyShowTimer"];
	playerlefttimer = Perl_ArcaneBar_Config[name]["PlayerLeftTimer"];
	targetlefttimer = Perl_ArcaneBar_Config[name]["TargetLeftTimer"];
	focuslefttimer = Perl_ArcaneBar_Config[name]["FocusLeftTimer"];
	partylefttimer = Perl_ArcaneBar_Config[name]["PartyLeftTimer"];
	playernamereplace = Perl_ArcaneBar_Config[name]["PlayerNameReplace"];
	targetnamereplace = Perl_ArcaneBar_Config[name]["TargetNameReplace"];
	focusnamereplace = Perl_ArcaneBar_Config[name]["FocusNameReplace"];
	partynamereplace = Perl_ArcaneBar_Config[name]["PartyNameReplace"];
	hideoriginal = Perl_ArcaneBar_Config[name]["HideOriginal"];
	transparency = Perl_ArcaneBar_Config[name]["Transparency"];

	if (playerenabled == nil) then
		playerenabled = 1;
	end
	if (targetenabled == nil) then
		targetenabled = 1;
	end
	if (focusenabled == nil) then
		focusenabled = 1;
	end
	if (partyenabled == nil) then
		partyenabled = 1;
	end
	if (playershowtimer == nil) then
		playershowtimer = 1;
	end
	if (targetshowtimer == nil) then
		targetshowtimer = 1;
	end
	if (focusshowtimer == nil) then
		focusshowtimer = 1;
	end
	if (partyshowtimer == nil) then
		partyshowtimer = 1;
	end
	if (playerlefttimer == nil) then
		playerlefttimer = 0;
	end
	if (targetlefttimer == nil) then
		targetlefttimer = 1;
	end
	if (focuslefttimer == nil) then
		focuslefttimer = 1;
	end
	if (partylefttimer == nil) then
		partylefttimer = 0;
	end
	if (playernamereplace == nil) then
		playernamereplace = 0;
	end
	if (targetnamereplace == nil) then
		targetnamereplace = 0;
	end
	if (focusnamereplace == nil) then
		focusnamereplace = 0;
	end
	if (partynamereplace == nil) then
		partynamereplace = 0;
	end
	if (hideoriginal == nil) then
		hideoriginal = 1;
	end
	if (transparency == nil) then
		transparency = 1;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_ArcaneBar_UpdateVars();

		-- Call any code we need to activate them
		Perl_ArcaneBar_Frame_Style();
		Perl_ArcaneBar_Set_Transparency();
		return;
	end

	local vars = {
		["playerenabled"] = playerenabled,
		["targetenabled"] = targetenabled,
		["focusenabled"] = focusenabled,
		["partyenabled"] = partyenabled,
		["playershowtimer"] = playershowtimer,
		["targetshowtimer"] = targetshowtimer,
		["focusshowtimer"] = focusshowtimer,
		["partyshowtimer"] = partyshowtimer,
		["playerlefttimer"] = playerlefttimer,
		["targetlefttimer"] = targetlefttimer,
		["focuslefttimer"] = focuslefttimer,
		["partylefttimer"] = partylefttimer,
		["playernamereplace"] = playernamereplace,
		["targetnamereplace"] = targetnamereplace,
		["focusnamereplace"] = focusnamereplace,
		["partynamereplace"] = partynamereplace,
		["hideoriginal"] = hideoriginal,
		["transparency"] = transparency,
	}
	return vars;
end

function Perl_ArcaneBar_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["PlayerEnabled"] ~= nil) then
				playerenabled = vartable["Global Settings"]["PlayerEnabled"];
			else
				playerenabled = nil;
			end
			if (vartable["Global Settings"]["TargetEnabled"] ~= nil) then
				targetenabled = vartable["Global Settings"]["TargetEnabled"];
			else
				targetenabled = nil;
			end
			if (vartable["Global Settings"]["FocusEnabled"] ~= nil) then
				focusenabled = vartable["Global Settings"]["FocusEnabled"];
			else
				focusenabled = nil;
			end
			if (vartable["Global Settings"]["PartyEnabled"] ~= nil) then
				partyenabled = vartable["Global Settings"]["PartyEnabled"];
			else
				partyenabled = nil;
			end
			if (vartable["Global Settings"]["PlayerShowTimer"] ~= nil) then
				playershowtimer = vartable["Global Settings"]["PlayerShowTimer"];
			else
				playershowtimer = nil;
			end
			if (vartable["Global Settings"]["TargetShowTimer"] ~= nil) then
				targetshowtimer = vartable["Global Settings"]["TargetShowTimer"];
			else
				targetshowtimer = nil;
			end
			if (vartable["Global Settings"]["FocusShowTimer"] ~= nil) then
				focusshowtimer = vartable["Global Settings"]["FocusShowTimer"];
			else
				focusshowtimer = nil;
			end
			if (vartable["Global Settings"]["PartyShowTimer"] ~= nil) then
				partyshowtimer = vartable["Global Settings"]["PartyShowTimer"];
			else
				partyshowtimer = nil;
			end
			if (vartable["Global Settings"]["PlayerLeftTimer"] ~= nil) then
				playerlefttimer = vartable["Global Settings"]["PlayerLeftTimer"];
			else
				playerlefttimer = nil;
			end
			if (vartable["Global Settings"]["TargetLeftTimer"] ~= nil) then
				targetlefttimer = vartable["Global Settings"]["TargetLeftTimer"];
			else
				targetlefttimer = nil;
			end
			if (vartable["Global Settings"]["FocusLeftTimer"] ~= nil) then
				focuslefttimer = vartable["Global Settings"]["FocusLeftTimer"];
			else
				focuslefttimer = nil;
			end
			if (vartable["Global Settings"]["PartyLeftTimer"] ~= nil) then
				partylefttimer = vartable["Global Settings"]["PartyLeftTimer"];
			else
				partylefttimer = nil;
			end
			if (vartable["Global Settings"]["PlayerNameReplace"] ~= nil) then
				playernamereplace = vartable["Global Settings"]["PlayerNameReplace"];
			else
				playernamereplace = nil;
			end
			if (vartable["Global Settings"]["TargetNameReplace"] ~= nil) then
				targetnamereplace = vartable["Global Settings"]["TargetNameReplace"];
			else
				targetnamereplace = nil;
			end
			if (vartable["Global Settings"]["FocusNameReplace"] ~= nil) then
				focusnamereplace = vartable["Global Settings"]["FocusNameReplace"];
			else
				focusnamereplace = nil;
			end
			if (vartable["Global Settings"]["PartyNameReplace"] ~= nil) then
				partynamereplace = vartable["Global Settings"]["PartyNameReplace"];
			else
				partynamereplace = nil;
			end
			if (vartable["Global Settings"]["HideOriginal"] ~= nil) then
				hideoriginal = vartable["Global Settings"]["HideOriginal"];
			else
				hideoriginal = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (playerenabled == nil) then
			playerenabled = 1;
		end
		if (targetenabled == nil) then
			targetenabled = 1;
		end
		if (focusenabled == nil) then
			focusenabled = 1;
		end
		if (partyenabled == nil) then
			partyenabled = 1;
		end
		if (playershowtimer == nil) then
			playershowtimer = 1;
		end
		if (targetshowtimer == nil) then
			targetshowtimer = 1;
		end
		if (focusshowtimer == nil) then
			focusshowtimer = 1;
		end
		if (partyshowtimer == nil) then
			partyshowtimer = 1;
		end
		if (playerlefttimer == nil) then
			playerlefttimer = 0;
		end
		if (targetlefttimer == nil) then
			targetlefttimer = 1;
		end
		if (focuslefttimer == nil) then
			focuslefttimer = 1;
		end
		if (partylefttimer == nil) then
			partylefttimer = 0;
		end
		if (playernamereplace == nil) then
			playernamereplace = 0;
		end
		if (targetnamereplace == nil) then
			targetnamereplace = 0;
		end
		if (focusnamereplace == nil) then
			focusnamereplace = 0;
		end
		if (partynamereplace == nil) then
			partynamereplace = 0;
		end
		if (hideoriginal == nil) then
			hideoriginal = 1;
		end
		if (transparency == nil) then
			transparency = 1;
		end

		-- Call any code we need to activate them
		Perl_ArcaneBar_Frame_Style();
		Perl_ArcaneBar_Set_Transparency();
	end

	Perl_ArcaneBar_Config[UnitName("player")] = {
		["PlayerEnabled"] = playerenabled,
		["TargetEnabled"] = targetenabled,
		["FocusEnabled"] = focusenabled,
		["PartyEnabled"] = partyenabled,
		["PlayerShowTimer"] = playershowtimer,
		["TargetShowTimer"] = targetshowtimer,
		["FocusShowTimer"] = focusshowtimer,
		["PartyShowTimer"] = partyshowtimer,
		["PlayerLeftTimer"] = playerlefttimer,
		["TargetLeftTimer"] = targetlefttimer,
		["FocusLeftTimer"] = focuslefttimer,
		["PartyLeftTimer"] = partylefttimer,
		["PlayerNameReplace"] = playernamereplace,
		["TargetNameReplace"] = targetnamereplace,
		["FocusNameReplace"] = focusnamereplace,
		["PartyNameReplace"] = partynamereplace,
		["HideOriginal"] = hideoriginal,
		["Transparency"] = transparency,
	};
end


----------------------
-- myAddOns Support --
----------------------
function Perl_ArcaneBar_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_ArcaneBar_myAddOns_Details = {
			name = "Perl_ArcaneBar",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Zlixar; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_ArcaneBar_myAddOns_Help = {};
		Perl_ArcaneBar_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_ArcaneBar_myAddOns_Details, Perl_ArcaneBar_myAddOns_Help);
	end
end
