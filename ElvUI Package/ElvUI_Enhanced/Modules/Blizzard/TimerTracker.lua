local E, L, V, P, G = unpack(ElvUI)
local TT = E:NewModule("Enhanced_TimerTracker", "AceHook-3.0", "AceEvent-3.0")

local ipairs = ipairs
local tonumber = tonumber
local unpack = unpack
local floor, fmod = math.floor, math.fmod

local GetTime = GetTime
local UnitFactionGroup = UnitFactionGroup

local timerTypes = {
	["30-120"] = {1, 30, 120},
	["60-120"] = {1, 60, 120},
	["120-120"] = {1, 120, 120},
	["15-60"] = {1, 15, 60},
	["30-60"] = {1, 30, 60},
	["60-60"] = {1, 60, 60},
}

local chatMessage = {
	-- Ущелье Песни Войны
	["Битва за Ущелье Песни Войны начнется через 30 секунд. Приготовьтесь!"] = timerTypes["30-120"],
	["Битва за Ущелье Песни Войны начнется через 1 минуту."] = timerTypes["60-120"],
	["Сражение в Ущелье Песни Войны начнется через 2 минуты."] = timerTypes["120-120"],
	-- Низина Арати
	["Битва за Низину Арати начнется через 30 секунд. Приготовьтесь!"] = timerTypes["30-120"],
	["Битва за Низину Арати начнется через 1 минуту."] = timerTypes["60-120"],
	["Сражение в Низине Арати начнется через 2 минуты."] = timerTypes["120-120"],
	-- Око Бури
	["Битва за Око Бури начнется через 30 секунд."] = timerTypes["30-120"],
	["Битва за Око Бури начнется через 1 минуту."] = timerTypes["60-120"],
	["Сражение в Око Бури начнется через 2 минуты."] = timerTypes["120-120"],
	-- Альтеракская долина
	["Сражение на Альтеракской долине начнется через 30 секунд. Приготовьтесь!"] = timerTypes["30-120"],
	["Сражение на Альтеракской долине начнется через 1 минуту."] = timerTypes["60-120"],
	["Сражение на Альтеракской долине начнется через 2 минуты."] = timerTypes["120-120"],
	-- Берег Древних
	["Битва за Берег Древних начнется через 30 секунд. Приготовьтесь!"] = timerTypes["30-120"],
	["Битва за Берег Древних начнется через 1 минуту."] = timerTypes["60-120"],
	["Битва за Берег Древних начнется через 2 минуты."] = timerTypes["120-120"],
	-- Берег древних 2-й раунд
	["Второй раунд начнется через 30 секунд. Приготовьтесь!"] = timerTypes["30-60"],
	["Второй раунд битвы за Берег Древних начнется через 1 минуту."] = timerTypes["60-60"],
	-- Другие
	["Битва начнется через 30 секунд!"] = timerTypes["30-120"],
	["Битва начнется через 1 минуту."] = timerTypes["60-120"],
	["Битва начнется через 2 минуты."] = timerTypes["120-120"],
	-- Арена
	["15 секунд до начала боя на арене!"] = timerTypes["15-60"],
	["30 секунд до начала боя на арене!"] = timerTypes["30-60"],
	["1 минута до начала боя на арене!"] = timerTypes["60-60"],
	["Пятнадцать секунд до начала боя на арене!"] = timerTypes["15-60"],
	["Тридцать секунд до начала боя на арене !"] = timerTypes["30-60"],

	-- WSG
	["The battle for Warsong Gulch begins in 30 seconds. Prepare yourselves!"] = timerTypes["30-120"],
	["The battle for Warsong Gulch begins in 1 minute."] = timerTypes["60-120"],
	["The battle for Warsong Gulch begins in 2 minutes."] = timerTypes["120-120"],
	-- AB
	["The Battle for Arathi Basin begins in 30 seconds. Prepare yourselves!"] = timerTypes["30-120"],
	["The Battle for Arathi Basin begins in 1 minute."] = timerTypes["60-120"],
	["The battle for Arathi Basin begins in 2 minutes."] = timerTypes["120-120"],
	-- EotS
	["The Battle for Eye of the Storm begins in 30 seconds."] = timerTypes["30-120"],
	["The Battle for Eye of the Storm begins in 1 minute."] = timerTypes["60-120"],
	["The battle for Eye of the Storm begins in 2 minutes."] = timerTypes["120-120"],
	-- AV
	["The Battle for Alterac Valley begins in 30 seconds. Prepare yourselves!"] = timerTypes["30-120"],
	["The Battle for Alterac Valley begins in 1 minute."] = timerTypes["60-120"],
	["The Battle for Alterac Valley begins in 2 minutes."] = timerTypes["120-120"],
	-- SotA
	["The battle for Strand of the Ancients begins in 30 seconds. Prepare yourselves!."] = timerTypes["30-120"],
	["The battle for Strand of the Ancients begins in 1 minute."] = timerTypes["60-120"],
	["The battle for Strand of the Ancients begins in 2 minutes."] = timerTypes["120-120"],
	-- SotA 2 round
	["Round 2 begins in 30 seconds. Prepare yourselves!"] = timerTypes["30-60"],
	["Round 2 of the Battle for the Strand of the Ancients begins in 1 minute."] = timerTypes["60-60"],
	-- Other
	["The battle will begin in 30 seconds!"] = timerTypes["30-120"],
	["The battle will begin in 1 minute."] = timerTypes["60-120"],
	["The battle will begin in two minutes."] = timerTypes["120-120"],
	["The battle begins in 30 seconds!"] = timerTypes["30-120"],
	["The battle begins in 1 minute!"] = timerTypes["60-120"],
	["The battle begins in 2 minutes!"] = timerTypes["120-120"],
	-- Arena
	["Fifteen seconds until the Arena battle begins!"] = timerTypes["15-60"],
	["Thirty seconds until the Arena battle begins!"] = timerTypes["30-60"],
	["One minute until the Arena battle begins!"] = timerTypes["60-60"]
}

local TIMER_MINUTES_DISPLAY = "%d:%02d"
local TIMER_TYPE_PVP = 1
local TIMER_TYPE_CHALLENGE_MODE = 2
local TIMER_TYPE_PLAYER_COUNTDOWN = 3

local TIMER_DATA = {
	[1] = {mediumMarker = 11, largeMarker = 6, updateInterval = 10},
	[2] = {mediumMarker = 100, largeMarker = 100, updateInterval = 100},
	[3] = {mediumMarker = 31, largeMarker = 11, updateInterval = 10}
}

local TIMER_NUMBERS_SETS = {}
TIMER_NUMBERS_SETS["BigGold"] = {
	texture = "Interface\\AddOns\\ElvUI_Enhanced\\media\\textures\\BigTimerNumbers",
	w = 256, h = 170, texW = 1024, texH = 512,
	numberHalfWidths = {
		35/128, -- 0
		14/128, -- 1
		33/128, -- 2
		32/128, -- 3
		36/128, -- 4
		32/128, -- 5
		33/128, -- 6
		29/128, -- 7
		31/128, -- 8
		31/128, -- 9
	}
}

local function CreateAlphaAnim(group, order, duration, change, delay, smoothing)
	local anim = group:CreateAnimation("Alpha")
	anim:SetOrder(order)
	anim:SetDuration(duration)
	anim:SetChange(change)

	if delay then
		anim:SetStartDelay(delay)
	end
	if smoothing then
		anim:SetSmoothing(smoothing)
	end
end

local function CreateScaleAnim(group, order, duration, scale, delay, smoothing)
	local anim = group:CreateAnimation("Scale")
	anim:SetOrder(order)
	anim:SetDuration(duration)
	anim:SetScale(scale, scale)

	if delay then
		anim:SetStartDelay(delay)
	end
	if smoothing then
		anim:SetSmoothing(smoothing)
	end
end

local function Timer_OnShow(self)
	self.time = self.endTime - GetTime()

	if self.time <= 0 then
		self:Hide()
		self.isFree = true
	elseif self.StartNumbers:IsPlaying() then
		self.StartNumbers:Stop()
		self.StartNumbers:Play()
		self.StartGlowNumbers:Stop()
		self.StartGlowNumbers:Play()
	end
end

local function StartNumbers_OnPlay(self)
	local timer = self:GetParent():GetParent()
	TT:SetTexNumbers(timer, timer.Digit1, timer.Digit2)
end

local function StartNumbers_OnFinished(self)
	local timer = self:GetParent():GetParent()
	timer.time = timer.time - 1

	if timer.time > 0 then
		if timer.time < TIMER_DATA[timer.type].largeMarker and not self.anchorCenter then
			TT:SwitchToLargeDisplay(timer)
		end

		timer.StartNumbers:Play()
		timer.StartGlowNumbers:Play()
	else
		timer.anchorCenter = false
		timer.isFree = true
		timer.GoTextureAnim:Play()
		timer.GoTextureGlowAnim:Play()
	end
end

local function FadeBarIn_OnPlay(self)
	local timer = self:GetParent():GetParent()
	timer.StatusBar:Show()
end

local function FadeBarOut_OnFinished(self)
	local timer = self:GetParent():GetParent()
	timer.time = timer.time - 0.9
	timer.StatusBar:Hide()
	timer.StartNumbers:Play()
	timer.StartGlowNumbers:Play()
end

function TT:CreateTimerBar()
	local timer = CreateFrame("Frame", "ElvUI_Timer"..(#self.timerList + 1), UIParent)
	timer:Size(206, 26)

	timer.GoFrame = CreateFrame("Frame", "$parentGoFrame", timer)
	timer.GoFrame:SetFrameLevel(1)
	timer.GoFrame:SetAlpha(0)
	timer.GoFrame:SetSize(256, 256)
	timer.GoFrame:SetPoint("CENTER", UIParent)
	timer.GoTextureAnim = timer.GoFrame:CreateAnimationGroup()
	CreateScaleAnim(timer.GoTextureAnim, 1, 0, 0.25)
	CreateAlphaAnim(timer.GoTextureAnim, 1, 0, 1)
	CreateScaleAnim(timer.GoTextureAnim, 2, 0.4, 4, nil, "OUT")
	CreateScaleAnim(timer.GoTextureAnim, 3, 0.2, 1.4, 0.6, "OUT")
	CreateAlphaAnim(timer.GoTextureAnim, 3, 0.2, -1, 0.6, "OUT")

	timer.GoTexture = timer.GoFrame:CreateTexture()
	timer.GoTexture:SetAllPoints()

	timer.GoGlowFrame = CreateFrame("Frame", "$parentGoGlowFrame", timer)
	timer.GoGlowFrame:SetFrameLevel(2)
	timer.GoGlowFrame:SetAlpha(0)
	timer.GoGlowFrame:SetAllPoints(timer.GoFrame)
	timer.GoTextureGlowAnim = timer.GoGlowFrame:CreateAnimationGroup()
	CreateScaleAnim(timer.GoTextureGlowAnim, 1, 0, 0.25)
	CreateAlphaAnim(timer.GoTextureGlowAnim, 1, 0, 1)
	CreateScaleAnim(timer.GoTextureGlowAnim, 2, 0.4, 4, nil, "OUT")
	CreateAlphaAnim(timer.GoTextureGlowAnim, 2, 0.4, -1, nil, "IN")

	timer.GoTextureGlow = timer.GoGlowFrame:CreateTexture()
	timer.GoTextureGlow:SetAllPoints()

	timer.DigitFrame = CreateFrame("Frame", "$parentDigitFrame", timer)
	timer.DigitFrame:SetFrameLevel(1)
	timer.DigitFrame:SetAlpha(0)
	timer.StartNumbers = timer.DigitFrame:CreateAnimationGroup()
	CreateScaleAnim(timer.StartNumbers, 1, 0, 0.25)
	CreateAlphaAnim(timer.StartNumbers, 1, 0, -1)
	CreateAlphaAnim(timer.StartNumbers, 2, 0, 1)
	CreateScaleAnim(timer.StartNumbers, 3, 0.3, 4, nil, "OUT")
	CreateScaleAnim(timer.StartNumbers, 4, 0.1, 1.2, 0.6)
	CreateAlphaAnim(timer.StartNumbers, 4, 0.1, -1, 0.6)
	timer.StartNumbers:SetScript("OnPlay", StartNumbers_OnPlay)
	timer.StartNumbers:SetScript("OnFinished", StartNumbers_OnFinished)

	timer.Digit1 = timer.DigitFrame:CreateTexture()
	timer.Digit2 = timer.DigitFrame:CreateTexture()

	timer.DigitGlowFrame = CreateFrame("Frame", "$parentDigitGlowFrame", timer)
	timer.DigitGlowFrame:SetFrameLevel(2)
	timer.DigitGlowFrame:SetAlpha(0)
	timer.StartGlowNumbers = timer.DigitGlowFrame:CreateAnimationGroup()
	CreateScaleAnim(timer.StartGlowNumbers, 1, 0, 0.25)
	CreateAlphaAnim(timer.StartGlowNumbers, 1, 0, 1)
	CreateScaleAnim(timer.StartGlowNumbers, 2, 0.3, 4, nil, "OUT")
	CreateAlphaAnim(timer.StartGlowNumbers, 2, 0.3, -1, nil, "IN")

	timer.Digit1.Glow = timer.DigitGlowFrame:CreateTexture()
	timer.Digit1.Glow:SetAllPoints(timer.Digit1)
	timer.Digit2.Glow = timer.DigitGlowFrame:CreateTexture()
	timer.Digit2.Glow:SetAllPoints(timer.Digit2)

	timer.StatusBar = CreateFrame("StatusBar", "$parentStatusBar", timer)
	timer.StatusBar:Hide()
	timer.StatusBar:Size(195, 13)
	timer.StatusBar:Point("TOP", 0, -2)
	timer.StatusBar:SetStatusBarTexture(E.media.glossTex)
	E:RegisterStatusBar(timer.StatusBar)
	timer.StatusBar:CreateBackdrop("Default")

	timer.StatusBar.Background = timer.StatusBar:CreateTexture("$parentBackground", "BORDER")
	timer.StatusBar.Background:SetAllPoints()
	timer.StatusBar.Background:SetTexture(E.media.blankTex)

	timer.StatusBar.Text = timer.StatusBar:CreateFontString("$parentTimeText", "OVERLAY", "GameFontHighlight")
	timer.StatusBar.Text:SetPoint("CENTER", 0, 0)

	timer.FadeBarIn = timer.StatusBar:CreateAnimationGroup()
	CreateAlphaAnim(timer.FadeBarIn, 1, 0, -1)
	CreateAlphaAnim(timer.FadeBarIn, 2, 1.9, 1)
	timer.FadeBarIn:SetScript("OnPlay", FadeBarIn_OnPlay)

	timer.FadeBarOut = timer.StatusBar:CreateAnimationGroup()
	CreateAlphaAnim(timer.FadeBarOut, 1, 0.9, -1)
	timer.FadeBarOut:SetScript("OnFinished", FadeBarOut_OnFinished)

	timer:SetScript("OnShow", Timer_OnShow)

	return timer
end

function TT:CreateTimer(timerType, timeSeconds, totalTime)
	if not timerType then return end

	local timer
	local isTimerRunning = false

	for _, frame in ipairs(self.timerList) do
		if frame.type == timerType and not frame.isFree then
			timer = frame
			isTimerRunning = true
			break
		end
	end

	if isTimerRunning and timer.type ~= TIMER_TYPE_PLAYER_COUNTDOWN then
		if not timer.StartNumbers:IsPlaying() then
			timer.time = timeSeconds
			timer.endTime = GetTime() + timeSeconds
		end
	else
		for _, frame in ipairs(self.timerList) do
			if frame.isFree then
				timer = frame
				break
			end
		end

		if not timer then
			timer = self:CreateTimerBar()
			self.timerList[#self.timerList + 1] = timer
		end

		timer:ClearAllPoints()
		timer:Point("TOP", 0, -155 - (24 * #self.timerList))

		timer.isFree = false
		timer.type = timerType
		timer.time = timeSeconds
		timer.endTime = GetTime() + timeSeconds
		timer.totalTime = totalTime
		timer.StatusBar:SetMinMaxValues(0, totalTime)
		timer.style = TIMER_NUMBERS_SETS["BigGold"]

		timer.Digit1:Size(timer.style.w / 2, timer.style.h / 2)
		timer.Digit2:Size(timer.style.w / 2, timer.style.h / 2)
		timer.Digit1.width = timer.style.w / 2
		timer.Digit2.width = timer.style.w / 2
		timer.Digit1:SetTexture(timer.style.texture)
		timer.Digit2:SetTexture(timer.style.texture)
		timer.Digit1.Glow:SetTexture(timer.style.texture.."Glow")
		timer.Digit2.Glow:SetTexture(timer.style.texture.."Glow")

		timer.updateTime = TIMER_DATA[timer.type].updateInterval
		timer:SetScript("OnUpdate", self.BigNumberOnUpdate)
		timer:Show()
	end

	self:SetGoTexture(timer)
end

function TT:BigNumberOnUpdate(elapsed)
	self.time = self.endTime - GetTime()
	self.updateTime = self.updateTime - elapsed

	if self.time < TIMER_DATA[self.type].mediumMarker then
		if (self.time < TIMER_DATA[self.type].largeMarker) and not self.anchorCenter then
			TT:SwitchToLargeDisplay(self)
		elseif self.anchorCenter then
			self.anchorCenter = false
		end

		self:SetScript("OnUpdate", nil)

		if self.barShowing then
			self.barShowing = false
			self.FadeBarOut:Play()
		else
			self.StartNumbers:Play()
			self.StartGlowNumbers:Play()
		end
	elseif not self.barShowing then
		self.FadeBarIn:Play()
		self.barShowing = true
	elseif self.updateTime <= 0 then
		self.updateTime = TIMER_DATA[self.type].updateInterval
	end

	self.StatusBar:SetValue(self.time)
	local minutes, seconds = floor(self.time / 60), floor(fmod(self.time, 60))
	self.StatusBar.Text:SetFormattedText(TIMER_MINUTES_DISPLAY, minutes, seconds)

	local r, g, b = E:ColorGradient((self.time - 10) / self.totalTime, 1,0,0, 1,1,0, 0,1,0)
	self.StatusBar:SetStatusBarColor(r, g, b)
	self.StatusBar.Background:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
end

function TT:SetTexNumbers(timer, ...)
	local digits = {...}
	local timeDigits = floor(timer.time)
	local style = timer.style

	local texCoW = style.w / style.texW
	local texCoH = style.h / style.texH
	local columns = floor(style.texW / style.w)

	local digit, l, r, t, b
	local numberOffset, numShown = 0, 0
	local i = 1

	while digits[i] do
		if timeDigits > 0 then
			digit = fmod(timeDigits, 10)

			digits[i].hw = style.numberHalfWidths[digit + 1] * digits[i].width
			numberOffset = numberOffset + digits[i].hw

			l = fmod(digit, columns) * texCoW
			r = l + texCoW
			t = floor(digit / columns) * texCoH
			b = t + texCoH

			digits[i]:SetTexCoord(l, r, t, b)
			digits[i].Glow:SetTexCoord(l, r, t, b)

			timeDigits = floor(timeDigits / 10)
			numShown = numShown + 1
		else
			digits[i]:SetTexCoord(0, 0, 0, 0)
			digits[i].Glow:SetTexCoord(0, 0, 0, 0)
		end

		i = i + 1
	end

	if numberOffset > 0 then
		digits[1]:ClearAllPoints()

		if timer.anchorCenter then
			digits[1]:Point("CENTER", UIParent, "CENTER", numberOffset - digits[1].hw, 0)
		else
			digits[1]:Point("CENTER", timer, "CENTER", numberOffset - digits[1].hw, 0)
		end

		for j = 2, numShown do
			digits[j]:ClearAllPoints()
			digits[j]:Point("CENTER", digits[j - 1], "CENTER", -(digits[j].hw + digits[j - 1].hw), 0)
		end
	end
end

function TT:SetGoTexture(timer)
	if timer.type == TIMER_TYPE_PVP then
		local factionGroup = UnitFactionGroup("player")

		if factionGroup and factionGroup ~= "Neutral" then
			timer.GoTexture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\"..factionGroup.."-Logo")
			timer.GoTextureGlow:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\media\\textures\\"..factionGroup.."Glow-Logo")
		end
	elseif timer.type == TIMER_TYPE_CHALLENGE_MODE then
		timer.GoTexture:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\media\\textures\\Challenges-Logo")
		timer.GoTextureGlow:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\media\\textures\\ChallengesGlow-Logo")
	elseif timer.type == TIMER_TYPE_PLAYER_COUNTDOWN then 
		timer.GoTexture:SetTexture("")
		timer.GoTextureGlow:SetTexture("")
	end
end

function TT:SwitchToLargeDisplay(timer)
	timer.Digit1:Size(timer.style.w, timer.style.h)
	timer.Digit2:Size(timer.style.w, timer.style.h)
	timer.Digit1.width = timer.style.w
	timer.Digit2.width = timer.style.w
	timer.anchorCenter = true
end

function TT:ReleaseTimers()
	for _, timer in ipairs(self.timerList) do
		timer.barShowing = false
		timer.isFree = true
	end
end

function TT:OnEvent(event, msg)
	if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
		if msg and chatMessage[msg] then
			self:CreateTimer(unpack(chatMessage[msg]))
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:ReleaseTimers()
	end
end

function TT:HookDBM()
	if not DBM then return end

	if E.db.enhanced.timerTracker.dbm then
		self:SecureHook(DBM, "CreatePizzaTimer", function(_, time, text)
			if text == DBM_CORE_TIMER_PULL then
				DBM.Bars:CancelBar(DBM_CORE_TIMER_PULL)
				time = (tonumber(time) or 10) + 0.1
				self:CreateTimer(E.db.enhanced.timerTracker.dbmTimerType, time, time)
			end
		end)
	else
		self:Unhook(DBM, "CreatePizzaTimer")
	end
end

function TT:ToggleState()
	if E.db.enhanced.timerTracker.enable then
		self.timerList = self.timerList or {}

		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")

		self:HookDBM()
	else
		self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		self:Unhook(DBM, "CreatePizzaTimer")
		self:ReleaseTimers()
	end
end

function TT:Initialize()
	if not E.db.enhanced.timerTracker.enable then return end

	self:ToggleState()
end

local function InitializeCallback()
	TT:Initialize()
end

E:RegisterModule(TT:GetName(), InitializeCallback)