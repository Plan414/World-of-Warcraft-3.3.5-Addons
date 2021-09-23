-- registers the mod with Cosmos
function CooldownCount_Register_Cosmos()
	if ( ( Cosmos_UpdateValue ) and ( Cosmos_RegisterConfiguration ) and ( CooldownCount_Cosmos_Registered == 0 ) ) then
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT",
			"SECTION",
			TEXT(COOLDOWNCOUNT_CONFIG_HEADER),
			TEXT(COOLDOWNCOUNT_CONFIG_HEADER_INFO)
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_HEADER",
			"SEPARATOR",
			TEXT(COOLDOWNCOUNT_CONFIG_HEADER),
			TEXT(COOLDOWNCOUNT_CONFIG_HEADER_INFO)
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_ENABLED",
			"CHECKBOX",
			TEXT(COOLDOWNCOUNT_ENABLED),
			TEXT(COOLDOWNCOUNT_ENABLED_INFO),
			CooldownCount_Toggle_Enabled,
			CooldownCount_Enabled
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_ROGUE_STEALTH",
			"CHECKBOX",
			TEXT(COOLDOWNCOUNT_ROGUE_STEALTH),
			TEXT(COOLDOWNCOUNT_ROGUE_STEALTH_INFO),
			CooldownCount_Toggle_RogueStealth,
			CooldownCount_RogueStealth
		);
		
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_NOSPACES",
			"CHECKBOX",
			TEXT(COOLDOWNCOUNT_NOSPACES),
			TEXT(COOLDOWNCOUNT_NOSPACES_INFO),
			CooldownCount_Toggle_NoSpaces,
			CooldownCount_NoSpaces
		);
		CooldownCount_UseLongTimerDescriptions = 0;
		--[[
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_USELONGTIMERS",
			"CHECKBOX",
			TEXT(COOLDOWNCOUNT_USELONGTIMERS),
			TEXT(COOLDOWNCOUNT_USELONGTIMERS_INFO),
			CooldownCount_Toggle_UseLongTimers,
			CooldownCount_UseLongTimerDescriptions
		);
		]]--
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_FLASHSPEED",
			"SLIDER",
			TEXT(COOLDOWNCOUNT_FLASHSPEED),
			TEXT(COOLDOWNCOUNT_FLASHSPEED_INFO),
			function (checked, value) CooldownCount_SetFlashSpeed(value, true); end,
			1,
			CooldownCount_TimeBetweenFlashes,
			0.1,
			1,
			COOLDOWNCOUNT_FLASHSPEED_SLIDER_DESCRIPTION,
			0.1,
			1,
			COOLDOWNCOUNT_FLASHSPEED_SLIDER_APPEND,
			1
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_USERSCALE",
			"SLIDER",
			TEXT(COOLDOWNCOUNT_USERSCALE),
			TEXT(COOLDOWNCOUNT_USERSCALE_INFO),
			function (checked, value) CooldownCount_SetUserScale(value, true); end,
			1,
			CooldownCount_UserScale,
			0.1,
			5,
			COOLDOWNCOUNT_USERSCALE_SLIDER_DESCRIPTION,
			0.1,
			1,
			COOLDOWNCOUNT_USERSCALE_SLIDER_APPEND,
			100
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_ALPHA",
			"SLIDER",
			TEXT(COOLDOWNCOUNT_ALPHA),
			TEXT(COOLDOWNCOUNT_ALPHA_INFO),
			function (checked, value) CooldownCount_Set_Alpha(value, true); end,
			1,
			CooldownCountOptions.alpha,
			0.01,
			1,
			COOLDOWNCOUNT_ALPHA_SLIDER_DESCRIPTION,
			0.01,
			1,
			COOLDOWNCOUNT_ALPHA_SLIDER_APPEND,
			100
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_HIDEUNTILTIMELEFT",
			"SLIDER",
			TEXT(COOLDOWNCOUNT_HIDEUNTILTIMELEFT),
			TEXT(COOLDOWNCOUNT_HIDEUNTILTIMELEFT_INFO),
			function (checked, value) CooldownCount_SetHideUntilTimeLeft(value, true); end,
			1,
			CooldownCount_HideUntilTimeLeft,
			0,
			60,
			COOLDOWNCOUNT_FLASHSPEED_SLIDER_DESCRIPTION,
			1,
			1,
			COOLDOWNCOUNT_FLASHSPEED_SLIDER_APPEND,
			1
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_NORMALCOLORSET",
			"BUTTON",
			COOLDOWNCOUNT_NORMALCOLOR_SET,
			COOLDOWNCOUNT_NORMALCOLOR_SET_INFO,
			CooldownCount_NormalColorSetButton,
			0,
			0,
			0,
			0,
			COOLDOWNCOUNT_SETTEXT
		);
		Cosmos_RegisterConfiguration(
			"COS_COOLDOWNCOUNT_FLASHCOLORSET",
			"BUTTON",
			COOLDOWNCOUNT_FLASHCOLOR_SET,
			COOLDOWNCOUNT_FLASHCOLOR_SET_INFO,
			CooldownCount_FlashColorSetButton,
			0,
			0,
			0,
			0,
			COOLDOWNCOUNT_SETTEXT
		);
		CooldownCount_Cosmos_Registered = 1;
	end
end


function CooldownCount_Extract_NextParameter(msg)
	local params = msg;
	local command = params;
	local index = strfind(command, " ");
	if ( index ) then
		command = strsub(command, 1, index-1);
		params = strsub(params, index+1);
	else
		params = "";
	end
	return command, params;
end


-- registers the mod with the system, integrating it with slash commands and "master" AddOns
function CooldownCount_Register()
	if ( not CooldownCount_Register_Khaos() ) then
		CooldownCount_Register_Cosmos();
	end

	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");

	if ( Cosmos_RegisterChatCommand ) then
		local CooldownCountMainCommands = COOLDOWNCOUNT_SLASH_COMMANDS;
		Cosmos_RegisterChatCommand (
			"COOLDOWNCOUNT_MAIN_COMMANDS", -- Some Unique Group ID
			CooldownCountMainCommands, -- The Commands
			CooldownCount_Main_ChatCommandHandler,
			COOLDOWNCOUNT_CHAT_COMMAND_MAIN_INFO -- Description String
		);
	else
		local sName = "COOLDOWNCOUNTSLASHMAIN";
		SlashCmdList[sName] = CooldownCount_Main_ChatCommandHandler;
		for k, v in pairs( COOLDOWNCOUNT_SLASH_COMMANDS ) do
			setglobal("SLASH_"..sName..k, v);
		end
	end
end

function CooldownCount_GetChatValue(msg)
	msg = string.lower(msg);
	-- Toggle appropriately
	if ( (string.find(msg, COOLDOWNCOUNT_PARAM_ON)) or ((string.find(msg, '1')) and (not string.find(msg, '-1')) ) ) then
		return 1;
	else
		if ( (string.find(msg, COOLDOWNCOUNT_PARAM_OFF)) or (string.find(msg, '0')) ) then
			return 0;
		else
			return -1;
		end
	end
end


function CooldownCount_Enable_ChatCommandHandler(msg)
	CooldownCount_Toggle_Enabled(1);
end

function CooldownCount_Disable_ChatCommandHandler(msg)
	CooldownCount_Toggle_Enabled(0);
end

function CooldownCount_Set_ChatCommandHandler(msg)
	local value = CooldownCount_GetChatValue(msg);
	CooldownCount_Toggle_Enabled(value);
end

function CooldownCount_NoSpaces_ChatCommandHandler(msg)
	local value = CooldownCount_GetChatValue(msg);
	CooldownCount_Toggle_NoSpaces(value);
end

function CooldownCount_UseLongTimers_ChatCommandHandler(msg)
	local value = CooldownCount_GetChatValue(msg);
	CooldownCount_Toggle_UseLongTimers(value);
end

function CooldownCount_Scale_ChatCommandHandler(msg)
	local scale = nil;
	if ( msg ) and ( strlen(msg) > 0 ) then
		scale = tonumber(msg);
	end
	if ( scale ) then
		CooldownCount_SetUserScale(scale);
	else
		CooldownCount_Print(COOLDOWNCOUNT_CHAT_USERSCALE_NOT_SPECIFIED);
	end
end

function CooldownCount_Alpha_ChatCommandHandler(msg)
	local alpha = nil;
	if ( msg ) and ( strlen(msg) > 0 ) then
		alpha = tonumber(msg);
	end
	if ( alpha ) then
		CooldownCount_Set_Alpha(alpha);
	else
		CooldownCount_Print(COOLDOWNCOUNT_CHAT_ALPHA_NOT_SPECIFIED);
	end
end

function CooldownCount_HideUntilTimeLeft_ChatCommandHandler(msg)
	local timeLeft = nil;
	if ( msg ) and ( strlen(msg) > 0 ) then
		timeLeft = tonumber(msg);
	end
	if ( timeLeft ) then
		CooldownCount_SetHideUntilTimeLeft(timeLeft);
	else
		CooldownCount_Print(COOLDOWNCOUNT_CHAT_HIDEUNTILTIMELEFT_NOT_SPECIFIED);
	end
end

-- Handles chat - e.g. slashcommands - enabling/disabling the CooldownCount
function CooldownCount_FlashSpeed_ChatCommandHandler(msg)
	msg = string.lower(msg);
	
	-- Toggle appropriately
	local num = tonumber(msg);
	if ( num ) then
		CooldownCount_SetFlashSpeed(num);
	end
end

function CooldownCount_PrintUsage()
	for k, v in pairs( COOLDOWNCOUNT_SLASH_USAGE ) do
		CooldownCount_Print(v);
	end
end

function CooldownCount_Main_ChatCommandHandler(msg)
	local cmd, params = CooldownCount_Extract_NextParameter(msg);
	cmd = string.lower(cmd);
	if ( string.find(cmd, COOLDOWNCOUNT_SLASH_ENABLE ) ) then
		return CooldownCount_Enable_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_DISABLE ) ) then
		return CooldownCount_Disable_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_SET ) ) then
		return CooldownCount_Set_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_SCALE ) ) then
		return CooldownCount_Scale_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_ALPHA ) ) then
		return CooldownCount_Alpha_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_NOSPACES ) ) then
		return CooldownCount_NoSpaces_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_NORMALCOLOR ) ) then
		return CooldownCount_NormalColorSetButton(true);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_FLASHCOLOR ) ) then
		return CooldownCount_FlashColorSetButton(true);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_FLASHSPEED ) ) then
		return CooldownCount_FlashSpeed_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_USELONGTIMERS ) ) then
		return CooldownCount_UseLongTimers_ChatCommandHandler(params);
	elseif ( string.find(cmd, COOLDOWNCOUNT_SLASH_HIDEUNTILTIMELEFT ) ) then
		return CooldownCount_HideUntilTimeLeft_ChatCommandHandler(params);
	else
		CooldownCount_PrintUsage();
		return;
	end
end


function CooldownCount_LoadOptions()
	if ( CooldownCount_Cosmos_Registered == 0 ) then
		local value = CooldownCount_Enabled;
		if (value == nil ) then
			-- defaults to off
			value = 0;
		end
		CooldownCount_Toggle_Enabled(value);
		
		local value = CooldownCount_TimeBetweenFlashes;
		if (value == nil ) then
			value = 0.25;
		end
		CooldownCount_SetFlashSpeed(value);
		
		local value = CooldownCount_UserScale;
		if (value == nil ) then
			value = 2;
		end
		CooldownCount_SetUserScale(value);
		
		local value = CooldownCount_UseLongTimerDescriptions;
		if (value == nil ) then
			value = 1;
		end
		CooldownCount_Toggle_UseLongTimers(value);
		if ( CooldownCountOptions ) then
			CooldownCount_Set_Alpha(CooldownCountOptions.alpha);
			CooldownCount_Set_NormalColor(CooldownCountOptions.color.normal);
			CooldownCount_Set_FlashColor(CooldownCountOptions.color.flash);
		end
		local value = CooldownCount_NoSpaces;
		if ( value == nil ) then
			value = 0;
		end
		CooldownCount_Toggle_NoSpaces(value);
		local value = CooldownCount_HideUntilTimeLeft;
		if ( value == nil ) then
			value = 0;
		end
		CooldownCount_SetHideUntilTimeLeft(value);
	end
end

CooldownCount_Toggle_Khaos_Arr = {};

function CooldownCount_Toggle_Khaos(state, func)
	if ( type(state) == "boolean" ) then
		CooldownCount_Toggle_Khaos_Arr.checked = state;
		state = CooldownCount_Toggle_Khaos_Arr;
	end
	local value = 0;
	if ( state ) and ( state.checked ) then
		value = 1;
	end
	if ( func ) then
		func(value);
	end
end

-- registers the mod with Cosmos
function CooldownCount_Register_Khaos()
	if ( not Khaos ) then
		return false;
	end
	local optionSetEasy = {
		id = COOLDOWNCOUNT_KHAOS_SET_ID;
		text = COOLDOWNCOUNT_CONFIG_HEADER;
		helptext = COOLDOWNCOUNT_CONFIG_HEADER_INFO;
		callback = function(state) CooldownCount_Toggle_Khaos(state, CooldownCount_Toggle_Enabled); end;
		difficulty = 1;
		default = true;
		options = {
			{
				id = "CooldownCountHeader";
				key = "header";
				text = COOLDOWNCOUNT_CONFIG_HEADER;
				helptext = COOLDOWNCOUNT_CONFIG_HEADER_INFO;
				type = K_HEADER;
				callback = function () end;
			},
			{
				id = "CooldownCountCheckBoxEnabled";
				key = "enabled";
				text = COOLDOWNCOUNT_ENABLED;
				helptext = COOLDOWNCOUNT_ENABLED_INFO;
				check = true;
				callback = function(state) CooldownCount_Toggle_Khaos(state, CooldownCount_Toggle_Enabled); end;
				type = K_TEXT;
				feedback = function(state) if ( not state ) or ( not state.checked ) then return COOLDOWNCOUNT_CHAT_DISABLED; else return COOLDOWNCOUNT_CHAT_ENABLED; end; end;
				default = {checked = true;};
				disabled = {checked = false;};
			},
			{
				id = "CooldownCountCheckBoxRogueStealthCooldown";
				key = "rogueStealthCooldown";
				text = COOLDOWNCOUNT_ROGUE_STEALTH;
				helptext = COOLDOWNCOUNT_ROGUE_STEALTH_INFO;
				check = true;
				callback = function(state) CooldownCount_Toggle_Khaos(state, CooldownCount_Toggle_RogueStealth); end;
				type = K_TEXT;
				feedback = function(state) if ( not state ) or ( not state.checked ) then return COOLDOWNCOUNT_CHAT_ROGUE_STEALTH_DISABLED; else return COOLDOWNCOUNT_CHAT_ROGUE_STEALTH_ENABLED; end; end;
				default = {checked = true;};
				disabled = {checked = false;};
			},
			{
				id = "CooldownCountCheckBoxNoSpaces";
				key = "noSpaces";
				text = COOLDOWNCOUNT_NOSPACES;
				helptext = COOLDOWNCOUNT_NOSPACES_INFO;
				check = true;
				callback = function(state) CooldownCount_Toggle_Khaos(state, CooldownCount_Toggle_NoSpaces); end;
				type = K_TEXT;
				feedback = function(state) if ( not state ) or ( not state.checked ) then return COOLDOWNCOUNT_CHAT_NOSPACES_DISABLED; else return COOLDOWNCOUNT_CHAT_NOSPACES_ENABLED; end; end;
				default = {checked = true;};
				disabled = {checked = false;};
			},
			{
				id="CooldownCountFlashSpeed";
				type=K_SLIDER;
				text=COOLDOWNCOUNT_FLASHSPEED;
				helptext=COOLDOWNCOUNT_FLASHSPEED_INFO;
				callback=function(state) CooldownCount_SetFlashSpeed(state.slider, true); end;
				feedback=function(state) end;
				default={checked=true;slider=CooldownCount_TimeBetweenFlashes};
				disabled={checked=false;slider=0};
				setup={
					sliderStep=0.1;
					sliderText=COOLDOWNCOUNT_HIDEUNTILTIMELEFT_SLIDER_DESCRIPTION;
					sliderMin=0.1;
					sliderMax=1;
					sliderDisplayFunc=function(val)return (math.floor(val*10)/10)..COOLDOWNCOUNT_HIDEUNTILTIMELEFT_SLIDER_APPEND; end;
				};
			},
			{
				id="CooldownCountScale";
				type=K_SLIDER;
				text=COOLDOWNCOUNT_USERSCALE;
				helptext=COOLDOWNCOUNT_USERSCALE_INFO;
				callback=function(state) CooldownCount_SetUserScale(state.slider, true); end;
				feedback=function(state) end;
				default={checked=true;slider=CooldownCount_UserScale};
				disabled={checked=false;slider=0};
				setup={
					sliderStep=0.1;
					sliderText=COOLDOWNCOUNT_USERSCALE_SLIDER_DESCRIPTION;
					sliderMin=0.1;
					sliderMax=5;
					sliderDisplayFunc=function(val)return (math.floor(val*100))..COOLDOWNCOUNT_USERSCALE_SLIDER_APPEND; end;
				};
			},
			{
				id="CooldownCountAlpha";
				type=K_SLIDER;
				text=COOLDOWNCOUNT_ALPHA;
				helptext=COOLDOWNCOUNT_ALPHA_INFO;
				callback=function(state) CooldownCount_Set_Alpha(state.slider, true); end;
				feedback=function(state) end;
				default={checked=true;slider=CooldownCountOptions.alpha};
				disabled={checked=false;slider=0};
				setup={
					sliderStep=0.01;
					sliderText=COOLDOWNCOUNT_ALPHA_SLIDER_DESCRIPTION;
					sliderMin=0.01;
					sliderMax=1;
					sliderDisplayFunc=function(val)return (math.floor((val)*100))..COOLDOWNCOUNT_ALPHA_SLIDER_APPEND; end;
				};
			},
			{
				id="CooldownCountHideUntil";
				type=K_SLIDER;
				text=COOLDOWNCOUNT_HIDEUNTILTIMELEFT;
				helptext=COOLDOWNCOUNT_HIDEUNTILTIMELEFT_INFO;
				callback=function(state) CooldownCount_SetHideUntilTimeLeft(state.slider, true); end;
				feedback=function(state) end;
				default={checked=true;slider=CooldownCount_HideUntilTimeLeft};
				disabled={checked=false;slider=0};
				setup={
					sliderStep=1;
					sliderText=COOLDOWNCOUNT_FLASHSPEED_SLIDER_DESCRIPTION;
					sliderMin=0;
					sliderMax=60;
					sliderDisplayFunc=function(val)return val..COOLDOWNCOUNT_FLASHSPEED_SLIDER_APPEND; end;
				};
			},
			{
				id="CoolDownCountFlashColor";
				text=COOLDOWNCOUNT_FLASHCOLOR_SET;
				helptext=COOLDOWNCOUNT_FLASHCOLOR_SET_INFO;
				difficulty=1;
				callback=CooldownCount_FlashColorSetButton;
				type=K_BUTTON;
				setup={ buttonText=COOLDOWNCOUNT_SETTEXT; };
			},
			{
				id="CoolDownCountNormalColor";
				text=COOLDOWNCOUNT_NORMALCOLOR_SET;
				helptext=COOLDOWNCOUNT_NORMALCOLOR_SET_INFO;
				difficulty=1;
				callback=CooldownCount_NormalColorSetButton;
				type=K_BUTTON;
				setup={ buttonText=COOLDOWNCOUNT_SETTEXT; };
			}
		};
	};
	Khaos.registerOptionSet( "bars", optionSetEasy );

	return true;
end
