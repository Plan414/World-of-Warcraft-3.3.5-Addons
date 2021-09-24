-------------------------------------------------------------------------------
-- Title: Warrior Proc Alert
-- Author: Lambsauce, KCmilam
-------------------------------------------------------------------------------

--Saved character variables.
WarriorProcAlert_SavedOptions = {
	Lock = true,
	Showing = false,
	ScalingFactor = 1,
	ShoutBox = 0,
	ProfileBox = 1,
	InstanceOnly = false,
	
	Profiles = {
		[1] = {
			Name = Armstext,
			SwordnBoard = false,
			BloodThirst = false, 
			ThunderClap = false, 
			Rend = true, 
			DemoralizingShout = false, 
			HeroicStrike = false, 
			ThirstForBlood = true, 
			SuddenDeath = true, 
			MortalStrike = true, 
			Hamstring = false,
			Vigilance = false,
			RageDump = true,
			Sunder = false,
			Execute = false
		},
		[2] = {
			Name = Furytext,
			SwordnBoard = false,
			BloodThirst = true, 
			ThunderClap = false, 
			Rend = false, 
			DemoralizingShout = false, 
			HeroicStrike = false, 
			ThirstForBlood = true, 
			SuddenDeath = false, 
			MortalStrike = false, 
			Hamstring = false,
			Vigilance = false,
			RageDump = true,
			Sunder = false,
			Execute = true
		},
		[3] = {
			Name = Prottext,
			SwordnBoard = true,
			BloodThirst = false, 
			ThunderClap = false, 
			Rend = false, 
			DemoralizingShout = false, 
			HeroicStrike = true, 
			ThirstForBlood = false, 
			SuddenDeath = false, 
			MortalStrike = false, 
			Hamstring = false,
			Vigilance = false,
			RageDump = true,
			Sunder = true,
			Execute = false
		}
	}
}

local ProcTable = {}
local Initialized = false

local function DeepCopy ( Source )

	local Dest = {}
	for Key, Val in pairs(Source) do
		Key = type(Key) == "table" and DeepCopy(Key) or Key
		Val = type(Val) == "table" and DeepCopy(Val) or Val
		Dest[Key] = Val
	end
	return Dest
end

local function DetectBuff ( index )
	if InCombatLockdown()then
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff("player", ProcTable[index].Name)	
		if (name ~= nil ) then
			ProcTable[index].Procced = true
			ProcTable[index].Timer = format("%.1f",(expirationTime-GetTime()))
		end
	end
end

local function DetectDebuff ( index )
	if ( InCombatLockdown() and CheckInteractDistance("target", 2) ) then
		if ProcTable[index].NonStackingBuffs then
			for proc, procname in pairs(ProcTable[index].NonStackingBuffs) do
				name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", procname)
				if ( name ~= nil ) then
					ProcTable[index].NonStack = true
				end
			end
		end
		
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", ProcTable[index].Name)
		if ( 	not ProcTable[index].NonStack and 
				(name == nil or ( expirationTime ~= nil and (-1*(GetTime()-expirationTime)) < 5) )  ) then
			ProcTable[index].Procced = true
			if ( expirationTime ~= nil ) then
				ProcTable[index].Timer = format("%.1f",(expirationTime-GetTime()))
			else
				ProcTable[index].Timer = format("%.1f", 0)
			end
		end	
	end

	ProcTable[index].NonStack = false
	
end

local function DetectBuffAbsence ( index )
	if ProcTable[index].NonStackingBuffs then
		for proc, procname in pairs(ProcTable[index].NonStackingBuffs) do
			name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff("player", procname)
			if ( name ~= nil ) then
				ProcTable[index].NonStack = true
			end
		end
	end
	
	name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff("player", ProcTable[index].Name)
	if ( not ProcTable[index].NonStack and
		not UnitIsPVPSanctuary("player") and
		(name == nil or ( expirationTime ~= nil and (-1*(GetTime()-expirationTime)) < 5) )  ) then
		ProcTable[index].Procced = true
		if ( expirationTime ~= nil ) then
			ProcTable[index].Timer = format("%.1f",-1*(GetTime()-expirationTime))
		else
			ProcTable[index].Timer = format("%.1f", 0)
		end
	end
	
	ProcTable[index].NonStack = false
end

local function DetectRage ( index )

	if InCombatLockdown() then
		if 80 < UnitPower ("player") then
			ProcTable[index].Procced = true
			ProcTable[index].Timer = format("%.1f", 0)
		end
	end
end

local function DetectStackingDebuff ( index )
	
	if ( InCombatLockdown() and CheckInteractDistance("target", 2) ) then
		if ProcTable[index].NonStackingBuffs then
			for proc, procname in pairs(ProcTable[index].NonStackingBuffs) do
				name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", procname)
				if ( name ~= nil ) then
					ProcTable[index].NonStack = true
				end
			end
		end
		
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", ProcTable[index].Name)
		if ( 	not ProcTable[index].NonStack and 
					(name == nil or 
					(expirationTime ~= nil and (expirationTime-GetTime()) < 5) or  
					(count ~= nil and count < 5)  )  ) then
			
			ProcTable[index].Procced = true
			
			if count == nil or expirationTime == nil then
				ProcTable[index].Timer = format("%.1f", 0)
			elseif ( count < 5 ) then
				ProcTable[index].Timer = format("Stacks %d", count)
			elseif (expirationTime-GetTime()) < 5 then
				ProcTable[index].Timer = format("%.1f", (expirationTime-GetTime()))
			
			end
		end	
	end

	ProcTable[index].NonStack = false
end

local function DetectExecute ( index )

	if InCombatLockdown() then
		if .2 > UnitHealth("target")/UnitHealthMax("target") then
			ProcTable[index].Procced = true
			ProcTable[index].Timer = format("%.1f", 0)
		end
	end
end

local function initProcTable ()

	local ProcEntry = {
	Rank = 0, 
	Procced = false, 
	NonStack = false, 
	Name = nil,
	Timer = format("%.1f", 0),
	NonStackingBuffs = nil,
	Color = { 0, 0, 0, 0 },
	BuffTarget = nil,
	Reset = true,
	Type = nil, -- 1 = proc, 2 = buff, 3 = debuff, 4 = ragedump
	Detect = false
	}
	
	ProcTable  = { 
	SnB = DeepCopy(ProcEntry),
	CS = DeepCopy(ProcEntry), 
	BS = DeepCopy(ProcEntry), 
	BT = DeepCopy(ProcEntry), 
	TC = DeepCopy(ProcEntry), 
	Rend = DeepCopy(ProcEntry), 
	DS = DeepCopy(ProcEntry), 
	HS = DeepCopy(ProcEntry), 
	TfB = DeepCopy(ProcEntry), 
	SD = DeepCopy(ProcEntry), 
	MS = DeepCopy(ProcEntry), 
	HString = DeepCopy(ProcEntry),
	Vig = DeepCopy(ProcEntry),
	Rage = DeepCopy(ProcEntry),
	Sunder = DeepCopy(ProcEntry),
	Execute = DeepCopy(ProcEntry)
	}
	
	ProcTable.SnB.Rank = 70
	ProcTable.SnB.Name = GetSpellInfo(46953)
	ProcTable.SnB.Color = { .33, .33, .33, 1 }
	ProcTable.SnB.Type = DetectBuff -- proc

	ProcTable.CS.Rank = 20
	ProcTable.CS.Name = GetSpellInfo(47440)
	ProcTable.CS.NonStackingBuffs = { BPname = GetSpellInfo(47982) }
	ProcTable.CS.Color = { 0, 0, 0, 1 }
	ProcTable.CS.Type = DetectBuffAbsence -- buff

	ProcTable.BS.Rank = 20
	ProcTable.BS.Name = GetSpellInfo(47436)
	ProcTable.BS.NonStackingBuffs = { GBOMname = GetSpellInfo(48934), BOMname = GetSpellInfo(48932) }
	ProcTable.BS.Color = { 0, 0, 1, 1 }
	ProcTable.BS.Type = DetectBuffAbsence -- buff

	ProcTable.BT.Rank = 90
	ProcTable.BT.Name = GetSpellInfo(46916)
	ProcTable.BT.Color = { 1, .5, 0, 1 }
	ProcTable.BT.Type = DetectBuff -- proc

	ProcTable.TC.Rank = 40
	ProcTable.TC.Name = GetSpellInfo(47502)
	ProcTable.TC.NonStackingBuffs = { FFname = GetSpellInfo(55095), IWname = GetSpellInfo(58181), JotJname = GetSpellInfo(68055) }
	ProcTable.TC.Color = { 1, 1, 1, 1 }
	ProcTable.TC.Type = DetectDebuff -- debuff
	
	ProcTable.Rend.Rank = 80
	ProcTable.Rend.Name = GetSpellInfo(47465)
	ProcTable.Rend.Color = { 0, 1, 0, 1 }
	ProcTable.Rend.Type = DetectDebuff -- debuff
	
	ProcTable.DS.Rank = 30
	ProcTable.DS.Name = GetSpellInfo(47437)
	ProcTable.DS.NonStackingBuffs = { DRname = GetSpellInfo(48560), CoWname = GetSpellInfo(50511) }
	ProcTable.DS.Color = { .5, 0, .8, 1 }
	ProcTable.DS.Type = DetectDebuff -- debuff

	ProcTable.HS.Rank = 60
	ProcTable.HS.Name = GetSpellInfo(58363)
	ProcTable.HS.Color = { 1, 0, 0, 1 }
	ProcTable.HS.Type = DetectBuff -- proc

	ProcTable.TfB.Rank = 50
	ProcTable.TfB.Name = GetSpellInfo(60503)
	ProcTable.TfB.Color = { .33, .33, .33, 1 }
	ProcTable.TfB.Type = DetectBuff -- proc

	ProcTable.SD.Rank = 65
	ProcTable.SD.Name = GetSpellInfo(52437)
	ProcTable.SD.Color = { 1, 0, 0, 1 }
	ProcTable.SD.Type = DetectBuff -- proc

	ProcTable.MS.Rank = 75
	ProcTable.MS.Name = GetSpellInfo(47486)
	ProcTable.MS.NonStackingBuffs = { WPname = GetSpellInfo(57975), ASname = GetSpellInfo(49050), FAname = GetSpellInfo(56112) }
	ProcTable.MS.Color = { 1, .5, 0, 1 }
	ProcTable.MS.Type = DetectDebuff -- debuff

	ProcTable.HString.Rank = 95
	ProcTable.HString.Name = GetSpellInfo(27584)
	ProcTable.HString.Color = { 1, .08, .58, 1 }
	ProcTable.HString.Type = DetectDebuff -- debuff
	
	ProcTable.Vig.Rank = 35
	ProcTable.Vig.Name = GetSpellInfo(50720)
	ProcTable.Vig.Color = { .69, .93, .93, 1 }
	ProcTable.Vig.Reset = false

	ProcTable.Rage.Rank = 10
	ProcTable.Rage.Name = Ragetext
	ProcTable.Rage.Color = { 1, 1, 0, 1 }
	ProcTable.Rage.Type = DetectRage -- Rage...special
	
	ProcTable.Sunder.Rank = 38
	ProcTable.Sunder.Name = GetSpellInfo(7386)
	ProcTable.Sunder.Color = { .72, .53, .04, 1 }
	ProcTable.Sunder.Type = DetectStackingDebuff -- stackingdebuff
	
	ProcTable.Execute.Rank = 45
	ProcTable.Execute.Name = Executetext
	ProcTable.Execute.Color = { .72, .53, .04, 1 }
	ProcTable.Execute.Type = DetectExecute -- execute
	
end
	
local function GetColor ( Entry )
	return Entry.Color[1], Entry.Color[2], Entry.Color[3], Entry.Color[4]
end

local LastDisplayTime = 0
local OptionShow = false
    
--Add-on On Load tasks
function WarriorProcAlert_OnLoadOptions(self)
	SLASH_WARRIORPROCALERT1 = "/wproc"
   	SlashCmdList["WARRIORPROCALERT"] = WarriorProcAlert_SlashCommand
	
	WarriorProcAlert_Transparent_Frame:RegisterEvent("ADDON_LOADED")
	
	if Initialized == false then
		initProcTable ()
	end
	
	if (not WarriorProcAlert_SavedOptions.Showing) then
		WarriorProcAlertProc_Frame:Hide()
	end

	WarriorProcAlertOptions_Frame:Hide()

	DEFAULT_CHAT_FRAME:AddMessage(STARTtext)	
end

function WarriorProcAlert_OnEvent(event, ...)
	
	local timestamp, type, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1, ...)

	if timestamp == "WarriorProcAlert" then
		
		if WarriorProcAlert_SavedOptions.ProfileBox > 0 then
			ProcTable.SnB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SwordnBoard
			ProcTable.Vig.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance
			ProcTable.TC.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThunderClap
			ProcTable.HS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].HeroicStrike
			ProcTable.DS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].DemoralizingShout
			ProcTable.Rend.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Rend
			ProcTable.TfB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThirstForBlood
			ProcTable.SD.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SuddenDeath
			ProcTable.MS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].MortalStrike
			ProcTable.BT.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].BloodThirst
			ProcTable.HString.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Hamstring
			ProcTable.Rage.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].RageDump
			ProcTable.Sunder.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Sunder
			ProcTable.Execute.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Execute
			
		else
			ProcTable.SnB.Detect = false
			ProcTable.Vig.Detect = false
			ProcTable.TC.Detect = false
			ProcTable.HS.Detect = false
			ProcTable.DS.Detect = false
			ProcTable.Rend.Detect = false
			ProcTable.TfB.Detect = false
			ProcTable.SD.Detect = false
			ProcTable.MS.Detect = false
			ProcTable.BT.Detect = false
			ProcTable.HString.Detect = false
			ProcTable.Rage.Detect = false
		end	
		
		if WarriorProcAlert_SavedOptions.ShoutBox == 10 then
			ProcTable.BS.Detect = 1
			ProcTable.CS.Detect = 0
		elseif WarriorProcAlert_SavedOptions.ShoutBox == 20 then
			ProcTable.BS.Detect = 0
			ProcTable.CS.Detect= 1
		else
			ProcTable.BS.Detect = 0
			ProcTable.CS.Detect= 0
		end
		
		if WarriorProcAlert_SavedOptions.Showing and 
		( WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance ) then
			WarriorProcAlert_Transparent_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			WarriorProcAlert_Transparent_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
			ProcTable.Vig.Procced = true
		else
			WarriorProcAlert_Transparent_Frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			WarriorProcAlert_Transparent_Frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			ProcTable.Vig.Procced = false
			ProcTable.Vig.BuffTarget = nil
		end
	elseif type == "SPELL_AURA_APPLIED" or type == "SPELL_AURA_REMOVED" or type == "SPELL_AURA_REFRESH" then
		if ProcTable.Vig.BuffTarget == nil or type == "PLAYER_ENTERING_WORLD" then
			ProcTable.Vig.Procced = true
			ProcTable.Vig.BuffTarget = nil
		end
		
		if (sourceName == UnitName("player")) then
			if (type == "SPELL_AURA_APPLIED") or (type == "SPELL_AURA_REFRESH") then
				local spellId, spellName, _ = select(9, ...)
				if (spellId == 50720) then
					ProcTable.Vig.Procced = false
					ProcTable.Vig.BuffTarget = destName
				end
			end
			if (type == "SPELL_AURA_REMOVED") then
				local spellId, _, _ = select(9, ...)
				if (spellId == 50720) then
					ProcTable.Vig.Procced = true
					ProcTable.Vig.BuffTarget = nil
				end
			end			
		end
	end
end
	
--Register the slash commands
function WarriorProcAlert_SlashCommand(msg)

	msg = string.lower(msg)
	local args = {}
	
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(args, word)
	end
		
	if ( args[1] ) then
		if ( args[1] == "options" ) then
			WarriorProcAlertOptions_Toggle()
			
		elseif ( args[1] == "help" ) then
			DEFAULT_CHAT_FRAME:AddMessage(USAGEtext)
			
		elseif ( args[1] == "show" ) then
			WarriorProcAlert_SavedOptions.Showing = not WarriorProcAlert_SavedOptions.Showing
			
		elseif ( args[1] == "lock" ) then
			WarriorProcAlert_SavedOptions.Lock = not WarriorProcAlert_SavedOptions.Lock
			
		elseif ( args[1] == "bs" ) then
			WarriorProcAlert_UpdateShout( 10 )
			
		elseif ( args[1] == "cs" ) then
			WarriorProcAlert_UpdateShout( 20 )
			
		elseif ( args[1] == "protection" ) then
			WarriorProcAlert_UpdateProfile ( 3 )
			
		elseif ( args[1] == "arms" ) then
			WarriorProcAlert_UpdateProfile ( 1 )
		 
		elseif ( args[1] == "fury" ) then
			WarriorProcAlert_UpdateProfile ( 2 )
			
		else
			DEFAULT_CHAT_FRAME:AddMessage(USAGEtext)
		end
		
	else
		DEFAULT_CHAT_FRAME:AddMessage(USAGEtext)
	end

end

function WarriorProcAlert_Transparent_Update()
    if ( LastDisplayTime < 10 ) then
        LastDisplayTime = LastDisplayTime + 1
    else
        LastDisplayTime = 0
        WarriorProcAlert_OnDisplay()
    end
end

function WarriorProcAlert_OnDisplay()
	
	if WarriorProcAlert_SavedOptions.Showing and 
		((not WarriorProcAlert_SavedOptions.InstanceOnly) or 
			(WarriorProcAlert_SavedOptions.InstanceOnly and IsInInstance()))
		then
		for procnum, procentry in pairs(ProcTable) do
			if procentry.Detect == 1 and procentry.Type ~= nil then
				procentry.Type(procnum)
			end
		end 
		
		local Shown_Rank = 0
        
		for procnum, procentry in pairs(ProcTable) do
			if (procentry.Procced and procentry.Rank > Shown_Rank) then
				Shown_Rank = procentry.Rank
			end
		end
		
		local ProcAvailable = false
		
		for procnum, procentry in pairs(ProcTable) do
			if procentry.Procced and procentry.Rank == Shown_Rank then 
				ProcAvailable = true
				WarriorProcAlertProc_Frame:Show()
				WarriorProcAlertProc_Frame:SetBackdropColor( GetColor(procentry) )
				WarriorProcAlertProc_Frame_Text:SetText(procentry.Name)
				WarriorProcAlertProc_Frame_Timer:SetText(procentry.Timer)
				break
			end
		end 
		
        if not ProcAvailable then
            WarriorProcAlertProc_Frame:Hide()
        end
		
		for procnum, procentry in pairs(ProcTable) do
			if procentry.Reset then
				procentry.Procced = false
			end
		end
		
	else
		WarriorProcAlertProc_Frame:Hide()
	end
end

function WarriorProcAlert_Lock(self)

	WarriorProcAlert_SavedOptions.Lock = not WarriorProcAlert_SavedOptions.Lock
	self:SetChecked(WarriorProcAlert_SavedOptions.Lock)
end

function WarriorProcAlert_DependencyButton(self)
	
	if self:GetChecked() then
		WarriorProcAlertOptions_FramechkInstance:Enable()
	else
		WarriorProcAlertOptions_FramechkInstance:SetChecked(false)
		WarriorProcAlertOptions_FramechkInstance:Disable()
	end

end

function WarriorProcAlert_UpdateShout( newValue )
	
	if WarriorProcAlert_SavedOptions.ShoutBox == newValue then
		WarriorProcAlert_SavedOptions.ShoutBox = 0
		WarriorProcAlertOptions_FrameShoutComboBoxText:SetText ( Nonetext )
		
	else		
		WarriorProcAlert_SavedOptions.ShoutBox = newValue
	end
	
	if WarriorProcAlert_SavedOptions.ShoutBox == 10 then
		ProcTable.BS.Detect = 1
		ProcTable.CS.Detect = 0
	elseif WarriorProcAlert_SavedOptions.ShoutBox == 20 then
		ProcTable.BS.Detect = 0
		ProcTable.CS.Detect= 1
	else
		ProcTable.BS.Detect = 0
		ProcTable.CS.Detect= 0
	end
	
	UIDropDownMenu_SetSelectedValue(WarriorProcAlertOptions_FrameShoutComboBox, WarriorProcAlert_SavedOptions.ShoutBox)
end

function WarriorProcAlert_SetChecks ( ProcEntry )
	
	if ProcEntry ~= nil then
		WarriorProcAlertOptions_FrameCheckButton1:SetChecked(ProcEntry.SwordnBoard)
		WarriorProcAlertOptions_FrameCheckButton2:SetChecked(ProcEntry.Vigilance)
		WarriorProcAlertOptions_FrameCheckButton3:SetChecked(ProcEntry.ThunderClap)
		WarriorProcAlertOptions_FrameCheckButton4:SetChecked(ProcEntry.HeroicStrike)
		WarriorProcAlertOptions_FrameCheckButton5:SetChecked(ProcEntry.DemoralizingShout)
		WarriorProcAlertOptions_FrameCheckButton6:SetChecked(ProcEntry.Rend)
		WarriorProcAlertOptions_FrameCheckButton7:SetChecked(ProcEntry.ThirstForBlood)
		WarriorProcAlertOptions_FrameCheckButton8:SetChecked(ProcEntry.SuddenDeath)
		WarriorProcAlertOptions_FrameCheckButton9:SetChecked(ProcEntry.MortalStrike)
		WarriorProcAlertOptions_FrameCheckButton10:SetChecked(ProcEntry.BloodThirst)
		WarriorProcAlertOptions_FrameCheckButton11:SetChecked(ProcEntry.Hamstring)
		WarriorProcAlertOptions_FrameCheckButton12:SetChecked(ProcEntry.RageDump)
		WarriorProcAlertOptions_FrameCheckButton13:SetChecked(ProcEntry.Sunder)
		WarriorProcAlertOptions_FrameCheckButton14:SetChecked(ProcEntry.Execute)
	else
		WarriorProcAlertOptions_FrameCheckButton1:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton2:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton3:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton4:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton5:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton6:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton7:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton8:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton9:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton10:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton11:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton12:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton13:SetChecked(false)
		WarriorProcAlertOptions_FrameCheckButton14:SetChecked(false)
	end
end

function WarriorProcAlert_UpdateProfile ( newValue )

	if WarriorProcAlert_SavedOptions.ProfileBox > 0 and OptionShow then
		-- Saves the old values
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SwordnBoard = WarriorProcAlertOptions_FrameCheckButton1:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance = WarriorProcAlertOptions_FrameCheckButton2:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThunderClap = WarriorProcAlertOptions_FrameCheckButton3:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].HeroicStrike = WarriorProcAlertOptions_FrameCheckButton4:GetChecked()	
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].DemoralizingShout = WarriorProcAlertOptions_FrameCheckButton5:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Rend = WarriorProcAlertOptions_FrameCheckButton6:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThirstForBlood = WarriorProcAlertOptions_FrameCheckButton7:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SuddenDeath = WarriorProcAlertOptions_FrameCheckButton8:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].MortalStrike = WarriorProcAlertOptions_FrameCheckButton9:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].BloodThirst = WarriorProcAlertOptions_FrameCheckButton10:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Hamstring = WarriorProcAlertOptions_FrameCheckButton11:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].RageDump = WarriorProcAlertOptions_FrameCheckButton12:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Sunder = WarriorProcAlertOptions_FrameCheckButton13:GetChecked()
		WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Execute = WarriorProcAlertOptions_FrameCheckButton14:GetChecked()		
		
	else
		ProcTable.SnB.Detect = false
		ProcTable.Vig.Detect = false
		ProcTable.TC.Detect = false
		ProcTable.HS.Detect = false
		ProcTable.DS.Detect = false
		ProcTable.Rend.Detect = false
		ProcTable.TfB.Detect = false
		ProcTable.SD.Detect = false
		ProcTable.MS.Detect = false
		ProcTable.BT.Detect = false
		ProcTable.HString.Detect = false
		ProcTable.Rage.Detect = false
		ProcTable.Sunder.Detect = false
		ProcTable.Execute.Detect = false
	end
	
	if WarriorProcAlert_SavedOptions.ProfileBox == newValue then
		WarriorProcAlert_SavedOptions.ProfileBox = 0
		WarriorProcAlertOptions_FrameProfileComboBoxText:SetText ( Nonetext )
		UIDropDownMenu_SetSelectedValue(WarriorProcAlertOptions_FrameProfileComboBox, 0)
	else
		UIDropDownMenu_SetSelectedValue(WarriorProcAlertOptions_FrameProfileComboBox, newValue)
		WarriorProcAlert_SavedOptions.ProfileBox = newValue
		-- Sets the alert for the new value
		ProcTable.SnB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SwordnBoard
		ProcTable.Vig.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance
		ProcTable.TC.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThunderClap
		ProcTable.HS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].HeroicStrike
		ProcTable.DS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].DemoralizingShout
		ProcTable.Rend.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Rend
		ProcTable.TfB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThirstForBlood
		ProcTable.SD.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SuddenDeath
		ProcTable.MS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].MortalStrike
		ProcTable.BT.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].BloodThirst
		ProcTable.HString.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Hamstring
		ProcTable.Rage.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].RageDump
		ProcTable.Sunder.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Sunder
		ProcTable.Execute.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Exeucte
	end
	
	-- Set Buttons if visible
	if OptionShow then
		WarriorProcAlert_SetChecks ( WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox] )
	end
end

function WarriorProcAlertOptions_ClickShoutComboBox(self)

	if self:GetName() == "DropDownList1Button1" then
		WarriorProcAlert_UpdateShout( 10 )
	elseif self:GetName() == "DropDownList1Button2" then
		WarriorProcAlert_UpdateShout( 20 )
	end
end

function WarriorProcAlertOptions_ClickProfileComboBox(self)

	if self:GetName() == "DropDownList1Button1" then
		WarriorProcAlert_UpdateProfile( 1 )
	elseif self:GetName() == "DropDownList1Button2" then
		WarriorProcAlert_UpdateProfile( 2 )
	elseif self:GetName() == "DropDownList1Button3" then
		WarriorProcAlert_UpdateProfile( 3 )
	end
end

function WarriorProcAlertOptions_ShoutDropDownMenu_OnLoad()
	
	if Initialized == false then
		Initialized = true
		initProcTable ()
	end
	
	info = {}
	
	info.text       = ProcTable.BS.Name
	info.value      = 10
	info.func       = WarriorProcAlertOptions_ClickShoutComboBox
	if ( WarriorProcAlert_SavedOptions.ShoutBox == 10 ) then
		info.checked 	= true
		WarriorProcAlertOptions_FrameShoutComboBoxText:SetText ( ProcTable.BS.Name )
	else
		info.checked 	= false
	end
	UIDropDownMenu_AddButton(info)
	
	info.text       = ProcTable.CS.Name
	info.value      = 20
	info.func       = WarriorProcAlertOptions_ClickShoutComboBox
	if ( WarriorProcAlert_SavedOptions.ShoutBox == 20 ) then
		info.checked 	= true
		WarriorProcAlertOptions_FrameShoutComboBoxText:SetText ( ProcTable.CS.Name )
	else
		info.checked 	= false
	end
	UIDropDownMenu_AddButton(info)

end

function WarriorProcAlertOptions_ProfileDropDownMenu_OnLoad()

	info = {}
   
	for index = 1, 3 do
		info.text       = WarriorProcAlert_SavedOptions.Profiles[index].Name
		info.value      = index
		info.func       = WarriorProcAlertOptions_ClickProfileComboBox
		if ( WarriorProcAlert_SavedOptions.ProfileBox == index ) then
			info.checked = true
		else
			info.checked = false
		end
	
		UIDropDownMenu_AddButton(info)
	end
end

--Shows and hides the options frame.
function WarriorProcAlertOptions_Toggle()
	
	OptionShow = not OptionShow
	
	if OptionShow then
		WarriorProcAlertOptions_Frame:Show()
        
		-- Set Labels for top checkboxes
		WarriorProcAlertOptions_FramechkShowText:SetText(Showtext)
		WarriorProcAlertOptions_FramechkInstanceText:SetText(Instancetext)
		
		WarriorProcAlertOptions_FramechkLockText:SetText(Locktext)
		
		-- Set the Labels for the checkboxes
		WarriorProcAlertOptions_FrameCheckButton1Text:SetText(ProcTable.SnB.Name)
		WarriorProcAlertOptions_FrameCheckButton2Text:SetText(ProcTable.Vig.Name)
		WarriorProcAlertOptions_FrameCheckButton3Text:SetText(ProcTable.TC.Name)
		WarriorProcAlertOptions_FrameCheckButton4Text:SetText(ProcTable.HS.Name)
		WarriorProcAlertOptions_FrameCheckButton5Text:SetText(ProcTable.DS.Name)
		WarriorProcAlertOptions_FrameCheckButton6Text:SetText(ProcTable.Rend.Name)
		WarriorProcAlertOptions_FrameCheckButton7Text:SetText(ProcTable.TfB.Name)
		WarriorProcAlertOptions_FrameCheckButton8Text:SetText(ProcTable.SD.Name)
		WarriorProcAlertOptions_FrameCheckButton9Text:SetText(ProcTable.MS.Name)
		WarriorProcAlertOptions_FrameCheckButton10Text:SetText(ProcTable.BT.Name)
		WarriorProcAlertOptions_FrameCheckButton11Text:SetText(ProcTable.HString.Name)
		WarriorProcAlertOptions_FrameCheckButton12Text:SetText(ProcTable.Rage.Name)
		WarriorProcAlertOptions_FrameCheckButton13Text:SetText(ProcTable.Sunder.Name)
		WarriorProcAlertOptions_FrameCheckButton14Text:SetText(ProcTable.Execute.Name)
		
		-- Set the Labels for ComboBoxes
		WarriorProcAlertOptions_ProfileDropDownMenu_OnLoad()
		UIDropDownMenu_SetSelectedValue(WarriorProcAlertOptions_FrameProfileComboBox, WarriorProcAlert_SavedOptions.ProfileBox)
		if WarriorProcAlert_SavedOptions.ProfileBox == 0 then
			WarriorProcAlertOptions_FrameProfileComboBoxText:SetText ( Nonetext )
			WarriorProcAlert_SetChecks ( nil )
		else
			WarriorProcAlert_SetChecks ( WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox] )
		end
		
		WarriorProcAlertOptions_ShoutDropDownMenu_OnLoad()
		UIDropDownMenu_SetSelectedValue(WarriorProcAlertOptions_FrameShoutComboBox, WarriorProcAlert_SavedOptions.ShoutBox)
		
		if WarriorProcAlert_SavedOptions.ShoutBox == 0 then			
			WarriorProcAlertOptions_FrameShoutComboBoxText:SetText ( Nonetext )
		end

		-- Set the Checkboxes themselves
		WarriorProcAlertOptions_FramechkShow:SetChecked(WarriorProcAlert_SavedOptions.Showing)
		WarriorProcAlert_DependencyButton(WarriorProcAlertOptions_FramechkShow)
		WarriorProcAlertOptions_FramechkInstance:SetChecked(WarriorProcAlert_SavedOptions.InstanceOnly)
		WarriorProcAlertOptions_FramechkLock:SetChecked(WarriorProcAlert_SavedOptions.Lock)
			
	else
		WarriorProcAlertOptions_Frame:Hide()
		
		WarriorProcAlert_SavedOptions.Showing = WarriorProcAlertOptions_FramechkShow:GetChecked()
		WarriorProcAlert_SavedOptions.InstanceOnly = WarriorProcAlertOptions_FramechkInstance:GetChecked()
		WarriorProcAlert_SavedOptions.Lock = WarriorProcAlertOptions_FramechkLock:GetChecked()
		
		WarriorProcAlert_SavedOptions.ShoutBox = UIDropDownMenu_GetSelectedValue ( WarriorProcAlertOptions_FrameShoutComboBox )
		
		WarriorProcAlert_SavedOptions.ProfileBox = UIDropDownMenu_GetSelectedValue ( WarriorProcAlertOptions_FrameProfileComboBox )
		
		if WarriorProcAlert_SavedOptions.ShoutBox == 10 then
			ProcTable.BS.Detect = 1
			ProcTable.CS.Detect = 0
		elseif WarriorProcAlert_SavedOptions.ShoutBox == 20 then
			ProcTable.BS.Detect = 0
			ProcTable.CS.Detect= 1
		else
			ProcTable.BS.Detect = 0
			ProcTable.CS.Detect= 0
		end
		
		if WarriorProcAlert_SavedOptions.ProfileBox > 0 then
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SwordnBoard = WarriorProcAlertOptions_FrameCheckButton1:GetChecked()
			ProcTable.SnB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SwordnBoard
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance = WarriorProcAlertOptions_FrameCheckButton2:GetChecked()
			ProcTable.Vig.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Vigilance
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThunderClap = WarriorProcAlertOptions_FrameCheckButton3:GetChecked()
			ProcTable.TC.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThunderClap
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].HeroicStrike = WarriorProcAlertOptions_FrameCheckButton4:GetChecked()	
			ProcTable.HS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].HeroicStrike
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].DemoralizingShout = WarriorProcAlertOptions_FrameCheckButton5:GetChecked()
			ProcTable.DS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].DemoralizingShout
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Rend = WarriorProcAlertOptions_FrameCheckButton6:GetChecked()
			ProcTable.Rend.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Rend
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThirstForBlood = WarriorProcAlertOptions_FrameCheckButton7:GetChecked()
			ProcTable.TfB.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].ThirstForBlood
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SuddenDeath = WarriorProcAlertOptions_FrameCheckButton8:GetChecked()
			ProcTable.SD.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].SuddenDeath
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].MortalStrike = WarriorProcAlertOptions_FrameCheckButton9:GetChecked()
			ProcTable.MS.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].MortalStrike
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].BloodThirst = WarriorProcAlertOptions_FrameCheckButton10:GetChecked()
			ProcTable.BT.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].BloodThirst
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Hamstring = WarriorProcAlertOptions_FrameCheckButton11:GetChecked()
			ProcTable.HString.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Hamstring
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].RageDump = WarriorProcAlertOptions_FrameCheckButton12:GetChecked()
			ProcTable.Rage.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].RageDump
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Sunder = WarriorProcAlertOptions_FrameCheckButton13:GetChecked()
			ProcTable.Sunder.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Sunder
			WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Execute = WarriorProcAlertOptions_FrameCheckButton14:GetChecked()
			ProcTable.Execute.Detect = WarriorProcAlert_SavedOptions.Profiles[WarriorProcAlert_SavedOptions.ProfileBox].Execute
		else
			ProcTable.SnB.Detect = false
			ProcTable.Vig.Detect = false
			ProcTable.TC.Detect = false
			ProcTable.HS.Detect = false
			ProcTable.DS.Detect = false
			ProcTable.Rend.Detect = false
			ProcTable.TfB.Detect = false
			ProcTable.SD.Detect = false
			ProcTable.MS.Detect = false
			ProcTable.BT.Detect = false
			ProcTable.HString.Detect = false
			ProcTable.Rage.Detect = false
			ProcTable.Sunder.Detect = false
			ProcTable.Execute.Detect = false
			
		end
	end
end
