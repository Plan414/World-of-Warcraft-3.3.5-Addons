local _, ns = ...
local oUF = oUF or ns.oUF or ElvUF
if not oUF then return end

local find = string.find

local GetInventoryItemID = GetInventoryItemID
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitAttackSpeed = UnitAttackSpeed
local UnitCastingInfo = UnitCastingInfo
local UnitRangedDamage = UnitRangedDamage

local mainHandID = GetInventoryItemID("player", 16)
local offHandID = GetInventoryItemID("player", 17)
local rangedID = GetInventoryItemID("player", 18)

local meleeing, ranging, lastHit

local function SwingStopped(element)
	local bar = element.__owner

	for _, Bar in pairs({bar.Twohand, bar.Mainhand, bar.Offhand}) do
		if Bar:IsShown() then return end
	end

	bar:Hide()
end

local OnDurationUpdate
do
	local checkElapsed, slamElapsed, slamTime = 0, 0, 0
	local slam = GetSpellInfo(1464)

	function OnDurationUpdate(self, elapsed)
		local now = GetTime()

		if meleeing then
			if checkElapsed > 0.01 then
				if lastHit + self.speed + slamTime < now then
					self:Hide()
					self:SetScript("OnUpdate", nil)
					SwingStopped(self)

					meleeing, ranging = false, false
				end

				checkElapsed = 0
			else
				checkElapsed = checkElapsed + elapsed
			end
		end

		if slam == UnitCastingInfo("player") then
			slamElapsed = slamElapsed + elapsed
			slamTime = slamTime + elapsed
		else
			if slamElapsed ~= 0 then
				self.min = self.min + slamElapsed
				self.max = self.max + slamElapsed

				self:SetMinMaxValues(self.min - now, self.max - now)

				slamElapsed = 0
			end

			if now > self.max then
				if meleeing then
					if lastHit then
						self.min = self.max
						self.max = self.max + self.speed

						self:SetMinMaxValues(self.min - now, self.max - now)

						slamTime = 0
					end
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)

					meleeing, ranging = false, false
				end
			else
				self:SetValue(now - self.min)

				if self.Text then
					self.Text:SetFormattedText("%.1f", self.max - now)
				end
			end
		end
	end
end

local function MeleeChange(self, _, unit)
	if unit ~= "player" then return end
	if not meleeing then return end

	local element = self.Swing
	local now = GetTime()
	local newMainHandID = GetInventoryItemID("player", 16)
	local newOffHandID = GetInventoryItemID("player", 17)
	local mainSpeed, offSpeed = UnitAttackSpeed("player")

	if (mainHandID ~= newMainHandID) or (offHandID ~= newOffHandID) then
		if offSpeed then
			element.Twohand:Hide()
			element.Twohand:SetScript("OnUpdate", nil)

			element.Mainhand.min = GetTime()
			element.Mainhand.max = element.Mainhand.min + mainSpeed
			element.Mainhand.speed = mainSpeed

			element.Mainhand:Show()
			element.Mainhand:SetMinMaxValues(element.Mainhand.min - now, element.Mainhand.max - now)
			element.Mainhand:SetScript("OnUpdate", OnDurationUpdate)

			element.Offhand.min = GetTime()
			element.Offhand.max = element.Offhand.min + offSpeed
			element.Offhand.speed = offSpeed

			element.Offhand:Show()
			element.Offhand:SetMinMaxValues(element.Offhand.min - now, element.Mainhand.max - now)
			element.Offhand:SetScript("OnUpdate", OnDurationUpdate)
		else
			element.Twohand.min = GetTime()
			element.Twohand.max = element.Twohand.min + mainSpeed
			element.Twohand.speed = mainSpeed

			element.Twohand:Show()
			element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
			element.Twohand:SetScript("OnUpdate", OnDurationUpdate)

			element.Mainhand:Hide()
			element.Mainhand:SetScript("OnUpdate", nil)

			element.Offhand:Hide()
			element.Offhand:SetScript("OnUpdate", nil)
		end

		lastHit = now

		mainHandID, offHandID = newMainHandID, newOffHandID
	else
		if offSpeed then
			if element.Mainhand.speed ~= mainSpeed then
				local percentage = (element.Mainhand.max - now) / (element.Mainhand.speed)
				element.Mainhand.min = now - mainSpeed * (1 - percentage)
				element.Mainhand.max = now + mainSpeed * percentage
				element.Mainhand:SetMinMaxValues(element.Mainhand.min - now, element.Mainhand.max - now)
				element.Mainhand.speed = mainSpeed
			end
			if element.Offhand.speed ~= offSpeed then
				local percentage = (element.Offhand.max - now) / (element.Offhand.speed)
				element.Offhand.min = now - offSpeed * (1 - percentage)
				element.Offhand.max = now + offSpeed * percentage
				element.Offhand:SetMinMaxValues(element.Offhand.min - now, element.Offhand.max - now)
				element.Offhand.speed = offSpeed
			end
		else
			if element.Twohand.speed ~= mainSpeed then
				local percentage = (element.Twohand.max - now) / (element.Twohand.speed)
				element.Twohand.min = now - mainSpeed * (1 - percentage)
				element.Twohand.max = now + mainSpeed * percentage
				element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
				element.Twohand.speed = mainSpeed
			end
		end
	end
end

local function RangedChange(self, _, unit)
	if unit ~= "player" then return end
	if not ranging then return end

	local element = self.Swing
	local now = GetTime()
	local newRangedID = GetInventoryItemID("player", 18)
	local speed = UnitRangedDamage("player")

	if rangedID ~= newRangedID then
		element.Twohand.speed = UnitRangedDamage(unit)
		element.Twohand.min = GetTime()
		element.Twohand.max = element.Twohand.min + element.Twohand.speed

		element.Twohand:Show()
		element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
		element.Twohand:SetScript("OnUpdate", OnDurationUpdate)

		rangedID = newRangedID
	else
		if element.Twohand.speed ~= speed then
			local percentage = (element.Twohand.max - GetTime()) / (element.Twohand.speed)
			element.Twohand.min = now - speed * (1 - percentage)
			element.Twohand.max = now + speed * percentage
			element.Twohand.speed = speed
		end
	end
end

local function Ranged(self, _, unit, spellName)
	if unit ~= "player" then return end
	if spellName ~= GetSpellInfo(75) and spellName ~= GetSpellInfo(5019) then return end

	local element = self.Swing
	local now = GetTime()

	element:Show()

	element.Twohand.speed = UnitRangedDamage(unit)
	element.Twohand.min = GetTime()
	element.Twohand.max = element.Twohand.min + element.Twohand.speed

	element.Twohand:Show()
	element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
	element.Twohand:SetScript("OnUpdate", OnDurationUpdate)

	element.Mainhand:Hide()
	element.Mainhand:SetScript("OnUpdate", nil)

	element.Offhand:Hide()
	element.Offhand:SetScript("OnUpdate", nil)

	meleeing, ranging = false, true
end

local function Melee(self, _, _, event, GUID, _, _, _, _, _, _, spellName)
	if UnitGUID("player") ~= GUID then return end
	if not find(event, "SWING") and not find(event, "SPELL_CAST_SUCCESS") then return end
	if find(event, "SPELL_CAST_SUCCESS") then
		if spellName ~= GetSpellInfo(30324) and spellName ~= GetSpellInfo(25231) and spellName ~= GetSpellInfo(27014) and spellName ~= GetSpellInfo(26996) then return end
	end

	local element = self.Swing
	local now = GetTime()

	if not meleeing then
		element:Show()

		for _, Bar in pairs({element.Twohand, element.Mainhand, element.Offhand}) do
			Bar:Hide()
			Bar:SetScript("OnUpdate", nil)
		end

		local mainSpeed, offSpeed = UnitAttackSpeed("player")

		if offSpeed then
			element.Mainhand.min = now
			element.Mainhand.max = element.Mainhand.min + mainSpeed
			element.Mainhand.speed = mainSpeed

			element.Mainhand:Show()
			element.Mainhand:SetMinMaxValues(element.Mainhand.min - now, element.Mainhand.max - now)
			element.Mainhand:SetScript("OnUpdate", OnDurationUpdate)

			element.Offhand.min = now
			element.Offhand.max = element.Offhand.min + offSpeed
			element.Offhand.speed = offSpeed

			element.Offhand:Show()
			element.Offhand:SetMinMaxValues(element.Offhand.min - now, element.Offhand.max - now)
			element.Offhand:SetScript("OnUpdate", OnDurationUpdate)
		else
			element.Twohand.min = now
			element.Twohand.max = element.Twohand.min + mainSpeed
			element.Twohand.speed = mainSpeed

			element.Twohand:Show()
			element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
			element.Twohand:SetScript("OnUpdate", OnDurationUpdate)
		end

		meleeing, ranging = true, false
	end

	lastHit = now
end

local function ParryHaste(self, _, _, subEvent, _, _, _, _, _, tarGUID, _, missType)
	if UnitGUID("player") ~= tarGUID then return end
	if not meleeing then return end
	if not find(subEvent, "MISSED") then return end
	if missType ~= "PARRY" then return end

	local element = self.Swing
	local now = GetTime()
	local _, offSpeed = UnitAttackSpeed("player")

	if offSpeed then
		local percentage = (element.Mainhand.max - now) / element.Mainhand.speed

		if percentage > 0.6 then
			element.Mainhand.max = now + element.Mainhand.speed * 0.6
			element.Mainhand.min = now - (element.Mainhand.max - now) * percentage / (1 - percentage)
			element.Mainhand:SetMinMaxValues(element.Mainhand.min - now, element.Mainhand.max - now)
		elseif percentage > 0.2 then
			element.Mainhand.max = now + element.Mainhand.speed * 0.2
			element.Mainhand.min = now - (element.Mainhand.max - now) * percentage / (1 - percentage)
			element.Mainhand:SetMinMaxValues(element.Mainhand.min - now, element.Mainhand.max - now)
		end

		percentage = (element.Offhand.max - now) / element.Offhand.speed

		if percentage > 0.6 then
			element.Offhand.max = now + element.Offhand.speed * 0.6
			element.Offhand.min = now - (element.Offhand.max - now) * percentage / (1 - percentage)
			element.Offhand:SetMinMaxValues(element.Offhand.min - now, element.Offhand.max - now)
		elseif percentage > 0.2 then
			element.Offhand.max = now + element.Offhand.speed * 0.2
			element.Offhand.min = now - (element.Offhand.max - now) * percentage / (1 - percentage)
			element.Offhand:SetMinMaxValues(element.Offhand.min - now, element.Offhand.max - now)
		end
	else
		local percentage = (element.Twohand.max - now) / element.Twohand.speed

		if percentage > 0.6 then
			element.Twohand.max = now + element.Twohand.speed * 0.6
			element.Twohand.min = now - (element.Twohand.max - now) * percentage / (1 - percentage)
			element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
		elseif percentage > 0.2 then
			element.Twohand.max = now + element.Twohand.speed * 0.2
			element.Twohand.min = now - (element.Twohand.max - now) * percentage / (1 - percentage)
			element.Twohand:SetMinMaxValues(element.Twohand.min - now, element.Twohand.max - now)
		end
	end
end

local function NoCombatHide(self)
	local element = self.Swing

	for _, Bar in pairs({element.Twohand, element.Mainhand, element.Offhand}) do
		Bar:Hide()
	end

	element:Hide()

	meleeing, ranging = false, false
end

local function ToggleTestMode(self)
	local element = self.Swing

	if element.testMode then
		if not (meleeing or ranging) then
			for _, Bar in pairs({element.Twohand, element.Mainhand, element.Offhand}) do
				Bar:Hide()
			end

			element:Hide()
		end

		element.testMode = nil
	end
end

local function Enable(self, unit)
	local element = self.Swing

	if element and unit == "player" then
		for _, Bar in pairs({element.Twohand, element.Mainhand, element.Offhand}) do
			Bar.__owner = element

			if Bar:IsObjectType("StatusBar") and not Bar:GetStatusBarTexture() then
				Bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end

			if Bar.Spark and Bar.Spark:IsObjectType("Texture") and not Bar.Spark:GetTexture() then
				Bar.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			end

			if Bar.Text then
				Bar.Text:SetParent(Bar)
			end
		end

		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
		self:RegisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
		self:RegisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", NoCombatHide)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", ToggleTestMode)

		return true
	end
end

local function Disable(self)
	local element = self.Swing

	if element then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
		self:UnregisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
		self:UnregisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", NoCombatHide)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", ToggleTestMode)

		element:Hide()
	end
end

oUF:AddElement("Swing", nil, Enable, Disable)